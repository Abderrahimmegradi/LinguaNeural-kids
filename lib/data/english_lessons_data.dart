import '../models/english_lesson_model.dart';

final List<EnglishLesson> allEnglishLessons = [
  // A1 LEVEL LESSONS
  EnglishLesson(
    id: 'a1_greeting',
    title: 'Greetings',
    titleArabic: 'التحيات',
    description: 'Learn basic greetings and how to say hello',
    descriptionArabic: 'تعلم التحيات الأساسية وكيفية قول مرحبا',
    level: 'A1',
    order: 1,
    category: 'Greetings',
    categoryArabic: 'التحيات',
    units: [
      LessonUnit(
        id: 'a1_greeting_vocab',
        type: 'vocabulary',
        exercises: [
          Exercise(
            id: 'ex1',
            question: 'What does "Hello" mean?',
            questionArabic: 'ماذا تعني كلمة "Hello"؟',
            type: 'multipleChoice',
            options: [
              ExerciseOption(
                id: 'opt1',
                text: 'مرحبا',
                textArabic: 'مرحبا',
                isCorrect: true,
              ),
              ExerciseOption(
                id: 'opt2',
                text: 'وداعا',
                textArabic: 'وداعا',
                isCorrect: false,
              ),
              ExerciseOption(
                id: 'opt3',
                text: 'شكرا',
                textArabic: 'شكرا',
                isCorrect: false,
              ),
              ExerciseOption(
                id: 'opt4',
                text: 'من فضلك',
                textArabic: 'من فضلك',
                isCorrect: false,
              ),
            ],
            explanation: 'Hello is used as a greeting to say hi to someone',
            explanationArabic: 'Hello تُستخدم كتحية للقول مرحبا لأحد ما',
            xpReward: 10,
          ),
          Exercise(
            id: 'ex2',
            question: 'What does "Good morning" mean?',
            questionArabic: 'ماذا تعني "Good morning"؟',
            type: 'multipleChoice',
            options: [
              ExerciseOption(
                id: 'opt1',
                text: 'صباح الخير',
                textArabic: 'صباح الخير',
                isCorrect: true,
              ),
              ExerciseOption(
                id: 'opt2',
                text: 'مساء الخير',
                textArabic: 'مساء الخير',
                isCorrect: false,
              ),
              ExerciseOption(
                id: 'opt3',
                text: 'ليلة سعيدة',
                textArabic: 'ليلة سعيدة',
                isCorrect: false,
              ),
              ExerciseOption(
                id: 'opt4',
                text: 'كيف حالك',
                textArabic: 'كيف حالك',
                isCorrect: false,
              ),
            ],
            explanation: 'Good morning is said in the morning hours',
            explanationArabic: 'Good morning تُقال في ساعات الصباح',
            xpReward: 10,
          ),
          Exercise(
            id: 'ex3',
            question: 'What does "Goodbye" mean?',
            questionArabic: 'ماذا تعني كلمة "Goodbye"؟',
            type: 'multipleChoice',
            options: [
              ExerciseOption(
                id: 'opt1',
                text: 'مرحبا',
                textArabic: 'مرحبا',
                isCorrect: false,
              ),
              ExerciseOption(
                id: 'opt2',
                text: 'وداعا',
                textArabic: 'وداعا',
                isCorrect: true,
              ),
              ExerciseOption(
                id: 'opt3',
                text: 'شكرا لك',
                textArabic: 'شكرا لك',
                isCorrect: false,
              ),
              ExerciseOption(
                id: 'opt4',
                text: 'أنا بخير',
                textArabic: 'أنا بخير',
                isCorrect: false,
              ),
            ],
            explanation: 'Goodbye is said when leaving or parting',
            explanationArabic: 'Goodbye تُقال عند المغادرة أو الوداع',
            xpReward: 10,
          ),
        ],
      ),
    ],
  ),
  EnglishLesson(
    id: 'a1_numbers',
    title: 'Numbers 1-10',
    titleArabic: 'الأرقام من 1 إلى 10',
    description: 'Learn to count from 1 to 10 in English',
    descriptionArabic: 'تعلم العد من 1 إلى 10 باللغة الإنجليزية',
    level: 'A1',
    order: 2,
    category: 'Numbers',
    categoryArabic: 'الأرقام',
    units: [
      LessonUnit(
        id: 'a1_numbers_vocab',
        type: 'vocabulary',
        exercises: [
          Exercise(
            id: 'ex1',
            question: 'What is the number 1 in English?',
            questionArabic: 'ما هو الرقم 1 باللغة الإنجليزية؟',
            type: 'multipleChoice',
            options: [
              ExerciseOption(
                id: 'opt1',
                text: 'One',
                textArabic: 'واحد',
                isCorrect: true,
              ),
              ExerciseOption(
                id: 'opt2',
                text: 'Two',
                textArabic: 'اثنان',
                isCorrect: false,
              ),
              ExerciseOption(
                id: 'opt3',
                text: 'Three',
                textArabic: 'ثلاثة',
                isCorrect: false,
              ),
              ExerciseOption(
                id: 'opt4',
                text: 'Zero',
                textArabic: 'صفر',
                isCorrect: false,
              ),
            ],
            explanation: 'One (1) is the first counting number',
            explanationArabic: 'One (1) هو الرقم الأول في العد',
            xpReward: 10,
          ),
          Exercise(
            id: 'ex2',
            question: 'What is the number 5 in English?',
            questionArabic: 'ما هو الرقم 5 باللغة الإنجليزية؟',
            type: 'multipleChoice',
            options: [
              ExerciseOption(
                id: 'opt1',
                text: 'Four',
                textArabic: 'أربعة',
                isCorrect: false,
              ),
              ExerciseOption(
                id: 'opt2',
                text: 'Five',
                textArabic: 'خمسة',
                isCorrect: true,
              ),
              ExerciseOption(
                id: 'opt3',
                text: 'Six',
                textArabic: 'ستة',
                isCorrect: false,
              ),
              ExerciseOption(
                id: 'opt4',
                text: 'Seven',
                textArabic: 'سبعة',
                isCorrect: false,
              ),
            ],
            explanation: 'Five (5) comes after four',
            explanationArabic: 'Five (5) تأتي بعد أربعة',
            xpReward: 10,
          ),
        ],
      ),
    ],
  ),
  EnglishLesson(
    id: 'a1_polite_words',
    title: 'Polite Words',
    titleArabic: 'الكلمات المهذبة',
    description: 'Please, Thank you, Sorry - essential polite expressions',
    descriptionArabic: 'من فضلك، شكرا، آسف - تعابير مهذبة أساسية',
    level: 'A1',
    order: 3,
    category: 'Polite',
    categoryArabic: 'مهذبة',
    units: [
      LessonUnit(
        id: 'a1_polite_vocab',
        type: 'vocabulary',
        exercises: [
          Exercise(
            id: 'ex1',
            question: 'What is the polite way to ask for something?',
            questionArabic: 'ما هي الطريقة المهذبة للطلب؟',
            type: 'multipleChoice',
            options: [
              ExerciseOption(
                id: 'opt1',
                text: 'Please',
                textArabic: 'من فضلك',
                isCorrect: true,
              ),
              ExerciseOption(
                id: 'opt2',
                text: 'Thank you',
                textArabic: 'شكرا',
                isCorrect: false,
              ),
              ExerciseOption(
                id: 'opt3',
                text: 'Sorry',
                textArabic: 'آسف',
                isCorrect: false,
              ),
              ExerciseOption(
                id: 'opt4',
                text: 'Goodbye',
                textArabic: 'وداعا',
                isCorrect: false,
              ),
            ],
            explanation: 'Please is used to politely request something',
            explanationArabic: 'Please تُستخدم للطلب بشكل مهذب',
            xpReward: 10,
          ),
          Exercise(
            id: 'ex2',
            question: 'How do you express gratitude?',
            questionArabic: 'كيف تعبر عن الامتنان؟',
            type: 'multipleChoice',
            options: [
              ExerciseOption(
                id: 'opt1',
                text: 'Thank you',
                textArabic: 'شكرا',
                isCorrect: true,
              ),
              ExerciseOption(
                id: 'opt2',
                text: 'Please',
                textArabic: 'من فضلك',
                isCorrect: false,
              ),
              ExerciseOption(
                id: 'opt3',
                text: 'Sorry',
                textArabic: 'آسف',
                isCorrect: false,
              ),
              ExerciseOption(
                id: 'opt4',
                text: 'Hello',
                textArabic: 'مرحبا',
                isCorrect: false,
              ),
            ],
            explanation: 'Thank you is used to show appreciation',
            explanationArabic: 'Thank you تُستخدم للتعبير عن التقدير',
            xpReward: 10,
          ),
        ],
      ),
    ],
  ),
];

