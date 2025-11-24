// =================================================================================
// El siguiente código define el detector de colisiones del juego,
// incluyendo métodos para detectar colisiones entre coches, obstáculos y power-ups
// =================================================================================
// Se diferencia de collision_service.dart en que este archivo solo contiene
// la lógica pura de detección de colisiones, sin manejar la respuesta a las mismas
// =================================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/car.dart';
import '../models/obstacle.dart';
import '../models/power_up.dart';
import '../models/game_orientation.dart';

/// Tipos de colisión posibles
enum CollisionType {
  none,
  carVsCar,
  carVsObstacle,
  carVsPowerUp,
  carVsBoundary,
}

/// Resultado de una colisión
class CollisionResult {
  final CollisionType type;
  final bool hasCollision;
  final dynamic objectA;
  final dynamic objectB;
  final Offset contactPoint;
  final double penetrationDepth;
  final Offset normal;
  final DateTime timestamp;
  
  const CollisionResult({
    required this.type,
    required this.hasCollision,
    required this.objectA,
    required this.objectB,
    required this.contactPoint,
    required this.penetrationDepth,
    required this.normal,
    required this.timestamp,
  });
  
  /// Constructor para colisión vacía
  factory CollisionResult.none() {
    return CollisionResult(
      type: CollisionType.none,
      hasCollision: false,
      objectA: null,
      objectB: null,
      contactPoint: Offset.zero,
      penetrationDepth: 0.0,
      normal: Offset.zero,
      timestamp: DateTime.now(),
    );
  }
  
  @override
  String toString() {
    return 'CollisionResult(type: $type, hasCollision: $hasCollision, depth: $penetrationDepth)';
  }
}

/// Detector principal de colisiones
class CollisionDetector {
  // Margen de tolerancia para colisiones
  static const double collisionTolerance = 2.0;
  
  // Cache de colisiones recientes para evitar múltiples detecciones
  static final Map<String, DateTime> _recentCollisions = {};
  static const Duration _collisionCooldown = Duration(milliseconds: 100);
  
  /// Detecta colisión entre el coche del jugador y un coche de tráfico
  static CollisionResult detectCarVsCar(Car playerCar, Car trafficCar) {
    if (_isInCooldown('${playerCar.id}_${trafficCar.id}')) {
      return CollisionResult.none();
    }
    
    final playerRect = _getAdjustedCollisionRect(playerCar);
    final trafficRect = _getAdjustedCollisionRect(trafficCar);
    
    if (_checkRectCollision(playerRect, trafficRect)) {
      final contactPoint = _calculateContactPoint(playerRect, trafficRect);
      final penetration = _calculatePenetrationDepth(playerRect, trafficRect);
      final normal = _calculateCollisionNormal(playerRect, trafficRect);
      
      _addToCooldown('${playerCar.id}_${trafficCar.id}');
      
      return CollisionResult(
        type: CollisionType.carVsCar,
        hasCollision: true,
        objectA: playerCar,
        objectB: trafficCar,
        contactPoint: contactPoint,
        penetrationDepth: penetration,
        normal: normal,
        timestamp: DateTime.now(),
      );
    }
    
    return CollisionResult.none();
  }
  
  /// Detecta colisión entre el coche del jugador y un obstáculo
  static CollisionResult detectCarVsObstacle(Car playerCar, Obstacle obstacle) {
    if (_isInCooldown('${playerCar.id}_${obstacle.id}')) {
      return CollisionResult.none();
    }
    
    final carRect = _getAdjustedCollisionRect(playerCar);
    final obstacleRect = obstacle.getCollisionRect();
    
    if (_checkRectCollision(carRect, obstacleRect)) {
      final contactPoint = _calculateContactPoint(carRect, obstacleRect);
      final penetration = _calculatePenetrationDepth(carRect, obstacleRect);
      final normal = _calculateCollisionNormal(carRect, obstacleRect);
      
      _addToCooldown('${playerCar.id}_${obstacle.id}');
      
      return CollisionResult(
        type: CollisionType.carVsObstacle,
        hasCollision: true,
        objectA: playerCar,
        objectB: obstacle,
        contactPoint: contactPoint,
        penetrationDepth: penetration,
        normal: normal,
        timestamp: DateTime.now(),
      );
    }
    
    return CollisionResult.none();
  }
  
