import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/game_orientation.dart';

/// Utilidad para convertir coordenadas entre diferentes sistemas y orientaciones
class CoordinateConverter {
  /// Convierte coordenadas de pantalla a coordenadas del juego
  static Offset screenToGame(Offset screenPoint, Size screenSize, Size gameSize) {
    final scaleX = gameSize.width / screenSize.width;
    final scaleY = gameSize.height / screenSize.height;
    
    return Offset(
      screenPoint.dx * scaleX,
      screenPoint.dy * scaleY,
    );
  }
  
  /// Convierte coordenadas del juego a coordenadas de pantalla
  static Offset gameToScreen(Offset gamePoint, Size gameSize, Size screenSize) {
    final scaleX = screenSize.width / gameSize.width;
    final scaleY = screenSize.height / gameSize.height;
    
    return Offset(
      gamePoint.dx * scaleX,
      gamePoint.dy * scaleY,
    );
  }
  
  /// Convierte coordenadas entre orientaciones (vertical <-> horizontal)
  static Offset convertBetweenOrientations(
    Offset point,
    GameOrientation fromOrientation,
    GameOrientation toOrientation,
    Size fromSize,
    Size toSize,
  ) {
    if (fromOrientation == toOrientation) {
      // Mismo orientación, solo escalar si es necesario
      return Offset(
        point.dx * (toSize.width / fromSize.width),
        point.dy * (toSize.height / fromSize.height),
      );
    }
    
    // Conversión entre orientaciones diferentes
    if (fromOrientation == GameOrientation.vertical && 
        toOrientation == GameOrientation.horizontal) {
      return _verticalToHorizontal(point, fromSize, toSize);
    } else {
      return _horizontalToVertical(point, fromSize, toSize);
    }
  }
  
  /// Convierte posición de carril entre orientaciones
  static LanePosition convertLanePosition(
    LanePosition lane,
    GameOrientation fromOrientation,
    GameOrientation toOrientation,
  ) {
    // Las posiciones de carril se mantienen iguales conceptualmente
    return lane;
  }
  
  /// Convierte velocidad entre orientaciones
  static Offset convertVelocity(
    Offset velocity,
    GameOrientation fromOrientation,
    GameOrientation toOrientation,
  ) {
    if (fromOrientation == toOrientation) {
      return velocity;
    }
    
    if (fromOrientation == GameOrientation.vertical) {
      // Vertical a Horizontal: Y se convierte en X, X se convierte en Y
      return Offset(velocity.dy, -velocity.dx);
    } else {
      // Horizontal a Vertical: X se convierte en Y, Y se convierte en -X
      return Offset(-velocity.dy, velocity.dx);
    }
  }
  
  /// Convierte un rectángulo entre orientaciones
  static Rect convertRect(
    Rect rect,
    GameOrientation fromOrientation,
    GameOrientation toOrientation,
    Size fromSize,
    Size toSize,
  ) {
    final topLeft = convertBetweenOrientations(
      rect.topLeft,
      fromOrientation,
      toOrientation,
      fromSize,
      toSize,
    );
    
    final bottomRight = convertBetweenOrientations(
      rect.bottomRight,
      fromOrientation,
      toOrientation,
      fromSize,
      toSize,
    );
    
    return Rect.fromPoints(topLeft, bottomRight);
  }
  
  /// Normaliza coordenadas a un rango de 0.0 a 1.0
  static Offset normalizeCoordinates(Offset point, Size bounds) {
    return Offset(
      (point.dx / bounds.width).clamp(0.0, 1.0),
      (point.dy / bounds.height).clamp(0.0, 1.0),
    );
  }
  
  /// Desnormaliza coordenadas de un rango 0.0-1.0 a coordenadas reales
  static Offset denormalizeCoordinates(Offset normalizedPoint, Size bounds) {
    return Offset(
      normalizedPoint.dx * bounds.width,
      normalizedPoint.dy * bounds.height,
    );
  }
  
