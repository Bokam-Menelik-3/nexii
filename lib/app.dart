import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/task_provider.dart';
import 'providers/agenda_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/focus_provider.dart';
import 'screens/budget_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/objectives_screen.dart';
import 'screens/agenda_screen.dart';
import 'screens/focus_screen.dart';
import 'screens/coach_screen.dart';

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool _initialized = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final profileProv = Provider.of<ProfileProvider>(context, listen: false);

      await auth.initialize();
      _isLoggedIn = auth.isLoggedIn;

      if (_isLoggedIn && auth.uid != null) {
        await profileProv.loadProfile(auth.uid!);
        try {
          final goalProv = Provider.of<GoalProvider>(context, listen: false);
          await goalProv.loadGoals();
        } catch (e) {}
        try {
          final taskProv = Provider.of<TaskProvider>(context, listen: false);
          await taskProv.loadTasks();
        } catch (e) {}
        final profile = profileProv.profile;
        if (profile != null) {
          final completed = profile.preferences['onboardingCompleted'] == true;
          if (completed) appState.completeOnboarding();
        }
      }
    } catch (e) {
      // In tests or environments where providers are not wired, skip initialization
      // and allow the widget tree to render (tests provide scoped providers).
    }

    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    if (!_initialized) {
      return const SplashScreen();
    }

    // If onboarding not complete, always show the onboarding flow first
    if (!state.isOnboardingComplete) {
      return const OnboardingScreen();
    }

    AuthProvider? auth;
    try {
      auth = Provider.of<AuthProvider>(context);
    } catch (e) {
      auth = null;
    }

    if (!state.isFirebaseConnected) {
      return const LoginScreen();
    }

    if (auth == null || !auth.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          final appState =
              Provider.of<AppStateProvider>(context, listen: false);
          appState.resetOnboarding();
        } catch (e) {}
        try {
          final profileProv =
              Provider.of<ProfileProvider>(context, listen: false);
          profileProv.clearProfile();
        } catch (e) {
          // ignore if profile provider not present in this context
        }
        try {
          final goalProv = Provider.of<GoalProvider>(context, listen: false);
          goalProv.clear();
        } catch (e) {}
        try {
          final taskProv = Provider.of<TaskProvider>(context, listen: false);
          taskProv.clear();
        } catch (e) {}
        try {
          final budgetProv =
              Provider.of<BudgetProvider>(context, listen: false);
          budgetProv.clear();
        } catch (e) {}
        try {
          final agendaProv =
              Provider.of<AgendaProvider>(context, listen: false);
          agendaProv.clear();
        } catch (e) {}
        try {
          final focusProv = Provider.of<FocusProvider>(context, listen: false);
          focusProv.clear();
        } catch (e) {}
      });
      return const LoginScreen();
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
  final List<Widget> _screens = [
    HomeScreen(),
    ObjectivesScreen(),
    AgendaScreen(),
    FocusScreen(),
    CoachScreen(),
    BudgetScreen(),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xff2563eb),
        unselectedItemColor:
            isDark ? const Color(0xff64748b) : const Color(0xff94a3b8),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        elevation: 8,
        onTap: (index) {
          state.setTabIndex(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Aujourd\'hui',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_outlined),
            activeIcon: Icon(Icons.flag),
            label: 'Objectifs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            activeIcon: Icon(Icons.timer),
            label: 'Focus',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome),
            label: 'Coach',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
        ],
      ),
    );
  }
}
