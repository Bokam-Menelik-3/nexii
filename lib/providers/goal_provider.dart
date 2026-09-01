import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../core/services/goal_service.dart';

class GoalProvider with ChangeNotifier {
  final GoalService _goalService;
  List<Goal> _goals = [];
  bool _isLoading = false;

  GoalProvider(this._goalService);

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;

  Future<void> loadGoals() async {
    _isLoading = true;
    notifyListeners();
    _goals = await _goalService.fetchGoals();
    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _goals = [];
    notifyListeners();
  }

  Future<void> addGoal(Goal goal) async {
    var toSave = goal;
    if (toSave.id.isEmpty) {
      toSave =
          toSave.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString());
    }
    _goals.add(toSave);
    notifyListeners();
    await _goalService.saveGoal(toSave);
  }

  Future<void> updateGoal(Goal goal) async {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
      notifyListeners();
      await _goalService.saveGoal(goal);
    }
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    notifyListeners();
    await _goalService.deleteGoal(id);
  }
}