  /// Detecta colisión entre el coche del jugador y un power-up
  static CollisionResult detectCarVsPowerUp(Car playerCar, PowerUp powerUp) {
    // DESHABILITAMOS el cooldown para power-ups para facilitar recolección
    // if (_isInCooldown('${playerCar.id}_${powerUp.id}')) {
    //   return CollisionResult.none();
    // }
    
    final carRect = _getAdjustedCollisionRect(playerCar);
    final powerUpRect = powerUp.getCollisionRect();
    
    // Los power-ups tienen un área de colisión MUY generosa para facilitar las pruebas
    final expandedPowerUpRect = Rect.fromCenter(
      center: powerUpRect.center,
      width: powerUpRect.width + 50,  // Área mucho más grande
      height: powerUpRect.height + 50, // Área mucho más grande
    );
    
    if (_checkRectCollision(carRect, expandedPowerUpRect)) {      
      final contactPoint = _calculateContactPoint(carRect, expandedPowerUpRect);
      
      // NO añadir cooldown para power-ups para permitir múltiples intentos
      // _addToCooldown('${playerCar.id}_${powerUp.id}');
      
      return CollisionResult(
        type: CollisionType.carVsPowerUp,
        hasCollision: true,
        objectA: playerCar,
        objectB: powerUp,
        contactPoint: contactPoint,
        penetrationDepth: 0.0, // Los power-ups no tienen penetración
        normal: Offset.zero,
        timestamp: DateTime.now(),
      );
    }
    
    return CollisionResult.none();
  }
  
  /// Detecta si el coche está fuera de los límites del área de juego
  static CollisionResult detectCarVsBoundary(Car car, Size gameAreaSize, GameOrientation orientation) {
    final carRect = car.getCollisionRect();
    bool isOutOfBounds = false;
    Offset contactPoint = Offset.zero;
    Offset normal = Offset.zero;
    
    if (orientation == GameOrientation.vertical) {
      // En modo vertical, el coche no puede salir horizontalmente
      if (carRect.left < 0) {
        isOutOfBounds = true;
        contactPoint = Offset(0, carRect.center.dy);
        normal = const Offset(1, 0); // Normal hacia la derecha
      } else if (carRect.right > gameAreaSize.width) {
        isOutOfBounds = true;
        contactPoint = Offset(gameAreaSize.width, carRect.center.dy);
        normal = const Offset(-1, 0); // Normal hacia la izquierda
      }
    } else {
      // En modo horizontal, el coche no puede salir verticalmente
      if (carRect.top < 0) {
        isOutOfBounds = true;
        contactPoint = Offset(carRect.center.dx, 0);
        normal = const Offset(0, 1); // Normal hacia abajo
      } else if (carRect.bottom > gameAreaSize.height) {
        isOutOfBounds = true;
        contactPoint = Offset(carRect.center.dx, gameAreaSize.height);
        normal = const Offset(0, -1); // Normal hacia arriba
      }
    }
    
    if (isOutOfBounds) {
      return CollisionResult(
        type: CollisionType.carVsBoundary,
        hasCollision: true,
        objectA: car,
        objectB: null,
        contactPoint: contactPoint,
        penetrationDepth: 0.0,
        normal: normal,
        timestamp: DateTime.now(),
      );
    }
    
    return CollisionResult.none();
  }
  
