// ============================================================================
// El siguiente código define el servicio para el spawn de objetos en el juego
// ============================================================================

import 'dart:math';
import '../models/game_state.dart';
import '../models/power_up.dart';
import '../models/obstacle.dart';
import '../models/car.dart';
import '../models/game_orientation.dart';
import '../constants/game_constants.dart';

/// Servicio especializado para el spawn de objetos en el juego
class SpawnService {
  static SpawnService? _instance;
  static SpawnService get instance => _instance ??= SpawnService._();
  SpawnService._();
  
  final Random _random = Random();

  /// Calcula el centro del carril usando el ancho dinámico de la ventana
  double _getDynamicLaneCenter(GameState state, LanePosition lane) {
    // CONFIGURACIÓN DE MÁRGENES
    const double sideMarginRatio = 0.18;

    double totalSize;

    // Detectamos si estamos en vertical u horizontal para saber qué medida usar
    if (state.orientation == GameOrientation.vertical) {
      totalSize = state.gameAreaSize.width;
    } else {
      totalSize = state.gameAreaSize.height;
    }

    // Si el tamaño es 0, usamos fallback
    if (totalSize <= 0) {
      return state.orientation == GameOrientation.vertical
          ? state.config.getLanePositionX(lane)
          : state.config.getLanePositionY(lane);
    }

    // Calculamos el espacio real de la carretera
    final sideMarginPx = totalSize * sideMarginRatio; // Espacio de la acera en px
    final usableRoadWidth = totalSize - (sideMarginPx * 2); // Espacio útil
    final visualLaneWidth = usableRoadWidth / 3; // Ancho real de cada carril

    final index = LanePosition.values.indexOf(lane);

    return sideMarginPx + (visualLaneWidth * index) + (visualLaneWidth / 2);
  }
  
  /// Genera un elemento aleatorio (obstáculo o power-up)
  void spawnRandomElement(GameState gameState, {double? levelGoalDistance}) {

    // 60% obstáculos, 40% power-ups
    if (_random.nextDouble() < 0.6) {
      spawnObstacle(gameState);
    } else {
      spawnPowerUp(gameState);
    }
  }
  
  /// Verifica si es momento de hacer spawn basado en baseSpawnRate
  bool _shouldSpawn(GameState gameState) {
    final now = DateTime.now();
    if (gameState.lastSpawnTime == null) return false;
    
    final timeSinceLastSpawn = now.difference(gameState.lastSpawnTime!);
    final spawnInterval = Duration(milliseconds: (1000 / GameConstants.baseSpawnRate).round());
    
    return timeSinceLastSpawn < spawnInterval;
  }
  
  /// Genera un power-up en una posición aleatoria usando baseSpawnRate
  void spawnPowerUp(GameState gameState) {
    final lanes = LanePosition.values;
    final randomLane = lanes[_random.nextInt(lanes.length)];
    
    // Verificar si es momento de hacer spawn basado en baseSpawnRate
    if (_shouldSpawn(gameState)) return;
    
    // Calcular posición desde arriba de la pantalla - siempre fuera del área visible
    double x, y;
    if (gameState.orientation == GameOrientation.vertical) {
      x = _getDynamicLaneCenter(gameState, randomLane) - 30;
      y = -100;
    } else {
      x = gameState.gameAreaSize.width + 100;
      y = _getDynamicLaneCenter(gameState, randomLane) - 30;
    }
    
    // Generar power-ups: 35% monedas, 15% combustible, 12% shields, 12% double points, 13% speedBoost, 13% magnet
    PowerUp powerUp;
    final randomValue = _random.nextDouble();
    
    if (randomValue < 0.35) {
      // 35% monedas
      powerUp = PowerUp.coin(
        orientation: gameState.orientation,
        x: x,
        y: y,
        lane: randomLane,
      );
    } else if (randomValue < 0.5) {
      // 15% combustible (0.35 + 0.15 = 0.5)
      powerUp = PowerUp.fuel(
        orientation: gameState.orientation,
        x: x,
        y: y,
        lane: randomLane,
      );
    } else if (randomValue < 0.62) {
      // 12% shields (0.5 + 0.12 = 0.62)
      powerUp = PowerUp.shield(
        orientation: gameState.orientation,
        x: x,
        y: y,
        lane: randomLane,
      );
    } else if (randomValue < 0.74) {
      // 12% double points (0.62 + 0.12 = 0.74)
      powerUp = PowerUp.doublePoints(
        orientation: gameState.orientation,
        x: x,
        y: y,
        lane: randomLane,
      );
    } else if (randomValue < 0.87) {
      // 13% speedBoost (0.74 + 0.13 = 0.87)
      powerUp = PowerUp.speedBoost(
        orientation: gameState.orientation,
        x: x,
        y: y,
        lane: randomLane,
      );
    } else {
      // 13% magnet (0.87 + 0.13 = 1.0)
      powerUp = PowerUp.magnet(
        orientation: gameState.orientation,
        x: x,
        y: y,
        lane: randomLane,
      );
    }
    
    // Agregar a la lista
    gameState.powerUps.add(powerUp);
    
    // Log del tipo de power-up generado
    String powerUpIcon = '';
    switch (powerUp.type) {
      case PowerUpType.coin:
        powerUpIcon = '💰';
        break;
      case PowerUpType.fuel:
        powerUpIcon = '⛽';
        break;
      case PowerUpType.shield:
        powerUpIcon = '🛡️';
        break;
      case PowerUpType.doublepoints:
        powerUpIcon = '⭐';
        break;
      case PowerUpType.speedboost:
        powerUpIcon = '⚡';
        break;
      case PowerUpType.magnet:
        powerUpIcon = '🧲';
        break;
    }
    
    print('$powerUpIcon ${powerUp.type.name} generado en carril ${randomLane.name} desde (${x.toInt()}, ${y.toInt()})');
  }

