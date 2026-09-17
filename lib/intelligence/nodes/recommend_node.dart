import '../models/intelligence_models.dart';
import 'intelligence_node.dart';

class RecommendNode extends IntelligenceNode {
  RecommendNode();

  @override
  String get nodeId => 'recommend';

  @override
  int get priority => 45;

  @override
  bool isRelevant(ContextSnapshot snapshot) {
    return snapshot.openTasks.isNotEmpty ||
        snapshot.mentalBattery < 60 ||
        snapshot.goals.isNotEmpty;
  }

  AdaptiveDecision evaluateDecision(
    ContextSnapshot snapshot, {
    PersonalLearningContext? learningContext,
  }) {
    final situation = SituationModel.fromSnapshot(snapshot);
    final anticipation = AnticipationModel.evaluate(snapshot, situation);
    return AdaptiveDecision.evaluate(
      snapshot,
      situation,
      anticipation,
      learningContext: learningContext,
    );
  }

  @override
  IntelligenceResult execute(ContextSnapshot snapshot) {
    final decision = evaluateDecision(snapshot);
    final openTasks = snapshot.openTasks;
    final observations = <String>[];
    final actions = <IntelligentAction>[];

    if (openTasks.isEmpty) {
      observations.add('aucune action prioritaire détectée dans le snapshot');
      return IntelligenceResult(
        nodeId: nodeId,
        status: IntelligenceStatus.idle,
        confidence: 0.2,
        observations: observations,
        generatedAt: DateTime.now(),
        metadata: {
          'recommendedAction': null,
          'reason': 'no_open_task',
        },
      );
    }

    final bestTask = openTasks.reduce((a, b) {
      final scoreA = _taskPriorityScore(a);
      final scoreB = _taskPriorityScore(b);
      return scoreA >= scoreB ? a : b;
    });

    final battery = snapshot.mentalBattery;
    final actionType = battery < 40
        ? IntelligentActionType.takeBreak
        : snapshot.focusMinutesTotal < 30
            ? IntelligentActionType.startFocus
            : IntelligentActionType.startTask;

    final reason = battery < 40
        ? 'batterie faible : prioriser une pause courte et une micro-action simple'
        : 'tâche prioritaire ouverte et compatible avec le niveau d’énergie actuel';

    final action = IntelligentAction(
      actionId: 'task:${bestTask.id}',
      actionType: actionType,
      targetType: 'task',
      targetId: bestTask.id,
      priority: 90,
      reason: reason,
      metadata: {
        'title': bestTask.title,
        'priority': bestTask.priority ?? 'unknown',
        'urgency': bestTask.urgency ?? 'unknown',
      },
      createdAt: DateTime.now(),
    );

    actions.add(action);
    observations.add('action recommandée : ${bestTask.title}');
    if (battery < 40) {
      observations.add(
          'batterie mentale faible : privilégier une micro pause puis la tâche la plus critique');
    }

    return IntelligenceResult(
      nodeId: nodeId,
      status: battery < 40 ? IntelligenceStatus.warning : IntelligenceStatus.ok,
      confidence: 0.8,
      observations: observations,
      actions: actions,
      generatedAt: DateTime.now(),
      metadata: {
        'recommendedActionId': action.actionId,
        'recommendedTaskId': bestTask.id,
        'taskTitle': bestTask.title,
        'mentalBattery': battery,
        'decisionType': decision.decisionType,
        'decisionReason': decision.reason,
        'expectedBenefit': decision.expectedBenefit,
        'frictionTarget': decision.frictionTarget,
      },
    );
  }

  int _taskPriorityScore(TaskSummary task) {
    final priorityMap = {'Haute': 4, 'Moyenne': 2, 'Basse': 1};
    final urgencyMap = {'Haute': 4, 'Moyenne': 2, 'Basse': 1};
    final difficultyMap = {'Difficile': 3, 'Moyen': 2, 'Facile': 1};

    var score = 0;
    score += priorityMap[task.priority] ?? 0;
    score += urgencyMap[task.urgency] ?? 0;
    score += difficultyMap[task.difficulty] ?? 0;
    score += (task.estimatedTimeMinutes ?? 0) > 60 ? 2 : 0;
    return score;
  }
}
