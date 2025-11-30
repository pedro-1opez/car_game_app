// ===========================================================================
// Modelo para definir temas visuales de carretera
// ===========================================================================

import 'package:flutter/material.dart';

/// Tipos de temas de carretera disponibles
enum RoadThemeType {
  classic,    // Carretera clásica gris
  night,      // Carretera nocturna
  desert,     // Carretera del desierto
  city,       // Carretera urbana
  highway,    // Autopista moderna
}

/// Configuración visual para temas de carretera
class RoadTheme {
  final RoadThemeType type;
  final String name;
  final String description;
  final Color roadSurfaceColor;
  final Color roadLineColor;
  final Color roadBorderColor;
  final LinearGradient roadGradient;
  final LinearGradient skyGradient;
  final IconData icon;

  const RoadTheme({
    required this.type,
    required this.name,
    required this.description,
    required this.roadSurfaceColor,
    required this.roadLineColor,
    required this.roadBorderColor,
    required this.roadGradient,
    required this.skyGradient,
    required this.icon,
  });

  /// Temas predefinidos de carretera
  static const Map<RoadThemeType, RoadTheme> themes = {
    RoadThemeType.classic: RoadTheme(
      type: RoadThemeType.classic,
      name: 'Clásica',
      description: 'Carretera gris tradicional',
      roadSurfaceColor: Color(0xFF374151),
      roadLineColor: Color(0xFFE5E7EB),
      roadBorderColor: Color(0xFF1F2937),
      roadGradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF111827),
          Color(0xFF374151),
          Color(0xFF111827),
        ],
      ),
      skyGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF4A90E2),
          Color(0xFF87CEEB),
          Color(0xFF98D8E8),
          Color(0xFFB8E6F0),
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      ),
      icon: Icons.route,
    ),

    RoadThemeType.night: RoadTheme(
      type: RoadThemeType.night,
      name: 'Nocturna',
      description: 'Carretera en la noche',
      roadSurfaceColor: Color(0xFF1F2937),
      roadLineColor: Color(0xFFFFE135),
      roadBorderColor: Color(0xFF0F172A),
      roadGradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF0F172A),
          Color(0xFF1F2937),
          Color(0xFF0F172A),
        ],
      ),
      skyGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0F172A),
          Color(0xFF1E293B),
          Color(0xFF334155),
          Color(0xFF475569),
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      ),
      icon: Icons.nightlight,
    ),

    RoadThemeType.desert: RoadTheme(
      type: RoadThemeType.desert,
      name: 'Desierto',
      description: 'Carretera en el desierto',
      roadSurfaceColor: Color(0xFF92400E),
      roadLineColor: Color(0xFFFFF7ED),
      roadBorderColor: Color(0xFF451A03),
      roadGradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF451A03),
          Color(0xFF92400E),
          Color(0xFF451A03),
        ],
      ),
      skyGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFF59E0B),
          Color(0xFFFBBF24),
          Color(0xFFFDE68A),
          Color(0xFFFEF3C7),
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      ),
      icon: Icons.wb_sunny,
    ),

    RoadThemeType.city: RoadTheme(
      type: RoadThemeType.city,
      name: 'Ciudad',
      description: 'Carretera urbana moderna',
      roadSurfaceColor: Color(0xFF475569),
      roadLineColor: Color(0xFF60A5FA),
      roadBorderColor: Color(0xFF1E293B),
      roadGradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF1E293B),
          Color(0xFF475569),
          Color(0xFF1E293B),
        ],
      ),
      skyGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF3B82F6),
          Color(0xFF60A5FA),
          Color(0xFF93C5FD),
          Color(0xFFDBEAFE),
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      ),
      icon: Icons.location_city,
    ),

    RoadThemeType.highway: RoadTheme(
      type: RoadThemeType.highway,
      name: 'Autopista',
      description: 'Autopista de alta velocidad',
      roadSurfaceColor: Color(0xFF1F2937),
      roadLineColor: Color(0xFF10B981),
      roadBorderColor: Color(0xFF111827),
      roadGradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF111827),
          Color(0xFF1F2937),
          Color(0xFF111827),
        ],
      ),
      skyGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF065F46),
          Color(0xFF059669),
          Color(0xFF10B981),
          Color(0xFF6EE7B7),
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      ),
      icon: Icons.local_shipping,
    ),
  };

  /// Obtiene un tema por tipo
  static RoadTheme getTheme(RoadThemeType type) {
    return themes[type] ?? themes[RoadThemeType.classic]!;
  }

  /// Lista de todos los tipos de tema disponibles
  static List<RoadThemeType> get availableTypes => RoadThemeType.values;

  /// Lista de todos los temas disponibles
  static List<RoadTheme> get availableThemes => themes.values.toList();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoadTheme && other.type == type;
  }

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'RoadTheme(type: $type, name: $name)';
}