// ===========================================================================
// El siguiente código define el modelo de un power-up en el juego,
// incluyendo sus propiedades, estados y métodos para crear diferentes tipos
// ===========================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'game_orientation.dart';
import '../constants/orientation_config.dart';
import '../constants/game_constants.dart';

/// Tipos de power-ups disponibles en el juego
enum PowerUpType {
  fuel,
  coin,
  shield,
  speedBoost,
  doublePoints,
  magnet,
}

/// Efectos que pueden tener los power-ups
enum PowerUpEffect {
  instant,    // Efecto inmediato
  duration,   // Efecto por tiempo limitado
  permanent,  // Efecto permanente hasta el final del juego
}

/// Modelo que representa un power-up en el juego
class PowerUp {
  final String id;
  final PowerUpType type;
  final GameOrientation orientation;
  final double width;
  final double height;
  final String assetPath;
  final int value;
  final PowerUpEffect effect;
  final Duration? duration; // Solo para efectos con duración
  
  // Posición actual del power-up
  double x;
  double y;
  LanePosition currentLane;
  
  // Estado del power-up
  bool isVisible;
  bool isCollected;
  DateTime? creationTime;
  
  // Animación
  double rotationAngle;
  double pulseScale;
  
  PowerUp({
    required this.id,
    required this.type,
    required this.orientation,
    required this.width,
    required this.height,
    required this.assetPath,
    required this.value,
    required this.effect,
    required this.x,
    required this.y,
    required this.currentLane,
    this.duration,
    this.isVisible = true,
    this.isCollected = false,
    DateTime? creationTime,
    this.rotationAngle = 0,
    this.pulseScale = 1.0,
  }) : creationTime = creationTime ?? DateTime.now();
  
  /// Factory para crear una moneda
  factory PowerUp.coin({
    required GameOrientation orientation,
    required double x,
    required double y,
    required LanePosition lane,
  }) {
    return PowerUp(
      id: 'coin_${DateTime.now().millisecondsSinceEpoch}',
      type: PowerUpType.coin,
      orientation: orientation,
      width: OrientationConstants.getObjectSize(orientation, 'powerUp', 'coin').width,
      height: OrientationConstants.getObjectSize(orientation, 'powerUp', 'coin').height,
      assetPath: _getPowerUpAssetPath(PowerUpType.coin, orientation),
      value: GameConstants.pointsPerCoin,
      effect: PowerUpEffect.instant,
      x: x,
      y: y,
      currentLane: lane,
    );
  }
  
  /// Factory para crear combustible
  factory PowerUp.fuel({
    required GameOrientation orientation,
    required double x,
    required double y,
    required LanePosition lane,
  }) {
    return PowerUp(
      id: 'fuel_${DateTime.now().millisecondsSinceEpoch}',
      type: PowerUpType.fuel,
      orientation: orientation,
      width: OrientationConstants.getObjectSize(orientation, 'powerUp', 'fuel').width,
      height: OrientationConstants.getObjectSize(orientation, 'powerUp', 'fuel').height,
      assetPath: _getPowerUpAssetPath(PowerUpType.fuel, orientation),
      value: GameConstants.fuelRefillValue,
      effect: PowerUpEffect.instant,
      x: x,
      y: y,
      currentLane: lane,
    );
  }
  
  /// Factory para crear escudo
  factory PowerUp.shield({
    required GameOrientation orientation,
    required double x,
    required double y,
    required LanePosition lane,
  }) {
    return PowerUp(
      id: 'shield_${DateTime.now().millisecondsSinceEpoch}',
      type: PowerUpType.shield,
      orientation: orientation,
      width: OrientationConstants.getObjectSize(orientation, 'powerUp', 'shield').width,
      height: OrientationConstants.getObjectSize(orientation, 'powerUp', 'shield').height,
      assetPath: _getPowerUpAssetPath(PowerUpType.shield, orientation),
      value: GameConstants.shieldCollisionsAllowed,
      effect: PowerUpEffect.duration,
      duration: GameConstants.shieldDuration,
      x: x,
      y: y,
      currentLane: lane,
    );
  }
  
  /// Factory para crear boost de velocidad
  factory PowerUp.speedBoost({
    required GameOrientation orientation,
    required double x,
    required double y,
    required LanePosition lane,
  }) {
    return PowerUp(
      id: 'speed_${DateTime.now().millisecondsSinceEpoch}',
      type: PowerUpType.speedBoost,
      orientation: orientation,
      width: OrientationConstants.getObjectSize(orientation, 'powerUp', 'speedBoost').width,
      height: OrientationConstants.getObjectSize(orientation, 'powerUp', 'speedBoost').height,
      assetPath: _getPowerUpAssetPath(PowerUpType.speedBoost, orientation),
      value: GameConstants.speedBoostValue,
      effect: PowerUpEffect.duration,
      duration: GameConstants.speedBoostDuration,
      x: x,
      y: y,
      currentLane: lane,
    );
  }
  
