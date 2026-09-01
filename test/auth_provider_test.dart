import 'package:flutter_test/flutter_test.dart';
import 'package:nexii/providers/auth_provider.dart';
import 'package:nexii/providers/profile_provider.dart';
import 'package:nexii/providers/goal_provider.dart';
import 'package:nexii/providers/task_provider.dart';
import 'package:nexii/providers/budget_provider.dart';
import 'package:nexii/providers/agenda_provider.dart';
import 'package:nexii/providers/focus_provider.dart';
import 'package:nexii/providers/app_state_provider.dart';
import 'package:nexii/core/services/i_firebase_service.dart';
import 'package:nexii/core/services/profile_service.dart';
import 'package:nexii/core/services/goal_service.dart';
import 'package:nexii/core/services/task_service.dart';
import 'package:nexii/core/services/budget_service.dart';
import 'package:nexii/core/services/agenda_service.dart';
import 'package:nexii/core/services/focus_service.dart';
import 'package:nexii/models/user_profile_model.dart';
import 'package:nexii/models/goal_model.dart';
import 'package:nexii/models/task_model.dart';
import 'package:nexii/models/transaction_model.dart';
import 'package:nexii/models/agenda_event_model.dart';

class FakeFirebaseService implements IFirebaseService {
  bool _isLoggedIn = false;
  String? _uid;
  String? _email;

  @override
  bool get isLoggedIn => _isLoggedIn;

  @override
  String? get uid => _uid;

  @override
  String? get email => _email;

  @override
  Future<bool> signIn(String email, String password) async {
    if (email == 'ok@example.com' && password == 'valid') {
      _isLoggedIn = true;
      _uid = 'uid-ok';
      _email = email;
      return true;
    }
    return false;
  }

  @override
  Future<bool> signUp(String email, String password) async {
    if (email.contains('@')) {
      _isLoggedIn = true;
      _uid = 'uid-new';
      _email = email;
      return true;
    }
    return false;
  }

  @override
  Future<bool> signInAnonymously() async {
    _isLoggedIn = true;
    _uid = 'uid-guest';
    _email = 'anonymous@nexii.app';
    return true;
  }

  @override
  void signOut() {
    _isLoggedIn = false;
    _uid = null;
    _email = null;
  }

  @override
  Future<void> waitForInitialization() async {
    // immediate
    return;
  }

  @override
  Future<Map<String, dynamic>?> fetchUserData() async {
    return null;
  }

  @override
  Future<bool> saveUserData(Map<String, dynamic> data) async {
    return true;
  }

  @override
  Future<List<Map<String, dynamic>>?> fetchUserSubcollection(
      String subcollectionName) async {
    return [];
  }

  @override
  Future<bool> saveUserSubcollectionDocument(
      String subcollectionName, String docId, Map<String, dynamic> data) async {
    return true;
  }

  @override
  Future<bool> deleteUserSubcollectionDocument(
      String subcollectionName, String docId) async {
    return true;
  }
}

