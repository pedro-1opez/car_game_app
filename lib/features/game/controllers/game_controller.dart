// ===========================================================================
// El siguiente código define el controlador principal del juego,
// que coordina los servicios modularizados para manejar la lógica del juego,
// incluyendo inicio, pausa, actualización del estado, manejo de colisiones,
// recolección de power-ups, y más.
// ===========================================================================

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/models/game_state.dart';
import '../../../core/models/car.dart';
import '../../../core/models/obstacle.dart';
import '../../../core/models/power_up.dart';
import '../../../core/models/game_orientation.dart';
import '../../../core/constants/orientation_config.dart';
import '../../../core/utils/score_calculator.dart';
import '../../../core/utils/collision_detector.dart';

// Servicios
import '../../../services/game_service.dart';
import '../../../core/services/spawn_service.dart';
import '../../../core/services/effects_service.dart';
import '../../../core/services/collision_service.dart';
import '../../../services/audio_service.dart';

/// Controlador principal del juego
class GameController extends ChangeNotifier {
  GameState _gameState;
  
  // Campo opcional para controlar el spawn en niveles
  double? _levelGoalDistance;
  
  // Servicios especializados
  final GameService _gameService = GameService.instance;
  // final PreferencesService _preferencesService = PreferencesService.instance;
  final AudioService _audioService = AudioService.instance;
  // final OrientationService _orientationService = OrientationService.instance;
  final SpawnService _spawnService = SpawnService.instance;
  final EffectsService _effectsService = EffectsService.instance;
  final CollisionService _collisionService = CollisionService.instance;
  // late final InputController _inputController;
  
  GameController._({required GameState initialState}) 
      : _gameState = initialState {
    // _inputController = InputController.instance;
  }
  
  /// Factory method para crear GameController con estado inicial cargado
  static Future<GameController> create({GameState? initialState}) async {
    GameState state;
    
    if (initialState != null) {
      state = initialState;
    } else {
      state = await GameState.createInitial(
        orientation: GameOrientation.vertical,
        config: OrientationConstants.configs[GameOrientation.vertical]!,
      );
    }
    
    return GameController._(initialState: state);
  }
  
  GameState get gameState => _gameState;

  /// Establece la distancia objetivo para un nivel (usado para controlar spawning)
  void setLevelGoalDistance(double goalDistance) {
    _levelGoalDistance = goalDistance;
  }

  /// Limpia la distancia objetivo del nivel (para modo infinito)
  void clearLevelGoalDistance() {
    _levelGoalDistance = null;
  }
  
  /// Inicia un nuevo juego
  Future<void> startNewGame({
    GameOrientation? orientation,
    GameDifficulty? difficulty,
  }) async {
    final newOrientation = orientation ?? _gameState.orientation;
    
    _gameState = await _gameService.createInitialGameState(
      orientation: newOrientation,
      difficulty: difficulty ?? GameDifficulty.medium,
    );
    
    // Iniciar el juego inmediatamente
    _gameState = _gameState.copyWith(status: GameStatus.playing);
    
    // Resetear servicios
    _collisionService.resetCooldown();

    // Iniciar la música
    await AudioService.instance.startMusic();
    
    // El spawn inicial se manejará en el primer update()
    
    notifyListeners();
  }

  void handleResize(Size newSize) {
    if (_gameState.gameAreaSize == newSize) return;

    // Definimos el margen
    const double sideMarginRatio = 0.15;

    // Calculamos el tamaño total según la orientación
    final totalSize = _gameState.orientation == GameOrientation.vertical
        ? newSize.width
        : newSize.height;

    // Calculamos el espacio real restando las dos aceras
    final usableRoadWidth = totalSize * (1 - (sideMarginRatio * 2));

    // El ancho del carril ahora es un tercio del ASFALTO, no de la pantalla
    final newLaneWidth = usableRoadWidth / 3;

    _gameState = _gameState.copyWith(
      gameAreaSize: newSize,
      laneWidth: newLaneWidth,
    );

    _recenterCar();
    notifyListeners();
  }


  /// Pausa o reanuda el juego
  void togglePause() {
    if (_gameState.isPlaying) {
      _gameState = _gameState.copyWith(status: GameStatus.paused);
      // PAUSAR MÚSICA
      _audioService.pauseMusic();
    } else if (_gameState.isPaused) {
      _gameState = _gameState.copyWith(status: GameStatus.playing);
      // REANUDAR MÚSICA
      _audioService.resumeMusic();
    }
    notifyListeners();
  }

