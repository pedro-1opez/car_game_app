// ===========================================================================
// El siguiente código proporciona utilidades para manejar orientaciones
// del juego, incluyendo detección de orientación del dispositivo,
// conversión entre orientaciones y ajustes de UI según la orientación.
// ===========================================================================
// Se diferencia de coordinate_converter.dart en que este archivo maneja
// la lógica relacionada con la orientación del juego y del dispositivo.
// ===========================================================================
// Se diferencia de orientation_config.dart en que este archivo contiene
// funciones y lógica, mientras que orientation_config.dart solo define
// configuraciones estáticas para cada orientación.
// ===========================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_orientation.dart';
import '../constants/orientation_config.dart';
import 'coordinate_converter.dart';

/// Helper para manejar orientaciones y transiciones entre ellas
class OrientationHelper {
  /// Detecta la orientación actual del dispositivo
  static GameOrientation detectDeviceOrientation(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final orientation = mediaQuery.orientation;
    
    return orientation == Orientation.portrait
        ? GameOrientation.vertical
        : GameOrientation.horizontal;
  }
  
  /// Verifica si el dispositivo está en orientación natural
  static bool isNaturalOrientation(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.orientation == Orientation.portrait;
  }
  
  /// Fuerza una orientación específica
  static Future<void> setPreferredOrientation(GameOrientation orientation) async {
    switch (orientation) {
      case GameOrientation.vertical:
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        break;
      case GameOrientation.horizontal:
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        break;
    }
  }
  
  /// Permite todas las orientaciones
  static Future<void> allowAllOrientations() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
  
  /// Obtiene la configuración para una orientación específica
  static OrientationConfig getConfigForOrientation(GameOrientation orientation) {
    return OrientationConstants.getConfig(orientation);
  }
  
  /// Calcula las dimensiones del área de juego según la pantalla
  static Size calculateGameArea(BuildContext context, GameOrientation orientation) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final config = getConfigForOrientation(orientation);
    
    // Ajustar el área de juego para que quepa en la pantalla
    final availableWidth = screenSize.width - config.padding.horizontal;
    final availableHeight = screenSize.height - config.padding.vertical;
    
    final scaleX = availableWidth / config.gameAreaWidth;
    final scaleY = availableHeight / config.gameAreaHeight;
    final scale = math.min(scaleX, scaleY);
    
