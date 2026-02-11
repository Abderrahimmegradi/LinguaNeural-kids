import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  int _currentCardIndex = 0;
  bool _isFlipped = false;

  final List<VocabularyWord> words = [
    VocabularyWord(
      english: 'Hello',
      translation: 'Bonjour',
      pronunciation: 'hə-ˈlō',
      example: 'Hello, how are you?',
      category: 'Greetings',
      level: 1,
    ),
    VocabularyWord(
      english: 'Goodbye',
      translation: 'Au revoir',
      pronunciation: 'ˌɡu̇d-ˈbī',
      example: 'Goodbye, see you later!',
      category: 'Greetings',
      level: 1,
    ),
    VocabularyWord(
      english: 'Thank you',
      translation: 'Merci',
      pronunciation: 'ˈthä-ŋk ˈyü',
      example: 'Thank you for your help!',
      category: 'Politeness',
      level: 1,
    ),
    VocabularyWord(
      english: 'Please',
      translation: 'S\'il vous plaît',
      pronunciation: 'ˈplēz',
      example: 'Please sit down.',
      category: 'Politeness',
      level: 1,
    ),
    VocabularyWord(
      english: 'Water',
      translation: 'Eau',
      pronunciation: 'ˈwȯ-tər',
      example: 'I drink water every day.',
      category: 'Food & Drinks',
      level: 1,
    ),
    VocabularyWord(
      english: 'Food',
      translation: 'Nourriture',
      pronunciation: 'ˈfüd',
      example: 'This food is delicious!',
      category: 'Food & Drinks',
      level: 1,
    ),
    VocabularyWord(
      english: 'Family',
      translation: 'Famille',
      pronunciation: 'ˈfa-mə-lē',
      example: 'My family is very important to me.',
      category: 'People',
      level: 2,
    ),
    VocabularyWord(
      english: 'Friend',
      translation: 'Ami',
      pronunciation: 'ˈfrend',
      example: 'She is my best friend.',
      category: 'People',
      level: 1,
    ),
  ];

  late List<VocabularyWord> filteredWords;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    filteredWords = words;
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All') {
        filteredWords = words;
      } else {
        filteredWords = words.where((w) => w.category == category).toList();
      }
      _currentCardIndex = 0;
      _isFlipped = false;
    });
  }

  List<String> get categories {
    final cats = {'All', ...words.map((w) => w.category)};
    return cats.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Vocabulary',
          style: GoogleFonts.nunitoSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A237E),
          ),
        ),
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 60,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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

          // Flashcard
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isFlipped = !_isFlipped;
                      });
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: _isFlipped
                          ? _buildFlippedCard(filteredWords[_currentCardIndex])
                          : _buildFrontCard(filteredWords[_currentCardIndex]),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Card Info
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Example',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 14,
                            color: const Color(0xFF546E7A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          filteredWords[_currentCardIndex].example,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A237E),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Progress
                  Text(
                    '${_currentCardIndex + 1}/${filteredWords.length}',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF546E7A),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Navigation Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _currentCardIndex > 0
                            ? () {
                                setState(() {
                                  _currentCardIndex--;
                                  _isFlipped = false;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Previous'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF29B6F6),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(width: 15),
                      ElevatedButton.icon(
                        onPressed: _currentCardIndex < filteredWords.length - 1
                            ? () {
                                setState(() {
                                  _currentCardIndex++;
                                  _isFlipped = false;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Next'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF66BB6A),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrontCard(VocabularyWord word) {
    return Container(
      key: const ValueKey('front'),
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF29B6F6),
            Color(0xFF66BB6A),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Tap to reveal',
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            word.english,
            style: GoogleFonts.nunitoSans(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            word.pronunciation,
            style: GoogleFonts.nunitoSans(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlippedCard(VocabularyWord word) {
    return Container(
      key: const ValueKey('back'),
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFAB47BC),
            Color(0xFFFF6E40),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Translation',
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            word.translation,
            style: GoogleFonts.nunitoSans(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              'Level ${word.level} • ${word.category}',
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VocabularyWord {
  final String english;
  final String translation;
  final String pronunciation;
  final String example;
  final String category;
  final int level;

  VocabularyWord({
    required this.english,
    required this.translation,
    required this.pronunciation,
    required this.example,
    required this.category,
    required this.level,
  });
}