  /// Cambia la orientación del juego y ajusta dimensiones inmediatamente
  void changeOrientation(GameOrientation newOrientation) {
    if (_gameState.orientation == newOrientation) return;

    //Obtener la configuración base
    final newConfig = OrientationConstants.configs[newOrientation]!;

    // Invertir las dimensiones actuales
    final newSize = Size(_gameState.gameAreaSize.height, _gameState.gameAreaSize.width);

    // Recalcular el ancho del carril inmediatamente
    final newLaneWidth = newOrientation == GameOrientation.vertical
        ? newSize.width / 3
        : newSize.height / 3;

    // Actualizar el estado COMPLETO
    _gameState = _gameState.copyWith(
      orientation: newOrientation,
      config: newConfig,
      gameAreaSize: newSize, // Guardamos el nuevo tamaño invertido
      laneWidth: newLaneWidth, // Guardamos el nuevo ancho de carril

      // Limpiar objetos existentes para evitar colisiones fantasma durante el giro
      trafficCars: [],
      obstacles: [],
      powerUps: [],
    );

    // Re-centrar el coche en las nuevas coordenadas
    _recenterCar();

    notifyListeners();
  }
  
  /// Cambia el coche del jugador de carril
  void changeLane(int direction) {
    if (!_gameState.isPlaying) return;

    final currentLane = _gameState.playerCar.currentLane;
    final lanes = LanePosition.values;
    final currentIndex = lanes.indexOf(currentLane);
    final newIndex = (currentIndex + direction).clamp(0, lanes.length - 1);

    if (newIndex != currentIndex) {
      final newLane = lanes[newIndex];

      // Configuración de márgenes
      const double sideMarginRatio = 0.15;

      double newX, newY;

      if (_gameState.orientation == GameOrientation.vertical) {
        // Calculamos cuánto mide la acera en píxeles
        final sideMarginPx = _gameState.gameAreaSize.width * sideMarginRatio;

        final laneCenter = sideMarginPx + (_gameState.laneWidth * newIndex) + (_gameState.laneWidth / 2);

        newX = laneCenter - (_gameState.playerCar.width / 2);
        newY = _gameState.playerCar.y;
      } else {
        final sideMarginPx = _gameState.gameAreaSize.height * sideMarginRatio;
        final laneCenter = sideMarginPx + (_gameState.laneWidth * newIndex) + (_gameState.laneWidth / 2);

        newX = _gameState.playerCar.x;
        newY = laneCenter - (_gameState.playerCar.height / 2);
      }

      final updatedCar = _gameState.playerCar.copyWith(
        currentLane: newLane,
        x: newX,
        y: newY,
      );

      _gameState = _gameState.copyWith(playerCar: updatedCar);
      notifyListeners();
    }
  }
  
  /// Actualiza el estado del juego
  void update(double deltaTime) {
    if (!_gameState.isPlaying) return;

    double effectiveDeltaTime = deltaTime;
    if (deltaTime > 0.1) {
      effectiveDeltaTime = 0.016;
    }

    _updateSpawning(effectiveDeltaTime);
    _updateGameObjects(effectiveDeltaTime);
    _updateGameStats(effectiveDeltaTime);
    _updateFuel(effectiveDeltaTime);
    _updateActiveEffects();

    // DETECCIÓN DE COLISIONES
    _detectAndHandleCollisions();
    
    // Verificar condiciones de game over
    if (_gameState.isFuelEmpty || _gameState.lives <= 0) {
      _gameState = _gameState.copyWith(status: GameStatus.gameOver);
      _audioService.stopMusic();
    }
    
    notifyListeners();
  }
  
