import 'package:flutter_test/flutter_test.dart';
import 'package:nexii/domains/agenda/agenda_domain_state.dart';
import 'package:nexii/providers/app_state_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Agenda Domain State Tests', () {
    test('AgendaDomainState manages events correctly', () {
      final domain = AgendaDomainState();
      expect(domain.isEmpty, isTrue);
      expect(domain.count, equals(0));

      domain.addEvent('Yoga', '08:00');
      expect(domain.isEmpty, isFalse);
      expect(domain.count, equals(1));
      expect(domain.events.first.title, equals('Yoga'));
      expect(domain.eventsAsMaps.first['title'], equals('Yoga'));

      domain.removeEventAt(0);
      expect(domain.isEmpty, isTrue);
    });

    test('AppStateProvider delegates Agenda operations to AgendaDomainState and triggers ContextSnapshot update', () {
      final state = AppStateProvider();
      expect(state.agendaEvents, isEmpty);

      state.addAgendaEvent('Méditation', '09:00');
      expect(state.agendaEvents.length, equals(1));
      expect(state.agendaEvents.first['title'], equals('Méditation'));

      final snapshot = state.currentContextSnapshot;
      expect(snapshot.agendaEvents.length, equals(1));
      expect(snapshot.agendaEvents.first.title, equals('Méditation'));

      state.removeAgendaEvent(0);
      expect(state.agendaEvents, isEmpty);
      expect(state.currentContextSnapshot.agendaEvents, isEmpty);
    });
  });
}
