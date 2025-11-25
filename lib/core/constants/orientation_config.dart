// ======================================================================================
// El siguiente código define las configuraciones para cada orientación 
// (horizontal y vertical) del juego, incluyendo tamaños de área, coches, 
// obstáculos, power-ups, velocidades, posiciones de carriles, posiciones iniciales del 
// jugador, zonas de spawn y configuraciones de UI.
// ======================================================================================

import 'package:flutter/material.dart';
import '../models/game_orientation.dart';

/// Configuraciones específicas para cada orientación del juego
class OrientationConstants {
  // === CONFIGURACIONES POR ORIENTACIÓN ===
  static const Map<GameOrientation, OrientationConfig> configs = {
    GameOrientation.vertical: OrientationConfig(
      orientation: GameOrientation.vertical,
      gameAreaWidth: 360.0,
      gameAreaHeight: 640.0,
      carWidth: 60.0,
      carHeight: 120.0,
      laneWidth: 80.0,
      carSpeed: 0.0, // El jugador no se mueve automáticamente
      obstacleSpeed: 580.0,
      laneCount: 3,
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
    ),
    GameOrientation.horizontal: OrientationConfig(
      orientation: GameOrientation.horizontal,
      gameAreaWidth: 640.0,
      gameAreaHeight: 360.0,
      carWidth: 80.0,
      carHeight: 40.0,
      laneWidth: 80.0,
      carSpeed: 0.0, // El jugador no se mueve automáticamente
      obstacleSpeed: 580.0,
      laneCount: 3,
      padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
    ),
  };
  
  // === POSICIONES DE CARRILES ===
  
  /// Posiciones X para carriles en modo vertical
  static const Map<LanePosition, double> verticalLanePositions = {
    LanePosition.left: 0.25,   // 25% del ancho
    LanePosition.center: 0.5,  // 50% del ancho
    LanePosition.right: 0.75,  // 75% del ancho
  };
  
  /// Posiciones Y para carriles en modo horizontal
  static const Map<LanePosition, double> horizontalLanePositions = {
    LanePosition.left: 0.25,   // 25% de la altura (equivale a "top")
    LanePosition.center: 0.5,  // 50% de la altura
    LanePosition.right: 0.75,  // 75% de la altura (equivale a "bottom")
  };
  
  // === TAMAÑOS DE OBJETOS POR ORIENTACIÓN ===
  
  /// Tamaños de coches del jugador
  static const Map<GameOrientation, Size> playerCarSizes = {
    GameOrientation.vertical: Size(60.0, 120.0),
    GameOrientation.horizontal: Size(80.0, 40.0),
  };
  
  /// Tamaños de coches de tráfico
  static const Map<GameOrientation, Size> trafficCarSizes = {
    GameOrientation.vertical: Size(55.0, 110.0),
    GameOrientation.horizontal: Size(75.0, 35.0),
  };
  
  /// Tamaños de obstáculos por tipo
  static const Map<GameOrientation, Map<String, Size>> obstacleSizes = {
    GameOrientation.vertical: {
      'cone': Size(30.0, 40.0),
      'oilSpill': Size(50.0, 30.0),
      'barrier': Size(80.0, 20.0),
      'pothole': Size(40.0, 40.0),
      'debris': Size(35.0, 35.0),
    },
    GameOrientation.horizontal: {
      'cone': Size(25.0, 35.0),
      'oilSpill': Size(40.0, 25.0),
      'barrier': Size(60.0, 15.0),
      'pothole': Size(35.0, 35.0),
      'debris': Size(30.0, 30.0),
    },
  };
  
  /// Tamaños de power-ups por tipo
  static const Map<GameOrientation, Map<String, Size>> powerUpSizes = {
    GameOrientation.vertical: {
      'coin': Size(40.0, 40.0),
      'fuel': Size(35.0, 50.0),
      'shield': Size(45.0, 45.0),
      'speedBoost': Size(50.0, 30.0),
      'doublePoints': Size(45.0, 45.0),
      'magnet': Size(40.0, 40.0),
    },
    GameOrientation.horizontal: {
      'coin': Size(35.0, 35.0),
      'fuel': Size(30.0, 45.0),
      'shield': Size(40.0, 40.0),
      'speedBoost': Size(45.0, 25.0),
      'doublePoints': Size(40.0, 40.0),
      'magnet': Size(35.0, 35.0),
    },
  };
  
