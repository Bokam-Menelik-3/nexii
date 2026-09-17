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
