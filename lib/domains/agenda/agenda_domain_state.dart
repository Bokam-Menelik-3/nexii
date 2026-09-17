import 'package:flutter/foundation.dart';
import 'agenda_event.dart';

/// Domain state manager for Agenda events.
/// Handles CRUD operations, list management, and state notifications for Agenda.
class AgendaDomainState extends ChangeNotifier {
  final List<AgendaEvent> _events = [];

  /// Read-only view of current agenda events as typed objects
  List<AgendaEvent> get events => List.unmodifiable(_events);

  /// Read-only view as Map for backward compatibility with existing UI & ContextSnapshotBuilder
  List<Map<String, dynamic>> get eventsAsMaps =>
      _events.map((e) => e.toMap()).toList();

  /// Total count of scheduled agenda events
  int get count => _events.length;

  /// Whether the agenda is currently empty
  bool get isEmpty => _events.isEmpty;

  /// Set the complete list of events (used during cloud sync or reload)
  void setEvents(List<Map<String, dynamic>> rawList) {
    _events.clear();
    for (final item in rawList) {
      _events.add(AgendaEvent.fromMap(Map<String, dynamic>.from(item)));
    }
    notifyListeners();
  }

  /// Add a new agenda event
  void addEvent(String title, String time) {
    final newEvent = AgendaEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      time: time,
    );
    _events.add(newEvent);
    notifyListeners();
  }

  /// Remove an agenda event by index
  void removeEventAt(int index) {
    if (index >= 0 && index < _events.length) {
      _events.removeAt(index);
      notifyListeners();
    }
  }

  /// Clear all events (e.g. on logout or reset)
  void clear() {
    _events.clear();
    notifyListeners();
  }
}
