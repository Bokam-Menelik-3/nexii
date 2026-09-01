import '../../models/agenda_event_model.dart';
import 'i_firebase_service.dart';

class AgendaService {
  final IFirebaseService _firebaseService;

  AgendaService(this._firebaseService);

  Future<List<AgendaEvent>> fetchEvents() async {
    final docs = await _firebaseService.fetchUserSubcollection('events');
    if (docs == null) return [];
    return docs.map((doc) => AgendaEvent.fromMap(doc)).toList();
  }

  Future<void> saveEvent(AgendaEvent event) async {
    await _firebaseService.saveUserSubcollectionDocument(
        'events', event.id, event.toMap());
  }

  Future<void> deleteEvent(String eventId) async {
    await _firebaseService.deleteUserSubcollectionDocument('events', eventId);
  }
}
