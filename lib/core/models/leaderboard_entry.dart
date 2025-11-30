// ===========================================================================
// Modelo de datos para los elementos del leaderboard
// Representa una entrada en la tabla de posiciones con información del jugador
// ===========================================================================

class LeaderboardEntry {
  final String playerName;
  final int points;
  final int rank;
  final DateTime updatedAt;

  const LeaderboardEntry({
    required this.playerName,
    required this.points,
    required this.rank,
    required this.updatedAt,
  });

  /// Factory para crear desde datos de Supabase
  factory LeaderboardEntry.fromSupabase(Map<String, dynamic> data) {
    return LeaderboardEntry(
      playerName: data['player_name'] as String,
      points: data['points'] as int,
      rank: data['rank'] as int,
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  /// Formatea los puntos de manera legible
  String get formattedPoints {
    if (points >= 1000000) {
      return '${(points / 1000000).toStringAsFixed(1)}M';
    } else if (points >= 1000) {
      return '${(points / 1000).toStringAsFixed(1)}K';
    } else {
      return points.toString();
    }
  }

  /// Formatea la fecha de manera legible
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }

  /// Obtiene el emoji de medalla según la posición
  String get medalEmoji {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }

  /// Obtiene el color de la posición según el ranking
  String get rankColor {
    if (rank <= 3) {
      return 'gold';
    } else if (rank <= 10) {
      return 'silver';
    } else {
      return 'normal';
    }
  }

  @override
  String toString() {
    return 'LeaderboardEntry(rank: $rank, player: $playerName, points: $points)';
  }
}