import '../../models/task_model.dart';
import 'i_firebase_service.dart';

class TaskService {
  final IFirebaseService _firebaseService;

  TaskService(this._firebaseService);

  Future<List<Task>> fetchTasks() async {
    final docs = await _firebaseService.fetchUserSubcollection('tasks');
    if (docs == null) return [];
    return docs.map((doc) => Task.fromMap(doc)).toList();
  }

  Future<void> saveTask(Task task) async {
    await _firebaseService.saveUserSubcollectionDocument(
        'tasks', task.id, task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _firebaseService.deleteUserSubcollectionDocument('tasks', taskId);
  }
}
