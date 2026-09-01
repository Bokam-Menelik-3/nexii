import 'package:flutter/foundation.dart';
import '../services/task_service.dart';
import '../services/goal_service.dart';
import '../services/agenda_service.dart';
import 'action_engine.dart';

class ActionEngineService {
  final ActionEngine _engine;

  ActionEngineService({
    required TaskService taskService,
    required GoalService goalService,
    required AgendaService agendaService,
  }) : _engine = ActionEngine(
          taskService: taskService,
          goalService: goalService,
          agendaService: agendaService,
        );

  Future<bool> executeIntent(Map<String, dynamic> intent) async {
    try {
      final action = intent['action']?.toString() ?? '';
      return await _engine.executeIntent(action, intent);
    } catch (e) {
      debugPrint('ActionEngineService.executeIntent error: $e');
      return false;
    }
  }
}
