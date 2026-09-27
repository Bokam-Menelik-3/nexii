import 'package:flutter_test/flutter_test.dart';
import 'package:nexii/experience/experience_engine.dart';
import 'package:nexii/experience/models/experience_action.dart';
import 'package:nexii/experience/models/experience_mode.dart';
import 'package:nexii/experience/models/experience_state.dart';
import 'package:nexii/intelligence/models/intelligence_models.dart';

final fixedNow = DateTime(2026, 1, 8, 9, 30);

TaskSummary _task(String id) =>
    TaskSummary(id: id, title: 'Task $id', isCompleted: false);

GoalSummary _goal(String id) =>
    GoalSummary(id: id, title: 'Goal $id', progress: 0.4);

N1Summary _n1({
  PriorityLevel priorityLevel = PriorityLevel.low,
  List<String> riskFlags = const <String>[],
  String? primaryTargetId,
}) {
  return N1Summary(
    summaryId: 'n1_test',
    generatedAt: fixedNow,
    currentStateSummary: 'state',
    primaryActionId: primaryTargetId != null ? 'task:$primaryTargetId' : null,
    primaryReason: 'reason',
    priorityLevel: priorityLevel,
    confidence: 0.8,
    riskFlags: riskFlags,
    recommendations: const <String>['rec'],
    primaryAction: primaryTargetId != null
        ? IntelligentAction(
            actionId: 'task:$primaryTargetId',
            actionType: IntelligentActionType.startTask,
            targetType: 'task',
            targetId: primaryTargetId,
            priority: 90,
            reason: 'reason',
            createdAt: fixedNow,
          )
        : null,
  );
}

ContextSnapshot _snapshot({
  int mentalBattery = 80,
  bool hasCheckedInToday = true,
  List<TaskSummary> openTasks = const <TaskSummary>[],
  List<GoalSummary> goals = const <GoalSummary>[],
  List<String> riskFlags = const <String>[],
}) {
  return ContextSnapshot(
    mentalBattery: mentalBattery,
    hasCheckedInToday: hasCheckedInToday,
    tasks: openTasks,
    openTasks: openTasks,
    goals: goals,
    riskFlags: riskFlags,
    now: fixedNow,
    generatedAt: fixedNow,
  );
}

class _Case {
  const _Case(
    this.name, {
    required this.mode,
    required this.focus,
    required this.actionType,
    this.targetId,
    required this.targetTab,
    required this.emphasis,
    required this.density,
    required this.tone,
    required this.reasons,
    this.battery = 80,
    this.checkedIn = true,
    this.openTasks = const <TaskSummary>[],
    this.goals = const <GoalSummary>[],
    this.n1Flags = const <String>[],
    this.priorityLevel = PriorityLevel.low,
    this.primaryTargetId,
    this.currentTab = 0,
  });

  final String name;
  final ExperienceMode mode;
  final ExperienceDominantFocus focus;
  final IntelligentActionType? actionType;
  final String? targetId;
  final int targetTab;
  final ExperienceEmphasis emphasis;
  final ExperienceDensity density;
  final ExperienceTone tone;
  final List<String> reasons;
  final int battery;
  final bool checkedIn;
  final List<TaskSummary> openTasks;
  final List<GoalSummary> goals;
  final List<String> n1Flags;
  final PriorityLevel priorityLevel;
  final String? primaryTargetId;
  final int currentTab;
}

