// ===========================================================================
// Pantalla de Leaderboard con tabla de posiciones integrada con Supabase
// Muestra los mejores jugadores ordenados por puntuación con paginación
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/leaderboard_entry.dart';
import '../../../services/supabase_service.dart';
import '../widgets/close_button.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late AnimationController _refreshController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _refreshAnimation;
  
  final SupabaseService _supabaseService = SupabaseService();
  
  List<LeaderboardEntry> _leaderboardData = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  
  // Paginación
  int _currentPage = 0;
  final int _pageSize = 10;
  int _totalPlayers = 0;
  bool _hasMoreData = true;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    
    // Cargar datos después de que el widget esté completamente inicializado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLeaderboard();
    });
  }
  
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
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
    
    _refreshAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _refreshController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }
  
  Future<void> _loadLeaderboard({bool refresh = false}) async {
    debugPrint('🔄 _loadLeaderboard llamado: refresh=$refresh, _isLoading=$_isLoading');
    
    if (refresh) {
      setState(() {
        _currentPage = 0;
        _leaderboardData.clear();
        _hasMoreData = true;
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });
    }
    
    // Evitar múltiples cargas simultáneas
    if (_isLoading && !refresh) {
      debugPrint('⏸️ Carga bloqueada: ya está cargando');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    debugPrint('📡 Iniciando carga de leaderboard...');
    
    try {
      // Usar consulta optimizada para la primera página
      if (_currentPage == 0) {
        final result = await _supabaseService.getLeaderboardWithCount(
          page: _currentPage, 
          pageSize: _pageSize
        );
        
        final leaderboardData = result['data'] as List<Map<String, dynamic>>;
        final totalCount = result['totalCount'] as int;
        
        final entries = leaderboardData
            .map((data) => LeaderboardEntry.fromSupabase(data))
            .toList();
        
        setState(() {
          _leaderboardData = entries;
          _totalPlayers = totalCount;
          _hasMoreData = entries.length == _pageSize && 
                        _leaderboardData.length < _totalPlayers;
          _isLoading = false;
          _hasError = false;
        });
        
        debugPrint('✅ Leaderboard cargado: ${entries.length} entradas, total: $totalCount');
      } else {
        // Para páginas siguientes, usar método normal
        final leaderboardData = await _supabaseService.getLeaderboard(
          page: _currentPage, 
          pageSize: _pageSize
        );
        
        final entries = leaderboardData
            .map((data) => LeaderboardEntry.fromSupabase(data))
            .toList();
        
        setState(() {
          _leaderboardData.addAll(entries);
          _hasMoreData = entries.length == _pageSize && 
                        _leaderboardData.length < _totalPlayers;
          _isLoading = false;
          _hasError = false;
        });
      }
      
    } catch (error) {
      debugPrint('❌ Error cargando leaderboard: $error');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = error.toString();
      });
    }
  }
  
  Future<void> _loadNextPage() async {
    if (_hasMoreData && !_isLoading) {
      _currentPage++;
      await _loadLeaderboard();
    }
  }
  
  Future<void> _refreshLeaderboard() async {
    HapticFeedback.lightImpact();
    _refreshController.forward().then((_) {
      _refreshController.reset();
    });
    await _loadLeaderboard(refresh: true);
  }
  

  
  @override
  void dispose() {
    _animationController.dispose();
    _refreshController.dispose();
    super.dispose();
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
                      _buildHeader(isSmallScreen, isTablet),
                      SizedBox(height: isSmallScreen ? 20 : 30),
                      Expanded(
                        child: _buildLeaderboardContent(isSmallScreen, isTablet),
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      _buildFooter(isSmallScreen),
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
  
  Widget _buildHeader(bool isSmallScreen, bool isTablet) {
    return Row(
      children: [
        // Botón de regresar
        CustomCloseButton(isSmallScreen: isSmallScreen),
        
        SizedBox(width: 16),
        
        // Título
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Leaderboard',
                style: TextStyle(
                  color: GameColors.textPrimary,
                  fontSize: isSmallScreen ? 24 : (isTablet ? 32 : 28),
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_totalPlayers > 0)
                Text(
                  '$_totalPlayers jugador${_totalPlayers != 1 ? 'es' : ''} registrado${_totalPlayers != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: GameColors.textSecondary,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
            ],
          ),
        ),
        
        // Botón de refrescar
        AnimatedBuilder(
          animation: _refreshAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _refreshAnimation.value * 2 * 3.14159,
              child: IconButton(
                onPressed: _refreshLeaderboard,
                icon: Icon(
                  Icons.refresh,
                  color: GameColors.primary,
                  size: isSmallScreen ? 24 : 28,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildLeaderboardContent(bool isSmallScreen, bool isTablet) {
    if (_hasError) {
      return _buildErrorState(isSmallScreen);
    }
    
    if (_isLoading && _leaderboardData.isEmpty) {
      return _buildLoadingState(isSmallScreen);
    }
    
    if (_leaderboardData.isEmpty) {
      return _buildEmptyState(isSmallScreen);
    }
    
    return _buildLeaderboardList(isSmallScreen, isTablet);
  }
  
  Widget _buildLoadingState(bool isSmallScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: GameColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(GameColors.primary),
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Cargando ranking...',
                  style: TextStyle(
                    color: GameColors.textPrimary,
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Obteniendo los mejores puntajes',
                  style: TextStyle(
                    color: GameColors.textSecondary,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(bool isSmallScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: GameColors.error,
            size: isSmallScreen ? 48 : 64,
          ),
          SizedBox(height: 16),
          Text(
            'Error al cargar el leaderboard',
            style: TextStyle(
              color: GameColors.error,
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: TextStyle(
                color: GameColors.textSecondary,
                fontSize: isSmallScreen ? 12 : 14,
              ),
              textAlign: TextAlign.center,
            ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshLeaderboard,
            style: ElevatedButton.styleFrom(
              backgroundColor: GameColors.primary,
            ),
            child: Text('Reintentar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(bool isSmallScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.leaderboard_outlined,
            color: GameColors.textSecondary,
            size: isSmallScreen ? 48 : 64,
          ),
          SizedBox(height: 16),
          Text(
            'No hay jugadores registrados',
            style: TextStyle(
              color: GameColors.textSecondary,
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Sé el primero en aparecer en el leaderboard',
            style: TextStyle(
              color: GameColors.textSecondary,
              fontSize: isSmallScreen ? 12 : 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildLeaderboardList(bool isSmallScreen, bool isTablet) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        // Detectar cuando el usuario está cerca del final (90% del scroll)
        final threshold = scrollInfo.metrics.maxScrollExtent * 0.9;
        if (!_isLoading && 
            _hasMoreData &&
            scrollInfo.metrics.pixels >= threshold) {
          _loadNextPage();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: _leaderboardData.length + (_hasMoreData || _isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _leaderboardData.length) {
            // Mostrar indicador de carga o botón según el estado
            if (_isLoading) {
              return _buildLoadingIndicator(isSmallScreen);
            } else if (_hasMoreData) {
              return _buildLoadMoreButton(isSmallScreen);
            }
            return SizedBox.shrink();
          }
          
          final entry = _leaderboardData[index];
          return _buildLeaderboardItem(entry, isSmallScreen, MediaQuery.of(context).size.width > 600);
        },
      ),
    );
  }
  
  Widget _buildLoadingIndicator(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(GameColors.primary),
              strokeWidth: 2,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Cargando más...',
            style: TextStyle(
              color: GameColors.textSecondary,
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Center(
        child: ElevatedButton.icon(
          onPressed: _loadNextPage,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
          label: Text(
            'Cargar más jugadores',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: GameColors.primary,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 24,
              vertical: isSmallScreen ? 8 : 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildLeaderboardItem(LeaderboardEntry entry, bool isSmallScreen, bool isTablet) {
    final isTopThree = entry.rank <= 3;
    
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 6 : 8), // Reducido margen
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: isTopThree 
            ? GameColors.primary.withValues(alpha: 0.1)
            : GameColors.surface,
        borderRadius: BorderRadius.circular(8), // Reducido radio
        border: isTopThree ? Border.all(
          color: GameColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ) : null, // Eliminado border para elementos normales
      ),
      child: Row(
        children: [
          // Ranking y medalla
          Container(
            width: isSmallScreen ? 40 : 50,
            child: Column(
              children: [
                Text(
                  '#${entry.rank}',
                  style: TextStyle(
                    color: isTopThree ? GameColors.primary : GameColors.textSecondary,
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: isTopThree ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                if (entry.medalEmoji.isNotEmpty)
                  Text(
                    entry.medalEmoji,
                    style: TextStyle(fontSize: isSmallScreen ? 16 : 20),
                  ),
              ],
            ),
          ),
          
          SizedBox(width: isSmallScreen ? 12 : 16),
          
          // Información del jugador
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.playerName,
                  style: TextStyle(
                    color: GameColors.textPrimary,
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  'Actualizado ${entry.formattedDate}',
                  style: TextStyle(
                    color: GameColors.textSecondary,
                    fontSize: isSmallScreen ? 12 : 13,
                  ),
                ),
              ],
            ),
          ),
          
          // Puntuación
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8 : 12,
              vertical: isSmallScreen ? 4 : 6,
            ),
            decoration: BoxDecoration(
              color: isTopThree 
                  ? GameColors.primary 
                  : GameColors.hudBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              entry.formattedPoints,
              style: TextStyle(
                color: isTopThree 
                    ? Colors.white 
                    : GameColors.textPrimary,
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFooter(bool isSmallScreen) {
    final showingCount = _leaderboardData.length;

    
    return Column(
      children: [
        // Información de paginación
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              color: GameColors.textSecondary,
              size: isSmallScreen ? 14 : 16,
            ),
            SizedBox(width: 8),
            Text(
              'Mostrando $showingCount de $_totalPlayers jugadores',
              style: TextStyle(
                color: GameColors.textSecondary,
                fontSize: isSmallScreen ? 12 : 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        
        if (_hasMoreData) ...[
          SizedBox(height: 4),
          Text(
            'Desliza hacia abajo para cargar más',
            style: TextStyle(
              color: GameColors.primary,
              fontSize: isSmallScreen ? 10 : 11,
            ),
          ),
        ],
        
        if (!_hasMoreData && _leaderboardData.isNotEmpty) ...[
          SizedBox(height: 4),
          Text(
            '¡Has visto todos los jugadores!',
            style: TextStyle(
              color: GameColors.success,
              fontSize: isSmallScreen ? 10 : 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}