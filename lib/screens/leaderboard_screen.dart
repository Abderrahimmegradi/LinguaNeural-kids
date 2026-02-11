import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _selectedTab = 'Global';

  final List<LeaderboardEntry> globalRanking = [
    LeaderboardEntry(
      rank: 1,
      name: 'Alex Star',
      xp: 15250,
      level: 8,
      streak: 45,
      avatar: '👨',
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      rank: 2,
      name: 'Sarah Genius',
      xp: 14800,
      level: 8,
      streak: 38,
      avatar: '👩',
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      rank: 3,
      name: 'You (John)',
      xp: 10150,
      level: 5,
      streak: 7,
      avatar: '🧑',
      isCurrentUser: true,
    ),
    LeaderboardEntry(
      rank: 4,
      name: 'Emma Quick',
      xp: 9800,
      level: 5,
      streak: 15,
      avatar: '👧',
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      rank: 5,
      name: 'Lucas Lee',
      xp: 9200,
      level: 4,
      streak: 12,
      avatar: '👦',
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      rank: 6,
      name: 'Sofia Smart',
      xp: 8900,
      level: 4,
      streak: 8,
      avatar: '👱‍♀️',
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      rank: 7,
      name: 'Marco Fast',
      xp: 8500,
      level: 4,
      streak: 5,
      avatar: '👨‍🦱',
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      rank: 8,
      name: 'Julia Smart',
      xp: 8100,
      level: 4,
      streak: 3,
      avatar: '👩‍🦰',
      isCurrentUser: false,
    ),
  ];

  late List<LeaderboardEntry> friendsRanking;

  @override
  void initState() {
    super.initState();
    friendsRanking = [
      LeaderboardEntry(
        rank: 1,
        name: 'Sarah Genius',
        xp: 14800,
        level: 8,
        streak: 38,
        avatar: '👩',
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        rank: 2,
        name: 'You (John)',
        xp: 10150,
        level: 5,
        streak: 7,
        avatar: '🧑',
        isCurrentUser: true,
      ),
      LeaderboardEntry(
        rank: 3,
        name: 'Emma Quick',
        xp: 9800,
        level: 5,
        streak: 15,
        avatar: '👧',
        isCurrentUser: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final rankings = _selectedTab == 'Global' ? globalRanking : friendsRanking;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Leaderboard',
          style: GoogleFonts.nunitoSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A237E),
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab Buttons
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('Global', 'Global'),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildTabButton('Friends', 'Friends'),
                ),
              ],
            ),
          ),

          // Top 3 Podium
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 2nd Place
                    if (rankings.length > 1)
                      _buildPodiumCard(
                        entry: rankings[1],
                        size: 'medium',
                        podiumHeight: 120,
                      )
                    else
                      const SizedBox(width: 100),

                    // 1st Place
                    _buildPodiumCard(
                      entry: rankings[0],
                      size: 'large',
                      podiumHeight: 180,
                    ),

                    // 3rd Place
                    if (rankings.length > 2)
                      _buildPodiumCard(
                        entry: rankings[2],
                        size: 'small',
                        podiumHeight: 80,
                      )
                    else
                      const SizedBox(width: 100),
                  ],
                ),
              ],
            ),
          ),

          // Ranking List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: rankings.length > 3 ? rankings.length - 3 : 0,
              itemBuilder: (context, index) {
                final entry = rankings[index + 3];
                return _buildRankingCard(entry);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, String value) {
    final isSelected = _selectedTab == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A237E) : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.nunitoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : const Color(0xFF546E7A),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumCard({
    required LeaderboardEntry entry,
    required String size,
    required double podiumHeight,
  }) {
    late double width;
    late double textScale;
    late Color podiumColor;

    switch (size) {
      case 'large':
        width = 100;
        textScale = 1.0;
        podiumColor = const Color(0xFFFFD700);
        break;
      case 'medium':
        width = 80;
        textScale = 0.9;
        podiumColor = const Color(0xFFC0C0C0);
        break;
      case 'small':
        width = 80;
        textScale = 0.8;
        podiumColor = const Color(0xFFCD7F32);
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // User Card
        Container(
          width: width,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.avatar,
                style: TextStyle(fontSize: 30 * textScale),
              ),
              const SizedBox(height: 8),
              Text(
                '#${entry.rank}',
                style: GoogleFonts.nunitoSans(
                  fontSize: 12 * textScale,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.name.split(' ').first,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 10 * textScale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF546E7A),
                ),
              ),
            ],
          ),
        ),

        // Podium
        Container(
          width: width,
          height: podiumHeight,
          decoration: BoxDecoration(
            color: podiumColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${entry.xp} XP',
                style: GoogleFonts.nunitoSans(
                  fontSize: 12 * textScale,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRankingCard(LeaderboardEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: entry.isCurrentUser ? const Color(0xFF29B6F6).withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: entry.isCurrentUser
            ? Border.all(color: const Color(0xFF29B6F6), width: 2)
            : null,
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
          // Rank
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '#${entry.rank}',
                style: GoogleFonts.nunitoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A237E),
                ),
              ),
            ),
          ),

          const SizedBox(width: 15),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.avatar,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.name,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A237E),
                        ),
                      ),
                    ),
                    if (entry.isCurrentUser)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF29B6F6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'You',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.stars, size: 14, color: Color(0xFFFFD700)),
                    const SizedBox(width: 5),
                    Text(
                      'Level ${entry.level}',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        color: const Color(0xFF546E7A),
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Icon(Icons.local_fire_department, size: 14, color: Color(0xFFFF6B6B)),
                    const SizedBox(width: 5),
                    Text(
                      '${entry.streak} day',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        color: const Color(0xFF546E7A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 15),

          // XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.xp}',
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A237E),
                ),
              ),
              Text(
                'XP',
                style: GoogleFonts.nunitoSans(
                  fontSize: 12,
                  color: const Color(0xFF546E7A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LeaderboardEntry {
  final int rank;
  final String name;
  final int xp;
  final int level;
  final int streak;
  final String avatar;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.xp,
    required this.level,
    required this.streak,
    required this.avatar,
    required this.isCurrentUser,
  });
}
