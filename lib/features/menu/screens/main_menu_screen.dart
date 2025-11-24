import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/game_orientation.dart';
import '../../game/game_exports.dart';
import '../../game/screens/game_screen.dart' as game;
import '../widgets/animated_game_title.dart';
import '../widgets/menu_buttons.dart';
import '../widgets/player_stats_widget.dart';
import '../widgets/game_info_widget.dart';
import '../dialogs/configuration_dialog.dart';
import '../dialogs/credits_dialog.dart';

/// Pantalla de menú principal modularizada
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _titleController;
  late AnimationController _buttonController;
  late AnimationController _backgroundController;
  
  late Animation<double> _titleAnimation;
  late Animation<double> _buttonAnimation;
  late Animation<double> _backgroundAnimation;
  
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
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    _titleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.elasticOut,
    ));
    
    _buttonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.bounceOut,
    ));
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));
  }
  
  void _startAnimations() {
    _backgroundController.repeat();
    _titleController.forward();
    
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _buttonController.forward();
    });
  }
  
  void _startGame(GameController gameController, [GameOrientation? orientation]) {
    HapticFeedback.lightImpact();
    
    if (orientation != null) {
      gameController.changeOrientation(orientation);
      
      SystemChrome.setPreferredOrientations([
        orientation == GameOrientation.vertical
            ? DeviceOrientation.portraitUp
            : DeviceOrientation.landscapeLeft,
      ]);
    }
    
    gameController.startNewGame(orientation: orientation);
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => game.GameScreen(),
      ),
    );
  }
  
  void _showConfigurationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => ConfigurationDialog(
        onStartGame: _startGame,
      ),
    );
  }
  
  void _showCreditsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => const CreditsDialog(),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, gameController, child) {
        return Scaffold(
          body: AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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
                  child: Column(
                    children: [
                      // Título principal animado
                      Flexible(
                        flex: 2,
                        child: Center(
                          child: _buildGameTitle(context),
                        ),
                      ),
                      
                      // Menú de opciones
                      Expanded(
                        flex: 3,
                        child: AnimatedBuilder(
                          animation: _buttonAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, 50 * (1 - _buttonAnimation.value)),
                              child: Opacity(
                                opacity: _buttonAnimation.value,
                                child: _buildMenuOptions(gameController, context),
                              ),
                            );
                          },
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
  
  Widget _buildGameTitle(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 600 || screenWidth < 400;
    
    return AnimatedGameTitle(
      animation: _titleAnimation,
      isSmallScreen: isSmallScreen,
    );
  }
  
  Widget _buildMenuOptions(GameController gameController, BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenHeight < 600 || screenWidth < 400;
        final isNarrowScreen = screenWidth < 360;
        
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isNarrowScreen ? 16 : (isSmallScreen ? 24 : 32),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón principal - Jugar
              MainMenuButton(
                icon: Icons.play_arrow,
                text: 'JUGAR',
                subtitle: 'Modo Adaptativo',
                onPressed: () => _startGame(gameController),
                isSmallScreen: isSmallScreen,
              ),
              
              SizedBox(height: isSmallScreen ? 12 : 20),
              
              // Opciones adicionales
              Row(
                children: [
                  Expanded(
                    child: SecondaryMenuButton(
                      icon: Icons.settings,
                      text: 'CONFIGURACIÓN',
                      onPressed: _showConfigurationDialog,
                      isSmallScreen: isSmallScreen,
                    ),
                  ),
                  
                  SizedBox(width: isSmallScreen ? 8 : 16),
                  
                  Expanded(
                    child: SecondaryMenuButton(
                      icon: Icons.info,
                      text: 'CRÉDITOS',
                      onPressed: _showCreditsDialog,
                      isSmallScreen: isSmallScreen,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: isSmallScreen ? 16 : 30),
              
              // Estadísticas del jugador
              if (gameController.gameState.highScore > 0)
                PlayerStatsWidget(
                  highScore: gameController.gameState.highScore,
                  gamesPlayed: gameController.gameState.gamesPlayed,
                  isSmallScreen: isSmallScreen,
                ),
              
              SizedBox(height: isSmallScreen ? 12 : 20),
              
              // Información del juego
              GameInfoWidget(isSmallScreen: isSmallScreen),
            ],
          ),
        );
      },
    );
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _buttonController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }
}
