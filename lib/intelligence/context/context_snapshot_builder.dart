import '../models/intelligence_models.dart';

class ContextSnapshotBuilder {
  const ContextSnapshotBuilder();

  ContextSnapshot build({
    required String? userId,
    required String? displayName,
    required int? age,
    required bool isAnonymous,
    required String locale,
    required bool onboardingComplete,
    required List<Map<String, dynamic>> tasks,
    required List<Map<String, dynamic>> agendaEvents,
    required List<Map<String, dynamic>> goals,
    required List<Map<String, dynamic>> missions,
    required int xp,
    required int level,
    required int streak,
    required int disciplineScore,
    required int auraScore,
    required String? currentMood,
    required int? dailyMood,
    required int? dailyEnergy,
    required int? dailyMotivation,
    required int? dailyStress,
    required int? dailySleep,
    required bool hasCheckedInToday,
    required int mentalBattery,
    required int focusMinutesTotal,
    required double totalBudget,
    required double remainingBudget,
    required DateTime now,
    List<String>? riskFlags,
    RiskLevel riskLevel = RiskLevel.low,
  }) {
    final taskSummaries = tasks.map(_mapTask).toList();
    final openTasks = taskSummaries.where((t) => !t.isCompleted).toList();
    final agendaSummaries = agendaEvents.map(_mapAgenda).toList();
    final upcomingEvents = agendaSummaries
        .where((event) => event.startMinutesFromNow != null)
        .toList();

    final goalSummaries = goals.map(_mapGoal).toList();
    final missionSummaries = missions.map(_mapMission).toList();

    final resolvedRiskFlags = <String>{
      ...?riskFlags,
      if (mentalBattery < 35) 'low_mental_battery',
      if (openTasks.length > 5) 'task_backlog_high',
      if (agendaSummaries.isNotEmpty && openTasks.isNotEmpty)
        'agenda_and_tasks_overlap_risk',
    }.toList();

    final resolvedRiskLevel = riskLevel;

    return ContextSnapshot(
      userId: userId,
      displayName: displayName,
      age: age,
      isAnonymous: isAnonymous,
      locale: locale,
      onboardingComplete: onboardingComplete,
      tasks: taskSummaries,
      openTasks: openTasks,
      agendaEvents: agendaSummaries,
      upcomingEvents: upcomingEvents,
      mentalBattery: mentalBattery,
      focusMinutesTotal: focusMinutesTotal,
      currentMood: currentMood,
      dailyMood: dailyMood,
      dailyEnergy: dailyEnergy,
      dailyMotivation: dailyMotivation,
      dailyStress: dailyStress,
      dailySleep: dailySleep,
      hasCheckedInToday: hasCheckedInToday,
      goals: goalSummaries,
      missions: missionSummaries,
      xp: xp,
      level: level,
      streak: streak,
      disciplineScore: disciplineScore,
      auraScore: auraScore,
      totalBudget: totalBudget,
      remainingBudget: remainingBudget,
      now: now,
      timeOfDay: _timeOfDay(now.hour),
      dayOfWeek: now.weekday,
      riskFlags: resolvedRiskFlags,
      riskLevel: resolvedRiskLevel,
      snapshotVersion: 1,
      generatedAt: DateTime.now(),
      source: 'AppStateProvider',
    );
  }

  TaskSummary _mapTask(Map<String, dynamic> task) {
    final subtasks =
        task['subtasks'] is List ? task['subtasks'] as List : const <dynamic>[];
    return TaskSummary(
      id: task['id']?.toString() ??
          'task_${DateTime.now().millisecondsSinceEpoch}',
      title: task['title']?.toString() ?? 'Sans titre',
      isCompleted: task['isCompleted'] == true,
      priority: task['priority']?.toString(),
      urgency: task['urgency']?.toString(),
      difficulty: task['difficulty']?.toString(),
      estimatedTimeMinutes:
          _toInt(task['estimatedTime']) ?? _toInt(task['durationMinutes']),
      energyNeeded: task['energyNeeded']?.toString(),
      category: task['category']?.toString(),
      subtaskCount: subtasks.length,
      linkedGoalId: task['linkedGoalId']?.toString(),
    );
  }

  AgendaEventSummary _mapAgenda(Map<String, dynamic> event) {
    final timeRaw = event['time']?.toString() ?? '';
    final startMinutesFromNow = _minutesUntilEvent(timeRaw);
    return AgendaEventSummary(
      id: event['id']?.toString() ??
          'agenda_${DateTime.now().millisecondsSinceEpoch}',
      title: event['title']?.toString() ?? 'Événement',
      time: timeRaw,
      startMinutesFromNow: startMinutesFromNow,
      durationMinutes: _toInt(event['durationMinutes']) ?? 30,
      importance: event['importance']?.toString(),
      kind: event['kind']?.toString() ?? 'agenda',
    );
  }

  GoalSummary _mapGoal(Map<String, dynamic> goal) {
    return GoalSummary(
      id: goal['id']?.toString() ??
          'goal_${DateTime.now().millisecondsSinceEpoch}',
      title: goal['title']?.toString() ?? 'Objectif',
      progress: (goal['progress'] is num)
          ? (goal['progress'] as num).toDouble()
          : 0.0,
      category: goal['category']?.toString(),
    );
  }

  MissionSummary _mapMission(Map<String, dynamic> mission) {
    return MissionSummary(
      id: mission['id']?.toString() ??
          'mission_${DateTime.now().millisecondsSinceEpoch}',
      title: mission['title']?.toString() ?? 'Mission',
      progress: (mission['progress'] is num)
          ? (mission['progress'] as num).toDouble()
          : 0.0,
      isCompleted: mission['isCompleted'] == true,
      xp: _toInt(mission['xp']) ?? 0,
      claimed: mission['claimed'] == true,
    );
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  String _timeOfDay(int hour) {
    if (hour < 6) return 'night';
    if (hour < 12) return 'morning';
    if (hour < 18) return 'afternoon';
    return 'evening';
  }

  int? _minutesUntilEvent(String rawTime) {
    if (rawTime.isEmpty) return null;

    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(rawTime);
    if (match == null) return null;

    final hour = int.tryParse(match.group(1) ?? '') ?? 0;
    final minute = int.tryParse(match.group(2) ?? '') ?? 0;

    final eventDateTime = DateTime.now();
    final candidate = DateTime(
      eventDateTime.year,
      eventDateTime.month,
      eventDateTime.day,
      hour,
      minute,
    );

    final diff = candidate.difference(DateTime.now()).inMinutes;
    return diff < 0 ? null : diff;
  }
}
