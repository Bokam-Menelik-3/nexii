import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nexii/core/theme/app_theme.dart';
import 'package:nexii/experience/models/experience_action.dart';
import 'package:nexii/experience/models/experience_mode.dart';
import 'package:nexii/experience/models/experience_state.dart';
import 'package:nexii/intelligence/models/intelligence_models.dart';
import 'package:nexii/providers/app_state_provider.dart';
import 'package:nexii/screens/home_screen.dart';
import 'package:nexii/screens/tasks_screen.dart';

/// Tasks ↔ Experience integration suite.
///
/// Verifies Tasks consumes the same canonical interpretation as Home:
///
///   Context → Intelligence → ExperienceState → Tasks presentation.
///
/// Tasks never re-ranks: the "Now" task is the canonical task-focused
/// target from ExperienceState (identical to Home's dominant surface),
/// with the screen's pre-existing fallback when there is no task-focused
/// state or the target went stale.
///
/// Coverage: 1 canonical Now, 2 Home/Tasks same target ID, 3 stale target
/// fallback, 4 no task-focused state, 5 Recovery, 6 Pressure, 7 CheckIn,
/// 8 Priority, 9 Calm, 10 canonical reason preferred, 11 CRUD intact.

Widget buildTestableTasksScreen(AppStateProvider provider,
    {Size screenSize = const Size(390, 844)}) {
  return _wrap(provider, const TasksScreen(), screenSize);
}

Widget buildTestableHomeScreen(AppStateProvider provider,
    {Size screenSize = const Size(390, 844)}) {
  return _wrap(provider, const HomeScreen(), screenSize);
}

Widget _wrap(AppStateProvider provider, Widget home, Size screenSize) {
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
            home: home,
          ),
        );
      },
    ),
  );
}
/// Injects a canonical Experience state so screen reactions can be tested
/// deterministically (stale targets, non-task focus, each mode). The rest
/// of the intelligence pipeline stays real.
class _FakeExperienceProvider extends AppStateProvider {
  _FakeExperienceProvider(this._experience);

  final ExperienceState _experience;

  @override
  ExperienceState get currentExperienceState => _experience;
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

/// Real canonical setup that reaches Priority / primaryTask through the
/// real pipeline: checked in, battery 82, two open tasks, no risk flags.
AppStateProvider _canonicalProvider() {
  final provider = AppStateProvider();
  provider.submitDailyCheckIn(4, 4, 3, 2, 7);
  provider.addTask('Présentation Client', 'Slides Q3', 'Travail',
      priority: 'Haute');
  provider.addTask('Notes secondaires', 'À trier', 'Perso',
      priority: 'Basse');
  return provider;
}

/// The task the canonical ExperienceState points at — the exact source
/// Home's dominant surface uses.
String _canonicalTaskTitle(AppStateProvider provider) {
  final targetId = provider.currentExperienceState.primaryAction.targetId;
  final matches =
      provider.tasks.where((t) => t['id']?.toString() == targetId);
  if (matches.isEmpty) {
    fail('canonical target "$targetId" not found among tasks');
  }
  return matches.first['title']?.toString() ?? '';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('1. Canonical Now', () {
    testWidgets('canonical dominant task appears as "Now"', (tester) async {
      final provider = _canonicalProvider();
      addTearDown(provider.dispose);

      final experience = provider.currentExperienceState;
      expect(experience.mode, ExperienceMode.priority);
      expect(experience.dominantFocus, ExperienceDominantFocus.primaryTask);

      await tester.pumpWidget(buildTestableTasksScreen(provider));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('MAINTENANT'), findsOneWidget);
      expect(find.text(_canonicalTaskTitle(provider)), findsOneWidget);
      expect(find.text('Pourquoi maintenant ?'), findsOneWidget);
    });
  });

  group('2. Home and Tasks share one target', () {
    testWidgets('Home and Tasks show the same canonical target task',
        (tester) async {
      final provider = _canonicalProvider();
      addTearDown(provider.dispose);

      final title = _canonicalTaskTitle(provider);
      final reason = provider.currentN1Summary.primaryReason;
      expect(title, isNotEmpty);

      await tester.pumpWidget(buildTestableHomeScreen(provider));
      await tester.pump(const Duration(milliseconds: 100));
      // Home dominant surface shows the canonical task and reason.
      expect(find.text(title), findsOneWidget);
      expect(find.text(reason), findsOneWidget);

      await tester.pumpWidget(buildTestableTasksScreen(provider));
      await tester.pump(const Duration(milliseconds: 100));
      // Tasks Now card shows the identical target and canonical reason.
      expect(find.text(title), findsOneWidget);
      expect(find.text(reason), findsOneWidget);
    });
  });
  group('3. Stale target', () {
    testWidgets('stale canonical target falls back safely', (tester) async {
      final provider = _FakeExperienceProvider(_exp(
        mode: ExperienceMode.priority,
        focus: ExperienceDominantFocus.primaryTask,
        actionType: IntelligentActionType.completeTask,
        targetId: 'ghost_task_42', // points at nothing
        density: ExperienceDensity.standard,
      ));
      addTearDown(provider.dispose);

      provider.addTask('Tâche Basse', 'détails', 'Perso', priority: 'Basse');
      provider.addTask('Tâche Haute', 'détails', 'Pro', priority: 'Haute');

      await tester.pumpWidget(buildTestableTasksScreen(provider));
      await tester.pump(const Duration(milliseconds: 100));

      // Existing fallback behavior: first high-priority task becomes Now,
      // rendered without any crash or invented ranking.
      expect(find.text('MAINTENANT'), findsOneWidget);
      expect(find.text('Tâche Haute'), findsOneWidget);
      expect(find.text('Tâche Basse'), findsOneWidget);
      // The stale target is not presented as a canonical decision.
      expect(find.text(provider.currentN1Summary.primaryReason), findsNothing);
      // Field-based explanation remains for the fallback card.
      expect(find.text('Priorité haute'), findsOneWidget);
      // Task controls stay reachable.
      expect(find.byIcon(Icons.delete_outline), findsWidgets);
      expect(find.byTooltip('Ajouter une tâche'), findsWidgets);
    });
  });

