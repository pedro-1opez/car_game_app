// ===========================================================================
// El siguiente código define un widget base para obstáculos con animaciones
// y efectos visuales para mejorar la experiencia de juego.
// ===========================================================================

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/models/obstacle.dart';
import '../../../../core/constants/colors.dart';

/// Widget base para obstáculos con animaciones y efectos
class ObstacleWidget extends StatefulWidget {
  final Obstacle obstacle;
  final AnimationController animationController;
  
  const ObstacleWidget({
    super.key,
    required this.obstacle,
    required this.animationController,
  });
  
  @override
  State<ObstacleWidget> createState() => _ObstacleWidgetState();
}

class _ObstacleWidgetState extends State<ObstacleWidget> {
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }
  
  void _initializeAnimations() {
    // Animación de pulso para obstáculos peligrosos
    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeInOut,
    ));
    
    // Animación de rotación para ciertos obstáculos
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(widget.animationController);
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.obstacle.isVisible || widget.obstacle.isDestroyed) {
      return const SizedBox.shrink();
    }
    
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        Widget obstacleWidget = _buildObstacleByType();
        
        // Aplicar animaciones según el tipo
        switch (widget.obstacle.type) {
          case ObstacleType.cone:
            // Los conos pulsan para llamar la atención
            obstacleWidget = Transform.scale(
              scale: _pulseAnimation.value,
              child: obstacleWidget,
            );
            break;
          case ObstacleType.debris:
            // Los escombros rotan lentamente
            obstacleWidget = Transform.rotate(
              angle: _rotationAnimation.value * 0.2,
              child: obstacleWidget,
            );
            break;
          case ObstacleType.oilSpill:
            // Los derrames de aceite tienen un efecto de brillo
            obstacleWidget = _buildOilSpillEffect(obstacleWidget);
            break;
          default:
            break;
        }
        
        return SizedBox(
          width: widget.obstacle.width,
          height: widget.obstacle.height,
          child: obstacleWidget,
        );
      },
    );
  }
  
  Widget _buildObstacleByType() {
    return Stack(
      children: [
        // Sombra
        Positioned(
          left: 2,
          top: 2,
          child: Container(
            width: widget.obstacle.width,
            height: widget.obstacle.height,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: _getBorderRadius(),
            ),
          ),
        ),
        
        // Obstáculo principal
        Container(
          width: widget.obstacle.width,
          height: widget.obstacle.height,
          decoration: BoxDecoration(
            color: _getObstacleColor(),
            borderRadius: _getBorderRadius(),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Icon(
              _getObstacleIcon(),
              color: Colors.white,
              size: (widget.obstacle.width / 2).clamp(12.0, 24.0),
            ),
          ),
        ),
        
        // Indicador de peligro
        if (widget.obstacle.damage > 30)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: GameColors.error,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: GameColors.error.withValues(alpha: 0.6),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildOilSpillEffect(Widget child) {
    return Stack(
      children: [
        child,
        // Efecto de brillo
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  GameColors.oilBlack.withValues(alpha: 0.0),
                  GameColors.oilBlack.withValues(alpha: 0.3),
                  GameColors.oilBlack.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: _getBorderRadius(),
            ),
          ),
        ),
      ],
    );
  }
  
  Color _getObstacleColor() {
    switch (widget.obstacle.type) {
      case ObstacleType.cone:
        return Colors.orange;
      case ObstacleType.oilSpill:
        return Colors.black;
      case ObstacleType.barrier:
        return Colors.red;
      case ObstacleType.pothole:
        return Colors.grey.shade800;
      case ObstacleType.debris:
        return Colors.brown;
    }
  }
  
  IconData _getObstacleIcon() {
    switch (widget.obstacle.type) {
      case ObstacleType.cone:
        return Icons.warning;
      case ObstacleType.oilSpill:
        return Icons.water_drop;
      case ObstacleType.barrier:
        return Icons.block;
      case ObstacleType.pothole:
        return Icons.crisis_alert;
      case ObstacleType.debris:
        return Icons.scatter_plot;
    }
  }

  BorderRadius _getBorderRadius() {
    switch (widget.obstacle.type) {
      case ObstacleType.cone:
        return BorderRadius.circular(4);
      case ObstacleType.oilSpill:
        return BorderRadius.circular(widget.obstacle.width / 2);
      case ObstacleType.barrier:
        return BorderRadius.circular(2);
      case ObstacleType.pothole:
        return BorderRadius.circular(widget.obstacle.width / 3);
      case ObstacleType.debris:
        return BorderRadius.circular(6);
    }
  }
}