import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('user model serializes role and identity', () {
    const user = UserModel(
      id: 'student-1',
      displayName: 'Lina',
      email: 'lina@example.com',
      role: UserRole.student,
    );

    expect(UserModel.fromMap(user.toMap()).role, UserRole.student);
    expect(UserModel.fromMap(user.toMap()).displayName, 'Lina');
  });

  test('progress model computes completion rate', () {
    const progress = ProgressModel(
      userId: 'student-1',
      lessonId: 'lesson-1',
      completedUnits: 2,
      totalUnits: 4,
    );

    expect(progress.completionRate, 0.5);
  });
}