  group('4. No task-focused state', () {
    testWidgets('non task-focused state behaves safely', (tester) async {
      final provider = _FakeExperienceProvider(_exp(
        mode: ExperienceMode.checkIn,
        focus: ExperienceDominantFocus.checkIn,
        actionType: null,
        density: ExperienceDensity.reduced,
        reasons: const <String>['daily_check_in_missing'],
      ));
      addTearDown(provider.dispose);

      provider.addTask('Tâche A', 'détails', 'Pro');
      provider.addTask('Tâche B', 'détails', 'Perso');

      await tester.pumpWidget(buildTestableTasksScreen(provider));
      await tester.pump(const Duration(milliseconds: 100));

      // Existing fallback only — no crash, no reordering invented from
      // missing check-in data. The canonical reason may appear as generic
      // context when the fallback task has no field-based explanation
      // (pre-existing behavior); what matters is that no canonical target
      // is claimed and no task is re-ranked.
      expect(find.text('MAINTENANT'), findsOneWidget);
      expect(find.text('Pourquoi maintenant ?'), findsOneWidget);
      expect(find.text('Tâche A'), findsOneWidget);
      expect(find.text('Tâche B'), findsOneWidget);
      // Task access fully preserved.
      expect(find.text('Terminer'), findsOneWidget);
      expect(find.byTooltip('Ajouter une tâche'), findsWidgets);
    });
  });

  group('5. Recovery', () {
    testWidgets('rest advice, gentler emphasis, tasks stay accessible',
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

      provider.addTask('Tâche essentielle', 'détails', 'Santé',
          priority: 'Haute');

      await tester.pumpWidget(buildTestableTasksScreen(provider));
      await tester.pump(const Duration(milliseconds: 100));

      // Rest advice comes from the canonical mode — not a local battery
      // threshold — and never reads as guilt or shaming.
      expect(
        find.text('Énergie basse : privilégiez des micro-actions ou du repos.'),
        findsOneWidget,
      );
      // Secondary metadata is quieter (0.45) but never removed.
      expect(
        find.byWidgetPredicate((w) => w is Opacity && w.opacity == 0.45),
        findsWidgets,
      );
      // Essential functionality stays available.
      expect(find.text('MAINTENANT'), findsOneWidget);
      expect(find.text('Tâche essentielle'), findsOneWidget);
      expect(find.text('Terminer'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsWidgets);
    });
  });

