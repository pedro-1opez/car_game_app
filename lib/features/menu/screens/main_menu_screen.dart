// ===========================================================================
// Este código define la pantalla de menú principal del juego,
// con opciones para iniciar el juego, configurar ajustes y ver créditos.
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/models/game_orientation.dart';
import '../../game/game_exports.dart';
import '../../game/screens/game_screen.dart' as game;
import '../widgets/animated_game_title.dart';
import '../widgets/menu_buttons.dart';
import '../widgets/player_stats_widget.dart';
import '../widgets/game_info_widget.dart';
import '../dialogs/configuration_dialog.dart';
import '../dialogs/credits_dialog.dart';
// Asegúrate de que la ruta de importación sea correcta según tu estructura de carpetas
import 'leaderboard_screen.dart';
import 'game_mode_selection_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with TickerProviderStateMixin {
  // -- MANTENEMOS TUS CONTROLADORES ORIGINALES --
  late AnimationController _titleController;
  late AnimationController _buttonController;
  late AnimationController _streakController;
  late AnimationController _pulseController;

  late Animation<double> _titleAnimation;
  late Animation<double> _buttonAnimation;
  late Animation<double> _streakAnimation;
  late Animation<double> _pulseAnimation;

  // Colores extraídos de tu imagen de referencia
  final Color _bgDark = const Color(0xFF0F3057); // Azul oscuro fondo
  final Color _bgLight = const Color(0xFF00587A); // Azul más claro
  final Color _btnStats = const Color(0xFF00E9A3); // Verde Menta (Stats)

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _streakController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _titleAnimation = CurvedAnimation(
      parent: _titleController,
      curve: Curves.elasticOut,
    );
    _buttonAnimation = CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeOutBack,
    );
    _streakAnimation = CurvedAnimation(
      parent: _streakController,
      curve: Curves.linear,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _streakController.repeat();
    _pulseController.repeat(reverse: true);
    _titleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _buttonController.forward();
    });
  }

  void _goToGameModeSelection() {
    HapticFeedback.lightImpact();

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const GameModeSelectionScreen()),
    );
  }

  Future<void> _startGame(
      GameController gameController, [
        GameOrientation? orientation,
      ]) async {
    HapticFeedback.mediumImpact();
    if (orientation != null) {
      gameController.changeOrientation(orientation);
      SystemChrome.setPreferredOrientations([
        orientation == GameOrientation.vertical
            ? DeviceOrientation.portraitUp
            : DeviceOrientation.landscapeLeft,
      ]);
    }
    await gameController.startNewGame(orientation: orientation);
    if (mounted) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => game.GameScreen()));
    }
  }

  void _showConfigurationDialog() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => ConfigurationDialog(onStartGame: _startGame),
    );
  }

  void _showCreditsDialog() {
    HapticFeedback.lightImpact();
    showDialog(context: context, builder: (context) => const CreditsDialog());
  }

  void _openLeaderboardScreen() {
    HapticFeedback.lightImpact();
    // Usamos push en lugar de showDialog porque tu LeaderboardScreen es un Scaffold completo
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _buttonController.dispose();
    _streakController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, gameController, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: _bgDark,
          body: Stack(
            children: [
              // Fondo
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/cars/background.jpeg'),
                    fit: BoxFit.cover,
                    opacity: 0.3, // Ajusta la opacidad para no opacar el contenido
                  ),
                ),
              ),

              //Contenido Principal
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    children: [
                      // --- TÍTULO ---
                      const SizedBox(height: 150),
                      ScaleTransition(
                        scale: _titleAnimation,
                        child: _buildFlatTitle(),
                      ),

                      const Spacer(),

                      // --- ZONA DE ACCIÓN ---
                      ScaleTransition(
                        scale: _buttonAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Botón para jugar
                            _buildPillButton(
                              label: "JUGAR",
                              color: Colors.white,
                              onTap: () => _goToGameModeSelection(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 50),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCircleButton(
                            icon: Icons.info_outline, // Icono de información
                            onTap: _showCreditsDialog,
                            color: Colors.white,
                            accentColor: _btnStats,
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // --- BARRA INFERIOR (CONFIG Y CRÉDITOS) ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCircleButton(
                            icon: Icons.settings_rounded,
                            onTap: _showConfigurationDialog,
                            color: Colors.white,
                            accentColor: const Color(0xFF9E86FF), // Lila
                          ),
                          // --- BOTÓN DE LEADERBOARD ---
                          _buildCircleButton(
                            icon: Icons.leaderboard_rounded,
                            onTap: _openLeaderboardScreen, // Llama a la nueva pantalla
                            color: Colors.white,
                            accentColor: _btnStats,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGETS ESTILO "FLAT & ROUNDED" ---
  Widget _buildFlatTitle() {
    return Column(
      children: [
        Icon(Icons.directions_car, size: 50, color: _btnStats),
        const SizedBox(height: 10),
        const Text(
          "POWER RUSH",
          style: TextStyle(
            fontFamily: "Arial Rounded MT Bold",
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }

  // Botón estilo "Pastilla" interactivo (Play)
  Widget _buildPillButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 70,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(35), // Bordes totalmente redondos
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        // Esquinas decorativas amarillas
        child: Stack(
          children: [
            Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 2,
                ),
              ),
            ),
            // Pequeños acentos en las esquinas (tipo brackets)
            Positioned(top: 15, left: 20, child: _cornerAccent()),
            Positioned(
              bottom: 15,
              right: 20,
              child: Transform.rotate(angle: 3.14, child: _cornerAccent()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cornerAccent() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFFFFD56B), // Amarillo
        shape: BoxShape.circle,
      ),
    );
  }

  // Display estilo "Pastilla" informativo (Stats)
  Widget _buildPillDisplay({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    bool isSmall = false,
  }) {
    return Container(
      width: isSmall ? 250 : double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // Botones circulares inferiores
  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required Color accentColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: accentColor, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: _bgDark, size: 28),
      ),
    );
  }
}

// Painter original
class SpeedStreaksPainter extends CustomPainter {
  final double animation;
  SpeedStreaksPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 4; i++) {
      final xPos = size.width * (0.2 + i * 0.2);
      final delay = i * 0.2;
      final streakAnim = ((animation + delay) % 1.0);
      final yPos = -100 + (size.height + 200) * streakAnim;

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0),
            Colors.white.withOpacity(0.2), // Más sutil
            Colors.white.withOpacity(0),
          ],
        ).createShader(Rect.fromLTWH(xPos, yPos, 20, 200)); // Rayas más anchas

      final path = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(xPos, yPos, 20, 200),
            const Radius.circular(10),
          ),
        );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(SpeedStreaksPainter oldDelegate) =>
      animation != oldDelegate.animation;
}