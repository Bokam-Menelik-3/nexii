import 'package:flutter_test/flutter_test.dart';
import 'package:nexii/experience/experience_engine.dart';
import 'package:nexii/experience/models/experience_mode.dart';
import 'package:nexii/experience/models/experience_state.dart';
import 'package:nexii/intelligence/engines/n1_decision_engine.dart';
import 'package:nexii/intelligence/models/intelligence_models.dart';
import 'package:nexii/intelligence/nodes/anticipate_node.dart';
import 'package:nexii/intelligence/nodes/living_goals_node.dart';
import 'package:nexii/intelligence/nodes/pulse_node.dart';
import 'package:nexii/intelligence/nodes/understand_node.dart';
import 'package:nexii/intelligence/services/intelligence_service.dart';

/// Intelligence coexistence — consolidation suite.
///
/// Verifies the single coherent architecture:
///
///   ContextSnapshot → 4 signals (Pulse, Living Goals, Understand,
///   Anticipate) → N1DecisionEngine (single decision authority) →
///   ExperienceEngine → ExperienceState → UI.
///
/// Categories: 1-4 each capability alone (this file also carries the
/// Anticipate production coverage — `anticipate_production_test.dart` was
/// never created); 5-8 pairwise + all-four coexistence, strongest signal
/// wins; 9 Recovery precedence; 10 Pressure precedence; 11 stable/default;
/// 12 action consistency; 13 deterministic results.
///
/// Known node-domain limitation (reported, not changed): Anticipate's
/// `stress >= 60` clause expects a 0-100 scale while AppStateProvider's
/// check-in supplies 1-5 — snapshot tests below use raw 0-100 values.

final fixedNow = DateTime(2026, 1, 15, 10, 30);

TaskSummary _task(String id) =>
    TaskSummary(id: id, title: 'Task $id', isCompleted: false);

GoalSummary _goal(String id, double progress) =>
    GoalSummary(id: id, title: 'Goal $id', progress: progress);

ContextSnapshot _snap({
  List<TaskSummary> tasks = const <TaskSummary>[],
  List<TaskSummary>? openTasks,
  List<GoalSummary> goals = const <GoalSummary>[],
  int mentalBattery = 85,
  int focusMinutesTotal = 60,
  int? dailyEnergy = 75,
  int? dailyMotivation = 75,
  int? dailyStress = 30,
  int? dailySleep = 7,
  bool hasCheckedInToday = true,
  List<String> riskFlags = const <String>[],
  DateTime? now,
}) {
  final effectiveNow = now ?? fixedNow;
  return ContextSnapshot(
    tasks: tasks,
    openTasks: openTasks ?? tasks,
    goals: goals,
    mentalBattery: mentalBattery,
    focusMinutesTotal: focusMinutesTotal,
    dailyEnergy: dailyEnergy,
    dailyMotivation: dailyMotivation,
    dailyStress: dailyStress,
    dailySleep: dailySleep,
    hasCheckedInToday: hasCheckedInToday,
    riskFlags: riskFlags,
    now: effectiveNow,
    generatedAt: effectiveNow,
  );
}

