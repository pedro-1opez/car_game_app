// ===========================================================================
// Servicio para manejar audio del juego (música y efectos de sonido).
// ===========================================================================
// TODO: Hace falta implementar los audios
// ===========================================================================

import 'package:flutter/material.dart';
import 'preferences_service.dart';

/// Servicio para manejar audio del juego (música y efectos de sonido)
class AudioService {
  static AudioService? _instance;
  static AudioService get instance => _instance ??= AudioService._();
  AudioService._();
  
  bool _musicEnabled = true;
  bool _soundEnabled = true;
  bool _initialized = false;
  
  /// Inicializa el servicio de audio
  Future<void> initialize() async {
    if (_initialized) return;
    
    _musicEnabled = await PreferencesService.instance.isMusicEnabled();
    _soundEnabled = await PreferencesService.instance.isSoundEnabled();
    
    _initialized = true;
    debugPrint('🎵 AudioService inicializado - Música: $_musicEnabled, Sonidos: $_soundEnabled');
  }
  
  /// Getters para el estado del audio
  bool get isMusicEnabled => _musicEnabled;
  bool get isSoundEnabled => _soundEnabled;
  
  /// Habilita/deshabilita música
  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    await PreferencesService.instance.setMusicEnabled(enabled);
    
    if (enabled) {
      await _playBackgroundMusic();
    } else {
      await _stopBackgroundMusic();
    }
  }
  
  /// Habilita/deshabilita efectos de sonido
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await PreferencesService.instance.setSoundEnabled(enabled);
  }
  
  /// Reproduce música de fondo
  Future<void> _playBackgroundMusic() async {
    if (!_musicEnabled) return;
    debugPrint('🎵 Reproduciendo música de fondo');
    // TODO: Implementar reproducción de música con audioplayers
  }
  
  /// Detiene música de fondo
  Future<void> _stopBackgroundMusic() async {
    debugPrint('🔇 Deteniendo música de fondo');
    // TODO: Implementar parada de música
  }
  
  /// Reproduce efecto de sonido para recoger moneda
  Future<void> playCoinCollectSound() async {
    if (!_soundEnabled) return;
    debugPrint('💰 Sonido: Moneda recogida');
    // TODO: Implementar sonido de moneda
  }
  
  /// Reproduce efecto de sonido para colisión
  Future<void> playCollisionSound() async {
    if (!_soundEnabled) return;
    debugPrint('💥 Sonido: Colisión');
    // TODO: Implementar sonido de colisión
  }
  
  /// Reproduce efecto de sonido para power-up
  Future<void> playPowerUpSound() async {
    if (!_soundEnabled) return;
    debugPrint('✨ Sonido: Power-up');
    // TODO: Implementar sonido de power-up
  }
  
  /// Reproduce efecto de sonido para combustible
  Future<void> playFuelSound() async {
    if (!_soundEnabled) return;
    debugPrint('⛽ Sonido: Combustible');
    // TODO: Implementar sonido de combustible
  }
  
  /// Reproduce efecto de sonido para game over
  Future<void> playGameOverSound() async {
    if (!_soundEnabled) return;
    debugPrint('💀 Sonido: Game Over');
    // TODO: Implementar sonido de game over
  }
  
  /// Reproduce efecto de sonido para cambio de carril
  Future<void> playLaneChangeSound() async {
    if (!_soundEnabled) return;
    debugPrint('🏃 Sonido: Cambio de carril');
    // TODO: Implementar sonido de cambio de carril
  }
  
  /// Pausa todos los sonidos
  Future<void> pauseAll() async {
    await _stopBackgroundMusic();
    debugPrint('⏸️ Audio pausado');
  }
  
  /// Reanuda audio
  Future<void> resume() async {
    if (_musicEnabled) {
      await _playBackgroundMusic();
    }
    debugPrint('▶️ Audio reanudado');
  }
  
  /// Limpia recursos
  Future<void> dispose() async {
    await _stopBackgroundMusic();
    _initialized = false;
    debugPrint('🗑️ AudioService disposed');
  }
}