void main() {
  group('AuthProvider with FakeFirebaseService', () {
    late FakeFirebaseService fake;
    late AuthProvider auth;

    setUp(() {
      fake = FakeFirebaseService();
      auth = AuthProvider(fake);
    });

    test('initial state: logged out', () {
      expect(auth.isLoggedIn, isFalse);
      expect(auth.uid, isNull);
    });

    test('login success sets uid', () async {
      final success = await auth.loginWithEmail('ok@example.com', 'valid');
      expect(success, isTrue);
      expect(auth.isLoggedIn, isTrue);
      expect(auth.uid, 'uid-ok');
    });

    test('login failure does not set uid', () async {
      final success = await auth.loginWithEmail('bad@example.com', 'wrong');
      expect(success, isFalse);
      expect(auth.isLoggedIn, isFalse);
      expect(auth.uid, isNull);
    });

    test('signup success sets uid', () async {
      final success = await auth.registerWithEmail('new@domain.com', 'pass');
      expect(success, isTrue);
      expect(auth.isLoggedIn, isTrue);
      expect(auth.uid, 'uid-new');
    });

    test('anonymous login works', () async {
      final success = await auth.continueAsGuest();
      expect(success, isTrue);
      expect(auth.isLoggedIn, isTrue);
      expect(auth.uid, 'uid-guest');
    });

    test('logout clears session', () async {
      await auth.continueAsGuest();
      expect(auth.isLoggedIn, isTrue);
      auth.logout();
      expect(auth.isLoggedIn, isFalse);
      expect(auth.uid, isNull);
    });

    test('initialize reflects restored session', () async {
      // simulate restored session by setting fake state before initialize
      fake._isLoggedIn = true;
      fake._uid = 'uid-restored';
      await auth.initialize();
      expect(auth.isLoggedIn, isTrue);
      expect(auth.uid, 'uid-restored');
    });

    test('logout cleanup clears provider memory', () async {
      final profileProv = ProfileProvider(ProfileService(fake));
      final goalProv = GoalProvider(GoalService(fake));
      final taskProv = TaskProvider(TaskService(fake));
      final budgetProv = BudgetProvider(BudgetService(fake));
      final agendaProv = AgendaProvider(AgendaService(fake));
      final focusProv = FocusProvider(FocusService(fake));
      final appState = AppStateProvider();

      await profileProv.updateProfile(
        const UserProfile(uid: 'uid-ok', name: 'Alice'),
      );
      await goalProv.addGoal(const Goal(id: 'g1', title: 'Goal 1'));
      await taskProv.addTask(const Task(id: 't1', title: 'Task 1'));
      await budgetProv.addTransaction(
        TransactionItem(
          id: 'tx1',
          title: 'Salary',
          amount: 1000,
          type: 'income',
          date: DateTime.now(),
        ),
      );
      await agendaProv.addEvent(
        AgendaEvent(
          id: 'e1',
          title: 'Sprint review',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          linkedTaskId: 't1',
        ),
      );
      focusProv.startFocus();
      appState.completeOnboarding();

      expect(profileProv.profile, isNotNull);
      expect(goalProv.goals, isNotEmpty);
      expect(taskProv.tasks, isNotEmpty);
      expect(budgetProv.transactions, isNotEmpty);
      expect(agendaProv.events, isNotEmpty);
      expect(focusProv.isFocusing, isTrue);

      appState.resetOnboarding();
      profileProv.clearProfile();
      goalProv.clear();
      taskProv.clear();
      budgetProv.clear();
      agendaProv.clear();
      focusProv.clear();

      expect(appState.isOnboardingComplete, isFalse);
      expect(profileProv.profile, isNull);
      expect(goalProv.goals, isEmpty);
      expect(taskProv.tasks, isEmpty);
      expect(budgetProv.transactions, isEmpty);
      expect(agendaProv.events, isEmpty);
      expect(focusProv.secondsRemaining, 25 * 60);
    });

    test('profile baseline snapshot records initial J0 data', () async {
      final profileProv = ProfileProvider(ProfileService(fake));
      await profileProv.updateProfile(
        const UserProfile(uid: 'uid-ok', name: 'Baseline User'),
      );

      await profileProv.recordBaseline(
        goalsCount: 2,
        tasksCount: 5,
        completedTasks: 1,
        focusSessions: 3,
        focusMinutes: 45,
      );

      expect(profileProv.profile, isNotNull);
      expect(profileProv.profile!.preferences['baselineSnapshot'], isNotNull);
      expect(
        profileProv.profile!.preferences['baselineSnapshot']['goalsCount'],
        2,
      );
      expect(
        profileProv.profile!.preferences['baselineSnapshot']['tasksCount'],
        5,
      );
      expect(
        profileProv.profile!.preferences['baselineSnapshot']['focusMinutes'],
        45,
      );
    });
  });
}