N1Summary _n1({
  List<String> riskFlags = const <String>[],
  String? primaryGoalId,
  String? primaryTargetId,
  PriorityLevel priorityLevel = PriorityLevel.medium,
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
    primaryGoalId: primaryGoalId,
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

final _service = IntelligenceService();
const _n1Engine = N1DecisionEngine();
const _xEngine = ExperienceEngine();

void main() {
  group('1. Pulse alone', () {
    test('recovery Pulse is the only promoted signal when handed to N1 alone',
        () {
      final snap = _snap(mentalBattery: 30);
      final n1 = _n1Engine.evaluate(snap, pulse: PulseNode().execute(snap));
      expect(n1.pulseState, 'recovery_needed');
      expect(n1.goalState, isNull);
      expect(n1.understandState, isNull);
      expect(n1.anticipationState, isNull);
      expect(n1.riskFlags,
          unorderedEquals(['mental_battery_low', 'pulse_recovery_needed']));
    });

    test('canonical pipeline promotes Pulse, other signals stay informational',
        () {
      final snap = _snap(mentalBattery: 30);
      final n1 = _service.evaluateN1(snap);
      expect(n1.pulseState, 'recovery_needed');
      expect(n1.riskFlags,
          unorderedEquals(['mental_battery_low', 'pulse_recovery_needed']));
      expect(n1.understandState, 'stable');
      expect(n1.anticipationState, 'clear');
      expect(n1.goalState, isNull);
      final state = _xEngine.derive(n1: n1, snapshot: snap, currentTab: 0);
      expect(state.mode, ExperienceMode.recovery);
      expect(state.reasons,
          ['mental_battery_critical', 'pulse_recovery_needed']);
    });
  });

  group('2. Living Goals alone', () {
    test('at-risk goal is the only promoted signal when handed to N1 alone',
        () {
      final snap = _snap(goals: [_goal('g1', 0.2)]);
      final n1 = _n1Engine.evaluate(
          snap, livingGoals: LivingGoalsNode().execute(snap));
      expect(n1.goalState, 'at_risk');
      expect(n1.pulseState, isNull);
      expect(n1.understandState, isNull);
      expect(n1.anticipationState, isNull);
      expect(n1.riskFlags, ['goal_at_risk']);
    });

    test('goal flag alone annotates calm — never changes the mode', () {
      final snap = _snap(goals: [_goal('g1', 0.2)]);
      final n1 = _service.evaluateN1(snap);
      expect(n1.goalState, 'at_risk');
      expect(n1.riskFlags, ['goal_at_risk']);
      expect(n1.pulseState, 'stable');
      expect(n1.understandState, 'stable');
      expect(n1.anticipationState, 'clear');
      final state = _xEngine.derive(n1: n1, snapshot: snap, currentTab: 0);
      expect(state.mode, ExperienceMode.calm);
      expect(state.reasons, ['goal_progress_available', 'goal_at_risk']);
      expect(state.primaryAction.actionType, isNull);
      expect(state.primaryAction.targetId, 'g1');
    });
  });

  group('3. Understand alone', () {
    test('elevated workload is the only promoted signal on N1 hand-off', () {
      final snap = _snap(tasks: [_task('t1'), _task('t2'), _task('t3')]);
      final n1 =
          _n1Engine.evaluate(snap, understand: UnderstandNode().execute(snap));
      expect(n1.understandState, 'elevated');
      expect(n1.pulseState, isNull);
      expect(n1.goalState, isNull);
      expect(n1.anticipationState, isNull);
      expect(n1.riskFlags, ['workload_elevated']);
    });

    test('canonical pipeline: workload flag reaches Pressure alone', () {
      final snap = _snap(tasks: [_task('t1'), _task('t2'), _task('t3')]);
      final n1 = _service.evaluateN1(snap);
      expect(n1.understandState, 'elevated');
      expect(n1.riskFlags, ['workload_elevated']);
      expect(n1.pulseState, 'stable');
      expect(n1.anticipationState, 'clear');
      expect(n1.goalState, isNull);
      final state = _xEngine.derive(n1: n1, snapshot: snap, currentTab: 0);
      expect(state.mode, ExperienceMode.pressure);
      expect(state.reasons, ['workload_elevated']);
      expect(
          state.primaryAction.actionType, IntelligentActionType.adjustPriority);
      expect(state.primaryAction.targetTab, 1);
    });
  });
  group('4. Anticipate alone incl. risk boundary', () {
    // This group also carries the Anticipate production coverage:
    // test/anticipate_production_test.dart was never created.
    final riskSnap = _snap(
      tasks: [_task('t1'), _task('t2')],
      mentalBattery: 44,
      focusMinutesTotal: 0,
      goals: [_goal('g1', 0.8)],
      dailyStress: 70,
    );

    test('compounding future risk is the only promoted signal on N1 hand-off',
        () {
      final n1 = _n1Engine.evaluate(
          riskSnap, anticipate: AnticipateNode().execute(riskSnap));
      expect(n1.anticipationState, 'risk');
      expect(n1.pulseState, isNull);
      expect(n1.understandState, isNull);
      expect(n1.goalState, isNull);
      expect(n1.riskFlags,
          unorderedEquals(['low_focus_time', 'anticipation_risk']));
      expect(n1.riskFlags, isNot(contains('mental_battery_low')));
      expect(n1.riskFlags, isNot(contains('pulse_recovery_needed')));
      expect(n1.riskFlags, isNot(contains('workload_elevated')));
      expect(n1.riskFlags, isNot(contains('goal_at_risk')));
    });

    test('canonical pipeline: Anticipate-only actionable promotion, Pressure '
        'reason order starts with it', () {
      final n1 = _service.evaluateN1(riskSnap);
      expect(n1.anticipationState, 'risk');
      expect(n1.riskFlags,
          unorderedEquals(['low_focus_time', 'anticipation_risk']));
      expect(n1.pulseState, 'watch');
      expect(n1.understandState, 'reduced');
      expect(n1.goalState, 'on_track');
      final state =
          _xEngine.derive(n1: n1, snapshot: riskSnap, currentTab: 0);
      expect(state.mode, ExperienceMode.pressure);
      expect(state.reasons, ['anticipation_risk']);
    });

    test('risk threshold boundary: accumulated score 4 stays clear, 5 '
        'promotes', () {
      final atFour = _snap(
        tasks: [_task('t1'), _task('t2'), _task('t3')],
        mentalBattery: 44,
        goals: [_goal('g1', 0.8)],
      );
      final n1Four = _service.evaluateN1(atFour);
      expect(n1Four.anticipationState, 'clear');
      expect(n1Four.riskFlags, isNot(contains('anticipation_risk')));

      final atFive = _snap(
        tasks: [_task('t1'), _task('t2'), _task('t3')],
        mentalBattery: 44,
        focusMinutesTotal: 0,
        goals: [_goal('g1', 0.8)],
      );
      final n1Five = _service.evaluateN1(atFive);
      expect(n1Five.anticipationState, 'risk');
      expect(n1Five.riskFlags, contains('anticipation_risk'));
    });

    test('relevance gate: anticipation stays null on healthy task-less context',
        () {
      final quiet = _snap(
        goals: [_goal('g1', 0.8)],
        mentalBattery: 60,
        focusMinutesTotal: 0,
        dailyStress: null,
        dailySleep: null,
      );
      final n1 = _service.evaluateN1(quiet);
      expect(n1.anticipationState, isNull);
      expect(n1.riskFlags, isNot(contains('anticipation_risk')));
    });
  });
  group('5. Pulse + Understand coexistence', () {
    test('both promote; Recovery shows only its own reasons', () {
      final snap =
          _snap(tasks: [_task('t1'), _task('t2'), _task('t3')],
              mentalBattery: 30);
      final n1 = _service.evaluateN1(snap);
      expect(n1.pulseState, 'recovery_needed');
      expect(n1.understandState, 'elevated');
      expect(
          n1.riskFlags,
          unorderedEquals([
            'mental_battery_low',
            'pulse_recovery_needed',
            'workload_elevated',
          ]));
      final state = _xEngine.derive(n1: n1, snapshot: snap, currentTab: 0);
      expect(state.mode, ExperienceMode.recovery);
      expect(state.reasons,
          ['mental_battery_critical', 'pulse_recovery_needed']);
      expect(state.reasons, isNot(contains('workload_elevated')));
    });
  });

  group('6. Pulse + Anticipate coexistence', () {
    test('anticipation risk coexists on N1 but never intrudes on Recovery', () {
      final snap = _snap(
        tasks: [_task('t1'), _task('t2')],
        mentalBattery: 30,
        focusMinutesTotal: 0,
        goals: [_goal('g1', 0.8)],
        dailyStress: 70,
      );
      final n1 = _service.evaluateN1(snap);
      expect(n1.pulseState, 'recovery_needed');
      expect(n1.anticipationState, 'risk');
      expect(
          n1.riskFlags,
          unorderedEquals([
            'mental_battery_low',
            'low_focus_time',
            'pulse_recovery_needed',
            'anticipation_risk',
          ]));
      final state = _xEngine.derive(n1: n1, snapshot: snap, currentTab: 0);
      expect(state.mode, ExperienceMode.recovery);
      expect(state.reasons,
          ['mental_battery_critical', 'pulse_recovery_needed']);
      expect(state.reasons, isNot(contains('anticipation_risk')));
      expect(state.primaryAction.actionType, IntelligentActionType.takeBreak);
      expect(state.primaryAction.targetTab, 2);
    });
  });

  group('7. Living Goals + Anticipate coexistence', () {
    final snap = _snap(
      tasks: [_task('t1'), _task('t2')],
      mentalBattery: 44,
      focusMinutesTotal: 0,
      goals: [_goal('g1', 0.2)],
      dailyStress: 70,
    );

    test('goal urgency never changes the mode; anticipation picks Pressure', () {
      final n1 = _service.evaluateN1(snap);
      expect(n1.goalState, 'at_risk');
      expect(n1.anticipationState, 'risk');
      expect(n1.pulseState, 'watch');
      expect(n1.understandState, 'reduced');
      expect(
          n1.riskFlags,
          unorderedEquals(
              ['low_focus_time', 'goal_at_risk', 'anticipation_risk']));
      final state = _xEngine.derive(n1: n1, snapshot: snap, currentTab: 0);
      expect(state.mode, ExperienceMode.pressure);
      expect(state.reasons, ['anticipation_risk']);
      expect(state.reasons, isNot(contains('goal_at_risk')));
    });

    test('at-risk goal advice keeps the last recommendation slot', () {
      final n1 = _service.evaluateN1(snap);
      expect(n1.recommendations, isNotEmpty);
      expect(n1.recommendations.first, startsWith('Commencer par '));
      expect(n1.recommendations.last, startsWith('Objectif « '));
    });
  });
  group('8. All four capabilities together', () {
    test('Scenario A: four signals promote, Experience shows one Recovery', () {
      final snap = _snap(
        tasks: [_task('t1'), _task('t2'), _task('t3')],
        mentalBattery: 30,
        focusMinutesTotal: 60,
        goals: [_goal('g1', 0.8)],
        dailyStress: 70,
      );
      final n1 = _service.evaluateN1(snap);
      expect(n1.pulseState, 'recovery_needed');
      expect(n1.understandState, 'elevated');
      expect(n1.goalState, 'on_track');
      expect(n1.anticipationState, 'risk');
      expect(
          n1.riskFlags,
          unorderedEquals([
            'mental_battery_low',
            'pulse_recovery_needed',
            'workload_elevated',
            'anticipation_risk',
          ]));
      final state = _xEngine.derive(n1: n1, snapshot: snap, currentTab: 0);
      expect(state.mode, ExperienceMode.recovery);
      expect(state.reasons,
          ['mental_battery_critical', 'pulse_recovery_needed']);
      expect(state.informationDensity, ExperienceDensity.minimal);
      expect(state.primaryAction.actionType, IntelligentActionType.takeBreak);
    });
  });

  group('9. Recovery precedence', () {
    test('recovery outranks workload and anticipation flags (manual N1)', () {
      final n1 = _n1(riskFlags: const [
        'pulse_recovery_needed',
        'workload_elevated',
        'anticipation_risk',
      ]);
      final state = _xEngine.derive(
          n1: n1, snapshot: _snap(mentalBattery: 80), currentTab: 0);
      expect(state.mode, ExperienceMode.recovery);
      expect(state.reasons, ['pulse_recovery_needed']);
      expect(state.reasons, isNot(contains('workload_elevated')));
      expect(state.reasons, isNot(contains('anticipation_risk')));
    });

    test('full pipeline: critical battery wins over backlog and workload', () {
      final snap =
          _snap(tasks: List.generate(6, (i) => _task('t$i')),
              mentalBattery: 30);
      final n1 = _service.evaluateN1(snap);
      expect(n1.riskFlags, contains('workload_elevated'));
      final state = _xEngine.derive(n1: n1, snapshot: snap, currentTab: 0);
      expect(state.mode, ExperienceMode.recovery);
      expect(state.reasons,
          ['mental_battery_critical', 'pulse_recovery_needed']);
    });

    test('Pulse alone triggers Recovery even with a healthy battery', () {
      final snap = _snap(mentalBattery: 80, dailyStress: 80);
      final n1 = _service.evaluateN1(snap);
      expect(n1.pulseState, 'recovery_needed');
      expect(n1.riskFlags, ['pulse_recovery_needed']);
      final state = _xEngine.derive(n1: n1, snapshot: snap, currentTab: 0);
      expect(state.mode, ExperienceMode.recovery);
      expect(state.reasons, ['pulse_recovery_needed']);
    });
  });
  group('10. Pressure precedence', () {
    test('Pressure wins over a missing check-in (elevated workload)', () {
      final snap = _snap(
          tasks: [_task('t1'), _task('t2'), _task('t3')],
          hasCheckedInToday: false);
      final n1 = _service.evaluateN1(snap);
      expect(n1.riskFlags, ['workload_elevated']);
      final state = _xEngine.derive(n1: n1, snapshot: snap, currentTab: 0);
      expect(state.mode, ExperienceMode.pressure);
      expect(state.reasons, ['workload_elevated']);
    });

    test('Pressure wins over a missing check-in (future risk alone)', () {
      final snap = _snap(
        tasks: [_task('t1'), _task('t2')],
        mentalBattery: 44,
        focusMinutesTotal: 0,
        goals: [_goal('g1', 0.8)],
        dailyStress: 70,
        hasCheckedInToday: false,
      );
      final n1 = _service.evaluateN1(snap);
      expect(
          n1.riskFlags, unorderedEquals(['low_focus_time', 'anticipation_risk']));
      final state = _xEngine.derive(n1: n1, snapshot: snap, currentTab: 0);
      expect(state.mode, ExperienceMode.pressure);
      expect(state.reasons, ['anticipation_risk']);
    });

    test('CheckIn stays independent when no signal is actionable', () {
      final snap = _snap(tasks: [_task('t1')], hasCheckedInToday: false);
      final n1 = _service.evaluateN1(snap);
      expect(n1.riskFlags, isEmpty);
      expect(n1.pulseState, 'stable');
      expect(n1.understandState, 'stable');
      expect(n1.anticipationState, 'clear');
      final state = _xEngine.derive(n1: n1, snapshot: snap, currentTab: 1);
      expect(state.mode, ExperienceMode.checkIn);
      expect(state.reasons, ['daily_check_in_missing']);
      expect(state.primaryAction.actionType, isNull);
      expect(state.primaryAction.targetTab, 1);
    });
  });

  group('11. Stable / default behavior', () {
    test('all four signals healthy → empty flags and the Priority surface', () {
      final snap =
          _snap(tasks: [_task('t1'), _task('t2')], goals: [_goal('g1', 0.8)]);
      final n1 = _service.evaluateN1(snap);
      expect(n1.riskFlags, isEmpty);
      expect(n1.pulseState, 'stable');
      expect(n1.understandState, 'stable');
      expect(n1.goalState, 'on_track');
      expect(n1.anticipationState, 'clear');
      final state = _xEngine.derive(n1: n1, snapshot: snap, currentTab: 0);
      expect(state.mode, ExperienceMode.priority);
      expect(state.reasons, ['open_task_available']);
      expect(
          state.primaryAction.actionType, IntelligentActionType.completeTask);
      expect(state.primaryAction.targetId, n1.primaryAction?.targetId);
    });

    test('legacy default: blank snapshot still resolves to Recovery', () {
      final blank = ContextSnapshot(now: fixedNow, generatedAt: fixedNow);
      final n1 = _service.evaluateN1(blank);
      expect(n1.pulseState, isNull);
      expect(n1.understandState, isNull);
      expect(n1.goalState, isNull);
      expect(n1.anticipationState, 'clear');
      expect(n1.riskFlags,
          unorderedEquals(['mental_battery_low', 'low_focus_time']));
      final state = _xEngine.derive(n1: n1, snapshot: blank, currentTab: 0);
      expect(state.mode, ExperienceMode.recovery);
      expect(state.reasons, ['mental_battery_critical']);
    });

    test('no tasks, no goals, checked in → calm free-focus fallback', () {
      final snap = _snap();
      final n1 = _service.evaluateN1(snap);
      expect(n1.riskFlags, isEmpty);
      final state = _xEngine.derive(n1: n1, snapshot: snap, currentTab: 0);
      expect(state.mode, ExperienceMode.calm);
      expect(state.reasons, ['no_urgent_work']);
      expect(state.primaryAction.actionType, IntelligentActionType.startFocus);
      expect(state.primaryAction.targetTab, 2);
    });
  });
  group('12. Action consistency across modes', () {
    test('nodes never emit actions; N1 emits one coherent primary action', () {
      final snap =
          _snap(tasks: [_task('t1'), _task('t2')], goals: [_goal('g1', 0.8)]);
      expect(PulseNode().execute(snap).actions, isEmpty);
      expect(LivingGoalsNode().execute(snap).actions, isEmpty);
      expect(UnderstandNode().execute(snap).actions, isEmpty);
      expect(AnticipateNode().execute(snap).actions, isEmpty);
      final n1 = _service.evaluateN1(snap);
      expect(n1.primaryAction, isNotNull);
      expect(n1.primaryAction!.actionType, IntelligentActionType.startTask);
      expect(n1.primaryActionId, 'task:${n1.primaryAction!.targetId}');
      expect(n1.recommendations.first, startsWith('Commencer par '));
    });

    test('each Experience mode exposes exactly the canonical action contract',
        () {
      // Recovery: flags-only promotion on a healthy raw battery.
      final recovery = _xEngine.derive(
        n1: _n1(
            riskFlags: const ['pulse_recovery_needed'],
            primaryTargetId: 't1'),
        snapshot: _snap(mentalBattery: 80),
        currentTab: 0,
      );
      expect(recovery.primaryAction.actionType,
          IntelligentActionType.takeBreak);
      expect(recovery.primaryAction.targetTab, 2);

      // Pressure: future risk dominates.
      final pressure = _xEngine.derive(
        n1: _n1(riskFlags: const ['anticipation_risk']),
        snapshot: _snap(),
        currentTab: 0,
      );
      expect(pressure.primaryAction.actionType,
          IntelligentActionType.adjustPriority);
      expect(pressure.primaryAction.targetTab, 1);

      // CheckIn: no action; echoes the current tab.
      final checkIn = _xEngine.derive(
        n1: _n1(),
        snapshot: _snap(hasCheckedInToday: false),
        currentTab: 1,
      );
      expect(checkIn.primaryAction.actionType, isNull);
      expect(checkIn.primaryAction.targetTab, 1);

      // Priority: reuses N1's task selection as-is.
      final priority = _xEngine.derive(
        n1: _n1(primaryTargetId: 't2'),
        snapshot: _snap(tasks: [_task('t1'), _task('t2')]),
        currentTab: 0,
      );
      expect(
          priority.primaryAction.actionType, IntelligentActionType.completeTask);
      expect(priority.primaryAction.targetId, 't2');

      // Calm: reuses N1's canonical goal (not a second ranking).
      final calm = _xEngine.derive(
        n1: _n1(primaryGoalId: 'g2'),
        snapshot: _snap(goals: [_goal('g1', 0.8), _goal('g2', 0.9)]),
        currentTab: 0,
      );
      expect(calm.primaryAction.actionType, isNull);
      expect(calm.primaryAction.targetId, 'g2');
    });
  });

  group('13. Deterministic results', () {
    test('same input state produces identical decisions across runs', () {
      ContextSnapshot build() => _snap(
            tasks: [_task('t1'), _task('t2'), _task('t3')],
            mentalBattery: 30,
            focusMinutesTotal: 0,
            goals: [_goal('g1', 0.8)],
            dailyStress: 70,
          );
      final n1A = _service.evaluateN1(build());
      final n1B = _service.evaluateN1(build());
      expect(n1A.riskFlags, unorderedEquals(n1B.riskFlags));
      expect(n1A.pulseState, n1B.pulseState);
      expect(n1A.understandState, n1B.understandState);
      expect(n1A.goalState, n1B.goalState);
      expect(n1A.anticipationState, n1B.anticipationState);
      expect(n1A.recommendations, n1B.recommendations);
      expect(n1A.priorityLevel, n1B.priorityLevel);
      final stateA = _xEngine.derive(
          n1: n1A, snapshot: build(), currentTab: 0);
      final stateB = _xEngine.derive(
          n1: n1B, snapshot: build(), currentTab: 0);
      expect(stateA.mode, stateB.mode);
      expect(stateA.reasons, stateB.reasons);
      expect(stateA.primaryAction.actionType,
          stateB.primaryAction.actionType);
      expect(stateA.primaryAction.targetId, stateB.primaryAction.targetId);
    });

    test('decisions do not depend on the time of day', () {
      final morning = _service.evaluateN1(
          _snap(mentalBattery: 30, now: DateTime(2026, 1, 15, 3, 0)));
      final afternoon = _service.evaluateN1(
          _snap(mentalBattery: 30, now: DateTime(2026, 1, 15, 15, 0)));
      expect(morning.riskFlags, unorderedEquals(afternoon.riskFlags));
      expect(morning.pulseState, afternoon.pulseState);
      expect(morning.understandState, afternoon.understandState);
      expect(morning.goalState, afternoon.goalState);
      expect(morning.anticipationState, afternoon.anticipationState);
      final stateA = _xEngine.derive(
          n1: morning, snapshot: _snap(), currentTab: 0);
      final stateB = _xEngine.derive(
          n1: afternoon, snapshot: _snap(), currentTab: 0);
      expect(stateA.mode, stateB.mode);
      expect(stateA.reasons, stateB.reasons);
    });
  });






}
