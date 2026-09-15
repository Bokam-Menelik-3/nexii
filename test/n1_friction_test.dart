import 'package:flutter_test/flutter_test.dart';
import 'package:nexii/intelligence/models/intelligence_models.dart';
import 'package:nexii/intelligence/services/intelligence_service.dart';
import 'package:nexii/providers/app_state_provider.dart';

void main() {
  final service = IntelligenceService();

  group('N1 Decision Engine - Situation → Friction → Adaptation', () {
    test('Scenario A: Normal situation produces NO_FRICTION / NO_ACTION', () {
      final snapshot = ContextSnapshot(
        userId: 'u1',
        mentalBattery: 82,
        dailyEnergy: 4,
        dailyStress: 2,
        openTasks: const [
          TaskSummary(
            id: 't1',
            title: 'Tâche normale',
            isCompleted: false,
            priority: 'Moyenne',
            difficulty: 'Moyen',
            estimatedTimeMinutes: 30,
          ),
        ],
        now: DateTime(2026, 7, 24, 10, 0),
        generatedAt: DateTime(2026, 7, 24, 10, 0),
      );

      final summary = service.evaluateN1(snapshot);

      expect(summary.contextTags.contains('NO_FRICTION'), isTrue);
      expect(summary.primaryAction, isNotNull);
      expect(summary.primaryAction!.actionType, IntelligentActionType.startTask);
      expect(summary.primaryAction!.targetId, 't1');
    });

    test('Scenario B: Time constraint produces TIME_FRICTION', () {
      final snapshot = ContextSnapshot(
        userId: 'u1',
        mentalBattery: 80,
        dailyEnergy: 4,
        openTasks: const [
          TaskSummary(
            id: 't1',
            title: 'Gros projet',
            isCompleted: false,
            priority: 'Haute',
            difficulty: 'Haut',
            estimatedTimeMinutes: 90,
          ),
        ],
        upcomingEvents: const [
          AgendaEventSummary(
            id: 'a1',
            title: 'Réunion',
            time: '10:30',
            startMinutesFromNow: 30,
          ),
        ],
        now: DateTime(2026, 7, 24, 10, 0),
        generatedAt: DateTime(2026, 7, 24, 10, 0),
      );

      final summary = service.evaluateN1(snapshot);

      expect(summary.contextTags.contains('TIME_FRICTION'), isTrue);
      expect(summary.riskFlags.contains('time_friction_detected'), isTrue);
      expect(summary.primaryReason, contains('Evidence: taskEstimatedTime=90m'));
      expect(summary.primaryAction, isNotNull);
      expect(summary.primaryAction!.actionType, IntelligentActionType.proposeMicroTask);
      expect(summary.primaryAction!.targetId, 'applyPulseAction');
    });

    test('Scenario C: Low energy produces CAPACITY_FRICTION', () {
      final snapshot = ContextSnapshot(
        userId: 'u1',
        mentalBattery: 34,
        dailyEnergy: 2,
        dailyStress: 3,
        openTasks: const [
          TaskSummary(
            id: 't1',
            title: 'Examen complexe',
            isCompleted: false,
            priority: 'Haute',
            difficulty: 'Difficile',
            estimatedTimeMinutes: 60,
          ),
        ],
        now: DateTime(2026, 7, 24, 10, 0),
        generatedAt: DateTime(2026, 7, 24, 10, 0),
      );

      final summary = service.evaluateN1(snapshot);

      expect(summary.contextTags.contains('CAPACITY_FRICTION'), isTrue);
      expect(summary.riskFlags.contains('capacity_friction_detected'), isTrue);
      expect(summary.recommendations.any((r) => r.contains('Mode Récupération')), isTrue);
      expect(summary.primaryAction, isNotNull);
      expect(summary.primaryAction!.actionType, IntelligentActionType.takeBreak);
      expect(summary.primaryAction!.targetId, 'toggleRecoveryMode');
    });

    test('Scenario D: Overload produces OVERLOAD_FRICTION', () {
      final snapshot = ContextSnapshot(
        userId: 'u1',
        mentalBattery: 30,
        dailyStress: 4,
        openTasks: List.generate(
          7,
          (index) => TaskSummary(
            id: 't$index',
            title: 'Tâche $index',
            isCompleted: false,
          ),
        ),
        now: DateTime(2026, 7, 24, 10, 0),
        generatedAt: DateTime(2026, 7, 24, 10, 0),
      );

      final summary = service.evaluateN1(snapshot);

      expect(summary.contextTags.contains('OVERLOAD_FRICTION'), isTrue);
      expect(summary.riskFlags.contains('overload_friction_detected'), isTrue);
      expect(summary.recommendations.any((r) => r.contains('Surcharge détectée')), isTrue);
      expect(summary.primaryAction, isNotNull);
      expect(summary.primaryAction!.actionType, IntelligentActionType.reduceTaskScope);
      expect(summary.primaryAction!.targetId, 'toggleCrisisMode');
    });

    test('Scenario E: Difficult task without subtasks produces CLARITY_FRICTION', () {
      final snapshot = ContextSnapshot(
        userId: 'u1',
        mentalBattery: 75,
        openTasks: const [
          TaskSummary(
            id: 't1',
            title: 'Rédiger thèse',
            isCompleted: false,
            priority: 'Haute',
            difficulty: 'Difficile',
            estimatedTimeMinutes: 120,
            subtaskCount: 0,
          ),
        ],
        now: DateTime(2026, 7, 24, 10, 0),
        generatedAt: DateTime(2026, 7, 24, 10, 0),
      );

      final summary = service.evaluateN1(snapshot);

      expect(summary.contextTags.contains('CLARITY_FRICTION'), isTrue);
      expect(summary.riskFlags.contains('clarity_friction_detected'), isTrue);
      expect(summary.recommendations.any((r) => r.contains('micro-actions')), isTrue);
      expect(summary.primaryAction, isNotNull);
      expect(summary.primaryAction!.actionType, IntelligentActionType.proposeMicroTask);
      expect(summary.primaryAction!.targetId, 't1');
    });

    test('Scenario F: Insufficient context produces insufficient_context without fabricated actions', () {
      final snapshot = ContextSnapshot(
        userId: null,
        mentalBattery: 0,
        hasCheckedInToday: false,
        openTasks: const [],
        goals: const [],
        missions: const [],
        now: DateTime(2026, 7, 24, 10, 0),
        generatedAt: DateTime(2026, 7, 24, 10, 0),
      );

      final summary = service.evaluateN1(snapshot);

      expect(summary.contextTags.contains('insufficient_context'), isTrue);
      expect(summary.primaryAction, isNull);
      expect(summary.primaryReason, contains('Données insuffisantes pour établir une friction'));
    });

    test('Dynamism Test: N1Summary adapts when task status changes', () {
      TestWidgetsFlutterBinding.ensureInitialized();
      final provider = AppStateProvider();
      addTearDown(provider.dispose);

      provider.addTask('Tâche 1', 'Sub', 'Cat', estimatedTime: 60, difficulty: 'Difficile');

      final snapshot1 = provider.currentContextSnapshot;
      final summary1 = provider.currentN1Summary;

      expect(snapshot1.openTasks.length, 1);
      expect(summary1.primaryActionId, isNotNull);

      // Complete the task
      final taskId = snapshot1.openTasks.first.id;
      provider.toggleTask(taskId);

      final snapshot2 = provider.currentContextSnapshot;
      final summary2 = provider.currentN1Summary;

      expect(snapshot2.openTasks.length, 0);
      expect(summary2.primaryActionId, isNull);
      expect(summary1.primaryActionId, isNot(equals(summary2.primaryActionId)));
    });

    test('Read-only Integrity Test: Intelligence execution does not mutate snapshot data', () {
      final snapshot = ContextSnapshot(
        userId: 'u1',
        mentalBattery: 32,
        dailyEnergy: 2,
        openTasks: const [
          TaskSummary(
            id: 't1',
            title: 'Tâche A',
            isCompleted: false,
            difficulty: 'Difficile',
            estimatedTimeMinutes: 60,
          ),
        ],
        now: DateTime(2026, 7, 24, 10, 0),
        generatedAt: DateTime(2026, 7, 24, 10, 0),
      );

      final batteryBefore = snapshot.mentalBattery;
      final taskCountBefore = snapshot.openTasks.length;

      final summary = service.evaluateN1(snapshot);

      expect(summary, isNotNull);
      expect(snapshot.mentalBattery, equals(batteryBefore));
      expect(snapshot.openTasks.length, equals(taskCountBefore));
    });

    test('Runtime Path Proof: AppStateProvider -> ContextSnapshotBuilder -> ContextSnapshot -> IntelligenceService -> N1DecisionEngine -> N1Summary', () {
      TestWidgetsFlutterBinding.ensureInitialized();
      final provider = AppStateProvider();
      addTearDown(provider.dispose);

      provider.addTask('Tâche de test', 'Sous-titre', 'Catégorie');
      final snapshot = provider.currentContextSnapshot;
      final n1Summary = provider.currentN1Summary;

      expect(snapshot.source, 'AppStateProvider');
      expect(snapshot.openTasks.isNotEmpty, isTrue);
      expect(n1Summary.summaryId, startsWith('n1_'));
      expect(n1Summary.generatedAt, isNotNull);
      expect(n1Summary.currentStateSummary, contains('1 tâches ouvertes'));
    });
  });
}
