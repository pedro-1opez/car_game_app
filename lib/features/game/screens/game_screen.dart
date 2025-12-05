// ================================================================================
// El siguiente código define la pantalla principal del juego, manejando la lógica
// de actualización del estado del juego, la interfaz de usuario y la interacción
// con el usuario.
// ================================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../controllers/game_controller.dart';
import '../widgets/adaptive/adaptive_game_area.dart';
import '../widgets/ui/score_display.dart';
import '../widgets/ui/fuel_gauge.dart';
import '../widgets/ui/speed_indicator.dart';
import 'pause_screen.dart';
import 'game_over_screen.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/game_state.dart';
import '../../../core/models/game_orientation.dart';
import '../../../core/models/power_up.dart';

/// Pantalla principal del juego
class GameScreen extends StatefulWidget {
  final GameController? gameController;
  final bool showGameOverDialog;
  
  const GameScreen({
    super.key,
    this.gameController,
    this.showGameOverDialog = true,
  });
  
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _hudAnimationController;
  late AnimationController _backgroundController;
  late Animation<double> _hudFadeAnimation;
  late Animation<double> _backgroundAnimation;
  
  late Ticker _gameTicker;
  DateTime? _lastUpdateTime;
  
  bool _showHUD = true;
  bool _gameOverScreenShown = false; // Bandera para evitar múltiples pantallas de game over
  
