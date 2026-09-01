import 'package:flutter_test/flutter_test.dart';
import 'package:nexii/core/intelligence/progress_engine.dart';
import 'package:nexii/core/services/task_service.dart';
import 'package:nexii/core/services/goal_service.dart';
import 'package:nexii/core/services/focus_service.dart';
import 'package:nexii/core/services/profile_service.dart';
import 'package:nexii/core/services/i_firebase_service.dart';

class FakeFirebaseForContext implements IFirebaseService {
  final Map<String, dynamic> _userData;
  final Map<String, List<Map<String, dynamic>>> _subs;

  FakeFirebaseForContext(
      {Map<String, dynamic>? userData,
      Map<String, List<Map<String, dynamic>>>? subs})
      : _userData = userData ?? {},
        _subs = subs ?? {};

  @override
  bool get isLoggedIn => true;

  @override
  String? get uid => 'uid-test';

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
  Future<Map<String, dynamic>?> fetchUserData() async => _userData;

  @override
  Future<bool> saveUserData(Map<String, dynamic> data) async => true;

  @override
  Future<List<Map<String, dynamic>>?> fetchUserSubcollection(
      String subcollectionName) async {
    return _subs[subcollectionName] ?? [];
  }

  @override
  Future<bool> saveUserSubcollectionDocument(
      String subcollectionName, String docId, Map<String, dynamic> data) async {
    final col = _subs.putIfAbsent(subcollectionName, () => []);
    col.removeWhere((m) => m['id'] == docId);
    col.add(data);
    return true;
  }

  @override
  Future<bool> deleteUserSubcollectionDocument(
      String subcollectionName, String docId) async {
    final col = _subs[subcollectionName];
    if (col == null) return true;
    col.removeWhere((m) => m['id'] == docId);
    return true;
  }
}

void main() {
  test('Coach progress context is constructed from ProgressEngine', () async {
    final now = DateTime.now();
    final tasks = [
      {'id': 't1', 'title': 'A', 'isCompleted': true},
      {'id': 't2', 'title': 'B', 'isCompleted': false},
    ];
    final goals = [
      {'id': 'g1', 'title': 'Goal 1', 'progress': 0.1}
    ];
    final sessions = [
      {
        'id': 's1',
        'userId': 'uid-test',
        'startedAt': now.subtract(const Duration(days: 2)).toIso8601String(),
        'endedAt': now
            .subtract(const Duration(days: 2))
            .add(const Duration(minutes: 25))
            .toIso8601String(),
        'duration': 25
      }
    ];

    final fake = FakeFirebaseForContext(userData: {
      'preferences': {}
    }, subs: {
      'tasks': tasks,
      'goals': goals,
      'focus_sessions': sessions,
    });

    final engine = ProgressEngine(
      taskService: TaskService(fake),
      goalService: GoalService(fake),
      focusService: FocusService(fake),
      profileService: ProfileService(fake),
    );

    final summary = await engine.compute7DaySummary(now);
    final snap = summary.snapshot;

    expect(snap.totalTasks, 2);
    expect(snap.completedTasks, 1);
    expect(snap.focusSessions, 1);
    expect(snap.focusMinutes, 25);
  });
}
