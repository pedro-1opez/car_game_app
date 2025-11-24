// ===========================================================================
// El siguiente código define el modelo de un coche en el juego,
// incluyendo sus propiedades, estados y métodos para crear coches
// del jugador y de tráfico, así como funcionalidades para moverlos,
// detectar colisiones y gestionar su estado.
// ===========================================================================

import 'package:flutter/material.dart';
import 'game_orientation.dart';

/// Tipos de coches disponibles en el juego
enum CarType {
  player,
  traffic,
  police,
  ambulance,
}

/// Colores disponibles para los coches
enum CarColor {
  purple,
  orange,
  blue,
  red,
  green,
  yellow,
  white,
  black,
}

/// Modelo que representa un coche en el juego
class Car {
  final String id;
  final CarType type;
  final CarColor color;
  final GameOrientation orientation;
  final double width;
  final double height;
  final double speed;
  final String assetPath;
  
  // Posición actual del coche
  double x;
  double y;
  LanePosition currentLane;
  
  // Estado del coche
  bool isVisible;
  bool isColliding;
  DateTime? lastCollisionTime;
  
  Car({
    required this.id,
    required this.type,
    required this.color,
    required this.orientation,
    required this.width,
    required this.height,
    required this.speed,
    required this.assetPath,
    required this.x,
    required this.y,
    this.currentLane = LanePosition.center,
    this.isVisible = true,
    this.isColliding = false,
    this.lastCollisionTime,
  });
  
  /// Factory para crear el coche del jugador
  factory Car.player({
    required GameOrientation orientation,
    required CarColor color,
    double? x,
    double? y,
  }) {
    final isVertical = orientation == GameOrientation.vertical;
    return Car(
      id: 'player_car',
      type: CarType.player,
      color: color,
      orientation: orientation,
      width: isVertical ? 60 : 40,
      height: isVertical ? 120 : 80,
      speed: 0, // El jugador no se mueve automáticamente
      assetPath: _getPlayerAssetPath(color, orientation),
      x: x ?? 0,
      y: y ?? 0,
      currentLane: LanePosition.center,
    );
  }
  
  /// Factory para crear coches de tráfico
  factory Car.traffic({
    required GameOrientation orientation,
    required CarColor color,
    required double x,
    required double y,
    required LanePosition lane,
  }) {
    final isVertical = orientation == GameOrientation.vertical;
    return Car(
      id: 'traffic_${DateTime.now().millisecondsSinceEpoch}',
      type: CarType.traffic,
      color: color,
      orientation: orientation,
      width: isVertical ? 55 : 35,
      height: isVertical ? 110 : 75,
      speed: isVertical ? 2.0 : 1.5,
      assetPath: _getTrafficAssetPath(color, orientation),
      x: x,
      y: y,
      currentLane: lane,
    );
  }
  
  /// Mueve el coche según su velocidad y orientación
  void move(double deltaTime) {
    if (orientation == GameOrientation.vertical) {
      y += speed * deltaTime * 60; // 60 FPS base
    } else {
      x += speed * deltaTime * 60;
    }
  }
  

  
  /// Obtiene el rectángulo de colisión del coche
  Rect getCollisionRect() {
    return Rect.fromLTWH(x, y, width, height);
  }
  
  /// Verifica si el coche está fuera de los límites de la pantalla
  bool isOutOfBounds(Size screenSize) {
    if (orientation == GameOrientation.vertical) {
      return y > screenSize.height + 100 || y < -height - 100;
    } else {
      return x > screenSize.width + 100 || x < -width - 100;
    }
  }
  
  /// Marca el coche como colisionando
  void setColliding() {
    isColliding = true;
    lastCollisionTime = DateTime.now();
  }
  
  /// Resetea el estado de colisión
  void resetCollision() {
    isColliding = false;
    lastCollisionTime = null;
  }
  
  /// Clona el coche con nuevos valores
  Car copyWith({
    String? id,
    CarType? type,
    CarColor? color,
    GameOrientation? orientation,
    double? width,
    double? height,
    double? speed,
    String? assetPath,
    double? x,
    double? y,
    LanePosition? currentLane,
    bool? isVisible,
    bool? isColliding,
  }) {
    return Car(
      id: id ?? this.id,
      type: type ?? this.type,
      color: color ?? this.color,
      orientation: orientation ?? this.orientation,
      width: width ?? this.width,
      height: height ?? this.height,
      speed: speed ?? this.speed,
      assetPath: assetPath ?? this.assetPath,
      x: x ?? this.x,
      y: y ?? this.y,
      currentLane: currentLane ?? this.currentLane,
      isVisible: isVisible ?? this.isVisible,
      isColliding: isColliding ?? this.isColliding,
      lastCollisionTime: lastCollisionTime,
    );
  }
  
  @override
  String toString() {
    return 'Car(id: $id, type: $type, lane: $currentLane, pos: ($x, $y))';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Car && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

/// Obtiene la ruta del asset para el coche del jugador
String _getPlayerAssetPath(CarColor color, GameOrientation orientation) {
  final orientationFolder = orientation == GameOrientation.vertical ? 'vertical' : 'horizontal';
  final colorName = color.name;
  return 'assets/images/cars/$orientationFolder/player/player_car_$colorName.png';
}

/// Obtiene la ruta del asset para coches de tráfico
String _getTrafficAssetPath(CarColor color, GameOrientation orientation) {
  final orientationFolder = orientation == GameOrientation.vertical ? 'vertical' : 'horizontal';
  final colorName = color.name;
  return 'assets/images/cars/$orientationFolder/traffic/traffic_car_$colorName.png';
}