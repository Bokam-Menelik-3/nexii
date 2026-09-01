import 'dart:async';
import 'package:flutter/material.dart';
import '../models/focus_session_model.dart';
import '../core/services/focus_service.dart';

class FocusProvider with ChangeNotifier {
  final FocusService _focusService;

  FocusProvider(this._focusService);

  int _focusMinutesTotal = 0;
  bool _isFocusing = false;
  String _selectedSound = 'Pluie en Forêt';

  Timer? _timer;
  int _secondsRemaining = 25 * 60;
  int _initialSeconds = 25 * 60;
  String _currentMode = 'Productive';
  DateTime? _sessionStartTime;

  int get focusMinutesTotal => _focusMinutesTotal;
  bool get isFocusing => _isFocusing;
  String get selectedSound => _selectedSound;
  int get secondsRemaining => _secondsRemaining;
  String get currentMode => _currentMode;

  void setMode(String mode) {
    _currentMode = mode;
    if (mode == 'Flow')
      _initialSeconds = 40 * 60;
    else if (mode == 'Productive')
      _initialSeconds = 25 * 60;
    else if (mode == 'Tired') _initialSeconds = 20 * 60;

    if (!_isFocusing) {
      _secondsRemaining = _initialSeconds;
      notifyListeners();
    }
  }

  void startFocus() {
    _isFocusing = true;
    _sessionStartTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        stopFocus(completed: true);
      }
    });
    notifyListeners();
  }

  void pauseFocus() {
    _timer?.cancel();
    _isFocusing = false;
    notifyListeners();
  }

  void resumeFocus() {
    if (!_isFocusing && _secondsRemaining > 0) {
      startFocus();
    }
  }

  void stopFocus({bool completed = false, String? uid, String? taskId}) async {
    _timer?.cancel();
    _isFocusing = false;

    int secondsElapsed = _initialSeconds - _secondsRemaining;
    int minutesCompleted = secondsElapsed ~/ 60;

    if (minutesCompleted > 0) {
      _focusMinutesTotal += minutesCompleted;
    }

    if (uid != null && _sessionStartTime != null) {
      final session = FocusSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: uid,
        linkedTaskId: taskId,
        startedAt: _sessionStartTime!,
        endedAt: DateTime.now(),
        duration: minutesCompleted,
        completed: completed,
        mode: _currentMode,
      );
      await _focusService.saveSession(session);
    }

    _secondsRemaining = _initialSeconds;
    notifyListeners();
  }

  void setSound(String sound) {
    _selectedSound = sound;
    notifyListeners();
  }

  void clear() {
    _timer?.cancel();
    _isFocusing = false;
    _focusMinutesTotal = 0;
    _secondsRemaining = _initialSeconds;
    _sessionStartTime = null;
    notifyListeners();
  }
}
