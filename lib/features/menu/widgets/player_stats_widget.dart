// ===============================================================================
// El siguiente código define un widget para mostrar las estadísticas del jugador
// en el menu principal del juego.
// ===============================================================================
// TODO: Sustituir con la ventana de estadísticas completa cuando esté lista.
// ===============================================================================

import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// Widget para mostrar estadísticas del jugador
class PlayerStatsWidget extends StatelessWidget {
  final int highScore;
  final int gamesPlayed;
  final bool isSmallScreen;

  const PlayerStatsWidget({
    super.key,
    required this.highScore,
    required this.gamesPlayed,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: GameColors.hudBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GameColors.primary,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.emoji_events,
              label: 'Mejor Puntuación',
              value: _formatScore(highScore),
              color: GameColors.coinGold,
              isSmallScreen: isSmallScreen,
            ),
          ),
          Container(
            width: 1,
            height: isSmallScreen ? 30 : 40,
            color: GameColors.hudBorder,
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.gamepad,
              label: 'Partidas Jugadas',
              value: '$gamesPlayed',
              color: GameColors.secondary,
              isSmallScreen: isSmallScreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isSmallScreen = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: isSmallScreen ? 18 : 24,
        ),
        SizedBox(height: isSmallScreen ? 2 : 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              color: GameColors.textPrimary,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                color: GameColors.textSecondary,
                fontSize: isSmallScreen ? 8 : 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  String _formatScore(int score) {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}K';
    } else {
      return score.toString();
    }
  }
}