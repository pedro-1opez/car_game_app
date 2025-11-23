import 'package:flutter/material.dart';

/// Paleta de colores del juego
class GameColors {
  // === COLORES PRINCIPALES ===
  static const Color primary = Color(0xFF6366F1);        // Índigo
  static const Color primaryDark = Color(0xFF4F46E5);    // Índigo oscuro
  static const Color primaryLight = Color(0xFF8B5CF6);   // Índigo claro
  
  static const Color secondary = Color(0xFFF59E0B);      // Ámbar
  static const Color secondaryDark = Color(0xFFD97706);  // Ámbar oscuro
  static const Color secondaryLight = Color(0xFFFBBF24); // Ámbar claro
  
  // === COLORES DE FONDO ===
  static const Color background = Color(0xFF0F172A);     // Azul muy oscuro
  static const Color backgroundLight = Color(0xFF1E293B); // Azul oscuro
  static const Color surface = Color(0xFF334155);        // Azul gris
  static const Color surfaceLight = Color(0xFF475569);   // Azul gris claro
  
  // === COLORES DE CARRETERA ===
  static const Color roadSurface = Color(0xFF374151);    // Gris oscuro
  static const Color roadLine = Color(0xFFE5E7EB);       // Gris muy claro
  static const Color roadBorder = Color(0xFF1F2937);     // Gris muy oscuro
  static const Color roadShoulder = Color(0xFF111827);   // Negro grisáceo
  
  // === COLORES DE ESTADO ===
  static const Color success = Color(0xFF10B981);        // Verde
  static const Color warning = Color(0xFFF59E0B);        // Ámbar
  static const Color error = Color(0xFFEF4444);          // Rojo
  static const Color info = Color(0xFF3B82F6);           // Azul
  
  // === COLORES DE COCHES ===
  static const Map<String, Color> carColors = {
    'purple': Color(0xFF8B5CF6),   // Morado
    'orange': Color(0xFFF97316),   // Naranja
    'blue': Color(0xFF3B82F6),     // Azul
    'red': Color(0xFFEF4444),      // Rojo
    'green': Color(0xFF10B981),    // Verde
    'yellow': Color(0xFFFBBF24),   // Amarillo
    'white': Color(0xFFF8FAFC),    // Blanco
    'black': Color(0xFF1F2937),    // Negro
  };
  
  // === COLORES DE POWER-UPS ===
  static const Color coinGold = Color(0xFFFFD700);       // Oro
  static const Color fuelBlue = Color(0xFF0EA5E9);       // Azul combustible
  static const Color shieldSilver = Color(0xFFC0C0C0);   // Plata
  static const Color speedRed = Color(0xFFDC2626);       // Rojo velocidad
  static const Color pointsGreen = Color(0xFF16A34A);    // Verde puntos
  static const Color magnetPurple = Color(0xFF9333EA);   // Morado imán
  
  // === COLORES DE OBSTÁCULOS ===
  static const Color coneOrange = Color(0xFFEA580C);     // Naranja cono
  static const Color oilBlack = Color(0xFF000000);       // Negro aceite
  static const Color barrierRed = Color(0xFFB91C1C);     // Rojo barrera
  static const Color potholeBrown = Color(0xFF92400E);   // Marrón bache
  static const Color debrisGray = Color(0xFF6B7280);     // Gris escombros
  
  // === COLORES DE UI ===
  static const Color textPrimary = Color(0xFFF8FAFC);    // Blanco
  static const Color textSecondary = Color(0xFFCBD5E1);  // Gris claro
  static const Color textDisabled = Color(0xFF64748B);   // Gris
  
  static const Color buttonPrimary = Color(0xFF6366F1);  // Índigo
  static const Color buttonSecondary = Color(0xFF475569); // Gris
  static const Color buttonDanger = Color(0xFFEF4444);   // Rojo
  
  // === COLORES DE ESTADO DEL JUEGO ===
  static const Color hudBackground = Color(0x80000000);   // Negro semi-transparente
  static const Color hudBorder = Color(0xFF334155);      // Gris azulado
  
  static const Color fuelHigh = Color(0xFF10B981);       // Verde (combustible alto)
  static const Color fuelMedium = Color(0xFFF59E0B);     // Ámbar (combustible medio)
  static const Color fuelLow = Color(0xFFEF4444);        // Rojo (combustible bajo)
  
  static const Color livesActive = Color(0xFFEF4444);    // Rojo (vida activa)
  static const Color livesInactive = Color(0xFF374151);  // Gris (vida perdida)
  
  // === GRADIENTES ===
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F172A),
      Color(0xFF1E293B),
    ],
  );
  
  static const LinearGradient roadGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF111827),
      Color(0xFF374151),
      Color(0xFF111827),
    ],
  );
  
  static const LinearGradient speedBoostGradient = LinearGradient(
    colors: [
      Color(0xFFDC2626),
      Color(0xFFEF4444),
      Color(0xFFF87171),
    ],
  );
  
  static const LinearGradient shieldGradient = LinearGradient(
    colors: [
      Color(0xFF3B82F6),
      Color(0xFF60A5FA),
      Color(0xFF93C5FD),
    ],
  );
  
  // === EFECTOS Y PARTÍCULAS ===
  static const Color explosionOrange = Color(0xFFEA580C);
  static const Color explosionYellow = Color(0xFFFBBF24);
  static const Color explosionRed = Color(0xFFDC2626);
  
  static const Color smokeGray = Color(0xFF6B7280);
  static const Color sparkWhite = Color(0xFFF8FAFC);
  static const Color sparkYellow = Color(0xFFFEF3C7);
  
  // === MÉTODOS ÚTILES ===
  
  /// Obtiene el color de un coche por nombre
  static Color getCarColor(String colorName) {
    return carColors[colorName.toLowerCase()] ?? carColors['purple']!;
  }
  
  /// Obtiene el color del combustible según el porcentaje
  static Color getFuelColor(double fuelPercentage) {
    if (fuelPercentage > 0.5) return fuelHigh;
    if (fuelPercentage > 0.2) return fuelMedium;
    return fuelLow;
  }
  
  /// Obtiene un color con opacidad específica
  static Color withOpacity(Color color, double opacity) {    
    return color.withValues(alpha: opacity.clamp(0.0, 1.0));
  }
  
  /// Obtiene una versión más clara del color
  static Color lighten(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return hslLight.toColor();
  }
  
  /// Obtiene una versión más oscura del color
  static Color darken(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    );
    return hslDark.toColor();
  }
  
  /// Colores del tema para diferentes dificultades
  static const Map<String, Color> difficultyColors = {
    'easy': Color(0xFF10B981),    // Verde
    'medium': Color(0xFFF59E0B),  // Ámbar
    'hard': Color(0xFFEF4444),    // Rojo
    'expert': Color(0xFF8B5CF6),  // Morado
  };
  
  /// Obtiene el color según la dificultad
  static Color getDifficultyColor(String difficulty) {
    return difficultyColors[difficulty.toLowerCase()] ?? difficultyColors['medium']!;
  }
}