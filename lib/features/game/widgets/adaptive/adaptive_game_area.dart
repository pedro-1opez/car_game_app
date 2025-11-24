import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  }
  
  void _detectAndHandleCollisions() {
    // La detección de colisiones ahora se maneja completamente en GameController
    // Este método se mantiene por compatibilidad pero delega toda la lógica
    // No es necesario hacer nada aquí ya que GameController maneja todo
  }
  
  // Todos los métodos de manejo de colisión se han movido al CollisionService
  // para mejor encapsulación y evitar duplicación de código
  
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