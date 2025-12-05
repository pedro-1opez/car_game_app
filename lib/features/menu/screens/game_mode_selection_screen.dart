// ===========================================================================
// Pantalla de selección de modo de juego
// Permite al usuario elegir entre diferentes modos: Niveles o Modo Infinito
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui'; // Para ImageFilter
import 'package:provider/provider.dart';
import '../../../core/models/game_orientation.dart';
import '../../game/game_exports.dart';
import '../../game/screens/game_screen.dart' as game;
import '../../../services/preferences_service.dart';
import 'levels_selection_screen.dart';

// Paleta de colores local
class ModeColors {
  static const Color bgDark = Color(0xFF0F3057);
  static const Color cardGlass = Color(0xFF162447);
  static const Color accentGreen = Color(0xFF00E9A3);
  static const Color accentPurple = Color(0xFF9E86FF);
}

class GameModeSelectionScreen extends StatefulWidget {
  const GameModeSelectionScreen({super.key});

  @override
  State<GameModeSelectionScreen> createState() => _GameModeSelectionScreenState();
}

class _GameModeSelectionScreenState extends State<GameModeSelectionScreen>
    with TickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _animationController.forward();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startInfiniteMode() async {
    HapticFeedback.mediumImpact();

    final gameController = Provider.of<GameController>(context, listen: false);

    // Cargar la orientación guardada en preferencias
    GameOrientation finalOrientation = await PreferencesService.instance.getPreferredOrientation();

    gameController.changeOrientation(finalOrientation);

    SystemChrome.setPreferredOrientations([
      finalOrientation == GameOrientation.vertical
          ? DeviceOrientation.portraitUp
          : DeviceOrientation.landscapeLeft,
    ]);

    await gameController.startNewGame(orientation: finalOrientation);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => game.GameScreen(),
        ),
      );
    }
  }

  void _goToLevelsSelection() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LevelsSelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModeColors.bgDark,
      body: Stack(
        children: [
          // FONDO COMÚN
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/cars/background.jpeg'),
                  fit: BoxFit.cover,
                  opacity: 0.3,
                ),
              ),
            ),
          ),

          // CONTENIDO PRINCIPAL
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  // HEADER
                  Row(
                    children: [
                      _buildBackButton(),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          "MODO DE JUEGO",
                          style: TextStyle(
                            fontFamily: "Arial Rounded MT Bold",
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 1),

                  // --- TARJETAS DE SELECCIÓN ---
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              // Tarjeta de Niveles
                              _GameModeCard(
                                title: "NIVELES",
                                subtitle: "Supera desafíos progresivos",
                                icon: Icons.map_rounded,
                                color: ModeColors.accentPurple,
                                onPressed: _goToLevelsSelection,
                              ),

                              const SizedBox(height: 20),

                              // Tarjeta de Modo Infinito
                              _GameModeCard(
                                title: "INFINITO",
                                subtitle: "Resiste tanto como puedas",
                                icon: Icons.all_inclusive_rounded,
                                color: ModeColors.accentGreen,
                                onPressed: _startInfiniteMode,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}

class _GameModeCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _GameModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_GameModeCard> createState() => _GameModeCardState();
}

class _GameModeCardState extends State<_GameModeCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _scaleController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _scaleController.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _scaleController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  // Fondo base igual para ambos
                  color: ModeColors.cardGlass.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // --- ICONO GRANDE ---
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: widget.color.withOpacity(0.3)),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 40,
                        color: widget.color,
                      ),
                    ),

                    const SizedBox(width: 20),

                    // --- TEXTOS ---
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontFamily: "Arial Rounded MT Bold",
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1,
                              shadows: [
                                Shadow(
                                  color: widget.color.withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- FLECHA INDICADORA ---
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withOpacity(0.3),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}