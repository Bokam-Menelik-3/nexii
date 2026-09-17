import 'package:flutter/foundation.dart';

/// Domain State Manager for Mental Battery and Cognitive Capacity.
class MentalBatteryDomainState extends ChangeNotifier {
  int _mentalBattery = 82; // 0 to 100
  int _cognitiveFatigue = 28; // 0 to 100
  int _emotionalLoad = 18; // 0 to 100
  int _recoveryIndex = 88; // 0 to 100
  bool _isCrisisMode = false;

  int get mentalBattery => _mentalBattery;
  int get cognitiveFatigue => _cognitiveFatigue;
  int get emotionalLoad => _emotionalLoad;
  int get recoveryIndex => _recoveryIndex;
  bool get isCrisisMode => _isCrisisMode;

  void setBattery(int value) {
    _mentalBattery = value.clamp(0, 100);
    notifyListeners();
  }

  void updateBattery(int delta) {
    _mentalBattery = (_mentalBattery + delta).clamp(0, 100);
    notifyListeners();
  }

  void setCrisisMode(bool enabled, {bool adjustBattery = true}) {
    _isCrisisMode = enabled;
    if (enabled && adjustBattery) {
      _mentalBattery = (_mentalBattery - 20).clamp(0, 100);
    }
    notifyListeners();
  }

  void setCognitiveFatigue(int value) {
    _cognitiveFatigue = value.clamp(0, 100);
    notifyListeners();
  }

  void setRecoveryIndex(int index) {
    _recoveryIndex = index.clamp(0, 100);
    notifyListeners();
  }

  void clear() {
    _mentalBattery = 82;
    _cognitiveFatigue = 28;
    _emotionalLoad = 18;
    _recoveryIndex = 88;
    _isCrisisMode = false;
    notifyListeners();
  }
}