  /// Detecta múltiples colisiones de una vez
  static List<CollisionResult> detectAllCollisions({
    required Car playerCar,
    required List<Car> trafficCars,
    required List<Obstacle> obstacles,
    required List<PowerUp> powerUps,
    required Size gameAreaSize,
    required GameOrientation orientation,
  }) {
    final results = <CollisionResult>[];
    
    // Colisiones con coches de tráfico
    for (final trafficCar in trafficCars) {
      if (trafficCar.isVisible && !trafficCar.isColliding) {
        final result = detectCarVsCar(playerCar, trafficCar);
        if (result.hasCollision) {
          results.add(result);
        }
      }
    }
    
    // Colisiones con obstáculos
    for (final obstacle in obstacles) {
      if (obstacle.isVisible && !obstacle.isDestroyed) {
        final result = detectCarVsObstacle(playerCar, obstacle);
        if (result.hasCollision) {
          results.add(result);
        }
      }
    }        
    
    for (final powerUp in powerUps) {
      if (powerUp.isVisible && !powerUp.isCollected) {
        final result = detectCarVsPowerUp(playerCar, powerUp);
        if (result.hasCollision) {          
          results.add(result);
        }
      }
    }
    
    // Colisión con límites
    final boundaryResult = detectCarVsBoundary(playerCar, gameAreaSize, orientation);
    if (boundaryResult.hasCollision) {
      results.add(boundaryResult);
    }
    
    return results;
  }
  
  /// Verifica si un punto está dentro de un rectángulo
  static bool isPointInRect(Offset point, Rect rect) {
    return rect.contains(point);
  }
  
  /// Calcula la distancia entre dos puntos
  static double distanceBetween(Offset point1, Offset point2) {
    return (point1 - point2).distance;
  }
  
  /// Verifica si dos círculos colisionan
  static bool checkCircleCollision(Offset center1, double radius1, Offset center2, double radius2) {
    final distance = distanceBetween(center1, center2);
    return distance <= (radius1 + radius2);
  }
  
  /// Limpia el cache de colisiones antiguas
  static void cleanupCollisionCache() {
    final now = DateTime.now();
    _recentCollisions.removeWhere((key, timestamp) {
      return now.difference(timestamp) > _collisionCooldown;
    });
  }
  
  /// Obtiene estadísticas del detector de colisiones
  static Map<String, dynamic> getStats() {
    return {
      'cached_collisions': _recentCollisions.length,
      'cooldown_duration': _collisionCooldown.inMilliseconds,
      'collision_tolerance': collisionTolerance,
    };
  }
  
  // === MÉTODOS PRIVADOS ===
  
  /// Obtiene un rectángulo de colisión ajustado para mayor precisión
  static Rect _getAdjustedCollisionRect(Car car) {
    final originalRect = car.getCollisionRect();
    // Reduce ligeramente el área de colisión para evitar falsos positivos
    return Rect.fromCenter(
      center: originalRect.center,
      width: originalRect.width - collisionTolerance,
      height: originalRect.height - collisionTolerance,
    );
  }
  
  /// Verifica colisión entre dos rectángulos
  static bool _checkRectCollision(Rect rect1, Rect rect2) {
    return rect1.overlaps(rect2);
  }
  
  /// Calcula el punto de contacto entre dos rectángulos
  static Offset _calculateContactPoint(Rect rect1, Rect rect2) {
    final intersection = Rect.fromLTRB(
      math.max(rect1.left, rect2.left),
      math.max(rect1.top, rect2.top),
      math.min(rect1.right, rect2.right),
      math.min(rect1.bottom, rect2.bottom),
    );
    
    return intersection.center;
  }
  
  /// Calcula la profundidad de penetración
  static double _calculatePenetrationDepth(Rect rect1, Rect rect2) {
    final overlapX = math.min(rect1.right, rect2.right) - math.max(rect1.left, rect2.left);
    final overlapY = math.min(rect1.bottom, rect2.bottom) - math.max(rect1.top, rect2.top);
    
    return math.min(overlapX, overlapY);
  }
  
  /// Calcula la normal de colisión
  static Offset _calculateCollisionNormal(Rect rect1, Rect rect2) {
    final center1 = rect1.center;
    final center2 = rect2.center;
    final direction = center1 - center2;
    
    if (direction.distance == 0) return const Offset(0, -1);
    
    return direction / direction.distance;
  }
  
  /// Verifica si una colisión está en periodo de enfriamiento
  static bool _isInCooldown(String collisionKey) {
    final lastCollision = _recentCollisions[collisionKey];
    if (lastCollision == null) return false;
    
    return DateTime.now().difference(lastCollision) < _collisionCooldown;
  }
  
  /// Añade una colisión al cache de enfriamiento
  static void _addToCooldown(String collisionKey) {
    _recentCollisions[collisionKey] = DateTime.now();
  }
}