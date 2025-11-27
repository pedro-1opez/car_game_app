// ===========================================================================
// Modelo de datos para los niveles del juego
// Define las metas de distancia y monedas para cada nivel
// ===========================================================================

class GameLevel {
  final int levelNumber;
  final int distanceGoalInMeters;
  final int minimumCoins;
  final String title;
  final String description;
  final bool isUnlocked;

  const GameLevel({
    required this.levelNumber,
    required this.distanceGoalInMeters,
    required this.minimumCoins,
    required this.title,
    required this.description,
    this.isUnlocked = true,
  });

  // Método para formatear la distancia de manera legible
  String get formattedDistance {
    if (distanceGoalInMeters >= 1000) {
      final km = distanceGoalInMeters / 1000;
      return km == km.toInt() ? '${km.toInt()} km' : '${km.toStringAsFixed(1)} km';
    } else {
      return '$distanceGoalInMeters m';
    }
  }

  // Método para obtener la descripción completa del nivel
  String get fullDescription {
    return 'Alcanza $formattedDistance y recolecta $minimumCoins monedas';
  }

  // Método para verificar si el nivel está completado
  bool isCompleted({required int distanceTraveled, required int coinsCollected}) {
    return distanceTraveled >= distanceGoalInMeters && coinsCollected >= minimumCoins;
  }

  // Factory method para crear la lista de niveles predefinidos
  static List<GameLevel> getDefaultLevels() {
    return [
      GameLevel(
        levelNumber: 1,
        distanceGoalInMeters: 200,
        minimumCoins: 20,
        title: 'Nivel',
        description: 'Tu primera aventura en la carretera',
      ),
      GameLevel(
        levelNumber: 2,
        distanceGoalInMeters: 500,
        minimumCoins: 50,
        title: 'Nivel',
        description: 'Aumenta la velocidad y la destreza',
      ),
      GameLevel(
        levelNumber: 3,
        distanceGoalInMeters: 1000,
        minimumCoins: 100,
        title: 'Nivel',
        description: 'El desafío definitivo',
      ),
    ];
  }

  // Método para obtener el progreso como porcentaje
  double getProgressPercentage({required int distanceTraveled, required int coinsCollected}) {
    final distanceProgress = (distanceTraveled / distanceGoalInMeters).clamp(0.0, 1.0);
    final coinsProgress = (coinsCollected / minimumCoins).clamp(0.0, 1.0);
    
    // El progreso total es el mínimo entre distancia y monedas
    // Ambos objetivos deben cumplirse
    return (distanceProgress + coinsProgress) / 2;
  }

  @override
  String toString() {
    return 'GameLevel(number: $levelNumber, distance: ${formattedDistance}, coins: $minimumCoins)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameLevel && other.levelNumber == levelNumber;
  }

  @override
  int get hashCode => levelNumber.hashCode;
}