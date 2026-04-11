import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';
import '../models/app_user_profile.dart';
import 'firestore_mvp_service.dart';

class AdminManagementService {
  AdminManagementService({
    FirestoreMvpService? firestoreService,
  }) : _firestoreService = firestoreService ?? FirestoreMvpService();

  final FirestoreMvpService _firestoreService;

  Future<AppUserProfile> createManagedUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? schoolId,
    String? teacherId,
  }) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();
    final trimmedSchoolId = schoolId?.trim();
    final trimmedTeacherId = teacherId?.trim();
    if (trimmedName.isEmpty) {
      throw Exception('Name is required.');
    }
    if (!_isValidEmail(trimmedEmail)) {
      throw Exception('Enter a valid email address.');
    }
    if (password.length < 8) {
      throw Exception('Password must be at least 8 characters.');
    }
    if (role != UserRole.school &&
        (trimmedSchoolId == null || trimmedSchoolId.isEmpty)) {
      throw Exception('School ID is required.');
    }
    if (role == UserRole.student &&
        (trimmedTeacherId == null || trimmedTeacherId.isEmpty)) {
      throw Exception('Teacher linkage is required for students.');
    }

    final secondaryApp = await Firebase.initializeApp(
      name: 'admin-create-${DateTime.now().microsecondsSinceEpoch}',
      options: DefaultFirebaseOptions.currentPlatform,
    );

    try {
      final secondaryAuth = fb_auth.FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Managed user creation failed.');
      }

      await firebaseUser.updateDisplayName(trimmedName);

      final profile = AppUserProfile(
        id: firebaseUser.uid,
        name: trimmedName,
        email: trimmedEmail,
        role: role,
        schoolId: role == UserRole.school ? null : trimmedSchoolId,
        teacherId: role == UserRole.student ? trimmedTeacherId : null,
      );
      await _firestoreService.saveUserProfile(profile);
      await secondaryAuth.signOut();
      return profile;
    } finally {
      await secondaryApp.delete();
    }
  }

  bool _isValidEmail(String value) {
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailPattern.hasMatch(value);
  }

  Future<void> deleteManagedUser({
    required AppUserProfile user,
    String? currentPassword,
  }) async {
    if (currentPassword != null && currentPassword.trim().isNotEmpty) {
      final secondaryApp = await Firebase.initializeApp(
        name: 'admin-delete-${DateTime.now().microsecondsSinceEpoch}',
        options: DefaultFirebaseOptions.currentPlatform,
      );

      try {
        final secondaryAuth = fb_auth.FirebaseAuth.instanceFor(app: secondaryApp);
        final credential = await secondaryAuth.signInWithEmailAndPassword(
          email: user.email,
          password: currentPassword.trim(),
        );
        final firebaseUser = credential.user;
        if (firebaseUser != null) {
          await firebaseUser.delete();
        }
        await secondaryAuth.signOut();
      } finally {
        await secondaryApp.delete();
      }
    }

    await _firestoreService.deleteUserData(user);
  }

  Future<AppUserProfile> updateManagedUser({
    required AppUserProfile originalProfile,
    required String name,
    required String email,
    required String schoolId,
    String? teacherId,
    String? currentPassword,
    String? newPassword,
  }) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();
    final trimmedSchoolId = schoolId.trim();
    final trimmedTeacherId = teacherId?.trim();
    final trimmedCurrentPassword = currentPassword?.trim() ?? '';
    final trimmedNewPassword = newPassword?.trim() ?? '';

    if (trimmedName.isEmpty) {
      throw Exception('Name is required.');
    }
    if (!_isValidEmail(trimmedEmail)) {
      throw Exception('Enter a valid email address.');
    }
    if (trimmedSchoolId.isEmpty) {
      throw Exception('School ID is required.');
    }
    if (originalProfile.role == UserRole.student &&
        (trimmedTeacherId == null || trimmedTeacherId.isEmpty)) {
      throw Exception('Teacher linkage is required for students.');
    }
    if (trimmedNewPassword.isNotEmpty && trimmedNewPassword.length < 8) {
      throw Exception('New password must be at least 8 characters.');
    }

    final shouldUpdateAuth =
        trimmedEmail != originalProfile.email || trimmedNewPassword.isNotEmpty;
    if (shouldUpdateAuth && trimmedCurrentPassword.isEmpty) {
      throw Exception(
        'Current password is required to update Firebase Auth email or password.',
      );
    }

    if (shouldUpdateAuth) {
      final secondaryApp = await Firebase.initializeApp(
        name: 'admin-update-${DateTime.now().microsecondsSinceEpoch}',
        options: DefaultFirebaseOptions.currentPlatform,
      );

      try {
        final secondaryAuth = fb_auth.FirebaseAuth.instanceFor(app: secondaryApp);
        final credential = await secondaryAuth.signInWithEmailAndPassword(
          email: originalProfile.email,
          password: trimmedCurrentPassword,
        );
        final firebaseUser = credential.user;
        if (firebaseUser == null) {
          throw Exception('Could not load the user for update.');
        }
        if (trimmedEmail != originalProfile.email) {
          await firebaseUser.updateEmail(trimmedEmail);
        }
        if (trimmedNewPassword.isNotEmpty) {
          await firebaseUser.updatePassword(trimmedNewPassword);
        }
        await firebaseUser.updateDisplayName(trimmedName);
        await secondaryAuth.signOut();
      } finally {
        await secondaryApp.delete();
      }
    }

    final updatedProfile = originalProfile.copyWith(
      name: trimmedName,
      email: trimmedEmail,
      schoolId: trimmedSchoolId,
      teacherId:
          originalProfile.role == UserRole.student ? trimmedTeacherId : null,
    );
    await _firestoreService.saveUserProfile(updatedProfile);
    return updatedProfile;
  }

  Future<void> resetHierarchyData({
    required String preserveAdminUserId,
  }) {
    return _firestoreService.resetHierarchyData(
      preserveAdminUserId: preserveAdminUserId,
    );
  }
}
