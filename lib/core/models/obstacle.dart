// ===========================================================================
// El siguiente código define el modelo de un obstáculo en el juego,
// incluyendo sus propiedades, estados y métodos para crear diferentes tipos
// ===========================================================================

import 'package:flutter/material.dart';
import 'game_orientation.dart';

/// Tipos de obstáculos disponibles en el juego
enum ObstacleType {
  cone,
  oilspill,
  barrier,
  pothole,
  debris,
}

/// Modelo que representa un obstáculo en el juego
class Obstacle {
  final String id;
  final ObstacleType type;
  final GameOrientation orientation;
  final double width;
  final double height;
  final String assetPath;
  final int damage; // Daño que causa al jugador
  final bool isDestructible;
  
  // Posición actual del obstáculo
  double x;
  double y;
  LanePosition currentLane;
  
  // Estado del obstáculo
  bool isVisible;
  bool isDestroyed;
  DateTime? creationTime;
  
  Obstacle({
    required this.id,
    required this.type,
    required this.orientation,
    required this.width,
    required this.height,
    required this.assetPath,
    required this.damage,
    required this.x,
    required this.y,
    required this.currentLane,
    this.isDestructible = false,
    this.isVisible = true,
    this.isDestroyed = false,
    DateTime? creationTime,
  }) : creationTime = creationTime ?? DateTime.now();
  
  /// Factory para crear un cono
  factory Obstacle.cone({
    required GameOrientation orientation,
    required double x,
    required double y,
    required LanePosition lane,
  }) {
    return Obstacle(
      id: 'cone_${DateTime.now().millisecondsSinceEpoch}',
      type: ObstacleType.cone,
      orientation: orientation,
      width:  40,
      height: 50,
      assetPath: _getObstacleAssetPath(ObstacleType.cone),
      damage: 20,
      x: x,
      y: y,
      currentLane: lane,
      isDestructible: true,
    );
  }
  
  /// Factory para crear un derrame de aceite
  factory Obstacle.oilspill({
    required GameOrientation orientation,
    required double x,
    required double y,
    required LanePosition lane,
  }) {
    return Obstacle(
      id: 'oil_${DateTime.now().millisecondsSinceEpoch}',
      type: ObstacleType.oilspill,
      orientation: orientation,
      width: 70,
      height: 50,
      assetPath: _getObstacleAssetPath(ObstacleType.oilspill),
      damage: 15,
      x: x,
      y: y,
      currentLane: lane,
      isDestructible: false,
    );
  }
  
  /// Factory para crear una barrera
  factory Obstacle.barrier({
    required GameOrientation orientation,
    required double x,
    required double y,
    required LanePosition lane,
  }) {
    return Obstacle(
      id: 'barrier_${DateTime.now().millisecondsSinceEpoch}',
      type: ObstacleType.barrier,
      orientation: orientation,
      width: 40,
      height: 40,
      assetPath: _getObstacleAssetPath(ObstacleType.barrier),
      damage: 50,
      x: x,
      y: y,
      currentLane: lane,
      isDestructible: false,
    );
  }

  /// Factory para crear escombros
  factory Obstacle.debris({
    required GameOrientation orientation,
    required double x,
    required double y,
    required LanePosition lane,
  }) {
    return Obstacle(
      id: 'debris_${DateTime.now().millisecondsSinceEpoch}',
      type: ObstacleType.debris,
      orientation: orientation,
      width: 50,
      height: 50,
      assetPath: _getObstacleAssetPath(ObstacleType.debris),
      damage: 30,
      x: x,
      y: y,
      currentLane: lane,
      isDestructible: false,
    );
  }
  
  /// Mueve el obstáculo según la orientación
  void move(double speed, double deltaTime) {    
    if (orientation == GameOrientation.vertical) {
      y += speed * deltaTime * 60;
    } else {
      x += speed * deltaTime * 60;
    }    
  }
  
  /// Obtiene el rectángulo de colisión del obstáculo
  Rect getCollisionRect() {
    return Rect.fromLTWH(x, y, width, height);
  }
  
  /// Verifica si el obstáculo está fuera de los límites
  bool isOutOfBounds(Size screenSize) {
    if (orientation == GameOrientation.vertical) {
      return y > screenSize.height + 100;
    } else {
      return x > screenSize.width + 100;
    }
  }
  
  /// Destruye el obstáculo si es destructible
  void destroy() {
    if (isDestructible) {
      isDestroyed = true;
      isVisible = false;
    }
  }
  
  /// Obtiene la edad del obstáculo en segundos
  int get ageInSeconds {
    if (creationTime == null) return 0;
    return DateTime.now().difference(creationTime!).inSeconds;
  }
  
  /// Clona el obstáculo con nuevos valores
  Obstacle copyWith({
    String? id,
    ObstacleType? type,
    GameOrientation? orientation,
    double? width,
    double? height,
    String? assetPath,
    int? damage,
    double? x,
    double? y,
    LanePosition? currentLane,
    bool? isDestructible,
    bool? isVisible,
    bool? isDestroyed,
  }) {
    return Obstacle(
      id: id ?? this.id,
      type: type ?? this.type,
      orientation: orientation ?? this.orientation,
      width: width ?? this.width,
      height: height ?? this.height,
      assetPath: assetPath ?? this.assetPath,
      damage: damage ?? this.damage,
      x: x ?? this.x,
      y: y ?? this.y,
      currentLane: currentLane ?? this.currentLane,
      isDestructible: isDestructible ?? this.isDestructible,
      isVisible: isVisible ?? this.isVisible,
      isDestroyed: isDestroyed ?? this.isDestroyed,
      creationTime: creationTime,
    );
  }
  
  @override
  String toString() {
    return 'Obstacle(id: $id, type: $type, lane: $currentLane, pos: ($x, $y))';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Obstacle && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

/// Obtiene la ruta del asset para el tipo de obstáculo
String _getObstacleAssetPath(ObstacleType type) {
  final typeName = type.name;
  return 'assets/images/obstacles/$typeName.png';
}