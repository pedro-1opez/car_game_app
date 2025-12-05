// ===========================================================================
// Servicio para manejar audio del juego (música y efectos de sonido).
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'preferences_service.dart';
import '../core/constants/assets.dart';

class AudioService {
  static AudioService? _instance;
  static AudioService get instance => _instance ??= AudioService._();

  final AudioPlayer _musicPlayer = AudioPlayer();

  // CONSTANTES DE VOLUMEN
  static const double _musicVolume = 0.3;
  static const double _sfxVolume = 1.0;

  final Random _random = Random();

  AudioService._() {
    _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  bool _musicEnabled = true;
  bool _soundEnabled = true;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _musicEnabled = await PreferencesService.instance.isMusicEnabled();
    _soundEnabled = await PreferencesService.instance.isSoundEnabled();
    _initialized = true;
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    await PreferencesService.instance.setMusicEnabled(enabled);
    if (enabled) {
      await startMusic();
    } else {
      await stopMusic();
    }
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await PreferencesService.instance.setSoundEnabled(enabled);
  }

  Future<void> startMusic() async {
    await _playBackgroundMusic();
  }

  Future<void> _playBackgroundMusic() async {
    if (!_musicEnabled) return;
    try {
      await _musicPlayer.setVolume(_musicVolume);
      await _musicPlayer.play(AssetSource('sounds/music/background_music.m4a'));
    } catch (e) {
      debugPrint("❌ Error música: $e");
    }
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  // =================================================================
  // AUDIO DUCKING (Atenuar música en impactos)
  // =================================================================
  Future<void> _duckMusic() async {
    if (!_musicEnabled || _musicPlayer.state != PlayerState.playing) return;

    // Bajar volumen rápidamente
    await _musicPlayer.setVolume(_musicVolume * 0.2);

    await Future.delayed(const Duration(milliseconds: 600));

    // Subir volumen suavemente
    if (_musicEnabled && _musicPlayer.state == PlayerState.playing) {
      await _musicPlayer.setVolume(_musicVolume);
    }
  }

  Future<void> _playSfx(String path, {bool withPitchVariance = false, bool triggerDucking = false}) async {
    if (!_soundEnabled) return;

    try {
      final player = AudioPlayer();

      // =================================================================
      // VARIACIÓN DE TONO
      // =================================================================
      if (withPitchVariance) {
        // Genera un número entre 0.85 y 1.1.  Esto cambia ligeramente la velocidad/tono del sonido
        double variance = 0.85 + _random.nextDouble() * 0.3;
        await player.setPlaybackRate(variance);
      }

      // Aplicar Ducking si es un sonido fuerte
      if (triggerDucking) {
        _duckMusic();
      }

      await player.setVolume(_sfxVolume);
      await player.play(AssetSource(path));

      player.onPlayerComplete.listen((event) {
        player.dispose();
      });

    } catch (e) {
      debugPrint('🔴 ERROR SFX ($path): $e');
    }
  }

  // --- MÉTODOS PÚBLICOS OPTIMIZADOS ---

  // Sonidos menores
  Future<void> playCone() async => _playSfx('sounds/sfx/cone.mp3', withPitchVariance: true);
  Future<void> playDebris() async => _playSfx('sounds/sfx/debris.mp3', withPitchVariance: true);

  // Sonidos medios
  Future<void> playOilSpill() async => _playSfx('sounds/sfx/oilspill.mp3', withPitchVariance: true);

  // Sonidos de IMPACTO FUERTE
  Future<void> playBarrier() async => _playSfx('sounds/sfx/barrier.mp3', triggerDucking: true);

  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
  }

  Future<void> resumeMusic() async {
    if (_musicEnabled) {
      await _musicPlayer.resume();
    }
  }

  Future<void> dispose() async {
    await _musicPlayer.dispose();
    _initialized = false;
  }
}