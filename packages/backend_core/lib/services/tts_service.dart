import 'package:backend_core/models/character.dart' as app_char;
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  late FlutterTts _flutterTts;
  bool _isInitialized = false;
  String? _lastError;
  List<dynamic> _availableVoices = const <dynamic>[];

  static const Map<String, Map<String, dynamic>> _characterVoices = {
    'lumi': {
      'pitch': 1.35,
      'rate': 0.85,
      'volume': 0.9,
      'language': 'en-US',
      'voiceKeywords': <String>['child', 'kid', 'baby', 'young', 'girl', 'female'],
      'description': 'Warm and encouraging baby friend',
    },
    'zippy': {
      'pitch': 1.15,
      'rate': 0.85,
      'volume': 0.95,
      'language': 'en-US',
      'voiceKeywords': <String>['bright', 'playful', 'female', 'girl', 'google'],
      'description': 'Fast-paced rocket mentor',
    },
    'nexo': {
      'pitch': 0.90,
      'rate': 0.80,
      'volume': 0.9,
      'language': 'en-US',
      'voiceKeywords': <String>['male', 'clear', 'english', 'en-us', 'standard'],
      'description': 'Logical and precise robot',
    },
    'orin': {
      'pitch': 1.05,
      'rate': 0.82,
      'volume': 0.9,
      'language': 'en-US',
      'voiceKeywords': <String>['calm', 'warm', 'english', 'mature', 'gentle'],
      'description': 'Thoughtful creative companion',
    },
  };

  factory TTSService() {
    return _instance;
  }

  TTSService._internal();

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _flutterTts = FlutterTts();
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.awaitSpeakCompletion(true);

      final voices = await _flutterTts.getVoices;
      if (voices == null || (voices is List && voices.isEmpty)) {
        _lastError = 'No TTS voices available on this device';
        return false;
      }
      _availableVoices = voices is List ? voices : const <dynamic>[];

      try {
        await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [IosTextToSpeechAudioCategoryOptions.defaultToSpeaker],
        );
      } catch (e) {
        _lastError = 'iOS audio config failed: $e';
      }

      _flutterTts.setCompletionHandler(() async {});
      _flutterTts.setErrorHandler((dynamic message) {
        _lastError = message.toString();
      });

      _isInitialized = true;
      return true;
    } catch (e) {
      _lastError = 'TTS initialization failed: $e';
      return false;
    }
  }

  Future<void> speak(
    String text, {
    required app_char.Character character,
    Future<void> Function()? onComplete,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }

    try {
      final voiceParams =
          _characterVoices[character.id] ?? _characterVoices['lumi']!;
      final language = voiceParams['language'] as String? ?? 'en-US';
      final rawRate = (voiceParams['rate'] as num?)?.toDouble() ?? 0.82;
      final speechText = _stripLeadingCharacterPrefix(text, character.name);

      await _flutterTts.setPitch(voiceParams['pitch']);
      await _flutterTts.setSpeechRate(_normalizeSpeechRate(rawRate));
      await _flutterTts.setVolume(voiceParams['volume']);
      await _flutterTts.setLanguage(language);
      await _setBestVoice(
        language: language,
        preferredKeywords:
            (voiceParams['voiceKeywords'] as List<dynamic>? ?? const <dynamic>[])
                .map((item) => item.toString())
                .toList(),
      );

      await _flutterTts.speak(_sanitizeForSpeech(speechText));

      if (onComplete != null) {
        Future.delayed(const Duration(milliseconds: 500), () async {
          await onComplete();
        });
      }
    } catch (e) {
      _lastError = 'TTS speak failed: $e';
    }
  }

  Future<void> speakCharacterMessage(
    String message, {
    required app_char.Character character,
    Future<void> Function()? onComplete,
  }) async {
    await speak(
      message,
      character: character,
      onComplete: onComplete,
    );
  }

  Future<void> speakAnswerFeedback(
    String message, {
    required app_char.Character character,
    required bool isCorrect,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }

    try {
      final base = _characterVoices[character.id] ?? _characterVoices['lumi']!;
      final language = base['language'] as String? ?? 'en-US';
      final basePitch = (base['pitch'] as num?)?.toDouble() ?? 1.0;
      final baseRate = (base['rate'] as num?)?.toDouble() ?? 0.85;
      final baseVolume = (base['volume'] as num?)?.toDouble() ?? 0.9;
      final speechText = _stripLeadingCharacterPrefix(message, character.name);

      await _flutterTts.setLanguage(language);
      await _setBestVoice(
        language: language,
        preferredKeywords:
            (base['voiceKeywords'] as List<dynamic>? ?? const <dynamic>[])
                .map((item) => item.toString())
                .toList(),
      );

      if (isCorrect) {
        await _flutterTts.setPitch((basePitch + 0.10).clamp(0.7, 1.6));
        await _flutterTts.setSpeechRate(
          _normalizeSpeechRate((baseRate + 0.05).clamp(0.35, 1.0).toDouble()),
        );
        await _flutterTts.setVolume((baseVolume + 0.05).clamp(0.0, 1.0));
      } else {
        await _flutterTts.setPitch((basePitch - 0.08).clamp(0.65, 1.4));
        await _flutterTts.setSpeechRate(
          _normalizeSpeechRate((baseRate - 0.10).clamp(0.32, 0.92).toDouble()),
        );
        await _flutterTts.setVolume(baseVolume.clamp(0.0, 1.0));
      }

      await _flutterTts.speak(_sanitizeForSpeech(speechText));
    } catch (e) {
      _lastError = 'TTS answer feedback failed: $e';
    }
  }

  Future<void> speakLessonSentence(
    String sentence, {
    required app_char.Character character,
  }) async {
    await speakNarratorText(sentence);
  }

  Future<void> speakNarratorText(String sentence) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }

    try {
      await _flutterTts.setPitch(0.98);
      await _flutterTts.setSpeechRate(_normalizeSpeechRate(0.5));
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setLanguage('en-US');
      await _setBestVoice(
        language: 'en-US',
        preferredKeywords: const <String>[
          'natural',
          'enhanced',
          'female',
          'siri',
          'google',
          'en-us',
        ],
      );

      await _flutterTts.speak(_sanitizeForSpeech(sentence));
    } catch (e) {
      _lastError = 'Lesson sentence TTS failed: $e';
    }
  }

  Future<void> _setBestVoice({
    required String language,
    required List<String> preferredKeywords,
  }) async {
    if (_availableVoices.isEmpty) {
      return;
    }

    final languageCode = language.toLowerCase();
    Map<String, String>? bestVoice;
    var bestScore = -1;

    for (final rawVoice in _availableVoices) {
      if (rawVoice is! Map) {
        continue;
      }

      final voice = Map<String, dynamic>.from(rawVoice);
      final normalizedVoice = <String, String>{
        for (final entry in voice.entries)
          entry.key.toString(): entry.value?.toString() ?? '',
      };
      final locale = (voice['locale'] ?? '').toString().toLowerCase();
      final name = (voice['name'] ?? '').toString().toLowerCase();
      final identifier = (voice['identifier'] ?? '').toString().toLowerCase();
      final haystack = '$locale $name $identifier';

      if (locale.isNotEmpty &&
          !locale.startsWith(languageCode) &&
          !languageCode.startsWith(locale)) {
        continue;
      }

      var score = 0;
      for (final keyword in preferredKeywords) {
        if (haystack.contains(keyword.toLowerCase())) {
          score += 3;
        }
      }
      if (haystack.contains('enhanced') ||
          haystack.contains('premium') ||
          haystack.contains('natural')) {
        score += 2;
      }
      if (haystack.contains('google') || haystack.contains('siri')) {
        score += 1;
      }

      if (score > bestScore) {
        bestScore = score;
        bestVoice = normalizedVoice;
      }
    }

    if (bestVoice != null) {
      await _flutterTts.setVoice(bestVoice);
    }
  }

  String _sanitizeForSpeech(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('â€¢', ', ')
        .replaceAll('...', '. ')
        .replaceAll('"', '')
        .trim();
  }

  double _normalizeSpeechRate(double rawRate) {
    if (kIsWeb) {
      return rawRate.clamp(0.35, 0.9);
    }

    return (rawRate * 0.58).clamp(0.25, 0.55);
  }

  String _stripLeadingCharacterPrefix(String text, String characterName) {
    final escapedName = RegExp.escape(characterName.trim());
    if (escapedName.isEmpty) {
      return text.trim();
    }

    final prefixPattern = RegExp(
      '^\\s*(?:$escapedName\\s*(?:says|said)?\\s*[:,-]?\\s*)+',
      caseSensitive: false,
    );

    return text.replaceFirst(prefixPattern, '').trim();
  }

  Future<void> stop() async {
    if (_isInitialized) {
      try {
        await _flutterTts.stop();
      } catch (e) {
        _lastError = 'TTS stop failed: $e';
      }
    }
  }

  bool get isInitialized => _isInitialized;
  String? get lastError => _lastError;

  void dispose() {
    if (_isInitialized) {
      _flutterTts.stop();
    }
  }
}
