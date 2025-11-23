import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/models/game_orientation.dart';
import '../../../../core/constants/colors.dart';


/// Fondo del juego con carretera animada y efectos de movimiento
class GameBackground extends StatefulWidget {
  final GameOrientation orientation;
  final Size gameAreaSize;
  final double speed;
  
  const GameBackground({
    super.key,
    required this.orientation,
    required this.gameAreaSize,
    required this.speed,
  });
  
  @override
  State<GameBackground> createState() => _GameBackgroundState();
}

class _GameBackgroundState extends State<GameBackground>
    with TickerProviderStateMixin {
  
  late AnimationController _roadController;
  late Animation<double> _roadOffset;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }
  
  void _initializeAnimations() {
    // Animación del movimiento de la carretera
    _roadController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _roadOffset = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_roadController);
    
    // Iniciar animaciones
    _roadController.repeat();
  }
  
  @override
  void didUpdateWidget(GameBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Ajustar velocidad de animación según la velocidad del juego
    final speedFactor = widget.speed / 200.0; // 200 es la velocidad base
    _roadController.duration = Duration(
      milliseconds: (2000 / speedFactor).round().clamp(500, 5000),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.gameAreaSize.width,
      height: widget.gameAreaSize.height,
      child: Stack(
        children: [
          // Fondo del cielo
          _buildSkyBackground(),
          
          // Carretera principal
          _buildAnimatedRoad(),
          
          // Líneas de carril
          _buildLaneLines(),
          
          // Efectos de velocidad
          if (widget.speed > 300)
            _buildSpeedEffect(),
        ],
      ),
    );
  }
  
  Widget _buildSkyBackground() {
    return Container(
      width: widget.gameAreaSize.width,
      height: widget.gameAreaSize.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: widget.orientation == GameOrientation.vertical
              ? Alignment.topCenter
              : Alignment.centerLeft,
          end: widget.orientation == GameOrientation.vertical
              ? Alignment.bottomCenter
              : Alignment.centerRight,
          colors: const [
            Color(0xFF4A90E2), // Azul cielo profundo
            Color(0xFF87CEEB), // Azul cielo claro
            Color(0xFF98D8E8), // Azul cielo medio
            Color(0xFFB8E6F0), // Transición suave
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
        ),
      ),
    );
  }
  

  
  Widget _buildAnimatedRoad() {
    return Positioned.fill(
      child: Container(
        width: widget.gameAreaSize.width,
        height: widget.gameAreaSize.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: widget.orientation == GameOrientation.vertical
                ? Alignment.topCenter
                : Alignment.centerLeft,
            end: widget.orientation == GameOrientation.vertical
                ? Alignment.bottomCenter
                : Alignment.centerRight,
            colors: [
              GameColors.roadSurface.withValues(alpha: 0.3),
              GameColors.roadSurface,
              GameColors.roadSurface,
              GameColors.roadSurface.withValues(alpha: 0.8),
            ],
            stops: const [0.0, 0.2, 0.8, 1.0],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLaneLines() {
    return AnimatedBuilder(
      animation: _roadOffset,
      builder: (context, child) {
        return CustomPaint(
          size: widget.gameAreaSize,
          painter: LaneLinesPainter(
            orientation: widget.orientation,
            offset: _roadOffset.value,
            speed: widget.speed,
          ),
        );
      },
    );
  }
  
  Widget _buildSpeedEffect() {
    return AnimatedBuilder(
      animation: _roadOffset,
      builder: (context, child) {
        return CustomPaint(
          size: widget.gameAreaSize,
          painter: SpeedEffectPainter(
            orientation: widget.orientation,
            progress: _roadOffset.value,
            speed: widget.speed,
          ),
        );
      },
    );
  }
  
  @override
  void dispose() {
    _roadController.dispose();
    super.dispose();
  }
}

// Custom Painters

class LaneLinesPainter extends CustomPainter {
  final GameOrientation orientation;
  final double offset;
  final double speed;
  
  LaneLinesPainter({
    required this.orientation,
    required this.offset,
    required this.speed,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GameColors.roadLine
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final dashPaint = Paint()
      ..color = GameColors.roadLine
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    if (orientation == GameOrientation.vertical) {
      _paintVerticalLanes(canvas, size, paint, dashPaint);
    } else {
      _paintHorizontalLanes(canvas, size, paint, dashPaint);
    }
  }
  
  void _paintVerticalLanes(Canvas canvas, Size size, Paint paint, Paint dashPaint) {
    final roadWidth = size.width;
    final laneWidth = roadWidth / 3; // Cada carril ocupa exactamente 1/3 del ancho
    
    // Líneas divisorias de carriles (discontinuas)
    final dashHeight = 40.0;
    final gapHeight = 30.0;
    final animationOffset = offset * (dashHeight + gapHeight);
    
    // Dibujar líneas divisorias entre los 3 carriles
    for (int lane = 1; lane <= 2; lane++) {
      final x = laneWidth * lane; // Posición exacta entre carriles
      
      for (double y = -animationOffset; y < size.height + dashHeight; y += dashHeight + gapHeight) {
        if (y >= -dashHeight && y <= size.height) {
          canvas.drawLine(
            Offset(x, math.max(0, y)),
            Offset(x, math.min(size.height, y + dashHeight)),
            dashPaint,
          );
        }
      }
    }
    
    // Líneas laterales de la carretera (bordes exteriores)
    canvas.drawLine(
      Offset(0, 0),
      Offset(0, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(roadWidth, 0),
      Offset(roadWidth, size.height),
      paint,
    );
  }
  
  void _paintHorizontalLanes(Canvas canvas, Size size, Paint paint, Paint dashPaint) {
    final roadHeight = size.height;
    final laneHeight = roadHeight / 3; // Cada carril ocupa exactamente 1/3 de la altura
    
    // Líneas divisorias de carriles (discontinuas)
    final dashWidth = 40.0;
    final gapWidth = 30.0;
    final animationOffset = offset * (dashWidth + gapWidth);
    
    // Dibujar líneas divisorias entre los 3 carriles
    for (int lane = 1; lane <= 2; lane++) {
      final y = laneHeight * lane; // Posición exacta entre carriles
      
      for (double x = -animationOffset; x < size.width + dashWidth; x += dashWidth + gapWidth) {
        if (x >= -dashWidth && x <= size.width) {
          canvas.drawLine(
            Offset(math.max(0, x), y),
            Offset(math.min(size.width, x + dashWidth), y),
            dashPaint,
          );
        }
      }
    }
    
    // Líneas laterales de la carretera (bordes exteriores)
    canvas.drawLine(
      Offset(0, 0),
      Offset(size.width, 0),
      paint,
    );
    canvas.drawLine(
      Offset(0, roadHeight),
      Offset(size.width, roadHeight),
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SpeedEffectPainter extends CustomPainter {
  final GameOrientation orientation;
  final double progress;
  final double speed;
  
  SpeedEffectPainter({
    required this.orientation,
    required this.progress,
    required this.speed,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final intensity = ((speed - 300) / 200).clamp(0.0, 1.0);
    
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1 * intensity)
      ..strokeWidth = 1 + (intensity * 2)
      ..style = PaintingStyle.stroke;
    
    final random = math.Random(42); // Seed fijo para consistencia
    
    for (int i = 0; i < (10 * intensity).round(); i++) {
      final startOffset = random.nextDouble();
      final length = 20 + (random.nextDouble() * 40 * intensity);
      
      double x1, y1, x2, y2;
      
      if (orientation == GameOrientation.vertical) {
        x1 = size.width * (0.1 + random.nextDouble() * 0.8);
        y1 = ((progress + startOffset) % 1.0) * size.height;
        x2 = x1;
        y2 = y1 + length;
      } else {
        x1 = ((progress + startOffset) % 1.0) * size.width;
        y1 = size.height * (0.1 + random.nextDouble() * 0.8);
        x2 = x1 + length;
        y2 = y1;
      }
      
      if ((orientation == GameOrientation.vertical && y2 <= size.height) ||
          (orientation == GameOrientation.horizontal && x2 <= size.width)) {
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}