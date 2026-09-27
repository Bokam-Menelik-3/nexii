import '../models/intelligence_models.dart';

class N1DecisionEngine {
  const N1DecisionEngine();

  /// Canonical decision authority. Optionally receives node results (`pulse`,
  /// `livingGoals`, `understand`, `anticipate`) so their signals are
  /// interpreted here — the decision layer decides what signals mean; nodes
  /// never decide UX.
  N1Summary evaluate(
    ContextSnapshot snapshot, {
    IntelligenceResult? pulse,
    IntelligenceResult? livingGoals,
    IntelligenceResult? understand,
    IntelligenceResult? anticipate,
  }) {
    final rawPulseState = pulse?.metadata['pulseState'];
    final pulseState = rawPulseState is String ? rawPulseState : null;

    // Canonical Living Goals decision: only an at-risk goal becomes an
    // actionable risk flag for the ExperienceEngine. `goal_lag` (and every
    // other node state) stays informational via [N1Summary.goalState].
    final goalState = _goalStateFrom(livingGoals);
    final goalAtRisk = goalState == 'at_risk';
    final primaryGoalId =
        livingGoals?.metadata['primaryGoalId'] is String
            ? livingGoals!.metadata['primaryGoalId'] as String
            : null;

    // Canonical decision on the Understand signal: only an elevated workload
    // becomes an actionable risk flag for the ExperienceEngine. `reduced`
    // (reduced activity to watch) stays informational — its battery/stress
    // drivers already flow through the Pulse signal — and `stable` needs no
    // action. The full state stays on [N1Summary.understandState].
    final understandState = _understandStateFrom(understand);

    // Canonical decision on the Anticipate signal: the node's own
    // forward-looking accumulation maps 1:1 to `risk`/`clear` (no threshold
    // is re-computed here). Only the node's compounding-risk verdict
    // (`anticipation_risk`) becomes an actionable flag; the full state stays
    // on [N1Summary.anticipationState] for downstream intelligence.
    final anticipationState = _anticipationStateFrom(anticipate);

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
      // Canonical decision on the Pulse signal: only a recovery-grade pulse
      // becomes an actionable risk flag for the ExperienceEngine. Other pulse
      // states stay informational via [N1Summary.pulseState].
      if (pulseState == 'recovery_needed') 'pulse_recovery_needed',
      // Canonical decision on the Living Goals signal: only an at-risk goal
      // (node flag `goal_at_risk`) is promoted. `goal_lag` stays informational.
      if (goalAtRisk) 'goal_at_risk',
      // Canonical decision on the Understand signal: only an elevated
      // workload is promoted — it feeds the existing Pressure context.
      if (understandState == 'elevated') 'workload_elevated',
      // Canonical decision on the Anticipate signal: only the node's own
      // compounding forward-looking verdict is promoted — it contributes to
      // the existing Pressure context. Anticipation stays advisory: it never
      // triggers an action on its own, and `clear` stays informational.
      if (anticipationState == 'risk') 'anticipation_risk',
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
    // Precedence (central, not per-screen): Recovery > Pressure > CheckIn >
    // task priority > goal urgency. The at-risk goal recommendation is
    // appended last — so any task/battery/agenda recommendation keeps the
    // primary slot — and is withheld entirely while a recovery-grade state
    // is active (low battery or recovery Pulse).
    if (goalAtRisk &&
        snapshot.mentalBattery >= 35 &&
        pulseState != 'recovery_needed') {
      final primaryGoal = primaryGoalId == null
          ? null
          : snapshot.goals.where((goal) => goal.id == primaryGoalId);
      if (primaryGoal != null && primaryGoal.isNotEmpty) {
        recommendations.add(
            'Objectif « ${primaryGoal.first.title} » à risque : avance-le dès aujourd’hui pour le remettre sur trajectoire.');
      }
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
      pulseState: pulseState,
      goalState: goalState,
      understandState: understandState,
      anticipationState: anticipationState,
      primaryGoalId: primaryGoalId,
    );
  }

  /// Maps the Living Goals node result to the canonical [N1Summary.goalState]
  /// vocabulary — a faithful, deterministic reading of the node's own risk
  /// flags and status (no new goal algorithm). Returns `null` when the node
  /// did not run or when it had no active goal to evaluate (e.g. missions
  /// only), so consumers can ignore the signal entirely.
  String? _goalStateFrom(IntelligenceResult? livingGoals) {
    if (livingGoals == null) return null;
    final goalCount = livingGoals.metadata['goalCount'];
    if (goalCount is! num || goalCount <= 0) return null;
    if (livingGoals.riskFlags.contains('goal_at_risk')) return 'at_risk';
    if (livingGoals.riskFlags.contains('goal_lag')) return 'lagging';
    if (livingGoals.status == IntelligenceStatus.ok) return 'on_track';
    return 'stable';
  }

  /// Maps the Understand node's own workload classification (its `signal`
  /// metadata) to the canonical [N1Summary.understandState] vocabulary — a
  /// faithful 1:1 normalization with no new thresholds. Returns `null` when
  /// the node did not run (no meaningful signal) or when an unknown value
  /// appears, so consumers can ignore the signal entirely.
  String? _understandStateFrom(IntelligenceResult? understand) {
    final signal = understand?.metadata['signal'];
    if (signal is! String) return null;
    return switch (signal) {
      'charge de travail élevée' => 'elevated',
      "baisse d'activité à surveiller" => 'reduced',
      'état stable' => 'stable',
      _ => null,
    };
  }

  /// Maps the Anticipate node result to the canonical
  /// [N1Summary.anticipationState] vocabulary — a faithful reading of the
  /// node's own forward-looking decision: `risk` when the node flagged
  /// `anticipation_risk` (its internal risk accumulation reached the node's
  /// own threshold), `clear` when it detected no compounding risk, `null`
  /// when the node did not run. No threshold is re-computed here.
  String? _anticipationStateFrom(IntelligenceResult? anticipate) {
    if (anticipate == null) return null;
    if (anticipate.riskFlags.contains('anticipation_risk')) return 'risk';
    return 'clear';
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
