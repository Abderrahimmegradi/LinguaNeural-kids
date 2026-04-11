import '../models/emotion_record.dart';
import 'firestore_mvp_service.dart';

class EmotionService {
  EmotionService({
    FirestoreMvpService? firestoreService,
  }) : _firestoreService = firestoreService ?? FirestoreMvpService();

  final FirestoreMvpService _firestoreService;

  Future<void> saveEmotion(
    String studentId,
    String type,
    double confidence,
  ) {
    return _firestoreService.saveEmotionRecord(
      EmotionRecord(
        id: '',
        studentId: studentId,
        type: type,
        confidence: confidence,
      ),
    );
  }

  Future<List<EmotionRecord>> getEmotionsForStudent(String studentId) {
    return _firestoreService.getEmotionsForStudent(studentId);
  }

  Future<EmotionRecord?> getLatestEmotionForStudent(String studentId) async {
    final records = await getEmotionsForStudent(studentId);
    if (records.isEmpty) {
      return null;
    }
    return records.first;
  }

  Future<String> analyzeEmotionFromVoice() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    const fakeEmotions = <String>['focused', 'happy', 'curious', 'tired'];
    return fakeEmotions[DateTime.now().millisecond % fakeEmotions.length];
  }
}
