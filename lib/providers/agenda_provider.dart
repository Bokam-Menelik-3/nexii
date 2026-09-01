import 'package:flutter/material.dart';
import '../models/agenda_event_model.dart';
import '../core/services/agenda_service.dart';

class AgendaProvider with ChangeNotifier {
  final AgendaService _agendaService;
  List<AgendaEvent> _events = [];
  bool _isLoading = false;

  AgendaProvider(this._agendaService);

  List<AgendaEvent> get events => _events;
  bool get isLoading => _isLoading;

  Future<void> loadEvents() async {
    _isLoading = true;
    notifyListeners();
    _events = await _agendaService.fetchEvents();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEvent(AgendaEvent event) async {
    _events.add(event);
    notifyListeners();
    await _agendaService.saveEvent(event);
  }

  Future<void> updateEvent(AgendaEvent event) async {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
      notifyListeners();
      await _agendaService.saveEvent(event);
    }
  }

  Future<void> deleteEvent(String id) async {
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
    await _agendaService.deleteEvent(id);
  }

  void clear() {
    _events = [];
    notifyListeners();
  }
}
