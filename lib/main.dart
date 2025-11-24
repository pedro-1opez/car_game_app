import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Importar sistema de juego completo
import 'features/game/game_exports.dart';
import 'core/constants/colors.dart';

// Importar widgets modulares del menú
import 'features/menu/screens/main_menu_screen.dart';

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

