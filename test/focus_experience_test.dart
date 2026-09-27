import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nexii/core/theme/nexii_colors.dart';
import 'package:nexii/experience/models/experience_action.dart';
import 'package:nexii/experience/models/experience_mode.dart';
import 'package:nexii/experience/models/experience_state.dart';
import 'package:nexii/intelligence/models/intelligence_models.dart';
import 'package:nexii/providers/app_state_provider.dart';
import 'package:nexii/screens/focus_screen.dart';

/// Focus ↔ Experience integration suite.
///
/// Verifies Focus consumes the same canonical interpretation as Home and
/// Tasks:
///
///   Context → Intelligence → ExperienceState → Focus presentation.
///
/// Focus presents only: `_FocusPresentation` derives copy, density,
/// spacing, glow, CTA emphasis and motion from ExperienceState. Timer
/// arithmetic, timer modes and every start/pause/reset/completion path
/// are the pre-existing engine and stay untouched.
///
/// Coverage: 1-3 architecture, 4-6 Recovery, 7-9 Pressure, 10-12
/// Priority, 13-14 CheckIn, 15 Calm, 16-18 motion/Pulse, 19-22 timer
/// regression.

Widget buildTestableFocus(
  AppStateProvider provider, {
  Size screenSize = const Size(390, 844),
  bool disableAnimations = false,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AppStateProvider>.value(value: provider),
    ],
    child: MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
            size: screenSize, disableAnimations: disableAnimations),
        child: const FocusScreen(),
      ),
    ),
  );
}

/// Injects a canonical Experience state so presentation reactions can be
/// tested deterministically. The rest of the intelligence pipeline stays
/// real; [setExperience] simulates a meaningful state change (Pulse).
class _FakeExperienceProvider extends AppStateProvider {
  _FakeExperienceProvider(this._experience);

  ExperienceState _experience;

  @override
  ExperienceState get currentExperienceState => _experience;

  void setExperience(ExperienceState value) {
    _experience = value;
    notifyListeners();
  }
}

ExperienceState _exp({
  required ExperienceMode mode,
  required ExperienceDominantFocus focus,
  IntelligentActionType? actionType,
  String? targetId,
  int targetTab = 0,
  ExperienceEmphasis emphasis = ExperienceEmphasis.standard,
  ExperienceDensity density = ExperienceDensity.standard,
  ExperienceTone tone = ExperienceTone.neutral,
  List<String> reasons = const <String>['open_task_available'],
}) {
  return ExperienceState(
    mode: mode,
    dominantFocus: focus,
    primaryAction: ExperienceAction(
      actionType: actionType,
      targetId: targetId,
      targetTab: targetTab,
      emphasis: emphasis,
    ),
    informationDensity: density,
    tone: tone,
    reasons: reasons,
  );
}

/// Real canonical setup reaching Priority / primaryTask: checked in,
/// battery 82, two open tasks. N1 ranks 'Tâche Canonical' higher (urgency
/// + difficulty + duration) while the screen's legacy fallback would pick
/// the first 'Haute' — proving canonical target usage when they differ.
AppStateProvider _priorityProvider() {
  final provider = AppStateProvider();
  provider.submitDailyCheckIn(4, 4, 3, 2, 7);
  provider.addTask('Tâche Locale', 'legacy pick', 'Pro',
      priority: 'Haute', urgency: 'Basse', difficulty: 'Facile');
  provider.addTask('Tâche Canonical', 'N1 pick', 'Travail',
      priority: 'Moyenne',
      urgency: 'Haute',
      difficulty: 'Difficile',
      estimatedTime: 75);
  // addTask derives ids from millisecond timestamps; two calls can share
  // a millisecond under the test clock. Guarantee distinct ids so the
  // canonical target comparison is deterministic (production code
  // untouched — this is the pre-existing provider id scheme).
  if (provider.tasks[0]['id'] == provider.tasks[1]['id']) {
    provider.tasks[1]['id'] = '${provider.tasks[1]['id']}_canonical';
  }
  return provider;
}

