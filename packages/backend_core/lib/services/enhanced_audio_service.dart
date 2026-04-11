import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import 'package:backend_core/services/tts_service.dart';

class SoundEffectsLibrary {
  static const Map<String, String> _soundMap = {
    'tap': 'assets/audio/ui/tap.mp3',
    'success': 'assets/audio/ui/success.mp3',
    'error': 'assets/audio/ui/error.mp3',
    'swipe': 'assets/audio/ui/swipe.mp3',
    'correct_answer': 'assets/audio/feedback/correct_answer.mp3',
    'wrong_answer': 'assets/audio/feedback/wrong_answer.mp3',
    'partial_credit': 'assets/audio/feedback/partial_credit.mp3',
    'xp_earned': 'assets/audio/feedback/xp_earned.mp3',
    'lesson_complete': 'assets/audio/celebration/lesson_complete.mp3',
    'perfect_score': 'assets/audio/celebration/perfect_score.mp3',
    'level_up': 'assets/audio/celebration/level_up.mp3',
    'unlock': 'assets/audio/celebration/unlock.mp3',
    'background_loop': 'assets/audio/ambient/background.mp3',
    'character_speak': 'assets/audio/ambient/character_speak.mp3',
  };

  static String? getSound(String key) {
    return _soundMap[key];
  }

  static List<String> getAllKeys() => _soundMap.keys.toList();

  static Map<String, String> getSoundInfo(String key) {
    final path = _soundMap[key];
    if (path == null) return {};

    if (path.contains('ui/')) return {'category': 'ui', 'path': path};
    if (path.contains('feedback/')) return {'category': 'feedback', 'path': path};
    if (path.contains('celebration/')) {
      return {'category': 'celebration', 'path': path};
    }
    if (path.contains('ambient/')) return {'category': 'ambient', 'path': path};

    return {'category': 'general', 'path': path};
  }
}

class EnhancedAudioService {
  static final EnhancedAudioService _instance =
      EnhancedAudioService._internal();

  late final AudioPlayer _audioPlayer;
  final Map<String, AudioPlayer> _soundPlayers = {};
  late TTSService _ttsService;

  double _masterVolume = 1.0;
  double _sfxVolume = 0.8;
  double _musicVolume = 0.6;
  bool _soundsEnabled = true;
  bool _ttsEnabled = true;
  bool _isInitialized = false;

  factory EnhancedAudioService() {
    return _instance;
  }

  EnhancedAudioService._internal();

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _audioPlayer = AudioPlayer();
      _ttsService = TTSService();
      await _ttsService.initialize();
      _isInitialized = true;
      return true;
    } catch (e) {
      if (kDebugMode) print('Audio initialization error: $e');
      return false;
    }
  }

  void setMasterVolume(double volume) {
    _masterVolume = volume.clamp(0.0, 1.0);
    _updateAllVolumes();
  }

  void setSFXVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    _updateAllVolumes();
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _updateAllVolumes();
  }

  void toggleSounds(bool enabled) {
    _soundsEnabled = enabled;
    if (!enabled) {
      stopAll();
    }
  }

  void setTTSEnabled(bool enabled) {
    _ttsEnabled = enabled;
  }

  void _updateAllVolumes() {
    _audioPlayer.setVolume(_masterVolume * _musicVolume);
    _soundPlayers.forEach((_, player) {
      player.setVolume(_masterVolume * _sfxVolume);
    });
  }

  Future<void> _playSound(String key, [double volumeOverride = 1.0]) async {
    if (!_soundsEnabled) return;

    try {
      final soundPath = SoundEffectsLibrary.getSound(key);
      if (soundPath == null) {
        if (kDebugMode) print('Sound not found: $key');
        return;
      }

      if (!_soundPlayers.containsKey(key)) {
        _soundPlayers[key] = AudioPlayer();
      }

      final player = _soundPlayers[key]!;

      try {
        await player.setAsset(soundPath);
        await player.setVolume(
          (_masterVolume * _sfxVolume * volumeOverride).clamp(0.0, 1.0),
        );
        await player.play();
      } catch (e) {
        if (kDebugMode) print('Error playing sound $key: $e');
      }
    } catch (e) {
      if (kDebugMode) print('Sound playback error: $e');
    }
  }

  Future<void> playTap() => _playSound('tap', 0.4);
  Future<void> playSwipe() => _playSound('swipe', 0.3);
  Future<void> playCorrect() => _playSound('correct_answer', 0.8);
  Future<void> playWrong() => _playSound('wrong_answer', 0.7);
  Future<void> playPartial() => _playSound('partial_credit', 0.7);
  Future<void> playXP() => _playSound('xp_earned', 0.6);
  Future<void> playCelebrate() => _playSound('lesson_complete', 0.9);
  Future<void> playPerfect() => _playSound('perfect_score', 1.0);
  Future<void> playLevelUp() => _playSound('level_up', 0.85);
  Future<void> playUnlock() => _playSound('unlock', 0.75);
  Future<void> playSound(String key, [double volume = 1.0]) =>
      _playSound(key, volume);

  Future<void> speakCharacterMessage(
    String message, {
    required dynamic character,
  }) async {
    if (!_ttsEnabled) return;
    await _ttsService.speakCharacterMessage(
      message,
      character: character,
    );
  }

  Future<void> speakLessonSentence(
    String sentence, {
    required dynamic character,
  }) async {
    if (!_ttsEnabled) return;
    await _ttsService.speakLessonSentence(
      sentence,
      character: character,
    );
  }

  Future<void> stopAll() async {
    try {
      await _audioPlayer.stop();
      for (final player in _soundPlayers.values) {
        await player.stop();
      }
      await _ttsService.stop();
    } catch (e) {
      if (kDebugMode) print('Error stopping audio: $e');
    }
  }

  Map<String, double> getVolumes() => {
        'master': _masterVolume,
        'sfx': _sfxVolume,
        'music': _musicVolume,
      };

  bool get isInitialized => _isInitialized;
  bool get soundsEnabled => _soundsEnabled;
  bool get ttsEnabled => _ttsEnabled;

  Future<void> dispose() async {
    try {
      await stopAll();
      await _audioPlayer.dispose();
      for (final player in _soundPlayers.values) {
        await player.dispose();
      }
      _soundPlayers.clear();
      _ttsService.dispose();
    } catch (e) {
      if (kDebugMode) print('Error disposing audio service: $e');
    }
  }
}
