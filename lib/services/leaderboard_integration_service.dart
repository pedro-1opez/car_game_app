// ===========================================================================
// Servicio para conectar el juego con el leaderboard de Supabase
// Maneja el envío automático de puntuaciones y gestión de datos del jugador
// ===========================================================================

import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../services/preferences_service.dart';

class LeaderboardIntegrationService {
  static LeaderboardIntegrationService? _instance;
  static LeaderboardIntegrationService get instance => 
      _instance ??= LeaderboardIntegrationService._();
  LeaderboardIntegrationService._();

  final SupabaseService _supabaseService = SupabaseService();
  
  // Cache del nombre del jugador para evitar múltiples consultas
  String? _cachedPlayerName;

  /// Obtiene el nombre del jugador desde SharedPreferences o usa uno por defecto
  Future<String> getPlayerName() async {
    if (_cachedPlayerName != null) {
      return _cachedPlayerName!;
    }

    try {
      // Obtener desde PreferencesService
      _cachedPlayerName = await PreferencesService.instance.getPlayerName();
      
      // Si es el nombre por defecto, generar uno único
      if (_cachedPlayerName == 'Jugador771694') {
        final uniqueName = await _generateDefaultPlayerName();
        await PreferencesService.instance.savePlayerName(uniqueName);
        _cachedPlayerName = uniqueName;
      }
      
      return _cachedPlayerName!;
    } catch (e) {
      debugPrint('❌ Error al obtener nombre del jugador: $e');
      _cachedPlayerName = 'JJugador771694';
      return _cachedPlayerName!;
    }
  }

  /// Genera un nombre de jugador por defecto único
  Future<String> _generateDefaultPlayerName() async {
    // Usar una combinación de timestamp y hash para generar un ID único
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uniqueId = timestamp.toString().substring(7); // Últimos 6 dígitos
    return 'Jugador$uniqueId';
  }

  /// Establece un nombre personalizado para el jugador
  Future<void> setPlayerName(String name) async {
    if (name.trim().isEmpty) return;
    
    final trimmedName = name.trim();
    await PreferencesService.instance.savePlayerName(trimmedName);
    
    _cachedPlayerName = trimmedName;
    debugPrint('✅ Nombre del jugador establecido: $_cachedPlayerName');
  }

  /// Envía una puntuación al leaderboard después de terminar una partida
  /// 
  /// Parámetros:
  /// - [score]: Puntuación obtenida en la partida
  /// - [gameMode]: Modo de juego ('infinite', 'level', etc.) para futuras mejoras
  /// 
  /// Retorna true si se envió exitosamente, false en caso contrario
  Future<bool> submitScore({
    required int score,
    String gameMode = 'infinite',
  }) async {
    try {
      // Solo enviar si la puntuación es mayor a 0
      if (score <= 0) {
        debugPrint('⚠️ Puntuación demasiado baja para enviar: $score');
        return false;
      }

      final playerName = await getPlayerName();
      
      debugPrint('📤 Enviando puntuación al leaderboard: $playerName - $score pts');
      
      await _supabaseService.checkAndUpsertPlayer(
        playerName: playerName,
        score: score,
      );
      
      debugPrint('✅ Puntuación enviada exitosamente al leaderboard');
      return true;
      
    } catch (e) {
      debugPrint('❌ Error al enviar puntuación al leaderboard: $e');
      return false;
    }
  }

  /// Obtiene la posición actual del jugador en el leaderboard
  Future<int?> getPlayerRank() async {
    try {
      final playerName = await getPlayerName();
      return await _supabaseService.getPlayerRank(playerName: playerName);
    } catch (e) {
      debugPrint('❌ Error al obtener ranking del jugador: $e');
      return null;
    }
  }

  /// Obtiene los puntos actuales del jugador en el leaderboard
  Future<int?> getPlayerPoints() async {
    try {
      final playerName = await getPlayerName();
      return await _supabaseService.retrievePoints(playerName: playerName);
    } catch (e) {
      debugPrint('❌ Error al obtener puntos del jugador: $e');
      return null;
    }
  }

  /// Verifica si una puntuación es un nuevo récord personal
  Future<bool> isNewPersonalRecord(int newScore) async {
    final currentPoints = await getPlayerPoints();
    return currentPoints == null || newScore > currentPoints;
  }

  /// Obtiene estadísticas completas del jugador para mostrar en la UI
  Future<Map<String, dynamic>> getPlayerStats() async {
    try {
      final playerName = await getPlayerName();
      final points = await getPlayerPoints();
      final rank = await getPlayerRank();
      
      return {
        'playerName': playerName,
        'points': points ?? 0,
        'rank': rank,
        'hasRecord': points != null && points > 0,
      };
    } catch (e) {
      debugPrint('❌ Error al obtener estadísticas del jugador: $e');
      return {
        'playerName': await getPlayerName(),
        'points': 0,
        'rank': null,
        'hasRecord': false,
      };
    }
  }

  /// Limpia la cache del nombre del jugador (útil para cambios de usuario)
  void clearCache() {
    _cachedPlayerName = null;
  }
}