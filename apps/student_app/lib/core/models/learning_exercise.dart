class LearningExercise {
  const LearningExercise({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.question,
    required this.questionArabic,
    required this.expectedSpeech,
    required this.correctAnswer,
    required this.explanation,
    required this.xpReward,
    required this.options,
    this.audioUrl,
    this.imageHint,
  });

  final String id;
  final String lessonId;
  final String type;
  final String question;
  final String questionArabic;
  final String expectedSpeech;
  final String correctAnswer;
  final String explanation;
  final int xpReward;
  final List<Map<String, dynamic>> options;
  final String? audioUrl;
  final String? imageHint;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lessonId': lessonId,
      'type': type,
      'question': question,
      'questionArabic': questionArabic,
      'expectedSpeech': expectedSpeech,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'xpReward': xpReward,
      'options': options,
      'audioUrl': audioUrl,
      'imageHint': imageHint,
    };
  }

  factory LearningExercise.fromMap(Map<String, dynamic> map) {
    return LearningExercise(
      id: map['id'] as String,
      lessonId: map['lessonId'] as String,
      type: map['type'] as String,
      question: map['question'] as String,
      questionArabic: map['questionArabic'] as String,
      expectedSpeech: map['expectedSpeech'] as String,
      correctAnswer: map['correctAnswer'] as String,
      explanation: map['explanation'] as String,
      xpReward: map['xpReward'] as int,
      options: List<Map<String, dynamic>>.from(
        (map['options'] as List<dynamic>).map(
          (item) => Map<String, dynamic>.from(item as Map),
        ),
      ),
      audioUrl: map['audioUrl'] as String?,
      imageHint: map['imageHint'] as String?,
    );
  }
}