import 'package:flutter/foundation.dart';
import 'task_item.dart';

/// Domain state manager for Task Items.
class TaskDomainState extends ChangeNotifier {
  final List<TaskItem> _tasks = [];

  List<TaskItem> get tasks => List.unmodifiable(_tasks);

  List<Map<String, dynamic>> get tasksAsMaps =>
      _tasks.map((t) => t.toMap()).toList();

  int get count => _tasks.length;
  bool get isEmpty => _tasks.isEmpty;

  void setTasks(List<Map<String, dynamic>> rawList) {
    _tasks.clear();
    for (final item in rawList) {
      _tasks.add(TaskItem.fromMap(Map<String, dynamic>.from(item)));
    }
    notifyListeners();
  }

  void addTask(TaskItem task) {
    _tasks.add(task);
    notifyListeners();
  }

  void toggleTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted);
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void addSubTask(String taskId, String title) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final subtasks = List<Map<String, dynamic>>.from(_tasks[index].subtasks);
      subtasks.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': title,
        'isCompleted': false,
      });
      _tasks[index] = _tasks[index].copyWith(subtasks: subtasks);
      notifyListeners();
    }
  }

  void toggleSubTask(String taskId, String subtaskId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final subtasks = List<Map<String, dynamic>>.from(_tasks[index].subtasks);
      final stIndex = subtasks.indexWhere((st) => st['id'] == subtaskId);
      if (stIndex != -1) {
        subtasks[stIndex]['isCompleted'] = !(subtasks[stIndex]['isCompleted'] == true);
        _tasks[index] = _tasks[index].copyWith(subtasks: subtasks);
        notifyListeners();
      }
    }
  }

  void deleteSubTask(String taskId, String subtaskId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final subtasks = List<Map<String, dynamic>>.from(_tasks[index].subtasks);
      subtasks.removeWhere((st) => st['id'] == subtaskId);
      _tasks[index] = _tasks[index].copyWith(subtasks: subtasks);
      notifyListeners();
    }
  }

  void clear() {
    _tasks.clear();
    notifyListeners();
  }
}
