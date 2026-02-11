// Firebase Lessons Data - Complete A1-C2 Curriculum
// Copy and paste individual lessons into Firestore Console
// OR use bulkAddLessons() in Firebase Service

import 'package:lingua_neural_kids_app/models/english_lesson_model.dart';

// Helper function to create lessons programmatically
List<EnglishLesson> getAllLessons() {
  return [
    // ==================== A1 LEVEL (Beginner) ====================

    EnglishLesson(
      id: 'a1_01_greetings',
      title: 'Greetings & Introductions',
      titleArabic: 'التحيات والتعريف بالنفس',
      description: 'Learn basic greetings and how to introduce yourself',
      descriptionArabic: 'تعلم التحيات الأساسية والتعريف بنفسك',
      level: 'A1',
      order: 1,
      category: 'Basics',
      categoryArabic: 'الأساسيات',
      units: [
        LessonUnit(
          id: 'a1_01_u1',
          type: 'vocabulary',
          exercises: [
            Exercise(
              id: 'ex_1',
              question: 'What do you say when meeting someone?',
              questionArabic: 'ماذا تقول عند لقاء شخص ما؟',
              type: 'multipleChoice',
              options: [
                ExerciseOption(id: 'opt_1', text: 'Hello', textArabic: 'مرحبا', isCorrect: true),
                ExerciseOption(id: 'opt_2', text: 'Goodbye', textArabic: 'وداعا', isCorrect: false),
                ExerciseOption(id: 'opt_3', text: 'Sleep', textArabic: 'نم', isCorrect: false),
              ],
              correctAnswer: 'Hello',
              explanation: 'Hello is the standard greeting',
              explanationArabic: 'Hello هي التحية القياسية',
              xpReward: 10,
            ),
            Exercise(
              id: 'ex_2',
              question: 'How do you say goodbye?',
              questionArabic: 'كيف تقول وداعا؟',
              type: 'multipleChoice',
              options: [
                ExerciseOption(id: 'opt_1', text: 'Good morning', textArabic: 'صباح الخير', isCorrect: false),
                ExerciseOption(id: 'opt_2', text: 'Goodbye', textArabic: 'وداعا', isCorrect: true),
                ExerciseOption(id: 'opt_3', text: 'Please', textArabic: 'من فضلك', isCorrect: false),
              ],
              correctAnswer: 'Goodbye',
              explanation: 'Goodbye is used when leaving',
              explanationArabic: 'Goodbye تُستخدم عند الرحيل',
              xpReward: 10,
            ),
            Exercise(
              id: 'ex_3',
              question: 'Complete: "Hi, my name is..."',
              questionArabic: 'أكمل: "Hi, my name is..."',
              type: 'multipleChoice',
              options: [
                ExerciseOption(id: 'opt_1', text: 'Sarah', textArabic: 'سارة', isCorrect: true),
                ExerciseOption(id: 'opt_2', text: 'Doing well', textArabic: 'بحال جيد', isCorrect: false),
                ExerciseOption(id: 'opt_3', text: 'Thank you', textArabic: 'شكرا', isCorrect: false),
              ],
              correctAnswer: 'Sarah',
              explanation: 'You use names to introduce yourself',
              explanationArabic: 'تستخدم الأسماء للتعريف بنفسك',
              xpReward: 10,
            ),
          ],
        ),
      ],
    ),

    EnglishLesson(
      id: 'a1_02_numbers',
      title: 'Numbers 1-10',
      titleArabic: 'الأرقام من 1 إلى 10',
      description: 'Learn to count from 1 to 10',
      descriptionArabic: 'تعلم التعداد من 1 إلى 10',
      level: 'A1',
      order: 2,
      category: 'Numbers',
      categoryArabic: 'الأرقام',
      units: [
        LessonUnit(
          id: 'a1_02_u1',
          type: 'vocabulary',
          exercises: [
            Exercise(
              id: 'ex_1',
              question: 'What number comes after 5?',
              questionArabic: 'ما الرقم الذي يأتي بعد 5؟',
              type: 'multipleChoice',
              options: [
                ExerciseOption(id: 'opt_1', text: '4', textArabic: '4', isCorrect: false),
                ExerciseOption(id: 'opt_2', text: '6', textArabic: '6', isCorrect: true),
                ExerciseOption(id: 'opt_3', text: '7', textArabic: '7', isCorrect: false),
              ],
              correctAnswer: '6',
              explanation: 'Numbers increase by one',
              explanationArabic: 'الأرقام تزداد بمقدار واحد',
              xpReward: 10,
            ),
            Exercise(
              id: 'ex_2',
              question: 'How do you write "eight" in digits?',
              questionArabic: 'كيف تكتب "eight" بالأرقام؟',
              type: 'multipleChoice',
              options: [
                ExerciseOption(id: 'opt_1', text: '7', textArabic: '7', isCorrect: false),
                ExerciseOption(id: 'opt_2', text: '8', textArabic: '8', isCorrect: true),
                ExerciseOption(id: 'opt_3', text: '9', textArabic: '9', isCorrect: false),
              ],
              correctAnswer: '8',
              explanation: 'Eight = 8',
              explanationArabic: 'Eight = 8',
              xpReward: 10,
            ),
          ],
        ),
      ],
    ),

    EnglishLesson(
      id: 'a1_03_colors',
      title: 'Basic Colors',
      titleArabic: 'الألوان الأساسية',
      description: 'Learn the names of primary colors',
      descriptionArabic: 'تعلم أسماء الألوان الأساسية',
      level: 'A1',
      order: 3,
      category: 'Vocabulary',
      categoryArabic: 'المفردات',
      units: [
        LessonUnit(
          id: 'a1_03_u1',
          type: 'vocabulary',
          exercises: [
            Exercise(
              id: 'ex_1',
              question: 'What color is the sky?',
              questionArabic: 'ما لون السماء؟',
              type: 'multipleChoice',
              options: [
                ExerciseOption(id: 'opt_1', text: 'Green', textArabic: 'أخضر', isCorrect: false),
                ExerciseOption(id: 'opt_2', text: 'Blue', textArabic: 'أزرق', isCorrect: true),
                ExerciseOption(id: 'opt_3', text: 'Red', textArabic: 'أحمر', isCorrect: false),
              ],
              correctAnswer: 'Blue',
              explanation: 'The sky is typically blue',
              explanationArabic: 'السماء عادة ما تكون زرقاء',
              xpReward: 10,
            ),
            Exercise(
              id: 'ex_2',
              question: 'Which color is opposite of white?',
              questionArabic: 'ما اللون الذي يعاكس الأبيض؟',
              type: 'multipleChoice',
              options: [
                ExerciseOption(id: 'opt_1', text: 'Black', textArabic: 'أسود', isCorrect: true),
                ExerciseOption(id: 'opt_2', text: 'Gray', textArabic: 'رمادي', isCorrect: false),
                ExerciseOption(id: 'opt_3', text: 'Yellow', textArabic: 'أصفر', isCorrect: false),
              ],
              correctAnswer: 'Black',
              explanation: 'Black and white are contrasts',
              explanationArabic: 'الأسود والأبيض متناقضان',
              xpReward: 10,
            ),
          ],
        ),
      ],
    ),

    // ==================== A2 LEVEL (Elementary) ====================

    EnglishLesson(
      id: 'a2_01_family',
      title: 'Family Members',
      titleArabic: 'أفراد الأسرة',
      description: 'Learn family vocabulary and relationships',
      descriptionArabic: 'تعلم مفردات الأسرة والعلاقات',
      level: 'A2',
      order: 1,
      category: 'Family',
      categoryArabic: 'الأسرة',
      units: [
        LessonUnit(
          id: 'a2_01_u1',
          type: 'vocabulary',
          exercises: [
            Exercise(
              id: 'ex_1',
              question: 'Who is your father\'s wife?',
              questionArabic: 'من هي زوجة والدك؟',
              type: 'multipleChoice',
              options: [
                ExerciseOption(id: 'opt_1', text: 'Mother', textArabic: 'الأم', isCorrect: true),
                ExerciseOption(id: 'opt_2', text: 'Sister', textArabic: 'الأخت', isCorrect: false),
                ExerciseOption(id: 'opt_3', text: 'Aunt', textArabic: 'العمة', isCorrect: false),
              ],
              correctAnswer: 'Mother',
              explanation: 'Your father\'s wife is your mother',
              explanationArabic: 'زوجة والدك هي والدتك',
              xpReward: 15,
            ),
          ],
        ),
      ],
    ),

    // ==================== B1 LEVEL (Intermediate) ====================

    EnglishLesson(
      id: 'b1_01_past_tense',
      title: 'Simple Past Tense',
      titleArabic: 'الماضي البسيط',
      description: 'Learn to talk about past actions',
      descriptionArabic: 'تعلم الحديث عن الأفعال الماضية',
      level: 'B1',
      order: 1,
      category: 'Grammar',
      categoryArabic: 'القواعد',
      units: [
        LessonUnit(
          id: 'b1_01_u1',
          type: 'grammar',
          exercises: [
            Exercise(
              id: 'ex_1',
              question: 'Choose the past tense: "I ___ to the store"',
              questionArabic: 'اختر الماضي: "I ___ to the store"',
              type: 'multipleChoice',
              options: [
                ExerciseOption(id: 'opt_1', text: 'go', textArabic: 'go', isCorrect: false),
                ExerciseOption(id: 'opt_2', text: 'went', textArabic: 'went', isCorrect: true),
                ExerciseOption(id: 'opt_3', text: 'goes', textArabic: 'goes', isCorrect: false),
              ],
              correctAnswer: 'went',
              explanation: 'Past tense of "go" is "went"',
              explanationArabic: '"went" هو الماضي من "go"',
              xpReward: 20,
            ),
          ],
        ),
      ],
    ),

    // ==================== B2 LEVEL (Upper-Intermediate) ====================

    EnglishLesson(
      id: 'b2_01_conditional',
      title: 'Conditional Sentences',
      titleArabic: 'جمل شرطية',
      description: 'Learn if/then conditional structures',
      descriptionArabic: 'تعلم هياكل "إذا/إذن" الشرطية',
      level: 'B2',
      order: 1,
      category: 'Grammar',
      categoryArabic: 'القواعد',
      units: [
        LessonUnit(
          id: 'b2_01_u1',
          type: 'grammar',
          exercises: [
            Exercise(
              id: 'ex_1',
              question: 'Complete: "If I had money, I ___ a house"',
              questionArabic: 'أكمل: "If I had money, I ___ a house"',
              type: 'multipleChoice',
              options: [
                ExerciseOption(id: 'opt_1', text: 'buy', textArabic: 'buy', isCorrect: false),
                ExerciseOption(id: 'opt_2', text: 'would buy', textArabic: 'would buy', isCorrect: true),
                ExerciseOption(id: 'opt_3', text: 'buys', textArabic: 'buys', isCorrect: false),
              ],
              correctAnswer: 'would buy',
              explanation: 'This is a second conditional (if + past, would + base)',
              explanationArabic: 'هذا شرط ثانٍ (if + past, would + base)',
              xpReward: 25,
            ),
          ],
        ),
      ],
    ),

    // ==================== C1 LEVEL (Advanced) ====================

    EnglishLesson(
      id: 'c1_01_subjunctive',
      title: 'Subjunctive Mood',
      titleArabic: 'صيغة التمني والافتراض',
      description: 'Master subjunctive mood for wishes and hypotheticals',
      descriptionArabic: 'إتقان صيغة التمني والافتراض للأمنيات والحالات الافتراضية',
      level: 'C1',
      order: 1,
      category: 'Advanced Grammar',
      categoryArabic: 'القواعد المتقدمة',
      units: [
        LessonUnit(
          id: 'c1_01_u1',
          type: 'grammar',
          exercises: [
            Exercise(
              id: 'ex_1',
              question: 'Which is correct? "I wish I ___ that earlier"',
              questionArabic: 'أي منها صحيح؟ "I wish I ___ that earlier"',
              type: 'multipleChoice',
              options: [
                ExerciseOption(id: 'opt_1', text: 'knew', textArabic: 'knew', isCorrect: false),
                ExerciseOption(id: 'opt_2', text: 'had known', textArabic: 'had known', isCorrect: true),
                ExerciseOption(id: 'opt_3', text: 'know', textArabic: 'know', isCorrect: false),
              ],
              correctAnswer: 'had known',
              explanation: 'Past wishes use past perfect subjunctive',
              explanationArabic: 'الأمنيات الماضية تستخدم الماضي التام',
              xpReward: 30,
            ),
          ],
        ),
      ],
    ),

    // ==================== C2 LEVEL (Proficiency) ====================

    EnglishLesson(
      id: 'c2_01_nuance',
      title: 'Linguistic Nuance & Style',
      titleArabic: 'الدقة اللغوية والأسلوب',
      description: 'Understand subtle differences in meaning and register',
      descriptionArabic: 'فهم الفروقات الدقيقة في المعنى والأسلوب',
      level: 'C2',
      order: 1,
      category: 'Mastery',
      categoryArabic: 'الإتقان',
      units: [
        LessonUnit(
          id: 'c2_01_u1',
          type: 'advanced',
          exercises: [
            Exercise(
              id: 'ex_1',
              question: 'What is the subtle difference? "I would argue" vs "one might contend"',
              questionArabic: 'ما الفرق الدقيق؟ "I would argue" مقابل "one might contend"',
              type: 'multipleChoice',
              options: [
                ExerciseOption(
                  id: 'opt_1',
                  text: 'First is formal, second is personal',
                  textArabic: 'الأول رسمي، الثاني شخصي',
                  isCorrect: true,
                ),
                ExerciseOption(
                  id: 'opt_2',
                  text: 'No meaningful difference',
                  textArabic: 'لا يوجد فرق ذو مغزى',
                  isCorrect: false,
                ),
                ExerciseOption(
                  id: 'opt_3',
                  text: 'First is stronger, second is weaker',
                  textArabic: 'الأول أقوى، الثاني أضعف',
                  isCorrect: false,
                ),
              ],
              correctAnswer: 'First is formal, second is personal',
              explanation: '"One" creates distance, more formal register',
              explanationArabic: '"One" تنشئ مسافة، أسلوب أكثر رسمية',
              xpReward: 40,
            ),
          ],
        ),
      ],
    ),
  ];
}

// To use this in Firebase Service:
// await firebaseEnglishLessonService.bulkAddLessons(getAllLessons());
