// ===========================================================================
// El siguiente código define el estado completo del juego,
// incluyendo configuraciones, puntuación, recursos del jugador,
// objetos del juego, efectos activos y estadísticas de sesión.
// ===========================================================================

import 'package:flutter/foundation.dart';
import 'game_orientation.dart';
import 'car.dart';
import 'obstacle.dart';
import 'power_up.dart';
import '../constants/game_constants.dart';
import '../../services/preferences_service.dart';

/// Estados posibles del juego
enum GameStatus {
  menu,
  playing,
  paused,
  gameOver,
  loading,
}

/// Dificultades del juego
enum GameDifficulty {
  easy,
  medium,
  hard,
  expert,
}

/// Efectos activos en el juego
class ActiveEffect {
  final PowerUpType type;
  final DateTime startTime;
  final Duration duration;
  final dynamic value;
  
  ActiveEffect({
    required this.type,
    required this.startTime,
    required this.duration,
    required this.value,
  });
  
  /// Verifica si el efecto sigue activo
  bool get isActive {
    return DateTime.now().difference(startTime) < duration;
  }
  
  /// Obtiene el tiempo restante del efecto
  Duration get remainingTime {
    final elapsed = DateTime.now().difference(startTime);
    final remaining = duration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }
  
  /// Obtiene el porcentaje restante del efecto (0.0 a 1.0)
  double get remainingPercentage {
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    final total = duration.inMilliseconds;
    final remaining = (total - elapsed) / total;
    return remaining.clamp(0.0, 1.0);
  }
}

/// Estado completo del juego
class GameState {
  // Configuración básica
  final GameStatus status;
  final GameOrientation orientation;
  final GameDifficulty difficulty;
  final OrientationConfig config;
  
  // Puntuación y estadísticas
  final int score;
  final int highScore;
  final int coinsCollected;
  final int obstaclesAvoided;
  final double distanceTraveled;
  final Duration gameTime;
  
  // Recursos del jugador
  final double fuel;
  final int lives;
  final bool hasShield;
  
  // Objetos del juego
  final Car playerCar;
  final List<Car> trafficCars;
  final List<Obstacle> obstacles;
  final List<PowerUp> powerUps;
  
  // Efectos activos
  final List<ActiveEffect> activeEffects;
  
  // Configuración de juego
  final double gameSpeed;
  final double spawnRate;
  final DateTime? lastSpawnTime;
  
  // Estadísticas de sesión
  final DateTime sessionStartTime;
  final int gamesPlayed;
  
  const GameState({
    required this.status,
    required this.orientation,
    required this.difficulty,
    required this.config,
    required this.score,
    required this.highScore,
    required this.coinsCollected,
    required this.obstaclesAvoided,
    required this.distanceTraveled,
    required this.gameTime,
    required this.fuel,
    required this.lives,
    required this.hasShield,
    required this.playerCar,
    required this.trafficCars,
    required this.obstacles,
    required this.powerUps,
    required this.activeEffects,
    required this.gameSpeed,
    required this.spawnRate,
    required this.sessionStartTime,
    required this.gamesPlayed,
    this.lastSpawnTime,
  });
  
  /// Crea un estado inicial del juego
  static Future<GameState> createInitial({
    required GameOrientation orientation,
    required OrientationConfig config,
    GameDifficulty difficulty = GameDifficulty.easy,
  }) async {
    // Cargar el color del coche seleccionado
    final selectedColorName = await PreferencesService.instance.getSelectedCarColor();
    print('🎮 GameState - Color desde preferencias: $selectedColorName');
    
    final selectedColor = CarColor.values.firstWhere(
      (c) => c.name == selectedColorName,
      orElse: () => CarColor.red,
    );
    
    print('🚗 GameState - Color final del jugador: ${selectedColor.name}');
    
    final playerCar = Car.player(
      orientation: orientation,
      color: selectedColor,
      x: config.getLanePositionX(LanePosition.center),
      y: orientation == GameOrientation.vertical 
          ? config.gameAreaHeight * 0.8 
          : config.gameAreaHeight * 0.5,
    );
    
    return GameState(
      status: GameStatus.menu,
      orientation: orientation,
      difficulty: difficulty,
      config: config,
      score: 0,
      highScore: 0,
      coinsCollected: 0,
      obstaclesAvoided: 0,
      distanceTraveled: 0.0,
      gameTime: Duration.zero,
      fuel: 100.0,
      lives: 3,
      hasShield: false,
      playerCar: playerCar,
      trafficCars: [],
      obstacles: [],
      powerUps: [],
      activeEffects: [],
      gameSpeed: 1.0,
      spawnRate: 1.0,
      sessionStartTime: DateTime.now(),
      gamesPlayed: 0,
    );
  }
  
