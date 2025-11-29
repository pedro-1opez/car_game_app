// ===========================================================================
// Modelo de estado para el modo de niveles
// Maneja el progreso, objetivos y condiciones de victoria/derrota
// ===========================================================================

import 'dart:math' as math;
import 'game_level.dart';

enum LevelStatus {
  notStarted,
  inProgress,
  completed,
  failed,
  reachedGoal, // Llegó a la meta pero aún no se evalúa las monedas
}

class LevelState {
  final GameLevel level;
  final double distanceTraveled;
  final int coinsCollected;
  final LevelStatus status;
  final bool showGasStation;
  final double progressPercentage;

  const LevelState({
    required this.level,
    this.distanceTraveled = 0.0,
    this.coinsCollected = 0,
    this.status = LevelStatus.notStarted,
    this.showGasStation = false,
    this.progressPercentage = 0.0,
  });

  // Método para crear una copia con cambios
  LevelState copyWith({
    GameLevel? level,
    double? distanceTraveled,
    int? coinsCollected,
    LevelStatus? status,
    bool? showGasStation,
    double? progressPercentage,
  }) {
    return LevelState(
      level: level ?? this.level,
      distanceTraveled: distanceTraveled ?? this.distanceTraveled,
      coinsCollected: coinsCollected ?? this.coinsCollected,
      status: status ?? this.status,
      showGasStation: showGasStation ?? this.showGasStation,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }

  // Calcular progreso hacia la meta de distancia
  double get distanceProgress {
    return (distanceTraveled / level.distanceGoalInMeters).clamp(0.0, 1.0);
  }

  // Calcular progreso de monedas
  double get coinsProgress {
    return (coinsCollected / level.minimumCoins).clamp(0.0, 1.0);
  }

  // Verificar si se alcanzó la distancia objetivo
  bool get hasReachedDistanceGoal {
    return distanceTraveled >= level.distanceGoalInMeters;
  }

  // Verificar si tiene suficientes monedas
  bool get hasSufficientCoins {
    return coinsCollected >= level.minimumCoins;
  }

  // Verificar si el nivel está completado
  bool get isCompleted {
    return hasReachedDistanceGoal && hasSufficientCoins;
  }

  // Distancia restante para completar el nivel
  double get remainingDistance {
    return math.max(0, level.distanceGoalInMeters - distanceTraveled);
  }

  // Monedas restantes para completar el nivel
  int get remainingCoins {
    return math.max(0, level.minimumCoins - coinsCollected);
  }

  // Método para obtener el mensaje de estado actual
  String get statusMessage {
    switch (status) {
      case LevelStatus.notStarted:
        return 'Nivel no iniciado';
      case LevelStatus.inProgress:
        if (hasReachedDistanceGoal) {
          return '¡Meta alcanzada! Dirígete a la gasolinera';
        } else {
          return 'Progreso: ${(distanceProgress * 100).toInt()}%';
        }
      case LevelStatus.reachedGoal:
        return hasSufficientCoins 
            ? '¡Felicidades! Nivel completado'
            : 'No tienes suficientes monedas. Nivel fallido.';
      case LevelStatus.completed:
        return '¡Nivel completado exitosamente!';
      case LevelStatus.failed:
        return 'Nivel fallido. ¡Inténtalo de nuevo!';
    }
  }

  @override
  String toString() {
    return 'LevelState('
        'level: ${level.levelNumber}, '
        'distance: ${distanceTraveled.toInt()}/${level.distanceGoalInMeters}, '
        'coins: $coinsCollected/${level.minimumCoins}, '
        'status: $status'
        ')';
  }
}

