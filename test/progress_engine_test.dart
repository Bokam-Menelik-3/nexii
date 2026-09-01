import 'package:flutter_test/flutter_test.dart';
import 'package:nexii/core/intelligence/progress_engine.dart';
import 'package:nexii/core/services/task_service.dart';
import 'package:nexii/core/services/goal_service.dart';
import 'package:nexii/core/services/focus_service.dart';
import 'package:nexii/core/services/profile_service.dart';
import 'package:nexii/core/services/i_firebase_service.dart';

class FakeFirebaseForProgress implements IFirebaseService {
  final String? _uid;
  final Map<String, dynamic> _userData;
  final Map<String, List<Map<String, dynamic>>> _subcollections;

  FakeFirebaseForProgress(
      {String? uid,
      Map<String, dynamic>? userData,
      Map<String, List<Map<String, dynamic>>>? subs})
      : _uid = uid ?? 'uid-test',
        _userData = userData ?? {},
        _subcollections = subs ?? {};

  @override
  bool get isLoggedIn => _uid != null;

  @override
  String? get uid => _uid;

  @override
  String? get email => null;

  @override
  Future<void> waitForInitialization() async {}

  @override
  Future<bool> signIn(String email, String password) async => false;

  @override
  Future<bool> signInAnonymously() async => false;

  @override
  Future<bool> signUp(String email, String password) async => false;

  @override
  void signOut() {}

  @override
  Future<Map<String, dynamic>?> fetchUserData() async => _userData;

  @override
  Future<bool> saveUserData(Map<String, dynamic> data) async => true;

  @override
  Future<List<Map<String, dynamic>>?> fetchUserSubcollection(
      String subcollectionName) async {
    return _subcollections[subcollectionName] ?? [];
  }

  @override
  Future<bool> saveUserSubcollectionDocument(String subcollectionName,
          String docId, Map<String, dynamic> data) async =>
      true;

  @override
  Future<bool> deleteUserSubcollectionDocument(
          String subcollectionName, String docId) async =>
      true;
}

void main() {
  test('ProgressEngine computes reasonable snapshot and insights', () async {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 6));

    // Tasks: 5 tasks, 2 completed
    final tasks = List.generate(
        5,
        (i) => {
              'id': 't$i',
              'title': 'Task $i',
              'isCompleted': i < 2,
              'linkedGoalId': i % 2 == 0 ? 'g1' : ''
            });

    // Goals: 1 goal
    final goals = [
      {'id': 'g1', 'title': 'Goal 1', 'progress': 0.2}
    ];

    // Focus sessions: 3 sessions within range
    final sessions = [
      {
        'id': 's1',
        'userId': 'uid-test',
        'startedAt':
            sevenDaysAgo.add(const Duration(days: 1)).toIso8601String(),
        'endedAt': sevenDaysAgo
            .add(const Duration(days: 1))
            .add(const Duration(minutes: 25))
            .toIso8601String(),
        'duration': 25
      },
      {
        'id': 's2',
        'userId': 'uid-test',
        'startedAt':
            sevenDaysAgo.add(const Duration(days: 3)).toIso8601String(),
        'endedAt': sevenDaysAgo
            .add(const Duration(days: 3))
            .add(const Duration(minutes: 30))
            .toIso8601String(),
        'duration': 30
      },
      {
        'id': 's3',
        'userId': 'uid-test',
        'startedAt':
            sevenDaysAgo.add(const Duration(days: 5)).toIso8601String(),
        'endedAt': sevenDaysAgo
            .add(const Duration(days: 5))
            .add(const Duration(minutes: 20))
            .toIso8601String(),
        'duration': 20
      }
    ];

    // Baseline in profile
    final userData = {
      'preferences': {
        'baselineSnapshot': {
          'createdAt': DateTime.now().toIso8601String(),
          'goalsCount': 1,
          'tasksCount': 4,
          'completedTasks': 1,
          'focusSessions': 2,
          'focusMinutes': 40,
          'mentalBattery': 80
        }
      }
    };

    final fakeFirebase =
        FakeFirebaseForProgress(uid: 'uid-test', userData: userData, subs: {
      'tasks': tasks,
      'goals': goals,
      'focus_sessions': sessions,
    });

    final taskService = TaskService(fakeFirebase);
    final goalService = GoalService(fakeFirebase);
    final focusService = FocusService(fakeFirebase);
    final profileService = ProfileService(fakeFirebase);

    final engine = ProgressEngine(
        taskService: taskService,
        goalService: goalService,
        focusService: focusService,
        profileService: profileService);

    final summary = await engine.compute7DaySummary(now);

    expect(summary.snapshot.totalTasks, 5);
    expect(summary.snapshot.completedTasks, 2);
    expect(summary.snapshot.focusSessions, 3);
    expect(summary.snapshot.focusMinutes, 25 + 30 + 20);
    expect(summary.snapshot.goalsCount, 1);
    // Insights should include completion and focus insights
    final titles = summary.insights.map((i) => i.title).toList();
    expect(titles.any((t) => t.contains('Taux de complétion')), isTrue);
    expect(
        titles.any((t) =>
            t.contains('Concentration') ||
            t.contains('concentration') ||
            t.contains('Plus de concentration')),
        isTrue);
  });
}
