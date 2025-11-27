// ===========================================================================
// El siguiente código define el servicio para manejar efectos y power-ups,
// incluyendo activación, desactivación y actualización de efectos activos.
// ===========================================================================

import '../models/game_state.dart';
import '../models/power_up.dart';
import '../utils/score_calculator.dart';

/// Servicio para manejar efectos y power-ups
class EffectsService {
  static EffectsService? _instance;
  static EffectsService get instance => _instance ??= EffectsService._();
  EffectsService._();
  
  /// Activa un escudo protector
  GameState activateShield(GameState gameState, Duration duration) {
    final effect = ActiveEffect(
      type: PowerUpType.shield,
      startTime: DateTime.now(),
      duration: duration,
      value: 1,
    );
    
    final newEffects = [...gameState.activeEffects, effect];
    return gameState.copyWith(
      activeEffects: newEffects,
      hasShield: true,
    );
  }
  
  /// Desactiva el escudo
  GameState deactivateShield(GameState gameState) {
    final newEffects = gameState.activeEffects
        .where((effect) => effect.type != PowerUpType.shield)
        .toList();
    
    return gameState.copyWith(
      activeEffects: newEffects,
      hasShield: false,
    );
  }
  
  /// Activa boost de velocidad
  GameState activateSpeedBoost(GameState gameState, int multiplier, Duration duration) {
    final effect = ActiveEffect(
      type: PowerUpType.speedboost,
      startTime: DateTime.now(),
      duration: duration,
      value: multiplier,
    );
    
    final newEffects = [...gameState.activeEffects, effect];
    return gameState.copyWith(activeEffects: newEffects);
  }
  
  /// Activa multiplicador de puntos
  GameState activateDoublePoints(GameState gameState, int multiplier, Duration duration) {
    final effect = ActiveEffect(
      type: PowerUpType.doublepoints,
      startTime: DateTime.now(),
      duration: duration,
      value: multiplier,
    );
    
    final newEffects = [...gameState.activeEffects, effect];
    return gameState.copyWith(activeEffects: newEffects);
  }
  
  /// Activa imán para atraer monedas
  GameState activateMagnet(GameState gameState, Duration duration) {
    final effect = ActiveEffect(
      type: PowerUpType.magnet,
      startTime: DateTime.now(),
      duration: duration,
      value: 1,
    );
    
    final newEffects = [...gameState.activeEffects, effect];
    return gameState.copyWith(activeEffects: newEffects);
  }
  
  /// Procesa la recolección de un power-up específico
  GameState collectPowerUp(GameState gameState, PowerUp powerUp) {
    if (powerUp.isCollected) return gameState;
    
    // Marcar como recolectado
    powerUp.collect();
    
    var updatedGameState = gameState;
    
    // Aplicar efectos específicos por tipo
    switch (powerUp.type) {
      case PowerUpType.coin:
        final scoreResult = ScoreCalculator.calculateCoinScore(powerUp, gameState);
        updatedGameState = _addScore(updatedGameState, scoreResult.totalPoints);
        updatedGameState = _incrementCoinsCollected(updatedGameState);
        break;
        
      case PowerUpType.fuel:
        final scoreResult = ScoreCalculator.calculateFuelScore(powerUp, gameState);
        updatedGameState = _addFuel(updatedGameState, powerUp.value.toDouble());
        updatedGameState = _addScore(updatedGameState, scoreResult.totalPoints);
        break;
        
      case PowerUpType.shield:
        final scoreResult = ScoreCalculator.calculatePowerUpScore(powerUp, gameState);
        updatedGameState = _addScore(updatedGameState, scoreResult.totalPoints);
        updatedGameState = activateShield(updatedGameState, powerUp.duration!);
        break;
        
      case PowerUpType.speedboost:
        final scoreResult = ScoreCalculator.calculatePowerUpScore(powerUp, gameState);
        updatedGameState = _addScore(updatedGameState, scoreResult.totalPoints);
        updatedGameState = activateSpeedBoost(updatedGameState, powerUp.value, powerUp.duration!);
        break;
        
      case PowerUpType.doublepoints:
        final scoreResult = ScoreCalculator.calculatePowerUpScore(powerUp, gameState);
        updatedGameState = _addScore(updatedGameState, scoreResult.totalPoints);
        updatedGameState = activateDoublePoints(updatedGameState, powerUp.value, powerUp.duration!);
        break;
        
      case PowerUpType.magnet:
        final scoreResult = ScoreCalculator.calculatePowerUpScore(powerUp, gameState);
        updatedGameState = _addScore(updatedGameState, scoreResult.totalPoints);
        updatedGameState = activateMagnet(updatedGameState, powerUp.duration!);
        break;
    }
    
    return updatedGameState;
  }
  
  /// Verifica y limpia efectos expirados
  GameState updateActiveEffects(GameState gameState) {
    final activeEffects = gameState.activeEffects
        .where((effect) => effect.isActive)
        .toList();
    
    // Verificar si el escudo expiró
    bool hasShield = activeEffects.any((effect) => effect.type == PowerUpType.shield);
    
    return gameState.copyWith(
      activeEffects: activeEffects,
      hasShield: hasShield,
    );
  }
  
  /// Obtiene el multiplicador de velocidad activo
  double getSpeedMultiplier(GameState gameState) {
    final speedBoosts = gameState.activeEffects
        .where((effect) => effect.type == PowerUpType.speedboost && effect.isActive);
    
    if (speedBoosts.isEmpty) return 1.0;
    
    double multiplier = 1.0;
    for (final boost in speedBoosts) {
      multiplier *= boost.value as double;
    }
    
    return multiplier;
  }
  
  /// Obtiene el multiplicador de puntos activo
  double getPointsMultiplier(GameState gameState) {
    final pointsBoosts = gameState.activeEffects
        .where((effect) => effect.type == PowerUpType.doublepoints && effect.isActive);
    
    if (pointsBoosts.isEmpty) return 1.0;
    
    double multiplier = 1.0;
    for (final boost in pointsBoosts) {
      multiplier *= boost.value as double;
    }
    
    return multiplier;
  }
  
  /// Verifica si el imán está activo
  bool isMagnetActive(GameState gameState) {
    return gameState.activeEffects
        .any((effect) => effect.type == PowerUpType.magnet && effect.isActive);
  }
  
  // Métodos auxiliares privados
  GameState _addScore(GameState gameState, int points) {
    final newScore = gameState.score + points;
    final newHighScore = newScore > gameState.highScore ? newScore : gameState.highScore;
    
    return gameState.copyWith(
      score: newScore,
      highScore: newHighScore,
    );
  }
  
  GameState _addFuel(GameState gameState, double amount) {
    final newFuel = (gameState.fuel + amount).clamp(0.0, 100.0);
    return gameState.copyWith(fuel: newFuel);
  }
  
  GameState _incrementCoinsCollected(GameState gameState) {
    return gameState.copyWith(
      coinsCollected: gameState.coinsCollected + 1,
    );
  }
}