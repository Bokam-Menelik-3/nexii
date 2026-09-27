import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nexii/core/theme/app_theme.dart';
import 'package:nexii/experience/experience_engine.dart';
import 'package:nexii/experience/models/experience_mode.dart';
import 'package:nexii/experience/models/experience_state.dart';
import 'package:nexii/intelligence/engines/n1_decision_engine.dart';
import 'package:nexii/intelligence/models/intelligence_models.dart';
import 'package:nexii/intelligence/nodes/understand_node.dart';
import 'package:nexii/intelligence/services/intelligence_service.dart';
import 'package:nexii/providers/app_state_provider.dart';
import 'package:nexii/screens/home_screen.dart';

/// Phase 3 — Understand production activation.
///
/// Covers: workload classification (the Understand node's own vocabulary
/// only, no invented thresholds), canonical (N1) integration, Experience
/// integration including deterministic precedence with Pulse and Living
/// Goals, and the user-visible consequence on Home. Understand stays
/// internal: no screen/Experience import of UnderstandNode, no second
/// workload scorer, no new ExperienceMode.
ContextSnapshot buildSnapshot({
  List<TaskSummary>? tasks,
  List<TaskSummary> openTasks = const [],
  List<GoalSummary> goals = const [],
  int mentalBattery = 85,
  int? dailyStress = 30,
  int? dailySleep = 7,
  int focusMinutesTotal = 60,
  bool hasCheckedInToday = true,
}) {
  final now = DateTime(2026, 9, 4, 10, 0);
  return ContextSnapshot(
    userId: 'u-1',
    displayName: 'Test User',
    tasks: tasks ?? openTasks,
    openTasks: openTasks,
    goals: goals,
    hasCheckedInToday: hasCheckedInToday,
    mentalBattery: mentalBattery,
    focusMinutesTotal: focusMinutesTotal,
    dailyStress: dailyStress,
    dailySleep: dailySleep,
    now: now,
    generatedAt: now,
  );
}

TaskSummary openTask(String id) =>
    TaskSummary(id: id, title: 'Tâche $id', isCompleted: false);
TaskSummary doneTask(String id) =>
    TaskSummary(id: id, title: 'Terminée $id', isCompleted: true);

const GoalSummary atRiskGoal =
    GoalSummary(id: 'g-risk', title: 'Objectif critique', progress: 0.20);
const TaskSummary mainTask = TaskSummary(
  id: 't1',
  title: 'Rapport',
  isCompleted: false,
  priority: 'Haute',
  urgency: 'Haute',
  difficulty: 'Moyen',
  estimatedTimeMinutes: 45,
);

final DateTime fixedNow = DateTime(2026, 9, 4, 10, 0);

/// Hand-built N1 summary for pure ExperienceEngine tests: carries only what
/// the engine reads (risk flags) so flag-to-mode math is tested in isolation
/// from the node pipeline.
N1Summary manualN1({List<String> riskFlags = const []}) => N1Summary(
      summaryId: 'n1_test',
      generatedAt: fixedNow,
      currentStateSummary: 'state',
      primaryActionId: null,
      primaryReason: 'reason',
      priorityLevel: PriorityLevel.low,
      confidence: 0.8,
      riskFlags: riskFlags,
      recommendations: const <String>['rec'],
    );

