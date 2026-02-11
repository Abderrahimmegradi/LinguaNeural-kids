import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../services/speech_service.dart';
import '../services/audio_helper.dart';

class SpeakingExercise extends StatefulWidget {
  final Exercise exercise;
  final Function(bool) onComplete;

  const SpeakingExercise({
    super.key,
    required this.exercise,
    required this.onComplete,
  });

  @override
  State<SpeakingExercise> createState() => _SpeakingExerciseState();
}

class _SpeakingExerciseState extends State<SpeakingExercise> {
  bool _isRecording = false;
  bool _showFeedback = false;
  String _userResponse = '';
  String _targetText = '';
  String _feedbackMessage = '';
  Color _feedbackColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _targetText = widget.exercise.question.toLowerCase();
  }

  Future<void> _startRecording() async {
    final speechService = Provider.of<SpeechService>(context, listen: false);
    
    if (!speechService.isAvailable) {
      await speechService.initialize();
    }

    setState(() {
      _isRecording = true;
      _showFeedback = false;
      _userResponse = '';
      _feedbackMessage = '';
    });

    // Start listening
    await speechService.startListening();
    
    // Wait for 5 seconds to get speech result
    await Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _isRecording = false;
        _userResponse = speechService.lastWords;
        _checkPronunciation();
      });
    });
  }

  void _checkPronunciation() {
    final userText = _userResponse.toLowerCase();
    final targetText = _targetText.toLowerCase();
    
    bool isCorrect = false;
    String feedback = '';
    
    if (userText.isEmpty) {
      feedback = 'Try speaking louder. I couldn\'t hear you!';
      AudioHelper.playWrong();
    } else if (userText.contains(targetText) || 
               targetText.contains(userText) ||
               _calculateSimilarity(userText, targetText) > 0.6) {
      isCorrect = true;
      feedback = 'Excellent! Perfect pronunciation! 🎉';
      _feedbackColor = const Color(0xFF66BB6A);
      AudioHelper.playCorrect();
    } else {
      feedback = 'Almost there! Try again: $targetText';
      _feedbackColor = const Color(0xFFFF9800);
      AudioHelper.playWrong();
    }
    
    setState(() {
      _showFeedback = true;
      _feedbackMessage = feedback;
    });
    
    // Continue after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      widget.onComplete(isCorrect);
    });
  }

  double _calculateSimilarity(String text1, String text2) {
    if (text1.isEmpty || text2.isEmpty) return 0.0;
    
    final words1 = text1.split(' ');
    final words2 = text2.split(' ');
    
    int matches = 0;
    for (final word1 in words1) {
      for (final word2 in words2) {
        if (word1 == word2) {
          matches++;
          break;
        }
      }
    }
    
    return matches / words2.length;
  }

  Future<void> _playExample() async {
    await AudioHelper.playPhrase(widget.exercise.question);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instruction
        Text(
          'Speaking Exercise',
          style: GoogleFonts.nunitoSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A237E),
          ),
        ),
        
        const SizedBox(height: 10),
        
        Text(
          'Repeat the phrase after the audio',
          style: GoogleFonts.nunitoSans(
            fontSize: 16,
            color: const Color(0xFF546E7A),
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Target Phrase
        GestureDetector(
          onTap: _playExample,
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.volume_up,
                  size: 40,
                  color: Color(0xFF66BB6A),
                ),
                
                const SizedBox(height: 20),
                
                Text(
                  widget.exercise.question,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A237E),
                  ),
                ),
                
                const SizedBox(height: 10),
                
                Text(
                  'Tap to listen',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14,
                    color: const Color(0xFF546E7A),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Recording Section
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Microphone
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isRecording ? 180 : 150,
                height: _isRecording ? 180 : 150,
                decoration: BoxDecoration(
                  color: _isRecording
                      ? const Color(0xFFFF9800).withOpacity(0.2)
                      : Colors.grey[200],
                  shape: BoxShape.circle,
                  boxShadow: _isRecording
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFF9800).withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  Icons.mic,
                  size: _isRecording ? 80 : 60,
                  color: _isRecording ? const Color(0xFFFF9800) : Colors.grey,
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Recording Status
              Text(
                _isRecording ? 'Recording... Speak now!' : 'Tap to start recording',
                style: GoogleFonts.nunitoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A237E),
                ),
              ),
              
              const SizedBox(height: 10),
              
              // User Response
              if (_userResponse.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      'You said: "$_userResponse"',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16,
                        color: const Color(0xFF546E7A),
                      ),
                    ),
                  ),
                ),
              
              if (_showFeedback && _feedbackMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: _feedbackColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: _feedbackColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _feedbackColor == const Color(0xFF66BB6A)
                              ? Icons.check_circle
                              : Icons.info_outline,
                          color: _feedbackColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _feedbackMessage,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 14,
                              color: const Color(0xFF1A237E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 30),
              
              // Record Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isRecording ? null : _startRecording,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording
                        ? Colors.grey[400]
                        : const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _isRecording ? 'Recording...' : 'Start Recording',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}