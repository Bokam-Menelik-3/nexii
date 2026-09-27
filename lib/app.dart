import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state_provider.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/focus_screen.dart';
import 'screens/progression_screen.dart';
import 'screens/coach_screen.dart';

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    if (!state.isFirebaseConnected) {
      return const LoginScreen();
    }
    if (!state.isOnboardingComplete) {
      return const OnboardingScreen();
    }
    return const MainNavigationScreen();
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final List<Widget> _screens = const [
    HomeScreen(),
    TasksScreen(),
    FocusScreen(),
    ProgressionScreen(),
    CoachScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = state.currentTabIndex;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0),
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xff2563eb),
          unselectedItemColor: isDark ? const Color(0xff64748b) : const Color(0xff94a3b8),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          backgroundColor: isDark ? const Color(0xff0b1120) : const Color(0xffffffff),
          onTap: (index) {
            state.setTabIndex(index);
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: state.currentLocale.languageCode == 'en'
                  ? 'Today'
                  : (state.currentLocale.languageCode == 'es' ? 'Hoy' : 'Aujourd\'hui'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.check_circle_outline),
              activeIcon: const Icon(Icons.check_circle),
              label: state.currentLocale.languageCode == 'en'
                  ? 'Tasks'
                  : (state.currentLocale.languageCode == 'es' ? 'Tareas' : 'Tâches'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.timer_outlined),
              activeIcon: const Icon(Icons.timer),
              label: 'Focus',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.trending_up_outlined),
              activeIcon: const Icon(Icons.trending_up),
              label: state.currentLocale.languageCode == 'en'
                  ? 'Progress'
                  : (state.currentLocale.languageCode == 'es' ? 'Progresión' : 'Progression'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.auto_awesome_outlined),
              activeIcon: const Icon(Icons.auto_awesome),
              label: 'Coach',
            ),
          ],
        ),
      ),
    );
  }
}