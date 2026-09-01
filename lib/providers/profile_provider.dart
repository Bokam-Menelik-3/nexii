import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';
import '../core/services/profile_service.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileService _profileService;
  UserProfile? _profile;
  bool _isLoading = false;

  ProfileProvider(this._profileService);

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> loadProfile(String fallbackUid) async {
    _isLoading = true;
    notifyListeners();
    _profile = await _profileService.fetchProfile();
    if (_profile == null) {
      // Create a default profile if none exists
      _profile = UserProfile(uid: fallbackUid, name: 'Utilisateur Nexii');
      await _profileService.saveProfile(_profile!);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile newProfile) async {
    _profile = newProfile;
    notifyListeners();
    await _profileService.saveProfile(newProfile);
  }

  Future<void> recordBaseline({
    required int goalsCount,
    required int tasksCount,
    required int completedTasks,
    required int focusSessions,
    required int focusMinutes,
    Map<String, dynamic>? extra,
  }) async {
    if (_profile == null) return;

    final preferences = Map<String, dynamic>.from(_profile!.preferences);
    preferences['baselineSnapshot'] = {
      'createdAt': DateTime.now().toIso8601String(),
      'goalsCount': goalsCount,
      'tasksCount': tasksCount,
      'completedTasks': completedTasks,
      'focusSessions': focusSessions,
      'focusMinutes': focusMinutes,
      'mentalBattery': _profile!.mentalBattery,
      if (extra != null) ...extra,
    };

    await updateProfile(_profile!.copyWith(preferences: preferences));
  }

  void clearProfile() {
    _profile = null;
    notifyListeners();
  }

  Future<void> addXp(int xpAmount) async {
    if (_profile == null) return;
    int newXp = _profile!.xp + xpAmount;
    int newLevel = _profile!.level;
    if (newXp >= 100 * newLevel) {
      newXp -= 100 * newLevel;
      newLevel += 1;
    }
    final updated = _profile!.copyWith(xp: newXp, level: newLevel);
    await updateProfile(updated);
  }
}
