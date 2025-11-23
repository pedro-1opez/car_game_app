import 'package:flutter/material.dart';
import '../../../core/models/game_state.dart';
import '../../../core/models/car.dart';
import '../../../core/models/obstacle.dart';
import '../../../core/models/power_up.dart';
import '../../../core/models/game_orientation.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/constants/orientation_config.dart';
import '../../../core/utils/score_calculator.dart';
import '../../../core/utils/orientation_helper.dart';

/// Controlador principal del juego que maneja toda la lógica
class GameController extends ChangeNotifier {
  GameState _gameState;
  
  // Variables para controlar el spawn de elementos
  double _lastSpawnTime = 2.0; // Comenzar por encima del intervalo para spawn inmediato
  double _obstacleSpawnInterval = 1.0; // segundos - spawn más rápido
  
  GameController({GameState? initialState}) 
      : _gameState = initialState ?? GameState.initial(
          orientation: GameOrientation.vertical,
          config: OrientationConstants.configs[GameOrientation.vertical]!,
        );
  
  GameState get gameState => _gameState;
  
  /// Inicia un nuevo juego
  void startNewGame({
    GameOrientation? orientation,
    GameDifficulty? difficulty,
  }) {
    final newOrientation = orientation ?? _gameState.orientation;
    final config = OrientationConstants.configs[newOrientation]!;
    
    _gameState = GameState.initial(
      orientation: newOrientation,
      config: config,
      difficulty: difficulty ?? GameDifficulty.medium,
    );
    
    // Iniciar el juego inmediatamente
    _gameState = _gameState.copyWith(status: GameStatus.playing);
    
    // Reiniciar variables de spawn
    _lastSpawnTime = 0;
    
    // Crear un obstáculo inicial para visibilidad inmediata
    _createInitialObstacle();
    
    notifyListeners();
  }
  
  /// Crea un obstáculo inicial para visibilidad inmediata
  void _createInitialObstacle() {
    // Elegir un carril aleatorio
    final randomLane = LanePosition.values[DateTime.now().millisecondsSinceEpoch % 3];
    
    // Calcular posición según orientación
    double x, y;
    if (_gameState.orientation == GameOrientation.vertical) {
      x = _gameState.config.getLanePositionX(randomLane) - 30; // -30 para centrar
      y = -50; // Aparecer arriba de la pantalla
    } else {
      x = -50; // Aparecer a la izquierda de la pantalla
      y = _gameState.config.getLanePositionY(randomLane) - 30; // -30 para centrar
    }
    
    final obstacle = Obstacle.cone(
      orientation: _gameState.orientation,
      x: x,
      y: y,
      lane: randomLane,
    );
    
    _gameState = _gameState.copyWith(
      obstacles: [obstacle],
    );        
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
    if (!_gameState.isPlaying) {      
      return;
    }
        
    _updateSpawning(deltaTime); // Spawning primero para crear nuevos objetos
    _updateGameObjects(deltaTime); // Luego mover los objetos existentes
    _updateGameStats(deltaTime);
    _updateFuel(deltaTime);
    _updateActiveEffects();
    
    // Verificar condiciones de game over
    if (_gameState.isFuelEmpty || _gameState.lives <= 0) {
      _gameState = _gameState.copyWith(status: GameStatus.gameOver);
    }
    
    notifyListeners();
  }  /// Maneja la recolección de power-ups
  void collectPowerUp(PowerUp powerUp) {
    if (powerUp.isCollected) return;
    
    // Marcar como recolectado
    powerUp.collect();
    
    // Calcular puntuación
    final scoreResult = ScoreCalculator.calculatePowerUpScore(powerUp, _gameState);
    
    // Aplicar efectos
    switch (powerUp.type) {
      case PowerUpType.coin:
        _addScore(scoreResult.totalPoints);
        _incrementCoinsCollected();
        break;
      case PowerUpType.fuel:
        _addFuel(powerUp.value.toDouble());
        _addScore(scoreResult.totalPoints);
        break;
      case PowerUpType.shield:
        _activateShield(powerUp.duration!);
        break;
      case PowerUpType.speedBoost:
        _activateSpeedBoost(powerUp.value, powerUp.duration!);
        break;
      case PowerUpType.doublePoints:
        _activateDoublePoints(powerUp.value, powerUp.duration!);
        break;
      case PowerUpType.magnet:
        _activateMagnet(powerUp.duration!);
        break;
    }
  }
  
