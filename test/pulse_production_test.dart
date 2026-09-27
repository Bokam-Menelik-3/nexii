import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nexii/core/theme/app_theme.dart';
import 'package:nexii/experience/experience_engine.dart';
import 'package:nexii/experience/models/experience_mode.dart';
import 'package:nexii/intelligence/models/intelligence_models.dart';
import 'package:nexii/intelligence/nodes/pulse_node.dart';
import 'package:nexii/intelligence/services/intelligence_service.dart';
import 'package:nexii/providers/app_state_provider.dart';
import 'package:nexii/screens/home_screen.dart';

/// Phase 1 — Pulse production activation.
///
/// Covers: signal generation, edge cases, canonical (N1) integration,
/// Experience transition caused by Pulse, and unchanged behavior when Pulse
/// is inactive. Pulse stays internal: no screen/ExperienceEngine import.
ContextSnapshot buildSnapshot({
  int mentalBattery = 85,
  int? dailyEnergy,
  int? dailyMotivation,
  int? dailyStress,
  bool hasCheckedInToday = true,
  List<TaskSummary> openTasks = const [],
  int focusMinutesTotal = 60,
}) {
  final now = DateTime(2026, 9, 4, 10, 0);
  return ContextSnapshot(
    userId: 'u-1',
    displayName: 'Test User',
    tasks: openTasks,
    openTasks: openTasks,
    hasCheckedInToday: hasCheckedInToday,
    mentalBattery: mentalBattery,
    focusMinutesTotal: focusMinutesTotal,
    dailyEnergy: dailyEnergy,
    dailyMotivation: dailyMotivation,
    dailyStress: dailyStress,
    now: now,
    generatedAt: now,
  );
}

