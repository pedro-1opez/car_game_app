// ===========================================================================
// Pantalla de selección de niveles
// Muestra los niveles disponibles numerados y permite seleccionar cada uno
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/game_level.dart';
import '../widgets/close_button.dart';
import 'level_game_screen.dart';

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
  
  final List<GameLevel> levels = GameLevel.getDefaultLevels(); // Niveles disponibles
  
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
    
    // Animaciones para cada nivel
    _levelAnimationControllers = List.generate(
      levels.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 200)),
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
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
  }
  
  void _startLevelAnimations() {
    for (int i = 0; i < _levelAnimationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 400 + (i * 150)), () {
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
    
    // Mostrar información detallada del nivel seleccionado
    _showLevelDetailsDialog(level);
  }
  
  void _showLevelDetailsDialog(GameLevel level) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 600 || screenSize.width < 400;
    
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        backgroundColor: GameColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono y número del nivel
              Container(
                width: isSmallScreen ? 60 : 80,
                height: isSmallScreen ? 60 : 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      GameColors.primary,
                      GameColors.primary.withValues(alpha: 0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${level.levelNumber}',
                    style: TextStyle(
                      color: GameColors.textPrimary,
                      fontSize: isSmallScreen ? 24 : 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: isSmallScreen ? 16 : 20),
              
              // Título
              Text(
                level.title,
                style: TextStyle(
                  color: GameColors.textPrimary,
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: isSmallScreen ? 8 : 12),
              
              // Descripción
              Text(
                level.description,
                style: TextStyle(
                  color: GameColors.textSecondary,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: isSmallScreen ? 16 : 20),
              
              // Objetivos
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                  color: GameColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: GameColors.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Objetivos:',
                      style: TextStyle(
                        color: GameColors.textPrimary,
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 8 : 10),
                    
                    // Meta de distancia
                    Row(
                      children: [
                        Icon(
                          Icons.flag,
                          color: GameColors.primary,
                          size: isSmallScreen ? 16 : 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Alcanzar ${level.formattedDistance}',
                          style: TextStyle(
                            color: GameColors.textSecondary,
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 6),
                    
                    // Meta de monedas
                    Row(
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: Colors.amber,
                          size: isSmallScreen ? 16 : 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Recolectar ${level.minimumCoins} monedas',
                          style: TextStyle(
                            color: GameColors.textSecondary,
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: isSmallScreen ? 20 : 24),
              
              // Botones
              Row(
                children: [
                  Expanded(
                    child: CustomCloseButton(
                      isSmallScreen: isSmallScreen,
                    ),
                  ),
                  
                  SizedBox(width: 12),
                  
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _startLevel(level);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GameColors.primary,
                        foregroundColor: GameColors.textPrimary,
                        elevation: 8,
                        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Jugar Nivel',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _startLevel(GameLevel level) async {
    HapticFeedback.lightImpact();
    
    // Navegar al juego con el nivel seleccionado
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LevelGameScreen(level: level),
      ),
    );
  }

  
  void _goBack() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 600 || screenSize.width < 400;
    final isTablet = screenSize.width > 600;
    
    return Scaffold(
      backgroundColor: GameColors.background,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
                  child: Column(
                    children: [
                      // Título
                      SizedBox(height: isSmallScreen ? 20 : 40),
                      Text(
                        'Selecciona un Nivel',
                        style: TextStyle(
                          color: GameColors.textPrimary,
                          fontSize: isSmallScreen ? 24 : (isTablet ? 32 : 28),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: isSmallScreen ? 40 : 60),
                      
                      // Niveles
                      Expanded(
                        child: _buildLevelsGrid(isSmallScreen, isTablet),
                      ),
                      
                      // Leyenda "Coming Soon"
                      Container(
                        margin: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 16 : 20,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 16 : 20,
                          vertical: isSmallScreen ? 12 : 16,
                        ),
                        decoration: BoxDecoration(
                          color: GameColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: GameColors.secondary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.access_time,
                              color: GameColors.secondary,
                              size: isSmallScreen ? 16 : 20,
                            ),
                            SizedBox(width: isSmallScreen ? 6 : 8),
                            Text(
                              'Coming Soon - Más niveles serán agregados',
                              style: TextStyle(
                                color: GameColors.secondary,
                                fontSize: isSmallScreen ? 12 : 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Botón Regresar
                      SizedBox(
                        width: double.infinity,
                        height: isSmallScreen ? 50 : 60,
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
                            children: [
                              Icon(
                                Icons.arrow_back, 
                                size: isSmallScreen ? 20 : 24,
                              ),
                              SizedBox(width: isSmallScreen ? 8 : 12),
                              Text(
                                'Regresar',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: isSmallScreen ? 16 : 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildLevelsGrid(bool isSmallScreen, bool isTablet) {
    // Configuración responsiva para el grid
    int crossAxisCount = isTablet ? 3 : (isSmallScreen ? 1 : 1);
    double childAspectRatio = isTablet ? 1.2 : (isSmallScreen ? 2.5 : 2.0);
    double spacing = isSmallScreen ? 16 : 20;
    
    if (isTablet) {
      // En tablet, mostrar en grid 3 columnas
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        ),
        itemCount: levels.length,
        itemBuilder: (context, index) {
          return _buildLevelCard(
            levels[index], 
            index, 
            isSmallScreen, 
            isTablet,
          );
        },
      );
    } else {
      // En móvil, mostrar en columna vertical
      return Column(
        children: levels.asMap().entries.map((entry) {
          int index = entry.key;
          GameLevel level = entry.value;
          
          return Expanded(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(
                bottom: index < levels.length - 1 ? spacing : 0,
              ),
              child: _buildLevelCard(
                level, 
                index, 
                isSmallScreen, 
                isTablet,
              ),
            ),
          );
        }).toList(),
      );
    }
  }
  
  Widget _buildLevelCard(GameLevel level, int index, bool isSmallScreen, bool isTablet) {
    return AnimatedBuilder(
      animation: _levelAnimationControllers[index],
      builder: (context, child) {
        return Transform.scale(
          scale: 0.3 + (0.7 * _levelAnimationControllers[index].value),
          child: Opacity(
            opacity: _levelAnimationControllers[index].value,
            child: _LevelButton(
              level: level,
              onPressed: () => _selectLevel(level),
              isSmallScreen: isSmallScreen,
              isTablet: isTablet,
            ),
          ),
        );
      },
    );
  }
}

class _LevelButton extends StatefulWidget {
  final GameLevel level;
  final VoidCallback onPressed;
  final bool isSmallScreen;
  final bool isTablet;

  const _LevelButton({
    required this.level,
    required this.onPressed,
    required this.isSmallScreen,
    required this.isTablet,
  });

  @override
  State<_LevelButton> createState() => _LevelButtonState();
}

class _LevelButtonState extends State<_LevelButton>
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
            onTapDown: (_) => _buttonController.forward(),
            onTapUp: (_) {
              _buttonController.reverse();
              widget.onPressed();
            },
            onTapCancel: () => _buttonController.reverse(),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.isTablet ? 24 : 20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    GameColors.primary,
                    GameColors.primary.withValues(alpha: 0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: GameColors.primary.withValues(alpha: 0.4),
                    blurRadius: widget.isTablet ? 25 : 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.isTablet ? 24 : 20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Número del nivel en un círculo
                      Container(
                        width: widget.isTablet ? 80 : (widget.isSmallScreen ? 60 : 70),
                        height: widget.isTablet ? 80 : (widget.isSmallScreen ? 60 : 70),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${widget.level.levelNumber}',
                            style: TextStyle(
                              color: GameColors.textPrimary,
                              fontSize: widget.isTablet ? 36 : (widget.isSmallScreen ? 24 : 28),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: widget.isTablet ? 12 : (widget.isSmallScreen ? 6 : 8)),
                      
                      // Título del nivel
                      Text(
                        widget.level.title,
                        style: TextStyle(
                          color: GameColors.textPrimary,
                          fontSize: widget.isTablet ? 18 : (widget.isSmallScreen ? 14 : 16),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}