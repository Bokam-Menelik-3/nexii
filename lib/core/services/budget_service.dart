import '../../models/transaction_model.dart';
import 'i_firebase_service.dart';

class BudgetService {
  final IFirebaseService _firebaseService;

  BudgetService(this._firebaseService);

  Future<List<TransactionItem>> fetchTransactions() async {
    final docs = await _firebaseService.fetchUserSubcollection('transactions');
    if (docs == null) return [];
    return docs.map((d) => TransactionItem.fromMap(d)).toList();
  }

  Future<void> saveTransaction(TransactionItem t) async {
    await _firebaseService.saveUserSubcollectionDocument(
        'transactions', t.id, t.toMap());
  }

  Future<void> deleteTransaction(String id) async {
    await _firebaseService.deleteUserSubcollectionDocument('transactions', id);
  }
}
