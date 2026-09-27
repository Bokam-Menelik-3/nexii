import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nexii/intelligence/models/intelligence_models.dart';
import 'package:nexii/intelligence/nodes/anticipate_node.dart';
import 'package:nexii/intelligence/nodes/aura_node.dart';
import 'package:nexii/intelligence/nodes/living_goals_node.dart';
import 'package:nexii/intelligence/nodes/measure_node.dart';
import 'package:nexii/intelligence/nodes/observe_node.dart';
import 'package:nexii/intelligence/nodes/pulse_node.dart';
import 'package:nexii/intelligence/nodes/recommend_node.dart';
import 'package:nexii/intelligence/nodes/understand_node.dart';
import 'package:nexii/intelligence/services/intelligence_service.dart';
import 'package:nexii/main.dart';
import 'package:nexii/providers/app_state_provider.dart';

void main() {
  test('AppStateProvider starts with a neutral empty user state', () {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    expect(provider.profileName, isEmpty);
    expect(provider.profileBirthdate, isEmpty);
    expect(provider.profileAge, 0);
    expect(provider.focusMinutesTotal, 0);
    expect(provider.tasks, isEmpty);
    expect(provider.missions, isEmpty);
    expect(provider.goals, isEmpty);
    expect(provider.livingGoals, isEmpty);
    expect(provider.agendaEvents, isEmpty);
  });

  test('logout clears user-specific state back to a blank state', () {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    provider.completeOnboarding('Alice', '2000-05-15');
    provider.addFocusMinutes(30);
    provider.addTask('Rédiger le rapport', 'Résumé', 'Pro');
    provider.addGoal('Terminer le projet', 'Pro');
    provider.addAgendaEvent('Réunion', '09:00');

    provider.logout();

    expect(provider.profileName, isEmpty);
    expect(provider.profileBirthdate, isEmpty);
    expect(provider.profileAge, 0);
    expect(provider.focusMinutesTotal, 0);
    expect(provider.tasks, isEmpty);
    expect(provider.goals, isEmpty);
    expect(provider.livingGoals, isEmpty);
    expect(provider.agendaEvents, isEmpty);
  });

  test('toggleMissionCompleted toggles completion status and updates progress', () {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    provider.addMission('Mission Test', 'Description', 50);
    expect(provider.missions.length, 1);
    final missionId = provider.missions.first['id'].toString();
    expect(provider.missions.first['isCompleted'], isNot(true));

    // Complete mission
    provider.toggleMissionCompleted(missionId);
    expect(provider.missions.first['isCompleted'], true);
    expect(provider.missions.first['progress'], 1.0);

    // Uncomplete mission
    provider.toggleMissionCompleted(missionId);
    expect(provider.missions.first['isCompleted'], false);
    expect(provider.missions.first['progress'], 0.0);
  });

  testWidgets('App launches successfully', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: provider),
        ],
        child: const NexiiApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  test(
      'ObserveNode reads a real ContextSnapshot and reports factual observations',
      () {
    final snapshot = ContextSnapshot(
      userId: 'u-1',
      displayName: 'Test User',
      age: 30,
      locale: 'fr',
      onboardingComplete: true,
      tasks: const [
        TaskSummary(
            id: 't1',
            title: 'Tâche A',
            isCompleted: false,
            priority: 'Haute',
            urgency: 'Haute',
            difficulty: 'Moyen',
            estimatedTimeMinutes: 45,
            energyNeeded: 'Haute',
            category: 'Pro'),
        TaskSummary(
            id: 't2',
            title: 'Tâche B',
            isCompleted: true,
            priority: 'Moyenne',
            urgency: 'Basse',
            difficulty: 'Facile',
            estimatedTimeMinutes: 20,
            energyNeeded: 'Basse',
            category: 'Zen'),
        TaskSummary(
            id: 't3',
            title: 'Tâche C',
            isCompleted: false,
            priority: 'Moyenne',
            urgency: 'Moyenne',
            difficulty: 'Moyen',
            estimatedTimeMinutes: 30,
            energyNeeded: 'Moyenne',
            category: 'Finance'),
      ],
      openTasks: const [
        TaskSummary(
            id: 't1',
            title: 'Tâche A',
            isCompleted: false,
            priority: 'Haute',
            urgency: 'Haute',
            difficulty: 'Moyen',
            estimatedTimeMinutes: 45,
            energyNeeded: 'Haute',
            category: 'Pro'),
        TaskSummary(
            id: 't3',
            title: 'Tâche C',
            isCompleted: false,
            priority: 'Moyenne',
            urgency: 'Moyenne',
            difficulty: 'Moyen',
            estimatedTimeMinutes: 30,
            energyNeeded: 'Moyenne',
            category: 'Finance'),
      ],
      agendaEvents: const [
        AgendaEventSummary(
            id: 'a1',
            title: 'Réunion',
            time: '14:00',
            startMinutesFromNow: 120,
            durationMinutes: 60,
            importance: 'Haute',
            kind: 'meeting'),
      ],
      upcomingEvents: const [
        AgendaEventSummary(
            id: 'a1',
            title: 'Réunion',
            time: '14:00',
            startMinutesFromNow: 120,
            durationMinutes: 60,
            importance: 'Haute',
            kind: 'meeting'),
      ],
      goals: const [
        GoalSummary(
            id: 'g1', title: 'Objectif majeur', progress: 0.65, category: 'Pro')
      ],
      missions: const [
        MissionSummary(
            id: 'm1',
            title: 'Mission 1',
            progress: 0.5,
            isCompleted: false,
            xp: 100,
            claimed: false)
      ],
      focusMinutesTotal: 45,
      mentalBattery: 72,
      currentMood: 'Bien',
      dailyEnergy: 80,
      dailyMotivation: 76,
      dailyStress: 34,
      dailySleep: 7,
      xp: 420,
      level: 4,
      streak: 5,
      auraScore: 81,
      now: DateTime(2026, 9, 4, 10, 0),
      generatedAt: DateTime(2026, 9, 4, 10, 0),
    );

    final result = ObserveNode().execute(snapshot);

    expect(result.nodeId, 'observe');
    expect(result.observations, isNotEmpty);
    expect(result.observations.any((o) => o.contains('2 tâches ouvertes')),
        isTrue);
    expect(result.observations.any((o) => o.contains('1 événement')), isTrue);
    expect(result.observations.any((o) => o.contains('45 minutes de focus')),
        isTrue);
    expect(result.observations.any((o) => o.contains('72')), isTrue);
    expect(result.actions, isEmpty);
    expect(result.recommendations, isEmpty);
  });

  test('ObserveNode handles a minimal empty snapshot honestly', () {
    final snapshot = ContextSnapshot(
      now: DateTime(2026, 9, 4, 10, 0),
      generatedAt: DateTime(2026, 9, 4, 10, 0),
    );

    final result = ObserveNode().execute(snapshot);

    expect(result.nodeId, 'observe');
    expect(result.observations, isNotEmpty);
    expect(result.observations.any((o) => o.contains('aucune tâche')), isTrue);
    expect(
        result.observations.any((o) => o.contains('aucun événement')), isTrue);
    expect(result.actions, isEmpty);
  });

  test('UnderstandNode interprets real workload into structured meaning', () {
    final snapshot = ContextSnapshot(
      userId: 'u-1',
      displayName: 'Test User',
      tasks: const [
        TaskSummary(
            id: 't1', title: 'A', isCompleted: false, priority: 'Haute'),
        TaskSummary(
            id: 't2', title: 'B', isCompleted: false, priority: 'Haute'),
        TaskSummary(
            id: 't3', title: 'C', isCompleted: false, priority: 'Moyenne'),
      ],
      openTasks: const [
        TaskSummary(
            id: 't1', title: 'A', isCompleted: false, priority: 'Haute'),
        TaskSummary(
            id: 't2', title: 'B', isCompleted: false, priority: 'Haute'),
      ],
      focusMinutesTotal: 20,
      mentalBattery: 35,
      currentMood: 'Stressé',
      dailyStress: 74,
      dailySleep: 5,
      now: DateTime(2026, 9, 4, 10, 0),
      generatedAt: DateTime(2026, 9, 4, 10, 0),
    );

    final result = UnderstandNode().execute(snapshot);

    expect(result.nodeId, 'understand');
    expect(result.observations, isNotEmpty);
    expect(
        result.observations.any((o) =>
            o.contains('charge de travail') ||
            o.contains('baisse d\'activité') ||
            o.contains('état stable')),
        isTrue);
    expect(result.actions, isEmpty);
  });

  test('PulseNode summarizes current state without inventing data', () {
    final snapshot = ContextSnapshot(
      userId: 'u-1',
      displayName: 'Test User',
      mentalBattery: 68,
      focusMinutesTotal: 80,
      currentMood: 'Bien',
      dailyEnergy: 82,
      dailyMotivation: 74,
      dailyStress: 30,
      dailySleep: 7,
      now: DateTime(2026, 9, 4, 10, 0),
      generatedAt: DateTime(2026, 9, 4, 10, 0),
    );

    final result = PulseNode().execute(snapshot);

    expect(result.nodeId, 'pulse');
    expect(result.observations, isNotEmpty);
    expect(
        result.observations
            .any((o) => o.contains('batterie') || o.contains('énergie')),
        isTrue);
    expect(result.metadata['pulseState'], isNotNull);
    expect(result.actions, isEmpty);
  });

  test('AuraNode consumes real aura score and reflects it honestly', () {
    final snapshot = ContextSnapshot(
      userId: 'u-1',
      displayName: 'Test User',
      auraScore: 81,
      mentalBattery: 72,
      now: DateTime(2026, 9, 4, 10, 0),
      generatedAt: DateTime(2026, 9, 4, 10, 0),
    );

    final result = AuraNode().execute(snapshot);

    expect(result.nodeId, 'aura');
    expect(result.observations, isNotEmpty);
    expect(
        result.observations.any((o) =>
            o.contains('81') || o.contains('Aura') || o.contains('équilibre')),
        isTrue);
    expect(result.metadata['auraScore'], 81);
    expect(result.actions, isEmpty);
  });

  test('LivingGoalsNode uses real goal progress and mission context', () {
    final snapshot = ContextSnapshot(
      userId: 'u-1',
      displayName: 'Test User',
      goals: const [
        GoalSummary(
            id: 'g1',
            title: 'Objectif principal',
            progress: 0.72,
            category: 'Pro'),
        GoalSummary(
            id: 'g2',
            title: 'Objectif secondaire',
            progress: 0.41,
            category: 'Zen'),
      ],
      missions: const [
        MissionSummary(
            id: 'm1',
            title: 'Mission 1',
            progress: 0.5,
            isCompleted: false,
            xp: 100,
            claimed: false),
      ],
      now: DateTime(2026, 9, 4, 10, 0),
      generatedAt: DateTime(2026, 9, 4, 10, 0),
    );

    final result = LivingGoalsNode().execute(snapshot);

    expect(result.nodeId, 'living_goals');
    expect(result.observations.any((o) => o.contains('objectif principal')),
        isTrue);
    expect(result.metadata['goalCount'], 2);
    expect(result.actions, isEmpty);
  });

  test('AnticipateNode flags real risk only when indicators are present', () {
    final riskySnapshot = ContextSnapshot(
      userId: 'u-1',
      displayName: 'Test User',
      openTasks: const [
        TaskSummary(id: 't1', title: 'A', isCompleted: false),
        TaskSummary(id: 't2', title: 'B', isCompleted: false),
        TaskSummary(id: 't3', title: 'C', isCompleted: false),
      ],
      mentalBattery: 35,
      dailyStress: 72,
      focusMinutesTotal: 20,
      goals: const [
        GoalSummary(
            id: 'g1',
            title: 'Objectif principal',
            progress: 0.3,
            category: 'Pro')
      ],
      now: DateTime(2026, 9, 4, 10, 0),
      generatedAt: DateTime(2026, 9, 4, 10, 0),
    );

    final result = AnticipateNode().execute(riskySnapshot);
    expect(result.status, IntelligenceStatus.warning);
    expect(result.riskFlags, contains('anticipation_risk'));

    final stableSnapshot = ContextSnapshot(
      userId: 'u-1',
      displayName: 'Test User',
      openTasks: const [TaskSummary(id: 't1', title: 'A', isCompleted: false)],
      mentalBattery: 75,
      dailyStress: 20,
      focusMinutesTotal: 60,
      goals: const [
        GoalSummary(
            id: 'g1',
            title: 'Objectif principal',
            progress: 0.7,
            category: 'Pro')
      ],
      now: DateTime(2026, 9, 4, 10, 0),
      generatedAt: DateTime(2026, 9, 4, 10, 0),
    );

    final stableResult = AnticipateNode().execute(stableSnapshot);
    expect(stableResult.status, IntelligenceStatus.ok);
    expect(stableResult.riskFlags, isEmpty);
  });

  test('RecommendNode picks a real task when there is a pertinent action', () {
    final snapshot = ContextSnapshot(
      userId: 'u-1',
      displayName: 'Test User',
      openTasks: const [
        TaskSummary(
          id: 't1',
          title: 'Tâche A',
          isCompleted: false,
          priority: 'Haute',
          urgency: 'Haute',
          difficulty: 'Moyen',
          estimatedTimeMinutes: 60,
        ),
        TaskSummary(
          id: 't2',
          title: 'Tâche B',
          isCompleted: false,
          priority: 'Moyenne',
          urgency: 'Basse',
          difficulty: 'Facile',
          estimatedTimeMinutes: 15,
        ),
      ],
      mentalBattery: 70,
      focusMinutesTotal: 50,
      now: DateTime(2026, 9, 4, 10, 0),
      generatedAt: DateTime(2026, 9, 4, 10, 0),
    );

    final result = RecommendNode().execute(snapshot);

    expect(result.nodeId, 'recommend');
    expect(result.actions, isNotEmpty);
    expect(result.actions.first.targetId, 't1');
  });

  test('RecommendNode avoids false recommendations when no action is pertinent',
      () {
    final snapshot = ContextSnapshot(
      userId: 'u-1',
      displayName: 'Test User',
      openTasks: const [],
      mentalBattery: 88,
      now: DateTime(2026, 9, 4, 10, 0),
      generatedAt: DateTime(2026, 9, 4, 10, 0),
    );

    final result = RecommendNode().execute(snapshot);

    expect(result.nodeId, 'recommend');
    expect(result.actions, isEmpty);
    expect(result.observations.any((o) => o.contains('aucune action')), isTrue);
  });

  test('MeasureNode returns real measurements without inventing history', () {
    final snapshot = ContextSnapshot(
      userId: 'u-1',
      displayName: 'Test User',
      tasks: const [
        TaskSummary(id: 't1', title: 'A', isCompleted: true),
        TaskSummary(id: 't2', title: 'B', isCompleted: false),
      ],
      openTasks: const [TaskSummary(id: 't2', title: 'B', isCompleted: false)],
      goals: const [
        GoalSummary(id: 'g1', title: 'Objectif', progress: 0.6, category: 'Pro')
      ],
      missions: const [
        MissionSummary(
            id: 'm1',
            title: 'Mission',
            progress: 0.5,
            isCompleted: false,
            xp: 50,
            claimed: false)
      ],
      xp: 300,
      streak: 6,
      auraScore: 82,
      focusMinutesTotal: 70,
      now: DateTime(2026, 9, 4, 10, 0),
      generatedAt: DateTime(2026, 9, 4, 10, 0),
    );

    final result = MeasureNode().execute(snapshot);

    expect(result.nodeId, 'measure');
    expect(result.observations.any((o) => o.contains('tâches complétées')),
        isTrue);
    expect(result.metadata['xp'], 300);
  });

  test('N1 consumes the intelligence results and produces a real summary', () {
    final snapshot = ContextSnapshot(
      userId: 'u-1',
      displayName: 'Test User',
      openTasks: const [
        TaskSummary(
          id: 't1',
          title: 'Tâche A',
          isCompleted: false,
          priority: 'Haute',
          urgency: 'Haute',
          difficulty: 'Moyen',
          estimatedTimeMinutes: 60,
        ),
      ],
      mentalBattery: 52,
      focusMinutesTotal: 25,
      agendaEvents: const [
        AgendaEventSummary(
          id: 'a1',
          title: 'Réunion',
          time: '14:00',
          durationMinutes: 60,
          importance: 'Haute',
        )
      ],
      now: DateTime(2026, 9, 4, 10, 0),
      generatedAt: DateTime(2026, 9, 4, 10, 0),
    );

    final summary = IntelligenceService().evaluateN1(snapshot);

    expect(summary.summaryId, isNotEmpty);
    expect(summary.primaryActionId, isNotNull);
    expect(summary.primaryAction, isNotNull);
    expect(summary.recommendations, isNotEmpty);
  });

  test(
      'IntelligenceService exposes LivingGoals, Anticipate, Recommend and Measure nodes',
      () {
    final service = IntelligenceService();
    final snapshot = ContextSnapshot(
      userId: 'u-1',
      displayName: 'Test User',
      goals: const [
        GoalSummary(
            id: 'g1',
            title: 'Objectif principal',
            progress: 0.62,
            category: 'Pro')
      ],
      missions: const [
        MissionSummary(
            id: 'm1',
            title: 'Mission 1',
            progress: 0.5,
            isCompleted: false,
            xp: 100,
            claimed: false)
      ],
      openTasks: const [TaskSummary(id: 't1', title: 'A', isCompleted: false)],
      mentalBattery: 60,
      dailyStress: 35,
      focusMinutesTotal: 50,
      now: DateTime(2026, 9, 4, 10, 0),
      generatedAt: DateTime(2026, 9, 4, 10, 0),
    );

    final livingGoalsResult = service.runLivingGoals(snapshot);
    final anticipateResult = service.runAnticipate(snapshot);
    final recommendResult = service.runRecommend(snapshot);
    final measureResult = service.runMeasure(snapshot);

    expect(livingGoalsResult.nodeId, 'living_goals');
    expect(anticipateResult.nodeId, 'anticipate');
    expect(recommendResult.nodeId, 'recommend');
    expect(measureResult.nodeId, 'measure');
  });

  test(
      'AppStateProvider exposes an empty real ContextSnapshot for a blank user',
      () async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    final snapshot = provider.currentContextSnapshot;
    final n1Summary = provider.currentN1Summary;

    expect(snapshot.tasks, isEmpty);
    expect(snapshot.openTasks, isEmpty);
    expect(snapshot.source, 'AppStateProvider');
    expect(n1Summary.summaryId, isNotEmpty);
    expect(n1Summary.primaryReason, isNotEmpty);
    expect(n1Summary.primaryActionId, isNull);
  });
}
