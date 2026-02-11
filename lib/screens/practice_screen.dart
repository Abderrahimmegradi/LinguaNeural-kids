import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'daily_challenge_screen.dart';
import 'vocabulary_screen.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Practice & Play',
          style: GoogleFonts.nunitoSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A237E),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Daily Challenge Card
              _buildPracticeCard(
                context,
                icon: '🎯',
                title: 'Daily Challenge',
                description: 'Complete today\'s challenge and earn points',
                color: const Color(0xFF66BB6A),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DailyChallengeScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),

              // Vocabulary Flashcards
              _buildPracticeCard(
                context,
                icon: '📚',
                title: 'Vocabulary Review',
                description: 'Practice with interactive flashcards',
                color: const Color(0xFF29B6F6),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VocabularyScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),

              // Grammar Games
              _buildPracticeCard(
                context,
                icon: '🎮',
                title: 'Grammar Games',
                description: 'Learn grammar through fun games',
                color: const Color(0xFFFF9800),
              ),

              const SizedBox(height: 15),

              // Listening Practice
              _buildPracticeCard(
                context,
                icon: '👂',
                title: 'Listening Practice',
                description: 'Improve your listening skills',
                color: const Color(0xFFAB47BC),
              ),

              const SizedBox(height: 15),

              // Speaking Practice
              _buildPracticeCard(
                context,
                icon: '🎤',
                title: 'Speaking Practice',
                description: 'Pronounce words and phrases',
                color: const Color(0xFFEC407A),
              ),

              const SizedBox(height: 15),

              // Quick Quiz
              _buildPracticeCard(
                context,
                icon: '❓',
                title: 'Quick Quiz',
                description: 'Get instant feedback on your knowledge',
                color: const Color(0xFF26C6DA),
              ),

              const SizedBox(height: 30),

              // Tips Section
              Text(
                'Practice Tips',
                style: GoogleFonts.nunitoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A237E),
                ),
              ),

              const SizedBox(height: 12),

              _buildTipTile(
                icon: '⏰',
                title: 'Practice Daily',
                description: 'Spend 15-20 minutes daily for best results',
              ),

              const SizedBox(height: 10),

              _buildTipTile(
                icon: '🎯',
                title: 'Set Goals',
                description: 'Focus on one skill at a time',
              ),

              const SizedBox(height: 10),

              _buildTipTile(
                icon: '🔄',
                title: 'Review Regularly',
                description: 'Revisit lessons you\'ve already learned',
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPracticeCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 13,
                      color: const Color(0xFF546E7A),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipTile({
    required String icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12,
                    color: const Color(0xFF546E7A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}