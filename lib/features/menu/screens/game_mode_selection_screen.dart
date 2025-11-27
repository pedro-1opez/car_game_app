// ===========================================================================
// Pantalla de selección de modo de juego
// Permite al usuario elegir entre diferentes modos: Niveles o Modo Infinito
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/game_orientation.dart';
import '../../game/game_exports.dart';
import '../../game/screens/game_screen.dart' as game;
import '../../../services/preferences_service.dart';
import 'levels_selection_screen.dart';

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
      begin: const Offset(0, 0.3),
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
    HapticFeedback.lightImpact();
    
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
  
  void _goBack() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Definir breakpoints responsivos
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          final isSmallScreen = screenHeight < 600 || screenWidth < 400;
          final isMediumScreen = screenHeight < 800 || screenWidth < 600;
          
          // Ajustar espaciados según el tamaño de pantalla
          final horizontalPadding = isSmallScreen ? 16.0 : (isMediumScreen ? 20.0 : 32.0);
          final topPadding = isSmallScreen ? 20.0 : (isMediumScreen ? 30.0 : 40.0);
          final titleFontSize = isSmallScreen ? 20.0 : (isMediumScreen ? 24.0 : 28.0);
          final spaceBetweenElements = isSmallScreen ? 20.0 : (isMediumScreen ? 40.0 : 60.0);
          
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 16.0,
                      ),
                      child: Column(
                        children: [
                          // Título
                          SizedBox(height: topPadding),
                          Flexible(
                            child: Text(
                              'Selecciona el modo de juego',
                              style: TextStyle(
                                color: GameColors.textPrimary,
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          SizedBox(height: spaceBetweenElements),
                          
                          // Botones de modo de juego
                          Expanded(
                            flex: isSmallScreen ? 3 : 2,
                            child: _buildGameModeButtons(
                              isSmallScreen: isSmallScreen,
                              isMediumScreen: isMediumScreen,
                            ),
                          ),
                          
                          SizedBox(height: isSmallScreen ? 20.0 : 30.0),
                          
                          // Botón Regresar
                          SizedBox(
                            width: double.infinity,
                            height: isSmallScreen ? 50.0 : 60.0,
                            child: ElevatedButton(
                              onPressed: _goBack,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: GameColors.secondary,
                                foregroundColor: GameColors.textPrimary,
                                elevation: 8,
                                shadowColor: GameColors.secondary.withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_back, 
                                    size: isSmallScreen ? 20.0 : 24.0,
                                  ),
                                  SizedBox(width: isSmallScreen ? 8.0 : 12.0),
                                  Flexible(
                                    child: Text(
                                      'Regresar',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 16.0 : 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          SizedBox(height: isSmallScreen ? 16.0 : 20.0),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  Widget _buildGameModeButtons({
    required bool isSmallScreen,
    required bool isMediumScreen,
  }) {
    final buttonSpacing = isSmallScreen ? 16.0 : 20.0;
    
    return Column(
      children: [
        // Botón Niveles
        Expanded(
          child: _GameModeButton(
            title: 'Niveles',
            subtitle: 'Desafíos progresivos',
            onPressed: _goToLevelsSelection,            
            isSmallScreen: isSmallScreen,
            isMediumScreen: isMediumScreen,
            iconData: Icons.stars,
          ),
        ),
        
        SizedBox(height: buttonSpacing),
        
        // Botón Modo Infinito
        Expanded(
          child: _GameModeButton(
            title: 'Modo Infinito',
            subtitle: 'Juego sin límites',
            onPressed: _startInfiniteMode,            
            isSmallScreen: isSmallScreen,
            isMediumScreen: isMediumScreen,
            iconData: Icons.all_inclusive,
          ),
        ),
      ],
    );
  }
}

class _GameModeButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback onPressed;  
  final bool isSmallScreen;
  final bool isMediumScreen;
  final IconData? iconData;

  const _GameModeButton({
    required this.title,
    required this.subtitle,
    required this.onPressed,    
    required this.isSmallScreen,
    required this.isMediumScreen,
    this.iconData,
  });

  @override
  State<_GameModeButton> createState() => _GameModeButtonState();
}

class _GameModeButtonState extends State<_GameModeButton>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _buttonController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              _buttonController.forward();
            },
            onTapUp: (_) {
              _buttonController.reverse();
              widget.onPressed();
            },
            onTapCancel: () {
              _buttonController.reverse();
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                          GameColors.primary,
                          GameColors.primary.withValues(alpha: 0.8)
                          ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: GameColors.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Fondo con patrón decorativo
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Contenido del botón
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(
                          widget.isSmallScreen ? 16.0 : (widget.isMediumScreen ? 20.0 : 24.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icono del modo
                          Container(
                            width: widget.isSmallScreen ? 60.0 : (widget.isMediumScreen ? 70.0 : 80.0),
                            height: widget.isSmallScreen ? 60.0 : (widget.isMediumScreen ? 70.0 : 80.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                widget.iconData ?? 
                                Icons.all_inclusive,                                
                                size: widget.isSmallScreen ? 28.0 : (widget.isMediumScreen ? 34.0 : 40.0),
                                color: GameColors.textPrimary,
                              ),
                            ),
                          ),
                          
                          SizedBox(height: widget.isSmallScreen ? 12.0 : (widget.isMediumScreen ? 16.0 : 20.0)),
                          
                          // Título
                          Flexible(
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                color: GameColors.textPrimary,
                                fontSize: widget.isSmallScreen ? 18.0 : (widget.isMediumScreen ? 21.0 : 24.0),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          SizedBox(height: widget.isSmallScreen ? 4.0 : 8.0),
                          
                          // Subtítulo
                          Flexible(
                            child: Text(
                              widget.subtitle,
                              style: TextStyle(
                                color: GameColors.textPrimary.withValues(alpha: 0.8),
                                fontSize: widget.isSmallScreen ? 12.0 : (widget.isMediumScreen ? 14.0 : 16.0),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),                                                 
                        ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}