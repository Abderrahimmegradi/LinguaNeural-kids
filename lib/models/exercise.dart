class Exercise {
  final String id;
  final String type; // 'multiple_choice', 'speaking', 'listening', 'matching', 'fill_blank'
  final String question;
  final List<String>? options;
  final String? correctAnswer;
  final String? audioUrl;
  final String? imageUrl;
  final int points;
  final String hint;

  Exercise({
    required this.id,
    required this.type,
    required this.question,
    this.options,
    this.correctAnswer,
    this.audioUrl,
    this.imageUrl,
    required this.points,
    required this.hint,
  });
}