  /// Verifica si el juego está en progreso
  bool get isPlaying => status == GameStatus.playing;
  
  /// Verifica si el juego está pausado
  bool get isPaused => status == GameStatus.paused;
  
  /// Verifica si el juego ha terminado
  bool get isGameOver => status == GameStatus.gameOver;
  
  /// Obtiene el multiplicador de puntos actual
  double get pointsMultiplier {
    double multiplier = 1.0;
    for (final effect in activeEffects) {
      if (effect.type == PowerUpType.doublePoints && effect.isActive) {
        multiplier *= (effect.value as int).toDouble();
      }
    }
    return multiplier;
  }
  
  /// Obtiene el multiplicador de velocidad actual
  double get speedMultiplier {
    double multiplier = 1.0;
    for (final effect in activeEffects) {
      if (effect.type == PowerUpType.speedBoost && effect.isActive) {
        multiplier *= (effect.value as int) / 100.0;
      }
    }
    return multiplier;
  }
  
  /// Verifica si hay un escudo activo
  bool get isShieldActive {
    return activeEffects.any((effect) => 
        effect.type == PowerUpType.shield && effect.isActive) || hasShield;
  }
  
  /// Obtiene el porcentaje de combustible (0.0 a 1.0)
  double get fuelPercentage => (fuel / 100.0).clamp(0.0, 1.0);
  
  /// Verifica si el combustible está crítico
  bool get isFuelCritical => fuel < GameConstants.criticalFuelThreshold;
  
  /// Verifica si el combustible se ha agotado
  bool get isFuelEmpty => fuel <= 0.0;
  
  /// Obtiene la velocidad de juego ajustada por dificultad y efectos
  double get adjustedGameSpeed {
    double speed = gameSpeed;
    
    // Ajuste por dificultad
    switch (difficulty) {
      case GameDifficulty.easy:
        speed *= 0.8;
        break;
      case GameDifficulty.medium:
        speed *= 1.0;
        break;
      case GameDifficulty.hard:
        speed *= 1.3;
        break;
      case GameDifficulty.expert:
        speed *= 1.6;
        break;
    }
    
    // Ajuste por efectos activos
    speed *= speedMultiplier;
    
    return speed;
  }
  
  /// Clona el estado con nuevos valores
  GameState copyWith({
    GameStatus? status,
    GameOrientation? orientation,
    GameDifficulty? difficulty,
    OrientationConfig? config,
    int? score,
    int? highScore,
    int? coinsCollected,
    int? obstaclesAvoided,
    double? distanceTraveled,
    Duration? gameTime,
    double? fuel,
    int? lives,
    bool? hasShield,
    Car? playerCar,
    List<Car>? trafficCars,
    List<Obstacle>? obstacles,
    List<PowerUp>? powerUps,
    List<ActiveEffect>? activeEffects,
    double? gameSpeed,
    double? spawnRate,
    DateTime? lastSpawnTime,
    DateTime? sessionStartTime,
    int? gamesPlayed,
  }) {
    return GameState(
      status: status ?? this.status,
      orientation: orientation ?? this.orientation,
      difficulty: difficulty ?? this.difficulty,
      config: config ?? this.config,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      coinsCollected: coinsCollected ?? this.coinsCollected,
      obstaclesAvoided: obstaclesAvoided ?? this.obstaclesAvoided,
      distanceTraveled: distanceTraveled ?? this.distanceTraveled,
      gameTime: gameTime ?? this.gameTime,
      fuel: fuel ?? this.fuel,
      lives: lives ?? this.lives,
      hasShield: hasShield ?? this.hasShield,
      playerCar: playerCar ?? this.playerCar,
      trafficCars: trafficCars ?? this.trafficCars,
      obstacles: obstacles ?? this.obstacles,
      powerUps: powerUps ?? this.powerUps,
      activeEffects: activeEffects ?? this.activeEffects,
      gameSpeed: gameSpeed ?? this.gameSpeed,
      spawnRate: spawnRate ?? this.spawnRate,
      lastSpawnTime: lastSpawnTime ?? this.lastSpawnTime,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
    );
  }
  
  @override
  String toString() {
    return 'GameState(status: $status, score: $score, fuel: $fuel, objects: ${trafficCars.length + obstacles.length + powerUps.length})';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameState &&
        other.status == status &&
        other.score == score &&
        other.fuel == fuel &&
        listEquals(other.trafficCars, trafficCars) &&
        listEquals(other.obstacles, obstacles) &&
        listEquals(other.powerUps, powerUps);
  }
  
  @override
  int get hashCode {
    return Object.hash(
      status,
      score,
      fuel,
      Object.hashAll(trafficCars),
      Object.hashAll(obstacles),
      Object.hashAll(powerUps),
    );
  }
}