  group('6. Pressure', () {
    testWidgets('triage clarity: Now leads, competing emphasis recedes',
        (tester) async {
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

      provider.addTask('Tâche Basse', 'détails', 'Perso', priority: 'Basse');
      provider.addTask('Tâche Urgente', 'détails', 'Pro', priority: 'Haute');

      await tester.pumpWidget(buildTestableTasksScreen(provider));
      await tester.pump(const Duration(milliseconds: 100));

      // The Now section leads; competing emphasis recedes (0.55).
      expect(find.text('MAINTENANT'), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is Opacity && w.opacity == 0.55),
        findsWidgets,
      );
      // Existing fallback only — no canonical task claim under triage
      // focus, no new ranking system.
      expect(find.text('Tâche Urgente'), findsOneWidget);
      expect(find.text('Tâche Basse'), findsOneWidget);
      expect(find.text(provider.currentN1Summary.primaryReason), findsNothing);
      expect(find.text('Terminer'), findsOneWidget);
    });
  });
  group('7. CheckIn', () {
    testWidgets('incomplete check-in data causes no arbitrary reordering',
        (tester) async {
      final provider = AppStateProvider(); // default: not checked in
      addTearDown(provider.dispose);
      // Low priority added FIRST: neither recency nor missing check-in
      // data may promote or reorder anything — fallback stays as-is.
      provider.addTask('Tâche Basse', 'détails', 'Perso', priority: 'Basse');
      provider.addTask('Tâche Haute', 'détails', 'Pro', priority: 'Haute');

      final experience = provider.currentExperienceState;
      expect(experience.mode, ExperienceMode.checkIn);
      expect(experience.dominantFocus, ExperienceDominantFocus.checkIn);
      expect(experience.informationDensity, ExperienceDensity.reduced);

      await tester.pumpWidget(buildTestableTasksScreen(provider));
      await tester.pump(const Duration(milliseconds: 100));

      // Existing fallback only — never a canonical claim from missing data.
      expect(find.text('MAINTENANT'), findsOneWidget);
      expect(find.text(provider.currentN1Summary.primaryReason), findsNothing);
      expect(find.text('Tâche Haute'), findsOneWidget);
      expect(find.text('Tâche Basse'), findsOneWidget);
      // Reduced density baseline: quieter metadata (0.68), controls intact.
      expect(
        find.byWidgetPredicate((w) => w is Opacity && w.opacity == 0.68),
        findsWidgets,
      );
      expect(find.byIcon(Icons.delete_outline), findsWidgets);
      expect(find.byTooltip('Ajouter une tâche'), findsWidgets);
    });
  });

  group('8. Priority', () {
    testWidgets('standard task workflow with canonical Now', (tester) async {
      final provider = _canonicalProvider();
      addTearDown(provider.dispose);

      final experience = provider.currentExperienceState;
      expect(experience.mode, ExperienceMode.priority);
      expect(experience.informationDensity, ExperienceDensity.standard);

      await tester.pumpWidget(buildTestableTasksScreen(provider));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(_canonicalTaskTitle(provider)), findsOneWidget);
      expect(find.text('Terminer'), findsOneWidget);
      // Standard density: no metadata is demoted.
      expect(
        find.byWidgetPredicate((w) => w is Opacity && w.opacity < 1.0),
        findsNothing,
      );
      // The canonical primary action targets this task — the UI only
      // offers actions; nothing is auto-completed or auto-started.
      expect(
        experience.primaryAction.actionType,
        IntelligentActionType.completeTask,
      );
      expect(provider.tasks.where((t) => t['isCompleted'] == true), isEmpty);
    });
  });

  group('9. Calm', () {
    testWidgets('normal task workspace without unnecessary urgency',
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

      provider.addTask('Tâche tranquille', 'détails', 'Perso');

      await tester.pumpWidget(buildTestableTasksScreen(provider));
      await tester.pump(const Duration(milliseconds: 100));

      // Full-density workspace, fallback Now, CRUD fully intact.
      expect(
        find.byWidgetPredicate((w) => w is Opacity && w.opacity < 1.0),
        findsNothing,
      );
      expect(find.text('MAINTENANT'), findsOneWidget);
      expect(find.text('Tâche tranquille'), findsOneWidget);
      expect(find.text('Terminer'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsWidgets);
    });
  });
  group('10. Canonical reason preferred', () {
    testWidgets('canonical N1 reason replaces field-based reconstruction',
        (tester) async {
      final provider = _canonicalProvider();
      addTearDown(provider.dispose);

      await tester.pumpWidget(buildTestableTasksScreen(provider));
      await tester.pump(const Duration(milliseconds: 100));

      // The canonical N1 reason is shown verbatim: human, understandable,
      // with no internal scores or implementation terminology.
      expect(find.text(provider.currentN1Summary.primaryReason), findsOneWidget);
      expect(find.textContaining('priorityLevel'), findsNothing);
      expect(find.textContaining('riskScore'), findsNothing);
      // Field-based reconstruction is not used when canonical explains it.
      expect(find.textContaining('Priorité haute'), findsNothing);
      expect(find.textContaining('Urgence immédiate'), findsNothing);
    });
  });

  group('11. CRUD intact', () {
    testWidgets('create, complete and delete still work end to end',
        (tester) async {
      final provider = AppStateProvider();
      addTearDown(provider.dispose);
      provider.addTask('Tâche existante', 'détails', 'Test');

      await tester.pumpWidget(buildTestableTasksScreen(provider));
      await tester.pump(const Duration(milliseconds: 100));

      // Create: open the add dialog and submit a new task.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Tâche créée');
      await tester.tap(find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(ElevatedButton),
      ));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Tâche créée'), findsOneWidget);

      // Complete: the Now card's Terminer button. The dialog defaults to
      // 'Haute' priority, so the freshly created task becomes the
      // fallback Now — completion targets whatever the Now card shows.
      await tester.tap(find.text('Terminer'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('TERMINÉES'), findsOneWidget);

      // Let the completion snackbar and confetti finish so the remaining
      // open task's controls are interactable.
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 100));

      // Delete the remaining open task via the Now card control (first
      // in tree order — the completed tile sits under the FAB in this
      // test viewport and must not be the tap target).
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Tâche existante'), findsNothing);
      expect(find.text('Tâche créée'), findsOneWidget);
    });
  });
}
