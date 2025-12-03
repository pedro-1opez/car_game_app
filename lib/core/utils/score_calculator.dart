// ===========================================================================
// El siguiente código define la calculadora de puntuación del juego,
// incluyendo métodos para calcular puntos por diferentes eventos,
// como distancia recorrida, monedas recogidas, obstáculos evitados, y más.
// ===========================================================================

import '../models/game_state.dart';
import '../models/power_up.dart';
import '../models/obstacle.dart';
import '../constants/game_constants.dart';

/// Tipos de eventos que generan puntuación
enum ScoreEvent {
  distanceTraveled,
  coinCollected,
  fuelCollected,
  obstacleAvoided,
  powerUpCollected,
  timeBonus,
  difficultyBonus,
  comboMultiplier,
  perfectRun,
}

/// Resultado de un cálculo de puntuación
class ScoreResult {
  final int basePoints;
  final int bonusPoints;
  final int totalPoints;
  final double multiplier;
  final ScoreEvent event;
  final String description;
  final DateTime timestamp;
  
  const ScoreResult({
    required this.basePoints,
    required this.bonusPoints,
    required this.totalPoints,
    required this.multiplier,
    required this.event,
    required this.description,
    required this.timestamp,
  });
  
  @override
  String toString() {
    return 'ScoreResult(event: $event, total: $totalPoints, multiplier: ${multiplier}x)';
  }
}

/// Calculadora de puntuación del juego
class ScoreCalculator {
  // Historial de eventos para calcular combos
  static final List<ScoreResult> _scoreHistory = [];
  static const int maxHistorySize = 100;
  
  // Tiempo del último evento para calcular combos
  static DateTime? _lastEventTime;
  static const Duration comboTimeWindow = Duration(seconds: 2);
  
  /// Calcula puntos por distancia recorrida
  static ScoreResult calculateDistanceScore(
    double distance,
    GameState gameState,
  ) {
    final basePoints = (distance * GameConstants.pointsPerDistance).round();
    final multiplier = _calculateTotalMultiplier(gameState);
    final bonusPoints = _calculateDistanceBonus(distance, gameState);
    
    final totalPoints = ((basePoints + bonusPoints) * multiplier).round();
    
    final result = ScoreResult(
      basePoints: basePoints,
      bonusPoints: bonusPoints,
      totalPoints: totalPoints,
      multiplier: multiplier,
      event: ScoreEvent.distanceTraveled,
      description: 'Distancia: ${distance.toStringAsFixed(1)}m',
      timestamp: DateTime.now(),
    );
    
    _addToHistory(result);
    return result;
  }
  
  /// Calcula puntos por recoger una moneda
  static ScoreResult calculateCoinScore(
    PowerUp coin,
    GameState gameState,
  ) {
    final basePoints = GameConstants.pointsPerCoin;
    final multiplier = _calculateTotalMultiplier(gameState);
    final bonusPoints = _calculateComboBonus(ScoreEvent.coinCollected);
    
    final totalPoints = ((basePoints + bonusPoints) * multiplier).round();
    
    final result = ScoreResult(
      basePoints: basePoints,
      bonusPoints: bonusPoints,
      totalPoints: totalPoints,
      multiplier: multiplier,
      event: ScoreEvent.coinCollected,
      description: 'Moneda dorada',
      timestamp: DateTime.now(),
    );
    
    _addToHistory(result);
    return result;
  }
  
  /// Calcula puntos por recoger combustible
  static ScoreResult calculateFuelScore(
    PowerUp fuel,
    GameState gameState,
  ) {
    final basePoints = GameConstants.pointsPerFuelCollected;
    final multiplier = _calculateTotalMultiplier(gameState);
    final bonusPoints = _calculateFuelBonus(gameState.fuel);
    
    final totalPoints = ((basePoints + bonusPoints) * multiplier).round();
    
    final result = ScoreResult(
      basePoints: basePoints,
      bonusPoints: bonusPoints,
      totalPoints: totalPoints,
      multiplier: multiplier,
      event: ScoreEvent.fuelCollected,
      description: 'Combustible (+${fuel.value}%)',
      timestamp: DateTime.now(),
    );
    
    _addToHistory(result);
    return result;
  }
  
  /// Calcula puntos por evitar un obstáculo
  static ScoreResult calculateObstacleAvoidedScore(
    Obstacle obstacle,
    GameState gameState,
  ) {
    final basePoints = GameConstants.pointsPerObstacleAvoided;
    final multiplier = _calculateTotalMultiplier(gameState);
    final bonusPoints = _calculateObstacleBonus(obstacle);
    
    final totalPoints = ((basePoints + bonusPoints) * multiplier).round();
    
    final result = ScoreResult(
      basePoints: basePoints,
      bonusPoints: bonusPoints,
      totalPoints: totalPoints,
      multiplier: multiplier,
      event: ScoreEvent.obstacleAvoided,
      description: 'Obstáculo evitado: ${obstacle.type.name}',
      timestamp: DateTime.now(),
    );
    
    _addToHistory(result);
    return result;
  }
  
