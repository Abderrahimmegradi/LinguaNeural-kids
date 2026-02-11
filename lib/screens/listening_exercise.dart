import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import '../models/exercise.dart';
import '../services/audio_helper.dart';

class ListeningExercise extends StatefulWidget {
  final Exercise exercise;
  final Function(bool) onComplete;

  const ListeningExercise({
    super.key,
    required this.exercise,
    required this.onComplete,
  });

  @override
  State<ListeningExercise> createState() => _ListeningExerciseState();
}

class _ListeningExerciseState extends State<ListeningExercise> {
  bool _isPlaying = false;
  String? _selectedAnswer;
  bool _showFeedback = false;
  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _setupAudio();
  }

  void _setupAudio() {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  Future<void> _playAudio() async {
    if (_isPlaying) {
      await _player.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      setState(() {
        _isPlaying = true;
      });
      
      // Play the audio from assets
      try {
        if (widget.exercise.audioUrl != null) {
          await _player.setAsset('assets/audio/phrases/${widget.exercise.audioUrl}');
        } else {
          // Default to hello sound if no audio specified
          await _player.setAsset('assets/audio/phrases/hello.mp3');
        }
        await _player.play();
      } catch (e) {
        print('Error playing audio: $e');
        setState(() {
          _isPlaying = false;
        });
        // Play a beep as fallback
        AudioHelper.playClick();
      }
    }
  }

  void _checkAnswer() {
    setState(() {
      _showFeedback = true;
    });
    
    final isCorrect = _selectedAnswer == widget.exercise.correctAnswer;
    
    // Play feedback sound
    if (isCorrect) {
      AudioHelper.playCorrect();
    } else {
      AudioHelper.playWrong();
    }
    
    Future.delayed(const Duration(seconds: 2), () {
      widget.onComplete(isCorrect);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instruction
        Text(
          'Listening Exercise',
          style: GoogleFonts.nunitoSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A237E),
          ),
        ),
        
        const SizedBox(height: 10),
        
        Text(
          'Listen to the audio and select what you hear',
          style: GoogleFonts.nunitoSans(
            fontSize: 16,
            color: const Color(0xFF546E7A),
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Audio Player
        Container(
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
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isPlaying ? 70 : 50,
                height: _isPlaying ? 70 : 50,
                decoration: BoxDecoration(
                  color: _isPlaying 
                      ? const Color(0xFF66BB6A).withOpacity(0.2)
                      : const Color(0xFF1A237E).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  size: _isPlaying ? 40 : 30,
                  color: _isPlaying ? const Color(0xFF66BB6A) : const Color(0xFF1A237E),
                ),
              ),
              
              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _playAudio,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPlaying 
                        ? const Color(0xFFEF5350) 
                        : const Color(0xFF66BB6A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isPlaying ? Icons.pause : Icons.headphones,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _isPlaying ? 'Stop Audio' : 'Play Audio',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Audio Progress
              StreamBuilder<Duration?>(
                stream: _player.durationStream,
                builder: (context, snapshot) {
                  final duration = snapshot.data ?? Duration.zero;
                  return StreamBuilder<Duration>(
                    stream: _player.positionStream,
                    builder: (context, snapshot) {
                      var position = snapshot.data ?? Duration.zero;
                      if (position > duration) {
                        position = duration;
                      }
                      return SizedBox(
                        height: 20,
                        child: LinearProgressIndicator(
                          value: duration.inSeconds > 0 
                              ? position.inSeconds / duration.inSeconds 
                              : 0,
                          backgroundColor: Colors.grey[200],
                          color: const Color(0xFF66BB6A),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Options
        Column(
          children: widget.exercise.options!.map((option) {
            bool isCorrect = option == widget.exercise.correctAnswer;
            bool isSelected = option == _selectedAnswer;
            
            Color getColor() {
              if (!_showFeedback) {
                return isSelected ? const Color(0xFF1A237E) : Colors.grey[200]!;
              }
              if (isCorrect) return const Color(0xFF66BB6A);
              if (isSelected && !isCorrect) return const Color(0xFFEF5350);
              return Colors.grey[200]!;
            }
            
            return GestureDetector(
              onTap: _showFeedback ? null : () {
                AudioHelper.playClick();
                setState(() {
                  _selectedAnswer = option;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: getColor(),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF1A237E) : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 18,
                          color: _showFeedback ? Colors.white : const Color(0xFF1A237E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (_showFeedback)
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: Colors.white,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        
        const Spacer(),
        
        // Check Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedAnswer == null || _showFeedback ? null : _checkAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              disabledBackgroundColor: Colors.grey[400],
            ),
            child: Text(
              _showFeedback ? 'Continue' : 'Check Answer',
              style: GoogleFonts.nunitoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}