const TaskSummary pulseTask = TaskSummary(
  id: 't-pulse',
  title: 'Rapport pulse',
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

  group('1. Pulse signal generation', () {
    test('stress 5/5 with healthy battery → recovery_needed', () {
      final result = PulseNode().execute(
        buildSnapshot(mentalBattery: 85, dailyStress: 5),
      );

      expect(result.nodeId, 'pulse');
      expect(result.metadata['pulseState'], 'recovery_needed');
      expect(result.status, IntelligenceStatus.critical);
      expect(result.riskFlags, contains('pulse_watch'));
      expect(result.actions, isEmpty);
    });

    test('battery below 35 → recovery_needed', () {
      final result = PulseNode().execute(buildSnapshot(mentalBattery: 30));

      expect(result.metadata['pulseState'], 'recovery_needed');
      expect(result.status, IntelligenceStatus.critical);
    });

    test('battery below 55 → watch', () {
      final result = PulseNode().execute(buildSnapshot(mentalBattery: 45));

      expect(result.metadata['pulseState'], 'watch');
      expect(result.status, IntelligenceStatus.warning);
    });

    test('healthy battery + low stress + good energy → stable', () {
      final result = PulseNode().execute(
        buildSnapshot(
          mentalBattery: 85,
          dailyEnergy: 4,
          dailyMotivation: 4,
          dailyStress: 1,
        ),
      );

      expect(result.metadata['pulseState'], 'stable');
      expect(result.status, IntelligenceStatus.ok);
      expect(result.riskFlags, isEmpty);
    });

    test('mid-range context → mixed', () {
      final result = PulseNode().execute(
        buildSnapshot(
          mentalBattery: 60,
          dailyEnergy: 3,
          dailyMotivation: 3,
          dailyStress: 3,
        ),
      );

      expect(result.metadata['pulseState'], 'mixed');
      expect(result.status, IntelligenceStatus.warning);
    });

    test('signal generation is deterministic for identical input', () {
      final snapshot = buildSnapshot(mentalBattery: 85, dailyStress: 5);

      final first = PulseNode().execute(snapshot);
      final second = PulseNode().execute(snapshot);

      expect(first.metadata['pulseState'], second.metadata['pulseState']);
      expect(first.status, second.status);
    });
  });

  group('2. Pulse edge cases', () {
    test('null daily values behave as no data (watch, never recovery)', () {
      final pulse = PulseNode();
      final snapshot = buildSnapshot(mentalBattery: 60);

      expect(pulse.isRelevant(snapshot), isTrue);
      expect(pulse.execute(snapshot).metadata['pulseState'], 'watch');
    });

    test('boundary: stress 4/5 (75) triggers recovery, 3/5 (50) does not', () {
      final atBoundary = PulseNode().execute(
        buildSnapshot(
          mentalBattery: 85,
          dailyEnergy: 4,
          dailyMotivation: 4,
          dailyStress: 4,
        ),
      );
      final belowBoundary = PulseNode().execute(
        buildSnapshot(
          mentalBattery: 85,
          dailyEnergy: 4,
          dailyMotivation: 4,
          dailyStress: 3,
        ),
      );

      expect(atBoundary.metadata['pulseState'], 'recovery_needed');
      expect(belowBoundary.metadata['pulseState'], 'mixed');
    });

    test('values outside 1-5 pass through unchanged (0-100 inputs)', () {
      final result = PulseNode().execute(
        buildSnapshot(
          mentalBattery: 68,
          dailyEnergy: 82,
          dailyMotivation: 74,
          dailyStress: 30,
        ),
      );

      expect(result.metadata['dailyEnergy'], 82);
      expect(result.metadata['dailyStress'], 30);
      expect(result.metadata['pulseState'], 'mixed');
    });

    test('battery exactly 35: stress decides recovery', () {
      final healthy = PulseNode().execute(
        buildSnapshot(mentalBattery: 35, dailyStress: 1),
      );
      final stressed = PulseNode().execute(
        buildSnapshot(mentalBattery: 35, dailyStress: 5),
      );

      expect(healthy.metadata['pulseState'], isNot('recovery_needed'));
      expect(stressed.metadata['pulseState'], 'recovery_needed');
    });

    test('pulse is not relevant for an empty default snapshot', () {
      final snapshot = ContextSnapshot(
        mentalBattery: 0,
        now: DateTime(2026, 9, 4, 10, 0),
        generatedAt: DateTime(2026, 9, 4, 10, 0),
      );

      expect(PulseNode().isRelevant(snapshot), isFalse);
    });
  });

  group('3. Integration into canonical intelligence', () {
    test('recovery-grade pulse is promoted into the N1 risk flags', () {
      final snapshot = buildSnapshot(
        mentalBattery: 85,
        dailyEnergy: 4,
        dailyMotivation: 4,
        dailyStress: 5,
        openTasks: const [pulseTask],
      );

      final summary = IntelligenceService().evaluateN1(snapshot);

      expect(summary.pulseState, 'recovery_needed');
      expect(summary.riskFlags, contains('pulse_recovery_needed'));
      // Existing N1 behavior remains intact alongside the enrichment.
      expect(summary.primaryActionId, 'task:t-pulse');
      expect(summary.recommendations, isNotEmpty);
    });

    test('stable pulse enriches the result without adding risk flags', () {
      final snapshot = buildSnapshot(
        mentalBattery: 85,
        dailyEnergy: 4,
        dailyMotivation: 4,
        dailyStress: 1,
        openTasks: const [pulseTask],
      );

      final summary = IntelligenceService().evaluateN1(snapshot);

      expect(summary.pulseState, 'stable');
      expect(summary.riskFlags, isNot(contains('pulse_recovery_needed')));
    });

    test('watch pulse stays informational only', () {
      final summary =
          IntelligenceService().evaluateN1(buildSnapshot(mentalBattery: 45));

      expect(summary.pulseState, 'watch');
      expect(summary.riskFlags, isNot(contains('pulse_recovery_needed')));
    });

    test('inactive pulse leaves the summary free of pulse signals', () {
      final snapshot = ContextSnapshot(
        mentalBattery: 0,
        now: DateTime(2026, 9, 4, 10, 0),
        generatedAt: DateTime(2026, 9, 4, 10, 0),
      );

      final summary = IntelligenceService().evaluateN1(snapshot);

      expect(summary.pulseState, isNull);
      expect(summary.riskFlags, isNot(contains('pulse_recovery_needed')));
    });
  });

  group('4. Experience transition caused by Pulse', () {
    test('same context: pulse recovery flips ExperienceMode to Recovery', () {
      const engine = ExperienceEngine();
      final service = IntelligenceService();

      final stressedSnapshot = buildSnapshot(
        mentalBattery: 85,
        dailyEnergy: 4,
        dailyMotivation: 4,
        dailyStress: 5,
        openTasks: const [pulseTask],
      );
      final calmSnapshot = buildSnapshot(
        mentalBattery: 85,
        dailyEnergy: 4,
        dailyMotivation: 4,
        dailyStress: 1,
        openTasks: const [pulseTask],
      );

      final stressedState = engine.derive(
        n1: service.evaluateN1(stressedSnapshot),
        snapshot: stressedSnapshot,
        currentTab: 0,
      );
      final calmState = engine.derive(
        n1: service.evaluateN1(calmSnapshot),
        snapshot: calmSnapshot,
        currentTab: 0,
      );

      // Identical context except the Pulse stress signal: the mode differs.
      expect(stressedState.mode, ExperienceMode.recovery);
      expect(stressedState.reasons, const ['pulse_recovery_needed']);
      expect(calmState.mode, ExperienceMode.priority);
      expect(calmState.reasons, const ['open_task_available']);
    });

    testWidgets(
        'Home follows the Pulse signal: Recovery appears and disappears',
        (WidgetTester tester) async {
      final provider = AppStateProvider();
      addTearDown(provider.dispose);

      provider.completeOnboarding('Iris', '1993-05-05');
      // Stress 5/5 with healthy battery: only Pulse can justify Recovery here.
      provider.submitDailyCheckIn(4, 4, 4, 5, 7);
      provider.addTask('Rapport pulse', 'Description', 'Pro',
          priority: 'Haute', urgency: 'Haute');

      await tester.pumpWidget(buildTestableHomeScreen(provider));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Récupération Nécessaire'), findsOneWidget);
      expect(find.text('RÉCUPÉRATION'), findsOneWidget); // mode label chip
      expect(find.text('TON MOMENT'), findsNothing);

      // Stress drops to 1/5 → pulse signal recovers → Priority surface.
      provider.submitDailyCheckIn(4, 4, 4, 1, 7);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Rapport pulse'), findsOneWidget);
      expect(find.text('TON MOMENT'), findsOneWidget); // mode label chip
      expect(find.text('Récupération Nécessaire'), findsNothing);
      expect(find.text('RÉCUPÉRATION'), findsNothing);
    });
  });

  group('5. Existing behavior unchanged when Pulse is inactive', () {
    test('inactive pulse → battery rule alone decides Recovery reasons', () {
      const engine = ExperienceEngine();
      final snapshot = ContextSnapshot(
        mentalBattery: 0,
        hasCheckedInToday: true,
        now: DateTime(2026, 9, 4, 10, 0),
        generatedAt: DateTime(2026, 9, 4, 10, 0),
      );
      final n1 = IntelligenceService().evaluateN1(snapshot);

      expect(n1.pulseState, isNull);

      final state = engine.derive(n1: n1, snapshot: snapshot, currentTab: 0);

      expect(state.mode, ExperienceMode.recovery);
      expect(state.reasons, const ['mental_battery_critical']);
    });

    test('non-actionable pulse (watch) leaves the experience untouched', () {
      const engine = ExperienceEngine();
      final snapshot = buildSnapshot(
        mentalBattery: 45,
        openTasks: const [pulseTask],
      );
      final n1 = IntelligenceService().evaluateN1(snapshot);

      expect(n1.pulseState, 'watch'); // signal exposed…
      expect(n1.riskFlags, isNot(contains('pulse_recovery_needed')));

      // …but the decision layer did not act on it: same experience as before.
      final state = engine.derive(n1: n1, snapshot: snapshot, currentTab: 0);

      expect(state.mode, ExperienceMode.priority);
      expect(state.reasons, const ['open_task_available']);
    });
  });
}
