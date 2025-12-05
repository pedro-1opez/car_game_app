// ===========================================================================
// El siguiente código define el fondo del juego con una carretera
// animada y efectos de movimiento según la velocidad del jugador.
// ===========================================================================

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/models/game_orientation.dart';

/// Fondo del juego con imagen de carretera en bucle infinito
class GameBackground extends StatefulWidget {
  final GameOrientation orientation;
  final Size gameAreaSize;
  final double speed;
  final String roadAssetPath; // Ruta del asset de la imagen
  final bool isPaused;

  const GameBackground({
    super.key,
    required this.orientation,
    required this.gameAreaSize,
    required this.speed,
    required this.roadAssetPath,
    required this.isPaused,
  });

  @override
  State<GameBackground> createState() => _GameBackgroundState();
}

class _GameBackgroundState extends State<GameBackground>
    with TickerProviderStateMixin {

  late AnimationController _roadController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Controlador principal del bucle de animación
    _roadController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Iniciar animación
    _roadController.repeat();
  }

  @override
  void didUpdateWidget(GameBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Ajustar velocidad de la animación según la velocidad del juego
    if (widget.isPaused != oldWidget.isPaused) {
      if (widget.isPaused) {
        _roadController.stop(); // Congela la carretera
      } else {
        // Solo reanudar si hay velocidad
        if (widget.speed > 0 && !_roadController.isAnimating) {
          _roadController.repeat();
        }
      }
    }

    // Ajustar velocidad
    if (widget.speed != oldWidget.speed && !widget.isPaused) {
      if (widget.speed <= 0) {
        _roadController.stop();
      } else {
        final durationMs = (200000 / widget.speed).clamp(100, 5000);
        _roadController.duration = Duration(milliseconds: durationMs.toInt());
        if (!_roadController.isAnimating) _roadController.repeat();
      }
    }
  }

  @override
  void dispose() {
    _roadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.gameAreaSize.width,
      height: widget.gameAreaSize.height,
      child: Stack(
        children: [
          // Capa de Fondo
          _buildImageScroller(),

          // Efectos de velocidad
          if (widget.speed > 300)
            _buildSpeedEffect(),
        ],
      ),
    );
  }

  Widget _buildImageScroller() {
    return AnimatedBuilder(
      animation: _roadController,
      builder: (context, child) {
        // El valor progress va de 0.0 a 1.0 repetidamente
        final progress = _roadController.value;

        return Stack(
          children: [
            // Renderizamos la misma imagen dos veces para lograr el efecto de bucle
            _buildMovingImage(progress, 0),
            _buildMovingImage(progress, 1),
          ],
        );
      },
    );
  }

  Widget _buildMovingImage(double progress, int index) {
    final width = widget.gameAreaSize.width;
    final height = widget.gameAreaSize.height;

    double top = 0;
    double left = 0;

    if (widget.orientation == GameOrientation.vertical) {
      // ============================================================
      // LÓGICA VERTICAL: Coche avanza hacia ARRIBA
      // Por tanto, el fondo se desplaza hacia ABAJO (+Y)
      // ============================================================
      final moveAmount = progress * height;

      if (index == 0) {
        // Imagen 1: Comienza en 0 y baja hasta salir de la pantalla
        top = moveAmount;
      } else {
        // Imagen 2: Comienza arriba (fuera de pantalla, -height) y baja
        // persiguiendo a la Imagen 1 para que no se vea espacio negro.
        top = moveAmount - height;
      }

      left = 0;

    } else {
      // ============================================================
      // LÓGICA HORIZONTAL: Coche avanza hacia DERECHA (ejemplo)
      // Por tanto, el fondo se desplaza hacia IZQUIERDA (-X)
      // ============================================================

      final moveAmount = progress * width;

      if (index == 0) {
        left = -moveAmount;
      } else {
        left = width - moveAmount;
      }

      top = 0;
    }

    return Positioned(
      top: top,
      left: left,
      width: width,
      height: height,
      child: RotatedBox(
        // Si es horizontal, rotamos 90 grados
        quarterTurns: widget.orientation == GameOrientation.horizontal ? 1 : 0,

        child: Image.asset(
          widget.roadAssetPath,
          fit: BoxFit.fill, // Esto asegura que la imagen rotada se estire para llenar la pantalla
          gaplessPlayback: true,
        ),
      ),
    );
  }

  Widget _buildSpeedEffect() {
    return AnimatedBuilder(
      animation: _roadController,
      builder: (context, child) {
        return CustomPaint(
          size: widget.gameAreaSize,
          painter: SpeedEffectPainter(
            orientation: widget.orientation,
            progress: _roadController.value,
            speed: widget.speed,
          ),
        );
      },
    );
  }
}

// Custom Painters

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
    // La intensidad del efecto depende de qué tan rápido vaya el coche (base 300)
    final intensity = ((speed - 300) / 200).clamp(0.0, 1.0);

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1 * intensity)
      ..strokeWidth = 1 + (intensity * 2)
      ..style = PaintingStyle.stroke;

    final random = math.Random(42); // Seed fijo para que las líneas "tiemblen" en su lugar pero no salten locamente

    // Dibujar líneas de viento
    for (int i = 0; i < (10 * intensity).round(); i++) {
      final startOffset = random.nextDouble();
      final length = 20 + (random.nextDouble() * 40 * intensity);

      double x1, y1, x2, y2;

      if (orientation == GameOrientation.vertical) {
        // Efecto vertical (líneas cayendo)
        x1 = size.width * (0.1 + random.nextDouble() * 0.8);
        y1 = ((progress + startOffset) % 1.0) * size.height;
        x2 = x1;
        y2 = y1 + length;
      } else {
        // Efecto horizontal (líneas pasando lateralmente)
        x1 = ((progress + startOffset) % 1.0) * size.width;
        y1 = size.height * (0.1 + random.nextDouble() * 0.8);
        x2 = x1 + length;
        y2 = y1;
      }

      // Dibujar solo si está dentro de los límites visibles
      if ((orientation == GameOrientation.vertical && y2 <= size.height) ||
          (orientation == GameOrientation.horizontal && x2 <= size.width)) {
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SpeedEffectPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.speed != speed;
  }
}