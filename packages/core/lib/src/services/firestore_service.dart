import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/lesson_model.dart';
import '../models/progress_model.dart';

class FirestoreService {
  const FirestoreService();

  CollectionReference<Map<String, dynamic>> get _lessonCollection {
    return FirebaseFirestore.instance.collection('lessons');
  }

  CollectionReference<Map<String, dynamic>> get _progressCollection {
    return FirebaseFirestore.instance.collection('progress');
  }

  Future<List<LessonModel>> fetchLessons() async {
    final snapshot = await _lessonCollection.get();
    return snapshot.docs.map((doc) {
      return LessonModel.fromMap({
        'id': doc.id,
        ...doc.data(),
      });
    }).toList();
  }

  Future<void> saveProgress(ProgressModel progress) {
    final documentId = '${progress.userId}_${progress.lessonId}';
    return _progressCollection.doc(documentId).set(progress.toMap());
  }
}