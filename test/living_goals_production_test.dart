import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nexii/core/theme/app_theme.dart';
import 'package:nexii/experience/experience_engine.dart';
import 'package:nexii/experience/models/experience_mode.dart';
import 'package:nexii/experience/models/experience_state.dart';
import 'package:nexii/intelligence/models/intelligence_models.dart';
import 'package:nexii/intelligence/nodes/living_goals_node.dart';
import 'package:nexii/intelligence/services/intelligence_service.dart';
import 'package:nexii/providers/app_state_provider.dart';
import 'package:nexii/screens/home_screen.dart';

/// Phase 2 — Living Goals production activation.
///
/// Covers: signal generation, canonical (N1) integration, Experience
/// integration including precedence with tasks/recovery, and the user-visible
/// consequence on Home. Living Goals stays internal: no screen/Experience
/// import of LivingGoalsNode, no second goal ranking, no new mode.
ContextSnapshot buildSnapshot({
  List<GoalSummary> goals = const [],
  List<MissionSummary> missions = const [],
  List<TaskSummary> openTasks = const [],
  int mentalBattery = 85,
  int? dailyStress,
  bool hasCheckedInToday = true,
  int focusMinutesTotal = 60,
}) {
  final now = DateTime(2026, 9, 4, 10, 0);
  return ContextSnapshot(
    userId: 'u-1',
    displayName: 'Test User',
    tasks: openTasks,
    openTasks: openTasks,
    goals: goals,
    missions: missions,
    hasCheckedInToday: hasCheckedInToday,
    mentalBattery: mentalBattery,
    focusMinutesTotal: focusMinutesTotal,
    dailyStress: dailyStress,
    now: now,
    generatedAt: now,
  );
}

const GoalSummary healthyGoal =
    GoalSummary(id: 'g-healthy', title: 'Objectif sain', progress: 0.8);
const GoalSummary laggingGoal =
    GoalSummary(id: 'g-lag', title: 'Objectif lent', progress: 0.30);
const GoalSummary atRiskGoal =
    GoalSummary(id: 'g-risk', title: 'Objectif critique', progress: 0.20);
const GoalSummary stableGoal =
    GoalSummary(id: 'g-stable', title: 'Objectif moyen', progress: 0.50);

