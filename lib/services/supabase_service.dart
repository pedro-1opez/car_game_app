// ===========================================================================
// Servicio centralizado para gestionar todas las interacciones con Supabase.
// Encapsula autenticación, consultas y operaciones CRUD en la tabla 'players'.
// ===========================================================================

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Servicio centralizado para gestionar todas las interacciones con Supabase.
/// 
/// Encapsula autenticación, consultas y operaciones CRUD en la tabla 'players'.
class SupabaseService {
  final SupabaseClient _client;

  /// Constructor. Recibe el cliente de Supabase (por defecto usa Supabase.instance.client).
  SupabaseService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Obtiene el cliente de Supabase (útil si necesitas acceso directo en casos especiales).
  SupabaseClient get client => _client;

  /// Obtiene el usuario actualmente autenticado.
  User? get currentUser => _client.auth.currentUser;

  /// Obtiene la sesión actual.
  Session? get currentSession => _client.auth.currentSession;

  /// Stream que emite cambios en el estado de autenticación.
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  // ============================================================================
  // AUTENTICACIÓN
  // ============================================================================

  /// Inicia sesión con email y contraseña.
  /// 
  /// Retorna `true` si la autenticación fue exitosa, `false` en caso contrario.
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null) {
        debugPrint('❌ Error signing in: No session returned');
        return false;
      } else {
        debugPrint('✅ User signed in: ${response.user?.email}');
        return true;
      }
    } catch (error) {
      debugPrint('❌ Error inesperado al hacer sign in: $error');
      return false;
    }
  }

  /// Cierra la sesión actual.
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      debugPrint('✅ Usuario deslogueado.');
    } catch (error) {
      debugPrint('❌ Error al hacer sign out: $error');
    }
  }

  // ============================================================================
  // OPERACIONES EN LA TABLA 'players'
  // ============================================================================

  /// Inserta un nuevo jugador en la tabla 'players'.
  /// 
  /// Si no hay sesión activa, intenta hacer sign-in primero usando credenciales del .env.
  /// 
  /// Parámetros:
  /// - [playerName]: Nombre del jugador.
  /// - [points]: Puntos iniciales del jugador.
  /// - [userId]: ID del usuario propietario (opcional, por defecto usa un ID fijo).
  Future<void> insertPlayer({
    required String playerName,
    required int points,
    String? userId,
  }) async {
    final session = _client.auth.currentSession;
    final user = _client.auth.currentUser;

    debugPrint('session: $session');
    debugPrint('user id: ${user?.id}');

    if (session == null || user == null) {
      // Intenta autenticarse si no hay sesión usando credenciales del .env
      debugPrint('⚠️ No hay sesión activa. Intentando autenticar...');
      final email = dotenv.env['AUTH_EMAIL'];
      final password = dotenv.env['AUTH_PASSWORD'];
      
      if (email != null && password != null) {
        await signIn(email: email, password: password);
      } else {
        debugPrint('❌ No se encontraron credenciales en .env');
        return;
      }
    }

    try {
      final newPlayer = {
        'player_name': playerName,
        'points': points,
        'user_id': userId ?? '3843a525-e9d5-414c-9994-dbb81aa4f633',
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client.from('players').insert(newPlayer);

      debugPrint('✅ Jugador insertado exitosamente: $playerName');
    } on PostgrestException catch (error) {
      debugPrint('❌ Error al insertar jugador: ${error.message}');
    } catch (error) {
      debugPrint('❌ Error inesperado al insertar: $error');
    }
  }

  /// Actualiza los puntos de un jugador existente en la tabla 'players'.
  /// 
  /// Filtra por el nombre del jugador.
  /// 
  /// Parámetros:
  /// - [playerName]: Nombre del jugador a actualizar.
  /// - [points]: Nuevos puntos del jugador.
  Future<void> updatePlayer({
    required String playerName,
    required int points,
  }) async {
    try {
      final updatedData = {
        'player_name': playerName,
        'points': points,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client
          .from('players')
          .update(updatedData)
          .eq('player_name', playerName);

      debugPrint('✅ Jugador con nombre $playerName actualizado exitosamente.');
    } on PostgrestException catch (error) {
      debugPrint('❌ Error al actualizar jugador: ${error.message}');
    } catch (error) {
      debugPrint('❌ Error inesperado al actualizar: $error');
    }
  }

  /// Verifica si un jugador existe. Si existe, lo actualiza; si no, lo inserta (UPSERT).
  /// 
  /// Parámetros:
  /// - [playerName]: Nombre del jugador.
  /// - [score]: Puntos a asignar o actualizar.
  Future<void> checkAndUpsertPlayer({
    required String playerName,
    required int score,
  }) async {
    try {
      final response = await _client
          .from('players')
          .select('id, player_name, points')
          .eq('player_name', playerName)
          .limit(1);

      if (response.isNotEmpty) {
        // Jugador existe → UPDATE
        final existingPlayer = response.first;
        final existingPlayerName = existingPlayer['player_name'] as String;
        final existingPoints = existingPlayer['points'] as int;

        debugPrint(
            'Jugador $playerName | $existingPlayerName encontrado. Actualizando puntuación de $existingPoints a $score...');

        await updatePlayer(playerName: playerName, points: score);
      } else {
        // Jugador NO existe → INSERT
        debugPrint(
            'Jugador $playerName no encontrado. Insertando nuevo registro...');

        await insertPlayer(playerName: playerName, points: score);
      }
    } on PostgrestException catch (error) {
      debugPrint('❌ Error de Supabase al buscar jugador: ${error.message}');
    } catch (error) {
      debugPrint('❌ Error inesperado: $error');
    }
  }

  /// Recupera los puntos de un jugador desde la tabla 'players'.
  /// 
  /// Retorna los puntos si el jugador existe, o `null` si no se encuentra.
  /// 
  /// Parámetros:
  /// - [playerName]: Nombre del jugador a buscar.
  Future<int?> retrievePoints({required String playerName}) async {
    try {
      final response = await _client
          .from('players')
          .select('points')
          .eq('player_name', playerName)
          .limit(1);

      if (response.isNotEmpty) {
        final playerData = response.first;
        final points = playerData['points'] as int;
        debugPrint('✅ Puntos recuperados para $playerName: $points');
        return points;
      } else {
        debugPrint('⚠️ Jugador $playerName no encontrado.');
        return null;
      }
    } catch (error) {
      debugPrint('❌ Error inesperado al recuperar puntos: $error');
      return null;
    }
  }

  // ============================================================================
  // LEADERBOARD - TABLA DE POSICIONES
  // ============================================================================

  /// Obtiene el leaderboard paginado ordenado por puntos (mayor a menor).
  /// 
  /// Parámetros:
  /// - [page]: Número de página (inicia en 0).
  /// - [pageSize]: Cantidad de registros por página (por defecto 10).
  /// 
  /// Retorna una lista de mapas con la estructura:
  /// - player_name: Nombre del jugador
  /// - points: Puntos del jugador
  /// - updated_at: Fecha de última actualización
  /// - rank: Posición en el ranking (calculada)
  Future<List<Map<String, dynamic>>> getLeaderboard({
    int page = 0,
    int pageSize = 10,
  }) async {
    try {
      final offset = page * pageSize;
      
      final response = await _client
          .from('players')
          .select('player_name, points, updated_at')
          .order('points', ascending: false)
          .order('updated_at', ascending: true) // En caso de empate, el más antiguo va primero
          .range(offset, offset + pageSize - 1);

      // Agregar el ranking calculado
      final leaderboardData = <Map<String, dynamic>>[];
      for (int i = 0; i < response.length; i++) {
        final player = Map<String, dynamic>.from(response[i]);
        player['rank'] = offset + i + 1; // Posición en el ranking global
        leaderboardData.add(player);
      }

      debugPrint('✅ Leaderboard obtenido: ${leaderboardData.length} jugadores en página $page');
      return leaderboardData;
    } on PostgrestException catch (error) {
      debugPrint('❌ Error de Supabase al obtener leaderboard: ${error.message}');
      return [];
    } catch (error) {
      debugPrint('❌ Error inesperado al obtener leaderboard: $error');
      return [];
    }
  }

  /// Obtiene el total de jugadores en la tabla para calcular la paginación.
  Future<int> getTotalPlayersCount() async {
    try {
      final response = await _client
          .from('players')
          .select('id')
          .count(CountOption.exact);

      return response.count ?? 0;
    } on PostgrestException catch (error) {
      debugPrint('❌ Error de Supabase al contar jugadores: ${error.message}');
      return 0;
    } catch (error) {
      debugPrint('❌ Error inesperado al contar jugadores: $error');
      return 0;
    }
  }

  /// Obtiene leaderboard con conteo total en una consulta optimizada.
  /// Retorna un mapa con 'data' (lista de jugadores) y 'totalCount' (total de jugadores).
  Future<Map<String, dynamic>> getLeaderboardWithCount({
    int page = 0,
    int pageSize = 10,
  }) async {
    try {
      final offset = page * pageSize;
      
      // Obtener datos y conteo en paralelo para mejor rendimiento
      final results = await Future.wait<dynamic>([
        _client
            .from('players')
            .select('player_name, points, updated_at')
            .order('points', ascending: false)
            .order('updated_at', ascending: true)
            .range(offset, offset + pageSize - 1),
        
        // Solo hacer conteo en la primera página
        if (page == 0)
          _client
              .from('players')
              .select('id')
              .count(CountOption.exact)
        else
          Future<PostgrestResponse<List<Map<String, dynamic>>>?>.value(null),
      ]);

      final leaderboardResponse = results[0] as List<Map<String, dynamic>>;
      final countResponse = results[1] as PostgrestResponse<dynamic>?;
      
      // Agregar el ranking calculado
      final leaderboardData = <Map<String, dynamic>>[];
      for (int i = 0; i < leaderboardResponse.length; i++) {
        final player = Map<String, dynamic>.from(leaderboardResponse[i]);
        player['rank'] = offset + i + 1;
        leaderboardData.add(player);
      }

      final totalCount = countResponse?.count ?? 0;
      
      debugPrint('✅ Leaderboard optimizado: ${leaderboardData.length} jugadores (página $page)');
      
      return {
        'data': leaderboardData,
        'totalCount': totalCount,
      };
    } on PostgrestException catch (error) {
      debugPrint('❌ Error de Supabase al obtener leaderboard optimizado: ${error.message}');
      return {'data': <Map<String, dynamic>>[], 'totalCount': 0};
    } catch (error) {
      debugPrint('❌ Error inesperado al obtener leaderboard optimizado: $error');
      return {'data': <Map<String, dynamic>>[], 'totalCount': 0};
    }
  }

  /// Obtiene la posición de un jugador específico en el ranking global.
  /// 
  /// Parámetros:
  /// - [playerName]: Nombre del jugador.
  /// 
  /// Retorna la posición (empezando en 1) o null si no se encuentra.
  Future<int?> getPlayerRank({required String playerName}) async {
    try {
      // Primero obtenemos los puntos del jugador
      final playerPoints = await retrievePoints(playerName: playerName);
      if (playerPoints == null) {
        return null;
      }

      // Contamos cuántos jugadores tienen más puntos
      final response = await _client
          .from('players')
          .select('player_name')
          .gt('points', playerPoints)
          .count(CountOption.exact);

      final playersAbove = response.count ?? 0;
      
      // La posición es el número de jugadores con más puntos + 1
      final rank = playersAbove + 1;
      
      debugPrint('✅ Posición de $playerName: #$rank con $playerPoints puntos');
      return rank;
    } on PostgrestException catch (error) {
      debugPrint('❌ Error de Supabase al obtener ranking: ${error.message}');
      return null;
    } catch (error) {
      debugPrint('❌ Error inesperado al obtener ranking: $error');
      return null;
    }
  }
}
