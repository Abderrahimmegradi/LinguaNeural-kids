enum UserRole {
  student,
  teacher,
  pedagogique,
  admin,
}

class UserModel {
  const UserModel({
    required this.id,
    required this.role,
    this.email,
    this.displayName,
  });

  final String id;
  final String? email;
  final String? displayName;
  final UserRole role;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String?,
      displayName: map['displayName'] as String?,
      role: UserRole.values.byName((map['role'] as String?) ?? 'student'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': role.name,
    };
  }
}