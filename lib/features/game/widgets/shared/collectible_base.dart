// ===========================================================================
// El siguiente código define un widget base para coleccionables (power-ups)
// con animaciones llamativas como flotación, rotación y efectos especiales
// ===========================================================================

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/models/power_up.dart';
import '../../../../core/models/game_orientation.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/constants/colors.dart';

/// Widget base para coleccionables (power-ups) con animaciones llamativas
class CollectibleWidget extends StatefulWidget {
  final PowerUp powerUp;
  final AnimationController animationController;
  
  const CollectibleWidget({
    super.key,
    required this.powerUp,
    required this.animationController,
  });
  
  @override
  State<CollectibleWidget> createState() => _CollectibleWidgetState();
}

class _CollectibleWidgetState extends State<CollectibleWidget>
    with TickerProviderStateMixin {
  
  late AnimationController _floatController;
  late AnimationController _glowController;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }
  
  void _initializeAnimations() {
    // Animación de flotación
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _floatAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    
    // Animación de rotación
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(widget.animationController);
    
    // Animación de pulso
    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.elasticInOut,
    ));
    
    // Animación de brillo
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    // Iniciar animaciones
    _floatController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.powerUp.isVisible || widget.powerUp.isCollected) {
      return const SizedBox.shrink();
    }
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.animationController,
        _floatController,
        _glowController,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.scale(
            scale: _pulseAnimation.value,
            child: Transform.rotate(
              angle: _getRotationAngle(),
              child: SizedBox(
                width: widget.powerUp.width,
                height: widget.powerUp.height,
                child: _buildPowerUpByType(),
              ),
            ),
          ),
        );
      },
    );
  }
  
  double _getRotationAngle() {
    switch (widget.powerUp.type) {
      case PowerUpType.coin:
        return _rotationAnimation.value;
      case PowerUpType.magnet:
        return _rotationAnimation.value * 0.5;
      default:
        return 0.0;
    }
  }
  
  Widget _buildPowerUpByType() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Efecto de brillo de fondo
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              width: widget.powerUp.width + 10,
              height: widget.powerUp.height + 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _getPowerUpGlowColor().withValues(alpha: _glowAnimation.value * 0.6),
                    _getPowerUpGlowColor().withValues(alpha: 0.0),
                  ],
                ),
              ),
            );
          },
        ),
        
        // Power-up principal
        Container(
          width: widget.powerUp.width,
          height: widget.powerUp.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                GameAssets.getPowerUpAsset(
                  widget.powerUp.type.name,
                  widget.powerUp.orientation == GameOrientation.vertical,
                ),
              ),
              fit: BoxFit.contain,
            ),
            boxShadow: [
              BoxShadow(
                color: _getPowerUpGlowColor().withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        
        // Efectos especiales por tipo
        _buildSpecialEffects(),
        
        // Indicador de valor (para monedas)
        if (widget.powerUp.type == PowerUpType.coin)
          Positioned(
            bottom: -15,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: GameColors.coinGold.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+${widget.powerUp.value}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildSpecialEffects() {
    switch (widget.powerUp.type) {
      case PowerUpType.speedBoost:
        return _buildSpeedTrailEffect();
      case PowerUpType.shield:
        return _buildShieldRippleEffect();
      case PowerUpType.doublePoints:
        return _buildStarBurstEffect();
      case PowerUpType.magnet:
        return _buildMagneticFieldEffect();
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildSpeedTrailEffect() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: SpeedTrailPainter(
              progress: _glowAnimation.value,
              color: GameColors.speedRed,
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildShieldRippleEffect() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: widget.powerUp.width + (20 * _glowAnimation.value),
          height: widget.powerUp.height + (20 * _glowAnimation.value),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: GameColors.shieldSilver.withValues(alpha: 0.6 * _glowAnimation.value),
              width: 2,
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildStarBurstEffect() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: CustomPaint(
            size: Size(widget.powerUp.width + 10, widget.powerUp.height + 10),
            painter: StarBurstPainter(
              color: GameColors.pointsGreen,
              opacity: _glowAnimation.value,
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildMagneticFieldEffect() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.powerUp.width + 20, widget.powerUp.height + 20),
          painter: MagneticFieldPainter(
            progress: _glowAnimation.value,
            color: GameColors.magnetPurple,
          ),
        );
      },
    );
  }
  
  Color _getPowerUpGlowColor() {
    switch (widget.powerUp.type) {
      case PowerUpType.coin:
        return GameColors.coinGold;
      case PowerUpType.fuel:
        return GameColors.fuelBlue;
      case PowerUpType.shield:
        return GameColors.shieldSilver;
      case PowerUpType.speedBoost:
        return GameColors.speedRed;
      case PowerUpType.doublePoints:
        return GameColors.pointsGreen;
      case PowerUpType.magnet:
        return GameColors.magnetPurple;
    }
  }
  
  @override
  void dispose() {
    _floatController.dispose();
    _glowController.dispose();
    super.dispose();
  }
}

// Custom Painters para efectos especiales

class SpeedTrailPainter extends CustomPainter {
  final double progress;
  final Color color;
  
  SpeedTrailPainter({required this.progress, required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    for (int i = 0; i < 3; i++) {
      final offset = i * 8.0 * progress;
      canvas.drawLine(
        Offset(center.dx - offset, center.dy),
        Offset(center.dx - offset - 10, center.dy),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class StarBurstPainter extends CustomPainter {
  final Color color;
  final double opacity;
  
  StarBurstPainter({required this.color, required this.opacity});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;
    
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2) / 8;
      final start = center;
      final end = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      canvas.drawLine(start, end, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MagneticFieldPainter extends CustomPainter {
  final double progress;
  final Color color;
  
  MagneticFieldPainter({required this.progress, required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    for (int i = 1; i <= 3; i++) {
      final radius = (size.width / 6) * i * progress;
      canvas.drawCircle(center, radius, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}