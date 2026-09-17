class TaskSummary {
  const TaskSummary({
    required this.id,
    required this.title,
    required this.isCompleted,
    this.priority,
    this.urgency,
    this.difficulty,
    this.estimatedTimeMinutes,
    this.energyNeeded,
    this.category,
    this.subtaskCount = 0,
    this.linkedGoalId,
  });

  final String id;
  final String title;
  final bool isCompleted;
  final String? priority;
  final String? urgency;
  final String? difficulty;
  final int? estimatedTimeMinutes;
  final String? energyNeeded;
  final String? category;
  final int subtaskCount;
  final String? linkedGoalId;
}

class AgendaEventSummary {
  const AgendaEventSummary({
    required this.id,
    required this.title,
    required this.time,
    this.startMinutesFromNow,
    this.durationMinutes,
    this.importance,
    this.kind,
  });

  final String id;
  final String title;
  final String time;
  final int? startMinutesFromNow;
  final int? durationMinutes;
  final String? importance;
  final String? kind;
}

class GoalSummary {
  const GoalSummary({
    required this.id,
    required this.title,
    required this.progress,
    this.category,
  });

  final String id;
  final String title;
  final double progress;
  final String? category;
}

class MissionSummary {
  const MissionSummary({
    required this.id,
    required this.title,
    required this.progress,
    required this.isCompleted,
    required this.xp,
    required this.claimed,
  });

  final String id;
  final String title;
  final double progress;
  final bool isCompleted;
  final int xp;
  final bool claimed;
}

enum RiskLevel {
  low,
  medium,
  high,
  critical,
}

enum PriorityLevel {
  low,
  medium,
  high,
  critical,
}

enum IntelligentActionType {
  completeTask,
  startTask,
  rescheduleTask,
  reduceTaskScope,
  proposeMicroTask,
  startFocus,
  takeBreak,
  reviewBudget,
  dismissInsight,
  ignoreInsight,
  adjustPriority,
  scheduleReminder,
}

class IntelligentAction {
  const IntelligentAction({
    required this.actionId,
    required this.actionType,
    required this.targetType,
    this.targetId,
    required this.priority,
    required this.reason,
    this.metadata = const <String, dynamic>{},
    required this.createdAt,
    this.expiresAt,
  });

  final String actionId;
  final IntelligentActionType actionType;
  final String targetType;
  final String? targetId;
  final int priority;
  final String reason;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? expiresAt;
}

class N1Summary {
  const N1Summary({
    required this.summaryId,
    required this.generatedAt,
    required this.currentStateSummary,
    required this.primaryActionId,
    required this.primaryReason,
    required this.priorityLevel,
    required this.confidence,
    required this.riskFlags,
    required this.recommendations,
    this.blockers = const <String>[],
    this.contextTags = const <String>[],
    this.primaryAction,
  });

  final String summaryId;
  final DateTime generatedAt;
  final String currentStateSummary;
  final String? primaryActionId;
  final String primaryReason;
  final PriorityLevel priorityLevel;
  final double confidence;
  final List<String> riskFlags;
  final List<String> recommendations;
  final List<String> blockers;
  final List<String> contextTags;
  final IntelligentAction? primaryAction;
}

enum ContextualInsightType {
  agendaConflict,
  energyRisk,
  taskBlocker,
  timeWindowOpportunity,
  overloadWarning,
  productivityRecommendation,
}

enum InsightStatus {
  active,
  accepted,
  dismissed,
  ignored,
  resolved,
  expired,
}

class ContextualInsight {
  const ContextualInsight({
    required this.insightId,
    required this.insightType,
    required this.message,
    required this.priority,
    required this.conflictDetected,
    required this.source,
    this.taskId,
    this.agendaId,
    this.actionId,
    required this.confidence,
    required this.status,
    required this.createdAt,
    this.expiresAt,
    this.metadata = const <String, dynamic>{},
  });

  final String insightId;
  final ContextualInsightType insightType;
  final String message;
  final PriorityLevel priority;
  final bool conflictDetected;
  final String source;
  final String? taskId;
  final String? agendaId;
  final String? actionId;
  final double confidence;
  final InsightStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final Map<String, dynamic> metadata;
}