  @override
  void initState() {
    super.initState();    
    _initializeAnimations();
    _setupSystemUI();
    _initializeGameLoop();
    
    // Solo iniciar automáticamente un nuevo juego si no está siendo controlado externamente
    if (widget.showGameOverDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final gameController = context.read<GameController>();
        gameController.startNewGame();
      });
    }
  }
  
  void _initializeAnimations() {
    _hudAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
    _hudFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hudAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));
    
    _hudAnimationController.forward();
    _backgroundController.repeat();
  }
  
  void _setupSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
  
  void _initializeGameLoop() {        
    _gameTicker = createTicker(_onTick);
    _lastUpdateTime = DateTime.now();    
    _gameTicker.start();        
  }

  void _onTick(Duration elapsed) {
    final gameController = context.read<GameController>();

    if (!gameController.gameState.isPlaying) {
      _lastUpdateTime = DateTime.now();
      return;
    }

    final currentTime = DateTime.now();

    if (_lastUpdateTime != null) {
      double deltaTime = currentTime.difference(_lastUpdateTime!).inMilliseconds / 1000.0;

      if (deltaTime > 0.1) {
        deltaTime = 0.016;
      }

      gameController.update(deltaTime);
    }

    _lastUpdateTime = currentTime;
  }
  
  void _toggleHUD() {
    setState(() {
      _showHUD = !_showHUD;
    });
    
    if (_showHUD) {
      _hudAnimationController.forward();
    } else {
      _hudAnimationController.reverse();
    }
  }
  
  void _showPauseScreen(GameController gameController) {
    gameController.togglePause();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PauseScreen(
        gameController: gameController,
        onResume: () {
          Navigator.of(context).pop();
          gameController.togglePause();
        },
        onRestart: () {
          Navigator.of(context).pop();
          gameController.startNewGame(
            orientation: gameController.gameState.orientation,
          );
        },
        onMainMenu: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop(); // Regresar al menú principal
        },
      ),
    );
  }
  
  void _showGameOverScreen(GameController gameController) {
    // DETENER EL TICKER INMEDIATAMENTE para evitar que el juego continúe
    if (_gameTicker.isActive) {
      _gameTicker.stop();      
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverScreen(
        gameController: gameController,
        onRestart: () {
          Navigator.of(context).pop();
          _gameOverScreenShown = false; // Resetear bandera
          gameController.startNewGame(
            orientation: gameController.gameState.orientation,
          );
          // Reiniciar el ticker cuando se reinicie el juego
          _gameTicker.start();          
        },
        onMainMenu: () {
          Navigator.of(context).pop();
          _gameOverScreenShown = false; // Resetear bandera
          Navigator.of(context).pop(); // Regresar al menú principal
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, gameController, child) {
        // Manejar el ticker según el estado del juego
        if (gameController.gameState.isPlaying) {
          // Solo iniciar el ticker si el juego está activo
          if (!_gameTicker.isActive) {
            _gameTicker.start();            
          }
        } else {
          // Detener el ticker si el juego no está jugando (pausa, game over, etc.)
          if (_gameTicker.isActive) {
            _gameTicker.stop();            
          }
        }
        
        // Mostrar pantalla de game over automáticamente (solo una vez)
        if (gameController.gameState.status == GameStatus.gameOver && !_gameOverScreenShown && widget.showGameOverDialog) {
          _gameOverScreenShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _showGameOverScreen(gameController);
            }
          });
        }
        
        // Resetear la bandera cuando el juego esté activo
        if (gameController.gameState.isPlaying && _gameOverScreenShown) {
          _gameOverScreenShown = false;
        }
        
        return Scaffold(
          backgroundColor: GameColors.background,
          body: AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      GameColors.primary.withValues(alpha: 0.1),
                      GameColors.background,
                      GameColors.secondary.withValues(alpha: 0.1),
                    ],
                    stops: [
                      (_backgroundAnimation.value * 0.3) % 1.0,
                      0.5,
                      (0.7 + _backgroundAnimation.value * 0.3) % 1.0,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Stack(
                    children: [
                      // Área principal del juego
                      Positioned.fill(
                        child: AdaptiveGameArea(
                          gameController: gameController,
                          onGameOver: () => _showGameOverScreen(gameController),
                        ),
                      ),
                      
                      // HUD Superior
                      if (_showHUD)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: AnimatedBuilder(
                            animation: _hudFadeAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _hudFadeAnimation.value,
                                child: _buildTopHUD(gameController),
                              );
                            },
                          ),
                        ),
                      
                      // Controles laterales
                      if (_showHUD)
                        Positioned(
                          right: 16,
                          top: MediaQuery.of(context).size.height * 0.3,
                          child: AnimatedBuilder(
                            animation: _hudFadeAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _hudFadeAnimation.value,
                                child: _buildSideControls(gameController),
                              );
                            },
                          ),
                        ),
                      

                      
                      // Contador de vidas (inferior izquierda)
                      if (_showHUD)
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: AnimatedBuilder(
                            animation: _hudFadeAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _hudFadeAnimation.value,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLivesIndicator(gameController),
                                    // Indicador de cooldown de colisiones
                                    if (gameController.isObstacleCollisionCooldownActive)
                                      const SizedBox(height: 8),
                                    if (gameController.isObstacleCollisionCooldownActive)
                                      _buildCollisionCooldownIndicator(gameController),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                      // Contador de tiempo (inferior central)
                      if (_showHUD)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: AnimatedBuilder(
                            animation: _hudFadeAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _hudFadeAnimation.value,
                                child: Center(
                                  child: _buildTimeIndicator(gameController),
                                ),
                              );
                            },
                          ),
                        ),

                      // Indicadores de efectos activos
                      if (gameController.gameState.activeEffects.isNotEmpty)
                        Positioned(
                          bottom: 80,
                          left: 16,
                          child: _buildActiveEffects(gameController),
                        ),
                      
                      // Botón para ocultar/mostrar HUD
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor: GameColors.hudBackground,
                          onPressed: _toggleHUD,
                          child: Icon(
                            _showHUD ? Icons.visibility_off : Icons.visibility,
                            color: GameColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  Widget _buildTopHUD(GameController gameController) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 8 : 12,
        vertical: isLandscape ? 6 : 12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            GameColors.hudBackground,
            GameColors.hudBackground.withValues(alpha: 0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: isLandscape ? _buildLandscapeHUD(gameController, screenWidth) : _buildPortraitHUD(gameController),
    );
  }

  Widget _buildPortraitHUD(GameController gameController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lateral izquierdo: Puntaje, Distancia y Monedas
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Puntuación
              ScoreDisplay(
                score: gameController.gameState.score,
                highScore: gameController.gameState.highScore,
              ),
              const SizedBox(height: 6),
              // Distancia y Monedas
              Row(
                children: [
                  Flexible(
                    child: _buildCompactStat(
                      icon: Icons.timeline,
                      value: '${gameController.gameState.distanceTraveled.toInt()}m',
                      color: GameColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: _buildCompactStat(
                      icon: Icons.monetization_on,
                      value: '${gameController.gameState.coinsCollected}',
                      color: GameColors.coinGold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Centro: Medidor de velocidad
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SizedBox(
              height: 80, // Altura fija para consistencia
              child: SpeedIndicator(
                speed: gameController.gameState.gameSpeed,
                maxSpeed: 300.0,
              ),
            ),
          ),
        ),
        
        // Lateral derecho: Medidor de combustible
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SizedBox(
              height: 80, // Altura fija para consistencia
              child: FuelGauge(
                fuelLevel: gameController.gameState.fuel / 100.0,
                isCritical: gameController.gameState.isFuelCritical,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeHUD(GameController gameController, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Lateral izquierdo: Puntaje compacto y estadísticas
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Puntuación compacta
              Transform.scale(
                scale: 0.85,
                alignment: Alignment.centerLeft,
                child: ScoreDisplay(
                  score: gameController.gameState.score,
                  highScore: gameController.gameState.highScore,
                ),
              ),
              const SizedBox(height: 4),
              // Distancia y Monedas
              Row(
                children: [
                  Flexible(
                    child: _buildCompactStat(
                      icon: Icons.timeline,
                      value: '${gameController.gameState.distanceTraveled.toInt()}m',
                      color: GameColors.textSecondary,
                      isSmall: true,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: _buildCompactStat(
                      icon: Icons.monetization_on,
                      value: '${gameController.gameState.coinsCollected}',
                      color: GameColors.coinGold,
                      isSmall: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Centro: Medidor de velocidad
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: SizedBox(
              height: 60, // Altura más compacta para landscape
              child: SpeedIndicator(
                speed: gameController.gameState.gameSpeed,
                maxSpeed: 300.0,
              ),
            ),
          ),
        ),
        
        // Lateral derecho: Medidor de combustible
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: SizedBox(
              height: 60, // Altura más compacta para landscape
              child: FuelGauge(
                fuelLevel: gameController.gameState.fuel / 100.0,
                isCritical: gameController.gameState.isFuelCritical,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSideControls(GameController gameController) {
    return Column(
      children: [
        // Botón de pausa
        _buildControlButton(
          icon: gameController.gameState.isPlaying
              ? Icons.pause
              : Icons.play_arrow,
          onPressed: () {
            if (gameController.gameState.status == GameStatus.menu) {
              gameController.startNewGame();
            } else if (gameController.gameState.isPlaying) {
              _showPauseScreen(gameController);
            } else {
              gameController.togglePause();
            }
          },
          color: GameColors.primary,
        ),
        
        const SizedBox(height: 12),
        
        // Botón de cambio de orientación
        _buildControlButton(
          icon: gameController.gameState.orientation == GameOrientation.vertical
              ? Icons.screen_rotation
              : Icons.stay_current_portrait,
          onPressed: () {
            final newOrientation = gameController.gameState.orientation == GameOrientation.vertical
                ? GameOrientation.horizontal
                : GameOrientation.vertical;
            
            gameController.changeOrientation(newOrientation);

            SystemChrome.setPreferredOrientations([
              newOrientation == GameOrientation.vertical
                  ? DeviceOrientation.portraitUp
                  : DeviceOrientation.landscapeLeft,
            ]);

            Future.delayed(const Duration(milliseconds: 100), () {
              gameController.changeOrientation(newOrientation);
            });
          },
          color: GameColors.secondary,
        ),
        
        const SizedBox(height: 12),
        
        // Botón de reinicio
        _buildControlButton(
          icon: Icons.refresh,
          onPressed: () {
            gameController.startNewGame(
              orientation: gameController.gameState.orientation,
            );
          },
          color: GameColors.warning,
        ),
      ],
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: GameColors.hudBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onPressed,
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
      ),
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

  Widget _buildCollisionCooldownIndicator(GameController gameController) {
    final remainingMs = gameController.obstacleCollisionCooldownRemainingMs;
    final totalMs = 1500; // Duración total del cooldown
    final progress = (totalMs - remainingMs) / totalMs;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shield,
            color: Colors.blue,
            size: 14,
          ),
          const SizedBox(width: 6),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${(remainingMs / 100).ceil() / 10}s',
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeIndicator(GameController gameController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            Icons.access_time,
            color: GameColors.textSecondary,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            _formatGameTime(gameController.gameState.gameTime),
            style: TextStyle(
              color: GameColors.textPrimary,
              fontSize: 14,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat({
    required IconData icon,
    required String value,
    required Color color,
    bool isSmall = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: GameColors.hudBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GameColors.hudBorder.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: isSmall ? 12 : 14,
          ),
          SizedBox(width: isSmall ? 3 : 4),
          Text(
            value,
            style: TextStyle(
              color: GameColors.textPrimary,
              fontSize: isSmall ? 10 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActiveEffects(GameController gameController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: gameController.gameState.activeEffects.map((effect) {
        final remaining = effect.remainingTime;
        final progress = 1.0 - (effect.remainingTime.inMilliseconds / effect.duration.inMilliseconds);
        
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
              const SizedBox(width: 6),
              SizedBox(
                width: 40,
                height: 4,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: GameColors.surface,
                  valueColor: AlwaysStoppedAnimation(_getEffectColor(effect.type)),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  IconData _getEffectIcon(PowerUpType type) {
    switch (type) {
      case PowerUpType.shield:
        return Icons.shield;
      case PowerUpType.speedboost:
        return Icons.speed;
      case PowerUpType.doublepoints:
        return Icons.stars;
      case PowerUpType.magnet:
        return Icons.attractions;
      default:
        return Icons.bolt;
    }
  }
  
  Color _getEffectColor(PowerUpType type) {
    switch (type) {
      case PowerUpType.shield:
        return GameColors.primary;
      case PowerUpType.speedboost:
        return GameColors.warning;
      case PowerUpType.doublepoints:
        return GameColors.secondary;
      case PowerUpType.magnet:
        return GameColors.success;
      default:
        return GameColors.primary;
    }
  }
  
  String _formatGameTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
  
  @override
  void dispose() {
    _gameTicker.dispose();
    _hudAnimationController.dispose();
    _backgroundController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
}