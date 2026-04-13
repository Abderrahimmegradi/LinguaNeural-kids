import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

import '../models/character.dart';

class AudioPlaybackResult {
  const AudioPlaybackResult({
    required this.usedFallback,
    required this.producedAudio,
  });

  final bool usedFallback;
  final bool producedAudio;
}

enum FeedbackCue {
  optionSelected,
  correctAnswer,
  incorrectAnswer,
  reward,
  celebration,
  gentlePrompt,
}

class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  AudioPlayer? _audioPlayer;
  AudioPlayer? _feedbackPlayer;
  FlutterTts? _tts;
  SpeechToText? _speech;
  List<dynamic>? _availableVoices;
  final Map<String, Map<String, String>?> _voiceSelectionCache = {};

  bool _speechReady = false;
  String _latestSpokenWords = '';

  bool get isListening => _speech?.isListening ?? false;

  Future<AudioPlaybackResult> play({String? source, String? fallbackText}) async {
    await stop();

    final normalizedSource = source?.trim();
    if (_isSupportedAudioUrl(normalizedSource)) {
      try {
        final audioPlayer = _ensureAudioPlayer();
        await audioPlayer.setUrl(normalizedSource!);
        await audioPlayer.play();
        return const AudioPlaybackResult(usedFallback: false, producedAudio: true);
      } catch (_) {
        final usedFallback = await _speakPromptFallback(fallbackText);
        return AudioPlaybackResult(usedFallback: usedFallback, producedAudio: usedFallback);
      }
    }

    final usedFallback = await _speakPromptFallback(fallbackText);
    return AudioPlaybackResult(usedFallback: usedFallback, producedAudio: usedFallback);
  }

  Future<void> stop() async {
    await _audioPlayer?.stop();
    await _feedbackPlayer?.stop();
    await _tts?.stop();
  }

  Future<void> playFeedbackCue(FeedbackCue cue) async {
    if (cue == FeedbackCue.optionSelected) {
      await HapticFeedback.selectionClick();
      return;
    }

    final assetPath = switch (cue) {
      FeedbackCue.optionSelected => 'assets/audio/feedback/select.wav',
      FeedbackCue.correctAnswer => 'assets/audio/feedback/correct.wav',
      FeedbackCue.incorrectAnswer => 'assets/audio/feedback/wrong.wav',
      FeedbackCue.reward => 'assets/audio/feedback/reward.wav',
      FeedbackCue.celebration => 'assets/audio/feedback/celebration.wav',
      FeedbackCue.gentlePrompt => 'assets/audio/feedback/prompt.wav',
    };

    switch (cue) {
      case FeedbackCue.correctAnswer:
        await HapticFeedback.lightImpact();
      case FeedbackCue.incorrectAnswer:
        await HapticFeedback.mediumImpact();
      case FeedbackCue.reward:
        await HapticFeedback.mediumImpact();
      case FeedbackCue.celebration:
        await HapticFeedback.heavyImpact();
      case FeedbackCue.gentlePrompt:
        await HapticFeedback.selectionClick();
      case FeedbackCue.optionSelected:
        return;
    }

    try {
      final feedbackPlayer = _ensureFeedbackPlayer();
      await feedbackPlayer.stop();
      await feedbackPlayer.setVolume(1.0);
      await feedbackPlayer.setAsset(assetPath);
      await feedbackPlayer.play();
    } catch (_) {
      await SystemSound.play(
        cue == FeedbackCue.incorrectAnswer || cue == FeedbackCue.gentlePrompt
            ? SystemSoundType.alert
            : SystemSoundType.click,
      );
    }
  }

  Future<void> speakCharacterLine({
    required Character character,
    required String text,
    String? emotion,
  }) async {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      return;
    }

    await _audioPlayer?.stop();
    final tts = _ensureTts();
    await tts.stop();

    final profile = _voiceProfileFor(character, emotion);
    await _applyCharacterVoice(tts, character);
    await tts.setSpeechRate(profile.speechRate);
    await tts.setPitch(profile.pitch);
    await tts.setVolume(1.0);
    await tts.speak(normalized);
  }

  Future<bool> startListening({
    required void Function(String words) onWords,
    void Function(String status)? onStatus,
    void Function(String message)? onError,
  }) async {
    final speech = _ensureSpeech();

    if (!_speechReady) {
      _speechReady = await speech.initialize(
        onStatus: onStatus,
        onError: (SpeechRecognitionError error) {
          onError?.call(error.errorMsg);
        },
      );
    }

    if (!_speechReady) {
      return false;
    }

    _latestSpokenWords = '';
    await speech.listen(
      onResult: (SpeechRecognitionResult result) {
        _latestSpokenWords = result.recognizedWords;
        onWords(result.recognizedWords);
      },
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
      ),
      listenFor: const Duration(seconds: 12),
      pauseFor: const Duration(seconds: 4),
      localeId: 'en_US',
    );

    return true;
  }

  Future<String> stopListening() async {
    final speech = _speech;
    if (speech != null && speech.isListening) {
      await speech.stop();
    }
    return _latestSpokenWords;
  }

  Future<void> dispose() async {
    await _audioPlayer?.dispose();
    await _tts?.stop();
    await _speech?.cancel();
  }

  AudioPlayer _ensureAudioPlayer() {
    return _audioPlayer ??= AudioPlayer();
  }

  AudioPlayer _ensureFeedbackPlayer() {
    return _feedbackPlayer ??= AudioPlayer();
  }

  FlutterTts _ensureTts() {
    return _tts ??= FlutterTts();
  }

  SpeechToText _ensureSpeech() {
    return _speech ??= SpeechToText();
  }

  bool _isSupportedAudioUrl(String? source) {
    if (source == null || source.isEmpty) {
      return false;
    }

    final uri = Uri.tryParse(source);
    if (uri == null || !uri.hasScheme) {
      return false;
    }

    return uri.scheme == 'http' || uri.scheme == 'https';
  }

  Future<bool> _speakPromptFallback(String? fallbackText) async {
    final text = fallbackText?.trim();
    if (text == null || text.isEmpty) {
      return false;
    }

    final tts = _ensureTts();
    await _audioPlayer?.stop();
    await tts.stop();
    await tts.setLanguage('en-US');
    await tts.setSpeechRate(0.42);
    await tts.setPitch(1.0);
    await tts.setVolume(1.0);
    await tts.speak(text);
    return true;
  }

  Future<void> _applyCharacterVoice(FlutterTts tts, Character character) async {
    const defaultLocale = 'en-US';
    try {
      _availableVoices ??= await tts.getVoices;
      final selectedVoice = _voiceSelectionCache.putIfAbsent(
        character.id,
        () => _pickVoice(character, _availableVoices ?? const []),
      );

      if (selectedVoice != null) {
        final locale = selectedVoice['locale'];
        if (locale != null && locale.isNotEmpty) {
          await tts.setLanguage(locale);
        } else {
          await tts.setLanguage(defaultLocale);
        }
        await tts.setVoice(selectedVoice);
        return;
      }
    } catch (_) {
      // Fall back to profile-only voice shaping when platform voices are unavailable.
    }

    await tts.setLanguage(defaultLocale);
  }

  Map<String, String>? _pickVoice(Character character, List<dynamic> rawVoices) {
    final voices = rawVoices
        .whereType<Map>()
        .map<Map<String, String>?>((voice) {
          final name = voice['name']?.toString();
          final locale = voice['locale']?.toString();
          if (name == null || locale == null) {
            return null;
          }
          return {
            'name': name,
            'locale': locale,
          };
        })
        .whereType<Map<String, String>>()
        .toList(growable: false);

    if (voices.isEmpty) {
      return null;
    }

    final englishVoices = voices.where((voice) {
      final locale = (voice['locale'] ?? '').toLowerCase();
      return locale.startsWith('en');
    }).toList(growable: false);
    final searchSpace = englishVoices.isNotEmpty ? englishVoices : voices;

    final preferredTokens = switch (character.id) {
      'baby' => const ['child', 'kid', 'girl', 'female', 'ava', 'samantha', 'aria'],
      'lumi' => const ['female', 'girl', 'ava', 'samantha', 'aria', 'allison', 'emma'],
      'nexo' => const ['robot', 'synth', 'network', 'wavenet', 'studio', 'x-', 'io'],
      'owl' => const ['male', 'guy', 'daniel', 'david', 'thomas', 'george'],
      _ => const <String>[],
    };

    for (final token in preferredTokens) {
      for (final voice in searchSpace) {
        final name = (voice['name'] ?? '').toLowerCase();
        if (name.contains(token)) {
          return voice;
        }
      }
    }

    if (character.id == 'owl') {
      final nonFemaleVoice = searchSpace.firstWhere(
        (voice) => !(voice['name'] ?? '').toLowerCase().contains('female'),
        orElse: () => searchSpace.first,
      );
      return nonFemaleVoice;
    }

    return searchSpace.first;
  }

  _VoiceProfile _voiceProfileFor(Character character, String? emotion) {
    final normalizedEmotion = emotion?.toLowerCase();
    final softened = normalizedEmotion == 'needs_support' || normalizedEmotion == 'frustrated';

    return switch (character.id) {
      'baby' => _VoiceProfile(
          speechRate: softened ? 0.34 : 0.38,
          pitch: softened ? 1.38 : 1.48,
        ),
      'nexo' => _VoiceProfile(
          speechRate: softened ? 0.35 : 0.4,
          pitch: 0.82,
        ),
      'owl' => _VoiceProfile(
          speechRate: softened ? 0.34 : 0.38,
          pitch: 0.72,
        ),
      _ => _VoiceProfile(
          speechRate: softened ? 0.39 : 0.44,
          pitch: 1.18,
        ),
    };
  }
}

class _VoiceProfile {
  const _VoiceProfile({
    required this.speechRate,
    required this.pitch,
  });

  final double speechRate;
  final double pitch;
}