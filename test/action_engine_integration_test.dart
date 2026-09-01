import 'package:flutter_test/flutter_test.dart';
import 'package:nexii/core/intelligence/action_engine.dart';
import 'package:nexii/core/services/i_firebase_service.dart';
import 'package:nexii/core/services/task_service.dart';
import 'package:nexii/core/services/goal_service.dart';
import 'package:nexii/core/services/agenda_service.dart';

class InMemoryFirebase implements IFirebaseService {
  final Map<String, List<Map<String, dynamic>>> _data = {};
  String? _uid = 'uid-test';

  @override
  bool get isLoggedIn => true;

  @override
  String? get uid => _uid;

  @override
  String? get email => null;

  @override
  Future<void> waitForInitialization() async {}

  @override
  Future<bool> signIn(String email, String password) async => false;

  @override
  Future<bool> signUp(String email, String password) async => false;

  @override
  Future<bool> signInAnonymously() async => false;

  @override
  void signOut() {}

  @override
  Future<Map<String, dynamic>?> fetchUserData() async => {};

  @override
  Future<bool> saveUserData(Map<String, dynamic> data) async => true;

  @override
  Future<List<Map<String, dynamic>>?> fetchUserSubcollection(
      String subcollectionName) async {
    return _data[subcollectionName] ?? [];
  }

  @override
  Future<bool> saveUserSubcollectionDocument(
      String subcollectionName, String docId, Map<String, dynamic> data) async {
    final col = _data.putIfAbsent(subcollectionName, () => []);
    col.removeWhere((m) => m['id'] == docId);
    col.add(data);
    return true;
  }

  @override
  Future<bool> deleteUserSubcollectionDocument(
      String subcollectionName, String docId) async {
    final col = _data[subcollectionName];
    if (col == null) return true;
    col.removeWhere((m) => m['id'] == docId);
    return true;
  }
}

void main() {
  test('ActionEngine.create_task persists task via TaskService', () async {
    final fb = InMemoryFirebase();
    final taskService = TaskService(fb);
    final goalService = GoalService(fb);
    final agendaService = AgendaService(fb);

    final engine = ActionEngine(
      taskService: taskService,
      goalService: goalService,
      agendaService: agendaService,
    );

    final success = await engine
        .executeIntent('create_task', {'title': 'Integration Task'});
    expect(success, isTrue);

    final tasks = await fb.fetchUserSubcollection('tasks');
    expect(tasks, isNotNull);
    expect(tasks!.any((t) => t['title'] == 'Integration Task'), isTrue);
  });
}
