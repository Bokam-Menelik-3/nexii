import 'package:flutter_test/flutter_test.dart';
import 'package:nexii/core/services/i_firebase_service.dart';
import 'package:nexii/core/services/task_service.dart';
import 'package:nexii/core/services/goal_service.dart';
import 'package:nexii/core/services/agenda_service.dart';
import 'package:nexii/providers/task_provider.dart';
import 'package:nexii/providers/goal_provider.dart';
import 'package:nexii/core/intelligence/action_engine_service.dart';

class FakePersistentFirebaseService implements IFirebaseService {
  bool _isLoggedIn = true;
  String? _uid = 'uid-test';
  String? _email = 'test@example.com';

  // in-memory storage: subcollection -> docId -> data
  final Map<String, Map<String, Map<String, dynamic>>> _store = {};

  @override
  bool get isLoggedIn => _isLoggedIn;

  @override
  String? get uid => _uid;

  @override
  String? get email => _email;

  @override
  Future<void> waitForInitialization() async {}

  @override
  Future<bool> signIn(String email, String password) async => true;

  @override
  Future<bool> signUp(String email, String password) async => true;

  @override
  Future<bool> signInAnonymously() async {
    _isLoggedIn = true;
    _uid = 'uid-guest';
    return true;
  }

  @override
  void signOut() {
    _isLoggedIn = false;
    _uid = null;
  }

  @override
  Future<Map<String, dynamic>?> fetchUserData() async => {};

  @override
  Future<bool> saveUserData(Map<String, dynamic> data) async => true;

  @override
  Future<List<Map<String, dynamic>>?> fetchUserSubcollection(
      String subcollectionName) async {
    final map = _store[subcollectionName];
    if (map == null) return [];
    final out = <Map<String, dynamic>>[];
    map.forEach((id, data) {
      final item = Map<String, dynamic>.from(data);
      item['id'] = id;
      out.add(item);
    });
    return out;
  }

  @override
  Future<bool> saveUserSubcollectionDocument(
      String subcollectionName, String docId, Map<String, dynamic> data) async {
    _store.putIfAbsent(subcollectionName, () => {});
    _store[subcollectionName]![docId] = Map<String, dynamic>.from(data);
    return true;
  }

  @override
  Future<bool> deleteUserSubcollectionDocument(
      String subcollectionName, String docId) async {
    _store[subcollectionName]?.remove(docId);
    return true;
  }
}

void main() {
  group('Coach intent -> ActionEngine -> persistence -> provider refresh', () {
    late FakePersistentFirebaseService fake;
    late TaskService taskService;
    late GoalService goalService;
    late AgendaService agendaService;
    late TaskProvider taskProvider;
    late GoalProvider goalProvider;

    setUp(() {
      fake = FakePersistentFirebaseService();
      taskService = TaskService(fake);
      goalService = GoalService(fake);
      agendaService = AgendaService(fake);
      taskProvider = TaskProvider(taskService);
      goalProvider = GoalProvider(goalService);
    });

    test('create_task intent persists and provider loads task', () async {
      final engine = ActionEngineService(
          taskService: taskService,
          goalService: goalService,
          agendaService: agendaService);

      final success = await engine.executeIntent({
        'action': 'create_task',
        'title': 'Test from Coach',
      });

      expect(success, isTrue);

      // Provider should load persisted tasks
      await taskProvider.loadTasks();
      expect(taskProvider.tasks.length, 1);
      expect(taskProvider.tasks.first.title, 'Test from Coach');
    });

    test('create_goal intent persists and provider loads goal', () async {
      final engine = ActionEngineService(
          taskService: taskService,
          goalService: goalService,
          agendaService: agendaService);

      final success = await engine.executeIntent({
        'action': 'create_goal',
        'title': 'Goal from Coach',
      });

      expect(success, isTrue);

      await goalProvider.loadGoals();
      expect(goalProvider.goals.length, 1);
      expect(goalProvider.goals.first.title, 'Goal from Coach');
    });
  });
}