final List<_Case> _table = <_Case>[
  _Case(
    'Recovery: battery below 35',
    mode: ExperienceMode.recovery,
    focus: ExperienceDominantFocus.recovery,
    actionType: IntelligentActionType.takeBreak,
    targetTab: 2,
    emphasis: ExperienceEmphasis.gentle,
    density: ExperienceDensity.minimal,
    tone: ExperienceTone.gentle,
    reasons: const <String>['mental_battery_critical'],
    battery: 20,
    checkedIn: false,
    openTasks: List.generate(6, (i) => _task('t$i')),
  ),
  _Case(
    'Recovery: N1 battery risk flag',
    mode: ExperienceMode.recovery,
    focus: ExperienceDominantFocus.recovery,
    actionType: IntelligentActionType.takeBreak,
    targetTab: 2,
    emphasis: ExperienceEmphasis.gentle,
    density: ExperienceDensity.minimal,
    tone: ExperienceTone.gentle,
    reasons: const <String>['mental_battery_critical'],
    n1Flags: const <String>['mental_battery_low'],
  ),
  _Case(
    'Pressure: backlog above 5 open tasks',
    mode: ExperienceMode.pressure,
    focus: ExperienceDominantFocus.triage,
    actionType: IntelligentActionType.adjustPriority,
    targetTab: 1,
    emphasis: ExperienceEmphasis.elevated,
    density: ExperienceDensity.reduced,
    tone: ExperienceTone.neutral,
    reasons: const <String>['task_backlog_high'],
    openTasks: List.generate(6, (i) => _task('t$i')),
  ),
  _Case(
    'Pressure: agenda conflict flag',
    mode: ExperienceMode.pressure,
    focus: ExperienceDominantFocus.triage,
    actionType: IntelligentActionType.adjustPriority,
    targetTab: 1,
    emphasis: ExperienceEmphasis.elevated,
    density: ExperienceDensity.reduced,
    tone: ExperienceTone.neutral,
    reasons: const <String>['agenda_conflict_possible'],
    n1Flags: const <String>['agenda_conflict_possible'],
    openTasks: <TaskSummary>[_task('t1')],
  ),
  _Case(
    'CheckIn: daily check-in missing',
    mode: ExperienceMode.checkIn,
    focus: ExperienceDominantFocus.checkIn,
    actionType: null,
    targetTab: 3,
    emphasis: ExperienceEmphasis.standard,
    density: ExperienceDensity.reduced,
    tone: ExperienceTone.encouraging,
    reasons: const <String>['daily_check_in_missing'],
    checkedIn: false,
    currentTab: 3,
  ),
  _Case(
    'Priority: N1 target id reused',
    mode: ExperienceMode.priority,
    focus: ExperienceDominantFocus.primaryTask,
    actionType: IntelligentActionType.completeTask,
    targetId: 't2',
    targetTab: 0,
    emphasis: ExperienceEmphasis.elevated,
    density: ExperienceDensity.standard,
    tone: ExperienceTone.neutral,
    reasons: const <String>['open_task_available'],
    openTasks: <TaskSummary>[_task('t1'), _task('t2')],
    priorityLevel: PriorityLevel.critical,
    primaryTargetId: 't2',
  ),
  _Case(
    'Priority: stale N1 target falls back to first open task',
    mode: ExperienceMode.priority,
    focus: ExperienceDominantFocus.primaryTask,
    actionType: IntelligentActionType.completeTask,
    targetId: 't1',
    targetTab: 0,
    emphasis: ExperienceEmphasis.standard,
    density: ExperienceDensity.standard,
    tone: ExperienceTone.neutral,
    reasons: const <String>['open_task_available'],
    openTasks: <TaskSummary>[_task('t1')],
    priorityLevel: PriorityLevel.medium,
    primaryTargetId: 'ghost',
  ),
  _Case(
    'Calm: goal available',
    mode: ExperienceMode.calm,
    focus: ExperienceDominantFocus.goal,
    actionType: null,
    targetId: 'g1',
    targetTab: 1,
    emphasis: ExperienceEmphasis.standard,
    density: ExperienceDensity.standard,
    tone: ExperienceTone.encouraging,
    reasons: const <String>['goal_progress_available'],
    goals: <GoalSummary>[_goal('g1')],
  ),
  _Case(
    'Calm: neutral fallback',
    mode: ExperienceMode.calm,
    focus: ExperienceDominantFocus.calm,
    actionType: IntelligentActionType.startFocus,
    targetTab: 2,
    emphasis: ExperienceEmphasis.standard,
    density: ExperienceDensity.standard,
    tone: ExperienceTone.encouraging,
    reasons: const <String>['no_urgent_work'],
  ),
];

