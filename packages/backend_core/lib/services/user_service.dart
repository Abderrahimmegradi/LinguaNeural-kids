import '../models/app_user_profile.dart';
import 'firestore_mvp_service.dart';

class UserService {
  UserService({
    FirestoreMvpService? firestoreService,
  }) : _firestoreService = firestoreService ?? FirestoreMvpService();

  final FirestoreMvpService _firestoreService;

  Future<AppUserProfile?> getUserById(String uid) {
    return _firestoreService.getUserProfile(uid);
  }

  Future<void> createUser(AppUserProfile user) {
    return _firestoreService.saveUserProfile(user);
  }

  Future<List<AppUserProfile>> getStudents({
    String? schoolId,
    String? teacherId,
    bool includeLegacyTeacherlessForSchool = false,
  }) {
    return _firestoreService.getUsersByRole(
      UserRole.student,
      schoolId: schoolId,
      teacherId: teacherId,
      includeLegacyTeacherlessForSchool: includeLegacyTeacherlessForSchool,
    );
  }

  Future<List<AppUserProfile>> getTeachers({
    String? schoolId,
  }) {
    return _firestoreService.getUsersByRole(
      UserRole.teacher,
      schoolId: schoolId,
    );
  }
}