  /// Maneja la recolección de power-ups
  void collectPowerUp(PowerUp powerUp) {
    if (powerUp.isCollected) return;
    
    // Marcar como recolectado
    powerUp.collect();
    
    // Calcular puntuación y aplicar efectos específicos por tipo
    switch (powerUp.type) {
      case PowerUpType.coin:
        final scoreResult = ScoreCalculator.calculateCoinScore(powerUp, _gameState);
        _addScore(scoreResult.totalPoints);
        _incrementCoinsCollected();                
        break;
      case PowerUpType.fuel:
        final scoreResult = ScoreCalculator.calculateFuelScore(powerUp, _gameState);
        _addFuel(powerUp.value.toDouble());
        _addScore(scoreResult.totalPoints);
        break;
      case PowerUpType.shield:
        final scoreResult = ScoreCalculator.calculatePowerUpScore(powerUp, _gameState);
        _addScore(scoreResult.totalPoints);
        _activateShield(powerUp.duration!);
        break;
      case PowerUpType.speedboost:
        final scoreResult = ScoreCalculator.calculatePowerUpScore(powerUp, _gameState);
        _addScore(scoreResult.totalPoints);
        _activateSpeedBoost(powerUp.value, powerUp.duration!);
        break;
      case PowerUpType.doublepoints:
        final scoreResult = ScoreCalculator.calculatePowerUpScore(powerUp, _gameState);
        _addScore(scoreResult.totalPoints);
        _activateDoublePoints(powerUp.value, powerUp.duration!);
        break;
      case PowerUpType.magnet:
        final scoreResult = ScoreCalculator.calculatePowerUpScore(powerUp, _gameState);
        _addScore(scoreResult.totalPoints);
        _activateMagnet(powerUp.duration!);
        break;
    }
  }
  
  /// Maneja colisión con obstáculo usando CollisionService
  void hitObstacle(Obstacle obstacle) {
    //  REPRODUCIR SONIDO
    switch (obstacle.type) {
      case ObstacleType.cone:
        _audioService.playCone();
        break;
      case ObstacleType.oilspill:
        _audioService.playOilSpill();
        break;
      case ObstacleType.barrier:
        _audioService.playBarrier();
        break;
      case ObstacleType.debris:
        _audioService.playDebris();
        break;
      default:
        break;
    }

    // LÓGICA DE IMPACTO
    final collision = CollisionResult(
      type: CollisionType.carVsObstacle,
      hasCollision: true,
      objectA: _gameState.playerCar,
      objectB: obstacle,
      contactPoint: Offset.zero,
      penetrationDepth: 0.0,
      normal: Offset.zero,
      timestamp: DateTime.now(),
    );

    // Actualizamos el estado con el daño recibido
    _gameState = _collisionService.handleSingleCollision(_gameState, collision);

    // Filtramos la lista para dejar SOLO los que NO sean este obstáculo
    final remainingObstacles = _gameState.obstacles
        .where((obs) => obs.id != obstacle.id)
        .toList();

    _gameState = _gameState.copyWith(obstacles: remainingObstacles);

    notifyListeners();
  }
  
  /// Maneja colisión con coche de tráfico
  void hitTrafficCar(Car trafficCar) {
    hitObstacle(Obstacle(
      id: 'temp_obstacle',
      type: ObstacleType.cone,
      orientation: _gameState.orientation,
      width: 40,
      height: 40,
      assetPath: '',
      damage: 50,
      x: trafficCar.x,
      y: trafficCar.y,
      currentLane: trafficCar.currentLane,
    ));
  }
  
  /// Limpia objetos fuera de los límites y objetos recolectados
  void cleanupOutOfBoundsObjects(Size gameAreaSize) {
    _gameState = _collisionService.cleanupOutOfBoundsObjects(_gameState, gameAreaSize);
  }
  
  // === MÉTODOS PRIVADOS ===
  
  void _updateGameObjects(double deltaTime) {
    // Mover coches de tráfico
    for (final car in _gameState.trafficCars) {
      car.move(deltaTime);
    }
    
    // Mover obstáculos - Crear nuevos obstáculos con posiciones actualizadas
    final updatedObstacles = _gameState.obstacles.map((obstacle) {
      final oldX = obstacle.x;
      final oldY = obstacle.y;
      
      // Calcular nueva posición
      double newX = oldX;
      double newY = oldY;
      if (obstacle.orientation == GameOrientation.vertical) {
        newY += _gameState.adjustedGameSpeed * deltaTime * 60;
      } else {
        newX -= _gameState.adjustedGameSpeed * deltaTime * 60;
      }
      
      // Si la posición cambió, crear nuevo obstáculo
      if (newX != oldX || newY != oldY) {        
        return Obstacle(
          id: obstacle.id,
          type: obstacle.type,
          orientation: obstacle.orientation,
          width: obstacle.width,
          height: obstacle.height,
          assetPath: obstacle.assetPath,
          damage: obstacle.damage,
          x: newX,
          y: newY,
          currentLane: obstacle.currentLane,
          isDestructible: obstacle.isDestructible,
          isVisible: obstacle.isVisible,
          isDestroyed: obstacle.isDestroyed,
          creationTime: obstacle.creationTime,
        );
      }
      return obstacle;
    }).toList();
    
    // Actualizar estado con nuevos obstáculos
    _gameState = _gameState.copyWith(obstacles: updatedObstacles);
    
    // Mover y animar power-ups
    for (final powerUp in _gameState.powerUps) {
      // Aplicar efecto magnético a las monedas si el imán está activo
      if (_effectsService.isMagnetActive(_gameState) && powerUp.type == PowerUpType.coin && !powerUp.isCollected) {
        _applyMagneticForce(powerUp, deltaTime);
      } else {
        powerUp.move(_gameState.adjustedGameSpeed, deltaTime);
      }
      powerUp.updateAnimation(deltaTime);
    }
  }
  
