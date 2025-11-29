// ===========================================================================
// Pantalla de juego para modo niveles
// Integra el juego real con la lógica de nivel y barra de progreso
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/game_level.dart';
import '../../../core/models/level_state.dart';
import '../../game/controllers/game_controller.dart';
import '../../levels/controllers/level_game_controller.dart';
import '../../game/screens/game_screen.dart';
import '../../game/widgets/ui/level_progress_bar.dart';
import 'levels_selection_screen.dart';

class LevelGameScreen extends StatefulWidget {
  final GameLevel level;

  const LevelGameScreen({
    super.key,
    required this.level,
  });

  @override
  State<LevelGameScreen> createState() => _LevelGameScreenState();
}

class _LevelGameScreenState extends State<LevelGameScreen> {
  late GameController _gameController;
  late LevelGameController _levelController;
  bool _isInitialized = false;
  bool _dialogShown = false; // Bandera para evitar diálogos duplicados
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    // Si ya existen controladores, limpiarlos primero
    if (_isInitialized) {
      _levelController.removeListener(_onLevelStateChanged);
      _levelController.dispose();
    }
    
    // Usar el GameController global del Provider en lugar de crear uno nuevo
    _gameController = context.read<GameController>();
    
    // Crear el LevelGameController
    _levelController = LevelGameController(
      level: widget.level,
      gameController: _gameController,
    );

    // Configurar listeners
    _levelController.addListener(_onLevelStateChanged);
    
    setState(() {
      _isInitialized = true;
    });
    
    // Iniciar el juego automáticamente
    _levelController.startLevel();
  }

  void _onLevelStateChanged() {
    if (!mounted || _dialogShown) return;
    
    // Verificar si el nivel está completado o fallido
    if (_levelController.isLevelCompleted) {
      _dialogShown = true;
      // Pausar el juego inmediatamente para detener el contador y la ejecución
      _levelController.pauseLevel();
      _showLevelCompletedDialog();
    } else if (_levelController.isLevelFailed) {
      _dialogShown = true;
      // Pausar el juego inmediatamente para detener el contador y la ejecución
      _levelController.pauseLevel();
      _showLevelFailedDialog();
    }
  }

  void _showLevelCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: GameColors.background,
        title: Text(
          '¡Nivel Completado!',
          style: TextStyle(
            color: GameColors.success,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: GameColors.success,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              '¡Felicidades! Has completado el ${widget.level.title}',
              style: TextStyle(
                color: GameColors.textPrimary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GameColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Distancia:',
                        style: TextStyle(
                          color: GameColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${_levelController.levelState.distanceTraveled.toInt()}m',
                        style: TextStyle(
                          color: GameColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Monedas:',
                        style: TextStyle(
                          color: GameColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${_levelController.levelState.coinsCollected}',
                        style: TextStyle(
                          color: GameColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar diálogo
              
              // Navegar directamente a la pantalla de selección de niveles
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LevelsSelectionScreen(),
                ),
              );
            },
            child: Text(
              'Continuar',
              style: TextStyle(color: GameColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showLevelFailedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: GameColors.background,
        title: Text(
          'Nivel Fallido',
          style: TextStyle(
            color: GameColors.error,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cancel,
              color: GameColors.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _levelController.levelState.status == LevelStatus.reachedGoal
                ? 'No recolectaste suficientes monedas'
                : 'No llegaste al destino',
              style: TextStyle(
                color: GameColors.textPrimary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GameColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Monedas recolectadas:',
                        style: TextStyle(
                          color: GameColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${_levelController.levelState.coinsCollected}/${widget.level.minimumCoins}',
                        style: TextStyle(
                          color: GameColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar diálogo
              _restartLevel();
            },
            child: Text(
              'Reintentar',
              style: TextStyle(color: GameColors.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar diálogo
              
              // Navegar directamente a la pantalla de selección de niveles
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LevelsSelectionScreen(),
                ),
              );
            },
            child: Text(
              'Salir',
              style: TextStyle(color: GameColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _restartLevel() async {
    // Resetear bandera de diálogo
    _dialogShown = false;
    // Reiniciar controladores
    await _initializeControllers();
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _levelController.removeListener(_onLevelStateChanged);
      _levelController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: GameColors.background,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _gameController,
      child: Scaffold(
        backgroundColor: GameColors.background,
        body: Stack(
          children: [
            // Juego principal - usar GameScreen original pero sin mostrar diálogo de game over
            GameScreen(
              gameController: _gameController,
              showGameOverDialog: false, // Desactivar diálogo automático
            ),
            
            // Overlay con barra de progreso
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: ChangeNotifierProvider.value(
                value: _levelController,
                child: Consumer<LevelGameController>(
                  builder: (context, levelController, _) {
                    return LevelProgressBar(
                      levelState: levelController.levelState,
                    );
                  },
                ),
              ),
            ),                                                

          ],
        ),
      ),
    );
  }
}