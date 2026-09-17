import 'package:flutter_test/flutter_test.dart';
import 'package:nexii/intelligence/models/intelligence_models.dart';
import 'package:nexii/intelligence/services/intelligence_service.dart';
import 'package:nexii/providers/app_state_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Generation 1/4 - Understand Situation Model Tests', () {
    test('SituationModel.fromSnapshot builds structured situation correctly from real snapshot', () {
      final state = AppStateProvider();
      final snapshot = state.currentContextSnapshot;
      final situation = SituationModel.fromSnapshot(snapshot);

      expect(situation.capacityLevel, isNotNull);
      expect(situation.workloadLevel, isNotNull);
      expect(situation.timePressureLevel, isNotNull);
      expect(situation.auraScore, equals(state.auraScore));
      expect(situation.generatedAt, isNotNull);
    });

    test('INSUFFICIENT_CONTEXT signal identified when user has not checked in and has zero tasks', () {
      final state = AppStateProvider();
      state.logout();

      final snapshot = state.currentContextSnapshot;
      final situation = SituationModel.fromSnapshot(snapshot);

      expect(situation.currentFriction, equals('INSUFFICIENT_CONTEXT'));
      expect(situation.contextSignal, equals('Check-In requis'));
    });

    test('Dynamic Situation Model adapts (Situation A != Situation B) when tasks or capacity change', () {
      final service = IntelligenceService();
      final state = AppStateProvider();

      // Situation A: Initial state
      final snapshotA = state.currentContextSnapshot;
      final situationA = service.understandSituation(snapshotA);

      // Situation B: User adds 8 urgent tasks
      for (int i = 0; i < 8; i++) {
        state.addTask('Urgent Task $i', 'Sub', 'Pro', urgency: 'High');
      }
      final snapshotB = state.currentContextSnapshot;
      final situationB = service.understandSituation(snapshotB);

      expect(situationA.workloadLevel, isNot(equals(situationB.workloadLevel)));
      expect(situationB.workloadLevel, equals('overload'));
      expect(situationB.currentFriction, equals('OVERLOAD_FRICTION'));
    });

    test('SituationModel is read-only and leaves AppStateProvider unmutated', () {
      final state = AppStateProvider();
      final initialBattery = state.mentalBattery;
      final initialAura = state.auraScore;

      final snapshot = state.currentContextSnapshot;
      final situation = SituationModel.fromSnapshot(snapshot);

      expect(situation, isNotNull);
      expect(state.mentalBattery, equals(initialBattery));
      expect(state.auraScore, equals(initialAura));
    });
  });
}
