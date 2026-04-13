import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:admin_app/models/admin_dashboard_models.dart';
import 'package:admin_app/screens/admin_dashboard_screen.dart';

void main() {
  testWidgets('admin dashboard renders admin overview header', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AdminDashboardScreen(
          currentRole: 'admin',
          currentDisplayName: 'Offline Admin',
          previewBundle: AdminDashboardBundle(
            users: [
              AdminUserRecord(
                id: 'student_1',
                displayName: 'Aya Ben',
                email: 'aya@example.com',
                role: 'student',
                status: 'active',
                schoolId: 'school_sunrise',
                teacherId: 'teacher_1',
                totalXp: 320,
                dailyStreak: 4,
                currentEmotion: 'confident',
                evolutionStage: 'glow',
                masteryScore: 0.82,
              ),
            ],
            roleCounts: const [
              AdminRoleCount(role: 'admin', count: 1),
              AdminRoleCount(role: 'pedagogiqueManager', count: 0),
              AdminRoleCount(role: 'teacher', count: 1),
              AdminRoleCount(role: 'student', count: 1),
            ],
            schoolSummaries: const [
              SchoolSummary(
                schoolId: 'school_sunrise',
                schoolName: 'Sunrise School',
                teacherCount: 1,
                studentCount: 1,
                averageXp: 320,
                averageMastery: 0.82,
              ),
            ],
            teacherSummaries: const [
              TeacherSummary(
                teacherId: 'teacher_1',
                teacherName: 'Teacher Amal',
                schoolId: 'school_sunrise',
                assignedStudents: 1,
                averageMastery: 0.82,
                supportNeededCount: 0,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Control center for real schools, roles, and student health'), findsOneWidget);
    expect(find.text('Platform Admin'), findsOneWidget);
    expect(find.text('Live pulse'), findsOneWidget);
  });
}