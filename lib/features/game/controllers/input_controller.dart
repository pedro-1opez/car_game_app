// ===========================================================================
// El siguiente código define el controlador de entrada del juego,
// manejando la interacción del usuario como gestos de arrastre y taps,
// y traduciendo estas interacciones en cambios en el estado del juego.
// ===========================================================================

import 'package:flutter/material.dart';
import '../../../core/models/game_orientation.dart';
import '../../../core/models/game_state.dart';
import '../../../core/constants/orientation_config.dart';

/// Controlador para manejar la entrada del usuario (touch, gestos, etc.)
class InputController {
  static InputController? _instance;
  static InputController get instance => _instance ??= InputController._();
  InputController._();
  
  /// Calcula el cambio de carril basado en la dirección
  GameState changeLane(GameState gameState, int direction) {
    if (!gameState.isPlaying) return gameState;
    
    final currentLane = gameState.playerCar.currentLane;
    final lanes = LanePosition.values;
    final currentIndex = lanes.indexOf(currentLane);
    final newIndex = (currentIndex + direction).clamp(0, lanes.length - 1);
    
    if (newIndex != currentIndex) {
      final newLane = lanes[newIndex];
      
      // Calcular nueva posición
      double newX, newY;
      if (gameState.orientation == GameOrientation.vertical) {
        newX = gameState.config.getLanePositionX(newLane) - gameState.playerCar.width / 2;
        newY = gameState.playerCar.y;
      } else {
        newX = gameState.playerCar.x;
        newY = gameState.config.getLanePositionY(newLane) - gameState.playerCar.height / 2;
      }
      
      final updatedCar = gameState.playerCar.copyWith(
        currentLane: newLane,
        x: newX,
        y: newY,
      );
      
      return gameState.copyWith(playerCar: updatedCar);
    }
    
    return gameState;
  }
  
  /// Cambia la orientación del juego
  GameState changeOrientation(GameState gameState, GameOrientation newOrientation) {
    if (gameState.orientation == newOrientation) return gameState;
    
    final newConfig = OrientationConstants.configs[newOrientation]!;
    
    // Convertir posición del jugador
    final newPlayerPosition = _getPlayerStartPosition(
      newOrientation,
      Size(newConfig.gameAreaWidth, newConfig.gameAreaHeight),
    );
    
    final updatedPlayerCar = gameState.playerCar.copyWith(
      orientation: newOrientation,
      x: newPlayerPosition.dx,
      y: newPlayerPosition.dy,
    );
    
    return gameState.copyWith(
      orientation: newOrientation,
      config: newConfig,
      playerCar: updatedPlayerCar,
      // Limpiar objetos existentes al cambiar orientación
      trafficCars: [],
      obstacles: [],
      powerUps: [],
    );
  }
  
  /// Alterna pausa
  GameState togglePause(GameState gameState) {
    if (gameState.isPlaying) {
      return gameState.copyWith(status: GameStatus.paused);
    } else if (gameState.isPaused) {
      return gameState.copyWith(status: GameStatus.playing);
    }
    return gameState;
  }
  
  /// Calcula posición inicial del jugador
  Offset _getPlayerStartPosition(GameOrientation orientation, Size gameAreaSize) {
    const margin = 50.0;
    
    if (orientation == GameOrientation.vertical) {
      return Offset(
        gameAreaSize.width / 2,
        gameAreaSize.height - margin - 50, // 50 = altura aproximada del coche
      );
    } else {
      return Offset(
        margin,
        gameAreaSize.height / 2,
      );
    }
  }
  
  /// Maneja gestos de arrastre
  GameState handleDragUpdate(GameState gameState, DragUpdateDetails details) {
    if (!gameState.isPlaying) return gameState;
    
    // Determinar dirección del movimiento
    int direction = 0;
    
    if (gameState.orientation == GameOrientation.vertical) {
      // Movimiento horizontal para orientación vertical
      if (details.delta.dx > 5) {
        direction = 1; // Derecha
      } else if (details.delta.dx < -5) {
        direction = -1; // Izquierda
      }
    } else {
      // Movimiento vertical para orientación horizontal
      if (details.delta.dy > 5) {
        direction = 1; // Abajo
      } else if (details.delta.dy < -5) {
        direction = -1; // Arriba
      }
    }
    
    if (direction != 0) {
      return changeLane(gameState, direction);
    }
    
    return gameState;
  }
  
  /// Maneja taps para cambio rápido de carril
  GameState handleTap(GameState gameState, TapUpDetails details, Size screenSize) {
    if (!gameState.isPlaying) return gameState;
    
    final tapPosition = details.localPosition;
    final playerPosition = Offset(gameState.playerCar.x, gameState.playerCar.y);
    
    int direction = 0;
    
    if (gameState.orientation == GameOrientation.vertical) {
      // Tap a la derecha o izquierda del coche
      if (tapPosition.dx > playerPosition.dx + 20) {
        direction = 1; // Mover a la derecha
      } else if (tapPosition.dx < playerPosition.dx - 20) {
        direction = -1; // Mover a la izquierda
      }
    } else {
      // Tap arriba o abajo del coche
      if (tapPosition.dy < playerPosition.dy - 20) {
        direction = -1; // Mover hacia arriba
      } else if (tapPosition.dy > playerPosition.dy + 20) {
        direction = 1; // Mover hacia abajo
      }
    }
    
    if (direction != 0) {
      return changeLane(gameState, direction);
    }
    
    return gameState;
  }
}