  /// Maneja colisión con obstáculo
  void hitObstacle(Obstacle obstacle) {
    if (_gameState.isShieldActive) {
      // El escudo absorbe el golpe
      _deactivateShield();
      return;
    }
    
    // Reducir vidas
    final newLives = (_gameState.lives - 1).clamp(0, GameConstants.maxLives);
    
    // Marcar coche como colisionando
    final updatedCar = _gameState.playerCar.copyWith(isColliding: true);
    
    _gameState = _gameState.copyWith(
      lives: newLives,
      playerCar: updatedCar,
    );
    
    // Resetear colisión después de un tiempo
    Future.delayed(const Duration(milliseconds: 500), () {
      final resetCar = _gameState.playerCar.copyWith(isColliding: false);
      _gameState = _gameState.copyWith(playerCar: resetCar);
      notifyListeners();
    });
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
  
  /// Limpia objetos fuera de los límites
  void cleanupOutOfBoundsObjects(Size gameAreaSize) {
    // Crear nuevas listas sin objetos fuera de pantalla
    final newTrafficCars = _gameState.trafficCars
        .where((car) => !car.isOutOfBounds(gameAreaSize))
        .toList();
    
    final newObstacles = _gameState.obstacles
        .where((obstacle) => !obstacle.isOutOfBounds(gameAreaSize))
        .toList();
    
    final newPowerUps = _gameState.powerUps
        .where((powerUp) => !powerUp.isOutOfBounds(gameAreaSize))
        .toList();
    
    // Actualizar estado solo si algo cambió
    if (newTrafficCars.length != _gameState.trafficCars.length ||
        newObstacles.length != _gameState.obstacles.length ||
        newPowerUps.length != _gameState.powerUps.length) {
      _gameState = _gameState.copyWith(
        trafficCars: newTrafficCars,
        obstacles: newObstacles,
        powerUps: newPowerUps,
      );
    }
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
      powerUp.move(_gameState.adjustedGameSpeed, deltaTime);
      powerUp.updateAnimation(deltaTime);
    }
  }
  
  void _updateGameStats(double deltaTime) {
    final distance = _gameState.adjustedGameSpeed * deltaTime;
    final newGameTime = _gameState.gameTime + Duration(
      milliseconds: (deltaTime * 1000).round(),
    );
    
    _gameState = _gameState.copyWith(
      distanceTraveled: _gameState.distanceTraveled + distance,
      gameTime: newGameTime,
    );
    
    // Añadir puntos por distancia
    if (distance > 0) {
      final distanceScore = ScoreCalculator.calculateDistanceScore(
        distance, _gameState
      );
      _addScore(distanceScore.totalPoints);
    }
  }
  
  void _updateSpawning(double deltaTime) {
    _lastSpawnTime += deltaTime;
    
    // Spawn obstáculos más frecuentemente
    if (_lastSpawnTime >= _obstacleSpawnInterval) {
      _spawnObstacle();
      _lastSpawnTime = 0;
      
      // Ajustar intervalos basados en el tiempo de juego (más rápido con el tiempo)
      final gameTimeSeconds = _gameState.gameTime.inSeconds;
      _obstacleSpawnInterval = (1.5 - (gameTimeSeconds * 0.01)).clamp(0.5, 1.5);
    }
    
    // Spawn power-ups ocasionalmente
    if (_gameState.gameTime.inSeconds % 8 == 0 && _gameState.gameTime.inMilliseconds % 1000 < 50) {
      _spawnPowerUp();
    }
    
    // Spawn coches de tráfico ocasionalmente
    if (_gameState.gameTime.inSeconds % 5 == 0 && _gameState.gameTime.inMilliseconds % 1000 < 50) {
      _spawnTrafficCar();
    }
  }
  
  void _spawnPowerUp() {
    final spawnZone = OrientationHelper.getSpawnZone(
      _gameState.orientation,
      Size(_gameState.config.gameAreaWidth, _gameState.config.gameAreaHeight),
    );
    
    final powerUp = PowerUp.coin(
      orientation: _gameState.orientation,
      x: spawnZone.left + (spawnZone.width * 0.5),
      y: spawnZone.top + (spawnZone.height * 0.5),
      lane: LanePosition.values[DateTime.now().millisecondsSinceEpoch % 3],
    );
    
    _gameState.powerUps.add(powerUp);
  }
  
