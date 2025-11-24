// ===========================================================================
// El siguiente código define las constantes principales del juego,
// incluyendo configuraciones generales, físicas del juego, sistema de carriles,
// spawning, combustible, puntuación, vidas y daño, efectos y power-ups,
// animaciones, configuración por dificultad, UI, audio y almacenamiento local.
// ===========================================================================

import '../models/game_state.dart';

/// Constantes principales del juego
class GameConstants {
  // === CONFIGURACIÓN GENERAL ===
  static const String gameTitle = 'Car Game App';
  static const String gameVersion = '1.0.0';
  static const int targetFPS = 60;
  
  // === FÍSICA DEL JUEGO ===
  static const double gravity = 9.8;
  static const double friction = 0.98;
  static const double baseSpeed = 200.0; // pixels per second
  
  // === SISTEMA DE CARRILES ===
  static const int laneCount = 3;
  static const double laneWidth = 80.0;
  static const double laneChangeSpeed = 300.0; // pixels per second
  
  // === SPAWNING ===
  static const double baseSpawnRate = 2.0; // objects per second
  static const double minSpawnDistance = 100.0;
  static const double maxSpawnDistance = 300.0;
  
  // === COMBUSTIBLE ===
  static const double maxFuel = 100.0;
  static const double fuelConsumptionRate = 1.5; // per second - Reducido de 5.0 a 1.5 para mayor duración
  static const double criticalFuelThreshold = 20.0;
  static const double fuelRefillAmount = 25.0;
  
  // === PUNTUACIÓN ===
  static const int pointsPerDistance = 1;
  static const int pointsPerCoin = 10;
  static const int pointsPerObstacleAvoided = 5;
  static const int pointsPerFuelCollected = 5;
  
  // === VIDAS Y DAÑO ===
  static const int maxLives = 3;
  static const int obstacleBaseDamage = 20;
  static const int trafficCarDamage = 50;
  
  // === EFECTOS Y POWER-UPS ===
  static const Duration shieldDuration = Duration(seconds: 10);
  static const Duration speedBoostDuration = Duration(seconds: 5);
  static const Duration doublePointsDuration = Duration(seconds: 15);
  static const Duration magnetDuration = Duration(seconds: 8);
  
  static const double speedBoostMultiplier = 1.5;
  static const int doublePointsMultiplier = 2;
  
  // === ANIMACIONES ===
  static const Duration laneChangeDuration = Duration(milliseconds: 200);
  static const Duration explosionDuration = Duration(milliseconds: 500);
  static const Duration coinRotationDuration = Duration(milliseconds: 2000);
  
  // === CONFIGURACIÓN POR DIFICULTAD ===
  static const Map<GameDifficulty, DifficultyConfig> difficultyConfigs = {
    GameDifficulty.easy: DifficultyConfig(
      speedMultiplier: 0.8,
      spawnRateMultiplier: 0.7,
      fuelConsumptionMultiplier: 0.8,
      obstacleChance: 0.3,
      trafficCarChance: 0.2,
      powerUpChance: 0.4,
    ),
    GameDifficulty.medium: DifficultyConfig(
      speedMultiplier: 1.0,
      spawnRateMultiplier: 1.0,
      fuelConsumptionMultiplier: 1.0,
      obstacleChance: 0.4,
      trafficCarChance: 0.3,
      powerUpChance: 0.3,
    ),
    GameDifficulty.hard: DifficultyConfig(
      speedMultiplier: 1.3,
      spawnRateMultiplier: 1.4,
      fuelConsumptionMultiplier: 1.2,
      obstacleChance: 0.5,
      trafficCarChance: 0.4,
      powerUpChance: 0.2,
    ),
    GameDifficulty.expert: DifficultyConfig(
      speedMultiplier: 1.6,
      spawnRateMultiplier: 1.8,
      fuelConsumptionMultiplier: 1.5,
      obstacleChance: 0.6,
      trafficCarChance: 0.5,
      powerUpChance: 0.15,
    ),
  };
  
  // === CONFIGURACIÓN DE UI ===
  static const double hudHeight = 80.0;
  static const double buttonHeight = 50.0;
  static const double borderRadius = 12.0;
  
  // === AUDIO ===
  static const double defaultVolume = 0.7;
  static const double sfxVolume = 0.8;
  static const double musicVolume = 0.5;
  
  // === ALMACENAMIENTO LOCAL ===
  static const String highScoreKey = 'high_score';
  static const String playerNameKey = 'player_name';
  static const String difficultyKey = 'difficulty';
  static const String orientationKey = 'orientation';
  static const String soundEnabledKey = 'sound_enabled';
  static const String musicEnabledKey = 'music_enabled';
  
  // === LÍMITES DE RENDIMIENTO ===
  static const int maxObjectsOnScreen = 20;
  static const int maxParticlesOnScreen = 50;
  static const Duration objectCleanupInterval = Duration(seconds: 5);
}

/// Configuración específica por dificultad
class DifficultyConfig {
  final double speedMultiplier;
  final double spawnRateMultiplier;
  final double fuelConsumptionMultiplier;
  final double obstacleChance;
  final double trafficCarChance;
  final double powerUpChance;
  
  const DifficultyConfig({
    required this.speedMultiplier,
    required this.spawnRateMultiplier,
    required this.fuelConsumptionMultiplier,
    required this.obstacleChance,
    required this.trafficCarChance,
    required this.powerUpChance,
  });
  
  /// Obtiene la velocidad ajustada por dificultad
  double getAdjustedSpeed(double baseSpeed) {
    return baseSpeed * speedMultiplier;
  }
  
  /// Obtiene la tasa de spawn ajustada por dificultad
  double getAdjustedSpawnRate(double baseRate) {
    return baseRate * spawnRateMultiplier;
  }
  
  /// Obtiene el consumo de combustible ajustado por dificultad
  double getAdjustedFuelConsumption(double baseConsumption) {
    return baseConsumption * fuelConsumptionMultiplier;
  }
}