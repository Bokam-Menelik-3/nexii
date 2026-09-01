import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  String _activity = '';
  String _productivityProblem = '';
  String _mood = '';

  void _nextPage() async {
    if (_currentIndex < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    // Finalize: persist answers temporarily and navigate to auth
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('onboarding_activity', _activity.trim());
    await prefs.setString(
        'onboarding_productivity_problem', _productivityProblem.trim());
    await prefs.setString('onboarding_mood', _mood.trim());

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
    }
  }

  Widget _pageWelcome() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 80, color: Color(0xff6366f1)),
            const SizedBox(height: 20),
            const Text('Bienvenue sur Nexii',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Quelques questions rapides pour te connaître.',
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _nextPage, child: const Text('Commencer'))
          ],
        ),
      ),
    );
  }

  Widget _pageActivity() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Que fais-tu actuellement ?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 18),
          TextField(
            onChanged: (v) => setState(() => _activity = v),
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ex: Étudiant, Développeur, Entrepreneur...'),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: _previousPage, child: const Text('Retour')),
              ElevatedButton(
                  onPressed: _activity.trim().isNotEmpty ? _nextPage : null,
                  child: const Text('Continuer')),
            ],
          )
        ],
      ),
    );
  }

  Widget _pageProblem() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Quel est ton principal problème avec ta productivité ?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 18),
          TextField(
            onChanged: (v) => setState(() => _productivityProblem = v),
            maxLines: 4,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ex: Je procrastine, je manque d\'organisation...'),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: _previousPage, child: const Text('Retour')),
              ElevatedButton(
                  onPressed:
                      _productivityProblem.trim().isNotEmpty ? _nextPage : null,
                  child: const Text('Continuer')),
            ],
          )
        ],
      ),
    );
  }

  Widget _pageMood() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Comment vas-tu ?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 18),
          TextField(
            onChanged: (v) => setState(() => _mood = v),
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ex: Fatigué·e, Motivé·e, Stressé·e...'),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: _previousPage, child: const Text('Retour')),
              ElevatedButton(
                  onPressed: _mood.trim().isNotEmpty ? _nextPage : null,
                  child: const Text('Se connecter / Créer un compte')),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (idx) => setState(() => _currentIndex = idx),
          children: [
            _pageWelcome(),
            _pageActivity(),
            _pageProblem(),
            _pageMood(),
          ],
        ),
      ),
    );
  }
}
