import 'i_firebase_service.dart';
import '../../models/focus_session_model.dart';

class FocusService {
  final IFirebaseService _firebaseService;

  FocusService(this._firebaseService);

  Future<void> saveSession(FocusSession session) async {
    final uid = _firebaseService.uid;
    if (uid == null) return;
    await _firebaseService.saveUserSubcollectionDocument(
        'focus_sessions', session.id, session.toMap());
  }

  Future<List<FocusSession>> fetchSessions() async {
    final list =
        await _firebaseService.fetchUserSubcollection('focus_sessions');
    if (list == null) return [];
    return list.map((map) => FocusSession.fromMap(map)).toList();
  }
}
