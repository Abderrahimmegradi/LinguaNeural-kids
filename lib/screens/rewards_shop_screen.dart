import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RewardsShopScreen extends StatefulWidget {
  const RewardsShopScreen({super.key});

  @override
  State<RewardsShopScreen> createState() => _RewardsShopScreenState();
}

class _RewardsShopScreenState extends State<RewardsShopScreen> {
  int _userCoins = 850;

  final List<Reward> rewards = [
    Reward(
      id: 'avatar_1',
      name: 'Cool Cat Avatar',
      description: 'Customize your profile with a cool cat',
      cost: 100,
      icon: '😺',
      category: 'Avatars',
      isUnlocked: false,
    ),
    Reward(
      id: 'avatar_2',
      name: 'Rocket Star Avatar',
      description: 'Zoom with this awesome rocket star',
      cost: 150,
      icon: '🚀',
      category: 'Avatars',
      isUnlocked: false,
    ),
    Reward(
      id: 'avatar_3',
      name: 'Magic Crown Avatar',
      description: 'Royal status with magical crown',
      cost: 200,
      icon: '👑',
      category: 'Avatars',
      isUnlocked: false,
    ),
    Reward(
      id: 'theme_1',
      name: 'Ocean Blue Theme',
      description: 'Fresh ocean vibes for your app',
      cost: 250,
      icon: '🌊',
      category: 'Themes',
      isUnlocked: false,
    ),
    Reward(
      id: 'theme_2',
      name: 'Forest Green Theme',
      description: 'Calm forest environment',
      cost: 250,
      icon: '🌲',
      category: 'Themes',
      isUnlocked: false,
    ),
    Reward(
      id: 'effect_1',
      name: 'Rainbow Effect',
      description: 'Colorful effects on lesson completion',
      cost: 180,
      icon: '🌈',
      category: 'Effects',
      isUnlocked: false,
    ),
    Reward(
      id: 'effect_2',
      name: 'Fireworks Effect',
      description: 'Celebrate with amazing fireworks',
      cost: 200,
      icon: '🎆',
      category: 'Effects',
      isUnlocked: false,
    ),
    Reward(
      id: 'badge_1',
      name: 'Gold Badge',
      description: 'Show off your achievement',
      cost: 300,
      icon: '🥇',
      category: 'Badges',
      isUnlocked: false,
    ),
  ];

  late List<Reward> filteredRewards;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    filteredRewards = rewards;
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All') {
        filteredRewards = rewards;
      } else {
        filteredRewards = rewards.where((r) => r.category == category).toList();
      }
    });
  }

  List<String> get categories {
    final cats = {'All', ...rewards.map((r) => r.category)};
    return cats.toList();
  }

  void _buyReward(Reward reward) {
    if (_userCoins >= reward.cost) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Buy ${reward.name}?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                reward.icon,
                style: const TextStyle(fontSize: 60),
              ),
              const SizedBox(height: 20),
              Text(
                'Cost: ${reward.cost} coins',
                style: GoogleFonts.nunitoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFFD700),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your coins: ${_userCoins - reward.cost}',
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  color: const Color(0xFF546E7A),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _userCoins -= reward.cost;
                  final index = rewards.indexWhere((r) => r.id == reward.id);
                  rewards[index] = Reward(
                    id: reward.id,
                    name: reward.name,
                    description: reward.description,
                    cost: reward.cost,
                    icon: reward.icon,
                    category: reward.category,
                    isUnlocked: true,
                  );
                  _filterByCategory(_selectedCategory);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${reward.name} unlocked!'),
                    backgroundColor: const Color(0xFF66BB6A),
                  ),
                );
              },
              child: const Text('Buy'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough coins!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Rewards Shop',
          style: GoogleFonts.nunitoSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A237E),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      '💰',
                      style: GoogleFonts.nunitoSans(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$_userCoins',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Banner
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFD700),
                  Color(0xFFFFA500),
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
            child: Row(
              children: [
                Text(
                  '🎁',
                  style: GoogleFonts.nunitoSans(fontSize: 50),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unlock Amazing Rewards',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Earn coins by completing lessons',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Category Filter
          Container(
            height: 50,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ChoiceChip(
                    label: Text(
                      category,
                      style: GoogleFonts.nunitoSans(
                        color: isSelected ? Colors.white : const Color(0xFF546E7A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF1A237E),
                    backgroundColor: Colors.grey[200],
                    onSelected: (selected) => _filterByCategory(category),
                  ),
                );
              },
            ),
          ),

          // Rewards Grid
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(20),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: filteredRewards
                  .map((reward) => _buildRewardCard(reward))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(Reward reward) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
        border: reward.isUnlocked
            ? Border.all(color: const Color(0xFF66BB6A), width: 2)
            : null,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: reward.isUnlocked
                            ? const Color(0xFF66BB6A).withOpacity(0.2)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          reward.icon,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      reward.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      reward.description,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11,
                        color: const Color(0xFF546E7A),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  child: reward.isUnlocked
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF66BB6A).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '✓ Unlocked',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF66BB6A),
                              ),
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () => _buyReward(reward),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            '${reward.cost}',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          if (reward.isUnlocked)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFF66BB6A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Reward {
  final String id;
  final String name;
  final String description;
  final int cost;
  final String icon;
  final String category;
  final bool isUnlocked;

  Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.icon,
    required this.category,
    required this.isUnlocked,
  });
}