// Helper function to get lessons by level
List<EnglishLesson> getLessonsByLevel(String level) {
  return allEnglishLessons.where((lesson) => lesson.level == level).toList();
}

// Helper function to get all unique levels
List<String> getAllLevels() {
  return ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
}

// Level descriptions for UI
Map<String, Map<String, String>> levelDescriptions = {
  'A1': {
    'en': 'Beginner - Basic vocabulary and simple greetings',
    'ar': 'مبتدئ - مفردات أساسية وتحيات بسيطة',
  },
  'A2': {
    'en': 'Elementary - Simple conversations and present tense',
    'ar': 'ابتدائي - محادثات بسيطة والزمن الحاضر',
  },
  'B1': {
    'en': 'Intermediate - Longer texts and past tense',
    'ar': 'متوسط - نصوص أطول والزمن الماضي',
  },
  'B2': {
    'en': 'Upper Intermediate - Complex sentences and idioms',
    'ar': 'متوسط عالي - جمل معقدة وتعابير اصطلاحية',
  },
  'C1': {
    'en': 'Advanced - Literature and nuanced meanings',
    'ar': 'متقدم - الأدب والمعاني الدقيقة',
  },
  'C2': {
    'en': 'Mastery - Fluent and authentic communication',
    'ar': 'إتقان - التواصل الطلق والأصيل',
  },
};
