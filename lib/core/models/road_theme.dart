// ===========================================================================
// Modelo para definir temas visuales de carretera
// ===========================================================================

import 'package:flutter/material.dart';

/// Tipos de temas de carretera disponibles
enum RoadThemeType {
  classic,    // Carretera clásica (asfalto)
  desert,     // Carretera del desierto
  snow,       // Carretera nevada
  space,      // Carretera espacial
  night       // Variante nocturna
}

/// Configuración visual para temas de carretera
class RoadTheme {
  final RoadThemeType type;
  final String name;
  final String description;

  /// Ruta de la imagen para el Infinite Scrolling
  final String backgroundAssetPath;

  // Colores de UI (para el diálogo de selección y bordes)
  final Color roadSurfaceColor;
  final Color roadLineColor;
  final Color roadBorderColor;
  final LinearGradient roadGradient; // Se mantiene para previsualizaciones de UI si falla la imagen
  final LinearGradient skyGradient;  // Se mantiene para el header del diálogo
  final IconData icon;

  const RoadTheme({
    required this.type,
    required this.name,
    required this.description,
    required this.backgroundAssetPath, // Nuevo campo requerido
    required this.roadSurfaceColor,
    required this.roadLineColor,
    required this.roadBorderColor,
    required this.roadGradient,
    required this.skyGradient,
    required this.icon,
  });

  /// Temas predefinidos de carretera
  static const Map<RoadThemeType, RoadTheme> themes = {
    // 1. CLÁSICA
    RoadThemeType.classic: RoadTheme(
      type: RoadThemeType.classic,
      name: 'Ciudad',
      description: 'Carretera urbana estándar',
      backgroundAssetPath: 'assets/images/roads/city_road.png', // Asegúrate de tener esta imagen
      roadSurfaceColor: Color(0xFF374151),
      roadLineColor: Color(0xFFE5E7EB),
      roadBorderColor: Color(0xFF1F2937),
      roadGradient: LinearGradient(
        colors: [Color(0xFF111827), Color(0xFF374151), Color(0xFF111827)],
      ),
      skyGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4A90E2), Color(0xFF87CEEB)],
      ),
      icon: Icons.location_city,
    ),

    // 2. DESIERTO
    RoadThemeType.desert: RoadTheme(
      type: RoadThemeType.desert,
      name: 'Desierto',
      description: 'Carretera árida y calurosa',
      backgroundAssetPath: 'assets/images/roads/desert.png',
      roadSurfaceColor: Color(0xFF92400E),
      roadLineColor: Color(0xFFFFF7ED),
      roadBorderColor: Color(0xFF451A03),
      roadGradient: LinearGradient(
        colors: [Color(0xFF451A03), Color(0xFF92400E), Color(0xFF451A03)],
      ),
      skyGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF59E0B), Color(0xFFFEF3C7)],
      ),
      icon: Icons.wb_sunny,
    ),

    // 3. NIEVE (Agregado)
    RoadThemeType.snow: RoadTheme(
      type: RoadThemeType.snow,
      name: 'Invierno',
      description: 'Pista congelada resbaladiza',
      backgroundAssetPath: 'assets/images/roads/snow.png',
      roadSurfaceColor: Color(0xFFE2E8F0),
      roadLineColor: Color(0xFF3B82F6),
      roadBorderColor: Color(0xFF94A3B8),
      roadGradient: LinearGradient(
        colors: [Color(0xFF94A3B8), Color(0xFFF1F5F9), Color(0xFF94A3B8)],
      ),
      skyGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF60A5FA), Color(0xFFDBEAFE)],
      ),
      icon: Icons.ac_unit,
    ),

    // 4. ESPACIO (Agregado)
    RoadThemeType.space: RoadTheme(
      type: RoadThemeType.space,
      name: 'Galaxia',
      description: 'Autopista interestelar',
      backgroundAssetPath: 'assets/images/roads/space.png',
      roadSurfaceColor: Color(0xFF312E81),
      roadLineColor: Color(0xFF818CF8),
      roadBorderColor: Color(0xFF1E1B4B),
      roadGradient: LinearGradient(
        colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF1E1B4B)],
      ),
      skyGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0F172A), Color(0xFF312E81)],
      ),
      icon: Icons.rocket_launch,
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

  /// Getter de compatibilidad por si usas assetPath en otro lado
  String get assetPath => backgroundAssetPath;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoadTheme && other.type == type;
  }

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'RoadTheme(type: $type, name: $name, asset: $backgroundAssetPath)';
}