String _focusSource() => File('lib/screens/focus_screen.dart').readAsStringSync();
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Architecture', () {
    test('1. Focus consumes currentExperienceState', () {
      expect(_focusSource(), contains('state.currentExperienceState'));
    });

    test('2. Focus has zero intelligence-node imports', () {
      final source = _focusSource();
      for (final token in [
        'pulse_node',
        'living_goals_node',
        'understand_node',
        'anticipate_node',
        'PulseNode',
        'LivingGoalsNode',
        'UnderstandNode',
        'AnticipateNode',
        'intelligence/nodes',
      ]) {
        expect(source, isNot(contains(token)), reason: 'forbidden: $token');
      }
    });

    test('3. Focus does not create a second Experience-mode decision', () {
      final source = _focusSource();
      // No mode derivation, no raw risk/battery presentation decisions.
      expect(source, isNot(contains('ExperienceEngine')));
      expect(source, isNot(contains('.derive(')));
      expect(source, isNot(contains('riskFlags')));
      expect(source, isNot(contains('mentalBattery')));
    });

    test('Focus does not calculate its own task priority', () {
      final source = _focusSource();
      // No screen-local scoring, weights or ranking formulas. (The
      // preserved legacy display fallback — first 'Haute', else first
      // open — is existing behavior, not a new ranking system.)
      expect(source, isNot(contains('_taskPriorityScore')));
      expect(source, isNot(contains('priorityMap')));
      expect(source, isNot(contains('urgencyMap')));
      expect(source, isNot(contains('score +=')));
      expect(source, isNot(contains('weightedScore')));
      expect(source, isNot(contains('urgency *')));
      expect(source, isNot(contains('priority *')));
    });
  });

  group('Recovery', () {
    testWidgets('4. Recovery presentation is calm/reduced-density',
        (tester) async {
      final provider = _FakeExperienceProvider(_exp(
        mode: ExperienceMode.recovery,
        focus: ExperienceDominantFocus.recovery,
        actionType: IntelligentActionType.takeBreak,
        targetTab: 2,
        density: ExperienceDensity.minimal,
        tone: ExperienceTone.gentle,
        reasons: const <String>['mental_battery_critical'],
      ));
      addTearDown(provider.dispose);

      await tester.pumpWidget(buildTestableFocus(provider));
      await tester.pumpAndSettle();

      // Soft, grounded supporting copy — no guilt, no pressure.
      expect(find.text('Allez-y doucement.'), findsOneWidget);
      // Secondary controls recede (0.45) but stay present.
      expect(
        find.byWidgetPredicate((w) => w is Opacity && w.opacity == 0.45),
        findsWidgets,
      );
      expect(find.text('Pomodoro (25m)'), findsOneWidget);
      // More breathing room around the timer + slower, softer motion.
      expect(
        tester.widget<AnimatedPadding>(find.byType(AnimatedPadding)).padding,
        const EdgeInsets.symmetric(vertical: NexiiSpacing.lg),
      );
      expect(
        tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher))
            .duration,
        NexiiMotion.slow,
      );
    });

    testWidgets('5. Recovery does not auto-start the timer', (tester) async {
      final provider = _FakeExperienceProvider(_exp(
        mode: ExperienceMode.recovery,
        focus: ExperienceDominantFocus.recovery,
        actionType: IntelligentActionType.takeBreak,
        targetTab: 2,
        density: ExperienceDensity.minimal,
      ));
      addTearDown(provider.dispose);

      await tester.pumpWidget(buildTestableFocus(provider));
      await tester.pumpAndSettle();

      // Timer untouched by intelligence: idle at the default duration.
      expect(find.text('25:00'), findsOneWidget);
      expect(find.text('DÉMARRER'), findsOneWidget);
      expect(find.text('PAUSE'), findsNothing);
    });

    testWidgets('6. Recovery keeps essential timer controls usable',
        (tester) async {
      final provider = _FakeExperienceProvider(_exp(
        mode: ExperienceMode.recovery,
        focus: ExperienceDominantFocus.recovery,
        actionType: IntelligentActionType.takeBreak,
        targetTab: 2,
        density: ExperienceDensity.minimal,
      ));
      addTearDown(provider.dispose);

      await tester.pumpWidget(buildTestableFocus(provider));
      await tester.pumpAndSettle();

      await tester.tap(find.text('DÉMARRER'));
      await tester.pump();
      expect(find.text('PAUSE'), findsOneWidget);
      await tester.tap(find.text('PAUSE'));
      await tester.pump();
      expect(find.text('DÉMARRER'), findsOneWidget);
    });
  });
  group('Pressure', () {
    testWidgets('7. Pressure emphasizes primary timer/action', (tester) async {
      final provider = _FakeExperienceProvider(_exp(
        mode: ExperienceMode.pressure,
        focus: ExperienceDominantFocus.triage,
        actionType: IntelligentActionType.adjustPriority,
        targetTab: 1,
        emphasis: ExperienceEmphasis.elevated,
        density: ExperienceDensity.reduced,
        reasons: const <String>['task_backlog_high'],
      ));
      addTearDown(provider.dispose);

      await tester.pumpWidget(buildTestableFocus(provider));
      await tester.pumpAndSettle();

      expect(find.text('Une chose à la fois.'), findsOneWidget);
      // Timer is the anchor: subtle scale emphasis + tighter framing.
      expect(
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
        1.04,
      );
      expect(
        tester.widget<AnimatedPadding>(find.byType(AnimatedPadding)).padding,
        const EdgeInsets.symmetric(vertical: NexiiSpacing.xs),
      );
      // Primary CTA promoted (emphasis key + stronger elevation).
      final cta = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'DÉMARRER'),
      );
      expect(cta.key, const ValueKey<bool>(true));
      expect(cta.style?.elevation, isNotNull);
    });

    testWidgets('8. Pressure reduces secondary visual emphasis',
        (tester) async {
      final provider = _FakeExperienceProvider(_exp(
        mode: ExperienceMode.pressure,
        focus: ExperienceDominantFocus.triage,
        actionType: IntelligentActionType.adjustPriority,
        targetTab: 1,
        density: ExperienceDensity.reduced,
      ));
      addTearDown(provider.dispose);

      await tester.pumpWidget(buildTestableFocus(provider));
      await tester.pumpAndSettle();

      // Secondary controls recede — but are never hidden.
      expect(
        find.byWidgetPredicate((w) => w is Opacity && w.opacity == 0.55),
        findsWidgets,
      );
      expect(find.text('Pomodoro (25m)'), findsOneWidget);
      expect(find.text('Flow (50m)'), findsOneWidget);
    });

    testWidgets('9. Pressure does not reorder or mutate timer data',
        (tester) async {
      final provider = _FakeExperienceProvider(_exp(
        mode: ExperienceMode.pressure,
        focus: ExperienceDominantFocus.triage,
        actionType: IntelligentActionType.adjustPriority,
        targetTab: 1,
        density: ExperienceDensity.reduced,
      ));
      addTearDown(provider.dispose);

      await tester.pumpWidget(buildTestableFocus(provider));
      await tester.pumpAndSettle();

      // The three existing timer modes and durations are untouched.
      expect(find.text('Pomodoro (25m)'), findsOneWidget);
      expect(find.text('Cohérence (2m)'), findsOneWidget);
      expect(find.text('Flow (50m)'), findsOneWidget);
      expect(find.text('25:00'), findsOneWidget);

      await tester.tap(find.text('Flow (50m)'));
      await tester.pump();
      expect(find.text('50:00'), findsOneWidget);
      await tester.tap(find.text('Pomodoro (25m)'));
      await tester.pump();
      expect(find.text('25:00'), findsOneWidget);
    });
  });

  group('Priority', () {
    testWidgets('10. Priority uses the canonical target when valid',
        (tester) async {
      final provider = _priorityProvider();
      addTearDown(provider.dispose);

      final experience = provider.currentExperienceState;
      expect(experience.mode, ExperienceMode.priority);
      expect(experience.dominantFocus, ExperienceDominantFocus.primaryTask);
      // Canonical target is N1's pick — not the legacy first-'Haute'.
      expect(experience.primaryAction.targetId,
          provider.tasks[1]['id'].toString());

      await tester.pumpWidget(buildTestableFocus(provider));
      await tester.pumpAndSettle();

      expect(find.text('Celle-ci mérite votre focus.'), findsOneWidget);
      expect(find.text('Tâche Canonical'), findsOneWidget);
      expect(find.text('Tâche Locale'), findsNothing);
      // Strongest timer hierarchy.
      expect(
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
        1.05,
      );
    });

    testWidgets('11. Stale canonical target falls back safely',
        (tester) async {
      final provider = _FakeExperienceProvider(_exp(
        mode: ExperienceMode.priority,
        focus: ExperienceDominantFocus.primaryTask,
        actionType: IntelligentActionType.completeTask,
        targetId: 'ghost_task_42',
        density: ExperienceDensity.standard,
      ));
      addTearDown(provider.dispose);

      provider.addTask('Tâche Basse', 'détails', 'Perso', priority: 'Basse');

      await tester.pumpWidget(buildTestableFocus(provider));
      await tester.pumpAndSettle();

      // Existing Focus selection preserved — no crash, no fabricated
      // canonical target, timer untouched.
      expect(find.text('Tâche Basse'), findsOneWidget);
      expect(find.text('25:00'), findsOneWidget);
      expect(find.text('DÉMARRER'), findsOneWidget);
    });

    testWidgets('12. Priority does not auto-start the timer', (tester) async {
      final provider = _priorityProvider();
      addTearDown(provider.dispose);

      await tester.pumpWidget(buildTestableFocus(provider));
      await tester.pumpAndSettle();

      expect(find.text('25:00'), findsOneWidget);
      expect(find.text('DÉMARRER'), findsOneWidget);
      expect(find.text('PAUSE'), findsNothing);
      expect(
        provider.tasks.where((t) => t['isCompleted'] == true),
        isEmpty,
      );
    });
  });
  group('CheckIn', () {
    testWidgets('13. CheckIn uses reduced/gentle presentation',
        (tester) async {
      final provider = AppStateProvider(); // default: not checked in
      addTearDown(provider.dispose);

      final experience = provider.currentExperienceState;
      expect(experience.mode, ExperienceMode.checkIn);
      expect(experience.informationDensity, ExperienceDensity.reduced);

      await tester.pumpWidget(buildTestableFocus(provider));
      await tester.pumpAndSettle();

      expect(find.text('Voyons ce qui convient maintenant.'), findsOneWidget);
      // Slightly lower secondary density (reduced baseline) …
      expect(
        find.byWidgetPredicate((w) => w is Opacity && w.opacity == 0.68),
        findsWidgets,
      );
      // … with a gentle (default) transition.
      expect(
        tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher))
            .duration,
        NexiiMotion.normal,
      );
    });

    testWidgets('14. CheckIn does not alter timer semantics', (tester) async {
      final provider = AppStateProvider();
      addTearDown(provider.dispose);

      await tester.pumpWidget(buildTestableFocus(provider));
      await tester.pumpAndSettle();

      // Existing modes, order and durations untouched.
      expect(find.text('25:00'), findsOneWidget);
      expect(find.text('Pomodoro (25m)'), findsOneWidget);
      expect(find.text('Cohérence (2m)'), findsOneWidget);
      expect(find.text('Flow (50m)'), findsOneWidget);

      await tester.tap(find.text('Cohérence (2m)'));
      await tester.pump();
      expect(find.text('02:00'), findsOneWidget);
      await tester.tap(find.text('Pomodoro (25m)'));
      await tester.pump();
      expect(find.text('25:00'), findsOneWidget);
    });
  });

  group('Calm', () {
    testWidgets('15. Calm preserves normal density and function',
        (tester) async {
      final provider = _FakeExperienceProvider(_exp(
        mode: ExperienceMode.calm,
        focus: ExperienceDominantFocus.calm,
        actionType: IntelligentActionType.startFocus,
        targetTab: 2,
        density: ExperienceDensity.standard,
        tone: ExperienceTone.encouraging,
        reasons: const <String>['no_urgent_work'],
      ));
      addTearDown(provider.dispose);

      await tester.pumpWidget(buildTestableFocus(provider));
      await tester.pumpAndSettle();

      expect(find.text('Vous êtes libre de vous concentrer.'), findsOneWidget);
      // Baseline: nothing is dimmed, nothing recedes.
      expect(
        find.byWidgetPredicate((w) => w is Opacity && w.opacity < 1.0),
        findsNothing,
      );
      // Normal control visibility and function.
      expect(find.text('25:00'), findsOneWidget);
      await tester.tap(find.text('DÉMARRER'));
      await tester.pump();
      expect(find.text('PAUSE'), findsOneWidget);
      await tester.tap(find.text('PAUSE'));
      await tester.pump();
      expect(find.text('DÉMARRER'), findsOneWidget);
    });
  });
  group('Motion', () {
    testWidgets('16. State transition uses the intended animation path',
        (tester) async {
      final provider = _FakeExperienceProvider(_exp(
        mode: ExperienceMode.calm,
        focus: ExperienceDominantFocus.calm,
        actionType: IntelligentActionType.startFocus,
        targetTab: 2,
        density: ExperienceDensity.standard,
      ));
      addTearDown(provider.dispose);

      await tester.pumpWidget(buildTestableFocus(provider));
      await tester.pumpAndSettle();
      expect(
        tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher))
            .duration,
        NexiiMotion.normal,
      );

      // A meaningful state change: calm → recovery.
      provider.setExperience(_exp(
        mode: ExperienceMode.recovery,
        focus: ExperienceDominantFocus.recovery,
        actionType: IntelligentActionType.takeBreak,
        targetTab: 2,
        density: ExperienceDensity.minimal,
        tone: ExperienceTone.gentle,
        reasons: const <String>['mental_battery_critical'],
      ));
      await tester.pump();

      // Single coherent Pulse: cross-fade + small upward settle.
      expect(find.byType(FadeTransition), findsWidgets);
      expect(find.byType(SlideTransition), findsWidgets);

      await tester.pumpAndSettle();
      // Transition completed: old copy fully replaced, nothing lingering.
      expect(find.text('Allez-y doucement.'), findsOneWidget);
      expect(find.text('Vous êtes libre de vous concentrer.'), findsNothing);
      expect(
        tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher))
            .duration,
        NexiiMotion.slow,
      );
    });

    testWidgets('17. Reduced motion disables animation', (tester) async {
      final provider = _FakeExperienceProvider(_exp(
        mode: ExperienceMode.recovery,
        focus: ExperienceDominantFocus.recovery,
        actionType: IntelligentActionType.takeBreak,
        targetTab: 2,
        density: ExperienceDensity.minimal,
      ));
      addTearDown(provider.dispose);

      await tester.pumpWidget(
          buildTestableFocus(provider, disableAnimations: true));
      await tester.pumpAndSettle();

      expect(
        tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher))
            .duration,
        Duration.zero,
      );
      expect(
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).duration,
        Duration.zero,
      );
      expect(
        tester.widget<AnimatedPadding>(find.byType(AnimatedPadding)).duration,
        Duration.zero,
      );
      // Content and controls remain fully available.
      expect(find.text('Allez-y doucement.'), findsOneWidget);
      expect(find.text('DÉMARRER'), findsOneWidget);
    });

    testWidgets('18. Changing mode does not interrupt timer arithmetic',
        (tester) async {
      final provider = _FakeExperienceProvider(_exp(
        mode: ExperienceMode.calm,
        focus: ExperienceDominantFocus.calm,
        actionType: IntelligentActionType.startFocus,
        targetTab: 2,
        density: ExperienceDensity.standard,
      ));
      addTearDown(provider.dispose);

      await tester.pumpWidget(buildTestableFocus(provider));
      await tester.pumpAndSettle();

      await tester.tap(find.text('DÉMARRER'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('24:57'), findsOneWidget);

      // The Experience state changes mid-session (Nexii recognized a new
      // context) — the Pulse transition runs, the countdown continues.
      provider.setExperience(_exp(
        mode: ExperienceMode.recovery,
        focus: ExperienceDominantFocus.recovery,
        actionType: IntelligentActionType.takeBreak,
        targetTab: 2,
        density: ExperienceDensity.minimal,
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('24:55'), findsOneWidget);
      // No auto-pause, no auto-stop: the user stays in control.
      expect(find.text('PAUSE'), findsOneWidget);

      await tester.tap(find.text('PAUSE'));
      await tester.pump();
      expect(find.text('DÉMARRER'), findsOneWidget);
    });
  });
  group('Timer regression', () {
    testWidgets('19. Start works', (tester) async {
      final provider = AppStateProvider();
      addTearDown(provider.dispose);

      await tester.pumpWidget(buildTestableFocus(provider));
      await tester.pumpAndSettle();

      expect(find.text('25:00'), findsOneWidget);
      await tester.tap(find.text('DÉMARRER'));
      await tester.pump();
      expect(find.text('PAUSE'), findsOneWidget);
      await tester.tap(find.text('PAUSE'));
      await tester.pump();
      expect(find.text('DÉMARRER'), findsOneWidget);
    });

    testWidgets('20. Pause/resume works', (tester) async {
      final provider = AppStateProvider();
      addTearDown(provider.dispose);

      await tester.pumpWidget(buildTestableFocus(provider));
      await tester.pumpAndSettle();

      await tester.tap(find.text('DÉMARRER'));
      await tester.pump();
      expect(find.text('PAUSE'), findsOneWidget);

      await tester.tap(find.text('PAUSE'));
      await tester.pump();
      expect(find.text('DÉMARRER'), findsOneWidget);

      await tester.tap(find.text('DÉMARRER'));
      await tester.pump();
      expect(find.text('PAUSE'), findsOneWidget);

      await tester.tap(find.text('PAUSE'));
      await tester.pump();
      expect(find.text('DÉMARRER'), findsOneWidget);
    });

    testWidgets('21. Reset works', (tester) async {
      final provider = AppStateProvider();
      addTearDown(provider.dispose);

      await tester.pumpWidget(buildTestableFocus(provider));
      await tester.pumpAndSettle();

      await tester.tap(find.text('DÉMARRER'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('24:57'), findsOneWidget);

      await tester.tap(find.byTooltip('Réinitialiser'));
      await tester.pump();
      expect(find.text('25:00'), findsOneWidget);
      expect(find.text('DÉMARRER'), findsOneWidget);
    });

    testWidgets('22. Completion behavior remains intact', (tester) async {
      final provider = AppStateProvider();
      addTearDown(provider.dispose);
      final before = provider.focusMinutesTotal;

      await tester.pumpWidget(buildTestableFocus(provider));
      await tester.pumpAndSettle();

      await tester.tap(find.text('DÉMARRER'));
      await tester.pump();

      // Finish early (existing skip control) → timer reaches zero …
      await tester.tap(find.byTooltip('Terminer la session'));
      await tester.pump();
      expect(find.text('00:00'), findsOneWidget);

      // … next tick runs the existing completion path unchanged.
      await tester.pump(const Duration(seconds: 1));
      expect(provider.focusMinutesTotal, before + 25);
      expect(find.textContaining('Session Focus complétée'), findsOneWidget);
      expect(provider.notifications.first['title'], 'Concentration Complétée 🍅');
      // Session stops and resets; nothing keeps running.
      expect(find.text('DÉMARRER'), findsOneWidget);
      expect(find.text('25:00'), findsOneWidget);
    });
  });
}
