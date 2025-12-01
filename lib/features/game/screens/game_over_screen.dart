// ===========================================================================
// El siguiente código define la pantalla de Game Over, mostrando estadísticas
// y opciones para reiniciar o volver al menú principal.
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import '../controllers/game_controller.dart';

import '../../../core/constants/colors.dart';
import '../../../core/models/game_orientation.dart';
import '../../../services/leaderboard_integration_service.dart';

/// Pantalla de Game Over con estadísticas y opciones
class GameOverScreen extends StatefulWidget {
  final GameController gameController;
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;
  
  const GameOverScreen({
    super.key,
    required this.gameController,
    required this.onRestart,
    required this.onMainMenu,
  });
  
  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _overlayController;
  late AnimationController _contentController;
  late AnimationController _shakeController;
  late AnimationController _scoreController;
  
  late Animation<double> _overlayAnimation;
  late Animation<double> _contentAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _scoreCountAnimation;
  
  bool _isNewHighScore = false;
  int _animatedScore = 0;
  
  @override
  void initState() {
    super.initState();
    _checkHighScore();
    _initializeAnimations();
    _startAnimations();
    _submitScoreToLeaderboard();
  }

  /// Envía automáticamente la puntuación al leaderboard
  void _submitScoreToLeaderboard() async {
    final score = widget.gameController.gameState.score;
    
    // Solo enviar si la puntuación es significativa
    if (score > 0) {
      try {
        final success = await LeaderboardIntegrationService.instance.submitScore(
          score: score,
          gameMode: 'infinite',
        );
        
        if (success) {
          debugPrint('✅ Puntuación enviada al leaderboard: $score');
        } else {
          debugPrint('⚠️ No se pudo enviar la puntuación al leaderboard');
        }
      } catch (e) {
        debugPrint('❌ Error al enviar puntuación: $e');
      }
    }
  }
  
  void _checkHighScore() {
    _isNewHighScore = widget.gameController.gameState.score > 
                     (widget.gameController.gameState.highScore - widget.gameController.gameState.score);
  }
  
