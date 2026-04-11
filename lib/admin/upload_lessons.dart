import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';

class UploadLessonsScreen extends StatefulWidget {
  const UploadLessonsScreen({super.key});

  @override
  State<UploadLessonsScreen> createState() => _UploadLessonsScreenState();
}

class _UploadLessonsScreenState extends State<UploadLessonsScreen> {
  final _firestoreService = FirestoreMvpService();
  bool _isBusy = false;
  String? _result;
  int _chapterCount = 0;
  int _unitCount = 0;
  int _lessonCount = 0;
  int _exerciseCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final chapters = await _firestoreService.getAllChapters();
    final units = await _firestoreService.getAllUnits();
    final lessons = await _firestoreService.getAllLessons();
    var exerciseCount = 0;
    for (final lesson in lessons) {
      final exercises =
          await _firestoreService.getExercisesForLesson(lesson.id);
      exerciseCount += exercises.length;
    }
    if (!mounted) return;
    setState(() {
      _chapterCount = chapters.length;
      _unitCount = units.length;
      _lessonCount = lessons.length;
      _exerciseCount = exerciseCount;
    });
  }

  Future<void> _runAction(
    Future<void> Function() action,
    String successMessage,
  ) async {
    setState(() {
      _isBusy = true;
      _result = null;
    });
    try {
      await action();
      await _loadCounts();
      if (!mounted) return;
      setState(() {
        _result = successMessage;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _confirmAndRun({
    required String title,
    required String message,
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _runAction(action, successMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Curriculum')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _isBusy
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Curriculum control',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Chapters: $_chapterCount | Units: $_unitCount | Lessons: $_lessonCount | Exercises: $_exerciseCount',
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Starter path: 5 chapters, 10 units, 30 lessons, and 120 game-style exercises ready for Firestore.',
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              ElevatedButton(
                                onPressed: () => _confirmAndRun(
                                  title: 'Upload starter curriculum?',
                                  message:
                                      'This will replace the current chapters, units, lessons, exercises, and lesson progress with the new game-style starter path.',
                                  action: () =>
                                      _firestoreService.uploadSeedCurriculum(
                                          initialCurriculumSeed),
                                  successMessage:
                                      'Starter curriculum uploaded successfully.',
                                ),
                                child: const Text('Upload starter curriculum'),
                              ),
                              OutlinedButton(
                                onPressed: () => _confirmAndRun(
                                  title: 'Clear lesson structure?',
                                  message:
                                      'This removes chapters, units, lessons, exercises, and lesson progress.',
                                  action: _firestoreService.clearLessons,
                                  successMessage: 'Lesson structure cleared.',
                                ),
                                child: const Text('Clear lesson structure'),
                              ),
                            ],
                          ),
                          if (_result != null) ...[
                            const SizedBox(height: 20),
                            Text(_result!),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