Widget buildTestableHomeScreen(
  AppStateProvider provider, {
  Size screenSize = const Size(390, 844),
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AppStateProvider>.value(value: provider),
    ],
    child: Builder(
      builder: (context) {
        return MediaQuery(
          data: MediaQueryData(size: screenSize),
          child: MaterialApp(
            themeMode: provider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            locale: provider.currentLocale,
            supportedLocales: const [
              Locale('fr', 'FR'),
              Locale('en', 'US'),
              Locale('es', 'ES'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const HomeScreen(),
          ),
        );
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const engine = ExperienceEngine();
  final service = IntelligenceService();

  group('1. Understand signal — low workload', () {
    test('few open tasks with healthy context → stable, no promotion', () {
      final snapshot = buildSnapshot(openTasks: [openTask('t1')]);
      final node = UnderstandNode();

      expect(node.isRelevant(snapshot), isTrue);
      expect(node.execute(snapshot).metadata['signal'], 'état stable');

      final n1 = service.evaluateN1(snapshot);
      expect(n1.understandState, 'stable');
      expect(n1.riskFlags, isNot(contains('workload_elevated')));
    });
  });

  group('2. Understand signal — medium workload', () {
    test('medium load is not a distinct tier: 2 open tasks stay stable', () {
      // The node classifies only stable / elevated / reduced — there is no
      // separate medium category to expose. Nothing new is invented here.
      final snapshot = buildSnapshot(
        openTasks: [openTask('t1'), openTask('t2')],
        mentalBattery: 60,
        dailyStress: 40,
      );

      final n1 = service.evaluateN1(snapshot);
      expect(n1.understandState, 'stable');
      expect(n1.riskFlags, isNot(contains('workload_elevated')));
    });
  });

  group('3. Understand signal — high workload', () {
    test('3 open tasks → elevated workload with canonical risk flag', () {
      final snapshot = buildSnapshot(
        openTasks: [openTask('t1'), openTask('t2'), openTask('t3')],
      );
      final result = UnderstandNode().execute(snapshot);
      expect(result.metadata['signal'], 'charge de travail élevée');

      final n1 = service.evaluateN1(snapshot);
      expect(n1.understandState, 'elevated');
      expect(n1.riskFlags, contains('workload_elevated'));
    });
  });

  group('4. Understand signal — boundary conditions', () {
    test('3 open tasks is elevated, 2 open tasks is not', () {
      final two = service
          .evaluateN1(buildSnapshot(openTasks: [openTask('t1'), openTask('t2')]));
      expect(two.understandState, 'stable');
      expect(two.riskFlags, isNot(contains('workload_elevated')));

      final three = service.evaluateN1(buildSnapshot(
          openTasks: [openTask('t1'), openTask('t2'), openTask('t3')]));
      expect(three.understandState, 'elevated');
      expect(three.riskFlags, contains('workload_elevated'));
    });

    test('5 total tasks with battery 44 → elevated', () {
      final snapshot = buildSnapshot(
        tasks: [
          openTask('t1'),
          openTask('t2'),
          doneTask('t3'),
          doneTask('t4'),
          doneTask('t5'),
        ],
        openTasks: [openTask('t1'), openTask('t2')],
        mentalBattery: 44,
      );
      expect(service.evaluateN1(snapshot).understandState, 'elevated');
    });

    test('5 total tasks with battery 45 → below the battery threshold', () {
      final snapshot = buildSnapshot(
        tasks: [
          openTask('t1'),
          openTask('t2'),
          doneTask('t3'),
          doneTask('t4'),
          doneTask('t5'),
        ],
        openTasks: [openTask('t1'), openTask('t2')],
        mentalBattery: 45,
      );
      expect(service.evaluateN1(snapshot).understandState, 'stable');
    });

    test('4 total tasks with battery 44 → reduced activity, not elevated', () {
      final snapshot = buildSnapshot(
        tasks: [
          openTask('t1'),
          openTask('t2'),
          doneTask('t3'),
          doneTask('t4'),
        ],
        openTasks: [openTask('t1'), openTask('t2')],
        mentalBattery: 44,
      );
      final n1 = service.evaluateN1(snapshot);
      expect(n1.understandState, 'reduced');
      expect(n1.riskFlags, isNot(contains('workload_elevated')));
    });

    test('high stress stays out of the workload classification', () {
      // Stress belongs to Pulse: the node reports its own workload_pressure
      // flag here, but N1 keys off the classification — not the node flag —
      // so nothing is double-promoted into Pressure.
      final snapshot = buildSnapshot(
        openTasks: [openTask('t1'), openTask('t2')],
        dailyStress: 70,
      );
      final nodeResult = UnderstandNode().execute(snapshot);
      expect(nodeResult.riskFlags, contains('workload_pressure'));

      final n1 = service.evaluateN1(snapshot);
      expect(n1.understandState, 'reduced');
      expect(n1.riskFlags, isNot(contains('workload_elevated')));
    });
  });

  group('5. Understand signal — missing/empty data', () {
    test('blank context → node not relevant, understandState null', () {
      final snapshot = ContextSnapshot(now: fixedNow, generatedAt: fixedNow);

      expect(UnderstandNode().isRelevant(snapshot), isFalse);

      final n1 = service.evaluateN1(snapshot);
      expect(n1.understandState, isNull);
      expect(n1.pulseState, isNull);
      expect(n1.goalState, isNull);
    });

    test('battery present but no tasks → idle stable classification', () {
      final snapshot = buildSnapshot(); // no tasks at all
      final nodeResult = UnderstandNode().execute(snapshot);
      expect(nodeResult.metadata['signal'], 'état stable');

      final n1 = service.evaluateN1(snapshot);
      expect(n1.understandState, 'stable');
      expect(n1.riskFlags, isNot(contains('workload_elevated')));
    });

    test('N1 without Understand input → understandState null', () {
      final n1 =
          const N1DecisionEngine().evaluate(buildSnapshot(openTasks: [mainTask]));
      expect(n1.understandState, isNull);
      expect(n1.riskFlags, isNot(contains('workload_elevated')));
    });
  });

  group('6. Coexistence with Pulse', () {
    test('elevated workload and a watch-level Pulse coexist on one summary',
        () {
      final snapshot = buildSnapshot(
        openTasks: [openTask('t1'), openTask('t2'), openTask('t3')],
        mentalBattery: 40,
      );

      final n1 = service.evaluateN1(snapshot);
      expect(n1.understandState, 'elevated');
      expect(n1.pulseState, 'watch');
      expect(n1.riskFlags, contains('workload_elevated'));
      expect(n1.riskFlags, isNot(contains('pulse_recovery_needed')));

      final state = engine.derive(n1: n1, snapshot: snapshot, currentTab: 0);
      expect(state.mode, ExperienceMode.pressure);
      expect(state.reasons, ['workload_elevated']);
    });

    test('recovery-grade Pulse outranks elevated workload', () {
      final snapshot = buildSnapshot(
        openTasks: [openTask('t1'), openTask('t2'), openTask('t3')],
        mentalBattery: 30,
      );

      final n1 = service.evaluateN1(snapshot);
      expect(n1.pulseState, 'recovery_needed');
      expect(n1.understandState, 'elevated'); // still recorded, informational
      expect(n1.riskFlags, contains('pulse_recovery_needed'));
      expect(n1.riskFlags, contains('workload_elevated'));

      final state = engine.derive(n1: n1, snapshot: snapshot, currentTab: 0);
      expect(state.mode, ExperienceMode.recovery);
      expect(state.reasons,
          ['mental_battery_critical', 'pulse_recovery_needed']);
    });

    test('reduced activity stays informational: Priority is unchanged', () {
      final snapshot = buildSnapshot(
        openTasks: [openTask('t1')],
        mentalBattery: 40,
      );

      final n1 = service.evaluateN1(snapshot);
      expect(n1.pulseState, 'watch');
      expect(n1.understandState, 'reduced');
      expect(n1.riskFlags, isNot(contains('workload_elevated')));

      final state = engine.derive(n1: n1, snapshot: snapshot, currentTab: 0);
      expect(state.mode, ExperienceMode.priority);
      expect(state.reasons, ['open_task_available']);
    });
  });

  group('7. Coexistence with Living Goals', () {
    test('at-risk goal and elevated workload both surface on one summary',
        () {
      final snapshot = buildSnapshot(
        openTasks: [openTask('t1'), openTask('t2'), openTask('t3')],
        goals: const [atRiskGoal],
      );

      final n1 = service.evaluateN1(snapshot);
      expect(n1.goalState, 'at_risk');
      expect(n1.understandState, 'elevated');
      expect(n1.riskFlags, contains('goal_at_risk'));
      expect(n1.riskFlags, contains('workload_elevated'));
      // Workload adds no recommendation: task advice keeps the first slot
      // and the goal advice still closes the list (precedence preserved).
      expect(n1.recommendations.first, startsWith('Commencer par'));
      expect(n1.recommendations.last, contains('à risque'));
      expect(n1.recommendations.where((r) => r.contains('à risque')),
          hasLength(1));
    });

    test(
        'at-risk goal with a single task: no workload promotion, Priority '
        'annotates the goal', () {
      final snapshot = buildSnapshot(
        openTasks: [mainTask],
        goals: const [atRiskGoal],
      );

      final n1 = service.evaluateN1(snapshot);
      expect(n1.goalState, 'at_risk');
      expect(n1.understandState, 'stable');
      expect(n1.riskFlags, isNot(contains('workload_elevated')));

      final state = engine.derive(n1: n1, snapshot: snapshot, currentTab: 0);
      expect(state.mode, ExperienceMode.priority);
      expect(state.reasons, ['open_task_available', 'goal_at_risk']);
    });
  });

  group('8. Canonical intelligence integration', () {
    test('evaluateN1 gates Understand by isRelevant', () {
      final blank = ContextSnapshot(now: fixedNow, generatedAt: fixedNow);
      expect(service.understandNode.isRelevant(blank), isFalse);
      expect(service.evaluateN1(blank).understandState, isNull);

      final active = buildSnapshot(openTasks: [openTask('t1')]);
      expect(service.understandNode.isRelevant(active), isTrue);
      expect(service.evaluateN1(active).understandState, 'stable');
    });

    test('N1 enrichment is additive: existing fields keep their behavior',
        () {
      final snapshot = buildSnapshot(openTasks: [mainTask], mentalBattery: 40);

      final n1 = service.evaluateN1(snapshot);
      expect(n1.primaryActionId, 'task:t1');
      expect(n1.priorityLevel, PriorityLevel.high); // battery < 50
      expect(n1.recommendations.where((r) => r.contains('Réduire la charge')),
          hasLength(1));
      expect(n1.understandState, 'reduced'); // battery 44 boundary branch
    });

    test('runUnderstand keeps returning the node result for existing callers',
        () {
      final result =
          service.runUnderstand(buildSnapshot(openTasks: [openTask('t1')]));
      expect(result.nodeId, 'understand');
      expect(result.metadata['signal'], 'état stable');
    });
  });

  group('9. Experience integration', () {
    test('workload_elevated flag → Pressure, reduced density, triage focus',
        () {
      final snapshot = buildSnapshot(openTasks: [mainTask]);
      final state = engine.derive(
        n1: manualN1(riskFlags: const ['workload_elevated']),
        snapshot: snapshot,
        currentTab: 0,
      );

      expect(state.mode, ExperienceMode.pressure);
      expect(state.dominantFocus, ExperienceDominantFocus.triage);
      expect(state.informationDensity, ExperienceDensity.reduced);
      expect(state.primaryAction.actionType, IntelligentActionType.adjustPriority);
      expect(state.primaryAction.targetTab, 1);
      expect(state.reasons, ['workload_elevated']);
    });

    test('Pressure (workload) beats a missing check-in, like backlog does',
        () {
      final state = engine.derive(
        n1: manualN1(riskFlags: const ['workload_elevated']),
        snapshot: buildSnapshot(hasCheckedInToday: false),
        currentTab: 0,
      );

      expect(state.mode, ExperienceMode.pressure);
      expect(state.reasons, ['workload_elevated']);
    });

    test('Recovery beats workload_elevated', () {
      final state = engine.derive(
        n1: manualN1(riskFlags: const ['workload_elevated']),
        snapshot: buildSnapshot(mentalBattery: 25),
        currentTab: 0,
      );

      expect(state.mode, ExperienceMode.recovery);
      expect(state.reasons, ['mental_battery_critical']);
    });

    test('without the flag, Priority / CheckIn / Calm behave exactly as before',
        () {
      final priority = engine.derive(
        n1: manualN1(),
        snapshot: buildSnapshot(openTasks: [mainTask]),
        currentTab: 0,
      );
      expect(priority.mode, ExperienceMode.priority);
      expect(priority.reasons, ['open_task_available']);

      final checkIn = engine.derive(
        n1: manualN1(),
        snapshot: buildSnapshot(hasCheckedInToday: false),
        currentTab: 0,
      );
      expect(checkIn.mode, ExperienceMode.checkIn);
      expect(checkIn.reasons, ['daily_check_in_missing']);

      final calm = engine.derive(
        n1: manualN1(),
        snapshot: buildSnapshot(goals: const [atRiskGoal]),
        currentTab: 0,
      );
      expect(calm.mode, ExperienceMode.calm);
      expect(calm.reasons, ['goal_progress_available']);
    });

    test('end to end: context → Understand → N1 → Experience → Pressure', () {
      final snapshot = buildSnapshot(
        openTasks: [openTask('t1'), openTask('t2'), openTask('t3')],
      );

      final n1 = service.evaluateN1(snapshot);
      expect(n1.understandState, 'elevated');

      final state = engine.derive(n1: n1, snapshot: snapshot, currentTab: 0);
      expect(state.mode, ExperienceMode.pressure);
      expect(state.informationDensity, ExperienceDensity.reduced);
      expect(state.reasons, ['workload_elevated']);
    });
  });

  group('10. Unchanged behavior without a meaningful signal', () {
    test('blank user: null signal contributes nothing to the experience', () {
      final snapshot = ContextSnapshot(now: fixedNow, generatedAt: fixedNow);

      final n1 = service.evaluateN1(snapshot);
      expect(n1.understandState, isNull);

      final state = engine.derive(n1: n1, snapshot: snapshot, currentTab: 0);
      expect(state.mode, ExperienceMode.recovery); // battery 0, legacy path
      expect(state.reasons, ['mental_battery_critical']);
    });

    test('stable signal is inert: legacy Priority path is untouched', () {
      final snapshot = buildSnapshot(openTasks: [mainTask]);

      final n1 = service.evaluateN1(snapshot);
      expect(n1.understandState, 'stable');
      expect(n1.riskFlags, isNot(contains('workload_elevated')));

      final state = engine.derive(n1: n1, snapshot: snapshot, currentTab: 0);
      expect(state.mode, ExperienceMode.priority);
      expect(state.reasons, ['open_task_available']);
    });
  });

  group('11. Home user-visible consequence', () {
    testWidgets('elevated workload → Home shows the triage surface',
        (WidgetTester tester) async {
      final provider = AppStateProvider();
      addTearDown(provider.dispose);

      provider.completeOnboarding('Iris', '1993-05-05');
      provider.submitDailyCheckIn(4, 4, 4, 1, 7);
      for (final title in ['Tâche A', 'Tâche B', 'Tâche C']) {
        provider.addTask(title, 'Description', 'Pro');
      }

      await tester.pumpWidget(buildTestableHomeScreen(provider));
      await tester.pump(const Duration(milliseconds: 100));

      // Pressure surface (3 open tasks → workload_elevated), not Priority.
      expect(find.text('Arriéré à Trier'), findsOneWidget);
      expect(find.text('À TRIER'), findsOneWidget);
      // One clear path: a single primary CTA.
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Trier mes tâches'), findsOneWidget);
    });

    testWidgets('single task → Home keeps its Priority card (unchanged)',
        (WidgetTester tester) async {
      final provider = AppStateProvider();
      addTearDown(provider.dispose);

      provider.completeOnboarding('Iris', '1993-05-05');
      provider.submitDailyCheckIn(4, 4, 4, 1, 7);
      provider.addTask('Rapport', 'Description', 'Pro',
          priority: 'Haute', urgency: 'Haute');

      await tester.pumpWidget(buildTestableHomeScreen(provider));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Arriéré à Trier'), findsNothing);
      expect(find.text('Rapport'), findsWidgets);
      expect(find.textContaining('Commencer par'), findsOneWidget);
    });
  });
}