  void _initializeAnimations() {
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _overlayAnimation = Tween<double>(
      begin: 0.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeIn,
    ));
    
    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.bounceOut,
    ));
    
    _shakeAnimation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
    
    _scoreCountAnimation = Tween<double>(
      begin: 0.0,
      end: widget.gameController.gameState.score.toDouble(),
    ).animate(CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOut,
    ));
    
    _scoreCountAnimation.addListener(() {
      setState(() {
        _animatedScore = _scoreCountAnimation.value.toInt();
      });
    });
  }
  
  void _startAnimations() {
    HapticFeedback.heavyImpact();
    
    _overlayController.forward();
    
    Future.delayed(const Duration(milliseconds: 200), () {
      _contentController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 300), () {
      _shakeController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 600), () {
      _scoreController.forward();
    });
    
    if (_isNewHighScore) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        _shakeController.repeat(reverse: true);
      });
    }
  }
  
  void _handleRestart() {
    HapticFeedback.lightImpact();
    _animateOut(() => widget.onRestart());
  }
  
  void _handleMainMenu() {
    HapticFeedback.lightImpact();
    _animateOut(() => widget.onMainMenu());
  }
  
  void _animateOut(VoidCallback callback) {
    _shakeController.stop();
    _contentController.reverse().then((_) {
      _overlayController.reverse().then((_) {
        callback();
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevenir salida con back button
      child: AnimatedBuilder(
        animation: Listenable.merge([_overlayAnimation, _contentAnimation]),
        builder: (context, child) {
          return Material(
            color: Colors.black.withValues(alpha: _overlayAnimation.value),
            child: Center(
              child: Transform.scale(
                scale: _contentAnimation.value,
                child: AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: _buildGameOverContent(),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildGameOverContent() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
        maxWidth: MediaQuery.of(context).size.width * 0.9,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: GameColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isNewHighScore ? GameColors.coinGold : GameColors.error,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: (_isNewHighScore ? GameColors.coinGold : GameColors.error)
                  .withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(MediaQuery.of(context).size.height < 600 ? 16 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
          // Título principal
          _buildGameOverTitle(),
          
          SizedBox(height: MediaQuery.of(context).size.height < 600 ? 12 : 20),
          
          // Puntuación principal con animación
          _buildAnimatedScore(),
          
          if (_isNewHighScore) ...[
            SizedBox(height: MediaQuery.of(context).size.height < 600 ? 12 : 16),
            _buildNewHighScoreBanner(),
          ],
          
          SizedBox(height: MediaQuery.of(context).size.height < 600 ? 16 : 24),
          
          // Estadísticas detalladas
          _buildDetailedStats(),
          
          SizedBox(height: MediaQuery.of(context).size.height < 600 ? 16 : 24),
          
          // Ranking de desempeño
          _buildPerformanceRanking(),
          
          SizedBox(height: MediaQuery.of(context).size.height < 600 ? 20 : 32),
          
          // Botones de acción
          _buildActionButtons(),
        ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildGameOverTitle() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 600;
    final isVerySmallScreen = screenHeight < 500 || screenWidth < 350;
    
    return Column(
      children: [
        Icon(
          Icons.sports_esports,
          color: _isNewHighScore ? GameColors.coinGold : GameColors.error,
          size: isVerySmallScreen ? 28 : (isSmallScreen ? 36 : 48),
        ),
        SizedBox(height: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12)),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _isNewHighScore ? '¡NUEVO RÉCORD!' : 'GAME OVER',
            style: TextStyle(
              color: _isNewHighScore ? GameColors.coinGold : GameColors.error,
              fontSize: isVerySmallScreen ? 18 : (isSmallScreen ? 22 : 28),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (!_isNewHighScore)
          Text(
            'No te rindas, ¡inténtalo de nuevo!',
            style: TextStyle(
              color: GameColors.textSecondary,
              fontSize: 14,
            ),
          ),
      ],
    );
  }
  
  Widget _buildAnimatedScore() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 600;
    final isVerySmallScreen = screenHeight < 500 || screenWidth < 350;
    
    return Container(
      padding: EdgeInsets.all(isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GameColors.primary.withValues(alpha: 0.2),
            GameColors.secondary.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(isVerySmallScreen ? 12 : 16),
        border: Border.all(
          color: GameColors.primary,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'PUNTUACIÓN FINAL',
              style: TextStyle(
                color: GameColors.textSecondary,
                fontSize: isVerySmallScreen ? 10 : (isSmallScreen ? 11 : 12),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: isVerySmallScreen ? 6 : 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatScore(_animatedScore),
              style: TextStyle(
                color: GameColors.textPrimary,
                fontSize: isVerySmallScreen ? 24 : (isSmallScreen ? 30 : 36),
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNewHighScoreBanner() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 600;
    final isVerySmallScreen = screenHeight < 500 || screenWidth < 350;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16),
        vertical: isVerySmallScreen ? 6 : (isSmallScreen ? 7 : 8),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GameColors.coinGold.withValues(alpha: 0.3),
            GameColors.coinGold.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(isVerySmallScreen ? 15 : 20),
        border: Border.all(
          color: GameColors.coinGold,
          width: isVerySmallScreen ? 1 : 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events,
            color: GameColors.coinGold,
            size: isVerySmallScreen ? 18 : (isSmallScreen ? 20 : 24),
          ),
          SizedBox(width: isVerySmallScreen ? 6 : 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '¡Superaste tu récord anterior!',
                style: TextStyle(
                  color: GameColors.coinGold,
                  fontSize: isVerySmallScreen ? 11 : (isSmallScreen ? 12 : 14),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailedStats() {
    final gameState = widget.gameController.gameState;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 600;
    final isVerySmallScreen = screenHeight < 500 || screenWidth < 350;
    final shouldUseVerticalLayout = screenWidth < 400;
    
    return Container(
      padding: EdgeInsets.all(isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 16)),
      decoration: BoxDecoration(
        color: GameColors.background,
        borderRadius: BorderRadius.circular(isVerySmallScreen ? 10 : 12),
        border: Border.all(
          color: GameColors.hudBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'ESTADÍSTICAS DE LA PARTIDA',
              style: TextStyle(
                color: GameColors.textPrimary,
                fontSize: isVerySmallScreen ? 11 : (isSmallScreen ? 12 : 14),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 16)),
          
          // En pantallas pequeñas o estrechas, mostrar en una sola columna
          (isSmallScreen || shouldUseVerticalLayout)
            ? _buildSingleColumnStats(gameState)
            : Row(
                children: [
                  Expanded(
                    child: _buildStatColumn(
                      [
                        _StatItem(
                          icon: Icons.timeline,
                          label: 'Distancia',
                          value: '${gameState.distanceTraveled.toInt()}m',
                          color: GameColors.success,
                        ),
                        _StatItem(
                          icon: Icons.monetization_on,
                          label: 'Monedas',
                          value: '${gameState.coinsCollected}',
                          color: GameColors.coinGold,
                        ),
                        _StatItem(
                          icon: Icons.speed,
                          label: 'Vel. Máx.',
                          value: '${gameState.gameSpeed.toInt()}',
                          color: GameColors.warning,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatColumn(
                      [
                        _StatItem(
                          icon: Icons.access_time,
                          label: 'Tiempo',
                          value: _formatGameTime(gameState.gameTime),
                          color: GameColors.secondary,
                        ),
                        _StatItem(
                          icon: Icons.local_gas_station,
                          label: 'Combustible',
                          value: '${gameState.fuel.toInt()}%',
                          color: GameColors.fuelBlue,
                        ),
                        _StatItem(
                          icon: Icons.gamepad,
                          label: 'Modo',
                          value: gameState.orientation == GameOrientation.vertical
                              ? 'Vertical'
                              : 'Horizontal',
                          color: GameColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }
  
  Widget _buildStatColumn(List<_StatItem> stats) {
    return Column(
      children: stats.map((stat) => _buildStatRow(stat)).toList(),
    );
  }

  Widget _buildSingleColumnStats(gameState) {
    final allStats = [
      _StatItem(
        icon: Icons.timeline,
        label: 'Distancia',
        value: '${gameState.distanceTraveled.toInt()}m',
        color: GameColors.success,
      ),
      _StatItem(
        icon: Icons.monetization_on,
        label: 'Monedas',
        value: '${gameState.coinsCollected}',
        color: GameColors.coinGold,
      ),
      _StatItem(
        icon: Icons.access_time,
        label: 'Tiempo',
        value: _formatGameTime(gameState.gameTime),
        color: GameColors.secondary,
      ),
      _StatItem(
        icon: Icons.speed,
        label: 'Vel. Máx.',
        value: '${gameState.gameSpeed.toInt()}',
        color: GameColors.warning,
      ),
      _StatItem(
        icon: Icons.local_gas_station,
        label: 'Combustible',
        value: '${gameState.fuel.toInt()}%',
        color: GameColors.fuelBlue,
      ),
      _StatItem(
        icon: Icons.gamepad,
        label: 'Modo',
        value: gameState.orientation == GameOrientation.vertical
            ? 'Vertical'
            : 'Horizontal',
        color: GameColors.primary,
      ),
    ];

    return Column(
      children: allStats.map((stat) => _buildStatRow(stat)).toList(),
    );
  }
  
  Widget _buildStatRow(_StatItem stat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            stat.icon,
            color: stat.color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              stat.label,
              style: TextStyle(
                color: GameColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            stat.value,
            style: TextStyle(
              color: GameColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPerformanceRanking() {
    final score = widget.gameController.gameState.score;
    final distance = widget.gameController.gameState.distanceTraveled;

    
    String rank;
    Color rankColor;
    IconData rankIcon;
    
    if (score > 50000 || distance > 5000) {
      rank = 'MAESTRO';
      rankColor = GameColors.coinGold;
      rankIcon = Icons.emoji_events;
    } else if (score > 25000 || distance > 2500) {
      rank = 'EXPERTO';
      rankColor = GameColors.primary;
      rankIcon = Icons.star;
    } else if (score > 10000 || distance > 1000) {
      rank = 'AVANZADO';
      rankColor = GameColors.success;
      rankIcon = Icons.trending_up;
    } else {
      rank = 'NOVATO';
      rankColor = GameColors.warning;
      rankIcon = Icons.sports;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            rankColor.withValues(alpha: 0.2),
            rankColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rankColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            rankIcon,
            color: rankColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Text(
                'CLASIFICACIÓN',
                style: TextStyle(
                  color: GameColors.textSecondary,
                  fontSize: 10,
                ),
              ),
              Text(
                rank,
                style: TextStyle(
                  color: rankColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Botón principal (Jugar de nuevo)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: GameColors.primary,
              foregroundColor: GameColors.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _handleRestart,
            icon: const Icon(Icons.refresh, size: 24),
            label: const Text(
              'JUGAR DE NUEVO',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Botón secundario (Menú principal)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: GameColors.textSecondary,
              side: BorderSide(color: GameColors.textSecondary),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _handleMainMenu,
            icon: const Icon(Icons.home, size: 20),
            label: const Text('MENÚ PRINCIPAL'),
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
  
  String _formatGameTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
  
  @override
  void dispose() {
    _overlayController.dispose();
    _contentController.dispose();
    _shakeController.dispose();
    _scoreController.dispose();
    super.dispose();
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  
  _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}