const TaskSummary goalTask = TaskSummary(
  id: 't-goal',
  title: 'Rapport objectif',
  isCompleted: false,
  priority: 'Haute',
  urgency: 'Haute',
  difficulty: 'Moyen',
  estimatedTimeMinutes: 45,
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

  group('1. Living Goals signal generation', () {
    test('healthy goal → ok status, no risk flags, primary goal metadata',
        () {
      final node = LivingGoalsNode();
      final snapshot = buildSnapshot(goals: const [healthyGoal]);

      expect(node.isRelevant(snapshot), isTrue);

      final result = node.execute(snapshot);

      expect(result.nodeId, 'living_goals');
      expect(result.status, IntelligenceStatus.ok);
      expect(result.riskFlags, isEmpty);
      expect(result.metadata['goalCount'], 1);
      expect(result.metadata['primaryGoalId'], 'g-healthy');
      expect(result.metadata['primaryGoalProgress'], 0.8);
    });

    test('lagging goal → goal_lag flag only', () {
      final result =
          LivingGoalsNode().execute(buildSnapshot(goals: const [laggingGoal]));

      expect(result.status, IntelligenceStatus.warning);
      expect(result.riskFlags, contains('goal_lag'));
      expect(result.riskFlags, isNot(contains('goal_at_risk')));
    });

    test('goal at risk → goal_at_risk flag', () {
      final result =
          LivingGoalsNode().execute(buildSnapshot(goals: const [atRiskGoal]));

      expect(result.status, IntelligenceStatus.warning);
      expect(result.riskFlags, contains('goal_at_risk'));
    });

    test('no goals → node inactive (or idle without goal signal)', () {
      final node = LivingGoalsNode();

      // Nothing to evaluate at all: the canonical pipeline skips the node.
      expect(node.isRelevant(buildSnapshot()), isFalse);

      // Missions only: node runs but reports no active goal.
      final missionsOnly = node.execute(buildSnapshot(
        missions: const [
          MissionSummary(
              id: 'm1',
              title: 'Mission 1',
              progress: 0.5,
              isCompleted: false,
              xp: 10,
              claimed: false),
        ],
      ));
      expect(missionsOnly.status, IntelligenceStatus.idle);
      expect(missionsOnly.metadata['goalCount'], 0);
    });

    test('multiple goals → primary is the highest-progress goal', () {
      const low =
          GoalSummary(id: 'g-low', title: 'Le plus bas', progress: 0.10);
      const high =
          GoalSummary(id: 'g-high', title: 'Le plus haut', progress: 0.80);

      final result =
          LivingGoalsNode().execute(buildSnapshot(goals: const [low, high]));

      expect(result.metadata['primaryGoalId'], 'g-high');
      expect(result.metadata['averageGoalProgress'], closeTo(0.45, 0.0001));
      // Healthy spread: no lag and no at-risk signal.
      expect(result.riskFlags, isEmpty);

      // All goals below 0.25 → the whole set is at risk.
      const atRiskA = GoalSummary(id: 'g-a', title: 'A', progress: 0.10);
      const atRiskB = GoalSummary(id: 'g-b', title: 'B', progress: 0.15);
      final risky = LivingGoalsNode()
          .execute(buildSnapshot(goals: const [atRiskA, atRiskB]));
      expect(risky.riskFlags, contains('goal_at_risk'));
      expect(risky.metadata['primaryGoalId'], 'g-b');
    });
  });
  group('2. Canonical intelligence integration', () {
    test('healthy goal → on_track, no promoted flag, no at-risk advice', () {
      final n1 =
          IntelligenceService().evaluateN1(buildSnapshot(goals: const [healthyGoal]));

      expect(n1.goalState, 'on_track');
      expect(n1.primaryGoalId, 'g-healthy');
      expect(n1.riskFlags, isNot(contains('goal_at_risk')));
      expect(n1.recommendations.any((r) => r.contains('à risque')), isFalse);
    });

    test('stable goal → stable state, informational only', () {
      final n1 =
          IntelligenceService().evaluateN1(buildSnapshot(goals: const [stableGoal]));

      expect(n1.goalState, 'stable');
      expect(n1.riskFlags, isNot(contains('goal_at_risk')));
      expect(n1.recommendations.any((r) => r.contains('à risque')), isFalse);
    });

    test('lagging goal → lagging state exposed but never promoted', () {
      final n1 =
          IntelligenceService().evaluateN1(buildSnapshot(goals: const [laggingGoal]));

      expect(n1.goalState, 'lagging');
      expect(n1.primaryGoalId, 'g-lag');
      expect(n1.riskFlags, isNot(contains('goal_at_risk')));
      expect(n1.recommendations.any((r) => r.contains('à risque')), isFalse);
    });

    test('goal at risk → at_risk state, promoted flag and advice', () {
      final n1 =
          IntelligenceService().evaluateN1(buildSnapshot(goals: const [atRiskGoal]));

      expect(n1.goalState, 'at_risk');
      expect(n1.primaryGoalId, 'g-risk');
      expect(n1.riskFlags, contains('goal_at_risk'));
      expect(
        n1.recommendations.any((r) =>
            r.contains('« Objectif critique »') && r.contains('à risque')),
        isTrue,
      );
    });

    test('no goals → goal signal absent from the summary', () {
      final n1 = IntelligenceService().evaluateN1(buildSnapshot());

      expect(n1.goalState, isNull);
      expect(n1.primaryGoalId, isNull);
      expect(n1.riskFlags, isNot(contains('goal_at_risk')));
    });

    test('task priority keeps the primary slot; goal advice is appended last',
        () {
      final n1 = IntelligenceService().evaluateN1(
        buildSnapshot(goals: const [atRiskGoal], openTasks: const [goalTask]),
      );

      expect(n1.riskFlags, contains('goal_at_risk'));
      expect(n1.recommendations.first, startsWith('Commencer par'));
      expect(n1.recommendations.last, contains('à risque'));
    });

    test('recovery-grade context withholds goal advice but keeps the flag',
        () {
      // Low battery: recovery dominates — advice suppressed, signal kept.
      final lowBattery = IntelligenceService()
          .evaluateN1(buildSnapshot(goals: const [atRiskGoal], mentalBattery: 30));
      expect(lowBattery.riskFlags, contains('goal_at_risk'));
      expect(lowBattery.recommendations.any((r) => r.contains('à risque')),
          isFalse);

      // Recovery-grade Pulse (stress 5/5) also outranks the goal signal.
      final stressedPulse = IntelligenceService().evaluateN1(
          buildSnapshot(goals: const [atRiskGoal], dailyStress: 5));
      expect(stressedPulse.pulseState, 'recovery_needed');
      expect(stressedPulse.riskFlags, contains('goal_at_risk'));
      expect(stressedPulse.recommendations.any((r) => r.contains('à risque')),
          isFalse);
    });
  });
  group('3. Experience integration', () {
    const engine = ExperienceEngine();

    test('interaction with task priority → task stays dominant, goal annotates',
        () {
      final snapshot = buildSnapshot(
        goals: const [atRiskGoal],
        openTasks: const [goalTask],
      );
      final n1 = IntelligenceService().evaluateN1(snapshot);
      final state = engine.derive(n1: n1, snapshot: snapshot, currentTab: 0);

      // Precedence: task priority wins over goal urgency.
      expect(state.mode, ExperienceMode.priority);
      expect(state.dominantFocus, ExperienceDominantFocus.primaryTask);
      expect(state.primaryAction.targetId, 't-goal');
      // The at-risk goal is still visible as canonical context.
      expect(state.reasons, const ['open_task_available', 'goal_at_risk']);
    });

    test('goal at risk with no tasks → goal focus with canonical target', () {
      final snapshot = buildSnapshot(goals: const [atRiskGoal]);
      final n1 = IntelligenceService().evaluateN1(snapshot);
      final state = engine.derive(n1: n1, snapshot: snapshot, currentTab: 0);

      expect(state.mode, ExperienceMode.calm);
      expect(state.dominantFocus, ExperienceDominantFocus.goal);
      expect(state.primaryAction.targetId, 'g-risk');
      expect(state.primaryAction.targetTab, 1);
      expect(state.reasons, const ['goal_progress_available', 'goal_at_risk']);
    });

    test('multiple goals → canonical primary selected, not list order', () {
      const low =
          GoalSummary(id: 'g-low', title: 'Le plus bas', progress: 0.10);
      const high =
          GoalSummary(id: 'g-high', title: 'Le plus haut', progress: 0.80);
      final snapshot = buildSnapshot(goals: const [low, high]);
      final n1 = IntelligenceService().evaluateN1(snapshot);
      final state = engine.derive(n1: n1, snapshot: snapshot, currentTab: 0);

      // Living Goals' primary (g-high) is used — the ExperienceEngine must
      // not rank goals itself.
      expect(state.dominantFocus, ExperienceDominantFocus.goal);
      expect(state.primaryAction.targetId, 'g-high');
    });

    test('recovery outranks goal urgency', () {
      final snapshot =
          buildSnapshot(goals: const [atRiskGoal], mentalBattery: 30);
      final n1 = IntelligenceService().evaluateN1(snapshot);
      final state = engine.derive(n1: n1, snapshot: snapshot, currentTab: 0);

      expect(n1.riskFlags, contains('goal_at_risk')); // signal kept…
      expect(state.mode, ExperienceMode.recovery);
      expect(state.reasons,
          const ['mental_battery_critical', 'pulse_recovery_needed']); // …not shown
    });

    test('healthy goal → experience unchanged', () {
      final snapshot = buildSnapshot(goals: const [healthyGoal]);
      final n1 = IntelligenceService().evaluateN1(snapshot);
      final state = engine.derive(n1: n1, snapshot: snapshot, currentTab: 0);

      expect(state.mode, ExperienceMode.calm);
      expect(state.dominantFocus, ExperienceDominantFocus.goal);
      expect(state.primaryAction.targetId, 'g-healthy');
      expect(state.reasons, const ['goal_progress_available']);
    });

    test('lagging goal → informational only, experience unchanged', () {
      final snapshot = buildSnapshot(goals: const [laggingGoal]);
      final n1 = IntelligenceService().evaluateN1(snapshot);
      final state = engine.derive(n1: n1, snapshot: snapshot, currentTab: 0);

      expect(n1.goalState, 'lagging');
      expect(state.reasons, const ['goal_progress_available']);
    });

    test('no goals → neutral calm experience (unchanged fallback)', () {
      final snapshot = buildSnapshot();
      final n1 = IntelligenceService().evaluateN1(snapshot);
      final state = engine.derive(n1: n1, snapshot: snapshot, currentTab: 0);

      expect(state.mode, ExperienceMode.calm);
      expect(state.dominantFocus, ExperienceDominantFocus.calm);
      expect(state.reasons, const ['no_urgent_work']);
    });
  });
  group('4. Home user-visible result', () {
    testWidgets('at-risk goal → existing goal surface shows the advice', (
      tester,
    ) async {
      final provider = AppStateProvider();
      addTearDown(provider.dispose);

      provider.completeOnboarding('Iris', '1993-05-05');
      provider.submitDailyCheckIn(4, 4, 4, 1, 7); // calm pulse, checked in
      provider.addGoal('Objectif critique', 'Santé'); // progress 0.0 → at risk

      await tester.pumpWidget(buildTestableHomeScreen(provider));
      await tester.pump(const Duration(milliseconds: 100));

      // Existing Calm goal surface stays (no new UI component)…
      expect(find.text('Objectif critique'), findsWidgets);
      // …and now carries the canonical at-risk advice from N1.
      expect(find.textContaining('à risque'), findsOneWidget);
    });

    testWidgets('healthy goal → Home unchanged, no at-risk advice', (
      tester,
    ) async {
      final provider = AppStateProvider();
      addTearDown(provider.dispose);

      provider.completeOnboarding('Iris', '1993-05-05');
      provider.submitDailyCheckIn(4, 4, 4, 1, 7);
      provider.addGoal('Objectif sain', 'Pro');
      provider.updateGoalProgress(provider.goals.first['id'].toString(), 0.8);

      await tester.pumpWidget(buildTestableHomeScreen(provider));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Objectif sain'), findsWidgets);
      expect(find.textContaining('à risque'), findsNothing);
    });

    testWidgets('task priority wins: Priority card keeps the primary slot', (
      tester,
    ) async {
      final provider = AppStateProvider();
      addTearDown(provider.dispose);

      provider.completeOnboarding('Iris', '1993-05-05');
      provider.submitDailyCheckIn(4, 4, 4, 1, 7);
      provider.addGoal('Objectif critique', 'Santé'); // at risk
      provider.addTask('Rapport objectif', 'Description', 'Pro',
          priority: 'Haute', urgency: 'Haute');

      await tester.pumpWidget(buildTestableHomeScreen(provider));
      await tester.pump(const Duration(milliseconds: 100));

      // Priority surface + task recommendation stay primary…
      expect(find.text('Rapport objectif'), findsWidgets);
      expect(find.textContaining('Commencer par'), findsOneWidget);
      // …the at-risk goal advice does not displace the task.
      expect(find.textContaining('à risque'), findsNothing);
    });
  });
}
