import 'package:flutter_test/flutter_test.dart';
import 'package:nexii/intelligence/models/intelligence_models.dart';
import 'package:nexii/intelligence/services/intelligence_service.dart';

void main() {
  group('Generation 4/4 - Personal Learning Loop Tests', () {
    late IntelligenceService service;

    setUp(() {
      service = IntelligenceService();
    });

    ContextSnapshot createSnapshot({
      bool hasCheckedInToday = true,
      int mentalBattery = 80,
      int openTaskCount = 3,
    }) {
      final now = DateTime(2025, 3, 10, 10, 0);
      final tasks = List.generate(
        openTaskCount,
        (i) => {
          'id': 'task_$i',
          'title': 'Task $i',
          'status': 'open',
          'completed': false,
          'estimatedMinutes': 15,
        },
      );

      return service.buildSnapshot(
        userId: 'u1',
        displayName: 'Test',
        age: 25,
        isAnonymous: false,
        locale: 'en',
        onboardingComplete: true,
        tasks: tasks,
        agendaEvents: [],
        goals: [],
        missions: [],
        xp: 100,
        level: 2,
        streak: 3,
        disciplineScore: 80,
        auraScore: 80,
        currentMood: 'good',
        dailyMood: 4,
        dailyEnergy: 4,
        dailyMotivation: 4,
        dailyStress: 2,
        dailySleep: 8,
        hasCheckedInToday: hasCheckedInToday,
        mentalBattery: mentalBattery,
        focusMinutesTotal: 60,
        totalBudget: 100,
        remainingBudget: 50,
        now: now,
      );
    }

    test('TEST 1: No learning history returns empty PersonalLearningContext', () {
      final snapshot = createSnapshot();
      final context = service.buildLearningContext(snapshot);

      expect(context.learnings, isEmpty);
      expect(context, equals(PersonalLearningContext.empty));
    });

    test('TEST 2: First observation builds initial knowledge with limited confidence', () {
      final event = LearningEvent(
        eventId: 'evt_1',
        timestamp: DateTime.now(),
        actionId: 'action_start_task',
        actionType: 'startTask',
        capacityLevel: 'high',
        workloadLevel: 'medium',
        frictionType: 'NO_FRICTION',
        outcome: OutcomeType.completed,
      );

      service.recordLearningEvent(event);
      final snapshot = createSnapshot(mentalBattery: 80);
      final learningContext = service.buildLearningContext(snapshot);

      expect(learningContext.learnings.length, equals(1));
      final knowledge = learningContext.learnings.first;
      expect(knowledge.totalAttempts, equals(1));
      expect(knowledge.positiveOutcomes, equals(1));
      expect(knowledge.confidence, lessThan(0.3)); // Requires >= 3 events for high confidence
    });

    test('TEST 3: Repeated successes increase knowledge confidence', () {
      final now = DateTime.now();
      for (int i = 0; i < 5; i++) {
        service.recordLearningEvent(LearningEvent(
          eventId: 'evt_$i',
          timestamp: now.add(Duration(minutes: i)),
          actionId: 'action_start_task',
          actionType: 'startTask',
          capacityLevel: 'high',
          workloadLevel: 'medium',
          frictionType: 'NO_FRICTION',
          outcome: OutcomeType.completed,
        ));
      }

      final snapshot = createSnapshot(mentalBattery: 80);
      final learningContext = service.buildLearningContext(snapshot);

      expect(learningContext.learnings.length, equals(1));
      final knowledge = learningContext.learnings.first;
      expect(knowledge.totalAttempts, equals(5));
      expect(knowledge.confidence, greaterThanOrEqualTo(0.8));
      expect(knowledge.effectivenessScore, equals(1.0));
    });

    test('TEST 4: Contradictory outcomes lower effectiveness without exploding confidence', () {
      final now = DateTime.now();
      // 2 successes, 2 abandoned
      final outcomes = [
        OutcomeType.completed,
        OutcomeType.completed,
        OutcomeType.abandoned,
        OutcomeType.abandoned,
      ];

      for (int i = 0; i < outcomes.length; i++) {
        service.recordLearningEvent(LearningEvent(
          eventId: 'evt_$i',
          timestamp: now.add(Duration(minutes: i)),
          actionId: 'action_start_task',
          actionType: 'startTask',
          capacityLevel: 'high',
          workloadLevel: 'medium',
          frictionType: 'NO_FRICTION',
          outcome: outcomes[i],
        ));
      }

      final snapshot = createSnapshot(mentalBattery: 80);
      final learningContext = service.buildLearningContext(snapshot);

      final knowledge = learningContext.learnings.first;
      expect(knowledge.effectivenessScore, equals(0.5));
      expect(knowledge.confidence, lessThanOrEqualTo(0.95));
    });

    test('TEST 5: Context differentiation prevents cross-context pattern blending', () {
      final now = DateTime.now();
      // Event in High capacity
      service.recordLearningEvent(LearningEvent(
        eventId: 'evt_high',
        timestamp: now,
        actionId: 'action_focus',
        actionType: 'startFocus',
        capacityLevel: 'high',
        workloadLevel: 'medium',
        frictionType: 'NO_FRICTION',
        outcome: OutcomeType.completed,
      ));

      // Event in Low capacity
      service.recordLearningEvent(LearningEvent(
        eventId: 'evt_low',
        timestamp: now,
        actionId: 'action_focus',
        actionType: 'startFocus',
        capacityLevel: 'low',
        workloadLevel: 'medium',
        frictionType: 'CAPACITY_FRICTION',
        outcome: OutcomeType.abandoned,
      ));

      final highSnapshot = createSnapshot(mentalBattery: 80);
      final lowSnapshot = createSnapshot(mentalBattery: 20);

      final highContext = service.buildLearningContext(highSnapshot);
      final lowContext = service.buildLearningContext(lowSnapshot);

      expect(highContext.learnings.first.contextPattern, contains('capacity:high'));
      expect(lowContext.learnings.first.contextPattern, contains('capacity:low'));
    });

    test('TEST 6 & 11: Dynamic G3 -> G4 -> G3 loop executes deterministically without LLM/side-effects', () {
      final snapshot = createSnapshot();

      // Step 1: Baseline decision
      final decision1 = service.decideAdaptiveAction(snapshot);
      expect(decision1.decisionType, equals('SELECT_TASK'));

      // Step 2: Record G4 learning outcome
      service.recordLearningEvent(LearningEvent(
        eventId: 'evt_loop',
        timestamp: DateTime.now(),
        actionId: decision1.selectedActionId!,
        actionType: 'startTask',
        capacityLevel: 'high',
        workloadLevel: 'medium',
        frictionType: 'NO_FRICTION',
        outcome: OutcomeType.completed,
      ));

      // Step 3: Recalculate G3 decision with G4 knowledge
      final decision2 = service.decideAdaptiveAction(snapshot);
      expect(decision2.decisionType, equals('SELECT_TASK'));
      expect(service.learningEvents.length, equals(1));
    });
  });
}
