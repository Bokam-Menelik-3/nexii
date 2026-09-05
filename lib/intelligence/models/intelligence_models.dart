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
