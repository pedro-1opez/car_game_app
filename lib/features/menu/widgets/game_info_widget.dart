// ===========================================================================
// Este código define el widget que se muestra en la parte inferior del menú
// principal del juego
// ===========================================================================

import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// Widget informativo del juego
class GameInfoWidget extends StatelessWidget {
  final bool isSmallScreen;

  const GameInfoWidget({
    super.key,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: GameColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            color: GameColors.textSecondary,
            size: isSmallScreen ? 14 : 16,
          ),
          SizedBox(width: isSmallScreen ? 6 : 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                isSmallScreen
                    ? 'Gestos • Power-ups • ¡Sobrevive!'
                    : 'Usa gestos para moverte • Colecciona power-ups • ¡Sobrevive!',
                style: TextStyle(
                  color: GameColors.textSecondary,
                  fontSize: isSmallScreen ? 9 : 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}