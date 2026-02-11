import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  String _selectedChild = 'John';

  final Map<String, ChildProfile> children = {
    'John': ChildProfile(
      name: 'John',
      avatar: '🧑',
      age: 8,
      level: 5,
      totalXP: 10150,
      streakDays: 7,
      lessonsCompleted: 12,
      averageScore: 85,
      lastActiveTime: 'Today at 3:45 PM',
      skillProgress: {
        'Listening': 75,
        'Speaking': 60,
        'Reading': 40,
        'Writing': 25,
      },
      weeklyProgress: [50, 45, 60, 55, 70, 65, 80],
    ),
    'Sarah': ChildProfile(
      name: 'Sarah',
      avatar: '👧',
      age: 10,
      level: 6,
      totalXP: 12500,
      streakDays: 14,
      lessonsCompleted: 18,
      averageScore: 92,
      lastActiveTime: 'Yesterday at 5:30 PM',
      skillProgress: {
        'Listening': 88,
        'Speaking': 85,
        'Reading': 72,
        'Writing': 68,
      },
      weeklyProgress: [70, 75, 80, 85, 90, 88, 92],
    ),
  };

  @override
  Widget build(BuildContext context) {
    final child = children[_selectedChild]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Parent Dashboard',
          style: GoogleFonts.nunitoSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A237E),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Child Selector
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Child',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      color: const Color(0xFF546E7A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: children.keys
                        .map((childName) => Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedChild = childName;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _selectedChild == childName
                                        ? const Color(0xFF1A237E)
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Text(
                                          children[childName]!.avatar,
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          childName,
                                          style: GoogleFonts.nunitoSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: _selectedChild == childName
                                                ? Colors.white
                                                : const Color(0xFF546E7A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),

            // Child Overview Card
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF66BB6A),
                    Color(0xFF29B6F6),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${child.name} (${child.age} yrs)',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Last active: ${child.lastActiveTime}',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        child.avatar,
                        style: const TextStyle(fontSize: 60),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatBox(
                        label: 'Level',
                        value: '${child.level}',
                        icon: '⭐',
                      ),
                      _buildStatBox(
                        label: 'Streak',
                        value: '${child.streakDays}',
                        icon: '🔥',
                      ),
                      _buildStatBox(
                        label: 'Avg Score',
                        value: '${child.averageScore}%',
                        icon: '📊',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Key Metrics
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Learning Summary',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMetricRow(
                          icon: '📚',
                          label: 'Lessons Completed',
                          value: '${child.lessonsCompleted}',
                          color: const Color(0xFF29B6F6),
                        ),
                        const Divider(height: 20),
                        _buildMetricRow(
                          icon: '⭐',
                          label: 'Total XP',
                          value: '${child.totalXP}',
                          color: const Color(0xFFFFD700),
                        ),
                        const Divider(height: 20),
                        _buildMetricRow(
                          icon: '📈',
                          label: 'Average Score',
                          value: '${child.averageScore}%',
                          color: const Color(0xFF66BB6A),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Skill Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skill Development',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      children: child.skillProgress.entries
                          .map((entry) => _buildSkillBar(
                                skill: entry.key,
                                progress: entry.value,
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Weekly Activity
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Activity',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: _buildActivityChart(child.weeklyProgress),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Recommendations
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommendations',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildRecommendationTile(
                    icon: '📝',
                    title: 'Focus on Writing',
                    description: '${child.name} needs more practice with writing skills.',
                    action: 'Suggest Lesson',
                  ),
                  const SizedBox(height: 10),
                  _buildRecommendationTile(
                    icon: '🎯',
                    title: 'Maintain Streak',
                    description: '${child.name} has a ${child.streakDays}-day streak. Keep it going!',
                    action: 'Encourage',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox({
    required String label,
    required String value,
    required String icon,
  }) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.nunitoSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.nunitoSans(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF546E7A),
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.nunitoSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillBar({
    required String skill,
    required int progress,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                skill,
                style: GoogleFonts.nunitoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$progress%',
                style: GoogleFonts.nunitoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF29B6F6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF29B6F6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart(List<int> data) {
    const maxHeight = 100;
    final maxValue = data.reduce((a, b) => a > b ? a : b).toDouble();

    return Column(
      children: [
        SizedBox(
          height: maxHeight + 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
              data.length,
              (index) => Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 30,
                    height: (data[index] / maxValue) * maxHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFF29B6F6),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index],
                    style: GoogleFonts.nunitoSans(
                      fontSize: 12,
                      color: const Color(0xFF546E7A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationTile({
    required String icon,
    required String title,
    required String description,
    required String action,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12,
                    color: const Color(0xFF546E7A),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              action,
              style: GoogleFonts.nunitoSans(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF29B6F6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChildProfile {
  final String name;
  final String avatar;
  final int age;
  final int level;
  final int totalXP;
  final int streakDays;
  final int lessonsCompleted;
  final int averageScore;
  final String lastActiveTime;
  final Map<String, int> skillProgress;
  final List<int> weeklyProgress;

  ChildProfile({
    required this.name,
    required this.avatar,
    required this.age,
    required this.level,
    required this.totalXP,
    required this.streakDays,
    required this.lessonsCompleted,
    required this.averageScore,
    required this.lastActiveTime,
    required this.skillProgress,
    required this.weeklyProgress,
  });
}
