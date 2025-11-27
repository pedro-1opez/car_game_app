// ===========================================================================
// El siguiente código define las rutas de los assets utilizados en el juego,
// organizados en categorías como coches, obstáculos, power-ups, UI, efectos
// visuales y audio. Proporciona métodos para obtener las rutas según el tipo
// de asset y la orientación del juego (vertical u horizontal).
// ===========================================================================

class GameAssets {
  // === CARPETAS BASE ===
  static const String _images = 'assets/images';
  static const String _sounds = 'assets/sounds';
  static const String _fonts = 'assets/fonts';
  
  // === SUBCARPETAS ===
  static const String _cars = '$_images/cars';
  static const String _obstacles = '$_images/obstacles';
  static const String _powerUps = '$_images/powerups';
  static const String _ui = '$_images/ui';
  static const String _roads = '$_images/roads';
  static const String _effects = '$_images/effects';
  
  // === COCHES DEL JUGADOR ===
  
  /// Coches del jugador - Modo Vertical
  static const Map<String, String> playerCarsVertical = {
    'purple': '$_cars/vertical/player/player_car_purple.png',
    'orange': '$_cars/vertical/player/player_car_orange.png',
    'blue': '$_cars/vertical/player/player_car_blue.png',
    'red': '$_cars/vertical/player/player_car_red.png',
    'green': '$_cars/vertical/player/player_car_green.png',
    'yellow': '$_cars/vertical/player/player_car_yellow.png',
    'white': '$_cars/vertical/player/player_car_white.png',
    'black': '$_cars/vertical/player/player_car_black.png',
  };
  
  /// Coches del jugador - Modo Horizontal
  static const Map<String, String> playerCarsHorizontal = {
    'purple': '$_cars/horizontal/player/player_car_purple.png',
    'orange': '$_cars/horizontal/player/player_car_orange.png',
    'blue': '$_cars/horizontal/player/player_car_blue.png',
    'red': '$_cars/horizontal/player/player_car_red.png',
    'green': '$_cars/horizontal/player/player_car_green.png',
    'yellow': '$_cars/horizontal/player/player_car_yellow.png',
    'white': '$_cars/horizontal/player/player_car_white.png',
    'black': '$_cars/horizontal/player/player_car_black.png',
  };
  
  // === COCHES DE TRÁFICO ===
  
  /// Coches de tráfico - Modo Vertical
  static const Map<String, String> trafficCarsVertical = {
    'orange': '$_cars/vertical/traffic/traffic_car_orange.png',
    'blue': '$_cars/vertical/traffic/traffic_car_blue.png',
    'red': '$_cars/vertical/traffic/traffic_car_red.png',
    'green': '$_cars/vertical/traffic/traffic_car_green.png',
    'yellow': '$_cars/vertical/traffic/traffic_car_yellow.png',
    'white': '$_cars/vertical/traffic/traffic_car_white.png',
    'black': '$_cars/vertical/traffic/traffic_car_black.png',
  };
  
  /// Coches de tráfico - Modo Horizontal
  static const Map<String, String> trafficCarsHorizontal = {
    'orange': '$_cars/horizontal/traffic/traffic_car_orange.png',
    'blue': '$_cars/horizontal/traffic/traffic_car_blue.png',
    'red': '$_cars/horizontal/traffic/traffic_car_red.png',
    'green': '$_cars/horizontal/traffic/traffic_car_green.png',
    'yellow': '$_cars/horizontal/traffic/traffic_car_yellow.png',
    'white': '$_cars/horizontal/traffic/traffic_car_white.png',
    'black': '$_cars/horizontal/traffic/traffic_car_black.png',
  };
  
  // === OBSTÁCULOS ===
  
  /// Obstáculos - Modo Vertical
  static const Map<String, String> obstaclesVertical = {
    'cone': '$_obstacles/vertical/cone.png',
    'oilSpill': '$_obstacles/vertical/oil_spill.png',
    'barrier': '$_obstacles/vertical/barrier.png',
    'pothole': '$_obstacles/vertical/pothole.png',
    'debris': '$_obstacles/vertical/debris.png',
  };
  
  /// Obstáculos - Modo Horizontal
  static const Map<String, String> obstaclesHorizontal = {
    'cone': '$_obstacles/horizontal/cone.png',
    'oilSpill': '$_obstacles/horizontal/oil_spill.png',
    'barrier': '$_obstacles/horizontal/barrier.png',
    'pothole': '$_obstacles/horizontal/pothole.png',
    'debris': '$_obstacles/horizontal/debris.png',
  };
  
  // === POWER-UPS ===
  
  /// Power-ups
  static const Map<String, String> powerUpsG = {
    'coin': '$_powerUps/coin.png',
    'fuel': '$_powerUps/fuel.png',
    'shield': '$_powerUps/shield.png',
    'speedboost': '$_powerUps/speedBoost.png',
    'doublepoints': '$_powerUps/doublePoints.png',
    'magnet': '$_powerUps/magnet.png',
  };
  
  // === CARRETERAS Y FONDOS ===
  
  /// Texturas de carretera - Modo Vertical
  static const Map<String, String> roadVertical = {
    'surface': '$_roads/vertical/road_surface.png',
    'lines': '$_roads/vertical/road_lines.png',
    'background': '$_roads/vertical/road_background.png',
  };
  
  /// Texturas de carretera - Modo Horizontal
  static const Map<String, String> roadHorizontal = {
    'surface': '$_roads/horizontal/road_surface.png',
    'lines': '$_roads/horizontal/road_lines.png',
    'background': '$_roads/horizontal/road_background.png',
  };
  
  // === ELEMENTOS DE UI ===
  
