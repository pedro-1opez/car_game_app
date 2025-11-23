import 'package:flutter/material.dart';

/// Enumeración que define las orientaciones disponibles del juego
enum GameOrientation {
  vertical,
  horizontal,
}

/// Posiciones de carril según la orientación
enum LanePosition {
  left,
  center,
  right;
}

/// Configuración específica para cada orientación del juego
class OrientationConfig {
  final GameOrientation orientation;
  final double gameAreaWidth;
  final double gameAreaHeight;
  final double carWidth;
  final double carHeight;
  final double laneWidth;
  final double carSpeed;
  final double obstacleSpeed;
  final int laneCount;
  final EdgeInsets padding;
  
  const OrientationConfig({
    required this.orientation,
    required this.gameAreaWidth,
    required this.gameAreaHeight,
    required this.carWidth,
    required this.carHeight,
    required this.laneWidth,
    required this.carSpeed,
    required this.obstacleSpeed,
    required this.laneCount,
    required this.padding,
  });
  
  /// Obtiene la posición X del carril en modo vertical
  double getLanePositionX(LanePosition lane) {
    if (orientation != GameOrientation.vertical) return 0;
    
    switch (lane) {
      case LanePosition.left:
        return gameAreaWidth * 0.2;
      case LanePosition.center:
        return gameAreaWidth * 0.5;
      case LanePosition.right:
        return gameAreaWidth * 0.8;
    }
  }
  
  /// Obtiene la posición Y del carril en modo horizontal
  double getLanePositionY(LanePosition lane) {
    if (orientation != GameOrientation.horizontal) return 0;
    
    switch (lane) {
      case LanePosition.left: // equivale a top en horizontal
        return gameAreaHeight * 0.2;
      case LanePosition.center:
        return gameAreaHeight * 0.5;
      case LanePosition.right: // equivale a bottom en horizontal
        return gameAreaHeight * 0.8;
    }
  }
  
  @override
  String toString() {
    return 'OrientationConfig(orientation: $orientation, size: ${gameAreaWidth}x$gameAreaHeight)';
  }
}