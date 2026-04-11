import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  admin,
  school,
  teacher,
  student,
}

UserRole userRoleFromString(String value) {
  switch (value.toLowerCase()) {
    case 'admin':
      return UserRole.admin;
    case 'school':
      return UserRole.school;
    case 'teacher':
      return UserRole.teacher;
    case 'student':
      return UserRole.student;
    default:
      return UserRole.student;
  }
}

class AppUserProfile {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? schoolId;
  final String? teacherId;
  final DateTime? createdAt;

  const AppUserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.schoolId,
    this.teacherId,
    this.createdAt,
  });

  String get roleValue => role.name;

  AppUserProfile copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? schoolId,
    String? teacherId,
    DateTime? createdAt,
  }) {
    return AppUserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      schoolId: schoolId ?? this.schoolId,
      teacherId: teacherId ?? this.teacherId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': roleValue,
      'schoolId': schoolId,
      'teacherId': teacherId,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory AppUserProfile.fromMap(Map<String, dynamic> map) {
    return AppUserProfile(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: userRoleFromString(map['role'] as String? ?? 'student'),
      schoolId: map['schoolId'] as String?,
      teacherId: map['teacherId'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  factory AppUserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return AppUserProfile.fromMap({
      ...data,
      'id': data['id'] ?? doc.id,
    });
  }
}
