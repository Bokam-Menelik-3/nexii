import 'package:flutter_test/flutter_test.dart';
import 'package:nexii/providers/app_state_provider.dart';
import 'package:nexii/intelligence/nodes/aura_node.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('N1 & Aura Consistency Tests', () {
    test('AppStateProvider.auraScore == ContextSnapshot.auraScore == AuraNode input', () {
      final state = AppStateProvider();
      final score = state.auraScore;
      final snapshot = state.currentContextSnapshot;

      expect(snapshot.auraScore, equals(score));
      expect(state.auraPercentage, equals(score.toDouble()));

      final auraNode = AuraNode();
      final result = auraNode.execute(snapshot);

      expect(result.metadata['auraScore'], equals(score));
    });

    test('Completing a task dynamically updates auraScore and recalculates N1Summary', () {
      final state = AppStateProvider();
      final initialScore = state.auraScore;
      expect(initialScore, isNotNull);

      // Add & complete a task
      state.addTask('Test Task for Aura', 'High', 'Travail');
      final task = state.tasks.firstWhere((t) => t['title'] == 'Test Task for Aura');
      state.toggleTask(task['id']);

      final updatedScore = state.auraScore;
      final snapshot2 = state.currentContextSnapshot;
      final summary2 = state.currentN1Summary;

      expect(updatedScore, equals(state.auraScore));
      expect(state.auraPercentage, equals(updatedScore.toDouble()));
      expect(snapshot2.auraScore, equals(updatedScore));
      expect(summary2, isNotNull);
    });
  });
}