  /// Iconos de UI
  static const Map<String, String> uiIcons = {
    'fuel_gauge': '$_ui/icons/fuel_gauge.png',
    'speedometer': '$_ui/icons/speedometer.png',
    'heart': '$_ui/icons/heart.png',
    'coin': '$_ui/icons/coin.png',
    'pause': '$_ui/icons/pause.png',
    'play': '$_ui/icons/play.png',
    'settings': '$_ui/icons/settings.png',
    'orientation_vertical': '$_ui/icons/orientation_vertical.png',
    'orientation_horizontal': '$_ui/icons/orientation_horizontal.png',
  };
  
  /// Elementos de HUD
  static const Map<String, String> hudElements = {
    'score_panel': '$_ui/hud/score_panel.png',
    'fuel_bar': '$_ui/hud/fuel_bar.png',
    'life_indicator': '$_ui/hud/life_indicator.png',
    'speed_gauge': '$_ui/hud/speed_gauge.png',
    'minimap': '$_ui/hud/minimap.png',
  };
  
  /// Botones y controles
  static const Map<String, String> buttons = {
    'button_primary': '$_ui/buttons/button_primary.png',
    'button_secondary': '$_ui/buttons/button_secondary.png',
    'button_round': '$_ui/buttons/button_round.png',
    'slider_thumb': '$_ui/buttons/slider_thumb.png',
  };
  
  // === EFECTOS VISUALES ===
  
  /// Partículas y efectos
  static const Map<String, String> effects = {
    'explosion': '$_effects/explosion.png',
    'smoke': '$_effects/smoke.png',
    'sparks': '$_effects/sparks.png',
    'dust': '$_effects/dust.png',
    'shield_glow': '$_effects/shield_glow.png',
    'speed_trail': '$_effects/speed_trail.png',
  };
  
  // === AUDIO ===
  
  /// Efectos de sonido
  static const Map<String, String> soundEffects = {
    'engine_idle': '$_sounds/sfx/engine_idle.mp3',
    'engine_rev': '$_sounds/sfx/engine_rev.mp3',
    'car_crash': '$_sounds/sfx/car_crash.mp3',
    'coin_pickup': '$_sounds/sfx/coin_pickup.mp3',
    'fuel_pickup': '$_sounds/sfx/fuel_pickup.mp3',
    'power_up': '$_sounds/sfx/power_up.mp3',
    'explosion': '$_sounds/sfx/explosion.mp3',
    'button_click': '$_sounds/sfx/button_click.mp3',
    'lane_change': '$_sounds/sfx/lane_change.mp3',
    'shield_activate': '$_sounds/sfx/shield_activate.mp3',
    'speed_boost': '$_sounds/sfx/speed_boost.mp3',
  };
  
  /// Música de fondo
  static const Map<String, String> music = {
    'menu_theme': '$_sounds/music/menu_theme.mp3',
    'game_theme': '$_sounds/music/game_theme.mp3',
    'game_over': '$_sounds/music/game_over.mp3',
    'victory': '$_sounds/music/victory.mp3',
  };
  
  // === FUENTES ===
  
  /// Fuentes del juego
  static const Map<String, String> fonts = {
    'game_font': '$_fonts/game_font.ttf',
    'score_font': '$_fonts/score_font.ttf',
    'ui_font': '$_fonts/ui_font.ttf',
  };
  
  // === MÉTODOS ÚTILES ===
  
  /// Obtiene la ruta del coche del jugador
  static String getPlayerCarAsset(String color, bool isVertical) {
    final cars = isVertical ? playerCarsVertical : playerCarsHorizontal;
    return cars[color.toLowerCase()] ?? cars['purple']!;
  }
  
  /// Obtiene la ruta del coche de tráfico
  static String getTrafficCarAsset(String color, bool isVertical) {
    final cars = isVertical ? trafficCarsVertical : trafficCarsHorizontal;
    return cars[color.toLowerCase()] ?? cars['orange']!;
  }
  
  /// Obtiene la ruta del obstáculo
  static String getObstacleAsset(String type, bool isVertical) {
    final obstacles = isVertical ? obstaclesVertical : obstaclesHorizontal;
    return obstacles[type.toLowerCase()] ?? obstacles['cone']!;
  }
  
  /// Obtiene la ruta del power-up
  static String getPowerUpAsset(String type, bool isVertical) {
    final powerUps = powerUpsG;
    return powerUps[type.toLowerCase()] ?? powerUps['coin']!;
  }
  
  /// Obtiene la ruta de la textura de carretera
  static String getRoadAsset(String type, bool isVertical) {
    final road = isVertical ? roadVertical : roadHorizontal;
    return road[type.toLowerCase()] ?? road['surface']!;
  }
  
  /// Obtiene la ruta del efecto de sonido
  static String getSoundEffect(String name) {
    return soundEffects[name.toLowerCase()] ?? soundEffects['button_click']!;
  }
  
  /// Obtiene la ruta de la música
  static String getMusic(String name) {
    return music[name.toLowerCase()] ?? music['game_theme']!;
  }
  
  /// Lista de todos los assets necesarios para precargar
  static List<String> get allAssets {
    return [
      ...playerCarsVertical.values,
      ...playerCarsHorizontal.values,
      ...trafficCarsVertical.values,
      ...trafficCarsHorizontal.values,
      ...obstaclesVertical.values,
      ...obstaclesHorizontal.values,
      ...powerUpsG.values,
      ...roadVertical.values,
      ...roadHorizontal.values,
      ...uiIcons.values,
      ...hudElements.values,
      ...buttons.values,
      ...effects.values,
    ];
  }
  
  /// Lista de assets de audio
  static List<String> get allAudioAssets {
    return [
      ...soundEffects.values,
      ...music.values,
    ];
  }
}