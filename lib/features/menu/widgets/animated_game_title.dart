import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// Widget para mostrar el título animado de la aplicación
class AnimatedGameTitle extends StatelessWidget {
  final Animation<double> animation;
  final bool isSmallScreen;

  const AnimatedGameTitle({
    super.key,
    required this.animation,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono principal - Responsivo
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      GameColors.primary,
                      GameColors.secondary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: GameColors.primary.withValues(alpha: 0.3),
                      blurRadius: isSmallScreen ? 15 : 20,
                      offset: Offset(0, isSmallScreen ? 5 : 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.sports_motorsports,
                  size: isSmallScreen ? 40 : 60,
                  color: GameColors.textPrimary,
                ),
              ),
              
              SizedBox(height: isSmallScreen ? 12 : 24),
              
              // Título del juego - Responsivo
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'CAR SLIDER',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 28 : 42,
                    fontWeight: FontWeight.bold,
                    color: GameColors.textPrimary,
                    letterSpacing: isSmallScreen ? 2 : 4,
                    shadows: [
                      Shadow(
                        color: GameColors.primary.withValues(alpha: 0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ),
              ),
              
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'GAME',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 20,
                    color: GameColors.textSecondary,
                    letterSpacing: isSmallScreen ? 3 : 6,
                  ),
                ),
              ),
              
              SizedBox(height: isSmallScreen ? 8 : 16),
              
              // Subtítulo - Responsivo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Esquiva, Colecciona, Sobrevive',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: GameColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}