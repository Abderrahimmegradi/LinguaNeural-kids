import '../models/english_lesson_model.dart';

// Complete curriculum for kids 8-10 years old
// A1: Basic vocabulary, 100-150 words
// A2: Elementary topics, 200-300 words
// B1: Intermediate stories, 400-500 words
// B2: Complex topics, 600-800 words
// C1: Advanced reading, 1000+ words
// C2: Expert level, specialized topics

final List<EnglishLesson> allEnglishLessons = [
  // ==================== A1 LEVEL (BEGINNER) ====================
  // Total: 15+ lessons for basic vocabulary and simple conversations
  
  EnglishLesson(
    id: 'a1_01_greetings',
    title: 'Greetings & Introductions',
    titleArabic: 'التحيات والتعريف بالنفس',
    description: 'Learn to say hello and introduce yourself',
    descriptionArabic: 'تعلم كيفية قول مرحبا والتعريف بنفسك',
    level: 'A1',
    order: 1,
    category: 'Greetings',
    categoryArabic: 'التحيات',
    units: [
      LessonUnit(
        id: 'a1_01_vocab',
        type: 'vocabulary',
        exercises: _generateExercises([
          ('Hello', 'مرحبا'),
          ('Hi', 'مرحبا'),
          ('Good morning', 'صباح الخير'),
          ('Good afternoon', 'مساء الخير'),
          ('Good evening', 'تحية المساء'),
          ('Good night', 'ليلة سعيدة'),
          ('Goodbye', 'وداعا'),
          ('Bye', 'باي'),
          ('My name is', 'اسمي هو'),
          ('What is your name?', 'ما اسمك؟'),
        ]),
      ),
    ],
  ),
  
  EnglishLesson(
    id: 'a1_02_family',
    title: 'Family Members',
    titleArabic: 'أفراد الأسرة',
    description: 'Learn family vocabulary for kids',
    descriptionArabic: 'تعلم مفردات الأسرة للأطفال',
    level: 'A1',
    order: 2,
    category: 'Family',
    categoryArabic: 'الأسرة',
    units: [
      LessonUnit(
        id: 'a1_02_vocab',
        type: 'vocabulary',
        exercises: _generateExercises([
          ('Father', 'الأب'),
          ('Mother', 'الأم'),
          ('Brother', 'الأخ'),
          ('Sister', 'الأخت'),
          ('Grandfather', 'الجد'),
          ('Grandmother', 'الجدة'),
          ('Uncle', 'العم'),
          ('Aunt', 'العمة'),
          ('Cousin', 'الابن العم'),
          ('Baby', 'الطفل الصغير'),
        ]),
      ),
    ],
  ),

  EnglishLesson(
    id: 'a1_03_numbers',
    title: 'Numbers 1-20',
    titleArabic: 'الأرقام من 1 إلى 20',
    description: 'Count and recognize numbers',
    descriptionArabic: 'العد والتعرف على الأرقام',
    level: 'A1',
    order: 3,
    category: 'Numbers',
    categoryArabic: 'الأرقام',
    units: [
      LessonUnit(
        id: 'a1_03_vocab',
        type: 'vocabulary',
        exercises: _generateExercises([
          ('Zero', 'صفر'),
          ('One', 'واحد'),
          ('Two', 'اثنان'),
          ('Three', 'ثلاثة'),
          ('Four', 'أربعة'),
          ('Five', 'خمسة'),
          ('Six', 'ستة'),
          ('Seven', 'سبعة'),
          ('Eight', 'ثمانية'),
          ('Nine', 'تسعة'),
          ('Ten', 'عشرة'),
        ]),
      ),
    ],
  ),

  EnglishLesson(
    id: 'a1_04_colors',
    title: 'Basic Colors',
    titleArabic: 'الألوان الأساسية',
    description: 'Learn primary colors in English',
    descriptionArabic: 'تعلم الألوان الأساسية بالإنجليزية',
    level: 'A1',
    order: 4,
    category: 'Colors',
    categoryArabic: 'الألوان',
    units: [
      LessonUnit(
        id: 'a1_04_vocab',
        type: 'vocabulary',
        exercises: _generateExercises([
          ('Red', 'أحمر'),
          ('Blue', 'أزرق'),
          ('Yellow', 'أصفر'),
          ('Green', 'أخضر'),
          ('Black', 'أسود'),
          ('White', 'أبيض'),
          ('Pink', 'وردي'),
          ('Purple', 'بنفسجي'),
          ('Orange', 'برتقالي'),
          ('Brown', 'بني'),
        ]),
      ),
    ],
  ),

  EnglishLesson(
    id: 'a1_05_animals',
    title: 'Common Animals',
    titleArabic: 'الحيوانات الشائعة',
    description: 'Learn names of animals kids know',
    descriptionArabic: 'تعلم أسماء الحيوانات التي يعرفها الأطفال',
    level: 'A1',
    order: 5,
    category: 'Animals',
    categoryArabic: 'الحيوانات',
    units: [
      LessonUnit(
        id: 'a1_05_vocab',
        type: 'vocabulary',
        exercises: _generateExercises([
          ('Dog', 'كلب'),
          ('Cat', 'قطة'),
          ('Bird', 'طائر'),
          ('Fish', 'سمكة'),
          ('Lion', 'أسد'),
          ('Tiger', 'نمر'),
          ('Elephant', 'فيل'),
          ('Monkey', 'قرد'),
          ('Cow', 'بقرة'),
          ('Horse', 'حصان'),
        ]),
      ),
    ],
  ),

  EnglishLesson(
    id: 'a1_06_body',
    title: 'Body Parts',
    titleArabic: 'أجزاء الجسم',
    description: 'Learn names of body parts',
    descriptionArabic: 'تعلم أسماء أجزاء الجسم',
    level: 'A1',
    order: 6,
    category: 'Body',
    categoryArabic: 'الجسم',
    units: [
      LessonUnit(
        id: 'a1_06_vocab',
        type: 'vocabulary',
        exercises: _generateExercises([
          ('Head', 'الرأس'),
          ('Face', 'الوجه'),
          ('Eye', 'العين'),
          ('Ear', 'الأذن'),
          ('Nose', 'الأنف'),
          ('Mouth', 'الفم'),
          ('Hand', 'اليد'),
          ('Arm', 'الذراع'),
          ('Leg', 'الساق'),
          ('Foot', 'القدم'),
        ]),
      ),
    ],
  ),

  EnglishLesson(
    id: 'a1_07_food',
    title: 'Basic Foods',
    titleArabic: 'الأطعمة الأساسية',
    description: 'Common foods kids eat',
    descriptionArabic: 'الأطعمة الشائعة التي يأكلها الأطفال',
    level: 'A1',
    order: 7,
    category: 'Food',
    categoryArabic: 'الطعام',
    units: [
      LessonUnit(
        id: 'a1_07_vocab',
        type: 'vocabulary',
        exercises: _generateExercises([
          ('Apple', 'تفاحة'),
          ('Banana', 'موزة'),
          ('Bread', 'خبز'),
          ('Rice', 'أرز'),
          ('Milk', 'حليب'),
          ('Cheese', 'جبن'),
          ('Chicken', 'دجاج'),
          ('Water', 'ماء'),
          ('Cake', 'كعكة'),
          ('Pizza', 'بيتزا'),
        ]),
      ),
    ],
  ),

  EnglishLesson(
    id: 'a1_08_school',
    title: 'School Vocabulary',
    titleArabic: 'مفردات المدرسة',
    description: 'Words related to school',
    descriptionArabic: 'الكلمات المتعلقة بالمدرسة',
    level: 'A1',
    order: 8,
    category: 'School',
    categoryArabic: 'المدرسة',
    units: [
      LessonUnit(
        id: 'a1_08_vocab',
        type: 'vocabulary',
        exercises: _generateExercises([
          ('Pen', 'قلم'),
          ('Pencil', 'قلم رصاص'),
          ('Paper', 'ورقة'),
          ('Book', 'كتاب'),
          ('Desk', 'مكتب'),
          ('Chair', 'كرسي'),
          ('Teacher', 'معلم'),
          ('Student', 'طالب'),
          ('Classroom', 'فصل دراسي'),
          ('School', 'مدرسة'),
        ]),
      ),
    ],
  ),

  EnglishLesson(
    id: 'a1_09_polite',
    title: 'Polite Expressions',
    titleArabic: 'التعابير المهذبة',
    description: 'Essential polite words and phrases',
    descriptionArabic: 'الكلمات والعبارات المهذبة الأساسية',
    level: 'A1',
    order: 9,
    category: 'Polite',
    categoryArabic: 'مهذبة',
    units: [
      LessonUnit(
        id: 'a1_09_vocab',
        type: 'vocabulary',
        exercises: _generateExercises([
          ('Please', 'من فضلك'),
          ('Thank you', 'شكرا'),
          ('Thank you very much', 'شكرا جزيلا'),
          ('You\'re welcome', 'على الرحب والسعة'),
          ('Sorry', 'آسف'),
          ('Excuse me', 'اعتذر'),
          ('Yes', 'نعم'),
          ('No', 'لا'),
          ('OK', 'حسنا'),
          ('Pardon?', 'ماذا؟'),
        ]),
      ),
    ],
  ),

  EnglishLesson(
    id: 'a1_10_questions',
    title: 'Basic Questions',
    titleArabic: 'الأسئلة الأساسية',
    description: 'Learn to ask simple questions',
    descriptionArabic: 'تعلم طرح أسئلة بسيطة',
    level: 'A1',
    order: 10,
    category: 'Grammar',
    categoryArabic: 'القواعد',
    units: [
      LessonUnit(
        id: 'a1_10_vocab',
        type: 'vocabulary',
        exercises: _generateExercises([
          ('What is this?', 'ما هذا؟'),
          ('What is your name?', 'ما اسمك؟'),
          ('How are you?', 'كيف حالك؟'),
          ('Where are you from?', 'من أين أنت؟'),
          ('How old are you?', 'كم عمرك؟'),
          ('What is your favorite color?', 'ما لونك المفضل؟'),
          ('Do you like...?', 'هل تحب...؟'),
          ('Can you...?', 'هل تستطيع...؟'),
          ('Where is...?', 'أين...؟'),
          ('When is...?', 'متى...؟'),
        ]),
      ),
    ],
  ),

  // ==================== A2 LEVEL (ELEMENTARY) ====================
  
  EnglishLesson(
    id: 'a2_01_daily_routine',
    title: 'Daily Routine',
    titleArabic: 'الروتين اليومي',
    description: 'Activities and times of the day',
    descriptionArabic: 'الأنشطة واوقات اليوم',
    level: 'A2',
    order: 1,
    category: 'Daily Life',
    categoryArabic: 'الحياة اليومية',
    units: [
      LessonUnit(
        id: 'a2_01_vocab',
        type: 'vocabulary',
        exercises: _generateExercises([
          ('Wake up', 'الاستيقاظ'),
          ('Breakfast', 'الإفطار'),
          ('Go to school', 'الذهاب إلى المدرسة'),
          ('Lunch', 'الغداء'),
          ('Come home', 'العودة للمنزل'),
          ('Play', 'تلعب'),
          ('Homework', 'الواجب المنزلي'),
          ('Dinner', 'العشاء'),
          ('Watch TV', 'مشاهدة التلفاز'),
          ('Go to bed', 'النوم'),
        ]),
      ),
    ],
  ),

  EnglishLesson(
    id: 'a2_02_sports_activities',
    title: 'Sports & Hobbies',
    titleArabic: 'الرياضة والهوايات',
    description: 'Games and fun activities',
    descriptionArabic: 'الألعاب والأنشطة الممتعة',
    level: 'A2',
    order: 2,
    category: 'Hobbies',
    categoryArabic: 'الهوايات',
    units: [
      LessonUnit(
        id: 'a2_02_vocab',
        type: 'vocabulary',
        exercises: _generateExercises([
          ('Football', 'كرة القدم'),
          ('Basketball', 'كرة السلة'),
          ('Tennis', 'التنس'),
          ('Swimming', 'السباحة'),
          ('Running', 'الجري'),
          ('Cycling', 'ركوب الدراجات'),
          ('Drawing', 'الرسم'),
          ('Reading', 'القراءة'),
          ('Playing music', 'عزف الموسيقى'),
          ('Singing', 'الغناء'),
        ]),
      ),
    ],
  ),

  EnglishLesson(
    id: 'a2_03_weather',
    title: 'Weather & Seasons',
    titleArabic: 'الطقس والفصول',
    description: 'Weather vocabulary and seasons',
    descriptionArabic: 'مفردات الطقس والفصول',
    level: 'A2',
    order: 3,
    category: 'Nature',
    categoryArabic: 'الطبيعة',
    units: [
      LessonUnit(
        id: 'a2_03_vocab',
        type: 'vocabulary',
        exercises: _generateExercises([
          ('Sunny', 'مشمس'),
          ('Rainy', 'ممطر'),
          ('Cloudy', 'غائم'),
          ('Snowy', 'ثلجي'),
          ('Windy', 'عاصف'),
          ('Hot', 'حار'),
          ('Cold', 'بارد'),
          ('Spring', 'الربيع'),
          ('Summer', 'الصيف'),
          ('Winter', 'الشتاء'),
        ]),
      ),
    ],
  ),

  EnglishLesson(
    id: 'a2_04_clothes',
    title: 'Clothing & Fashion',
    titleArabic: 'الملابس والموضة',
    description: 'Types of clothes and accessories',
    descriptionArabic: 'أنواع الملابس والإكسسوارات',
    level: 'A2',
    order: 4,
    category: 'Clothes',
    categoryArabic: 'الملابس',
    units: [
      LessonUnit(
        id: 'a2_04_vocab',
        type: 'vocabulary',
        exercises: _generateExercises([
          ('Shirt', 'قميص'),
          ('Pants', 'بنطال'),
          ('Dress', 'فستان'),
          ('Jacket', 'سترة'),
          ('Hat', 'قبعة'),
          ('Shoes', 'أحذية'),
          ('Socks', 'جوارب'),
          ('Tie', 'ربطة عنق'),
          ('Gloves', 'قفازات'),
          ('Scarf', 'وشاح'),
        ]),
      ),
    ],
  ),

  EnglishLesson(
    id: 'a2_05_shopping',
    title: 'Shopping & Numbers Up to 100',
    titleArabic: 'التسوق والأرقام حتى 100',
    description: 'Shopping vocabulary and prices',
    descriptionArabic: 'مفردات التسوق والأسعار',
    level: 'A2',
    order: 5,
    category: 'Shopping',
    categoryArabic: 'التسوق',
    units: [
      LessonUnit(
        id: 'a2_05_vocab',
        type: 'vocabulary',
        exercises: _generateExercises([
          ('Shop', 'متجر'),
          ('Market', 'سوق'),
          ('Buy', 'شراء'),
          ('Sell', 'بيع'),
          ('Price', 'السعر'),
          ('Expensive', 'مكلف'),
          ('Cheap', 'رخيص'),
          ('Money', 'المال'),
          ('Pay', 'الدفع'),
          ('Change', 'التغيير'),
        ]),
      ),
    ],
  ),

  // ==================== B1 LEVEL (INTERMEDIATE) ====================
  
  EnglishLesson(
    id: 'b1_01_past_tense',
    title: 'Past Simple - What I Did',
    titleArabic: 'الزمن الماضي - ما فعلت',
    description: 'Learn basic past tense verbs',
    descriptionArabic: 'تعلم أفعال الزمن الماضي الأساسية',
    level: 'B1',
    order: 1,
    category: 'Grammar',
    categoryArabic: 'القواعد',
    units: [
      LessonUnit(
        id: 'b1_01_vocab',
        type: 'vocabulary',
        exercises: _generateExercises([
          ('Go - Went', 'ذهب - ذهبت'),
          ('See - Saw', 'شاهد - شاهدت'),
          ('Eat - Ate', 'أكل - أكلت'),
          ('Play - Played', 'لعب - لعبت'),
          ('Watch - Watched', 'شاهد - شاهدت'),
          ('Read - Read', 'قرأ - قرأت'),
          ('Do - Did', 'فعل - فعلت'),
          ('Have - Had', 'كان لديه - كان عندي'),
          ('Talk - Talked', 'تحدث - تحدثت'),
          ('Work - Worked', 'عمل - عملت'),
        ]),
      ),
    ],
  ),

  EnglishLesson(
    id: 'b1_02_future_plans',
    title: 'Future Plans & Will Go',
    titleArabic: 'الخطط المستقبلية والذهاب',
    description: 'Talk about future plans',
    descriptionArabic: 'التحدث عن الخطط المستقبلية',
    level: 'B1',
    order: 2,
    category: 'Grammar',
    categoryArabic: 'القواعد',
    units: [
      LessonUnit(
        id: 'b1_02_vocab',
        type: 'vocabulary',
        exercises: _generateExercises([
          ('Tomorrow', 'غدا'),
          ('Next week', 'الأسبوع القادم'),
          ('Will go', 'سأذهب'),
          ('Going to', 'ذاهب إلى'),
          ('Holiday', 'إجازة'),
          ('Vacation', 'عطلة'),
          ('Travel', 'السفر'),
          ('Beach', 'الشاطئ'),
          ('Mountain', 'الجبل'),
          ('Adventure', 'مغامرة'),
        ]),
      ),
    ],
  ),

  EnglishLesson(
    id: 'b1_03_stories',
    title: 'Telling Stories - What Happened',
    titleArabic: 'سرد القصص - ما حدث',
    description: 'Tell simple stories about experiences',
    descriptionArabic: 'سرد قصص بسيطة عن الخبرات',
    level: 'B1',
    order: 3,
    category: 'Stories',
    categoryArabic: 'القصص',
    units: [
      LessonUnit(
        id: 'b1_03_vocab',
        type: 'vocabulary',
        exercises: _generateExercises([
          ('Once upon a time', 'في يوم من الأيام'),
          ('First', 'أولا'),
          ('Then', 'ثم'),
          ('After that', 'بعد ذلك'),
          ('Finally', 'أخيرا'),
          ('Lucky', 'محظوظ'),
          ('Sad', 'حزين'),
          ('Happy', 'سعيد'),
          ('Excited', 'متحمس'),
          ('Scared', 'خائف'),
        ]),
      ),
    ],
  ),

  // ==================== B2 LEVEL (UPPER INTERMEDIATE) ====================
  
  EnglishLesson(
    id: 'b2_01_opinions',
    title: 'Expressing Opinions',
    titleArabic: 'التعبير عن الآراء',
    description: 'How to give your opinion on topics',
    descriptionArabic: 'كيفية إبداء رأيك في المواضيع',
    level: 'B2',
    order: 1,
    category: 'Communication',
    categoryArabic: 'التواصل',
    units: [
      LessonUnit(
        id: 'b2_01_vocab',
        type: 'vocabulary',
        exercises: _generateExercises([
          ('I think', 'أعتقد'),
          ('In my opinion', 'في رأيي'),
          ('I believe', 'أعتقد'),
          ('I agree', 'أوافق'),
          ('I disagree', 'أختلف'),
          ('Interesting', 'مثير للاهتمام'),
          ('Boring', 'ممل'),
          ('Exciting', 'مثير'),
          ('Important', 'مهم'),
          ('Useful', 'مفيد'),
        ]),
      ),
    ],
  ),

  // ==================== C1 LEVEL (ADVANCED) ====================
  
  EnglishLesson(
    id: 'c1_01_literature',
    title: 'Reading Literature',
    titleArabic: 'قراءة الأدب',
    description: 'Understanding complex narratives',
    descriptionArabic: 'فهم السرد المعقد',
    level: 'C1',
    order: 1,
    category: 'Literature',
    categoryArabic: 'الأدب',
    units: [
      LessonUnit(
        id: 'c1_01_vocab',
        type: 'vocabulary',
        exercises: _generateExercises([
          ('Narrative', 'السرد'),
          ('Character', 'الشخصية'),
          ('Plot', 'الحبكة'),
          ('Theme', 'الموضوع'),
          ('Setting', 'الإعداد'),
          ('Symbolism', 'الرمزية'),
          ('Metaphor', 'الاستعارة'),
          ('Irony', 'السخرية'),
          ('Climax', 'الذروة'),
          ('Resolution', 'الحل'),
        ]),
      ),
    ],
  ),

  // ==================== C2 LEVEL (MASTERY) ====================
  
  EnglishLesson(
    id: 'c2_01_advanced_topics',
    title: 'Advanced Topics & Analysis',
    titleArabic: 'المواضيع المتقدمة والتحليل',
    description: 'In-depth analysis of complex subjects',
    descriptionArabic: 'التحليل المتعمق للمواضيع المعقدة',
    level: 'C2',
    order: 1,
    category: 'Advanced',
    categoryArabic: 'متقدم',
    units: [
      LessonUnit(
        id: 'c2_01_vocab',
        type: 'vocabulary',
        exercises: _generateExercises([
          ('Analyze', 'تحليل'),
          ('Interpret', 'تفسير'),
          ('Evaluate', 'تقييم'),
          ('Synthesize', 'تركيب'),
          ('Critical thinking', 'التفكير النقدي'),
          ('philosophical', 'فلسفي'),
          ('Existential', 'وجودي'),
          ('Theoretical', 'نظري'),
          ('Empirical', 'تجريبي'),
          ('Controversial', 'مثير للجدل'),
        ]),
      ),
    ],
  ),
];