  /// Calcula puntos por recoger un power-up
  static ScoreResult calculatePowerUpScore(
    PowerUp powerUp,
    GameState gameState,
  ) {
    final basePoints = _getPowerUpBaseScore(powerUp.type);
    final multiplier = _calculateTotalMultiplier(gameState);
    final bonusPoints = _calculatePowerUpBonus(powerUp);
    
    final totalPoints = ((basePoints + bonusPoints) * multiplier).round();
    
    final result = ScoreResult(
      basePoints: basePoints,
      bonusPoints: bonusPoints,
      totalPoints: totalPoints,
      multiplier: multiplier,
      event: ScoreEvent.powerUpCollected,
      description: 'Power-up: ${powerUp.type.name}',
      timestamp: DateTime.now(),
    );
    
    _addToHistory(result);
    return result;
  }
  
  /// Calcula bonus por tiempo de supervivencia
  static ScoreResult calculateTimeBonus(
    Duration gameTime,
    GameState gameState,
  ) {
    final minutes = gameTime.inMinutes;
    final basePoints = minutes * 50; // 50 puntos por minuto
    final multiplier = _calculateTotalMultiplier(gameState);
    
    final totalPoints = (basePoints * multiplier).round();
    
    final result = ScoreResult(
      basePoints: basePoints,
      bonusPoints: 0,
      totalPoints: totalPoints,
      multiplier: multiplier,
      event: ScoreEvent.timeBonus,
      description: 'Bonus de tiempo: ${gameTime.inMinutes}m ${gameTime.inSeconds % 60}s',
      timestamp: DateTime.now(),
    );
    
    return result;
  }
  
  /// Calcula bonus por dificultad
  static ScoreResult calculateDifficultyBonus(
    GameState gameState,
  ) {
    final difficultyMultipliers = {
      GameDifficulty.easy: 1.0,
      GameDifficulty.medium: 1.2,
      GameDifficulty.hard: 1.5,
      GameDifficulty.expert: 2.0,
    };
    
    final baseDifficultyScore = gameState.score;
    final difficultyMultiplier = difficultyMultipliers[gameState.difficulty] ?? 1.0;
    final bonusPoints = (baseDifficultyScore * (difficultyMultiplier - 1.0)).round();
    
    final result = ScoreResult(
      basePoints: 0,
      bonusPoints: bonusPoints,
      totalPoints: bonusPoints,
      multiplier: difficultyMultiplier,
      event: ScoreEvent.difficultyBonus,
      description: 'Bonus ${gameState.difficulty.name}: ${difficultyMultiplier}x',
      timestamp: DateTime.now(),
    );
    
    return result;
  }
  
  /// Calcula puntuación final del juego
  static Map<String, dynamic> calculateFinalScore(GameState gameState) {
    final baseScore = gameState.score;
    final timeBonus = calculateTimeBonus(gameState.gameTime, gameState);
    final difficultyBonus = calculateDifficultyBonus(gameState);
    
    // Bonus por estadísticas
    final statsBonus = _calculateStatsBonus(gameState);
    
    // Bonus por racha perfecta (sin colisiones)
    final perfectBonus = _calculatePerfectRunBonus(gameState);
    
    final totalBonus = timeBonus.totalPoints + 
                      difficultyBonus.totalPoints + 
                      statsBonus + 
                      perfectBonus;
    
    final finalScore = baseScore + totalBonus;
    
    return {
      'base_score': baseScore,
      'time_bonus': timeBonus.totalPoints,
      'difficulty_bonus': difficultyBonus.totalPoints,
      'stats_bonus': statsBonus,
      'perfect_bonus': perfectBonus,
      'total_bonus': totalBonus,
      'final_score': finalScore,
      'is_high_score': finalScore > gameState.highScore,
    };
  }
  
  /// Obtiene estadísticas de puntuación
  static Map<String, dynamic> getScoreStats() {
    final recentEvents = _scoreHistory.where((result) {
      return DateTime.now().difference(result.timestamp) < const Duration(minutes: 5);
    }).toList();
    
    return {
      'total_events': _scoreHistory.length,
      'recent_events': recentEvents.length,
      'average_score_per_event': _scoreHistory.isNotEmpty
          ? _scoreHistory.map((r) => r.totalPoints).reduce((a, b) => a + b) / _scoreHistory.length
          : 0.0,
      'highest_single_score': _scoreHistory.isNotEmpty
          ? _scoreHistory.map((r) => r.totalPoints).reduce((a, b) => a > b ? a : b)
          : 0,
      'combo_count': _calculateCurrentComboCount(),
    };
  }
  
