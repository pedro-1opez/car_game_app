// ===========================================================================
// Pantalla de Leaderboard REDISEÑADA
// Incluye Podio visual para el Top 3, efectos de vidrio y animaciones
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui'; // Necesario para ImageFilter (Blur)
// Asegúrate de que estas importaciones apunten a tus archivos correctos
import '../../../core/models/leaderboard_entry.dart';
import '../../../services/supabase_service.dart';
import '../widgets/close_button.dart';

// Definimos los colores localmente para asegurar consistencia con el Menú Principal
class LeaderboardColors {
  static const Color bgDark = Color(0xFF0F3057);
  static const Color bgLight = Color(0xFF00587A);
  static const Color accentGreen = Color(0xFF00E9A3);
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);
  static const Color textWhite = Colors.white;
}

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {

  // Controladores de animación
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late AnimationController _podiumController;
  late Animation<double> _podiumScaleAnimation;

  final SupabaseService _supabaseService = SupabaseService();

  List<LeaderboardEntry> _leaderboardData = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  // Paginación
  int _currentPage = 0;
  final int _pageSize = 20; // Cargamos más para llenar la lista tras el podio
  int _totalPlayers = 0;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLeaderboard(refresh: true);
    });
  }

  void _initializeAnimations() {
    _podiumController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _podiumScaleAnimation = CurvedAnimation(
      parent: _podiumController,
      curve: Curves.elasticOut,
    );
  }

  Future<void> _loadLeaderboard({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _leaderboardData.clear();
      _hasMoreData = true;
      _hasError = false;
      _podiumController.reset(); // Reiniciar animación del podio
    }

    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Nota: Asumimos que tu servicio devuelve un Map con 'data' y 'totalCount'
      // Si tu implementación es diferente, ajusta esta parte.
      final result = await _supabaseService.getLeaderboardWithCount(
          page: _currentPage,
          pageSize: _pageSize
      );

      final rawData = result['data'] as List<Map<String, dynamic>>;
      final totalCount = result['totalCount'] as int;

      final newEntries = rawData
          .map((data) => LeaderboardEntry.fromSupabase(data))
          .toList();

      setState(() {
        if (refresh) {
          _leaderboardData = newEntries;
          // Si refrescamos, acabamos de cargar la página 0.
          // La siguiente vez queremos la página 1.
          _currentPage = 1;

          if (newEntries.isNotEmpty) {
            _podiumController.forward();
          }
        } else {
          _leaderboardData.addAll(newEntries);
          // Si estamos cargando más, ya teníamos la página X.
          // Ahora queremos prepararnos para la siguiente (X + 1).
          _currentPage++;
        }

        _totalPlayers = totalCount;
        _hasMoreData = _leaderboardData.length < _totalPlayers;
        _isLoading = false;
      });

    } catch (error) {
      debugPrint('Error loading leaderboard: $error');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _refresh() async {
    HapticFeedback.mediumImpact();
    await _loadLeaderboard(refresh: true);
  }

  @override
  void dispose() {
    _podiumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Top 3 separados para el Podio
    final topThree = _leaderboardData.take(3).toList();
    // El resto para la lista
    final restOfList = _leaderboardData.length > 3
        ? _leaderboardData.sublist(3)
        : <LeaderboardEntry>[];

    return Scaffold(
      backgroundColor: LeaderboardColors.bgDark,
      body: Stack(
        children: [
          // FONDO CON IMAGEN
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/images/cars/background.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (c,e,s) => Container(color: LeaderboardColors.bgDark),
              ),
            ),
          ),

          // CONTENIDO PRINCIPAL
          SafeArea(
            child: Column(
              children: [
                // --- HEADER ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Usamos un botón de regreso
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          "Leaderboard",
                          style: TextStyle(
                            fontFamily: "Arial Rounded MT Bold",
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: LeaderboardColors.accentGreen),
                        onPressed: _refresh,
                      ),
                    ],
                  ),
                ),

                // --- CUERPO ---
                Expanded(
                  child: _isLoading && _leaderboardData.isEmpty
                      ? const Center(child: CircularProgressIndicator(color: LeaderboardColors.accentGreen))
                      : _hasError
                      ? _buildErrorView()
                      : RefreshIndicator(
                    onRefresh: _refresh,
                    color: LeaderboardColors.accentGreen,
                    backgroundColor: LeaderboardColors.bgDark,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // Espacio superior
                        const SliverToBoxAdapter(child: SizedBox(height: 10)),

                        // --- PODIO ---
                        if (topThree.isNotEmpty)
                          SliverToBoxAdapter(
                            child: ScaleTransition(
                              scale: _podiumScaleAnimation,
                              child: _buildPodium(topThree),
                            ),
                          ),

                        const SliverToBoxAdapter(child: SizedBox(height: 20)),

                        // --- LISTA RESTANTE (4to en adelante) ---
                        if (restOfList.isNotEmpty)
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                final entry = restOfList[index];
                                // Animación simple de entrada
                                return TweenAnimationBuilder<double>(
                                  duration: Duration(milliseconds: 400 + (index * 50)),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  curve: Curves.easeOutQuart,
                                  builder: (context, value, child) {
                                    return Transform.translate(
                                      offset: Offset(0, 50 * (1 - value)),
                                      child: Opacity(
                                        opacity: value,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: _buildListItem(entry),
                                );
                              },
                              childCount: restOfList.length,
                            ),
                          ),

                        // Loader inferior para paginación infinita
                        if (_hasMoreData)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Center(
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: LeaderboardColors.accentGreen)
                                    : OutlinedButton(
                                  onPressed: () => _loadLeaderboard(),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: LeaderboardColors.accentGreen,
                                    side: const BorderSide(color: LeaderboardColors.accentGreen),
                                  ),
                                  child: const Text("CARGAR MÁS"),
                                ),
                              ),
                            ),
                          ),

                        // Espacio final
                        const SliverToBoxAdapter(child: SizedBox(height: 30)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DEL PODIO ---
  Widget _buildPodium(List<LeaderboardEntry> topThree) {
    // Aseguramos que haya 3 espacios, aunque sean nulos si no hay suficientes jugadores
    final first = topThree.isNotEmpty ? topThree[0] : null;
    final second = topThree.length > 1 ? topThree[1] : null;
    final third = topThree.length > 2 ? topThree[2] : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 260, // Altura del área del podio
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end, // Alinear abajo
        children: [
          // 2nd Place (Izquierda)
          if (second != null)
            Expanded(child: _buildPodiumPlace(second, 2, LeaderboardColors.silver, 180)),

          // 1st Place (Centro)
          if (first != null)
            Expanded(flex: 2, child: _buildPodiumPlace(first, 1, LeaderboardColors.gold, 200)), // Más ancho y alto

          // 3rd Place (Derecha)
          if (third != null)
            Expanded(child: _buildPodiumPlace(third, 3, LeaderboardColors.bronze, 160)),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(LeaderboardEntry entry, int rank, Color color, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar / Icono
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.5), blurRadius: 15, spreadRadius: 1),
                ],
              ),
              child: CircleAvatar(
                radius: rank == 1 ? 35 : 25,
                backgroundColor: Colors.white,
                child: Text(
                  entry.playerName.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: rank == 1 ? 28 : 20,
                    fontWeight: FontWeight.bold,
                    color: LeaderboardColors.bgDark,
                  ),
                ),
              ),
            ),
            // Medalla flotante
            if (rank == 1)
              Transform.translate(
                offset: const Offset(5, -10),
                child: const Icon(Icons.emoji_events_rounded, color: LeaderboardColors.gold, size: 30),
              ),
          ],
        ),

        const SizedBox(height: 10),

        // Texto Nombre
        Text(
          entry.playerName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14
          ),
        ),

        // Texto Puntos
        Text(
          entry.formattedPoints,
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 16 // Más grande
          ),
        ),

        const SizedBox(height: 8),

        // Barra del podio
        Container(
          height: height - 100, // Ajuste visual basado en la altura total
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withOpacity(0.6),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            border: Border(top: BorderSide(color: color, width: 2)),
          ),
          child: Center(
            child: Text(
              "$rank",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET DE LISTA ---
  Widget _buildListItem(LeaderboardEntry entry) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08), // Translucido
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                // Posición (Rank)
                SizedBox(
                  width: 30,
                  child: Text(
                    "${entry.rank}",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Avatar Pequeño
                CircleAvatar(
                  radius: 18,
                  backgroundColor: LeaderboardColors.accentGreen.withOpacity(0.2),
                  child: Text(
                    entry.playerName.isNotEmpty ? entry.playerName[0].toUpperCase() : "?",
                    style: const TextStyle(
                      color: LeaderboardColors.accentGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                // Nombre y Fecha
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.playerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        entry.formattedDate, // Asegúrate que tu modelo tenga esto o usa una fecha ejemplo
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Puntuación
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: LeaderboardColors.accentGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    entry.formattedPoints,
                    style: const TextStyle(
                      color: LeaderboardColors.accentGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red[300], size: 50),
          const SizedBox(height: 10),
          Text(
            "Oops! Algo salió mal",
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _refresh(),
            style: ElevatedButton.styleFrom(
              backgroundColor: LeaderboardColors.accentGreen,
              foregroundColor: LeaderboardColors.bgDark,
            ),
            child: const Text("Reintentar"),
          )
        ],
      ),
    );
  }
}