    return Size(
      config.gameAreaWidth * scale,
      config.gameAreaHeight * scale,
    );
  }
  
  /// Convierte posición de carril a coordenadas absolutas
  static Offset getLanePosition(
    LanePosition lane,
    GameOrientation orientation,
    Size gameAreaSize,
  ) {
    return CoordinateConverter.getLaneCenter(lane, orientation, gameAreaSize);
  }
  
  /// Obtiene el carril más cercano a una posición
  static LanePosition getClosestLane(
    Offset position,
    GameOrientation orientation,
    Size gameAreaSize,
  ) {
    final lanes = LanePosition.values;
    LanePosition closestLane = LanePosition.center;
    double minDistance = double.infinity;
    
    for (final lane in lanes) {
      final laneCenter = getLanePosition(lane, orientation, gameAreaSize);
      final distance = CoordinateConverter.calculateDistance(position, laneCenter);
      
      if (distance < minDistance) {
        minDistance = distance;
        closestLane = lane;
      }
    }
    
    return closestLane;
  }
  
  /// Calcula la velocidad de movimiento para cambio de carril
  static double getLaneChangeSpeed(GameOrientation orientation) {
    return OrientationConstants.laneChangeSpeeds[orientation] ?? 300.0;
  }
  
  /// Obtiene la dirección de movimiento principal según la orientación
  static Offset getMovementDirection(GameOrientation orientation) {
    switch (orientation) {
      case GameOrientation.vertical:
        return const Offset(0, 1); // Hacia abajo
      case GameOrientation.horizontal:
        return const Offset(1, 0); // Hacia la derecha
    }
  }
  
  /// Obtiene la dirección perpendicular al movimiento (para cambio de carril)
  static Offset getLaneChangeDirection(GameOrientation orientation) {
    switch (orientation) {
      case GameOrientation.vertical:
        return const Offset(1, 0); // Horizontal
      case GameOrientation.horizontal:
        return const Offset(0, 1); // Vertical
    }
  }
  
  /// Verifica si una posición está dentro del área de juego
  static bool isWithinGameArea(Offset position, Size gameAreaSize) {
    return position.dx >= 0 &&
           position.dx <= gameAreaSize.width &&
           position.dy >= 0 &&
           position.dy <= gameAreaSize.height;
  }
  
  /// Ajusta la posición para mantenerla dentro del área de juego
  static Offset clampToGameArea(Offset position, Size gameAreaSize) {
    return CoordinateConverter.clampToBounds(position, gameAreaSize);
  }
  
  /// Calcula la zona de spawn para nuevos objetos
  static Rect getSpawnZone(GameOrientation orientation, Size gameAreaSize) {
    const spawnMargin = 100.0;
    
    switch (orientation) {
      case GameOrientation.vertical:
        // Spawn en la parte superior, fuera de la pantalla
        return Rect.fromLTWH(
          0,
          -spawnMargin,
          gameAreaSize.width,
          spawnMargin,
        );
      case GameOrientation.horizontal:
        // Spawn en la parte izquierda, fuera de la pantalla
        return Rect.fromLTWH(
          -spawnMargin,
          0,
          spawnMargin,
          gameAreaSize.height,
        );
    }
  }
  
  /// Calcula la zona de destrucción para objetos que salen de pantalla
  static Rect getDestroyZone(GameOrientation orientation, Size gameAreaSize) {
    const destroyMargin = 100.0;
    
    switch (orientation) {
      case GameOrientation.vertical:
        // Destruir en la parte inferior
        return Rect.fromLTWH(
          0,
          gameAreaSize.height,
          gameAreaSize.width,
          destroyMargin,
        );
      case GameOrientation.horizontal:
        // Destruir en la parte derecha
        return Rect.fromLTWH(
          gameAreaSize.width,
          0,
          destroyMargin,
          gameAreaSize.height,
        );
    }
  }
  
  /// Obtiene la posición inicial del jugador
  static Offset getPlayerStartPosition(
    GameOrientation orientation,
    Size gameAreaSize,
  ) {
    final startPositions = OrientationConstants.playerStartPositions;
    final relativePosition = startPositions[orientation] ?? const Offset(0.5, 0.5);
    
    return CoordinateConverter.denormalizeCoordinates(relativePosition, gameAreaSize);
  }
  
  /// Convierte un objeto entre orientaciones manteniendo su lógica
  static T convertObject<T>(
    T object,
    GameOrientation fromOrientation,
    GameOrientation toOrientation,
    Size fromSize,
    Size toSize,
  ) {
    // Esta función sería específica para cada tipo de objeto
    // Por ahora retorna el objeto sin cambios
    return object;
  }
  
  /// Obtiene el factor de escala para UI según la orientación
  static double getUIScaleFactor(GameOrientation orientation, Size screenSize) {
    // Base scale factor
    double scaleFactor = 1.0;
    
    switch (orientation) {
      case GameOrientation.vertical:
        // En vertical, escalar según la altura
        scaleFactor = (screenSize.height / 800.0).clamp(0.5, 2.0);
        break;
      case GameOrientation.horizontal:
        // En horizontal, escalar según el ancho
        scaleFactor = (screenSize.width / 800.0).clamp(0.5, 2.0);
        break;
    }
    
    return scaleFactor;
  }
  
  /// Obtiene información de debug sobre la orientación actual
  static Map<String, dynamic> getOrientationDebugInfo(
    BuildContext context,
    GameOrientation gameOrientation,
  ) {
    final mediaQuery = MediaQuery.of(context);
    final config = getConfigForOrientation(gameOrientation);
    
    return {
      'device_orientation': mediaQuery.orientation.toString(),
      'game_orientation': gameOrientation.toString(),
      'screen_size': '${mediaQuery.size.width}x${mediaQuery.size.height}',
      'game_area_size': '${config.gameAreaWidth}x${config.gameAreaHeight}',
      'scale_factor': getUIScaleFactor(gameOrientation, mediaQuery.size),
      'is_natural': isNaturalOrientation(context),
    };
  }
}