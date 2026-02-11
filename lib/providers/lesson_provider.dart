import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../data/english_lessons.dart';

class LessonProvider extends ChangeNotifier {
  List<Lesson> _lessons = [];
  String _selectedCategory = 'Basics';
  Lesson? _currentLesson;
  int _completedLessons = 1;

  LessonProvider() {
    _loadLessons();
  }

  List<Lesson> get lessons => _lessons;
  String get selectedCategory => _selectedCategory;
  Lesson? get currentLesson => _currentLesson;
  int get completedLessons => _completedLessons;

  void _loadLessons() {
    _lessons = EnglishLessons.allLessons;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setCurrentLesson(Lesson lesson) {
    _currentLesson = lesson;
    notifyListeners();
  }

  void completeLesson(String lessonId) {
    final index = _lessons.indexWhere((lesson) => lesson.id == lessonId);
    if (index != -1) {
      _lessons[index] = Lesson(
        id: _lessons[index].id,
        title: _lessons[index].title,
        description: _lessons[index].description,
        category: _lessons[index].category,
        level: _lessons[index].level,
        duration: _lessons[index].duration,
        progress: 1.0,
        isLocked: false,
        skills: _lessons[index].skills,
        icon: _lessons[index].icon,
      );
      _completedLessons++;
      notifyListeners();
    }
  }

  List<Lesson> getLessonsByCategory(String category) {
    return _lessons.where((lesson) => lesson.category == category).toList();
  }

  void unlockNextLesson() {
    final lockedLessons = _lessons.where((lesson) => lesson.isLocked).toList();
    if (lockedLessons.isNotEmpty) {
      final nextLessonIndex = _lessons.indexWhere(
        (lesson) => lesson.id == lockedLessons.first.id,
      );
      if (nextLessonIndex != -1) {
        _lessons[nextLessonIndex] = Lesson(
          id: _lessons[nextLessonIndex].id,
          title: _lessons[nextLessonIndex].title,
          description: _lessons[nextLessonIndex].description,
          category: _lessons[nextLessonIndex].category,
          level: _lessons[nextLessonIndex].level,
          duration: _lessons[nextLessonIndex].duration,
          progress: 0.0,
          isLocked: false,
          skills: _lessons[nextLessonIndex].skills,
          icon: _lessons[nextLessonIndex].icon,
        );
        notifyListeners();
      }
    }
  }
}