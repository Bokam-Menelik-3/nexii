import 'package:flutter/material.dart';

class AppStateProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _currentLocale = const Locale('fr', 'FR');

  bool _isOnboardingComplete = false;

  int _currentTabIndex = 0;

  ThemeMode get themeMode => _themeMode;
  Locale get currentLocale => _currentLocale;
  bool get isOnboardingComplete => _isOnboardingComplete;
  int get currentTabIndex => _currentTabIndex;
  bool get isFirebaseConnected =>
      true; // Toujours vrai pour la bêta pour ne pas bloquer

  void setTabIndex(int index) {
    if (index >= 0 && index <= 5) {
      _currentTabIndex = index;
      notifyListeners();
    }
  }

  void completeOnboarding() {
    _isOnboardingComplete = true;
    notifyListeners();
  }

  void resetOnboarding() {
    _isOnboardingComplete = false;
    _currentTabIndex = 0;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
