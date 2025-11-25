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
import '../../../core/utils/orientation_helper.dart';
import '../../../core/utils/collision_detector.dart';

// Servicios
import '../../../services/game_service.dart';
import '../../../core/services/spawn_service.dart';
import '../../../core/services/effects_service.dart';
import '../../../core/services/collision_service.dart';

/// Controlador principal del juego
class GameController extends ChangeNotifier {
  GameState _gameState;
  
  // Servicios especializados
  final GameService _gameService = GameService.instance;
  // final PreferencesService _preferencesService = PreferencesService.instance;
  // final AudioService _audioService = AudioService.instance;
  // final OrientationService _orientationService = OrientationService.instance;
  final SpawnService _spawnService = SpawnService.instance;
  final EffectsService _effectsService = EffectsService.instance;
  final CollisionService _collisionService = CollisionService.instance;
  // late final InputController _inputController;
  
  GameController({GameState? initialState}) 
      : _gameState = initialState ?? GameState.initial(
          orientation: GameOrientation.vertical,
          config: OrientationConstants.configs[GameOrientation.vertical]!,
        ) {
    // _inputController = InputController.instance;
  }
  
  GameState get gameState => _gameState;
  
  /// Inicia un nuevo juego
  void startNewGame({
    GameOrientation? orientation,
    GameDifficulty? difficulty,
  }) {
    final newOrientation = orientation ?? _gameState.orientation;
    
    _gameState = _gameService.createInitialGameState(
      orientation: newOrientation,
      difficulty: difficulty ?? GameDifficulty.medium,
    );
    
    // Iniciar el juego inmediatamente
    _gameState = _gameState.copyWith(status: GameStatus.playing);
    
    // Resetear servicios
    _collisionService.resetCooldown();
    
    // El spawn inicial se manejará en el primer update()
    
    notifyListeners();
  }
  

  
  /// Pausa o reanuda el juego
  void togglePause() {
    if (_gameState.isPlaying) {
      _gameState = _gameState.copyWith(status: GameStatus.paused);
    } else if (_gameState.isPaused) {
      _gameState = _gameState.copyWith(status: GameStatus.playing);
    }
    notifyListeners();
  }
  
  /// Cambia la orientación del juego
  void changeOrientation(GameOrientation newOrientation) {
    if (_gameState.orientation == newOrientation) return;
    
    final newConfig = OrientationConstants.configs[newOrientation]!;
    
    // Convertir posición del jugador
    final newPlayerPosition = OrientationHelper.getPlayerStartPosition(
      newOrientation,
      Size(newConfig.gameAreaWidth, newConfig.gameAreaHeight),
    );
    
    final updatedPlayerCar = _gameState.playerCar.copyWith(
      orientation: newOrientation,
      x: newPlayerPosition.dx,
      y: newPlayerPosition.dy,
    );
    
    _gameState = _gameState.copyWith(
      orientation: newOrientation,
      config: newConfig,
      playerCar: updatedPlayerCar,
      // Limpiar objetos existentes al cambiar orientación
      trafficCars: [],
      obstacles: [],
      powerUps: [],
    );
    
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
      
      // Cambio inmediato
      double newX, newY;
      if (_gameState.orientation == GameOrientation.vertical) {
        newX = _gameState.config.getLanePositionX(newLane) - _gameState.playerCar.width / 2;
        newY = _gameState.playerCar.y;
      } else {
        newX = _gameState.playerCar.x;
        newY = _gameState.config.getLanePositionY(newLane) - _gameState.playerCar.height / 2;
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
    _updateSpawning(deltaTime); // Spawning primero para crear nuevos objetos
    _updateGameObjects(deltaTime); // Luego mover los objetos existentes
    _updateGameStats(deltaTime);
    _updateFuel(deltaTime);
    _updateActiveEffects();
    
    // DETECCIÓN DE COLISIONES - Añadido aquí para garantizar que funcione
    _detectAndHandleCollisions();
    
    // Verificar condiciones de game over
    if (_gameState.isFuelEmpty || _gameState.lives <= 0) {
      _gameState = _gameState.copyWith(status: GameStatus.gameOver);
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
      case PowerUpType.speedBoost:
        final scoreResult = ScoreCalculator.calculatePowerUpScore(powerUp, _gameState);
        _addScore(scoreResult.totalPoints);
        _activateSpeedBoost(powerUp.value, powerUp.duration!);
        break;
      case PowerUpType.doublePoints:
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
    
    _gameState = _collisionService.handleSingleCollision(_gameState, collision);
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
        newX += _gameState.adjustedGameSpeed * deltaTime * 60;
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
    _gameState = _spawnService.updateSpawning(_gameState, deltaTime);
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
    _gameState = _effectsService.activateShield(_gameState, duration);
  }
  
  void _activateSpeedBoost(int multiplier, Duration duration) {
    _gameState = _effectsService.activateSpeedBoost(_gameState, multiplier, duration);
  }
  
  void _activateDoublePoints(int multiplier, Duration duration) {
    _gameState = _effectsService.activateDoublePoints(_gameState, multiplier, duration);
  }
  
  void _activateMagnet(Duration duration) {
    final effect = ActiveEffect(
      type: PowerUpType.magnet,
      startTime: DateTime.now(),
      duration: duration,
      value: 1,
    );
    
    final newEffects = [..._gameState.activeEffects, effect];
    _gameState = _gameState.copyWith(activeEffects: newEffects);
  }
  
  /// Verifica si el cooldown de colisiones con obstáculos está activo
  bool get isObstacleCollisionCooldownActive {
    return _collisionService.isObstacleCollisionCooldownActive;
  }
  
  /// Obtiene el tiempo restante del cooldown en millisegundos
  int get obstacleCollisionCooldownRemainingMs {
    return _collisionService.obstacleCollisionCooldownRemainingMs;
  }

  /// Detecta y maneja todas las colisiones del juego usando CollisionService
  void _detectAndHandleCollisions() {
    if (!_gameState.isPlaying) return;        
    
    // Usar un tamaño de área de juego genérico para la detección
    const gameAreaSize = Size(400, 800); // Tamaño aproximado
    
    // Usar el nuevo método integrado que es más eficiente
    _gameState = _collisionService.detectAndHandleCollisions(_gameState, gameAreaSize);
    
    // También limpiar objetos fuera de los límites
    _gameState = _collisionService.cleanupOutOfBoundsObjects(_gameState, gameAreaSize);
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