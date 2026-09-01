import '../services/task_service.dart';
import '../services/goal_service.dart';
import '../services/agenda_service.dart';
import '../../models/task_model.dart';
import '../../models/goal_model.dart';
import '../../models/agenda_event_model.dart';

class ActionEngine {
  final TaskService _taskService;
  final GoalService _goalService;
  final AgendaService _agendaService;

  ActionEngine({
    required TaskService taskService,
    required GoalService goalService,
    required AgendaService agendaService,
  })  : _taskService = taskService,
        _goalService = goalService,
        _agendaService = agendaService;

  /// Exécute une action structurée (Intent) de manière déterministe
  Future<bool> executeIntent(
      String actionType, Map<String, dynamic> payload) async {
    try {
      switch (actionType) {
        case 'create_task':
          return await _createTask(payload);
        case 'update_task':
          return await _updateTask(payload);
        case 'delete_task':
          return await _deleteTask(payload);
        case 'create_goal':
          return await _createGoal(payload);
        case 'update_goal':
          return await _updateGoal(payload);
        case 'create_event':
          return await _createEvent(payload);
        case 'reschedule_task':
          return await _rescheduleTask(payload);
        default:
          print("Action non supportée: $actionType");
          return false;
      }
    } catch (e) {
      print("Erreur d'exécution de l'action $actionType: $e");
      return false;
    }
  }

  Future<bool> _createTask(Map<String, dynamic> payload) async {
    if (!payload.containsKey('title')) return false;
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: payload['title'],
      subtitle: payload['subtitle'] ?? '',
      priority: payload['priority'] ?? 'Moyenne',
      linkedGoalId: payload['linkedGoalId'] ?? '',
    );
    await _taskService.saveTask(task);
    return true;
  }

  Future<bool> _updateTask(Map<String, dynamic> payload) async {
    if (!payload.containsKey('id')) return false;
    // Ideally, we fetch the existing task, merge, and save.
    // For simplicity, we assume full payload is provided.
    final task = Task.fromMap(payload);
    await _taskService.saveTask(task);
    return true;
  }

  Future<bool> _deleteTask(Map<String, dynamic> payload) async {
    if (!payload.containsKey('id')) return false;
    await _taskService.deleteTask(payload['id']);
    return true;
  }

  Future<bool> _createGoal(Map<String, dynamic> payload) async {
    if (!payload.containsKey('title')) return false;
    final goal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: payload['title'],
      priority: payload['priority'] ?? 'Moyenne',
      deadline: payload['deadline'] != null
          ? DateTime.tryParse(payload['deadline'])
          : null,
    );
    await _goalService.saveGoal(goal);
    return true;
  }

  Future<bool> _updateGoal(Map<String, dynamic> payload) async {
    if (!payload.containsKey('id')) return false;
    final goal = Goal.fromMap(payload);
    await _goalService.saveGoal(goal);
    return true;
  }

  Future<bool> _createEvent(Map<String, dynamic> payload) async {
    if (!payload.containsKey('title') ||
        !payload.containsKey('startTime') ||
        !payload.containsKey('endTime')) return false;
    final event = AgendaEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: payload['title'],
      startTime: DateTime.parse(payload['startTime']),
      endTime: DateTime.parse(payload['endTime']),
      linkedTaskId: payload['linkedTaskId'],
    );
    await _agendaService.saveEvent(event);
    return true;
  }

  Future<bool> _rescheduleTask(Map<String, dynamic> payload) async {
    if (!payload.containsKey('taskId') || !payload.containsKey('newStartTime'))
      return false;

    final taskId = payload['taskId']?.toString() ?? '';
    final newStartRaw = payload['newStartTime']?.toString();
    final newEndRaw = payload['newEndTime']?.toString();

    if (taskId.isEmpty || newStartRaw == null) return false;

    DateTime? newStart;
    DateTime? newEnd;
    try {
      newStart = DateTime.parse(newStartRaw);
      if (newEndRaw != null) newEnd = DateTime.parse(newEndRaw);
    } catch (e) {
      return false; // invalid date format
    }

    // Fetch events and find the one linked to this task
    final events = await _agendaService.fetchEvents();
    AgendaEvent? matched;
    for (final e in events) {
      if (e.linkedTaskId == taskId) {
        matched = e;
        break;
      }
    }

    if (matched == null) {
      return false; // no linked event found
    }

    final AgendaEvent oldEvent = matched;
    // Determine new end time: if not provided, keep same duration
    if (newEnd == null) {
      final duration = oldEvent.endTime.difference(oldEvent.startTime);
      newEnd = newStart.add(duration);
    }

    final updated = oldEvent.copyWith(startTime: newStart, endTime: newEnd);

    try {
      await _agendaService.saveEvent(updated);
      return true;
    } catch (e) {
      return false;
    }
  }
}
