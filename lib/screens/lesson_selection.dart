import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/english_lessons.dart';
import '../models/lesson.dart';
import 'lesson_screen.dart';
import '../providers/lesson_provider.dart';

class LessonSelectionScreen extends StatefulWidget {
  const LessonSelectionScreen({super.key});

  @override
  State<LessonSelectionScreen> createState() => _LessonSelectionScreenState();
}

class _LessonSelectionScreenState extends State<LessonSelectionScreen> {
  String _selectedCategory = 'Basics';

  @override
  Widget build(BuildContext context) {
    final lessonProvider = Provider.of<LessonProvider>(context);
    final categories = EnglishLessons.getAllCategories();
    final lessons = EnglishLessons.getLessonsByCategory(_selectedCategory);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF1A237E),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Learn English',
          style: GoogleFonts.nunitoSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A237E),
          ),
        ),
      ),
      body: Column(
        children: [
          // Category Selector
          Container(
            height: 70,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: ChoiceChip(
                    label: Text(
                      category,
                      style: GoogleFonts.nunitoSans(
                        color: isSelected ? Colors.white : const Color(0xFF546E7A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF1A237E),
                    backgroundColor: Colors.grey[200],
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          
          // Progress Header
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Progress',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        color: const Color(0xFF546E7A),
                      ),
                    ),
                    Text(
                      'Level 1 • $_selectedCategory',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A237E),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF66BB6A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFF9800),
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${lessonProvider.completedLessons * 50} XP',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A237E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Lessons List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                return LessonCardWidget(
                  lesson: lesson,
                  onTap: () {
                    if (!lesson.isLocked) {
                      lessonProvider.setCurrentLesson(lesson);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LessonScreen(lesson: lesson),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LessonCardWidget extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback onTap;

  const LessonCardWidget({
    super.key,
    required this.lesson,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
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
          border: lesson.isLocked
              ? Border.all(color: Colors.grey[300]!)
              : null,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: lesson.isLocked
                    ? Colors.grey[200]
                    : const Color(0xFF29B6F6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  lesson.icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            
            const SizedBox(width: 15),
            
            // Lesson Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        lesson.title,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: lesson.isLocked
                              ? Colors.grey[500]
                              : const Color(0xFF1A237E),
                        ),
                      ),
                      if (lesson.isLocked)
                        const Icon(
                          Icons.lock_outline,
                          color: Colors.grey,
                          size: 20,
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 5),
                  
                  Text(
                    lesson.description,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Progress and Info
                  Row(
                    children: [
                      // Level Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getLevelColor(lesson.level).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Level ${lesson.level}',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _getLevelColor(lesson.level),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 10),
                      
                      // Duration
                      Row(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            color: Colors.grey,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${lesson.duration} min',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(width: 10),
                      
                      // Skills Icons
                      Row(
                        children: lesson.skills.map((skill) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Icon(
                              _getSkillIcon(skill),
                              color: _getSkillColor(skill),
                              size: 16,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return const Color(0xFF66BB6A); // Green
      case 2:
        return const Color(0xFFFF9800); // Orange
      case 3:
        return const Color(0xFFAB47BC); // Purple
      default:
        return const Color(0xFF29B6F6); // Blue
    }
  }

  IconData _getSkillIcon(String skill) {
    switch (skill) {
      case 'listening':
        return Icons.headphones;
      case 'speaking':
        return Icons.mic;
      case 'reading':
        return Icons.menu_book;
      case 'writing':
        return Icons.edit;
      default:
        return Icons.check_circle;
    }
  }

  Color _getSkillColor(String skill) {
    switch (skill) {
      case 'listening':
        return const Color(0xFF66BB6A);
      case 'speaking':
        return const Color(0xFFFF9800);
      case 'reading':
        return const Color(0xFF29B6F6);
      case 'writing':
        return const Color(0xFFAB47BC);
      default:
        return Colors.grey;
    }
  }
}