// ===============================================================================
// El siguiente código define un widget que muestra la velocidad actual del auto
// ===============================================================================

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/constants/colors.dart';

/// Widget que muestra la velocidad actual del juego
class SpeedIndicator extends StatefulWidget {
  final double speed;
  final double maxSpeed;
  final bool showNeedle;
  
  const SpeedIndicator({
    super.key,
    required this.speed,
    required this.maxSpeed,
    this.showNeedle = true,
  });
  
  @override
  State<SpeedIndicator> createState() => _SpeedIndicatorState();
}

class _SpeedIndicatorState extends State<SpeedIndicator>
    with TickerProviderStateMixin {
  
  late AnimationController _needleController;
  late Animation<double> _needleAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }
  
  void _initializeAnimations() {
    _needleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _needleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _needleController,
      curve: Curves.easeOut,
    ));
  }
  
  @override
  void didUpdateWidget(SpeedIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animar aguja cuando cambia la velocidad
    if (widget.speed != oldWidget.speed) {
      _needleController.forward();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: GameColors.hudBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: GameColors.hudBorder,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.speed,
                color: GameColors.secondary,
                size: 16,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Velocidad',
                  style: TextStyle(
                    color: GameColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 2),
          
          Expanded(
            child: Center(
              child: widget.showNeedle
                  ? _buildSpeedometerDial()
                  : _buildSpeedBar(),
            ),
          ),
          
          const SizedBox(height: 2),
          
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${widget.speed.round()}',
              style: TextStyle(
                color: _getSpeedColor(),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSpeedometerDial() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight).clamp(25.0, 40.0);
        return SizedBox(
          width: size,
          height: size,
          child: AnimatedBuilder(
            animation: _needleAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(size, size),
                painter: SpeedometerPainter(
                  speed: widget.speed,
                  maxSpeed: widget.maxSpeed,
                  needleAnimation: _needleAnimation.value,
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  Widget _buildSpeedBar() {
    final speedRatio = (widget.speed / widget.maxSpeed).clamp(0.0, 1.0);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        return Container(
          width: availableWidth,
          height: 6,
          decoration: BoxDecoration(
            color: GameColors.surface,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: GameColors.hudBorder,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: speedRatio,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(_getSpeedColor()),
            ),
          ),
        );
      },
    );
  }
  
  Color _getSpeedColor() {
    final speedRatio = widget.speed / widget.maxSpeed;
    
    if (speedRatio > 0.8) return GameColors.error;
    if (speedRatio > 0.5) return GameColors.warning;
    return GameColors.success;
  }
  
  @override
  void dispose() {
    _needleController.dispose();
    super.dispose();
  }
}

/// Painter customizado para el velocimetro circular
class SpeedometerPainter extends CustomPainter {
  final double speed;
  final double maxSpeed;
  final double needleAnimation;
  
  SpeedometerPainter({
    required this.speed,
    required this.maxSpeed,
    required this.needleAnimation,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    
    // Dibujar arco de fondo
    final backgroundPaint = Paint()
      ..color = GameColors.surface
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75, // Comenzar desde -135 grados
      math.pi * 1.5,   // Arco de 270 grados
      false,
      backgroundPaint,
    );
    
    // Dibujar arco de velocidad
    final speedRatio = (speed / maxSpeed).clamp(0.0, 1.0);
    final speedAngle = math.pi * 1.5 * speedRatio;
    
    final speedPaint = Paint()
      ..color = _getSpeedColor(speedRatio)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      speedAngle * needleAnimation,
      false,
      speedPaint,
    );
    
    // Dibujar aguja
    final needleAngle = -math.pi * 0.75 + (speedAngle * needleAnimation);
    final needleEnd = Offset(
      center.dx + math.cos(needleAngle) * (radius - 2),
      center.dy + math.sin(needleAngle) * (radius - 2),
    );
    
    final needlePaint = Paint()
      ..color = GameColors.textPrimary
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(center, needleEnd, needlePaint);
    
    // Dibujar centro
    canvas.drawCircle(
      center,
      3,
      Paint()..color = GameColors.primary,
    );
  }
  
  Color _getSpeedColor(double speedRatio) {
    if (speedRatio > 0.8) return GameColors.error;
    if (speedRatio > 0.5) return GameColors.warning;
    return GameColors.success;
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}