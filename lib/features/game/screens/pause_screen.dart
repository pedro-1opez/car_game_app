import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/game_controller.dart';
import '../widgets/ui/score_display.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/game_orientation.dart';

/// Pantalla de pausa del juego
class PauseScreen extends StatefulWidget {
  final GameController gameController;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;
  
  const PauseScreen({
    super.key,
    required this.gameController,
    required this.onResume,
    required this.onRestart,
    required this.onMainMenu,
  });
  
  @override
  State<PauseScreen> createState() => _PauseScreenState();
}

class _PauseScreenState extends State<PauseScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _overlayController;
  late AnimationController _contentController;
  late AnimationController _pulseController;
  
  late Animation<double> _overlayAnimation;
  late Animation<double> _contentAnimation;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }
  
  void _initializeAnimations() {
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _overlayAnimation = Tween<double>(
      begin: 0.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeOut,
    ));
    
    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }
  
  void _startAnimations() {
    _overlayController.forward();
    _contentController.forward();
    _pulseController.repeat(reverse: true);
  }
  
  void _handleResume() {
    HapticFeedback.lightImpact();
    _animateOut(() => widget.onResume());
  }
  
  void _handleRestart() {
    HapticFeedback.mediumImpact();
    _showConfirmDialog(
      title: '¿Reiniciar Juego?',
      content: 'Perderás todo el progreso actual del juego.',
      confirmText: 'Reiniciar',
      onConfirm: () => _animateOut(() => widget.onRestart()),
    );
  }
  
  void _handleMainMenu() {
    HapticFeedback.mediumImpact();
    _showConfirmDialog(
      title: '¿Volver al Menú?',
      content: 'El progreso del juego se perderá.',
      confirmText: 'Salir',
      onConfirm: () => _animateOut(() => widget.onMainMenu()),
    );
  }
  
  void _animateOut(VoidCallback callback) {
    _contentController.reverse().then((_) {
      _overlayController.reverse().then((_) {
        callback();
      });
    });
  }
  
  void _showConfirmDialog({
    required String title,
    required String content,
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: GameColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          content,
          style: TextStyle(
            color: GameColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: GameColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: GameColors.error,
              foregroundColor: GameColors.textPrimary,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleResume();
        return false;
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_overlayAnimation, _contentAnimation]),
        builder: (context, child) {
          return Material(
            color: Colors.black.withValues(alpha: _overlayAnimation.value),
            child: Center(
              child: Transform.scale(
                scale: _contentAnimation.value,
                child: _buildPauseContent(),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildPauseContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: GameColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: GameColors.primary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: GameColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título con animación de pulso
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pause_circle_filled,
                      color: GameColors.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'JUEGO PAUSADO',
                      style: TextStyle(
                        color: GameColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Estadísticas actuales
          _buildGameStats(),
          
          const SizedBox(height: 32),
          
          // Botones de acción
          _buildActionButtons(),
          
          const SizedBox(height: 16),
          
          // Información adicional
          _buildGameInfo(),
        ],
      ),
    );
  }
  
  Widget _buildGameStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GameColors.hudBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Puntuación actual
          ScoreDisplay(
            score: widget.gameController.gameState.score,
            highScore: widget.gameController.gameState.highScore,
            isAnimated: false,
          ),
          
          const SizedBox(height: 16),
          
          // Estadísticas en filas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                icon: Icons.timeline,
                label: 'Distancia',
                value: '${widget.gameController.gameState.distanceTraveled.toInt()}m',
                color: GameColors.success,
              ),
              _buildStatItem(
                icon: Icons.access_time,
                label: 'Tiempo',
                value: _formatGameTime(widget.gameController.gameState.gameTime),
                color: GameColors.secondary,
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                icon: Icons.monetization_on,
                label: 'Monedas',
                value: '${widget.gameController.gameState.coinsCollected}',
                color: GameColors.coinGold,
              ),
              _buildStatItem(
                icon: Icons.favorite,
                label: 'Vidas',
                value: '${widget.gameController.gameState.lives}/3',
                color: GameColors.livesActive,
              ),
            ],
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
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: GameColors.textSecondary,
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: GameColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Botón principal (Continuar)
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
            onPressed: _handleResume,
            icon: const Icon(Icons.play_arrow, size: 24),
            label: const Text(
              'CONTINUAR',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Botones secundarios
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: GameColors.warning,
                  side: BorderSide(color: GameColors.warning),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _handleRestart,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Reiniciar'),
              ),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: GameColors.error,
                  side: BorderSide(color: GameColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _handleMainMenu,
                icon: const Icon(Icons.home, size: 20),
                label: const Text('Menú'),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildGameInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GameColors.hudBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.gameController.gameState.orientation == GameOrientation.vertical
                ? Icons.stay_current_portrait
                : Icons.screen_rotation,
            color: GameColors.textSecondary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Modo: ${widget.gameController.gameState.orientation == GameOrientation.vertical ? "Vertical" : "Horizontal"}',
            style: TextStyle(
              color: GameColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            Icons.speed,
            color: GameColors.textSecondary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Velocidad: ${widget.gameController.gameState.gameSpeed.toInt()}',
            style: TextStyle(
              color: GameColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
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
    _pulseController.dispose();
    super.dispose();
  }
}