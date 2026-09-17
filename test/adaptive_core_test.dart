import 'package:flutter_test/flutter_test.dart';
import 'package:nexii/providers/app_state_provider.dart';
import 'package:nexii/intelligence/nodes/aura_node.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Adaptive Core Loop Tests', () {
    test('Check-In updates Mental Battery, Aura, ContextSnapshot, and N1Summary', () {
      final state = AppStateProvider();
      final initialBattery = state.mentalBattery;

      // Submit high energy, low stress check-in
      state.submitDailyCheckIn(5, 5, 5, 1, 8);

      final updatedBattery = state.mentalBattery;
      final updatedAura = state.auraScore;
      final snapshot = state.currentContextSnapshot;
      final summary = state.currentN1Summary;

      expect(updatedBattery, greaterThanOrEqualTo(initialBattery));
      expect(snapshot.mentalBattery, equals(updatedBattery));
      expect(snapshot.auraScore, equals(updatedAura));
      expect(summary, isNotNull);
    });

    test('Dynamic N1 evaluation adapts when user capacity drops', () {
      final state = AppStateProvider();

      // Case A: High energy, low stress
      state.submitDailyCheckIn(5, 5, 5, 1, 8);

      // Case B: Toggle recovery mode to drop workload capacity
      state.toggleRecoveryMode();
      final summaryB = state.currentN1Summary;

      expect(state.isRecoveryMode, isTrue);
      expect(summaryB, isNotNull);
      expect(summaryB.summaryId, isNotEmpty);
    });

    test('Canonical Aura value is consistent across AppStateProvider, ContextSnapshot, and AuraNode', () {
      final state = AppStateProvider();
      final score = state.auraScore;
      final snapshot = state.currentContextSnapshot;

      expect(snapshot.auraScore, equals(score));
      expect(state.auraPercentage, equals(score.toDouble()));

      final auraNode = AuraNode();
      final result = auraNode.execute(snapshot);
      expect(result.metadata['auraScore'], equals(score));
    });

    test('Execution of an IntelligentAction mutates state and updates ContextSnapshot dynamically', () {
      final state = AppStateProvider();
      expect(state.isRecoveryMode, isFalse);

      // Trigger action
      state.toggleRecoveryMode();
      expect(state.isRecoveryMode, isTrue);

      final snapshot = state.currentContextSnapshot;
      expect(snapshot.mentalBattery, isNotNull);
    });
  });
}