enum IntelligenceStatus {
  idle,
  ok,
  warning,
  critical,
  error,
}

class IntelligenceResult {
  const IntelligenceResult({
    required this.nodeId,
    required this.status,
    required this.confidence,
    required this.observations,
    this.riskFlags = const <String>[],
    this.recommendations = const <String>[],
    this.actions = const <IntelligentAction>[],
    required this.generatedAt,
    this.metadata = const <String, dynamic>{},
  });

  final String nodeId;
  final IntelligenceStatus status;
  final double confidence;
  final List<String> observations;
  final List<String> riskFlags;
  final List<String> recommendations;
  final List<IntelligentAction> actions;
  final DateTime generatedAt;
  final Map<String, dynamic> metadata;
}

class ContextSnapshot {
  const ContextSnapshot({
    this.userId,
    this.displayName,
    this.age,
    this.isAnonymous = false,
    this.locale = 'fr',
    this.onboardingComplete = true,
    this.tasks = const <TaskSummary>[],
    this.openTasks = const <TaskSummary>[],
    this.agendaEvents = const <AgendaEventSummary>[],
    this.upcomingEvents = const <AgendaEventSummary>[],
    this.mentalBattery = 0,
    this.focusMinutesTotal = 0,
    this.currentMood,
    this.dailyMood,
    this.dailyEnergy,
    this.dailyMotivation,
    this.dailyStress,
    this.dailySleep,
    this.hasCheckedInToday = false,
    this.goals = const <GoalSummary>[],
    this.missions = const <MissionSummary>[],
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
    this.disciplineScore = 0,
    this.auraScore = 0,
    this.totalBudget = 0.0,
    this.remainingBudget = 0.0,
    required this.now,
    this.timeOfDay = 'unknown',
    this.dayOfWeek = 0,
    this.riskFlags = const <String>[],
    this.riskLevel = RiskLevel.low,
    this.snapshotVersion = 1,
    required this.generatedAt,
    this.source = 'AppStateProvider',
  });

  final String? userId;
  final String? displayName;
  final int? age;
  final bool isAnonymous;
  final String locale;
  final bool onboardingComplete;
  final List<TaskSummary> tasks;
  final List<TaskSummary> openTasks;
  final List<AgendaEventSummary> agendaEvents;
  final List<AgendaEventSummary> upcomingEvents;
  final int mentalBattery;
  final int focusMinutesTotal;
  final String? currentMood;
  final int? dailyMood;
  final int? dailyEnergy;
  final int? dailyMotivation;
  final int? dailyStress;
  final int? dailySleep;
  final bool hasCheckedInToday;
  final List<GoalSummary> goals;
  final List<MissionSummary> missions;
  final int xp;
  final int level;
  final int streak;
  final int disciplineScore;
  final int auraScore;
  final double totalBudget;
  final double remainingBudget;
  final DateTime now;
  final String timeOfDay;
  final int dayOfWeek;
  final List<String> riskFlags;
  final RiskLevel riskLevel;
  final int snapshotVersion;
  final DateTime generatedAt;
  final String source;
}

/// Structured Representation of the User's Current Situation (Generation 1/4).
class SituationModel {
  final String capacityLevel; // 'low', 'medium', 'high'
  final int mentalBattery;
  final String workloadLevel; // 'low', 'medium', 'high', 'overload'
  final int openTaskCount;
  final int overdueTaskCount;
  final String timePressureLevel; // 'none', 'moderate', 'high'
  final int scheduledEventsCount;
  final String goalAlignmentStatus; // 'none', 'active', 'progressing'
  final int activeGoalCount;
  final int activeMissionCount;
  final int auraScore;
  final int userLevel;
  final int streakDays;
  final String currentFriction; // FrictionCategory or 'NO_FRICTION' or 'INSUFFICIENT_CONTEXT'
  final bool hasCheckedInToday;
  final String contextSignal;
  final DateTime generatedAt;

