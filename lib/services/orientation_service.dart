// ===========================================================================
// Este servicio maneja la orientación del dispositivo y del juego,
// permitiendo cambiar, bloquear y restaurar la orientación según las
// preferencias del usuario y el estado del juego.
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/models/game_orientation.dart';
import 'preferences_service.dart';

/// Servicio para manejar orientación del dispositivo y juego
class OrientationService {
  static OrientationService? _instance;
  static OrientationService get instance => _instance ??= OrientationService._();
  OrientationService._();
  
  GameOrientation _currentGameOrientation = GameOrientation.vertical;
  bool _isLocked = false;
  
  /// Inicializa el servicio con la orientación guardada
  Future<void> initialize() async {
    _currentGameOrientation = await PreferencesService.instance.getPreferredOrientation();
    await _applySystemOrientation(_currentGameOrientation);
    debugPrint('🔄 OrientationService inicializado - Orientación: $_currentGameOrientation');
  }
  
  /// Getter para la orientación actual
  GameOrientation get currentOrientation => _currentGameOrientation;
  
  /// Cambia la orientación del juego
  Future<void> setGameOrientation(GameOrientation orientation) async {
    if (_currentGameOrientation == orientation) return;
    
    _currentGameOrientation = orientation;
    await PreferencesService.instance.savePreferredOrientation(orientation);
    await _applySystemOrientation(orientation);
    
    debugPrint('🔄 Orientación cambiada a: $orientation');
  }
  
  /// Bloquea la orientación actual
  Future<void> lockOrientation() async {
    if (_isLocked) return;
    
    _isLocked = true;
    await _applySystemOrientation(_currentGameOrientation);
    debugPrint('🔒 Orientación bloqueada');
  }
  
  /// Desbloquea la orientación
  Future<void> unlockOrientation() async {
    if (!_isLocked) return;
    
    _isLocked = false;
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    debugPrint('🔓 Orientación desbloqueada');
  }
  
  /// Aplica la orientación del sistema según la orientación del juego
  Future<void> _applySystemOrientation(GameOrientation gameOrientation) async {
    List<DeviceOrientation> orientations;
    
    switch (gameOrientation) {
      case GameOrientation.vertical:
        orientations = [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ];
        break;
      case GameOrientation.horizontal:
        orientations = [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ];
        break;
    }
    
    await SystemChrome.setPreferredOrientations(orientations);
  }
  
  /// Determina la orientación del juego basada en la orientación del dispositivo
  GameOrientation getGameOrientationFromDevice(Orientation deviceOrientation) {
    switch (deviceOrientation) {
      case Orientation.portrait:
        return GameOrientation.vertical;
      case Orientation.landscape:
        return GameOrientation.horizontal;
    }
  }
  
  /// Verifica si la orientación actual es compatible con el dispositivo
  bool isOrientationSupported(GameOrientation orientation, Size screenSize) {
    // Verificar que la pantalla tenga las proporciones adecuadas
    final aspectRatio = screenSize.width / screenSize.height;
    
    switch (orientation) {
      case GameOrientation.vertical:
        return aspectRatio < 1.0; // Más alto que ancho
      case GameOrientation.horizontal:
        return aspectRatio > 1.0; // Más ancho que alto
    }
  }
  
  /// Obtiene la orientación recomendada basada en el tamaño de pantalla
  GameOrientation getRecommendedOrientation(Size screenSize) {
    final aspectRatio = screenSize.width / screenSize.height;
    return aspectRatio > 1.0 ? GameOrientation.horizontal : GameOrientation.vertical;
  }
  
  /// Alterna entre orientaciones
  Future<void> toggleOrientation() async {
    final newOrientation = _currentGameOrientation == GameOrientation.vertical
        ? GameOrientation.horizontal
        : GameOrientation.vertical;
    
    await setGameOrientation(newOrientation);
  }
  
  /// Restaura la configuración de orientación por defecto
  Future<void> resetToDefault() async {
    await setGameOrientation(GameOrientation.vertical);
    await unlockOrientation();
  }
  
  /// Limpia el servicio
  Future<void> dispose() async {
    await unlockOrientation();
    debugPrint('🗑️ OrientationService disposed');
  }
}