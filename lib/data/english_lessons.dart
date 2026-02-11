import '../models/lesson.dart';
import '../models/exercise.dart';

class EnglishLessons {
  static final List<Lesson> allLessons = [
    // Level 1: Basics
    Lesson(
      id: 'basics_1',
      title: 'Greetings',
      description: 'Learn basic greetings and introductions',
      category: 'Basics',
      level: 1,
      duration: 10,
      progress: 0.0,
      isLocked: false,
      skills: ['listening', 'speaking'],
      icon: '👋',
    ),
    Lesson(
      id: 'basics_2',
      title: 'Numbers 1-20',
      description: 'Count from 1 to 20',
      category: 'Basics',
      level: 1,
      duration: 15,
      progress: 0.0,
      isLocked: true,
      skills: ['listening', 'speaking'],
      icon: '🔢',
    ),
    Lesson(
      id: 'basics_3',
      title: 'Colors',
      description: 'Learn basic colors',
      category: 'Basics',
      level: 1,
      duration: 12,
      progress: 0.0,
      isLocked: true,
      skills: ['reading', 'writing'],
      icon: '🎨',
    ),

    // Level 2: Everyday
    Lesson(
      id: 'everyday_1',
      title: 'Family',
      description: 'Family members and relationships',
      category: 'Everyday',
      level: 2,
      duration: 20,
      progress: 0.0,
      isLocked: true,
      skills: ['listening', 'speaking', 'reading'],
      icon: '👨‍👩‍👧‍👦',
    ),
    Lesson(
      id: 'everyday_2',
      title: 'Food & Drinks',
      description: 'Common foods and beverages',
      category: 'Everyday',
      level: 2,
      duration: 25,
      progress: 0.0,
      isLocked: true,
      skills: ['listening', 'speaking', 'reading'],
      icon: '🍎',
    ),

    // Level 3: Conversation
    Lesson(
      id: 'conversation_1',
      title: 'At School',
      description: 'School-related vocabulary',
      category: 'Conversation',
      level: 3,
      duration: 30,
      progress: 0.0,
      isLocked: true,
      skills: ['listening', 'speaking', 'reading', 'writing'],
      icon: '🏫',
    ),
    Lesson(
      id: 'conversation_2',
      title: 'Daily Routine',
      description: 'Talk about your daily activities',
      category: 'Conversation',
      level: 3,
      duration: 35,
      progress: 0.0,
      isLocked: true,
      skills: ['listening', 'speaking', 'reading', 'writing'],
      icon: '⏰',
    ),
  ];

  static List<Exercise> getExercisesForLesson(String lessonId) {
    switch (lessonId) {
      case 'basics_1': // Greetings
        return [
          // Multiple Choice
          Exercise(
            id: '1',
            type: 'multiple_choice',
            question: 'How do you say "Hello" in English?',
            options: ['Bonjour', 'Hola', 'Hello', 'Ciao'],
            correctAnswer: 'Hello',
            points: 10,
            hint: 'Think about the most common greeting',
          ),
          
          // Listening
          Exercise(
            id: '2',
            type: 'listening',
            question: 'Hello',
            options: ['Hello', 'Goodbye', 'Thank you', 'Please'],
            audioUrl: 'hello.mp3',
            correctAnswer: 'Hello',
            points: 15,
            hint: 'Listen carefully to the audio',
          ),
          
          // Speaking
          Exercise(
            id: '3',
            type: 'speaking',
            question: 'Hello, how are you?',
            correctAnswer: 'hello how are you',
            points: 20,
            hint: 'Speak clearly and slowly',
          ),
          
          // Matching
          Exercise(
            id: '4',
            type: 'multiple_choice',
            question: 'Which word means "goodbye"?',
            options: ['Hello', 'Goodbye', 'Thank you', 'Please'],
            correctAnswer: 'Goodbye',
            points: 10,
            hint: 'What do you say when leaving?',
          ),
          
          // Fill in the blank
          Exercise(
            id: '5',
            type: 'multiple_choice',
            question: 'Complete: "___ morning!"',
            options: ['Good', 'Bad', 'Hello', 'Hi'],
            correctAnswer: 'Good',
            points: 15,
            hint: 'What do you say in the morning?',
          ),
        ];

      case 'basics_2': // Numbers 1-20
        return [
          Exercise(
            id: '1',
            type: 'multiple_choice',
            question: 'What is "five" in numbers?',
            options: ['3', '5', '7', '9'],
            correctAnswer: '5',
            points: 10,
            hint: 'Count from 1 to 5',
          ),
          
          Exercise(
            id: '2',
            type: 'listening',
            question: 'Five',
            options: ['Three', 'Four', 'Five', 'Six'],
            audioUrl: 'five.mp3',
            correctAnswer: 'Five',
            points: 15,
            hint: 'Listen for the number',
          ),
          
          Exercise(
            id: '3',
            type: 'speaking',
            question: 'Say the numbers from 1 to 5',
            correctAnswer: 'one two three four five',
            points: 25,
            hint: 'Count slowly: one, two, three...',
          ),
        ];

      default:
        return [
          Exercise(
            id: '1',
            type: 'multiple_choice',
            question: 'Sample question for $lessonId',
            options: ['Option A', 'Option B', 'Option C', 'Option D'],
            correctAnswer: 'Option A',
            points: 10,
            hint: 'This is a sample exercise',
          ),
        ];
    }
  }

  static List<Lesson> getLessonsByCategory(String category) {
    return allLessons.where((lesson) => lesson.category == category).toList();
  }

  static List<String> getAllCategories() {
    return allLessons.map((lesson) => lesson.category).toSet().toList();
  }
}