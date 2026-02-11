import 'package:just_audio/just_audio.dart';

class AudioHelper {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isInitialized = false;

  // Sound effects paths
  static const String correctSound = 'assets/audio/effects/correct.mp3';
  static const String wrongSound = 'assets/audio/effects/wrong.mp3';
  static const String completeSound = 'assets/audio/effects/complete.mp3';
  static const String clickSound = 'assets/audio/effects/click.mp3';
  
  // Phrase paths
  static const String helloSound = 'assets/audio/phrases/hello.mp3';
  static const String goodbyeSound = 'assets/audio/phrases/goodbye.mp3';
  static const String thankYouSound = 'assets/audio/phrases/thank_you.mp3';

  static Future<void> initialize() async {
    if (!_isInitialized) {
      _isInitialized = true;
    }
  }

  static Future<void> playSound(String assetPath) async {
    try {
      await initialize();
      await _player.setAsset(assetPath);
      await _player.play();
    } catch (e) {
      print('Error playing sound: $e');
      // Fallback to vibration or visual feedback
    }
  }

  // Quick play methods for common sounds
  static Future<void> playCorrect() async {
    await playSound(correctSound);
  }

  static Future<void> playWrong() async {
    await playSound(wrongSound);
  }

  static Future<void> playComplete() async {
    await playSound(completeSound);
  }

  static Future<void> playClick() async {
    await playSound(clickSound);
  }

  static Future<void> playPhrase(String phrase) async {
    switch (phrase.toLowerCase()) {
      case 'hello':
        await playSound(helloSound);
        break;
      case 'goodbye':
        await playSound(goodbyeSound);
        break;
      case 'thank you':
        await playSound(thankYouSound);
        break;
      default:
        // Try to find phrase in assets
        final path = 'assets/audio/phrases/${phrase.toLowerCase()}.mp3';
        await playSound(path);
    }
  }

  static Future<void> stop() async {
    await _player.stop();
  }

  static void dispose() {
    _player.dispose();
  }
}