void main() {
  const engine = ExperienceEngine();

  ExperienceState run(_Case c) => engine.derive(
        n1: _n1(
          priorityLevel: c.priorityLevel,
          riskFlags: c.n1Flags,
          primaryTargetId: c.primaryTargetId,
        ),
        snapshot: _snapshot(
          mentalBattery: c.battery,
          hasCheckedInToday: c.checkedIn,
          openTasks: c.openTasks,
          goals: c.goals,
        ),
        currentTab: c.currentTab,
        now: fixedNow,
      );

  group('derive: mode table', () {
    for (final c in _table) {
      test(c.name, () {
        final state = run(c);
        expect(state.mode, c.mode, reason: c.name);
        expect(state.dominantFocus, c.focus, reason: c.name);
        expect(state.primaryAction.actionType, c.actionType, reason: c.name);
        expect(state.primaryAction.targetId, c.targetId, reason: c.name);
        expect(state.primaryAction.targetTab, c.targetTab, reason: c.name);
        expect(state.primaryAction.emphasis, c.emphasis, reason: c.name);
        expect(state.informationDensity, c.density, reason: c.name);
        expect(state.tone, c.tone, reason: c.name);
        expect(state.reasons, c.reasons, reason: c.name);
      });
    }
  });

  group('precedence', () {
    test('enum order is Recovery > Pressure > CheckIn > Priority > Calm', () {
      final ordered = [...ExperienceMode.values]
        ..sort((a, b) => a.precedenceIndex.compareTo(b.precedenceIndex));
      expect(
        ordered,
        [
          ExperienceMode.recovery,
          ExperienceMode.pressure,
          ExperienceMode.checkIn,
          ExperienceMode.priority,
          ExperienceMode.calm,
        ],
      );
    });

    final precedenceTable = <_Case>[
      _Case(
        'battery critical beats backlog',
        mode: ExperienceMode.recovery,
        focus: ExperienceDominantFocus.recovery,
        actionType: IntelligentActionType.takeBreak,
        targetTab: 2,
        emphasis: ExperienceEmphasis.gentle,
        density: ExperienceDensity.minimal,
        tone: ExperienceTone.gentle,
        reasons: const <String>['mental_battery_critical'],
        battery: 10,
        openTasks: List.generate(6, (i) => _task('t$i')),
      ),
      _Case(
        'backlog beats missing check-in',
        mode: ExperienceMode.pressure,
        focus: ExperienceDominantFocus.triage,
        actionType: IntelligentActionType.adjustPriority,
        targetTab: 1,
        emphasis: ExperienceEmphasis.elevated,
        density: ExperienceDensity.reduced,
        tone: ExperienceTone.neutral,
        reasons: const <String>['task_backlog_high'],
        checkedIn: false,
        openTasks: List.generate(6, (i) => _task('t$i')),
      ),
      _Case(
        'missing check-in beats open task',
        mode: ExperienceMode.checkIn,
        focus: ExperienceDominantFocus.checkIn,
        actionType: null,
        targetTab: 0,
        emphasis: ExperienceEmphasis.standard,
        density: ExperienceDensity.reduced,
        tone: ExperienceTone.encouraging,
        reasons: const <String>['daily_check_in_missing'],
        checkedIn: false,
        openTasks: <TaskSummary>[_task('t1')],
      ),
      _Case(
        'open task beats goal (calm)',
        mode: ExperienceMode.priority,
        focus: ExperienceDominantFocus.primaryTask,
        actionType: IntelligentActionType.completeTask,
        targetId: 't1',
        targetTab: 0,
        emphasis: ExperienceEmphasis.gentle,
        density: ExperienceDensity.standard,
        tone: ExperienceTone.neutral,
        reasons: const <String>['open_task_available'],
        openTasks: <TaskSummary>[_task('t1')],
        goals: <GoalSummary>[_goal('g1')],
      ),
    ];

    for (final c in precedenceTable) {
      test(c.name, () {
        expect(run(c).mode, c.mode, reason: c.name);
      });
    }
  });

  group('target id behavior', () {
    test('priority with no N1 target uses first open task', () {
      final state = engine.derive(
        n1: _n1(),
        snapshot: _snapshot(openTasks: <TaskSummary>[_task('t1'), _task('t2')]),
        currentTab: 0,
      );
      expect(state.primaryAction.targetId, 't1');
    });

    test('non-targeted actions carry null targetId', () {
      final recovery = engine.derive(
        n1: _n1(),
        snapshot: _snapshot(mentalBattery: 25),
        currentTab: 0,
      );
      expect(recovery.primaryAction.targetId, isNull);
    });
  });

  group('determinism', () {
    test('identical inputs produce identical states', () {
      final first = run(_table.first);
      final second = run(_table.first);
      expect(first.mode, second.mode);
      expect(first.dominantFocus, second.dominantFocus);
      expect(first.primaryAction.actionType, second.primaryAction.actionType);
      expect(first.primaryAction.targetId, second.primaryAction.targetId);
      expect(first.primaryAction.targetTab, second.primaryAction.targetTab);
      expect(first.primaryAction.emphasis, second.primaryAction.emphasis);
      expect(first.informationDensity, second.informationDensity);
      expect(first.tone, second.tone);
      expect(first.reasons, second.reasons);
    });
  });
}
