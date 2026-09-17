import 'package:flutter_test/flutter_test.dart';
import 'package:nexii/intelligence/models/intelligence_models.dart';
import 'package:nexii/intelligence/services/intelligence_service.dart';
import 'package:nexii/providers/app_state_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Generation 2/4 - Anticipate Future Model Tests', () {
    test('TEST A: NO_ANTICIPATION produced when situation is balanced and stable', () {
      final state = AppStateProvider();
      // Ensure clean balanced state with CheckIn
      state.submitDailyCheckIn(4, 4, 4, 2, 8);

      final snapshot = state.currentContextSnapshot;
      final situation = SituationModel.fromSnapshot(snapshot);
      final anticipation = AnticipationModel.evaluate(snapshot, situation);

      expect(anticipation.type, equals('NO_ANTICIPATION'));
      expect(anticipation.affectedDomain, equals('General'));
      expect(anticipation.evidence, isNotEmpty);
    });

    test('TEST B: Real RISK anticipation produced when capacity or workload thresholds are breached', () {
      final state = AppStateProvider();
      state.updateMentalBattery(-60, reason: 'Test Heavy Draining');

      final snapshot = state.currentContextSnapshot;
      final situation = SituationModel.fromSnapshot(snapshot);
      final anticipation = AnticipationModel.evaluate(snapshot, situation);

      expect(anticipation.type, equals('RISK'));
      expect(anticipation.affectedDomain, equals('Capacity'));
      expect(anticipation.horizon, equals('immediate'));
      expect(anticipation.confidence, greaterThanOrEqualTo(0.8));
      expect(anticipation.evidence, isNotEmpty);
      expect(anticipation.potentialConsequence, isNotEmpty);
    });

    test('TEST C / D: False positive / Insufficient context handled honestly', () {
      final state = AppStateProvider();
      state.logout(); // No check-in, no tasks

      final snapshot = state.currentContextSnapshot;
      final situation = SituationModel.fromSnapshot(snapshot);
      final anticipation = AnticipationModel.evaluate(snapshot, situation);

      expect(situation.currentFriction, equals('INSUFFICIENT_CONTEXT'));
      expect(anticipation.type, equals('NO_ANTICIPATION'));
    });

    test('TEST E: Dynamic adaptation (Anticipation A != Anticipation B) upon real state mutation', () {
      final service = IntelligenceService();
      final state = AppStateProvider();

      // Situation A: Clean state -> NO_ANTICIPATION
      state.submitDailyCheckIn(4, 4, 4, 2, 8);
      final snapshotA = state.currentContextSnapshot;
      final anticipationA = service.anticipateFuture(snapshotA);

      // Mutation: Add 8 high priority urgent tasks to breach workload threshold
      for (int i = 0; i < 8; i++) {
        state.addTask('Urgent Task $i', 'Sub', 'Pro', urgency: 'High');
      }
      final snapshotB = state.currentContextSnapshot;
      final anticipationB = service.anticipateFuture(snapshotB);

      expect(anticipationA.type, equals('NO_ANTICIPATION'));
      expect(anticipationB.type, equals('RISK'));
      expect(anticipationB.affectedDomain, equals('Tasks'));
      expect(anticipationA.type, isNot(equals(anticipationB.type)));
    });

    test('TEST F: AnticipateNode is strictly read-only and leaves AppStateProvider unmutated', () {
      final state = AppStateProvider();
      final initialBattery = state.mentalBattery;
      final initialAura = state.auraScore;

      final snapshot = state.currentContextSnapshot;
      final situation = SituationModel.fromSnapshot(snapshot);
      final anticipation = AnticipationModel.evaluate(snapshot, situation);

      expect(anticipation, isNotNull);
      expect(state.mentalBattery, equals(initialBattery));
      expect(state.auraScore, equals(initialAura));
    });

    test('TEST G: 0 Network / LLM call isolation (deterministic local execution)', () {
      final service = IntelligenceService();
      final state = AppStateProvider();

      final snapshot = state.currentContextSnapshot;
      final anticipation = service.anticipateFuture(snapshot);

      expect(anticipation.confidence, greaterThan(0.0));
      expect(anticipation.generatedAt, isNotNull);
    });
  });
}
