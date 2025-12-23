import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum SoundType {
  notification,
  sos,
  success,
  error,
  warning,
  click,
}

class AudioConfig {
  final double volume;
  final bool looping;
  final Duration duration;

  const AudioConfig({
    this.volume = 0.8,
    this.looping = false,
    this.duration = const Duration(seconds: 2),
  });
}

class AudioService {
  static final AudioService _instance = AudioService._internal();

  bool _isInitialized = false;
  bool _isMuted = true;
  double _masterVolume = 0.8;
  late AudioPlayer _player;

  Map<SoundType, AudioConfig> _soundConfigs = {
    SoundType.notification: const AudioConfig(volume: 0.6),
    SoundType.sos: const AudioConfig(volume: 1.0, looping: true),
    SoundType.success: const AudioConfig(volume: 0.7),
    SoundType.error: const AudioConfig(volume: 0.7),
    SoundType.warning: const AudioConfig(volume: 0.8),
    SoundType.click: const AudioConfig(volume: 0.5),
  };

  factory AudioService() => _instance;

  AudioService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;
    _player = AudioPlayer();
    _isInitialized = true;
  }

  Future<void> playSound(
    SoundType soundType, {
    double? customVolume,
    bool overrideMute = false,
  }) async {
    if (!_isInitialized) await initialize();
    if (_isMuted && !overrideMute) return;

    final config = _soundConfigs[soundType] ?? const AudioConfig();
    final effectiveVolume = (customVolume ?? config.volume) * _masterVolume;

    try {
      if (config.looping) {
        _player.setReleaseMode(ReleaseMode.loop);
      } else {
        _player.setReleaseMode(ReleaseMode.stop);
      }

      await _player.setVolume(effectiveVolume);

      // Assumes assets/sounds/ naming convention
      await _player.play(AssetSource('sounds/${soundType.name}.mp3'));
    } catch (e) {
      // Suppress missing asset errors for clean logs
      // debugPrint('Error playing sound $soundType: $e');
    }
  }

  Future<void> playSosAlert() async {
    // Try system alert since custom assets might be missing
    await SystemSound.play(SystemSoundType.click);
    // And vibrate
    await HapticFeedback.heavyImpact();

    // Attempt asset play just in case
    // await playSound(SoundType.sos, overrideMute: true);
  }

  Future<void> playSuccess() async {
    await playSound(SoundType.success);
  }

  Future<void> playError() async {
    await playSound(SoundType.error);
  }

  Future<void> playWarning() async {
    await playSound(SoundType.warning);
  }

  Future<void> playClick() async {
    // Fallback to system click since assets might be missing
    await SystemSound.play(SystemSoundType.click);
  }

  Future<void> stopAll() async {
    try {
      if (_isInitialized) {
        await _player.stop();
      }
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  void mute() {
    _isMuted = true;
    stopAll();
  }

  void unmute() {
    _isMuted = false;
  }

  bool isMuted() => _isMuted;

  void setMasterVolume(double volume) {
    _masterVolume = volume.clamp(0.0, 1.0);
    if (_isInitialized) {
      _player.setVolume(_masterVolume);
    }
  }

  double getMasterVolume() => _masterVolume;

  void setSoundConfig(SoundType soundType, AudioConfig config) {
    _soundConfigs[soundType] = config;
  }

  AudioConfig? getSoundConfig(SoundType soundType) {
    return _soundConfigs[soundType];
  }

  Future<void> testSound(SoundType soundType) async {
    await playSound(soundType);
  }

  void setAudioEnabled(bool enabled) {
    if (enabled) {
      unmute();
    } else {
      mute();
    }
  }

  bool isAudioEnabled() => !_isMuted;

  void resetSettings() {
    _isMuted = false;
    _masterVolume = 0.8;
  }

  Future<void> dispose() async {
    try {
      await stopAll();
      if (_isInitialized) {
        await _player.dispose();
      }
      _isInitialized = false;
    } catch (e) {
      debugPrint('Error disposing audio: $e');
    }
  }

  Map<String, dynamic> getStatistics() {
    return {
      'is_initialized': _isInitialized,
      'is_muted': _isMuted,
      'master_volume': _masterVolume,
      'sound_types_count': _soundConfigs.length,
      'audio_enabled': isAudioEnabled(),
    };
  }
}

final audioService = AudioService();
