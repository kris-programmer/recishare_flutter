import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'my_home_page.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);

    // Ensure the widget is still mounted before navigating
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildPage(
                  title: 'Welcome to ReciShare!',
                  description:
                      'Discover and share amazing recipes with your friends.',
                  image: Icons.fastfood,
                ),
                _buildPage(
                  title: 'Save Your Favorites',
                  description:
                      'Keep track of your favorite recipes in one place.',
                  image: Icons.favorite,
                ),
                _buildPage(
                  title: 'Begin!',
                  description: 'Let’s dive into the world of recipes!',
                  image: Icons.check_circle,
                  isLastPage: true,
                  onComplete: _completeTutorial,
                ),
              ],
            ),
          ),
          _buildIndicator(),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          3, // Number of pages
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            width: _currentPage == index ? 12.0 : 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              color: _currentPage == index ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String description,
    required IconData image,
    bool isLastPage = false,
    VoidCallback? onComplete,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(image, size: 100, color: Colors.green),
          const SizedBox(height: 32),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (isLastPage)
            ElevatedButton(
              onPressed: onComplete,
              child: const Text('Get Started'),
            ),
        ],
      ),
    );
  }
}