  /// Limpia el historial de puntuación
  static void clearHistory() {
    _scoreHistory.clear();
    _lastEventTime = null;
  }
  
  // === MÉTODOS PRIVADOS ===
  
  /// Calcula el multiplicador total activo
  static double _calculateTotalMultiplier(GameState gameState) {
    double multiplier = 1.0;
    
    // Multiplicador por efectos activos
    multiplier *= gameState.pointsMultiplier;
    
    // Multiplicador por combo
    multiplier *= _calculateComboMultiplier();
    
    return multiplier;
  }
  
  /// Calcula bonus por distancia
  static int _calculateDistanceBonus(double distance, GameState gameState) {
    // Bonus cada 100 metros
    final distanceMilestones = (distance / 100).floor();
    return distanceMilestones * 10;
  }
  
  /// Calcula bonus por combo de eventos
  static int _calculateComboBonus(ScoreEvent event) {
    final comboCount = _calculateCurrentComboCount();
    if (comboCount > 1) {
      return comboCount * 5; // 5 puntos extra por cada evento en el combo
    }
    return 0;
  }
  
  /// Calcula multiplicador por combo
  static double _calculateComboMultiplier() {
    final comboCount = _calculateCurrentComboCount();
    if (comboCount >= 5) return 2.0;
    if (comboCount >= 3) return 1.5;
    if (comboCount >= 2) return 1.2;
    return 1.0;
  }
  
  /// Calcula el número actual de combo
  static int _calculateCurrentComboCount() {
    if (_scoreHistory.isEmpty || _lastEventTime == null) return 0;
    
    final now = DateTime.now();
    int comboCount = 0;
    
    for (int i = _scoreHistory.length - 1; i >= 0; i--) {
      final event = _scoreHistory[i];
      if (now.difference(event.timestamp) <= comboTimeWindow) {
        comboCount++;
      } else {
        break;
      }
    }
    
    return comboCount;
  }
  
  /// Obtiene puntos base para un tipo de power-up
  static int _getPowerUpBaseScore(PowerUpType type) {
    switch (type) {
      case PowerUpType.coin:
        return GameConstants.pointsPerCoin;
      case PowerUpType.fuel:
        return GameConstants.pointsPerFuelCollected;
      case PowerUpType.shield:
        return 20;
      case PowerUpType.speedboost:
        return 15;
      case PowerUpType.doublepoints:
        return 25;
      case PowerUpType.magnet:
        return 30;
    }
  }
  
  /// Calcula bonus por combustible (más points si el combustible está bajo)
  static int _calculateFuelBonus(double currentFuel) {
    if (currentFuel < 20) return 20; // Bonus por recoger con combustible crítico
    if (currentFuel < 50) return 10; // Bonus por recoger con combustible bajo
    return 0;
  }
  
  /// Calcula bonus por tipo de obstáculo
  static int _calculateObstacleBonus(Obstacle obstacle) {
    switch (obstacle.type) {
      case ObstacleType.cone:
        return 5;
      case ObstacleType.oilspill:
        return 8;
      case ObstacleType.barrier:
        return 15;
      case ObstacleType.pothole:
        return 10;
      case ObstacleType.debris:
        return 7;
    }
  }
  
  /// Calcula bonus por power-up
  static int _calculatePowerUpBonus(PowerUp powerUp) {
    // Bonus basado en la edad del power-up (más difícil de atrapar = más points)
    final age = powerUp.ageInSeconds;
    return age * 2;
  }
  
  /// Calcula bonus por estadísticas del juego
  static int _calculateStatsBonus(GameState gameState) {
    int bonus = 0;
    
    // Bonus por monedas recolectadas
    bonus += gameState.coinsCollected * 2;
    
    // Bonus por obstáculos evitados
    bonus += gameState.obstaclesAvoided * 3;
    
    // Bonus por distancia
    bonus += (gameState.distanceTraveled / 10).round();
    
    return bonus;
  }
  
  /// Calcula bonus por juego perfecto (sin colisiones)
  static int _calculatePerfectRunBonus(GameState gameState) {
    // Verificar si el jugador tiene todas las vidas
    if (gameState.lives == GameConstants.maxLives) {
      return (gameState.score * 0.5).round(); // 50% bonus por juego perfecto
    }
    return 0;
  }
  
  /// Añade un resultado al historial
  static void _addToHistory(ScoreResult result) {
    _scoreHistory.add(result);
    _lastEventTime = result.timestamp;
    
    // Mantener el tamaño del historial
    if (_scoreHistory.length > maxHistorySize) {
      _scoreHistory.removeAt(0);
    }
  }
}