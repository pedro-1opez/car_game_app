// ===========================================================================
// Servicio para manejar la lógica central del juego.
// ===========================================================================

import '../core/models/game_state.dart';
import '../core/models/game_orientation.dart';
import '../core/constants/game_constants.dart';
import '../core/constants/orientation_config.dart';

/// Servicio para manejar la lógica central del juego
class GameService {
  static GameService? _instance;
  static GameService get instance => _instance ??= GameService._();
  GameService._();
  
  /// Crea un nuevo estado de juego inicial
  Future<GameState> createInitialGameState({
    GameOrientation? orientation,
    GameDifficulty? difficulty,
  }) async {
    final gameOrientation = orientation ?? GameOrientation.vertical;
    final config = OrientationConstants.configs[gameOrientation]!;
    
    return GameState.createInitial(
      orientation: gameOrientation,
      config: config,
      difficulty: difficulty ?? GameDifficulty.medium,
    );
  }
  
  /// Verifica condiciones de game over
  bool shouldGameEnd(GameState gameState) {
    return gameState.isFuelEmpty || gameState.lives <= 0;
  }
  
  /// Actualiza las estadísticas del juego
  GameState updateGameStats(GameState gameState, double deltaTime) {
    final distance = gameState.adjustedGameSpeed * deltaTime;
    final newGameTime = gameState.gameTime + Duration(
      milliseconds: (deltaTime * 1000).round(),
    );
    
    return gameState.copyWith(
      distanceTraveled: gameState.distanceTraveled + distance,
      gameTime: newGameTime,
    );
  }
  
  /// Actualiza el combustible
  GameState updateFuel(GameState gameState, double deltaTime) {
    final consumption = GameConstants.fuelConsumptionRate * deltaTime;
    final newFuel = (gameState.fuel - consumption).clamp(0.0, 100.0);
    
    return gameState.copyWith(fuel: newFuel);
  }
  
  /// Actualiza efectos activos
  GameState updateActiveEffects(GameState gameState) {
    final activeEffects = gameState.activeEffects
        .where((effect) => effect.isActive)
        .toList();
    
    return gameState.copyWith(activeEffects: activeEffects);
  }
  
  /// Añade puntuación
  GameState addScore(GameState gameState, int points) {
    final newScore = gameState.score + points;
    final newHighScore = newScore > gameState.highScore ? newScore : gameState.highScore;
    
    return gameState.copyWith(
      score: newScore,
      highScore: newHighScore,
    );
  }
  
  /// Añade combustible
  GameState addFuel(GameState gameState, double amount) {
    final newFuel = (gameState.fuel + amount).clamp(0.0, 100.0);
    return gameState.copyWith(fuel: newFuel);
  }
  
  /// Incrementa monedas recolectadas
  GameState incrementCoinsCollected(GameState gameState) {
    return gameState.copyWith(
      coinsCollected: gameState.coinsCollected + 1,
    );
  }
}