  void _spawnObstacle() {
    // Elegir un carril aleatorio
    final randomLane = LanePosition.values[DateTime.now().millisecondsSinceEpoch % 3];
    
    // Calcular posición según orientación
    double x, y;
    if (_gameState.orientation == GameOrientation.vertical) {
      x = _gameState.config.getLanePositionX(randomLane) - 30; // -30 para centrar
      y = -50; // Aparecer arriba de la pantalla
    } else {
      x = -50; // Aparecer a la izquierda de la pantalla
      y = _gameState.config.getLanePositionY(randomLane) - 30; // -30 para centrar
    }
    
    final obstacle = Obstacle.cone(
      orientation: _gameState.orientation,
      x: x,
      y: y,
      lane: randomLane,
    );
    
    // Crear nueva lista con el obstáculo agregado
    final newObstacles = List<Obstacle>.from(_gameState.obstacles)..add(obstacle);
    _gameState = _gameState.copyWith(obstacles: newObstacles);
  }
  
  void _spawnTrafficCar() {
    final spawnZone = OrientationHelper.getSpawnZone(
      _gameState.orientation,
      Size(_gameState.config.gameAreaWidth, _gameState.config.gameAreaHeight),
    );
    
    final trafficCar = Car.traffic(
      orientation: _gameState.orientation,
      color: CarColor.values[DateTime.now().millisecondsSinceEpoch % CarColor.values.length],
      x: spawnZone.left + (spawnZone.width * 0.5),
      y: spawnZone.top + (spawnZone.height * 0.5),
      lane: LanePosition.values[DateTime.now().millisecondsSinceEpoch % 3],
    );
    
    _gameState.trafficCars.add(trafficCar);
  }
  
  void _updateFuel(double deltaTime) {
    final consumption = GameConstants.fuelConsumptionRate * deltaTime;
    final newFuel = (_gameState.fuel - consumption).clamp(0.0, 100.0);
    
    _gameState = _gameState.copyWith(fuel: newFuel);
  }
  
  void _updateActiveEffects() {
    // Filtrar efectos expirados
    final activeEffects = _gameState.activeEffects
        .where((effect) => effect.isActive)
        .toList();
    
    _gameState = _gameState.copyWith(activeEffects: activeEffects);
  }
  
  void _addScore(int points) {
    final newScore = _gameState.score + points;
    final newHighScore = newScore > _gameState.highScore ? newScore : _gameState.highScore;
    
    _gameState = _gameState.copyWith(
      score: newScore,
      highScore: newHighScore,
    );
  }
  
  void _addFuel(double amount) {
    final newFuel = (_gameState.fuel + amount).clamp(0.0, 100.0);
    _gameState = _gameState.copyWith(fuel: newFuel);
  }
  
  void _incrementCoinsCollected() {
    _gameState = _gameState.copyWith(
      coinsCollected: _gameState.coinsCollected + 1,
    );
  }
  
  void _activateShield(Duration duration) {
    final effect = ActiveEffect(
      type: PowerUpType.shield,
      startTime: DateTime.now(),
      duration: duration,
      value: 1,
    );
    
    final newEffects = [..._gameState.activeEffects, effect];
    _gameState = _gameState.copyWith(
      activeEffects: newEffects,
      hasShield: true,
    );
  }
  
  void _deactivateShield() {
    final newEffects = _gameState.activeEffects
        .where((effect) => effect.type != PowerUpType.shield)
        .toList();
    
    _gameState = _gameState.copyWith(
      activeEffects: newEffects,
      hasShield: false,
    );
  }
  
  void _activateSpeedBoost(int multiplier, Duration duration) {
    final effect = ActiveEffect(
      type: PowerUpType.speedBoost,
      startTime: DateTime.now(),
      duration: duration,
      value: multiplier,
    );
    
    final newEffects = [..._gameState.activeEffects, effect];
    _gameState = _gameState.copyWith(activeEffects: newEffects);
  }
  
  void _activateDoublePoints(int multiplier, Duration duration) {
    final effect = ActiveEffect(
      type: PowerUpType.doublePoints,
      startTime: DateTime.now(),
      duration: duration,
      value: multiplier,
    );
    
    final newEffects = [..._gameState.activeEffects, effect];
    _gameState = _gameState.copyWith(activeEffects: newEffects);
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
}