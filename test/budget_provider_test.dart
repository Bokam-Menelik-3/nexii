import 'package:flutter_test/flutter_test.dart';
import 'package:nexii/providers/budget_provider.dart';
import 'package:nexii/models/transaction_model.dart';

import 'package:nexii/core/services/budget_service.dart';
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

void main() {
  group('BudgetProvider', () {
    late FakeIFirebaseService fake;
    late BudgetProvider prov;
    late BudgetService service;

    setUp(() {
      fake = FakeIFirebaseService();
      service = BudgetService(fake);
      prov = BudgetProvider(service);
    });

    test('loadTransactions empty', () async {
      await prov.loadTransactions();
      expect(prov.transactions, isEmpty);
    });

    test('add income and expense and compute totals', () async {
      final income = TransactionItem(
          id: '',
          title: 'Salary',
          amount: 1000.0,
          type: 'income',
          date: DateTime.now());
      final expense = TransactionItem(
          id: '',
          title: 'Coffee',
          amount: 3.5,
          type: 'expense',
          date: DateTime.now());
      await prov.addTransaction(income);
      await prov.addTransaction(expense);
      expect(prov.totalIncome, closeTo(1000.0, 0.01));
      expect(prov.totalExpense, closeTo(3.5, 0.01));
      expect(prov.balance, closeTo(996.5, 0.01));
    });

    test('modify transaction updates totals', () async {
      final t = TransactionItem(
          id: 'x1',
          title: 'X',
          amount: 50.0,
          type: 'expense',
          date: DateTime.now());
      await fake.saveUserSubcollectionDocument('transactions', t.id, t.toMap());
      await prov.loadTransactions();
      expect(prov.totalExpense, 50.0);
      final updated = t.copyWith(amount: 30.0);
      await prov.updateTransaction(updated);
      expect(prov.totalExpense, 30.0);
    });

    test('delete transaction', () async {
      final t = TransactionItem(
          id: 'x2',
          title: 'Y',
          amount: 10.0,
          type: 'income',
          date: DateTime.now());
      await fake.saveUserSubcollectionDocument('transactions', t.id, t.toMap());
      await prov.loadTransactions();
      expect(prov.transactions.length, 1);
      await prov.deleteTransaction('x2');
      expect(prov.transactions, isEmpty);
    });

    test('clear empties memory only', () async {
      final t = TransactionItem(
          id: 'x3',
          title: 'Z',
          amount: 5.0,
          type: 'expense',
          date: DateTime.now());
      await fake.saveUserSubcollectionDocument('transactions', t.id, t.toMap());
      await prov.loadTransactions();
      expect(prov.transactions.length, 1);
      prov.clear();
      expect(prov.transactions, isEmpty);
      final persisted = await fake.fetchUserSubcollection('transactions');
      expect(persisted?.length ?? 0, 1);
    });
  });
}