  void _updateGameStats(double deltaTime) {
    _gameState = _gameService.updateGameStats(_gameState, deltaTime);
    
    // Añadir puntos por distancia
    final distance = _gameState.adjustedGameSpeed * deltaTime;
    if (distance > 0) {
      final distanceScore = ScoreCalculator.calculateDistanceScore(
        distance, _gameState
      );
      _addScore(distanceScore.totalPoints);
    }
  }
  
  void _updateSpawning(double deltaTime) {
    _gameState = _spawnService.updateSpawning(
      _gameState, 
      deltaTime, 
      levelGoalDistance: _levelGoalDistance,
    );
  }
  
  void _updateFuel(double deltaTime) {
    _gameState = _gameService.updateFuel(_gameState, deltaTime);
  }
  
  void _updateActiveEffects() {
    _gameState = _effectsService.updateActiveEffects(_gameState);
  }
  
  void _addScore(int points) {
    _gameState = _gameService.addScore(_gameState, points);
  }
  
  void _addFuel(double amount) {
    _gameState = _gameService.addFuel(_gameState, amount);
  }
  
  void _incrementCoinsCollected() {
    _gameState = _gameService.incrementCoinsCollected(_gameState);
  }
  
  void _activateShield(Duration duration) {
    _addOrResetEffect(PowerUpType.shield, 1, duration);
  }
  
  void _activateSpeedBoost(int multiplier, Duration duration) {
    _addOrResetEffect(PowerUpType.speedboost, multiplier, duration);
  }
  
  void _activateDoublePoints(int multiplier, Duration duration) {
    _addOrResetEffect(PowerUpType.doublepoints, multiplier, duration);
  }
  
  void _activateMagnet(Duration duration) {
    _addOrResetEffect(PowerUpType.magnet, 1, duration);
  }

  /// Recalcula la posición del coche para que quede centrado en su carril actual
  /// después de un cambio de tamaño de pantalla.
  void _recenterCar() {
    if (_gameState.laneWidth <= 0) return;

    final currentLane = _gameState.playerCar.currentLane;
    final lanes = LanePosition.values;
    final laneIndex = lanes.indexOf(currentLane);

    const double sideMarginRatio = 0.15;

    double newX, newY;

    if (_gameState.orientation == GameOrientation.vertical) {
      final sideMarginPx = _gameState.gameAreaSize.width * sideMarginRatio;

      final laneCenter = sideMarginPx + (_gameState.laneWidth * laneIndex) + (_gameState.laneWidth / 2);

      newX = laneCenter - (_gameState.playerCar.width / 2);
      newY = _gameState.gameAreaSize.height * 0.8;

      if (newY < 100) newY = 300;
    } else {
      final sideMarginPx = _gameState.gameAreaSize.height * sideMarginRatio;
      final laneCenter = sideMarginPx + (_gameState.laneWidth * laneIndex) + (_gameState.laneWidth / 2);

      newX = 100.0;
      if (newX < 50) newX = 100;
      newY = laneCenter - (_gameState.playerCar.height / 2);
    }

    final updatedCar = _gameState.playerCar.copyWith(
      x: newX,
      y: newY,
      orientation: _gameState.orientation,
    );

    _gameState = _gameState.copyWith(playerCar: updatedCar);
  }
  
  /// Verifica si el cooldown de colisiones con obstáculos está activo
  bool get isObstacleCollisionCooldownActive {
    return _collisionService.isObstacleCollisionCooldownActive;
  }
  
  /// Obtiene el tiempo restante del cooldown en millisegundos
  int get obstacleCollisionCooldownRemainingMs {
    return _collisionService.obstacleCollisionCooldownRemainingMs;
  }