  const SituationModel({
    required this.capacityLevel,
    required this.mentalBattery,
    required this.workloadLevel,
    required this.openTaskCount,
    required this.overdueTaskCount,
    required this.timePressureLevel,
    required this.scheduledEventsCount,
    required this.goalAlignmentStatus,
    required this.activeGoalCount,
    required this.activeMissionCount,
    required this.auraScore,
    required this.userLevel,
    required this.streakDays,
    required this.currentFriction,
    required this.hasCheckedInToday,
    required this.contextSignal,
    required this.generatedAt,
  });

  factory SituationModel.fromSnapshot(ContextSnapshot snapshot) {
    // Capacity
    final battery = snapshot.mentalBattery;
    final capacity = battery < 35
        ? 'low'
        : battery < 65
            ? 'medium'
            : 'high';

    // Workload
    final openCount = snapshot.openTasks.length;
    final overdueCount = snapshot.openTasks.where((t) => t.urgency == 'High').length;
    final workload = openCount >= 7 || overdueCount >= 3
        ? 'overload'
        : openCount >= 4
            ? 'high'
            : openCount >= 1
                ? 'medium'
                : 'low';

    // Time Pressure
    final agendaCount = snapshot.agendaEvents.length;
    final timePressure = agendaCount >= 4
        ? 'high'
        : agendaCount >= 1
            ? 'moderate'
            : 'none';

    // Goal Alignment
    final goalCount = snapshot.goals.length;
    final missionCount = snapshot.missions.length;
    final goalStatus = (goalCount > 0 || missionCount > 0)
        ? (snapshot.goals.any((g) => g.progress > 0) ? 'progressing' : 'active')
        : 'none';

    // Friction
    String friction = 'NO_FRICTION';
    if (!snapshot.hasCheckedInToday && snapshot.tasks.isEmpty) {
      friction = 'INSUFFICIENT_CONTEXT';
    } else if (battery < 35) {
      friction = 'CAPACITY_FRICTION';
    } else if (workload == 'overload') {
      friction = 'OVERLOAD_FRICTION';
    } else if (agendaCount > 0 && openCount > 0) {
      friction = 'TIME_FRICTION';
    }

    // Context Signal
    final signal = friction == 'INSUFFICIENT_CONTEXT'
        ? 'Check-In requis'
        : friction == 'CAPACITY_FRICTION'
            ? 'Capacité réduite - Mode Récupération'
            : workload == 'overload'
                ? 'Surcharge de travail détectée'
                : 'Situation stable';

    return SituationModel(
      capacityLevel: capacity,
      mentalBattery: battery,
      workloadLevel: workload,
      openTaskCount: openCount,
      overdueTaskCount: overdueCount,
      timePressureLevel: timePressure,
      scheduledEventsCount: agendaCount,
      goalAlignmentStatus: goalStatus,
      activeGoalCount: goalCount,
      activeMissionCount: missionCount,
      auraScore: snapshot.auraScore,
      userLevel: snapshot.level,
      streakDays: snapshot.streak,
      currentFriction: friction,
      hasCheckedInToday: snapshot.hasCheckedInToday,
      contextSignal: signal,
      generatedAt: DateTime.now(),
    );
  }
}

enum OutcomeType {
  completed,
  partiallyCompleted,
  ignored,
  refused,
  abandoned,
  noResult,
}

/// Represents an observed action outcome in a specific context (Generation 4/4).
class LearningEvent {
  final String eventId;
  final DateTime timestamp;
  final String? decisionId;
  final String actionId;
  final String actionType;
  final String? targetType;
  final String? targetId;
  final String capacityLevel;
  final String workloadLevel;
  final String frictionType;
  final OutcomeType outcome;

  const LearningEvent({
    required this.eventId,
    required this.timestamp,
    this.decisionId,
    required this.actionId,
    required this.actionType,
    this.targetType,
    this.targetId,
    required this.capacityLevel,
    required this.workloadLevel,
    required this.frictionType,
    required this.outcome,
  });

  bool get isPositive =>
      outcome == OutcomeType.completed || outcome == OutcomeType.partiallyCompleted;

