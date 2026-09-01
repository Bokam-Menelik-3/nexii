import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../core/services/budget_service.dart';

class BudgetProvider with ChangeNotifier {
  final BudgetService _service;
  List<TransactionItem> _transactions = [];
  bool _isLoading = false;

  BudgetProvider(this._service);

  List<TransactionItem> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();
    _transactions = await _service.fetchTransactions();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionItem t) async {
    var toSave = t;
    if (toSave.id.isEmpty) {
      toSave =
          toSave.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString());
    }
    _transactions.add(toSave);
    notifyListeners();
    await _service.saveTransaction(toSave);
  }

  Future<void> updateTransaction(TransactionItem t) async {
    final idx = _transactions.indexWhere((x) => x.id == t.id);
    if (idx != -1) {
      _transactions[idx] = t;
      notifyListeners();
      await _service.saveTransaction(t);
    }
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
    await _service.deleteTransaction(id);
  }

  double get totalIncome => _transactions
      .where((t) => t.type == 'income')
      .fold(0.0, (s, t) => s + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == 'expense')
      .fold(0.0, (s, t) => s + t.amount);

  double get balance => totalIncome - totalExpense;

  void clear() {
    _transactions = [];
    notifyListeners();
  }
}
