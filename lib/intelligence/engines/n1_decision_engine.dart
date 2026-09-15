import '../models/intelligence_models.dart';

class N1DecisionEngine {
  const N1DecisionEngine();

  N1Summary evaluate(
    ContextSnapshot snapshot, {
    List<String>? nodeRiskFlags,
    List<String>? nodeRecommendations,
  }) {
    final openTasks = snapshot.openTasks;
    final topTask = openTasks.isNotEmpty
        ? openTasks.reduce((a, b) {
            final scoreA = _taskPriorityScore(a);
            final scoreB = _taskPriorityScore(b);
            return scoreA >= scoreB ? a : b;
          })
        : null;

    final frictionResult = _detectFriction(snapshot, topTask);

    final riskFlags = <String>{
      ...snapshot.riskFlags,
      ...?nodeRiskFlags,

      if (snapshot.mentalBattery < 35) 'mental_battery_low',
      if (snapshot.agendaEvents.isNotEmpty && topTask != null)
        'agenda_conflict_possible',
      if (snapshot.focusMinutesTotal < 30 && openTasks.isNotEmpty)
        'low_focus_time',
      if (frictionResult.riskFlag != null) frictionResult.riskFlag!,
    }.toList();

    final recommendations = <String>{
      ...?nodeRecommendations,
      if (frictionResult.recommendation != null)
        frictionResult.recommendation!,
      if (frictionResult.frictionType == 'NO_FRICTION' && topTask != null)
        'Commencer par ${topTask.title}.',
      if (snapshot.mentalBattery < 50 && frictionResult.frictionType == 'NO_FRICTION')
        'Réduire la charge cognitive et favoriser une micro-action simple.',
    }.toList();

    final IntelligentAction? primaryAction = frictionResult.action ??
        (topTask != null
            ? IntelligentAction(
                actionId: 'task:${topTask.id}',
                actionType: IntelligentActionType.startTask,
                targetType: 'task',
                targetId: topTask.id,
                priority: 90,
                reason:
                    'Tâche ouverte prioritée selon urgence, difficulté et énergie disponible.',
                metadata: {
                  'title': topTask.title,
                  'priority': topTask.priority ?? 'unknown',
                  'urgency': topTask.urgency ?? 'unknown',
                },
                createdAt: DateTime.now(),
              )
            : null);

    final primaryActionId = primaryAction?.actionId;
    final primaryReason = frictionResult.evidence.isNotEmpty
        ? '${frictionResult.reason} (Evidence: ${frictionResult.evidence})'
        : (primaryAction?.reason ??
            (openTasks.isEmpty
                ? 'Aucune tâche prioritaire active ni contrainte détectée.'
                : 'Aucune tâche prioritaire active détectée.'));

    final confidence = openTasks.isEmpty
        ? 0.10
        : (1.0 - ((snapshot.mentalBattery / 100.0) * 0.3)).clamp(0.2, 0.94);

    final contextTags = <String>[
      frictionResult.frictionType,
      if (snapshot.mentalBattery < 40) 'low_energy',
      if (snapshot.agendaEvents.isNotEmpty) 'agenda_present',
      if (topTask != null) 'task_priority_detected',
    ];

    return N1Summary(
      summaryId: 'n1_${DateTime.now().millisecondsSinceEpoch}',
      generatedAt: DateTime.now(),
      currentStateSummary: _currentStateSummary(snapshot, frictionResult),
      primaryActionId: primaryActionId,
      primaryReason: primaryReason,
      priorityLevel: frictionResult.priorityLevel ??
          _priorityLevelFrom(snapshot, topTask),
      confidence: confidence,
      riskFlags: riskFlags,
      recommendations: recommendations,
      blockers: snapshot.riskFlags,
      contextTags: contextTags,
      primaryAction: primaryAction,
    );
  }

