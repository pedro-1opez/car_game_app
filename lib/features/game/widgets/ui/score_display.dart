import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

/// Widget que muestra la puntuación actual del jugador
class ScoreDisplay extends StatelessWidget {
  final int score;
  final int? highScore;
  final bool isAnimated;
  
  const ScoreDisplay({
    super.key,
    required this.score,
    this.highScore,
    this.isAnimated = true,
  });
  
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.stars,
                color: GameColors.coinGold,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Puntuación',
                style: TextStyle(
                  color: GameColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          AnimatedSwitcher(
            duration: isAnimated 
                ? const Duration(milliseconds: 300)
                : Duration.zero,
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: Text(
              _formatScore(score),
              key: ValueKey(score),
              style: TextStyle(
                color: GameColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (highScore != null && highScore! > 0) ...[
            const SizedBox(height: 2),
            Text(
              'Mejor: ${_formatScore(highScore!)}',
              style: TextStyle(
                color: GameColors.textSecondary,
                fontSize: 8,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
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