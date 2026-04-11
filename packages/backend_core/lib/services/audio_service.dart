import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

class AudioService {
  AudioService() {
    _configureTts();
  }

  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _tts = FlutterTts();

  Future<void> _configureTts() async {
    await _tts.setLanguage('en-US');
    if (kIsWeb) {
      await _tts.setSpeechRate(0.42);
    } else {
      await _tts.setSpeechRate(0.25);
    }
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
  }

  Future<void> play({
    String? assetPath,
    String? url,
    String? promptText,
  }) async {
    await stop();

    if (assetPath != null && assetPath.isNotEmpty) {
      await _player.setAsset(assetPath);
      await _player.play();
      return;
    }

    if (url != null && url.isNotEmpty) {
      await _player.setUrl(url);
      await _player.play();
      return;
    }

    if (promptText != null && promptText.isNotEmpty) {
      await _tts.speak(promptText);
    }
  }

  Future<void> stop() async {
    await _player.stop();
    await _tts.stop();
  }

  Future<void> dispose() async {
    await stop();
    await _player.dispose();
  }

  void playTap() {
    _playSound('assets/sounds/tap.mp3');
  }

  void playCorrect() {
    _playSound('assets/sounds/correct.mp3');
  }

  void playWrong() {
    _playSound('assets/sounds/wrong.mp3');
  }

  void playXP() {
    _playSound('assets/sounds/xp.mp3');
  }

  void playCelebrate() {
    _playSound('assets/sounds/celebrate.mp3');
  }

  void playUnlock() {
    _playSound('assets/sounds/unlock.mp3');
  }

  void _playSound(String assetPath) {
    Future.microtask(() async {
      try {
        await _player.setAsset(assetPath);
        await _player.play();
      } catch (_) {
      }
    });
  }
}
