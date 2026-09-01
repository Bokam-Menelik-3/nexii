import 'package:flutter_test/flutter_test.dart';
import 'package:nexii/providers/task_provider.dart';
import 'package:nexii/models/task_model.dart';
import 'package:nexii/providers/profile_provider.dart';
import 'package:nexii/core/services/profile_service.dart';

import 'package:nexii/core/services/task_service.dart';
import 'package:nexii/core/services/i_firebase_service.dart';

class FakeIFirebaseService implements IFirebaseService {
  final Map<String, Map<String, dynamic>> _store = {};

  @override
  bool get isLoggedIn => true;

  @override
  String? get uid => 'fake-uid';

  @override
  String? get email => 'fake@example.com';

  @override
  Future<void> waitForInitialization() async {}

  @override
  Future<bool> signIn(String email, String password) async => true;

  @override
  Future<bool> signUp(String email, String password) async => true;

  @override
  Future<bool> signInAnonymously() async => true;

  @override
  void signOut() {}

  @override
  Future<Map<String, dynamic>?> fetchUserData() async => null;

  @override
  Future<bool> saveUserData(Map<String, dynamic> data) async => true;

  @override
  Future<List<Map<String, dynamic>>?> fetchUserSubcollection(
      String subcollectionName) async {
    return _store.values.map((m) => Map<String, dynamic>.from(m)).toList();
  }

  @override
  Future<bool> saveUserSubcollectionDocument(
      String subcollectionName, String docId, Map<String, dynamic> data) async {
    _store[docId] = Map<String, dynamic>.from(data);
    return true;
  }

  @override
  Future<bool> deleteUserSubcollectionDocument(
      String subcollectionName, String docId) async {
    _store.remove(docId);
    return true;
  }
}

class FakeProfileProvider {
  int xp = 0;

  Future<void> addXp(int xpAmount) async {
    xp += xpAmount;
  }
}

void main() {
  group('TaskProvider', () {
    late FakeIFirebaseService fakeFirebase;
    late TaskProvider provider;
    late TaskService service;

    setUp(() {
      fakeFirebase = FakeIFirebaseService();
      service = TaskService(fakeFirebase);
      provider = TaskProvider(service);
    });

    test('loadTasks empty initially', () async {
      await provider.loadTasks();
      expect(provider.tasks, isEmpty);
    });

    test('addTask generates id and persists', () async {
      final task = Task(id: '', title: 'T1');
      await provider.addTask(task);
      expect(provider.tasks.length, 1);
      final saved = provider.tasks.first;
      expect(saved.id, isNotEmpty);
      expect(saved.title, 'T1');
    });

    test('updateTask awards xp on complete', () async {
      final task = Task(
          id: 't1',
          title: 'Do it',
          isCompleted: false,
          priority: 'Haute',
          xpAwarded: false);
      await fakeFirebase.saveUserSubcollectionDocument(
          'tasks', task.id, task.toMap());
      await provider.loadTasks();

      final profileService = ProfileService(fakeFirebase);
      final profileProv = ProfileProvider(profileService);
      await profileProv.loadProfile(fakeFirebase.uid!);
      final completed = task.copyWith(isCompleted: true);
      await provider.updateTask(completed, profileProvider: profileProv);
      // profileProv.addXp increments xp on completion; ensure xp > 0
      expect(profileProv.profile?.xp ?? 0, greaterThan(0));
      final updated = provider.tasks.first;
      expect(updated.isCompleted, isTrue);
      expect(updated.xpAwarded, isTrue);
    });

    test('deleteTask removes', () async {
      final task = Task(id: 't2', title: 'T2');
      await fakeFirebase.saveUserSubcollectionDocument(
          'tasks', task.id, task.toMap());
      await provider.loadTasks();
      expect(provider.tasks.length, 1);
      await provider.deleteTask('t2');
      expect(provider.tasks, isEmpty);
    });

    test('linkedGoalId preserved on add', () async {
      final task = Task(id: '', title: 'linked', linkedGoalId: 'gX');
      await provider.addTask(task);
      expect(provider.tasks.first.linkedGoalId, 'gX');
    });

    test('clear empties memory', () async {
      final task = Task(id: 't3', title: 'T3');
      await fakeFirebase.saveUserSubcollectionDocument(
          'tasks', task.id, task.toMap());
      await provider.loadTasks();
      expect(provider.tasks.length, 1);
      provider.clear();
      expect(provider.tasks, isEmpty);
      final persisted = await fakeFirebase.fetchUserSubcollection('tasks');
      expect(persisted?.length ?? 0, 1);
    });
  });
}
