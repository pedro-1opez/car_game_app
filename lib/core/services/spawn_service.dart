// ============================================================================
// El siguiente código define el servicio para el spawn de objetos en el juego
// ============================================================================

import 'dart:math';
import 'package:flutter/material.dart';
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
    const double sideMarginRatio = 0.18;
    double totalSize;

    if (state.orientation == GameOrientation.vertical) {
      totalSize = state.gameAreaSize.width;
    } else {
      totalSize = state.gameAreaSize.height;
    }

    if (totalSize <= 0) {
      return state.orientation == GameOrientation.vertical
          ? state.config.getLanePositionX(lane)
          : state.config.getLanePositionY(lane);
    }

    final sideMarginPx = totalSize * sideMarginRatio;
    final usableRoadWidth = totalSize - (sideMarginPx * 2);
    final visualLaneWidth = usableRoadWidth / 3;

    final index = LanePosition.values.indexOf(lane);
    return sideMarginPx + (visualLaneWidth * index) + (visualLaneWidth / 2);
  }

  /// Verifica si colocar un objeto en [newRect] se superpone con algo existente.
  bool _isPositionSafe(GameState state, Rect newRect) {
    // Margen de seguridad para evitar que las cosas estén "pegadas"
    final safeRect = newRect.inflate(20);

    // Checar colisión con Obstáculos existentes
    for (final obs in state.obstacles) {
      if (!obs.isDestroyed && obs.isVisible) {
        if (obs.getCollisionRect().overlaps(safeRect)) return false;
      }
    }

    // Checar colisión con PowerUps existentes
    for (final pu in state.powerUps) {
      if (!pu.isCollected && pu.isVisible) {
        if (pu.getCollisionRect().overlaps(safeRect)) return false;
      }
    }

    // 3. Checar colisión con Tráfico
    for (final car in state.trafficCars) {
      if (car.getCollisionRect().inflate(30).overlaps(safeRect)) return false; // Tráfico necesita más aire
    }

    return true;
  }

  /// Lógica Anti-Trampa: Verifica si poner un obstáculo en [targetLane] bloquearía el ÚNICO paso libre.
  /// Retorna true si spawnear aquí crearía una pared imposible.
  bool _wouldBlockPath(GameState state, LanePosition targetLane, double spawnCoord) {
    // Definimos una "ventana de peligro". Si hay obstáculos en esa distancia, cuentan como bloqueo.
    const double dangerZone = 500.0;

    final blockedLanes = <LanePosition>{};

    // Revisar qué carriles tienen obstáculos cerca del punto de spawn
    for (final obs in state.obstacles) {
      if (obs.isDestroyed || !obs.isVisible) continue;

      double distance;
      if (state.orientation == GameOrientation.vertical) {
        // Distancia en Y
        distance = (obs.y - spawnCoord).abs();
      } else {
        // Distancia en X (horizontal)
        distance = (obs.x - spawnCoord).abs();
      }

      if (distance < dangerZone) {
        blockedLanes.add(obs.currentLane);
      }
    }

    // Si ya hay obstáculos en 2 carriles (y no son el que queremos usar ahora)
    // Significa que los otros 2 están bloqueados. Si ponemos uno en el 3ro, cerramos el paso.
    if (blockedLanes.length >= (LanePosition.values.length - 1)) {
      if (!blockedLanes.contains(targetLane)) {
        return true;
      }
    }
    return false;
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

  bool _shouldSpawn(GameState gameState) {
    final now = DateTime.now();
    if (gameState.lastSpawnTime == null) return false;

    final timeSinceLastSpawn = now.difference(gameState.lastSpawnTime!);
    final spawnInterval = Duration(milliseconds: (1000 / GameConstants.baseSpawnRate).round());

    return timeSinceLastSpawn < spawnInterval;
  }

  /// Genera un power-up asegurando que no caiga sobre un obstáculo
  void spawnPowerUp(GameState gameState) {
    if (_shouldSpawn(gameState)) return;

    final lanes = LanePosition.values;
    for (int i = 0; i < 3; i++) {
      final randomLane = lanes[_random.nextInt(lanes.length)];

      double x, y;
      if (gameState.orientation == GameOrientation.vertical) {
        x = _getDynamicLaneCenter(gameState, randomLane) - 30;
        y = -100;
      } else {
        x = gameState.gameAreaSize.width + 100;
        y = _getDynamicLaneCenter(gameState, randomLane) - 30;
      }

      // Creamos un rect temporal para validar la posición
      // Asumimos un tamaño promedio de powerup (60x60) para la prueba
      final testRect = Rect.fromLTWH(x, y, 60, 60);

      if (!_isPositionSafe(gameState, testRect)) {
        // Si no es seguro, intentamos otro ciclo del loop (otra posición)
        continue;
      }

      // Si es seguro, procedemos a crear el objeto
      _createAndAddPowerUp(gameState, randomLane, x, y);
      return; // Salimos después de crear uno exitosamente
    }
  }

  // Método auxiliar para la creación pura del objeto (movido para limpieza)
  void _createAndAddPowerUp(GameState gameState, LanePosition lane, double x, double y) {
    PowerUp powerUp;
    final randomValue = _random.nextDouble();

    if (randomValue < 0.35) {
      powerUp = PowerUp.coin(orientation: gameState.orientation, x: x, y: y, lane: lane);
    } else if (randomValue < 0.5) {
      powerUp = PowerUp.fuel(orientation: gameState.orientation, x: x, y: y, lane: lane);
    } else if (randomValue < 0.62) {
      powerUp = PowerUp.shield(orientation: gameState.orientation, x: x, y: y, lane: lane);
    } else if (randomValue < 0.74) {
      powerUp = PowerUp.doublePoints(orientation: gameState.orientation, x: x, y: y, lane: lane);
    } else if (randomValue < 0.87) {
      powerUp = PowerUp.speedBoost(orientation: gameState.orientation, x: x, y: y, lane: lane);
    } else {
      powerUp = PowerUp.magnet(orientation: gameState.orientation, x: x, y: y, lane: lane);
    }

    gameState.powerUps.add(powerUp);
    print('✨ PowerUp generado en ${lane.name}');
  }

  /// Genera un obstáculo con validación Anti-Trampa
  void spawnObstacle(GameState gameState) {
    final lanes = LanePosition.values;

    // Intentamos encontrar un carril válido
    // Barajamos los carriles para probar en orden aleatorio pero exhaustivo
    final shuffledLanes = List<LanePosition>.from(lanes)..shuffle(_random);

    for (final lane in shuffledLanes) {
      double x, y;
      if (gameState.orientation == GameOrientation.vertical) {
        x = _getDynamicLaneCenter(gameState, lane) - 30;
        y = -50;
      } else {
        x = gameState.gameAreaSize.width + 50;
        y = _getDynamicLaneCenter(gameState, lane) - 30;
      }

      // Validación Anti-Trampa
      double spawnCoord = (gameState.orientation == GameOrientation.vertical) ? y : x;
      if (_wouldBlockPath(gameState, lane, spawnCoord)) {
        // Si bloquea el último camino, probamos el siguiente carril de la lista
        continue;
      }

      // Validación de Superposición
      final testRect = Rect.fromLTWH(x, y, 60, 60); // Tamaño aprox obstáculo
      if (!_isPositionSafe(gameState, testRect)) {
        continue;
      }

      // Si pasamos ambas pruebas, creamos el obstáculo
      _createAndAddObstacle(gameState, lane, x, y);
      return;
    }

    // Si ningún carril fue válido, no spawneamos nada
    print("Spawn de obstáculo cancelado para evitar trampa imposible.");
  }

  void _createAndAddObstacle(GameState gameState, LanePosition lane, double x, double y) {
    Obstacle obstacle;
    final randomValue = _random.nextDouble();

    if (randomValue < 0.4) {
      obstacle = Obstacle.cone(orientation: gameState.orientation, x: x, y: y, lane: lane);
    } else if (randomValue < 0.6) {
      obstacle = Obstacle.oilspill(orientation: gameState.orientation, x: x, y: y, lane: lane);
    } else if (randomValue < 0.8) {
      obstacle = Obstacle.barrier(orientation: gameState.orientation, x: x, y: y, lane: lane);
    } else {
      obstacle = Obstacle.debris(orientation: gameState.orientation, x: x, y: y, lane: lane);
    }

    gameState.obstacles.add(obstacle);
    print('⚠️ ${obstacle.type.name} generado en carril ${lane.name}');
  }

  /// Genera un coche de tráfico (también debería validar, pero es menos crítico)
  void spawnTrafficCar(GameState gameState) {
    final lanes = LanePosition.values;
    final randomLane = lanes[_random.nextInt(lanes.length)];

    double x, y;
    if (gameState.orientation == GameOrientation.vertical) {
      x = _getDynamicLaneCenter(gameState, randomLane) - 40;
      y = -80;
    } else {
      x = gameState.gameAreaSize.width + 80;
      y = _getDynamicLaneCenter(gameState, randomLane) - 40;
    }

    // Validación básica para coches también
    final testRect = Rect.fromLTWH(x, y, 80, 160); // Coche es más grande
    if (!_isPositionSafe(gameState, testRect)) return;

    final trafficCar = Car.traffic(
      orientation: gameState.orientation,
      color: CarColor.values[_random.nextInt(CarColor.values.length)],
      x: x,
      y: y,
      lane: randomLane,
    );

    gameState.trafficCars.add(trafficCar);
  }

  double calculateSpawnInterval(GameState gameState, double baseInterval) {
    final gameTimeSeconds = gameState.gameTime.inSeconds;
    return (baseInterval - (gameTimeSeconds * 0.01)).clamp(0.5, baseInterval);
  }

  bool shouldSpawn(double lastSpawnTime, double spawnInterval) {
    return lastSpawnTime >= spawnInterval;
  }

  SpawnProbabilities getSpawnProbabilities(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return SpawnProbabilities(obstacle: 0.4, powerUp: 0.6, trafficCar: 0.1);
      case GameDifficulty.medium:
        return SpawnProbabilities(obstacle: 0.6, powerUp: 0.4, trafficCar: 0.2);
      case GameDifficulty.hard:
        return SpawnProbabilities(obstacle: 0.7, powerUp: 0.3, trafficCar: 0.3);
      case GameDifficulty.expert:
        return SpawnProbabilities(obstacle: 0.8, powerUp: 0.2, trafficCar: 0.4);
    }
  }

  double _lastSpawnTime = 2.0;
  final double _obstacleSpawnInterval = 1.2;

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

  void resetSpawnTimer() {
    _lastSpawnTime = 0;
  }
}

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