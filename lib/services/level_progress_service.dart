// ===========================================================================
// Servicio para manejar el progreso y estado de los niveles
// Gestiona el desbloqueo, completado y estadísticas de cada nivel
// ===========================================================================

import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/game_level.dart';

class LevelProgressService {
  static const String _keyUnlockedLevels = 'unlocked_levels';
  static const String _keyCompletedLevels = 'completed_levels';
  
  static LevelProgressService? _instance;
  
  static LevelProgressService get instance {
    _instance ??= LevelProgressService._();
    return _instance!;
  }
  
  LevelProgressService._();
  
  // Obtener todos los niveles con su estado actual
  Future<List<GameLevel>> getLevelsWithProgress() async {
    final defaultLevels = GameLevel.getDefaultLevels();
    final unlockedLevels = await getUnlockedLevels();
    
    return defaultLevels.map((level) {
      final isUnlocked = unlockedLevels.contains(level.levelNumber) || level.levelNumber == 1;
      return GameLevel(
        levelNumber: level.levelNumber,
        distanceGoalInMeters: level.distanceGoalInMeters,
        minimumCoins: level.minimumCoins,
        title: level.title,
        description: level.description,
        isUnlocked: isUnlocked,
      );
    }).toList();
  }
  
  // Obtener los niveles desbloqueados
  Future<List<int>> getUnlockedLevels() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedLevelsString = prefs.getStringList(_keyUnlockedLevels) ?? ['1'];
    return unlockedLevelsString.map((e) => int.parse(e)).toList();
  }
  
  // Obtener los niveles completados
  Future<List<int>> getCompletedLevels() async {
    final prefs = await SharedPreferences.getInstance();
    final completedLevelsString = prefs.getStringList(_keyCompletedLevels) ?? [];
    return completedLevelsString.map((e) => int.parse(e)).toList();
  }
  
  // Verificar si un nivel está desbloqueado
  Future<bool> isLevelUnlocked(int levelNumber) async {
    if (levelNumber == 1) return true; // El primer nivel siempre está desbloqueado
    
    final unlockedLevels = await getUnlockedLevels();
    return unlockedLevels.contains(levelNumber);
  }
  
  // Verificar si un nivel está completado
  Future<bool> isLevelCompleted(int levelNumber) async {
    final completedLevels = await getCompletedLevels();
    return completedLevels.contains(levelNumber);
  }
  
  // Completar un nivel y desbloquear el siguiente
  Future<void> completeLevel(int levelNumber, {required int distanceTraveled, required int coinsCollected}) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Marcar el nivel como completado
    final completedLevels = await getCompletedLevels();
    if (!completedLevels.contains(levelNumber)) {
      completedLevels.add(levelNumber);
      await prefs.setStringList(_keyCompletedLevels, completedLevels.map((e) => e.toString()).toList());
    }
    
    // Desbloquear el siguiente nivel
    final nextLevel = levelNumber + 1;
    final allLevels = GameLevel.getDefaultLevels();
    if (nextLevel <= allLevels.length) {
      final unlockedLevels = await getUnlockedLevels();
      if (!unlockedLevels.contains(nextLevel)) {
        unlockedLevels.add(nextLevel);
        await prefs.setStringList(_keyUnlockedLevels, unlockedLevels.map((e) => e.toString()).toList());
      }
    }
    
    // Guardar estadísticas del nivel
    await _saveLevelStats(levelNumber, distanceTraveled, coinsCollected);
  }
  
  // Guardar estadísticas del nivel
  Future<void> _saveLevelStats(int levelNumber, int distance, int coins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('level_${levelNumber}_best_distance', distance);
    await prefs.setInt('level_${levelNumber}_best_coins', coins);
    await prefs.setInt('level_${levelNumber}_attempts', await getLevelAttempts(levelNumber) + 1);
  }
  
  // Obtener el mejor puntaje de un nivel
  Future<Map<String, int>> getLevelBestScore(int levelNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final bestDistance = prefs.getInt('level_${levelNumber}_best_distance') ?? 0;
    final bestCoins = prefs.getInt('level_${levelNumber}_best_coins') ?? 0;
    
    return {
      'distance': bestDistance,
      'coins': bestCoins,
    };
  }
  
  // Obtener el número de intentos de un nivel
  Future<int> getLevelAttempts(int levelNumber) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('level_${levelNumber}_attempts') ?? 0;
  }
  
  // Reiniciar todo el progreso (útil para testing o reset)
  Future<void> resetAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove(_keyUnlockedLevels);
    await prefs.remove(_keyCompletedLevels);
    
    // Limpiar estadísticas de todos los niveles
    final allLevels = GameLevel.getDefaultLevels();
    for (final level in allLevels) {
      await prefs.remove('level_${level.levelNumber}_best_distance');
      await prefs.remove('level_${level.levelNumber}_best_coins');
      await prefs.remove('level_${level.levelNumber}_attempts');
    }
  }
  
  // Obtener estadísticas generales de progreso
  Future<Map<String, dynamic>> getOverallProgress() async {
    final allLevels = GameLevel.getDefaultLevels();
    final completedLevels = await getCompletedLevels();
    final unlockedLevels = await getUnlockedLevels();
    
    int totalAttempts = 0;
    for (final level in allLevels) {
      totalAttempts += await getLevelAttempts(level.levelNumber);
    }
    
    return {
      'totalLevels': allLevels.length,
      'completedLevels': completedLevels.length,
      'unlockedLevels': unlockedLevels.length,
      'completionPercentage': (completedLevels.length / allLevels.length * 100).round(),
      'totalAttempts': totalAttempts,
    };
  }
}