import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/game_orientation.dart';
import '../../../../core/models/car.dart';
import '../../../../core/models/obstacle.dart';
import '../../../../core/models/power_up.dart';
import '../../../../core/utils/collision_detector.dart';

import '../../../../core/constants/colors.dart';
import '../shared/player_car_base.dart';
import '../shared/obstacle_base.dart';
import '../shared/collectible_base.dart';
import '../shared/game_background.dart';
import '../../controllers/game_controller.dart';

/// Área de juego principal que se adapta a la orientación
class AdaptiveGameArea extends StatefulWidget {
  final GameController gameController;
  final Function(CollisionResult)? onCollision;
  final VoidCallback? onGameOver;
  
  const AdaptiveGameArea({
    super.key,
    required this.gameController,
    this.onCollision,
    this.onGameOver,
  });
  
  @override
  State<AdaptiveGameArea> createState() => _AdaptiveGameAreaState();
}

class _AdaptiveGameAreaState extends State<AdaptiveGameArea>
    with TickerProviderStateMixin {
  
  late AnimationController _gameLoopController;
  late AnimationController _collisionController;
  
  Size? _gameAreaSize;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startGameLoop();
  }
  
  void _initializeAnimations() {
    _gameLoopController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    
    _collisionController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _gameLoopController.addListener(_updateGameLoop);
  }
  
  void _startGameLoop() {
    _gameLoopController.forward();
  }
  
  void _updateGameLoop() {
    if (!mounted) {      
      return;
    }        
    
    // Solo detectar colisiones y limpiar, el GameScreen ya maneja update()
    if (_gameAreaSize != null) {
      _detectAndHandleCollisions();
    } 
    
    _cleanupObjects();
    
    // Nota: NO llamamos widget.gameController.update() aquí porque GameScreen ya lo hace
    // Nota: NO llamamos setState() aquí porque Consumer se encarga del rebuild
  }
  
  void _detectAndHandleCollisions() {
    final gameState = widget.gameController.gameState;
    
    if (!gameState.isPlaying) {      
      return;
    }                
    
    final collisions = CollisionDetector.detectAllCollisions(
      playerCar: gameState.playerCar,
      trafficCars: gameState.trafficCars,
      obstacles: gameState.obstacles,
      powerUps: gameState.powerUps,
      gameAreaSize: _gameAreaSize!,
      orientation: gameState.orientation,
    );        
    
    for (final collision in collisions) {
      _handleCollision(collision);
    }
  }
  
  void _handleCollision(CollisionResult collision) {
    if (!collision.hasCollision) return;
    
    switch (collision.type) {
      case CollisionType.carVsPowerUp:
        _handlePowerUpCollection(collision);
        break;
      case CollisionType.carVsObstacle:
        _handleObstacleCollision(collision);
        break;
      case CollisionType.carVsCar:
        _handleCarCollision(collision);
        break;
      case CollisionType.carVsBoundary:
        _handleBoundaryCollision(collision);
        break;
      case CollisionType.none:
        break;
    }
    
    // Notificar colisión
    widget.onCollision?.call(collision);
    
    // Trigger collision animation
    if (collision.type != CollisionType.carVsPowerUp) {
      _collisionController.forward().then((_) {
        _collisionController.reset();
      });
    }
  }
  
  void _handlePowerUpCollection(CollisionResult collision) {
    final powerUp = collision.objectB as PowerUp;    
    widget.gameController.collectPowerUp(powerUp);
  }
  
  void _handleObstacleCollision(CollisionResult collision) {
    final obstacle = collision.objectA as Obstacle;
    widget.gameController.hitObstacle(obstacle);
    
    // Verificar game over
    if (widget.gameController.gameState.lives <= 0) {
      widget.onGameOver?.call();
    }
  }
  
  void _handleCarCollision(CollisionResult collision) {
    final trafficCar = collision.objectB as Car;
    widget.gameController.hitTrafficCar(trafficCar);
    
    // Verificar game over
    if (widget.gameController.gameState.lives <= 0) {
      widget.onGameOver?.call();
    }
  }
  
  void _handleBoundaryCollision(CollisionResult collision) {
    // Mantener el coche dentro de los límites
    final car = collision.objectA as Car;
    final gameState = widget.gameController.gameState;
    
    if (gameState.orientation == GameOrientation.vertical) {
      if (car.x < 0) car.x = 0;
      if (car.x + car.width > _gameAreaSize!.width) {
        car.x = _gameAreaSize!.width - car.width;
      }
    } else {
      if (car.y < 0) car.y = 0;
      if (car.y + car.height > _gameAreaSize!.height) {
        car.y = _gameAreaSize!.height - car.height;
      }
    }
  }
  
  void _cleanupObjects() {
    if (_gameAreaSize == null) return;
    
    widget.gameController.cleanupOutOfBoundsObjects(_gameAreaSize!);
    CollisionDetector.cleanupCollisionCache();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(builder: (context, controller, child) {
      final gameState = controller.gameState;            
      
      return LayoutBuilder(builder: (context, constraints) {
        // Usar todo el espacio disponible
        _gameAreaSize = Size(constraints.maxWidth, constraints.maxHeight);
        
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: GameColors.backgroundGradient,
          ),
          child: ClipRect(
            child: Stack(
              children: [
                // Fondo del juego
                GameBackground(
                  orientation: gameState.orientation,
                  gameAreaSize: _gameAreaSize!,
                  speed: gameState.adjustedGameSpeed,
                ),
                
                // Coches de tráfico
                ...gameState.trafficCars.map((car) => Positioned(
                  left: car.x,
                  top: car.y,
                  child: TrafficCarWidget(
                    car: car,
                    isColliding: car.isColliding,
                  ),
                )),
                
                // Obstáculos
                ...gameState.obstacles.map((obstacle) => Positioned(
                    left: obstacle.x,
                    top: obstacle.y,
                    child: ObstacleWidget(
                      obstacle: obstacle,
                      animationController: _gameLoopController,
                    ),
                  )),
                
                // Power-ups
                ...gameState.powerUps.map((powerUp) => Positioned(
                  left: powerUp.x,
                  top: powerUp.y,
                  child: CollectibleWidget(
                    powerUp: powerUp,
                    animationController: _gameLoopController,
                  ),
                )),
                
                // Coche del jugador
                Positioned(
                  left: gameState.playerCar.x,
                  top: gameState.playerCar.y,
                  child: PlayerCarWidget(
                    car: gameState.playerCar,
                    orientation: gameState.orientation,
                    isColliding: gameState.playerCar.isColliding,
                    hasShield: gameState.isShieldActive,
                    isInCollisionCooldown: controller.isObstacleCollisionCooldownActive,
                    collisionAnimation: _collisionController,
                    onLaneChange: (direction) {
                      controller.changeLane(direction);
                    },
                  ),
                ),
                
                // Nota: El HUD se maneja desde GameScreen para evitar duplicación
              ],
            ),
          ),
        );
      });
    });
  }
  

  
  @override
  void dispose() {
    _gameLoopController.dispose();
    _collisionController.dispose();
    super.dispose();
  }
}