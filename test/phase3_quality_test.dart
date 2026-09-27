import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexii/providers/app_state_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 3 — Quality, Lifecycle & Offline Safety', () {
    late AppStateProvider provider;

    setUp(() {
      provider = AppStateProvider();
    });

    test('1. Uninitialized or default state provides safe context', () {
      expect(provider.tasks, isEmpty);
      expect(provider.goals, isEmpty);
      expect(provider.auraScore, greaterThanOrEqualTo(0));
      expect(provider.currentExperienceState, isNotNull);
    });

    test('2. Day validation updates streak and XP safely', () {
      final initialStreak = provider.streak;
      final initialXp = provider.xp;

      provider.validateDay();

      expect(provider.isDayValidated, isTrue);
      expect(provider.streak, equals(initialStreak + 1));
      expect(provider.xp, equals(initialXp + 30));
    });

    test('3. Task lifecycle (add, subtask, toggle, delete) executes safely', () {
      provider.addTask('Test Task', 'Subtitle', 'Travail');
      expect(provider.tasks.length, equals(1));

      final taskId = provider.tasks.first['id'] as String;
      provider.addSubTask(taskId, 'Subtask 1');
      expect((provider.tasks.first['subtasks'] as List).length, equals(1));

      provider.toggleTask(taskId);
      expect(provider.tasks.first['isCompleted'], isTrue);

      provider.deleteTask(taskId);
      expect(provider.tasks, isEmpty);
    });

    test('4. SignOut clears session state safely', () {
      provider.signOut();
      expect(provider.userUid, null);
    });
  });
}
