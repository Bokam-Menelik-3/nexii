import 'package:flutter_test/flutter_test.dart';
import 'package:nexii/domains/focus/focus_domain_state.dart';
import 'package:nexii/providers/app_state_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Focus Domain State Tests', () {
    test('FocusDomainState records focus sessions and total minutes', () {
      final domain = FocusDomainState();
      expect(domain.totalFocusMinutes, equals(0));

      domain.recordSession(25, mode: 'Pomodoro');
      expect(domain.totalFocusMinutes, equals(25));
      expect(domain.sessions.length, equals(1));
      expect(domain.sessions.first.minutes, equals(25));

      domain.setSelectedSound('Océan');
      expect(domain.selectedSound, equals('Océan'));

      domain.clear();
      expect(domain.totalFocusMinutes, equals(0));
    });

    test('AppStateProvider delegates Focus operations to FocusDomainState and updates ContextSnapshot', () {
      final state = AppStateProvider();
      final initialMinutes = state.focusMinutesTotal;

      state.addFocusMinutes(30);
      expect(state.focusMinutesTotal, equals(initialMinutes + 30));

      final snapshot = state.currentContextSnapshot;
      expect(snapshot.focusMinutesTotal, equals(initialMinutes + 30));
    });
  });
}
