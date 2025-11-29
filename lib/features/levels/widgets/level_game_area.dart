// ===========================================================================
// Widget de área de juego para niveles
// Similar a GameScreen pero sin manejo automático de game over
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/power_up.dart';
import '../../game/controllers/game_controller.dart';
import '../../game/widgets/adaptive/adaptive_game_area.dart';
import '../../game/widgets/ui/score_display.dart';
import '../../game/widgets/ui/fuel_gauge.dart';
import '../../game/widgets/ui/speed_indicator.dart';

class LevelGameArea extends StatefulWidget {
  final GameController gameController;

  const LevelGameArea({
    super.key,
    required this.gameController,
  });

  @override
  State<LevelGameArea> createState() => _LevelGameAreaState();
}

class _LevelGameAreaState extends State<LevelGameArea> 
    with TickerProviderStateMixin {
  
  late Ticker _gameTicker;
  DateTime? _lastUpdateTime;
  
  final bool _showHUD = true;
  
  @override
  void initState() {
    super.initState();
    _initializeGameLoop();
  }

  void _initializeGameLoop() {
    _gameTicker = createTicker((elapsed) {
      final now = DateTime.now();
      if (_lastUpdateTime != null) {
        final deltaTime = now.difference(_lastUpdateTime!).inMilliseconds / 1000.0;
        widget.gameController.update(deltaTime);
      }
      _lastUpdateTime = now;
    });
  }

  @override
  void dispose() {
    if (_gameTicker.isActive) {
      _gameTicker.stop();
    }
    _gameTicker.dispose();
    super.dispose();
  }

  Widget _buildTopHUD(GameController gameController) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score Display
          ScoreDisplay(
            score: gameController.gameState.score,
          ),
          
          // Speed Indicator
          SpeedIndicator(
            speed: 60.0, // Velocidad fija para niveles
            maxSpeed: 120.0,
          ),
        ],
      ),
    );
  }

  Widget _buildSideControls(GameController gameController) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Fuel Gauge
        FuelGauge(
          fuelLevel: (gameController.gameState.fuel / 100.0).clamp(0.0, 1.0),
          isCritical: gameController.gameState.fuel < 25.0,
        ),
      ],
    );
  }

  Widget _buildLivesIndicator(GameController gameController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: GameColors.hudBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: GameColors.hudBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite,
            color: GameColors.livesActive,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${gameController.gameState.lives}',
            style: TextStyle(
              color: GameColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeIndicator(GameController gameController) {
    final minutes = gameController.gameState.gameTime.inMinutes;
    final seconds = gameController.gameState.gameTime.inSeconds % 60;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: GameColors.hudBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: GameColors.hudBorder,
          width: 1,
        ),
      ),
      child: Text(
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
        style: TextStyle(
          color: GameColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildActiveEffects(GameController gameController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: gameController.gameState.activeEffects.map((effect) {
        final remaining = effect.remainingTime;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: GameColors.hudBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getEffectColor(effect.type),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getEffectIcon(effect.type),
                color: _getEffectColor(effect.type),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '${remaining.inSeconds}s',
                style: TextStyle(
                  color: GameColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getEffectColor(PowerUpType effectType) {
    switch (effectType) {
      case PowerUpType.shield:
        return GameColors.shieldSilver;
      case PowerUpType.speedboost:
        return GameColors.speedRed;
      case PowerUpType.doublepoints:
        return GameColors.pointsGreen;
      case PowerUpType.magnet:
        return GameColors.magnetPurple;
      default:
        return GameColors.primary;
    }
  }

  IconData _getEffectIcon(PowerUpType effectType) {
    switch (effectType) {
      case PowerUpType.shield:
        return Icons.shield;
      case PowerUpType.speedboost:
        return Icons.speed;
      case PowerUpType.doublepoints:
        return Icons.star;
      case PowerUpType.magnet:
        return Icons.radio_button_checked;
      default:
        return Icons.flash_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, gameController, child) {
        // Controlar el ticker basado en el estado del juego
        if (gameController.gameState.isPlaying) {
          if (!_gameTicker.isActive) {
            _gameTicker.start();
          }
        } else {
          // Detener el ticker si el juego no está jugando (pausa, game over, etc.)
          if (_gameTicker.isActive) {
            _gameTicker.stop();
          }
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                GameColors.background,
                GameColors.backgroundLight,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Área principal del juego
              Positioned.fill(
                child: AdaptiveGameArea(
                  gameController: gameController,
                  onGameOver: () {
                    // No hacer nada aquí - el LevelGameController maneja el game over
                  },
                ),
              ),
              
              // HUD Superior
              if (_showHUD)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildTopHUD(gameController),
                ),
              
              // Controles laterales
              if (_showHUD)
                Positioned(
                  right: 16,
                  top: MediaQuery.of(context).size.height * 0.3,
                  child: _buildSideControls(gameController),
                ),

              // Contador de vidas (inferior izquierda)
              if (_showHUD)
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: _buildLivesIndicator(gameController),
                ),

              // Contador de tiempo (inferior central)
              if (_showHUD)
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildTimeIndicator(gameController),
                  ),
                ),

              // Indicadores de efectos activos
              if (gameController.gameState.activeEffects.isNotEmpty)
                Positioned(
                  bottom: 80,
                  left: 16,
                  child: _buildActiveEffects(gameController),
                ),
            ],
          ),
        );
      },
    );
  }
}