import 'package:flutter_test/flutter_test.dart';
import 'package:nexii/core/services/notification_service.dart';
import 'package:nexii/intelligence/context/context_snapshot_builder.dart';

void main() {
  group('NexiiNotificationService Invariants', () {
    late NexiiNotificationService service;
    late ContextSnapshotBuilder builder;

    setUp(() {
      service = NexiiNotificationService();
      builder = const ContextSnapshotBuilder();
    });

    test('1. Quiet hours (22:00) defers notification', () {
      final quietTime = DateTime(2025, 5, 10, 23, 0);
      final snapshot = builder.build(
        userId: 'u1',
        displayName: 'Iris',
        age: 30,
        isAnonymous: false,
        locale: 'fr',
        onboardingComplete: true,
        tasks: [],
        agendaEvents: [],
        goals: [],
        missions: [],
        xp: 100,
        level: 1,
        streak: 3,
        disciplineScore: 80,
        auraScore: 75,
        currentMood: 'Serein',
        dailyMood: 4,
        dailyEnergy: 4,
        dailyMotivation: 4,
        dailyStress: 1,
        dailySleep: 8,
        hasCheckedInToday: true,
        mentalBattery: 80,
        focusMinutesTotal: 60,
        totalBudget: 500,
        remainingBudget: 300,
        now: quietTime,
      );

      final decision = service.evaluate(
        snapshot: snapshot,
        title: 'Important',
        body: 'Conseil',
        targetRoute: '/home',
        now: quietTime,
      );

      expect(decision.outcome, equals(NotificationOutcome.defer));
      expect(decision.reason, equals('quiet_hours_active'));
    });

    test('2. Interruption budget silences 3rd notification in 24h', () {
      final activeTime = DateTime(2025, 5, 10, 14, 0);
      final snapshot = builder.build(
        userId: 'u1',
        displayName: 'Iris',
        age: 30,
        isAnonymous: false,
        locale: 'fr',
        onboardingComplete: true,
        tasks: [],
        agendaEvents: [],
        goals: [],
        missions: [],
        xp: 100,
        level: 1,
        streak: 3,
        disciplineScore: 80,
        auraScore: 75,
        currentMood: 'Serein',
        dailyMood: 4,
        dailyEnergy: 4,
        dailyMotivation: 4,
        dailyStress: 1,
        dailySleep: 8,
        hasCheckedInToday: true,
        mentalBattery: 80,
        focusMinutesTotal: 60,
        totalBudget: 500,
        remainingBudget: 300,
        now: activeTime,
      );

      // 1st notification -> SEND
      final d1 = service.evaluate(
        snapshot: snapshot,
        title: 'Notif 1',
        body: 'Body 1',
        targetRoute: '/tasks',
        now: activeTime,
      );
      expect(d1.outcome, equals(NotificationOutcome.send));

      // 2nd notification -> SEND
      final d2 = service.evaluate(
        snapshot: snapshot,
        title: 'Notif 2',
        body: 'Body 2',
        targetRoute: '/tasks',
        now: activeTime.add(const Duration(minutes: 30)),
      );
      expect(d2.outcome, equals(NotificationOutcome.send));

      // 3rd notification -> SILENCE (budget exceeded)
      final d3 = service.evaluate(
        snapshot: snapshot,
        title: 'Notif 3',
        body: 'Body 3',
        targetRoute: '/tasks',
        now: activeTime.add(const Duration(hours: 1)),
      );
      expect(d3.outcome, equals(NotificationOutcome.silence));
      expect(d3.reason, equals('interruption_budget_exceeded'));
    });
  });
}