  /// Calcula la posición de un carril específico en coordenadas absolutas
  static Offset getLaneCenter(
    LanePosition lane,
    GameOrientation orientation,
    Size gameSize,
  ) {
    final lanePositions = {
      LanePosition.left: 0.25,
      LanePosition.center: 0.5,
      LanePosition.right: 0.75,
    };
    
    final laneRatio = lanePositions[lane] ?? 0.5;
    
    if (orientation == GameOrientation.vertical) {
      return Offset(
        gameSize.width * laneRatio,
        gameSize.height * 0.5,
      );
    } else {
      return Offset(
        gameSize.width * 0.5,
        gameSize.height * laneRatio,
      );
    }
  }
  
  /// Convierte ángulo entre orientaciones
  static double convertAngle(
    double angle,
    GameOrientation fromOrientation,
    GameOrientation toOrientation,
  ) {
    if (fromOrientation == toOrientation) {
      return angle;
    }
    
    // Rotar 90 grados al cambiar orientación
    return angle + (math.pi / 2);
  }
  
  /// Calcula la distancia entre dos puntos
  static double calculateDistance(Offset point1, Offset point2) {
    return (point1 - point2).distance;
  }
  
  /// Calcula el ángulo entre dos puntos
  static double calculateAngle(Offset from, Offset to) {
    final delta = to - from;
    return math.atan2(delta.dy, delta.dx);
  }
  
  /// Rota un punto alrededor de otro punto
  static Offset rotatePoint(Offset point, Offset center, double angle) {
    final cos = math.cos(angle);
    final sin = math.sin(angle);
    
    final translated = point - center;
    
    return Offset(
      translated.dx * cos - translated.dy * sin,
      translated.dx * sin + translated.dy * cos,
    ) + center;
  }
  
  /// Interpola linealmente entre dos puntos
  static Offset lerp(Offset start, Offset end, double t) {
    return Offset.lerp(start, end, t.clamp(0.0, 1.0))!;
  }
  
  /// Verifica si un punto está dentro de los límites
  static bool isWithinBounds(Offset point, Size bounds) {
    return point.dx >= 0 &&
           point.dx <= bounds.width &&
           point.dy >= 0 &&
           point.dy <= bounds.height;
  }
  
  /// Clampea un punto dentro de los límites especificados
  static Offset clampToBounds(Offset point, Size bounds) {
    return Offset(
      point.dx.clamp(0.0, bounds.width),
      point.dy.clamp(0.0, bounds.height),
    );
  }
  
  /// Calcula el punto más cercano en un rectángulo
  static Offset closestPointOnRect(Offset point, Rect rect) {
    return Offset(
      point.dx.clamp(rect.left, rect.right),
      point.dy.clamp(rect.top, rect.bottom),
    );
  }
  
  /// Convierte coordenadas polares a cartesianas
  static Offset polarToCartesian(double radius, double angle) {
    return Offset(
      radius * math.cos(angle),
      radius * math.sin(angle),
    );
  }
  
  /// Convierte coordenadas cartesianas a polares
  static ({double radius, double angle}) cartesianToPolar(Offset point) {
    final radius = point.distance;
    final angle = math.atan2(point.dy, point.dx);
    return (radius: radius, angle: angle);
  }
  
  // === MÉTODOS PRIVADOS ===
  
  /// Convierte de orientación vertical a horizontal
  static Offset _verticalToHorizontal(Offset point, Size fromSize, Size toSize) {
    // En vertical: X es horizontal, Y es vertical (hacia abajo)
    // En horizontal: X es horizontal (hacia derecha), Y es vertical
    
    // Normalizar primero
    final normalizedX = point.dx / fromSize.width;
    final normalizedY = point.dy / fromSize.height;
    
    // Convertir: 
    // - La Y vertical se convierte en X horizontal (progreso del juego)
    // - La X vertical se convierte en Y horizontal (posición de carril)
    return Offset(
      normalizedY * toSize.width,
      normalizedX * toSize.height,
    );
  }
  
  /// Convierte de orientación horizontal a vertical
  static Offset _horizontalToVertical(Offset point, Size fromSize, Size toSize) {
    // Proceso inverso de _verticalToHorizontal
    final normalizedX = point.dx / fromSize.width;
    final normalizedY = point.dy / fromSize.height;
    
    return Offset(
      normalizedY * toSize.width,
      normalizedX * toSize.height,
    );
  }
}