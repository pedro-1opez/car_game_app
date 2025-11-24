import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


// Importar sistema de juego completo
import 'features/game/game_exports.dart';
import 'features/game/screens/game_screen.dart' as game;
import 'core/constants/colors.dart';
import 'core/models/game_orientation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Carga las variables de entorno desde .env
  await dotenv.load(fileName: ".env");
  
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameController(),
      child: MaterialApp(
        title: 'Car Slider Game',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: GameColors.background,
          appBarTheme: AppBarTheme(
            backgroundColor: GameColors.primary,
            foregroundColor: GameColors.textPrimary,
            elevation: 0,
          ),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: GameColors.textPrimary),
            bodyMedium: TextStyle(color: GameColors.textSecondary),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: GameColors.textPrimary,
              backgroundColor: GameColors.primary,
            ),
          ),
        ),
        home: MainMenuScreen(),
      ),
    );
  }
}

/// Pantalla de menú principal con animaciones
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
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
      
      // Configurar orientación del dispositivo
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
                      // Título principal animado - Responsivo
                      Flexible(
                        flex: 2,
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _titleAnimation,
                            builder: (context, child) {
                              final screenHeight = MediaQuery.of(context).size.height;
                              final screenWidth = MediaQuery.of(context).size.width;
                              final isSmallScreen = screenHeight < 600 || screenWidth < 400;
                              
                              return Transform.scale(
                                scale: _titleAnimation.value,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Icono principal - Responsivo
                                    Container(
                                      padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            GameColors.primary,
                                            GameColors.secondary,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: GameColors.primary.withValues(alpha: 0.3),
                                            blurRadius: isSmallScreen ? 15 : 20,
                                            offset: Offset(0, isSmallScreen ? 5 : 10),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.sports_motorsports,
                                        size: isSmallScreen ? 40 : 60,
                                        color: GameColors.textPrimary,
                                      ),
                                    ),
                                    
                                    SizedBox(height: isSmallScreen ? 12 : 24),
                                    
                                    // Título del juego - Responsivo
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'CAR SLIDER',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 28 : 42,
                                          fontWeight: FontWeight.bold,
                                          color: GameColors.textPrimary,
                                          letterSpacing: isSmallScreen ? 2 : 4,
                                          shadows: [
                                            Shadow(
                                              color: GameColors.primary.withValues(alpha: 0.5),
                                              blurRadius: 10,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'GAME',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 20,
                                          color: GameColors.textSecondary,
                                          letterSpacing: isSmallScreen ? 3 : 6,
                                        ),
                                      ),
                                    ),
                                    
                                    SizedBox(height: isSmallScreen ? 8 : 16),
                                    
                                    // Subtítulo - Responsivo
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'Esquiva, Colecciona, Sobrevive',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 12 : 14,
                                          color: GameColors.textSecondary,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
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
                                child: _buildMenuOptions(gameController),
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
  
  Widget _buildMenuOptions(GameController gameController) {
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
              // Botón principal - Jugar (modo adaptativo)
              _buildMainButton(
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
                    child: _buildMenuButton(
                      icon: Icons.settings,
                      text: 'CONFIGURACIÓN',
                      onPressed: () => _showConfigurationDialog(),
                      isSmallScreen: isSmallScreen,
                    ),
                  ),
                  
                  SizedBox(width: isSmallScreen ? 8 : 16),
                  
                  Expanded(
                    child: _buildMenuButton(
                      icon: Icons.info,
                      text: 'CRÉDITOS',
                      onPressed: () => _showCreditsDialog(),
                      isSmallScreen: isSmallScreen,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: isSmallScreen ? 16 : 30),
              
              // Estadísticas del jugador
              if (gameController.gameState.highScore > 0)
                _buildPlayerStats(gameController, isSmallScreen),
              
              SizedBox(height: isSmallScreen ? 12 : 20),
              
              // Información del juego
              _buildGameInfo(isSmallScreen),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildMainButton({
    required IconData icon,
    required String text,
    required String subtitle,
    required VoidCallback onPressed,
    bool isSmallScreen = false,
  }) {
    return Container(
      width: double.infinity,
      height: isSmallScreen ? 60 : 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [GameColors.primary, GameColors.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: GameColors.primary.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: isSmallScreen ? 24 : 32,
                  color: GameColors.textPrimary,
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 20,
                            fontWeight: FontWeight.bold,
                            color: GameColors.textPrimary,
                          ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 12,
                            color: GameColors.textPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildMenuButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    bool isSmallScreen = false,
  }) {
    return Container(
      height: isSmallScreen ? 50 : 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GameColors.primary,
          width: 2,
        ),
        color: GameColors.surface,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 4 : 8,
              vertical: 4,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: isSmallScreen ? 18 : 24,
                  color: GameColors.primary,
                ),
                SizedBox(height: isSmallScreen ? 2 : 4),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 9 : 12,
                        fontWeight: FontWeight.w600,
                        color: GameColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showConfigurationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: GameColors.hudBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.settings, color: GameColors.primary),
              const SizedBox(width: 8),
              Text(
                'Configuración',
                style: TextStyle(color: GameColors.textPrimary),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selector de orientación
              ListTile(
                leading: Icon(Icons.screen_rotation, color: GameColors.secondary),
                title: Text(
                  'Orientación del Juego',
                  style: TextStyle(color: GameColors.textPrimary),
                ),
                subtitle: Text(
                  'Selecciona la orientación preferida',
                  style: TextStyle(color: GameColors.textSecondary),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _startGame(
                            Provider.of<GameController>(context, listen: false),
                            GameOrientation.vertical,
                          );
                        },
                        icon: Icon(Icons.stay_current_portrait),
                        label: Text('Vertical'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GameColors.surface,
                          foregroundColor: GameColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _startGame(
                            Provider.of<GameController>(context, listen: false),
                            GameOrientation.horizontal,
                          );
                        },
                        icon: Icon(Icons.screen_rotation),
                        label: Text('Horizontal'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GameColors.surface,
                          foregroundColor: GameColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Otras configuraciones futuras
              ListTile(
                leading: Icon(Icons.volume_up, color: GameColors.secondary),
                title: Text(
                  'Sonido',
                  style: TextStyle(color: GameColors.textPrimary),
                ),
                subtitle: Text(
                  'Próximamente...',
                  style: TextStyle(color: GameColors.textSecondary),
                ),
                trailing: Switch(
                  value: true,
                  onChanged: null, // Deshabilitado por ahora
                  activeThumbColor: GameColors.primary,
                ),
              ),
              
              ListTile(
                leading: Icon(Icons.vibration, color: GameColors.secondary),
                title: Text(
                  'Vibración',
                  style: TextStyle(color: GameColors.textPrimary),
                ),
                subtitle: Text(
                  'Feedback háptico',
                  style: TextStyle(color: GameColors.textSecondary),
                ),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Implementar configuración de vibración
                  },
                  activeThumbColor: GameColors.primary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cerrar',
                style: TextStyle(color: GameColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _showCreditsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: GameColors.hudBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.info, color: GameColors.primary),
              const SizedBox(width: 8),
              Text(
                'Créditos',
                style: TextStyle(color: GameColors.textPrimary),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información del juego
                _buildCreditSection(
                  title: '🎮 Car Slider Game',
                  items: [
                    'Versión: 1.0.0',
                    'Desarrollado con Flutter',
                    'Motor de juego: Flame Engine',
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Desarrollo
                _buildCreditSection(
                  title: '👨‍💻 Desarrollo',
                  items: [
                    'Desarrollador Principal: Tu Nombre',
                    'Diseño de Juego: Equipo de Diseño',
                    'Programación: Flutter & Dart',
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Tecnologías
                _buildCreditSection(
                  title: '🛠️ Tecnologías Utilizadas',
                  items: [
                    'Flutter SDK',
                    'Flame Game Engine',
                    'Supabase Backend',
                    'Provider State Management',
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Características
                _buildCreditSection(
                  title: '✨ Características',
                  items: [
                    '• Dual orientación adaptativa',
                    '• Sistema de colisiones avanzado',
                    '• 6 tipos de power-ups',
                    '• Animaciones fluidas',
                    '• Sistema de puntuaciones',
                    '• Interfaz adaptativa',
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Agradecimientos
                Text(
                  '💝 Agradecimientos Especiales',
                  style: TextStyle(
                    color: GameColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gracias a todos los jugadores que hacen posible este proyecto. ¡Esperamos que disfrutes jugando tanto como nosotros disfrutamos desarrollándolo!',
                  style: TextStyle(
                    color: GameColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Footer
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: GameColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '© 2024 Car Slider Game\nHecho con ❤️ y Flutter',
                      style: TextStyle(
                        color: GameColors.textSecondary,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cerrar',
                style: TextStyle(color: GameColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildCreditSection({
    required String title,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: GameColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Text(
            item,
            style: TextStyle(
              color: GameColors.textSecondary,
              fontSize: 12,
            ),
          ),
        )),
      ],
    );
  }
  
  Widget _buildPlayerStats(GameController gameController, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: GameColors.hudBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GameColors.primary,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.emoji_events,
              label: 'Mejor Puntuación',
              value: _formatScore(gameController.gameState.highScore),
              color: GameColors.coinGold,
              isSmallScreen: isSmallScreen,
            ),
          ),
          Container(
            width: 1,
            height: isSmallScreen ? 30 : 40,
            color: GameColors.hudBorder,
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.gamepad,
              label: 'Partidas Jugadas',
              value: '${gameController.gameState.gamesPlayed}',
              color: GameColors.secondary,
              isSmallScreen: isSmallScreen,
            ),
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
    bool isSmallScreen = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: isSmallScreen ? 18 : 24,
        ),
        SizedBox(height: isSmallScreen ? 2 : 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              color: GameColors.textPrimary,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                color: GameColors.textSecondary,
                fontSize: isSmallScreen ? 8 : 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildGameInfo(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: GameColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            color: GameColors.textSecondary,
            size: isSmallScreen ? 14 : 16,
          ),
          SizedBox(width: isSmallScreen ? 6 : 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                isSmallScreen
                    ? 'Gestos • Power-ups • ¡Sobrevive!'
                    : 'Usa gestos para moverte • Colecciona power-ups • ¡Sobrevive!',
                style: TextStyle(
                  color: GameColors.textSecondary,
                  fontSize: isSmallScreen ? 9 : 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatScore(int score) {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}K';
    } else {
      return score.toString();
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _buttonController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }
}

// GameScreen eliminado - se usa la implementación completa de features/game/screens/game_screen.dart