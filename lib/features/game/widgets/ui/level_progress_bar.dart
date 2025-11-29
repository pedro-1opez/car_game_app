// ===========================================================================
// Widget de barra de progreso para niveles
// Muestra el progreso hacia la meta de distancia y monedas requeridas
// ===========================================================================

import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/models/level_state.dart';

class LevelProgressBar extends StatelessWidget {
  final LevelState levelState;
  final bool isSmallScreen;

  const LevelProgressBar({
    super.key,
    required this.levelState,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 6 : 8,
      ),
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GameColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título del nivel y número
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nivel ${levelState.level.levelNumber}',
                style: TextStyle(
                  color: GameColors.textPrimary,
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(levelState.distanceProgress * 100).toInt()}%',
                style: TextStyle(
                  color: GameColors.primary,
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          SizedBox(height: isSmallScreen ? 6 : 8),
          
          // Barra de progreso principal (distancia)
          Container(
            height: isSmallScreen ? 6 : 8,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: levelState.distanceProgress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  levelState.hasReachedDistanceGoal 
                      ? Colors.green 
                      : GameColors.primary,
                ),
              ),
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 4 : 6),
          
          // Información de objetivos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Meta de distancia
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.flag,
                    color: levelState.hasReachedDistanceGoal 
                        ? Colors.green 
                        : GameColors.textSecondary,
                    size: isSmallScreen ? 12 : 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${levelState.distanceTraveled.toInt()}m / ${levelState.level.formattedDistance}',
                    style: TextStyle(
                      color: levelState.hasReachedDistanceGoal 
                          ? Colors.green 
                          : GameColors.textSecondary,
                      fontSize: isSmallScreen ? 10 : 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              // Meta de monedas
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: levelState.hasSufficientCoins 
                        ? Colors.green 
                        : Colors.amber,
                    size: isSmallScreen ? 12 : 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${levelState.coinsCollected} / ${levelState.level.minimumCoins}',
                    style: TextStyle(
                      color: levelState.hasSufficientCoins 
                          ? Colors.green 
                          : Colors.amber,
                      fontSize: isSmallScreen ? 10 : 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),                             
        ],
      ),
    );
  }
}