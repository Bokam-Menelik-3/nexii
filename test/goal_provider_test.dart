import 'package:flutter_test/flutter_test.dart';
import 'package:nexii/providers/goal_provider.dart';
import 'package:nexii/models/goal_model.dart';

import 'package:nexii/core/services/goal_service.dart';
import 'package:nexii/core/services/i_firebase_service.dart';

class FakeIFirebaseService implements IFirebaseService {
  final Map<String, Map<String, dynamic>> _store = {};
  bool throwOnSave = false;

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
    final list = _store.values.toList();
    return list.map((m) => Map<String, dynamic>.from(m)).toList();
  }

  @override
  Future<bool> saveUserSubcollectionDocument(
      String subcollectionName, String docId, Map<String, dynamic> data) async {
    if (throwOnSave) throw Exception('save failed');
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

void main() {
  group('GoalProvider', () {
    late FakeIFirebaseService fakeFirebase;
    late GoalProvider provider;
    late GoalService service;

    setUp(() {
      fakeFirebase = FakeIFirebaseService();
      service = GoalService(fakeFirebase);
      provider = GoalProvider(service);
    });

    test('loadGoals returns empty when no goals', () async {
      await provider.loadGoals();
      expect(provider.goals, isEmpty);
    });

    test('addGoal creates and persists', () async {
      final goal = Goal(id: '', title: 'New Goal');
      await provider.addGoal(goal);
      expect(provider.goals, isNotEmpty);
      final saved = provider.goals.first;
      expect(saved.title, 'New Goal');
      expect(saved.id, isNotEmpty);
    });

    test('updateGoal modifies existing goal', () async {
      final goal = Goal(id: 'g1', title: 'G1');
      await fakeFirebase.saveUserSubcollectionDocument(
          'goals', goal.id, goal.toMap());
      await provider.loadGoals();
      final updated = goal.copyWith(title: 'G1 updated');
      await provider.updateGoal(updated);
      expect(provider.goals.first.title, 'G1 updated');
    });

    test('deleteGoal removes goal', () async {
      final goal = Goal(id: 'g2', title: 'G2');
      await fakeFirebase.saveUserSubcollectionDocument(
          'goals', goal.id, goal.toMap());
      await provider.loadGoals();
      expect(provider.goals.length, 1);
      await provider.deleteGoal('g2');
      expect(provider.goals, isEmpty);
    });

    test('clear empties memory but does not touch persistence', () async {
      final goal = Goal(id: 'g3', title: 'G3');
      await fakeFirebase.saveUserSubcollectionDocument(
          'goals', goal.id, goal.toMap());
      await provider.loadGoals();
      expect(provider.goals.length, 1);
      provider.clear();
      expect(provider.goals, isEmpty);
      // underlying store still has it
      final persisted = await fakeFirebase.fetchUserSubcollection('goals');
      expect(persisted?.length, 1);
    });

    test('service save error bubbles and provider keeps in-memory entry',
        () async {
      fakeFirebase.throwOnSave = true;
      final goal = Goal(id: '', title: 'ErrGoal');
      try {
        await provider.addGoal(goal);
        fail('expected exception');
      } catch (e) {
        // provider added to memory before save attempt
        expect(provider.goals.length, 1);
      }
    });
  });
}