  _FrictionResult _detectFriction(
      ContextSnapshot snapshot, TaskSummary? topTask) {
    // 1. CAPACITY_FRICTION
    final isLowEnergy = snapshot.mentalBattery < 40 ||
        (snapshot.dailyEnergy != null && snapshot.dailyEnergy! <= 2);
    final isDifficultTask = topTask != null &&
        (topTask.difficulty == 'Difficile' ||
            topTask.difficulty == 'Haut' ||
            (topTask.estimatedTimeMinutes != null &&
                topTask.estimatedTimeMinutes! >= 45));

    if (isLowEnergy && isDifficultTask) {
      final evidence =
          'mentalBattery=${snapshot.mentalBattery}%, dailyEnergy=${snapshot.dailyEnergy ?? 'N/A'}, taskDifficulty=${topTask.difficulty ?? 'N/A'}, estimatedTime=${topTask.estimatedTimeMinutes ?? 'N/A'}m';
      return _FrictionResult(
        frictionType: 'CAPACITY_FRICTION',
        reason:
            'Niveau d\'énergie faible par rapport à la difficulté de la tâche prioritaire.',
        evidence: evidence,
        recommendation:
            'Ton énergie est basse (${snapshot.mentalBattery}%). Nous recommandons d\'alléger la pression et de passer en Mode Récupération.',
        priorityLevel: snapshot.mentalBattery < 30
            ? PriorityLevel.critical
            : PriorityLevel.high,
        riskFlag: 'capacity_friction_detected',
        action: IntelligentAction(
          actionId: 'action:toggleRecoveryMode',
          actionType: IntelligentActionType.takeBreak,
          targetType: 'recovery_mode',
          targetId: 'toggleRecoveryMode',
          priority: 95,
          reason:
              'Proposer le Mode Récupération suite à une baisse de batterie mentale.',
          metadata: {
            'actionMethod': 'toggleRecoveryMode',
            'suggestedMode': 'RecoveryMode'
          },
          createdAt: DateTime.now(),
        ),
      );
    }

    // 2. OVERLOAD_FRICTION
    final isHighTaskCount = snapshot.openTasks.length > 5;
    final isHighStress = (snapshot.dailyStress != null &&
            snapshot.dailyStress! >= 4) &&
        snapshot.openTasks.length > 3;

    if (isHighTaskCount || isHighStress) {
      final evidence =
          'openTasks=${snapshot.openTasks.length}, dailyStress=${snapshot.dailyStress ?? 'N/A'}';
      return _FrictionResult(
        frictionType: 'OVERLOAD_FRICTION',
        reason:
            'Surcharge cognitive ou nombre élevé de tâches en attente.',
        evidence: evidence,
        recommendation:
            'Surcharge détectée (${snapshot.openTasks.length} tâches ouvertes). Se foculer sur l\'essentiel avec l\'affichage épuré.',
        priorityLevel: PriorityLevel.high,
        riskFlag: 'overload_friction_detected',
        action: IntelligentAction(
          actionId: 'action:toggleCrisisMode',
          actionType: IntelligentActionType.reduceTaskScope,
          targetType: 'crisis_mode',
          targetId: 'toggleCrisisMode',
          priority: 90,
          reason:
              'Proposer l\'affichage épuré Mode Crise pour réduire la surcharge cognitive.',
          metadata: {
            'actionMethod': 'toggleCrisisMode',
            'suggestedMode': 'CrisisMode'
          },
          createdAt: DateTime.now(),
        ),
      );
    }

    // 3. TIME_FRICTION
    if (topTask != null &&
        topTask.estimatedTimeMinutes != null &&
        snapshot.upcomingEvents.isNotEmpty) {
      final upcomingEvent = snapshot.upcomingEvents.firstWhere(
        (e) => e.startMinutesFromNow != null && e.startMinutesFromNow! > 0,
        orElse: () => snapshot.upcomingEvents.first,
      );
      if (upcomingEvent.startMinutesFromNow != null &&
          topTask.estimatedTimeMinutes! > upcomingEvent.startMinutesFromNow!) {
        final evidence =
            'taskEstimatedTime=${topTask.estimatedTimeMinutes}m, timeAvailableBeforeEvent=${upcomingEvent.startMinutesFromNow}m';
        return _FrictionResult(
          frictionType: 'TIME_FRICTION',
          reason:
              'Temps disponible avant le prochain événement insuffisant pour terminer la tâche.',
          evidence: evidence,
          recommendation:
              'Le créneau (${upcomingEvent.startMinutesFromNow} min) est plus court que la tâche \'${topTask.title}\' (${topTask.estimatedTimeMinutes} min). Planning réajusté.',
          priorityLevel: PriorityLevel.medium,
          riskFlag: 'time_friction_detected',
          action: IntelligentAction(
            actionId: 'action:applyPulseAction',
            actionType: IntelligentActionType.proposeMicroTask,
            targetType: 'pulse_action',
            targetId: 'applyPulseAction',
            priority: 85,
            reason:
              'Proposer un réajustement du planning via Nexii Pulse.',
            metadata: {
              'actionMethod': 'applyPulseAction',
              'taskId': topTask.id,
            },
            createdAt: DateTime.now(),
          ),
        );
      }
    }

    // 4. CLARITY_FRICTION
    if (topTask != null &&
        topTask.subtaskCount == 0 &&
        ((topTask.estimatedTimeMinutes != null &&
                topTask.estimatedTimeMinutes! >= 45) ||
            topTask.difficulty == 'Difficile' ||
            topTask.difficulty == 'Haut')) {
      final evidence =
          'subtaskCount=0, estimatedTime=${topTask.estimatedTimeMinutes ?? 'N/A'}m, difficulty=${topTask.difficulty ?? 'N/A'}';
      return _FrictionResult(
        frictionType: 'CLARITY_FRICTION',
        reason:
            'Tâche prioritaire complexe sans découpage en sous-actions.',
        evidence: evidence,
        recommendation:
            'La tâche \'${topTask.title}\' semble lourde sans sous-étapes. La décomposer en micro-actions de 2 minutes.',
        priorityLevel: PriorityLevel.medium,
        riskFlag: 'clarity_friction_detected',
        action: IntelligentAction(
          actionId: 'action:decomposeTask:${topTask.id}',
          actionType: IntelligentActionType.proposeMicroTask,
          targetType: 'task',
          targetId: topTask.id,
          priority: 80,
          reason:
              'Proposer la décomposition automatique de la tâche en micro-actions.',
          metadata: {
            'actionMethod': 'decomposeTaskToMicroActions',
            'taskId': topTask.id,
          },
          createdAt: DateTime.now(),
        ),
      );
    }

    // 5. SCHEDULING_FRICTION
    if (snapshot.agendaEvents.length >= 3 && snapshot.openTasks.length > 3) {
      final evidence =
          'agendaEvents=${snapshot.agendaEvents.length}, openTasks=${snapshot.openTasks.length}';
      return _FrictionResult(
        frictionType: 'SCHEDULING_FRICTION',
        reason:
            'Densité d\'agenda élevée superposée à un carnet de tâches ouvert.',
        evidence: evidence,
        recommendation:
            'Agenda chargé et plusieurs tâches ouvertes. Appliquer la stratégie d\'optimisation des priorités.',
        priorityLevel: PriorityLevel.medium,
        riskFlag: 'scheduling_friction_detected',
        action: IntelligentAction(
          actionId: 'action:applyAIStrategy',
          actionType: IntelligentActionType.adjustPriority,
          targetType: 'ai_strategy',
          targetId: 'applyAIStrategy',
          priority: 75,
          reason:
              'Proposer l\'application de la stratégie d\'optimisation des priorités.',
          metadata: {'actionMethod': 'applyAIStrategy'},
          createdAt: DateTime.now(),
        ),
      );
    }

    // 6. MOMENTUM_FRICTION
    if (snapshot.focusMinutesTotal == 0 &&
        snapshot.openTasks.isNotEmpty &&
        snapshot.hasCheckedInToday) {
      final evidence =
          'focusMinutes=0, openTasks=${snapshot.openTasks.length}, checkedIn=true';
      return _FrictionResult(
        frictionType: 'MOMENTUM_FRICTION',
        reason:
            'Aucune session de focus démarrée malgré des tâches en attente.',
        evidence: evidence,
        recommendation:
            'Amorce la journée avec une courte session de 15 minutes de focus.',
        priorityLevel: PriorityLevel.low,
        riskFlag: 'momentum_friction_detected',
        action: IntelligentAction(
          actionId: 'action:startFocus',
          actionType: IntelligentActionType.startFocus,
          targetType: 'focus',
          targetId: 'startFocus',
          priority: 70,
          reason:
              'Recommander le démarrage d\'une première session de concentration.',
          metadata: {'suggestedDuration': 15},
          createdAt: DateTime.now(),
        ),
      );
    }

    // 7. INSUFFICIENT CONTEXT / EMPTY STATE
    if (snapshot.openTasks.isEmpty &&
        snapshot.goals.isEmpty &&
        snapshot.missions.isEmpty &&
        !snapshot.hasCheckedInToday) {
      return _FrictionResult(
        frictionType: 'insufficient_context',
        reason: 'Données insuffisantes pour établir une friction.',
        evidence: 'openTasks=0, goals=0, missions=0, checkedIn=false',
        recommendation: null,
        priorityLevel: PriorityLevel.low,
        riskFlag: null,
        action: null,
      );
    }

    // 8. NO FRICTION (Normal Situation)
    return _FrictionResult(
      frictionType: 'NO_FRICTION',
      reason: 'Aucune friction significative détectée.',
      evidence:
          'mentalBattery=${snapshot.mentalBattery}%, openTasks=${snapshot.openTasks.length}',
      recommendation: null,
      priorityLevel: PriorityLevel.low,
      riskFlag: null,
      action: null,
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

  String _currentStateSummary(
      ContextSnapshot snapshot, _FrictionResult friction) {
    final taskPart = snapshot.openTasks.isNotEmpty
        ? '${snapshot.openTasks.length} tâches ouvertes'
        : 'aucune tâche ouverte';
    final energyPart = 'énergie ${snapshot.mentalBattery}%';
    final frictionPart = friction.frictionType != 'NO_FRICTION'
        ? ' [Friction: ${friction.frictionType}]'
        : '';
    return '$taskPart, $energyPart$frictionPart.';
  }
}

class _FrictionResult {
  const _FrictionResult({
    required this.frictionType,
    required this.reason,
    required this.evidence,
    this.recommendation,
    this.priorityLevel,
    this.riskFlag,
    this.action,
  });

  final String frictionType;
  final String reason;
  final String evidence;
  final String? recommendation;
  final PriorityLevel? priorityLevel;
  final String? riskFlag;
  final IntelligentAction? action;
}
