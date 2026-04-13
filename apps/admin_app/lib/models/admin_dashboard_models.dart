class AdminUserRecord {
  const AdminUserRecord({
    required this.id,
    required this.displayName,
    required this.email,
    required this.role,
    required this.status,
    required this.schoolId,
    required this.totalXp,
    required this.dailyStreak,
    required this.currentEmotion,
    required this.evolutionStage,
    required this.masteryScore,
    this.teacherId,
  });

  final String id;
  final String displayName;
  final String email;
  final String role;
  final String status;
  final String schoolId;
  final int totalXp;
  final int dailyStreak;
  final String currentEmotion;
  final String evolutionStage;
  final double masteryScore;
  final String? teacherId;

  bool get isStudent => role == 'student';
  bool get isTeacher => role == 'teacher';
}

class AdminRoleCount {
  const AdminRoleCount({required this.role, required this.count});

  final String role;
  final int count;
}

class SchoolSummary {
  const SchoolSummary({
    required this.schoolId,
    required this.schoolName,
    required this.teacherCount,
    required this.studentCount,
    required this.averageXp,
    required this.averageMastery,
  });

  final String schoolId;
  final String schoolName;
  final int teacherCount;
  final int studentCount;
  final double averageXp;
  final double averageMastery;
}

class TeacherSummary {
  const TeacherSummary({
    required this.teacherId,
    required this.teacherName,
    required this.schoolId,
    required this.assignedStudents,
    required this.averageMastery,
    required this.supportNeededCount,
  });

  final String teacherId;
  final String teacherName;
  final String schoolId;
  final int assignedStudents;
  final double averageMastery;
  final int supportNeededCount;
}

class AdminLessonStateSummary {
  const AdminLessonStateSummary({
    required this.lessonId,
    required this.completed,
    required this.score,
    required this.mistakeCount,
    required this.xpEarned,
  });

  final String lessonId;
  final bool completed;
  final double score;
  final int mistakeCount;
  final int xpEarned;
}

class AdminEmotionEvent {
  const AdminEmotionEvent({
    required this.lessonId,
    required this.emotion,
    required this.masteryScore,
    required this.score,
    required this.mistakeCount,
    required this.createdAt,
  });

  final String lessonId;
  final String emotion;
  final double masteryScore;
  final double score;
  final int mistakeCount;
  final DateTime? createdAt;
}

class AdminStudentInsight {
  const AdminStudentInsight({
    required this.user,
    required this.currentLessonId,
    required this.completedLessonsCount,
    required this.badgesCount,
    required this.unlockedChapterIds,
    required this.lessonStates,
    required this.emotionEvents,
  });

  final AdminUserRecord user;
  final String currentLessonId;
  final int completedLessonsCount;
  final int badgesCount;
  final List<String> unlockedChapterIds;
  final List<AdminLessonStateSummary> lessonStates;
  final List<AdminEmotionEvent> emotionEvents;
}

class AdminDashboardBundle {
  const AdminDashboardBundle({
    required this.users,
    required this.roleCounts,
    required this.schoolSummaries,
    required this.teacherSummaries,
  });

  final List<AdminUserRecord> users;
  final List<AdminRoleCount> roleCounts;
  final List<SchoolSummary> schoolSummaries;
  final List<TeacherSummary> teacherSummaries;

  int get adminCount => _countFor('admin');
  int get pedagogiqueManagerCount => _countFor('pedagogiqueManager');
  int get teacherCount => _countFor('teacher');
  int get studentCount => _countFor('student');

  List<AdminUserRecord> get students =>
      users.where((user) => user.isStudent).toList(growable: false);

  List<AdminUserRecord> get teachers =>
      users.where((user) => user.isTeacher).toList(growable: false);

  double get averageStudentMastery {
    if (students.isEmpty) {
      return 0;
    }
    final total = students.fold<double>(0, (value, user) => value + user.masteryScore);
    return total / students.length;
  }

  double get averageStudentStreak {
    if (students.isEmpty) {
      return 0;
    }
    final total = students.fold<int>(0, (value, user) => value + user.dailyStreak);
    return total / students.length;
  }

  int get supportNeededStudents =>
      students.where((user) => user.currentEmotion == 'needs_support' || user.masteryScore < 0.65).length;

  int _countFor(String role) {
    return roleCounts
        .firstWhere(
          (entry) => entry.role == role,
          orElse: () => const AdminRoleCount(role: '', count: 0),
        )
        .count;
  }
}