  bool get isNegative =>
      outcome == OutcomeType.abandoned || outcome == OutcomeType.refused;
}

/// Consolidated knowledge pattern for an action within a context (Generation 4/4).
class PersonalLearning {
  final String actionType;
  final String? targetType;
  final String contextPattern; // e.g. "capacity:low|friction:CAPACITY_FRICTION"
  final int totalAttempts;
  final int positiveOutcomes;
  final int negativeOutcomes;
  final int ignoredOutcomes;
  final double confidence; // Bounded 0.0 to 1.0 based on cumulative sample size
  final double effectivenessScore; // 0.0 to 1.0
  final DateTime lastObserved;

  const PersonalLearning({
    required this.actionType,
    this.targetType,
    required this.contextPattern,
    required this.totalAttempts,
    required this.positiveOutcomes,
    required this.negativeOutcomes,
    required this.ignoredOutcomes,
    required this.confidence,
    required this.effectivenessScore,
    required this.lastObserved,
  });

  factory PersonalLearning.fromEvents({
    required String actionType,
    String? targetType,
    required String contextPattern,
    required List<LearningEvent> events,
  }) {
    if (events.isEmpty) {
      return PersonalLearning(
        actionType: actionType,
        targetType: targetType,
        contextPattern: contextPattern,
        totalAttempts: 0,
        positiveOutcomes: 0,
        negativeOutcomes: 0,
        ignoredOutcomes: 0,
        confidence: 0.0,
        effectivenessScore: 0.5,
        lastObserved: DateTime.now(),
      );
    }

    final total = events.length;
    final positive = events.where((e) => e.isPositive).length;
    final negative = events.where((e) => e.isNegative).length;
    final ignored = events.where((e) => e.outcome == OutcomeType.ignored).length;

    // Confidence formula: logarithmic growth bounded at 0.95 (requires >= 3 events for >0.5 confidence)
    final rawConfidence = total >= 3 ? (0.4 + (total * 0.1)).clamp(0.0, 0.95) : (total * 0.15);

    // Effectiveness: positive ratio weighted against active attempts
    final activeAttempts = positive + negative;
    final effectiveness = activeAttempts > 0
        ? (positive / activeAttempts).clamp(0.0, 1.0)
        : 0.5;

    final latestTime = events.map((e) => e.timestamp).reduce((a, b) => a.isAfter(b) ? a : b);

    return PersonalLearning(
      actionType: actionType,
      targetType: targetType,
      contextPattern: contextPattern,
      totalAttempts: total,
      positiveOutcomes: positive,
      negativeOutcomes: negative,
      ignoredOutcomes: ignored,
      confidence: rawConfidence,
      effectivenessScore: effectiveness,
      lastObserved: latestTime,
    );
  }
}

/// Collection of established user learning patterns provided to G3 decisions (Generation 4/4).
class PersonalLearningContext {
  final List<PersonalLearning> learnings;

  const PersonalLearningContext({
    this.learnings = const <PersonalLearning>[],
  });

  static const empty = PersonalLearningContext();

  PersonalLearning? findKnowledge({
    required String actionType,
    required String capacityLevel,
    required String frictionType,
  }) {
    final pattern = 'capacity:$capacityLevel|friction:$frictionType';
    for (final l in learnings) {
      if (l.actionType == actionType && l.contextPattern == pattern && l.confidence >= 0.3) {
        return l;
      }
    }
    return null;
  }
}

/// Deterministic Decision Model produced by G3 Adaptive Engine.
class AdaptiveDecision {
  final String decisionType; // 'SELECT_TASK', 'RECOVERY', 'DECOMPOSE_TASK', 'PULSE_ACTION', 'CHECKIN_REQUIRED', 'NO_ACTION'
  final String? selectedActionId;
  final IntelligentAction? primaryAction;
  final String reason;
  final PriorityLevel priorityLevel;
  final double confidence; // 0.0 to 1.0
  final String expectedBenefit;
  final String frictionTarget;
  final List<String> evidence;
  final List<IntelligentAction> alternatives;
  final bool isExecutable;
  final DateTime generatedAt;