// Helper function to generate exercises from word pairs
List<Exercise> _generateExercises(List<(String, String)> wordPairs) {
  List<Exercise> exercises = [];
  
  for (var i = 0; i < wordPairs.length; i++) {
    final english = wordPairs[i].$1;
    final arabic = wordPairs[i].$2;
    
    // Create shuffled options
    List<ExerciseOption> options = [];
    options.add(ExerciseOption(
      id: 'opt_correct',
      text: arabic,
      textArabic: arabic,
      isCorrect: true,
    ));
    
    // Add wrong options from other words
    int j = 0;
    while (options.length < 4 && j < wordPairs.length) {
      if (j != i) {
        options.add(ExerciseOption(
          id: 'opt_false_$j',
          text: wordPairs[j].$2,
          textArabic: wordPairs[j].$2,
          isCorrect: false,
        ));
      }
      j++;
    }
    
    // Shuffle options
    options.shuffle();
    
    exercises.add(Exercise(
      id: 'ex_${i + 1}',
      question: 'What does "$english" mean?',
      questionArabic: 'ماذا تعني كلمة "$english"؟',
      type: 'multipleChoice',
      options: options,
      correctAnswer: arabic,
      explanation: '"$english" means "$arabic" in English.',
      explanationArabic: '"$english" تعني "$arabic" باللغة الإنجليزية.',
      xpReward: 10,
    ));
  }
  
  return exercises;
}
