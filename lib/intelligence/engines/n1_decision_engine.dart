import '../models/intelligence_models.dart';

class N1DecisionEngine {
  const N1DecisionEngine();

  N1Summary evaluate(ContextSnapshot snapshot) {
    final openTasks = snapshot.openTasks;
    final topTask = openTasks.isNotEmpty
        ? openTasks.reduce((a, b) {
            final scoreA = _taskPriorityScore(a);
            final scoreB = _taskPriorityScore(b);
            return scoreA >= scoreB ? a : b;
          })
        : null;

    final riskFlags = <String>{
      ...snapshot.riskFlags,
      if (snapshot.mentalBattery < 35) 'mental_battery_low',
      if ((snapshot.agendaEvents.isNotEmpty && topTask != null))
        'agenda_conflict_possible',
      if (snapshot.focusMinutesTotal < 30) 'low_focus_time',
    }.toList();

    final recommendations = <String>[];
    if (topTask != null) {
      recommendations.add('Commencer par ${topTask.title}.');
    }
    if (snapshot.mentalBattery < 50) {
      recommendations.add(
          'Réduire la charge cognitive et favoriser une micro-action simple.');
    }
    if (snapshot.agendaEvents.isNotEmpty) {
      recommendations.add(
          'Vérifier les événements à venir afin d’éviter un conflit de planification.');
    }

    final primaryActionId = topTask != null ? 'task:${topTask.id}' : null;
    final primaryReason = topTask != null
        ? 'Tâche ouverte prioritée selon urgence, difficulté et énergie disponible.'
        : 'Aucune tâche prioritaire active détectée.';

    final primaryAction = topTask != null
        ? IntelligentAction(
            actionId: primaryActionId!,
            actionType: IntelligentActionType.startTask,
            targetType: 'task',
            targetId: topTask.id,
            priority: 90,
            reason: primaryReason,
            metadata: {
              'title': topTask.title,
              'priority': topTask.priority ?? 'unknown',
              'urgency': topTask.urgency ?? 'unknown',
            },
            createdAt: DateTime.now(),
          )
        : null;

    final confidence = snapshot.openTasks.isEmpty
        ? 0.15
        : (1.0 - ((snapshot.mentalBattery / 100.0) * 0.3)).clamp(0.2, 0.94);

    return N1Summary(
      summaryId: 'n1_${DateTime.now().millisecondsSinceEpoch}',
      generatedAt: DateTime.now(),
      currentStateSummary: _currentStateSummary(snapshot),
      primaryActionId: primaryActionId,
      primaryReason: primaryReason,
      priorityLevel: _priorityLevelFrom(snapshot, topTask),
      confidence: confidence,
      riskFlags: riskFlags,
      recommendations: recommendations,
      blockers: snapshot.riskFlags,
      contextTags: [
        if (snapshot.mentalBattery < 40) 'low_energy',
        if (snapshot.agendaEvents.isNotEmpty) 'agenda_present',
        if (topTask != null) 'task_priority_detected',
      ],
      primaryAction: primaryAction,
    );
  }

  int _taskPriorityScore(TaskSummary task) {
    var score = 0;
    final priorityMap = {'Haute': 4, 'Moyenne': 2, 'Basse': 1};
    final urgencyMap = {'Haute': 4, 'Moyenne': 2, 'Basse': 1};
    final difficultyMap = {'Difficile': 3, 'Moyen': 2, 'Facile': 1};

    score += priorityMap[task.priority] ?? 0;
    score += urgencyMap[task.urgency] ?? 0;
    score += difficultyMap[task.difficulty] ?? 0;
    score += (task.estimatedTimeMinutes ?? 0) > 60 ? 2 : 0;
    return score;
  }

  PriorityLevel _priorityLevelFrom(
      ContextSnapshot snapshot, TaskSummary? topTask) {
    if (snapshot.mentalBattery < 30 ||
        snapshot.riskLevel == RiskLevel.critical) {
      return PriorityLevel.critical;
    }
    if (snapshot.mentalBattery < 50 ||
        (topTask != null && snapshot.agendaEvents.isNotEmpty)) {
      return PriorityLevel.high;
    }
    if (snapshot.openTasks.isNotEmpty || snapshot.riskFlags.isNotEmpty) {
      return PriorityLevel.medium;
    }
    return PriorityLevel.low;
  }

  String _currentStateSummary(ContextSnapshot snapshot) {
    final taskPart = snapshot.openTasks.isNotEmpty
        ? '${snapshot.openTasks.length} tâches ouvertes'
        : 'aucune tâche ouverte';
    final energyPart = 'énergie ${snapshot.mentalBattery}%';
    final agendaPart = snapshot.agendaEvents.isNotEmpty
        ? 'avec ${snapshot.agendaEvents.length} événement(s) planifié(s)'
        : 'sans événement planifié';
    return '$taskPart, $energyPart, $agendaPart.';
  }
}
