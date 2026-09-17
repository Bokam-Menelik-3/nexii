import 'package:flutter_test/flutter_test.dart';
import 'package:nexii/domains/tasks/task_domain_state.dart';
import 'package:nexii/domains/tasks/task_item.dart';
import 'package:nexii/providers/app_state_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Task Domain State Tests', () {
    test('TaskDomainState manages tasks and subtasks correctly', () {
      final domain = TaskDomainState();
      expect(domain.isEmpty, isTrue);

      final task = TaskItem(
        id: 't-1',
        title: 'Tester le domaine Tasks',
        category: 'Dev',
        priority: 'Haute',
      );

      domain.addTask(task);
      expect(domain.count, equals(1));
      expect(domain.tasks.first.title, equals('Tester le domaine Tasks'));

      domain.addSubTask('t-1', 'Sous-tâche 1');
      expect(domain.tasks.first.subtasks.length, equals(1));

      domain.toggleTask('t-1');
      expect(domain.tasks.first.isCompleted, isTrue);

      domain.deleteTask('t-1');
      expect(domain.isEmpty, isTrue);
    });

    test('AppStateProvider delegates Task operations to TaskDomainState and projects into ContextSnapshot', () {
      final state = AppStateProvider();
      final initialCount = state.tasks.length;

      state.addTask('Tâche via Provider', 'Sous-titre', 'Dev', priority: 'Haute');
      expect(state.tasks.length, equals(initialCount + 1));

      final snapshot = state.currentContextSnapshot;
      expect(snapshot.tasks.any((t) => t.title == 'Tâche via Provider'), isTrue);
    });
  });
}
