import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  int _selectedAnswer = -1;
  bool _answered = false;
  int _correctCount = 0;
  final int _totalChallenges = 5;
  int _currentChallenge = 0;

  final List<Challenge> challenges = [
    Challenge(
      question: 'What does "Hello" mean in French?',
      options: ['Au revoir', 'Bonjour', 'Merci', 'S\'il vous plaît'],
      correctIndex: 1,
      explanation: 'Bonjour is the French word for hello or good day.',
      points: 10,
    ),
    Challenge(
      question: 'How do you say "Thank you" in English?',
      options: ['Please', 'Thank you', 'Goodbye', 'Sorry'],
      correctIndex: 1,
      explanation: '"Thank you" is used to express gratitude.',
      points: 10,
    ),
    Challenge(
      question: 'Which number comes after 5?',
      options: ['Four', 'Five', 'Six', 'Seven'],
      correctIndex: 2,
      explanation: 'Six (6) comes after five (5).',
      points: 10,
    ),
    Challenge(
      question: 'What is the English word for "Eau"?',
      options: ['Food', 'Water', 'Family', 'Friend'],
      correctIndex: 1,
      explanation: 'Eau is the French word for water.',
      points: 10,
    ),
    Challenge(
      question: 'What color is associated with danger?',
      options: ['Blue', 'Green', 'Red', 'Yellow'],
      correctIndex: 2,
      explanation: 'Red is commonly associated with danger or warning.',
      points: 10,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final challenge = challenges[_currentChallenge];
    final isCompleted = _currentChallenge >= _totalChallenges;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Daily Challenge',
          style: GoogleFonts.nunitoSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A237E),
          ),
        ),
      ),
      body: isCompleted
          ? _buildCompletionScreen()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF66BB6A),
                            Color(0xFF29B6F6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Challenge ${_currentChallenge + 1}/$_totalChallenges',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${challenge.points} Points',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '🎯',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 40,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (_currentChallenge) / _totalChallenges,
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF29B6F6),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Question
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        challenge.question,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A237E),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Options
                    Column(
                      children: List.generate(
                        challenge.options.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildOptionButton(
                            option: challenge.options[index],
                            index: index,
                            challenge: challenge,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Explanation (if answered)
                    if (_answered)
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: _selectedAnswer == challenge.correctIndex
                              ? const Color(0xFF66BB6A).withOpacity(0.1)
                              : const Color(0xFFFF6B6B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: _selectedAnswer == challenge.correctIndex
                                ? const Color(0xFF66BB6A)
                                : const Color(0xFFFF6B6B),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _selectedAnswer == challenge.correctIndex
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: _selectedAnswer == challenge.correctIndex
                                      ? const Color(0xFF66BB6A)
                                      : const Color(0xFFFF6B6B),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _selectedAnswer == challenge.correctIndex
                                      ? 'Correct!'
                                      : 'Incorrect',
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: _selectedAnswer == challenge.correctIndex
                                        ? const Color(0xFF66BB6A)
                                        : const Color(0xFFFF6B6B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              challenge.explanation,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 14,
                                color: const Color(0xFF546E7A),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 30),

                    // Next Button
                    if (_answered)
                      ElevatedButton(
                        onPressed: _goToNextChallenge,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF29B6F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          _currentChallenge == _totalChallenges - 1
                              ? 'Finish'
                              : 'Next Challenge',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOptionButton({
    required String option,
    required int index,
    required Challenge challenge,
  }) {
    final isSelected = _selectedAnswer == index;
    final isCorrect = index == challenge.correctIndex;
    final showResult = _answered;

    Color backgroundColor;
    Color textColor;
    if (!showResult) {
      backgroundColor = Colors.white;
      textColor = const Color(0xFF1A237E);
    } else if (isCorrect) {
      backgroundColor = const Color(0xFF66BB6A).withOpacity(0.2);
      textColor = const Color(0xFF66BB6A);
    } else if (isSelected && !isCorrect) {
      backgroundColor = const Color(0xFFFF6B6B).withOpacity(0.2);
      textColor = const Color(0xFFFF6B6B);
    } else {
      backgroundColor = Colors.white;
      textColor = const Color(0xFF546E7A);
    }

    return GestureDetector(
      onTap: _answered
          ? null
          : () {
              setState(() {
                _selectedAnswer = index;
                _answered = true;
                if (index == challenge.correctIndex) {
                  _correctCount++;
                }
              });
            },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected && showResult
                ? textColor
                : Colors.grey.withOpacity(0.2),
            width: isSelected && showResult ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected && !showResult)
              BoxShadow(
                color: const Color(0xFF29B6F6).withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isSelected && !showResult
                    ? const Color(0xFF29B6F6)
                    : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected && !showResult ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                option,
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            if (showResult && isCorrect)
              const Icon(Icons.check_circle, color: Color(0xFF66BB6A)),
            if (showResult && isSelected && !isCorrect)
              const Icon(Icons.cancel, color: Color(0xFFFF6B6B)),
          ],
        ),
      ),
    );
  }

  void _goToNextChallenge() {
    setState(() {
      _currentChallenge++;
      _selectedAnswer = -1;
      _answered = false;
    });
  }

  Widget _buildCompletionScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF66BB6A).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration,
                size: 100,
                color: Color(0xFF66BB6A),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Challenge Complete! 🎉',
              style: GoogleFonts.nunitoSans(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Your Score',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      color: const Color(0xFF546E7A),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    '$_correctCount/$_totalChallenges',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 60,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Points Earned: ${_correctCount * 10}',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentChallenge = 0;
                  _selectedAnswer = -1;
                  _answered = false;
                  _correctCount = 0;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF29B6F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Try Again Tomorrow',
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Challenge {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final int points;

  Challenge({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.points,
  });
}