  const AdaptiveDecision({
    required this.decisionType,
    this.selectedActionId,
    this.primaryAction,
    required this.reason,
    required this.priorityLevel,
    required this.confidence,
    required this.expectedBenefit,
    required this.frictionTarget,
    required this.evidence,
    this.alternatives = const <IntelligentAction>[],
    required this.isExecutable,
    required this.generatedAt,
  });

  factory AdaptiveDecision.evaluate(
    ContextSnapshot snapshot,
    SituationModel situation,
    AnticipationModel anticipation, {
    PersonalLearningContext? learningContext,
  }) {
    final evidenceList = <String>[];

    // Case 1: Insufficient Context -> CheckIn Required
    if (situation.currentFriction == 'INSUFFICIENT_CONTEXT' || !snapshot.hasCheckedInToday) {
      return AdaptiveDecision(
        decisionType: 'CHECKIN_REQUIRED',
        selectedActionId: 'action_checkin',
        primaryAction: IntelligentAction(
          actionId: 'action_checkin',
          actionType: IntelligentActionType.startTask,
          targetType: 'check_in',
          priority: 95,
          reason: 'Réaliser le Bilan Quotidien pour calibrer l\'IA',
          createdAt: DateTime.now(),
        ),
        reason: 'Données d\'énergie quotidiennes non renseignées : Check-In nécessaire pour adapter l\'assistance',
        priorityLevel: PriorityLevel.high,
        confidence: 0.95,
        expectedBenefit: 'Permet une calibration précise de la batterie mentale et du planning',
        frictionTarget: 'INSUFFICIENT_CONTEXT',
        evidence: const ['Check-In quotidien manquant'],
        isExecutable: true,
        generatedAt: DateTime.now(),
      );
    }

    // Case 2: Capacity Risk -> Recovery Mode
    if (situation.capacityLevel == 'low' || snapshot.mentalBattery < 35 || anticipation.affectedDomain == 'Capacity') {
      evidenceList.add('Batterie mentale sous le seuil (${snapshot.mentalBattery}%)');
      evidenceList.add('Stress perçu : ${snapshot.dailyStress ?? 3}/5');

      final recoveryAction = IntelligentAction(
        actionId: 'action_recovery',
        actionType: IntelligentActionType.takeBreak,
        targetType: 'system',
        priority: 90,
        reason: 'Activer le Mode Récupération pour protéger les réserves cognitives',
        createdAt: DateTime.now(),
      );

      return AdaptiveDecision(
        decisionType: 'RECOVERY',
        selectedActionId: recoveryAction.actionId,
        primaryAction: recoveryAction,
        reason: 'Capacité cognitive fortement sollicitée : la priorité est d\'alléger la pression',
        priorityLevel: PriorityLevel.critical,
        confidence: 0.90,
        expectedBenefit: 'Restauration de +25% de batterie mentale sans impacter les échéances réelles',
        frictionTarget: 'CAPACITY_FRICTION',
        evidence: evidenceList,
        isExecutable: true,
        generatedAt: DateTime.now(),
      );
    }

    // Case 3: Overload or Clarity Risk -> Decompose Task
    if (situation.workloadLevel == 'overload' || situation.overdueTaskCount >= 3) {
      final topTask = snapshot.openTasks.isNotEmpty ? snapshot.openTasks.first : null;
      evidenceList.add('Surcharge détectée : ${snapshot.openTasks.length} tâches ouvertes');

      if (topTask != null) {
        evidenceList.add('Tâche prioritaire ciblée : ${topTask.title}');
        final decomposeAction = IntelligentAction(
          actionId: 'task_decompose_${topTask.id}',
          actionType: IntelligentActionType.proposeMicroTask,
          targetType: 'task',
          targetId: topTask.id,
          priority: 85,
          reason: 'Décomposer "${topTask.title}" en micro-actions simples',
          createdAt: DateTime.now(),
        );

        return AdaptiveDecision(
          decisionType: 'DECOMPOSE_TASK',
          selectedActionId: decomposeAction.actionId,
          primaryAction: decomposeAction,
          reason: 'Surcharge de travail : la décomposition réduit la friction d\'amorce',
          priorityLevel: PriorityLevel.high,
          confidence: 0.85,
          expectedBenefit: 'Baisse immédiate de la friction mentale et amorce d\'action en <2 min',
          frictionTarget: 'OVERLOAD_FRICTION',
          evidence: evidenceList,
          isExecutable: true,
          generatedAt: DateTime.now(),
        );
      }
    }

    // Case 4: Open Task Selection aligned with Goals
    if (snapshot.openTasks.isNotEmpty) {
      final bestTask = snapshot.openTasks.reduce((a, b) {
        final scoreA = (a.priority == 'High' ? 3 : 1) + (a.linkedGoalId != null ? 2 : 0);
        final scoreB = (b.priority == 'High' ? 3 : 1) + (b.linkedGoalId != null ? 2 : 0);
        return scoreA >= scoreB ? a : b;
      });

      evidenceList.add('Tâche sélectionnée : "${bestTask.title}"');
      if (bestTask.linkedGoalId != null) {
        evidenceList.add('Directement alignée avec un Objectif de Vie actif');
      }

      final taskAction = IntelligentAction(
        actionId: 'task_start_${bestTask.id}',
        actionType: IntelligentActionType.startTask,
        targetType: 'task',
        targetId: bestTask.id,
        priority: 80,
        reason: 'Exécuter la tâche la plus alignée avec tes cibles actuelles',
        createdAt: DateTime.now(),
      );

      // Alternatives
      final alternatives = snapshot.openTasks
          .where((t) => t.id != bestTask.id)
          .take(2)
          .map((alt) => IntelligentAction(
                actionId: 'task_start_${alt.id}',
                actionType: IntelligentActionType.startTask,
                targetType: 'task',
                targetId: alt.id,
                priority: 60,
                reason: 'Option alternative : ${alt.title}',
                createdAt: DateTime.now(),
              ))
          .toList();

      return AdaptiveDecision(
        decisionType: 'SELECT_TASK',
        selectedActionId: taskAction.actionId,
        primaryAction: taskAction,
        reason: 'Situation optimale : action alignée sur tes objectifs et ton niveau d\'énergie',
        priorityLevel: PriorityLevel.medium,
        confidence: 0.88,
        expectedBenefit: 'Avancement direct sur un jalon clé et gain d\'XP (+15 XP)',
        frictionTarget: 'NO_FRICTION',
        evidence: evidenceList,
        alternatives: alternatives,
        isExecutable: true,
        generatedAt: DateTime.now(),
      );
    }

    // Case 5: No Action Required
    return AdaptiveDecision(
      decisionType: 'NO_ACTION',
      selectedActionId: null,
      primaryAction: null,
      reason: 'Situation parfaitement stable : aucune friction active ou action requise',
      priorityLevel: PriorityLevel.low,
      confidence: 0.70,
      expectedBenefit: 'Maintien de l\'état de sérénité et de flow',
      frictionTarget: 'NO_FRICTION',
      evidence: const ['Aucune tâche urgente ou alerte de capacité active'],
      isExecutable: false,
      generatedAt: DateTime.now(),
    );
  }
}

