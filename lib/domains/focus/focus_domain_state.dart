import 'package:flutter/foundation.dart';
import 'focus_session.dart';

/// Domain state manager for Focus Sessions and cumulative focus time.
class FocusDomainState extends ChangeNotifier {
  int _totalFocusMinutes = 0;
  String _selectedSound = 'Pluie';
  final List<FocusSession> _sessions = [];

  int get totalFocusMinutes => _totalFocusMinutes;
  String get selectedSound => _selectedSound;
  List<FocusSession> get sessions => List.unmodifiable(_sessions);

  void setTotalMinutes(int mins) {
    _totalFocusMinutes = mins;
    notifyListeners();
  }

  void setSelectedSound(String sound) {
    _selectedSound = sound;
    notifyListeners();
  }

  void recordSession(int minutes, {String mode = 'Pomodoro'}) {
    _totalFocusMinutes += minutes;
    _sessions.add(FocusSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      minutes: minutes,
      mode: mode,
      sound: _selectedSound,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  void clear() {
    _totalFocusMinutes = 0;
    _selectedSound = 'Pluie';
    _sessions.clear();
    notifyListeners();
  }
}
