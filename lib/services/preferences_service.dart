// ===========================================================================
// Este servicio maneja las preferencias del juego y el almacenamiento
// persistente utilizando SharedPreferences.
// ===========================================================================

import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/game_orientation.dart';
import '../core/models/road_theme.dart';

/// Servicio para manejar preferencias y guardado del juego
class PreferencesService {
  static PreferencesService? _instance;
  static PreferencesService get instance => _instance ??= PreferencesService._();
  PreferencesService._();
  
  static const String _keyHighScore = 'high_score';
  static const String _keyCoinsTotal = 'coins_total';
  static const String _keyGamesPlayed = 'games_played';
  static const String _keyPreferredOrientation = 'preferred_orientation';
  static const String _keyMusicEnabled = 'music_enabled';
  static const String _keySoundEnabled = 'sound_enabled';
  static const String _keySelectedCarColor = 'selected_car_color';
  static const String _keySelectedRoadTheme = 'selected_road_theme';
  static const String _keyPlayerName = 'player_name';
  
  /// Guarda el puntaje más alto
  Future<void> saveHighScore(int highScore) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyHighScore, highScore);
  }
  
  /// Obtiene el puntaje más alto guardado
  Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyHighScore) ?? 0;
  }
  
  /// Guarda el total de monedas recolectadas
  Future<void> saveTotalCoins(int totalCoins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCoinsTotal, totalCoins);
  }
  
  /// Obtiene el total de monedas guardadas
  Future<int> getTotalCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCoinsTotal) ?? 0;
  }
  
  /// Guarda número de juegos jugados
  Future<void> saveGamesPlayed(int gamesPlayed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyGamesPlayed, gamesPlayed);
  }
  
  /// Obtiene número de juegos jugados
  Future<int> getGamesPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyGamesPlayed) ?? 0;
  }
  
  /// Guarda orientación preferida
  Future<void> savePreferredOrientation(GameOrientation orientation) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPreferredOrientation, orientation.name);
  }
  
  /// Obtiene orientación preferida
  Future<GameOrientation> getPreferredOrientation() async {
    final prefs = await SharedPreferences.getInstance();
    final orientationName = prefs.getString(_keyPreferredOrientation);
    
    if (orientationName != null) {
      return GameOrientation.values.firstWhere(
        (o) => o.name == orientationName,
        orElse: () => GameOrientation.vertical,
      );
    }
    
    return GameOrientation.vertical;
  }
  
  /// Configuraciones de audio
  Future<void> setMusicEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMusicEnabled, enabled);
  }
  
  Future<bool> isMusicEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyMusicEnabled) ?? true;
  }
  
  Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySoundEnabled, enabled);
  }
  
  Future<bool> isSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySoundEnabled) ?? true;
  }
  
  /// Configuración del coche seleccionado
  Future<void> setSelectedCarColor(String colorName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedCarColor, colorName);
  }
  
  Future<String> getSelectedCarColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedCarColor) ?? 'red';
  }

  /// Configuración del tema de carretera seleccionado
  Future<void> setSelectedRoadTheme(RoadThemeType themeType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedRoadTheme, themeType.name);
  }

  Future<RoadThemeType> getSelectedRoadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_keySelectedRoadTheme);
    
    if (themeName != null) {
      return RoadThemeType.values.firstWhere(
        (theme) => theme.name == themeName,
        orElse: () => RoadThemeType.classic,
      );
    }
    
    return RoadThemeType.classic;
  }
  
  /// Guarda el nombre del jugador
  Future<void> savePlayerName(String playerName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPlayerName, playerName);
  }

  /// Obtiene el nombre del jugador
  Future<String> getPlayerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPlayerName) ?? 'Jugador771694';
  }

  /// Limpia todas las preferencias (para reset de datos)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}