/// Structured Representation of Future Anticipations & Risk Signals (Generation 2/4).
class AnticipationModel {
  final String type; // 'RISK', 'OPPORTUNITY', 'CHANGE', 'CONSTRAINT', 'NO_ANTICIPATION'
  final String description;
  final String horizon; // 'immediate', 'short_term', 'near_term'
  final List<String> evidence;
  final double confidence; // 0.0 to 1.0
  final String potentialConsequence;
  final String affectedDomain; // 'Tasks', 'Capacity', 'Time', 'Goals', 'General'
  final DateTime generatedAt;

  const AnticipationModel({
    required this.type,
    required this.description,
    required this.horizon,
    required this.evidence,
    required this.confidence,
    required this.potentialConsequence,
    required this.affectedDomain,
    required this.generatedAt,
  });

  factory AnticipationModel.evaluate(ContextSnapshot snapshot, SituationModel situation) {
    final evidenceList = <String>[];

    // Check Capacity Risk
    if (situation.capacityLevel == 'low' || snapshot.mentalBattery < 35) {
      evidenceList.add('Batterie mentale sous le seuil critique (${snapshot.mentalBattery}%)');
      if (snapshot.dailyStress != null && snapshot.dailyStress! >= 4) {
        evidenceList.add('Niveau de stress élevé (${snapshot.dailyStress}/5)');
      }
      return AnticipationModel(
        type: 'RISK',
        description: 'Risque imminent d\'épuisement et de baisse de clarté cognitive',
        horizon: 'immediate',
        evidence: evidenceList,
        confidence: 0.88,
        potentialConsequence: 'Incapacité à finaliser les tâches complexes prévues aujourd\'hui',
        affectedDomain: 'Capacity',
        generatedAt: DateTime.now(),
      );
    }

    // Check Workload / Overload Risk
    if (situation.workloadLevel == 'overload' || snapshot.openTasks.length >= 7) {
      evidenceList.add('Backlog élevé : ${snapshot.openTasks.length} tâches ouvertes');
      final highPrioCount = snapshot.openTasks.where((t) => t.priority == 'High' || t.urgency == 'High').length;
      if (highPrioCount > 0) {
        evidenceList.add('$highPrioCount tâche(s) à haute priorité non finalisée(s)');
      }
      return AnticipationModel(
        type: 'RISK',
        description: 'Risque d\'embouteillage de planning et de retard sur les échéances',
        horizon: 'short_term',
        evidence: evidenceList,
        confidence: 0.82,
        potentialConsequence: 'Report forcé de plusieurs tâches prioritaires vers les jours suivants',
        affectedDomain: 'Tasks',
        generatedAt: DateTime.now(),
      );
    }

    // Check Constraint / Time Conflict
    if (situation.timePressureLevel == 'high' || (snapshot.agendaEvents.isNotEmpty && snapshot.openTasks.isNotEmpty)) {
      evidenceList.add('${snapshot.agendaEvents.length} événement(s) planifié(s) dans l\'agenda');
      evidenceList.add('${snapshot.openTasks.length} tâche(s) en attente d\'exécution');
      return AnticipationModel(
        type: 'CONSTRAINT',
        description: 'Pression temporelle élevée : chevauchement potentiel agenda et tâches',
        horizon: 'short_term',
        evidence: evidenceList,
        confidence: 0.75,
        potentialConsequence: 'Fenêtres de travail fragmentées et manque de plages de Deep Work',
        affectedDomain: 'Time',
        generatedAt: DateTime.now(),
      );
    }

    // Check Opportunity
    if (situation.capacityLevel == 'high' && situation.workloadLevel == 'low' && snapshot.openTasks.isNotEmpty) {
      evidenceList.add('Excellente capacité cognitive (${snapshot.mentalBattery}%)');
      evidenceList.add('Charge de travail modérée (${snapshot.openTasks.length} tâche open)');
      return AnticipationModel(
        type: 'OPPORTUNITY',
        description: 'Fenêtre idéale pour avancer sur un objectif de fond ou une tâche complexe',
        horizon: 'near_term',
        evidence: evidenceList,
        confidence: 0.78,
        potentialConsequence: 'Gain d\'élan significatif et augmentation du score d\'Aura',
        affectedDomain: 'Goals',
        generatedAt: DateTime.now(),
      );
    }

    // Default: No Anticipation required
    return AnticipationModel(
      type: 'NO_ANTICIPATION',
      description: 'Aucun risque ou goulot d\'étranglement majeur anticipé à court terme',
      horizon: 'near_term',
      evidence: const ['Régularité et capacité dans les seuils nominaux'],
      confidence: 0.65,
      potentialConsequence: 'Maintien de la trajectoire actuelle sans ajustement nécessaire',
      affectedDomain: 'General',
      generatedAt: DateTime.now(),
    );
  }
}