  /// Genera un obstáculo aleatorio en una posición aleatoria
  void spawnObstacle(GameState gameState) {
    final lanes = LanePosition.values;
    final randomLane = lanes[_random.nextInt(lanes.length)];

    // Calcular posición según orientación
    double x, y;
    if (gameState.orientation == GameOrientation.vertical) {
      x = _getDynamicLaneCenter(gameState, randomLane) - 30; // Usar dinámico
      y = -50;
    } else {
      x = gameState.gameAreaSize.width + 50;
      y = _getDynamicLaneCenter(gameState, randomLane) - 30;
    }

    // Elegir un número aleatorio para decidir qué obstáculo crear
    Obstacle obstacle;
    final randomValue = _random.nextDouble();

    // Probabilidades (puedes ajustarlas a tu gusto):
    // 40% Cono, 20% Aceite, 20% Barrera, 10% Bache, 10% Escombros
    if (randomValue < 0.4) {
      obstacle = Obstacle.cone(
        orientation: gameState.orientation,
        x: x, y: y, lane: randomLane,
      );
    } else if (randomValue < 0.6) {
      obstacle = Obstacle.oilspill(
        orientation: gameState.orientation,
        x: x, y: y, lane: randomLane,
      );
    } else if (randomValue < 0.8) {
      obstacle = Obstacle.barrier(
        orientation: gameState.orientation,
        x: x, y: y, lane: randomLane,
      );
    } else {
      obstacle = Obstacle.debris(
        orientation: gameState.orientation,
        x: x, y: y, lane: randomLane,
      );
    }

    gameState.obstacles.add(obstacle);
    print('⚠️ ${obstacle.type.name} generado en carril ${randomLane.name}');
  }
  
  /// Genera un coche de tráfico
  void spawnTrafficCar(GameState gameState) {
    final lanes = LanePosition.values;
    final randomLane = lanes[_random.nextInt(lanes.length)];

    double x, y;
    // Para los coches el offset suele ser mayor (-40) porque son más anchos
    if (gameState.orientation == GameOrientation.vertical) {
      x = _getDynamicLaneCenter(gameState, randomLane) - 40;
      y = -80;
    } else {
      x = gameState.gameAreaSize.width + 80;
      y = _getDynamicLaneCenter(gameState, randomLane) - 40;
    }

    final trafficCar = Car.traffic(
      orientation: gameState.orientation,
      color: CarColor.values[_random.nextInt(CarColor.values.length)],
      x: x,
      y: y,
      lane: randomLane,
    );

    gameState.trafficCars.add(trafficCar);
  }
  
  /// Calcula el intervalo de spawn dinámico basado en el tiempo de juego
  double calculateSpawnInterval(GameState gameState, double baseInterval) {
    final gameTimeSeconds = gameState.gameTime.inSeconds;
    // Hacer spawn más frecuente con el tiempo (hasta un límite)
    return (baseInterval - (gameTimeSeconds * 0.01)).clamp(0.5, baseInterval);
  }
  
  /// Verifica si es momento de hacer spawn
  bool shouldSpawn(double lastSpawnTime, double spawnInterval) {
    return lastSpawnTime >= spawnInterval;
  }
  
  /// Obtiene probabilidades de spawn basadas en la dificultad
  SpawnProbabilities getSpawnProbabilities(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return SpawnProbabilities(
          obstacle: 0.4,
          powerUp: 0.6,
          trafficCar: 0.1,
        );
      case GameDifficulty.medium:
        return SpawnProbabilities(
          obstacle: 0.6,
          powerUp: 0.4,
          trafficCar: 0.2,
        );
      case GameDifficulty.hard:
        return SpawnProbabilities(
          obstacle: 0.7,
          powerUp: 0.3,
          trafficCar: 0.3,
        );
      case GameDifficulty.expert:
        return SpawnProbabilities(
          obstacle: 0.8,
          powerUp: 0.2,
          trafficCar: 0.4,
        );
    }
  }
  
  /// Variables internas para el spawn timing
  double _lastSpawnTime = 2.0;
  final double _obstacleSpawnInterval = 1.2;
  
  /// Actualiza el sistema de spawn con timing
  /// Acepta la distancia objetivo del nivel para controlar el spawn
  GameState updateSpawning(GameState gameState, double deltaTime, {double? levelGoalDistance}) {
    _lastSpawnTime += deltaTime;
    
    if (_lastSpawnTime >= _obstacleSpawnInterval) {
      var updatedState = gameState;
      spawnRandomElement(updatedState, levelGoalDistance: levelGoalDistance);
      _lastSpawnTime = 0;
      return updatedState;
    }
    
    return gameState;
  }
  
  /// Resetea el timer de spawn
  void resetSpawnTimer() {
    _lastSpawnTime = 0;
  }
}

/// Clase para definir probabilidades de spawn
class SpawnProbabilities {
  final double obstacle;
  final double powerUp;
  final double trafficCar;
  
  const SpawnProbabilities({
    required this.obstacle,
    required this.powerUp,
    required this.trafficCar,
  });
}