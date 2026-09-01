import '../../models/goal_model.dart';
import 'i_firebase_service.dart';

class GoalService {
  final IFirebaseService _firebaseService;

  GoalService(this._firebaseService);

  Future<List<Goal>> fetchGoals() async {
    final docs = await _firebaseService.fetchUserSubcollection('goals');
    if (docs == null) return [];
    return docs.map((doc) => Goal.fromMap(doc)).toList();
  }

  Future<void> saveGoal(Goal goal) async {
    await _firebaseService.saveUserSubcollectionDocument(
        'goals', goal.id, goal.toMap());
  }

  Future<void> deleteGoal(String goalId) async {
    await _firebaseService.deleteUserSubcollectionDocument('goals', goalId);
  }
}