  /// Factory para crear puntos dobles
  factory PowerUp.doublePoints({
    required GameOrientation orientation,
    required double x,
    required double y,
    required LanePosition lane,
  }) {
    return PowerUp(
      id: 'double_${DateTime.now().millisecondsSinceEpoch}',
      type: PowerUpType.doublePoints,
      orientation: orientation,
      width: OrientationConstants.getObjectSize(orientation, 'powerUp', 'doublePoints').width,
      height: OrientationConstants.getObjectSize(orientation, 'powerUp', 'doublePoints').height,
      assetPath: _getPowerUpAssetPath(PowerUpType.doublePoints, orientation),
      value: GameConstants.doublePointsMultiplier,
      effect: PowerUpEffect.duration,
      duration: GameConstants.doublePointsDuration,
      x: x,
      y: y,
      currentLane: lane,
    );
  }
  
  /// Factory para crear imán
  factory PowerUp.magnet({
    required GameOrientation orientation,
    required double x,
    required double y,
    required LanePosition lane,
  }) {
    return PowerUp(
      id: 'magnet_${DateTime.now().millisecondsSinceEpoch}',
      type: PowerUpType.magnet,
      orientation: orientation,
      width: OrientationConstants.getObjectSize(orientation, 'powerUp', 'magnet').width,
      height: OrientationConstants.getObjectSize(orientation, 'powerUp', 'magnet').height,
      assetPath: _getPowerUpAssetPath(PowerUpType.magnet, orientation),
      value: GameConstants.magnetRange,
      effect: PowerUpEffect.duration,
      duration: GameConstants.magnetDuration,
      x: x,
      y: y,
      currentLane: lane,
    );
  }
  
  /// Mueve el power-up según la orientación
  void move(double speed, double deltaTime) {
    if (orientation == GameOrientation.vertical) {
      y += speed * deltaTime * 60;
    } else {
      x += speed * deltaTime * 60;
    }
  }
  
  /// Actualiza la animación del power-up
  void updateAnimation(double deltaTime) {
    // Rotación continua
    rotationAngle += deltaTime * 180; // 180 grados por segundo
    if (rotationAngle >= 360) rotationAngle -= 360;
    
    // Efecto de pulso
    final pulseSpeed = 2.0; // Ciclos por segundo
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    pulseScale = 1.0 + 0.1 * (1.0 + math.sin(time * pulseSpeed * 2 * math.pi)) / 2;
  }
  
  /// Obtiene el rectángulo de colisión del power-up
  Rect getCollisionRect() {
    return Rect.fromLTWH(x, y, width, height);
  }
  
  /// Verifica si el power-up está fuera de los límites
  bool isOutOfBounds(Size screenSize) {
    if (orientation == GameOrientation.vertical) {
      return y > screenSize.height + 100;
    } else {
      return x > screenSize.width + 100;
    }
  }
  
  /// Recoge el power-up
  void collect() {
    isCollected = true;
    isVisible = false;
  }
  
  /// Obtiene la descripción del efecto del power-up
  String getEffectDescription() {
    switch (type) {
      case PowerUpType.fuel:
        return 'Restaura $value% de combustible';
      case PowerUpType.coin:
        return '+$value puntos';
      case PowerUpType.shield:
        return 'Protección por ${duration?.inSeconds} segundos';
      case PowerUpType.speedBoost:
        return 'Velocidad x${value / 100} por ${duration?.inSeconds}s';
      case PowerUpType.doublePoints:
        return 'Puntos x$value por ${duration?.inSeconds}s';
      case PowerUpType.magnet:
        return 'Atrae monedas por ${duration?.inSeconds}s';
    }
  }
  
  /// Obtiene la edad del power-up en segundos
  int get ageInSeconds {
    if (creationTime == null) return 0;
    return DateTime.now().difference(creationTime!).inSeconds;
  }
  
  /// Clona el power-up con nuevos valores
  PowerUp copyWith({
    String? id,
    PowerUpType? type,
    GameOrientation? orientation,
    double? width,
    double? height,
    String? assetPath,
    int? value,
    PowerUpEffect? effect,
    Duration? duration,
    double? x,
    double? y,
    LanePosition? currentLane,
    bool? isVisible,
    bool? isCollected,
    double? rotationAngle,
    double? pulseScale,
  }) {
    return PowerUp(
      id: id ?? this.id,
      type: type ?? this.type,
      orientation: orientation ?? this.orientation,
      width: width ?? this.width,
      height: height ?? this.height,
      assetPath: assetPath ?? this.assetPath,
      value: value ?? this.value,
      effect: effect ?? this.effect,
      duration: duration ?? this.duration,
      x: x ?? this.x,
      y: y ?? this.y,
      currentLane: currentLane ?? this.currentLane,
      isVisible: isVisible ?? this.isVisible,
      isCollected: isCollected ?? this.isCollected,
      creationTime: creationTime,
      rotationAngle: rotationAngle ?? this.rotationAngle,
      pulseScale: pulseScale ?? this.pulseScale,
    );
  }
  
  @override
  String toString() {
    return 'PowerUp(id: $id, type: $type, lane: $currentLane, pos: ($x, $y))';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PowerUp && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

/// Obtiene la ruta del asset para el tipo de power-up
String _getPowerUpAssetPath(PowerUpType type, GameOrientation orientation) {
  final orientationFolder = orientation == GameOrientation.vertical ? 'vertical' : 'horizontal';
  final typeName = type.name;
  return 'assets/images/powerups/$orientationFolder/$typeName.png';
}
