import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;
  bool _isInitializing = false;
  bool _isStarting = false;
  bool _isResetting = false;
  String _lastWords = '';
  String? _lastError;
  DateTime? _lastResetTime;

  Future<bool> initialize() async {
    if (_isInitializing || _isAvailable) {
      return _isAvailable;
    }

    _isInitializing = true;
    try {
      await _hardReset();

      _isAvailable = await _speech.initialize(
        onStatus: (status) {
          _handleStatusChange(status);
        },
        onError: (error) {
          _isListening = false;
          _isStarting = false;
          _lastError = 'Speech recognition error: ${error.errorMsg}';
        },
      );
    } catch (e) {
      _isAvailable = false;
      _lastError = 'Initialization error: $e';
    } finally {
      _isInitializing = false;
    }
    return _isAvailable;
  }

  void _handleStatusChange(String status) {
    switch (status) {
      case 'done':
      case 'notListening':
        _isListening = false;
        _isStarting = false;
        break;
      case 'listening':
        _isStarting = false;
        _isListening = true;
        break;
      case 'initializing':
        break;
    }
  }

  Future<void> _hardReset() async {
    try {
      _isStarting = false;
      _isListening = false;
      _lastResetTime = DateTime.now();

      try {
        _speech.stop();
        _speech.cancel();
      } catch (_) {
      }

      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      _lastError = 'Hard reset failed: $e';
    }
  }

  Future<void> _ensureReset() async {
    if (_isResetting) return;
    _isResetting = true;
    try {
      await _hardReset();
    } finally {
      _isResetting = false;
    }
  }

  Future<bool> startListening({
    void Function(String words)? onResult,
    void Function(String error)? onError,
    String localeId = 'en_US',
    Duration listenFor = const Duration(seconds: 5),
    Duration pauseFor = const Duration(seconds: 2),
  }) async {
    if (_isStarting || _isListening || _isResetting) {
      final errorMsg = _isStarting
          ? 'Speech recognition is starting...'
          : _isListening
              ? 'Already listening...'
              : 'Resetting speech service...';
      onError?.call(errorMsg);
      return false;
    }

    _isStarting = true;

    try {
      await _ensureReset();

      final now = DateTime.now();
      final timeSinceReset = now.difference(_lastResetTime ?? now);
      if (timeSinceReset.inMilliseconds < 500) {
        await Future.delayed(
          Duration(milliseconds: 500 - timeSinceReset.inMilliseconds),
        );
      }

      if (!_isAvailable) {
        final initialized = await initialize();
        if (!initialized) {
          onError?.call('Speech recognition is not available on this device');
          _isStarting = false;
          return false;
        }
      }

      _lastWords = '';
      _lastError = null;

      _isListening = await _speech.listen(
            onResult: (result) {
              _lastWords = result.recognizedWords;
              if (onResult != null) onResult(_lastWords);
            },
            listenFor: listenFor,
            pauseFor: pauseFor,
            localeId: localeId,
            listenOptions: stt.SpeechListenOptions(
              cancelOnError: true,
              partialResults: true,
              onDevice: true,
            ),
          ) ??
          false;

      if (!_isListening) {
        _lastError =
            'Failed to start listening. Please check microphone permissions.';
        onError?.call(_lastError!);
      }

      return _isListening;
    } catch (e) {
      _isListening = false;
      _lastError = 'Listen error: $e';
      onError?.call(_lastError!);
      return false;
    } finally {
      _isStarting = false;
    }
  }

  void stopListening() {
    try {
      _isStarting = false;
      if (_isListening) {
        _speech.stop();
        _isListening = false;
      }
    } catch (e) {
      _lastError = e.toString();
      _isListening = false;
      _isStarting = false;
    }
  }

  bool get isAvailable => _isAvailable;
  bool get isListening => _isListening;
  bool get isStarting => _isStarting;
  bool get isResetting => _isResetting;
  String get lastWords => _lastWords;
  String? get lastError => _lastError;
}
