// ===========================================================================
// El siguiente código define la pantalla de pausa del juego,
// mostrando estadísticas actuales y opciones para continuar,
// reiniciar o volver al menú principal.
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui'; // Para ImageFilter

import '../../../services/audio_service.dart';
import '../controllers/game_controller.dart';
import '../../../core/models/game_orientation.dart';

// Paleta local para consistencia
class PauseColors {
  static const Color accentGreen = Color(0xFF00E9A3);
  static const Color accentOrange = Color(0xFFFFD56B);
  static const Color accentRed = Color(0xFFFF5252);
  static const Color accentBlue = Color(0xFF448AFF);
  static const Color textWhite = Colors.white;
}

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

class _PauseScreenState extends State<PauseScreen> with TickerProviderStateMixin {

  late AnimationController _contentController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );

    _contentController.forward();
  }

  void _handleResume() {
    HapticFeedback.lightImpact();
    _animateOut(widget.onResume);
  }

  void _handleRestart() {
    HapticFeedback.mediumImpact();
    _showGlassConfirmDialog(
      title: '¿REINICIAR?',
      content: 'Perderás el progreso actual.',
      confirmText: 'SÍ, REINICIAR',
      confirmColor: PauseColors.accentOrange,
      onConfirm: () => _animateOut(widget.onRestart),
    );
  }

  void _handleMainMenu() {
    HapticFeedback.mediumImpact();
    AudioService.instance.stopMusic();
    _showGlassConfirmDialog(
      title: '¿SALIR?',
      content: 'Volverás al menú principal.',
      confirmText: 'SALIR',
      confirmColor: PauseColors.accentRed,
      onConfirm: () => _animateOut(widget.onMainMenu),
    );
  }

  void _animateOut(VoidCallback callback) {
    _contentController.reverse().then((_) => callback());
  }

  // Diálogo de confirmación personalizado estilo Glass
  void _showGlassConfirmDialog({
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 320),
              decoration: BoxDecoration(
                color: const Color(0xFF0F3057).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: SingleChildScrollView( // Scroll también aquí por si acaso
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: "Arial Rounded MT Bold",
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        content,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("CANCELAR", style: TextStyle(color: Colors.white54)),
                            ),
                          ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                onConfirm();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: confirmColor,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(confirmText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Detectamos orientación para ajustar espacios
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final spacerHeight = isLandscape ? 10.0 : 30.0; // Menos espacio en horizontal
    final headerHeight = isLandscape ? 10.0 : 30.0;

    return WillPopScope(
      onWillPop: () async {
        _handleResume();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // BLUR DE FONDO
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: const Color(0xFF0F3057).withOpacity(0.6),
                ),
              ),
            ),

            // CONTENIDO DEL MENÚ CON SCROLL (para horizontal)
            Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    // Limitamos la altura para que no toque los bordes en horizontal
                    constraints: BoxConstraints(
                        maxWidth: 400,
                        maxHeight: MediaQuery.of(context).size.height * 0.9
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // --- HEADER ---
                              Text(
                                "PAUSA",
                                style: TextStyle(
                                    fontFamily: "Arial Rounded MT Bold",
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 3,
                                    decoration: TextDecoration.none,
                                    shadows: [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0,4))]
                                ),
                              ),

                              SizedBox(height: headerHeight),

                              // --- SCORE BOARD ---
                              _buildScoreDisplay(),

                              SizedBox(height: isLandscape ? 10 : 20),

                              // --- STATS GRID ---
                              _buildStatsGrid(),

                              SizedBox(height: spacerHeight),

                              // --- BOTÓN CONTINUAR ---
                              _buildMainButton(
                                label: "CONTINUAR",
                                icon: Icons.play_arrow_rounded,
                                color: PauseColors.accentGreen,
                                onTap: _handleResume,
                              ),

                              const SizedBox(height: 16),

                              // --- BOTONES SECUNDARIOS ---
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSecondaryButton(
                                      label: "Reiniciar",
                                      icon: Icons.refresh_rounded,
                                      color: PauseColors.accentOrange,
                                      onTap: _handleRestart,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildSecondaryButton(
                                      label: "Salir",
                                      icon: Icons.home_rounded,
                                      color: PauseColors.accentRed,
                                      onTap: _handleMainMenu,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreDisplay() {
    return Column(
      children: [
        Text(
          "PUNTUACIÓN",
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          "${widget.gameController.gameState.score}",
          style: const TextStyle(
            fontFamily: "Arial Rounded MT Bold",
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.timeline_rounded, "${widget.gameController.gameState.distanceTraveled.toInt()}m", PauseColors.accentBlue),
          Container(width: 1, height: 30, color: Colors.white10),
          _buildStatItem(Icons.monetization_on_rounded, "${widget.gameController.gameState.coinsCollected}", PauseColors.accentOrange),
          Container(width: 1, height: 30, color: Colors.white10),
          _buildStatItem(Icons.favorite_rounded, "${widget.gameController.gameState.lives}", PauseColors.accentRed),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget _buildMainButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF0F3057), size: 28),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF0F3057),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}