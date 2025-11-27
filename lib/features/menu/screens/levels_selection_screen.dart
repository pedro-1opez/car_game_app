// ===========================================================================
// Pantalla de selección de niveles
// Muestra los niveles disponibles numerados y permite seleccionar cada uno
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/colors.dart';

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
  
  final List<int> levels = [1, 2, 3]; // Niveles disponibles
  
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
  
  void _selectLevel(int levelNumber) {
    HapticFeedback.lightImpact();
    
    // Obtener información de pantalla para hacer el mensaje responsivo
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 600 || screenSize.width < 400;
    final isVerySmallScreen = screenSize.width < 320;
    
    // Por ahora solo mostramos un mensaje, funcionalidad pendiente
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _buildResponsiveSnackBarContent(levelNumber, isSmallScreen, isVerySmallScreen),
        backgroundColor: GameColors.primary,
        duration: Duration(seconds: isSmallScreen ? 3 : 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 8 : 12,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 10 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
        ),
      ),
    );
  }
  
  Widget _buildResponsiveSnackBarContent(int levelNumber, bool isSmallScreen, bool isVerySmallScreen) {
    if (isVerySmallScreen) {
      // Para pantallas muy pequeñas, mostrar en columna
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.videogame_asset, 
                color: GameColors.textPrimary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Nivel $levelNumber',
                style: TextStyle(
                  color: GameColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Funcionalidad pendiente',
            style: TextStyle(
              color: GameColors.textPrimary.withValues(alpha: 0.9),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else if (isSmallScreen) {
      // Para pantallas pequeñas, texto más corto
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videogame_asset, 
            color: GameColors.textPrimary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Nivel $levelNumber - Próximamente',
              style: TextStyle(
                color: GameColors.textPrimary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    } else {
      // Para pantallas normales y grandes
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videogame_asset, 
            color: GameColors.textPrimary,
            size: 22,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              'Nivel $levelNumber seleccionado - Funcionalidad pendiente',
              style: TextStyle(
                color: GameColors.textPrimary,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }
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
          int levelNumber = entry.value;
          
          return Expanded(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(
                bottom: index < levels.length - 1 ? spacing : 0,
              ),
              child: _buildLevelCard(
                levelNumber, 
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
  
  Widget _buildLevelCard(int levelNumber, int index, bool isSmallScreen, bool isTablet) {
    return AnimatedBuilder(
      animation: _levelAnimationControllers[index],
      builder: (context, child) {
        return Transform.scale(
          scale: 0.3 + (0.7 * _levelAnimationControllers[index].value),
          child: Opacity(
            opacity: _levelAnimationControllers[index].value,
            child: _LevelButton(
              levelNumber: levelNumber,
              onPressed: () => _selectLevel(levelNumber),
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
  final int levelNumber;
  final VoidCallback onPressed;
  final bool isSmallScreen;
  final bool isTablet;

  const _LevelButton({
    required this.levelNumber,
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
                            '${widget.levelNumber}',
                            style: TextStyle(
                              color: GameColors.textPrimary,
                              fontSize: widget.isTablet ? 36 : (widget.isSmallScreen ? 24 : 28),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: widget.isTablet ? 16 : (widget.isSmallScreen ? 8 : 12)),
                      
                      // Texto del nivel
                      Text(
                        'Nivel ${widget.levelNumber}',
                        style: TextStyle(
                          color: GameColors.textPrimary,
                          fontSize: widget.isTablet ? 20 : (widget.isSmallScreen ? 16 : 18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      SizedBox(height: widget.isSmallScreen ? 4 : 6),
                      
                      // Descripción
                      Text(
                        'Toca para jugar',
                        style: TextStyle(
                          color: GameColors.textPrimary.withValues(alpha: 0.8),
                          fontSize: widget.isTablet ? 14 : (widget.isSmallScreen ? 12 : 13),
                        ),
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