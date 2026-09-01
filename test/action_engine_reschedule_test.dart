import 'package:flutter_test/flutter_test.dart';
import 'package:nexii/core/services/i_firebase_service.dart';
import 'package:nexii/core/services/task_service.dart';
import 'package:nexii/core/services/agenda_service.dart';
import 'package:nexii/core/services/goal_service.dart';
import 'package:nexii/core/intelligence/action_engine_service.dart';
import 'package:nexii/providers/agenda_provider.dart';
import 'package:nexii/models/agenda_event_model.dart';

class FakePersistentFirebaseService implements IFirebaseService {
  bool _isLoggedIn = true;
  String? _uid = 'uid-test';
  String? _email = 'test@example.com';

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
  test('reschedule_task updates linked agenda event and provider reloads',
      () async {
    final fake = FakePersistentFirebaseService();
    final agendaService = AgendaService(fake);
    final taskService = TaskService(fake);

    // Create initial event linked to task 't1'
    final originalStart = DateTime.utc(2026, 9, 1, 9, 0, 0);
    final originalEnd = DateTime.utc(2026, 9, 1, 10, 0, 0);
    final event = AgendaEvent(
      id: 'e1',
      title: 'Meeting',
      startTime: originalStart,
      endTime: originalEnd,
      linkedTaskId: 't1',
    );

    await agendaService.saveEvent(event);

    final agendaProvider = AgendaProvider(agendaService);

    // Ensure provider loads the original event
    await agendaProvider.loadEvents();
    expect(agendaProvider.events.length, 1);
    expect(agendaProvider.events.first.startTime, originalStart);

    final goalService = GoalService(fake);
    final engine = ActionEngineService(
      taskService: taskService,
      goalService: goalService,
      agendaService: agendaService,
    );

    final newStart = DateTime.utc(2026, 9, 2, 14, 0, 0);

    final success = await engine.executeIntent({
      'action': 'reschedule_task',
      'taskId': 't1',
      'newStartTime': newStart.toIso8601String(),
    });

    expect(success, isTrue);

    // Reload provider and check updated event
    await agendaProvider.loadEvents();
    expect(agendaProvider.events.length, 1);
    expect(agendaProvider.events.first.startTime, newStart);
    expect(agendaProvider.events.first.endTime,
        newStart.add(originalEnd.difference(originalStart)));
  });
}
