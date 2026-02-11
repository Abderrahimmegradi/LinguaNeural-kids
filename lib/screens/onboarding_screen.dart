import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Emotion-Aware Learning',
      'description': 'Our AI adapts to your child\'s emotions, creating a comfortable and fun environment.',
      'icon': Icons.emoji_emotions_outlined,
      'color': const Color(0xFF66BB6A),
    },
    {
      'title': 'Personalized Journey',
      'description': 'Every child gets a tailored learning path based on their level and style.',
      'icon': Icons.auto_awesome,
      'color': const Color(0xFFFF9800),
    },
    {
      'title': 'Build Confidence',
      'description': 'Gentle corrections and positive encouragement help children gain confidence.',
      'icon': Icons.thumb_up_outlined,
      'color': const Color(0xFF29B6F6),
    },
    {
      'title': 'Learn with Joy',
      'description': 'Transform language learning into an empowering and joyful experience.',
      'icon': Icons.celebration_outlined,
      'color': const Color(0xFFAB47BC),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, right: 20),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/home');
                  },
                  child: Text(
                    'Skip',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _pages[_currentPage]['color'] as Color,
                    ),
                  ),
                ),
              ),
            ),
            
            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingPageContent(
                    title: _pages[index]['title'] as String,
                    description: _pages[index]['description'] as String,
                    icon: _pages[index]['icon'] as IconData,
                    color: _pages[index]['color'] as Color,
                  );
                },
              ),
            ),
            
            // Indicators and Next Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 30 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? _pages[_currentPage]['color'] as Color
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Next Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Navigator.pushNamed(context, '/home');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage]['color'] as Color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPageContent extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const OnboardingPageContent({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 70,
              color: color,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A237E),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              fontSize: 16,
              height: 1.5,
              color: const Color(0xFF546E7A),
            ),
          ),
        ],
      ),
    );
  }
}