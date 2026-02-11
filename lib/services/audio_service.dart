import 'package:just_audio/just_audio.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (!_isInitialized) {
      _isInitialized = true;
    }
  }

  Future<void> playAsset(String assetPath) async {
    try {
      await initialize();
      await _player.setAsset(assetPath);
      await _player.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> playUrl(String url) async {
    try {
      await initialize();
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;
}