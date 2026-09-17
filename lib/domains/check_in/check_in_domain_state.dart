import 'package:flutter/foundation.dart';

/// Domain State Manager for Daily Check-In entries.
class CheckInDomainState extends ChangeNotifier {
  int _dailyMood = 3; // 1-5
  int _dailyEnergy = 3; // 1-5
  int _dailyMotivation = 3; // 1-5
  int _dailyStress = 3; // 1-5
  int _dailySleep = 3; // 1-5
  bool _hasCheckedInToday = false;
  String _lastManualCheckInDate = '';

  int get dailyMood => _dailyMood;
  int get dailyEnergy => _dailyEnergy;
  int get dailyMotivation => _dailyMotivation;
  int get dailyStress => _dailyStress;
  int get dailySleep => _dailySleep;
  bool get hasCheckedInToday => _hasCheckedInToday;
  String get lastManualCheckInDate => _lastManualCheckInDate;

  void submitCheckIn({
    required int mood,
    required int energy,
    required int motivation,
    required int stress,
    required int sleep,
    String? date,
  }) {
    _dailyMood = mood.clamp(1, 5);
    _dailyEnergy = energy.clamp(1, 5);
    _dailyMotivation = motivation.clamp(1, 5);
    _dailyStress = stress.clamp(1, 5);
    _dailySleep = sleep.clamp(1, 5);
    _hasCheckedInToday = true;
    _lastManualCheckInDate = date ?? DateTime.now().toIso8601String().split('T')[0];
    notifyListeners();
  }

  void loadFromCloud({
    required int mood,
    required int energy,
    required int motivation,
    required int stress,
    required int sleep,
    required String lastCheckInDate,
  }) {
    _dailyMood = mood;
    _dailyEnergy = energy;
    _dailyMotivation = motivation;
    _dailyStress = stress;
    _dailySleep = sleep;
    _lastManualCheckInDate = lastCheckInDate;
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    _hasCheckedInToday = _lastManualCheckInDate == todayStr;
    notifyListeners();
  }

  void clear() {
    _dailyMood = 3;
    _dailyEnergy = 3;
    _dailyMotivation = 3;
    _dailyStress = 3;
    _dailySleep = 3;
    _hasCheckedInToday = false;
    _lastManualCheckInDate = '';
    notifyListeners();
  }
}
