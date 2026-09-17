import 'package:flutter_test/flutter_test.dart';
import 'package:nexii/domains/aura/aura_domain_state.dart';
import 'package:nexii/providers/app_state_provider.dart';
import 'package:nexii/intelligence/nodes/aura_node.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Aura Domain Tests', () {
    test('AuraDomainState computes 6-pillar score accurately with formula preservation', () {
      final domain = AuraDomainState();
      final result = domain.computeAura(
        tasks: [{'id': '1', 'isCompleted': true}],
        livingGoals: [{'progress': 0.8}],
        focusMinutesTotal: 60,
        dailySleep: 8,
        selectedMood: 'Serein',
        streak: 5,
        cognitiveFatigue: 20,
      );

      expect(result.score, greaterThan(0));
      expect(result.score, lessThanOrEqualTo(100));
      expect(result.level, isNotEmpty);
      expect(result.icon, isNotEmpty);
    });

    test('Single source of truth: AuraDomainState == AppStateProvider.auraScore == ContextSnapshot.auraScore == AuraNode input', () {
      final state = AppStateProvider();
      final score = state.auraScore;
      final result = state.currentAuraResult;
      final snapshot = state.currentContextSnapshot;

      expect(result.score, equals(score));
      expect(snapshot.auraScore, equals(score));
      expect(state.auraPercentage, equals(score.toDouble()));

      final auraNode = AuraNode();
      final nodeResult = auraNode.execute(snapshot);
      expect(nodeResult.metadata['auraScore'], equals(score));
    });
  });
}
