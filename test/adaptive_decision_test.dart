import 'package:flutter_test/flutter_test.dart';
import 'package:nexii/intelligence/models/intelligence_models.dart';
import 'package:nexii/intelligence/services/intelligence_service.dart';

void main() {
  group('AdaptiveDecision (G3 Decision Engine)', () {
    late IntelligenceService service;

    setUp(() {
      service = IntelligenceService();
    });

    ContextSnapshot createBaseSnapshot({
      bool hasCheckedInToday = true,
      int mentalBattery = 80,
      int openTaskCount = 3,
      List<String> riskFlags = const [],
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
        riskFlags: riskFlags,
      );
    }

    test('recommends CHECKIN_REQUIRED when check-in is missing', () {
      final snapshot = createBaseSnapshot(hasCheckedInToday: false);
      final decision = service.decideAdaptiveAction(snapshot);

      expect(decision.decisionType, equals('CHECKIN_REQUIRED'));
      expect(decision.frictionTarget, equals('INSUFFICIENT_CONTEXT'));
    });

    test('recommends RECOVERY when mental battery is critically low', () {
      final snapshot = createBaseSnapshot(mentalBattery: 15);
      final decision = service.decideAdaptiveAction(snapshot);

      expect(decision.decisionType, equals('RECOVERY'));
      expect(decision.frictionTarget, equals('CAPACITY_FRICTION'));
    });

    test('recommends SELECT_TASK when state is healthy and open tasks exist', () {
      final snapshot = createBaseSnapshot(mentalBattery: 80, openTaskCount: 3);
      final decision = service.decideAdaptiveAction(snapshot);

      expect(decision.decisionType, equals('SELECT_TASK'));
      expect(decision.frictionTarget, equals('NO_FRICTION'));
    });

    test('executes in a read-only manner without side effects', () {
      final snapshot = createBaseSnapshot();
      final resultBefore = snapshot.openTasks.length;

      final decision1 = service.decideAdaptiveAction(snapshot);
      final decision2 = service.decideAdaptiveAction(snapshot);

      expect(decision1.decisionType, equals(decision2.decisionType));
      expect(snapshot.openTasks.length, equals(resultBefore));
    });
  });
}
