import 'package:flutter/material.dart';
import '../../../core/models/game_level.dart';
import '../../../core/models/level_state.dart';
import '../../game/controllers/game_controller.dart';
import '../../../core/models/game_state.dart';

class LevelGameController extends ChangeNotifier {
  final GameLevel level;
  final GameController _gameController;
  LevelState _levelState;
  bool _isHandlingGameOver = false; // Bandera para evitar bucle infinito

  LevelGameController({
    required this.level,
    required GameController gameController,
  }) : _gameController = gameController,
       _levelState = LevelState(
         level: level,
         status: LevelStatus.inProgress,
         distanceTraveled: 0,
         coinsCollected: 0,
       ) {
    // Configurar la distancia objetivo del nivel
    _gameController.setLevelGoalDistance(level.distanceGoalInMeters.toDouble());
    
    // Escuchar cambios en el GameController
    _gameController.addListener(_onGameStateChanged);
  }

  LevelState get levelState => _levelState;
  GameController get gameController => _gameController;
  GameState get gameState => _gameController.gameState;

  void _onGameStateChanged() {
    // Evitar bucle infinito durante el manejo de game over
    if (_isHandlingGameOver) return;
    
    // Actualizar el progreso del nivel basado en el estado del juego
    final newDistanceTraveled = gameState.distanceTraveled;
    final newCoinsCollected = gameState.coinsCollected;
    
    // MANEJAR GAME OVER - Si el juego termina, determinar el estado del nivel
    if (gameState.status == GameStatus.gameOver && 
        (_levelState.status == LevelStatus.inProgress || _levelState.status == LevelStatus.reachedGoal)) {
      
      // Marcar que estamos manejando el game over
      _isHandlingGameOver = true;
      
      // Determinar el estado del nivel
      if (newDistanceTraveled >= level.distanceGoalInMeters && newCoinsCollected >= level.minimumCoins) {
        _levelState = _levelState.copyWith(
          status: LevelStatus.completed,
          distanceTraveled: newDistanceTraveled,
          coinsCollected: newCoinsCollected,
        );
      } else {
        _levelState = _levelState.copyWith(
          status: LevelStatus.failed,
          distanceTraveled: newDistanceTraveled,
          coinsCollected: newCoinsCollected,
        );
      }
      
      notifyListeners();
      return;
    }
    
    _levelState = _levelState.copyWith(
      distanceTraveled: newDistanceTraveled,
      coinsCollected: newCoinsCollected,
    );

    // Verificar si se alcanzó la distancia objetivo - TERMINAR EL NIVEL INMEDIATAMENTE
    if (_levelState.status == LevelStatus.inProgress && 
        newDistanceTraveled >= level.distanceGoalInMeters) {
      // Evaluar si se completó exitosamente o falló según las monedas
      if (newCoinsCollected >= level.minimumCoins) {
        _levelState = _levelState.copyWith(
          status: LevelStatus.completed,
          distanceTraveled: newDistanceTraveled,
          coinsCollected: newCoinsCollected,
        );
      } else {
        _levelState = _levelState.copyWith(
          status: LevelStatus.failed,
          distanceTraveled: newDistanceTraveled,
          coinsCollected: newCoinsCollected,
        );
      }
    }

    notifyListeners();
  }

  void startLevel() {
    // Reiniciar la bandera de manejo de game over
    _isHandlingGameOver = false;
    _gameController.startNewGame();
  }

  void pauseLevel() {
    _gameController.togglePause();
  }

  void resumeLevel() {
    if (gameState.isPaused) {
      _gameController.togglePause();
    }
  }

  void resetLevel() {
    _levelState = LevelState(
      level: level,
      status: LevelStatus.inProgress,
      distanceTraveled: 0,
      coinsCollected: 0,
    );
    // No reiniciamos el GameController aquí, lo haremos desde la pantalla
    notifyListeners();
  }

  bool get isLevelCompleted => _levelState.status == LevelStatus.completed;
  bool get isLevelFailed => _levelState.status == LevelStatus.failed;
  bool get hasReachedGoal => _levelState.status == LevelStatus.reachedGoal || isLevelCompleted;

  @override
  void dispose() {
    _gameController.removeListener(_onGameStateChanged);
    _gameController.clearLevelGoalDistance(); // Limpiar configuración del nivel
    super.dispose();
  }
}