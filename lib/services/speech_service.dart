import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;
  String _lastWords = '';

  Future<bool> initialize() async {
    _isAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          _isListening = false;
        }
      },
      onError: (error) {
        _isListening = false;
      },
    );
    return _isAvailable;
  }

  Future<String> startListening() async {
    if (!_isAvailable) {
      await initialize();
    }

    _lastWords = '';
    _isListening = await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          _lastWords = result.recognizedWords;
        }
      },
      listenFor: const Duration(seconds: 5),
      pauseFor: const Duration(seconds: 2),
      localeId: 'en_US',
    );

    return _lastWords;
  }

  void stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
    }
  }

  bool get isAvailable => _isAvailable;
  bool get isListening => _isListening;
  String get lastWords => _lastWords;
}