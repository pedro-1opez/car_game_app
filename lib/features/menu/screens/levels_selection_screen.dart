// ===========================================================================
// Pantalla de selección de niveles
// Muestra los niveles disponibles numerados y permite seleccionar cada uno
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui'; // Para ImageFilter
import '../../../core/models/game_level.dart';
import 'level_game_screen.dart';

// Paleta local para consistencia con el tema
class LevelColors {
  static const Color bgDark = Color(0xFF0F3057);
  static const Color cardGlass = Color(0xFF162447);
  static const Color accentGreen = Color(0xFF00E9A3);
  static const Color accentPurple = Color(0xFF9E86FF);
  static const Color accentBlue = Color(0xFF448AFF);
  static const Color textWhite = Colors.white;
}

class LevelsSelectionScreen extends StatefulWidget {
  const LevelsSelectionScreen({super.key});

  @override
  State<LevelsSelectionScreen> createState() => _LevelsSelectionScreenState();
}

class _LevelsSelectionScreenState extends State<LevelsSelectionScreen>
    with TickerProviderStateMixin {

  late AnimationController _animationController;
  late List<AnimationController> _levelAnimationControllers;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<GameLevel> levels = GameLevel.getDefaultLevels();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _animationController.forward();
    _startLevelAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _levelAnimationControllers = List.generate(
      levels.length,
          (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 150)),
        vsync: this,
      ),
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

  void _startLevelAnimations() {
    for (int i = 0; i < _levelAnimationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 200 + (i * 100)), () {
        if (mounted) {
          _levelAnimationControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _levelAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _selectLevel(GameLevel level) {
    HapticFeedback.lightImpact();
    _showGlassLevelDialog(level);
  }

  void _showGlassLevelDialog(GameLevel level) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 350),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: LevelColors.bgDark.withOpacity(0.85),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono Nivel Grande
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: LevelColors.accentPurple.withOpacity(0.2),
                        border: Border.all(color: LevelColors.accentPurple, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: LevelColors.accentPurple.withOpacity(0.4),
                            blurRadius: 20,
                          )
                        ]
                    ),
                    child: Center(
                      child: Text(
                        '${level.levelNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Arial Rounded MT Bold",
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    level.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Arial Rounded MT Bold",
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    level.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                  ),

                  const SizedBox(height: 24),

                  // Objetivos
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        _buildObjectiveRow(Icons.flag_rounded, "Alcanzar ${level.formattedDistance}", LevelColors.accentGreen),
                        const SizedBox(height: 10),
                        _buildObjectiveRow(Icons.monetization_on_rounded, "Recolectar ${level.minimumCoins}", const Color(0xFFFFD56B)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botones de Acción
                  Row(
                    children: [
                      // --- BOTÓN CANCELAR ---
                      Expanded(
                        flex: 1,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "CANCELAR",
                            style: TextStyle(color: Colors.white54),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // --- BOTÓN JUGAR  ---
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _startLevel(level);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LevelColors.accentGreen,
                            foregroundColor: LevelColors.bgDark,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text("JUGAR NIVEL", style: TextStyle(fontWeight: FontWeight.bold)),
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
    );
  }

  Widget _buildObjectiveRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Future<void> _startLevel(GameLevel level) async {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LevelGameScreen(level: level),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Detectar orientación para layout
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: LevelColors.bgDark,
      body: Stack(
        children: [
          // FONDO
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

          // CONTENIDO
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  // --- HEADER ---
                  Row(
                    children: [
                      _buildBackButton(),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          "SELECCIONA NIVEL",
                          style: TextStyle(
                            fontFamily: "Arial Rounded MT Bold",
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // --- GRID DE NIVELES ---
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildLevelsGrid(isLandscape),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // --- COMING SOON ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_clock, color: Colors.white.withOpacity(0.5), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "Próximamente más niveles...",
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
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

  Widget _buildLevelsGrid(bool isLandscape) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isLandscape ? 3 : 2, // 3 columnas si está acostado
        childAspectRatio: 1.1, // Tarjetas casi cuadradas
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _levelAnimationControllers[index],
          builder: (context, child) {
            // Animación de escala elástica al aparecer
            final val = _levelAnimationControllers[index].value;
            return Transform.scale(
              scale: 0.5 + (0.5 * val),
              child: Opacity(
                opacity: val,
                child: _LevelCard(
                  level: levels[index],
                  onPressed: () => _selectLevel(levels[index]),
                  index: index,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _LevelCard extends StatefulWidget {
  final GameLevel level;
  final VoidCallback onPressed;
  final int index;

  const _LevelCard({
    required this.level,
    required this.onPressed,
    required this.index,
  });

  @override
  State<_LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<_LevelCard> with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(duration: const Duration(milliseconds: 100), vsync: this);
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(_pressController);
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Alternar colores para variedad visual
    final List<Color> colors = [
      LevelColors.accentGreen,
      LevelColors.accentPurple,
      LevelColors.accentBlue,
    ];
    final color = colors[widget.index % colors.length];

    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: BoxDecoration(
                color: LevelColors.cardGlass.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Número de fondo sutil
                  Positioned(
                    right: -10,
                    bottom: -15,
                    child: Text(
                      "${widget.level.levelNumber}",
                      style: TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.05),
                        fontFamily: "Arial Rounded MT Bold",
                      ),
                    ),
                  ),

                  // Contenido
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Círculo del número
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: color.withOpacity(0.6)),
                          ),
                          child: Center(
                            child: Text(
                              "${widget.level.levelNumber}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        Text(
                          widget.level.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children: [
                            Icon(Icons.flag, color: Colors.white.withOpacity(0.5), size: 12),
                            const SizedBox(width: 4),
                            Text(
                              widget.level.formattedDistance,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}