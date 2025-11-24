import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/obstacle.dart';
import '../models/power_up.dart';
import '../models/car.dart';
import '../utils/collision_detector.dart';
import '../constants/game_constants.dart';
import 'effects_service.dart';

/// Servicio para manejar todas las colisiones del juego
class CollisionService {
  static CollisionService? _instance;
  static CollisionService get instance => _instance ??= CollisionService._();
  CollisionService._();
  
  // Sistema de cooldown para colisiones con obstaculos
  DateTime? _lastObstacleCollision;
  static const Duration _obstacleCollisionCooldown = Duration(milliseconds: 1500);
  
  /// Detecta y maneja todas las colisiones del juego
  GameState detectAndHandleCollisions(GameState gameState, Size gameAreaSize) {
    if (!gameState.isPlaying) return gameState;
    
    final collisions = CollisionDetector.detectAllCollisions(
      playerCar: gameState.playerCar,
      trafficCars: gameState.trafficCars,
      obstacles: gameState.obstacles,
      powerUps: gameState.powerUps,
      gameAreaSize: gameAreaSize,
      orientation: gameState.orientation,
    );
    
    var updatedGameState = gameState;
    
    for (final collision in collisions) {
      updatedGameState = _handleCollision(updatedGameState, collision);
    }
    
    return updatedGameState;
  }
  
  /// Maneja una colision especifica
  GameState _handleCollision(GameState gameState, CollisionResult collision) {
    if (!collision.hasCollision) return gameState;
    
    switch (collision.type) {
      case CollisionType.carVsPowerUp:
        return _handlePowerUpCollision(gameState, collision);
      case CollisionType.carVsObstacle:
        return _handleObstacleCollision(gameState, collision);
      case CollisionType.carVsCar:
        return _handleCarCollision(gameState, collision);
      case CollisionType.carVsBoundary:
        return gameState; // Sin accion especial
      case CollisionType.none:
        break;
    }
    
    return gameState;
  }
  
  /// Maneja colision con power-up
  GameState _handlePowerUpCollision(GameState gameState, CollisionResult collision) {
    final powerUp = collision.objectB as PowerUp;
    return EffectsService.instance.collectPowerUp(gameState, powerUp);
  }
  
  /// Maneja colision con obstaculo
  GameState _handleObstacleCollision(GameState gameState, CollisionResult collision) {
    final obstacle = collision.objectB as Obstacle;
    
    // Solo procesar si el obstaculo no esta destruido y es visible
    if (obstacle.isDestroyed || !obstacle.isVisible) {
      return gameState;
    }
    
    return _hitObstacle(gameState, obstacle);
  }
  
  /// Maneja colision entre coches
  GameState _handleCarCollision(GameState gameState, CollisionResult collision) {
    final trafficCar = collision.objectB as Car;
    
    // Crear un obstaculo temporal para manejar la colision
    final tempObstacle = Obstacle(
      id: 'temp_obstacle',
      type: ObstacleType.cone,
      orientation: gameState.orientation,
      width: 40,
      height: 40,
      assetPath: '',
      damage: 50,
      x: trafficCar.x,
      y: trafficCar.y,
      currentLane: trafficCar.currentLane,
    );
    
    return _hitObstacle(gameState, tempObstacle);
  }
  
  /// Procesa el golpe contra un obstaculo
  GameState _hitObstacle(GameState gameState, Obstacle obstacle) {
    // Verificar cooldown de colision con obstaculos
    final now = DateTime.now();
    if (_lastObstacleCollision != null && 
        now.difference(_lastObstacleCollision!) < _obstacleCollisionCooldown) {
      return gameState; // Ignorar colision debido al cooldown
    }
    
    if (gameState.isShieldActive) {
      // El escudo absorbe el golpe
      _lastObstacleCollision = now; // Activar cooldown incluso con escudo
      return EffectsService.instance.deactivateShield(gameState);
    }
    
    // Registrar el tiempo de la colision
    _lastObstacleCollision = now;
    
    // Reducir vidas
    final newLives = (gameState.lives - 1).clamp(0, GameConstants.maxLives);
    
    // Marcar coche como colisionando
    final updatedCar = gameState.playerCar.copyWith(isColliding: true);
    
    var updatedGameState = gameState.copyWith(
      lives: newLives,
      playerCar: updatedCar,
    );
    
    // Verificar game over
    if (newLives <= 0) {
      updatedGameState = updatedGameState.copyWith(status: GameStatus.gameOver);
    }
    
    return updatedGameState;
  }
  
  /// Limpia objetos fuera de los limites
  GameState cleanupOutOfBoundsObjects(GameState gameState, Size gameAreaSize) {
    // Filtrar coches de trafico fuera de pantalla
    final newTrafficCars = gameState.trafficCars
        .where((car) => !car.isOutOfBounds(gameAreaSize))
        .toList();
    
    // Filtrar obstaculos fuera de pantalla
    final newObstacles = gameState.obstacles
        .where((obstacle) => !obstacle.isOutOfBounds(gameAreaSize))
        .toList();
    
    // Filtrar power-ups: eliminar los que estan fuera de pantalla O que han sido recolectados
    final newPowerUps = gameState.powerUps
        .where((powerUp) => !powerUp.isOutOfBounds(gameAreaSize) && !powerUp.isCollected)
        .toList();
    
    // Actualizar estado solo si algo cambio
    if (newTrafficCars.length != gameState.trafficCars.length ||
        newObstacles.length != gameState.obstacles.length ||
        newPowerUps.length != gameState.powerUps.length) {
      return gameState.copyWith(
        trafficCars: newTrafficCars,
        obstacles: newObstacles,
        powerUps: newPowerUps,
      );
    }
    
    return gameState;
  }
  
  /// Verifica si el cooldown de colisiones con obstaculos esta activo
  bool get isObstacleCollisionCooldownActive {
    if (_lastObstacleCollision == null) return false;
    final now = DateTime.now();
    return now.difference(_lastObstacleCollision!) < _obstacleCollisionCooldown;
  }
  
  /// Obtiene el tiempo restante del cooldown en millisegundos
  int get obstacleCollisionCooldownRemainingMs {
    if (!isObstacleCollisionCooldownActive) return 0;
    final now = DateTime.now();
    final elapsed = now.difference(_lastObstacleCollision!);
    return (_obstacleCollisionCooldown.inMilliseconds - elapsed.inMilliseconds)
        .clamp(0, _obstacleCollisionCooldown.inMilliseconds);
  }
  
  /// Resetea el cooldown
  void resetCooldown() {
    _lastObstacleCollision = null;
  }
  
  /// Método de compatibilidad para manejar una colisión individual
  /// (Para mantener compatibilidad con métodos públicos como hitObstacle)
  GameState handleSingleCollision(GameState gameState, CollisionResult collision) {
    return _handleCollision(gameState, collision);
  }
}