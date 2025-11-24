// ===========================================================================
// El siguiente código define un widget base para el coche del jugador con
// controles y efectos visuales.
// ===========================================================================

import 'package:flutter/material.dart';
import '../../../../core/models/car.dart';
import '../../../../core/models/game_orientation.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/constants/colors.dart';


/// Widget base para el coche del jugador con controles y efectos
class PlayerCarWidget extends StatefulWidget {
  final Car car;
  final GameOrientation orientation;
  final bool isColliding;
  final bool hasShield;
  final bool isInCollisionCooldown;
  final AnimationController collisionAnimation;
  final Function(int) onLaneChange;
  
  const PlayerCarWidget({
    super.key,
    required this.car,
    required this.orientation,
    required this.isColliding,
    required this.hasShield,
    this.isInCollisionCooldown = false,
    required this.collisionAnimation,
    required this.onLaneChange,
  });
  
  @override
  State<PlayerCarWidget> createState() => _PlayerCarWidgetState();
}

class _PlayerCarWidgetState extends State<PlayerCarWidget>
    with TickerProviderStateMixin {
  
  late AnimationController _shieldController;
  late AnimationController _engineController;
  late AnimationController _laneChangeController;
  late Animation<double> _shieldAnimation;
  late Animation<double> _engineAnimation;
  late Animation<Offset> _laneChangeAnimation;
  
  double _dragStartPosition = 0.0;
  bool _isDragging = false;
  LanePosition _lastLane = LanePosition.center;
  Offset _animationStartPosition = Offset.zero;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }
  
  void _initializeAnimations() {
    // Animación del escudo
    _shieldController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _shieldAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _shieldController,
      curve: Curves.easeInOut,
    ));
    
    // Animación del motor
    _engineController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _engineAnimation = Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(_engineController);
    
    // Animación de cambio de carril
    _laneChangeController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    
    _laneChangeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _laneChangeController,
      curve: Curves.easeInOut,
    ));
    
    // Listener para actualizar la posición durante la animación
    _laneChangeAnimation.addListener(() {
      setState(() {
      });
    });
    
    // Inicializar variables
    _lastLane = widget.car.currentLane;
    
    // Iniciar animaciones
    if (widget.hasShield) {
      _shieldController.repeat(reverse: true);
    }
    
    _engineController.repeat(reverse: true);
  }
  
  @override
  void didUpdateWidget(PlayerCarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Detectar cambio de carril y animar
    if (widget.car.currentLane != _lastLane) {
      _animateLaneChange(oldWidget.car, widget.car);
      _lastLane = widget.car.currentLane;
    }
    
    // Manejar cambios en el escudo
    if (widget.hasShield != oldWidget.hasShield) {
      if (widget.hasShield) {
        _shieldController.repeat(reverse: true);
      } else {
        _shieldController.stop();
        _shieldController.reset();
      }
    }
  }
  
  void _animateLaneChange(Car oldCar, Car newCar) {
    // Calcular el desplazamiento de la animación
    _animationStartPosition = Offset(oldCar.x, oldCar.y);
    final targetOffset = Offset(newCar.x, newCar.y);
    
    _laneChangeAnimation = Tween<Offset>(
      begin: _animationStartPosition,
      end: targetOffset,
    ).animate(CurvedAnimation(
      parent: _laneChangeController,
      curve: Curves.easeInOut,
    ));
    
    // Reiniciar y comenzar la animación
    _laneChangeController.reset();
    _laneChangeController.forward();
  }
  
  void _handlePanStart(DragStartDetails details) {
    _isDragging = true;
    if (widget.orientation == GameOrientation.vertical) {
      _dragStartPosition = details.localPosition.dx;
    } else {
      _dragStartPosition = details.localPosition.dy;
    }
  }
  
  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    
    final currentPosition = widget.orientation == GameOrientation.vertical
        ? details.localPosition.dx
        : details.localPosition.dy;
    
    final deltaPosition = currentPosition - _dragStartPosition;
    
    // Cambiar carril si el movimiento es suficiente
    if (deltaPosition.abs() > 30) {
      if (deltaPosition > 0) {
        widget.onLaneChange(1); // Derecha/Abajo
      } else {
        widget.onLaneChange(-1); // Izquierda/Arriba
      }
      
      _isDragging = false;
    }
  }
  
  void _handlePanEnd(DragEndDetails details) {
    _isDragging = false;
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: SizedBox(
        width: widget.car.width,
        height: widget.car.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Escudo (si está activo)
            if (widget.hasShield)
              AnimatedBuilder(
                animation: _shieldAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _shieldAnimation.value,
                    child: Container(
                      width: widget.car.width + 20,
                      height: widget.car.height + 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: GameColors.shieldGradient,
                        boxShadow: [
                          BoxShadow(
                            color: GameColors.shieldSilver.withValues(alpha: 0.6),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            
            // Efecto de colisión
            if (widget.isColliding)
              AnimatedBuilder(
                animation: widget.collisionAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      (widget.collisionAnimation.value * 4 - 2) * 
                          (widget.collisionAnimation.value < 0.5 ? 1 : -1),
                      0,
                    ),
                    child: Container(
                      width: widget.car.width,
                      height: widget.car.height,
                      decoration: BoxDecoration(
                        color: GameColors.error.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
              ),
            
            // Coche principal
            AnimatedBuilder(
              animation: _engineAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    _engineAnimation.value * 0.5, // Vibración del motor
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: widget.car.width,
                        height: widget.car.height,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              GameAssets.getPlayerCarAsset(
                                widget.car.color.name,
                                widget.orientation == GameOrientation.vertical,
                              ),
                            ),
                            fit: BoxFit.contain,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      
                      // Efecto de cooldown de colisiones
                      if (widget.isInCollisionCooldown)
                        Container(
                          width: widget.car.width,
                          height: widget.car.height,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                Colors.blue.withValues(alpha: 0.3),
                                Colors.lightBlue.withValues(alpha: 0.1),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.7, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.blue.withValues(alpha: 0.6),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            
            // Indicador de dirección (cuando se arrastra)
            if (_isDragging)
              Positioned(
                bottom: -30,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: GameColors.primary.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Cambiar carril',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _shieldController.dispose();
    _engineController.dispose();
    _laneChangeController.dispose();
    super.dispose();
  }
}

/// Widget para coches de tráfico
class TrafficCarWidget extends StatelessWidget {
  final Car car;
  final bool isColliding;
  
  const TrafficCarWidget({
    super.key,
    required this.car,
    required this.isColliding,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: car.width,
      height: car.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            GameAssets.getTrafficCarAsset(
              car.color.name,
              car.orientation == GameOrientation.vertical,
            ),
          ),
          fit: BoxFit.contain,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isColliding
          ? Container(
              decoration: BoxDecoration(
                color: GameColors.error.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
            )
          : null,
    );
  }
}