  /// Método auxiliar inteligente: Si el efecto existe, lo reinicia. Si no, lo agrega.
  void _addOrResetEffect(PowerUpType type, dynamic value, Duration duration) {
    final now = DateTime.now();

    // Buscamos si ya existe un efecto de este tipo
    final existingIndex = _gameState.activeEffects.indexWhere((e) => e.type == type);

    List<ActiveEffect> newEffects;

    if (existingIndex != -1) {
      // CASO A: Ya existe. Lo reemplazamos por uno nuevo (reiniciando el tiempo)
      // Copiamos la lista actual
      newEffects = List.from(_gameState.activeEffects);

      // Reemplazamos el elemento existente con uno nuevo (tiempo reseteado a 'now')
      newEffects[existingIndex] = ActiveEffect(
        type: type,
        value: value,
        duration: duration,
        startTime: now,
      );

      print('🔄 Efecto ${type.name} reiniciado! Tiempo extendido.');
    } else {
      // CASO B: No existe. Lo agregamos normalmente al final.
      final effect = ActiveEffect(
        type: type,
        value: value,
        duration: duration,
        startTime: now,
      );
      newEffects = [..._gameState.activeEffects, effect];

      print('✨ Nuevo efecto ${type.name} activado.');
    }

    // Actualizamos el estado con la lista corregida
    _gameState = _gameState.copyWith(activeEffects: newEffects);
  }

  /// Detecta y maneja todas las colisiones del juego usando CollisionService
  void _detectAndHandleCollisions() {
    if (!_gameState.isPlaying) return;

    // Usamos el Detector para buscar colisiones activas
    final collisions = CollisionDetector.detectAllCollisions(
      playerCar: _gameState.playerCar,
      trafficCars: _gameState.trafficCars,
      obstacles: _gameState.obstacles,
      powerUps: _gameState.powerUps,
      gameAreaSize: _gameState.gameAreaSize,
      orientation: _gameState.orientation,
    );

    // Si encontramos colisiones, llamamos a los métodos que tienen SONIDO y LÓGICA
    for (final collision in collisions) {
      if (!collision.hasCollision) continue;

      switch (collision.type) {
        case CollisionType.carVsObstacle:
          hitObstacle(collision.objectB as Obstacle);
          break;
        case CollisionType.carVsCar:
          hitTrafficCar(collision.objectB as Car);
          break;
        case CollisionType.carVsPowerUp:
          collectPowerUp(collision.objectB as PowerUp);
          break;
        default:
          break;
      }
    }

    // Limpiar objetos fuera de los límites (Esto se mantiene igual)
    _gameState = _collisionService.cleanupOutOfBoundsObjects(_gameState, _gameState.gameAreaSize);
  }
  
  /// Aplica fuerza magnética a una moneda para atraerla hacia el jugador
  void _applyMagneticForce(PowerUp coin, double deltaTime) {
    final playerX = _gameState.playerCar.x + _gameState.playerCar.width / 2;
    final playerY = _gameState.playerCar.y + _gameState.playerCar.height / 2;
    final coinX = coin.x + coin.width / 2;
    final coinY = coin.y + coin.height / 2;
    
    // Calcular distancia y dirección hacia el jugador
    final dx = playerX - coinX;
    final dy = playerY - coinY;
    final distance = math.sqrt(dx * dx + dy * dy);
    
    // Solo aplicar fuerza magnética si la moneda está dentro del rango
    const magneticRange = 200.0; // Rango ampliado del efecto magnético
    if (distance < magneticRange && distance > 0) {
      // Normalizar la dirección
      final normalizedDx = dx / distance;
      final normalizedDy = dy / distance;
      
      // Fuerza magnética más fuerte cuando está más cerca
      final magneticStrength = (magneticRange - distance) / magneticRange;
      const magneticSpeed = 200.0; // Velocidad base de atracción
      
      // Aplicar movimiento magnético
      final magneticForceX = normalizedDx * magneticSpeed * magneticStrength * deltaTime * 60;
      final magneticForceY = normalizedDy * magneticSpeed * magneticStrength * deltaTime * 60;
      
      coin.x += magneticForceX;
      coin.y += magneticForceY;
    } else {
      // Fuera del rango magnético, mover normalmente
      coin.move(_gameState.adjustedGameSpeed, deltaTime);
    }
  }
  
}