  // === VELOCIDADES POR ORIENTACIÓN ===
  
  /// Velocidades de movimiento de objetos
  static const Map<GameOrientation, double> baseMovementSpeeds = {
    GameOrientation.vertical: 200.0,   // pixels per second hacia abajo
    GameOrientation.horizontal: 180.0, // pixels per second hacia la derecha
  };
  
  /// Velocidades de cambio de carril
  static const Map<GameOrientation, double> laneChangeSpeeds = {
    GameOrientation.vertical: 300.0,   // horizontal movement speed
    GameOrientation.horizontal: 280.0, // vertical movement speed
  };
  
  // === POSICIONES INICIALES ===
  
  /// Posición inicial del jugador como porcentaje del área de juego
  static const Map<GameOrientation, Offset> playerStartPositions = {
    GameOrientation.vertical: Offset(0.5, 0.85),   // centro-abajo
    GameOrientation.horizontal: Offset(0.15, 0.5), // izquierda-centro
  };
  
  /// Zonas de spawn para objetos (como porcentaje)
  static const Map<GameOrientation, Rect> spawnZones = {
    GameOrientation.vertical: Rect.fromLTRB(0.0, -0.1, 1.0, 0.0),    // arriba de la pantalla
    GameOrientation.horizontal: Rect.fromLTRB(-0.1, 0.0, 0.0, 1.0),  // izquierda de la pantalla
  };
  
  // === CONFIGURACIONES DE UI POR ORIENTACIÓN ===
  
  /// Posiciones del HUD
  static const Map<GameOrientation, Map<String, Alignment>> hudPositions = {
    GameOrientation.vertical: {
      'score': Alignment.topLeft,
      'fuel': Alignment.topRight,
      'lives': Alignment.topCenter,
      'speed': Alignment.centerLeft,
    },
    GameOrientation.horizontal: {
      'score': Alignment.topLeft,
      'fuel': Alignment.topRight,
      'lives': Alignment.bottomCenter,
      'speed': Alignment.centerLeft,
    },
  };
  
  /// Tamaños de elementos del HUD
  static const Map<GameOrientation, Map<String, Size>> hudElementSizes = {
    GameOrientation.vertical: {
      'scorePanel': Size(120.0, 60.0),
      'fuelGauge': Size(100.0, 20.0),
      'lifeIndicator': Size(30.0, 30.0),
      'speedometer': Size(80.0, 80.0),
    },
    GameOrientation.horizontal: {
      'scorePanel': Size(120.0, 50.0),
      'fuelGauge': Size(80.0, 20.0),
      'lifeIndicator': Size(25.0, 25.0),
      'speedometer': Size(60.0, 60.0),
    },
  };
  
  // === MÉTODOS ÚTILES ===
  
  /// Obtiene la configuración para una orientación específica
  static OrientationConfig getConfig(GameOrientation orientation) {
    return configs[orientation]!;
  }
  
  /// Obtiene el tamaño del área de juego para una orientación
  static Size getGameAreaSize(GameOrientation orientation) {
    final config = getConfig(orientation);
    return Size(config.gameAreaWidth, config.gameAreaHeight);
  }
  
  /// Obtiene la posición de un carril específico
  static double getLanePosition(GameOrientation orientation, LanePosition lane) {
    final config = getConfig(orientation);
    if (orientation == GameOrientation.vertical) {
      return config.getLanePositionX(lane);
    } else {
      return config.getLanePositionY(lane);
    }
  }
  
  /// Convierte una posición relativa a absoluta
  static Offset getAbsolutePosition(GameOrientation orientation, Offset relativePosition) {
    final size = getGameAreaSize(orientation);
    return Offset(
      relativePosition.dx * size.width,
      relativePosition.dy * size.height,
    );
  }
  
  /// Obtiene el tamaño de un objeto específico
  static Size getObjectSize(GameOrientation orientation, String category, String type) {
    switch (category) {
      case 'playerCar':
        return playerCarSizes[orientation]!;
      case 'trafficCar':
        return trafficCarSizes[orientation]!;
      case 'obstacle':
        return obstacleSizes[orientation]![type] ?? const Size(40.0, 40.0);
      case 'powerUp':
        return powerUpSizes[orientation]![type] ?? const Size(40.0, 40.0);
      default:
        return const Size(40.0, 40.0);
    }
  }
}