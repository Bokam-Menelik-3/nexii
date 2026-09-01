import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../core/services/task_service.dart';
import 'profile_provider.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService;
  List<Task> _tasks = [];
  bool _isLoading = false;

  TaskProvider(this._taskService);

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    _tasks = await _taskService.fetchTasks();
    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _tasks = [];
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    var toSave = task;
    if (toSave.id.isEmpty) {
      toSave =
          toSave.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString());
    }
    _tasks.add(toSave);
    notifyListeners();
    await _taskService.saveTask(toSave);
  }

  Future<void> updateTask(Task task, {ProfileProvider? profileProvider}) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      Task updatedTask = task;

      if (task.isCompleted && !task.xpAwarded) {
        int xp = 5;
        if (task.priority == 'Haute')
          xp = 15;
        else if (task.priority == 'Moyenne') xp = 10;

        if (profileProvider != null) {
          await profileProvider.addXp(xp);
          updatedTask = task.copyWith(xpAwarded: true);
        }
      }

      _tasks[index] = updatedTask;
      notifyListeners();
      await _taskService.saveTask(updatedTask);
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
    await _taskService.deleteTask(id);
  }
}
