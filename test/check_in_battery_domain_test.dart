import 'package:flutter_test/flutter_test.dart';
import 'package:nexii/domains/check_in/check_in_domain_state.dart';
import 'package:nexii/domains/adaptive_state/mental_battery_domain_state.dart';
import 'package:nexii/providers/app_state_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CheckIn & Mental Battery Domain Tests', () {
    test('CheckInDomainState stores and updates subjective daily metrics', () {
      final domain = CheckInDomainState();
      expect(domain.hasCheckedInToday, isFalse);

      domain.submitCheckIn(mood: 4, energy: 5, motivation: 4, stress: 2, sleep: 8);
      expect(domain.hasCheckedInToday, isTrue);
      expect(domain.dailyEnergy, equals(5));
      expect(domain.dailyStress, equals(2));

      domain.clear();
      expect(domain.hasCheckedInToday, isFalse);
    });

    test('MentalBatteryDomainState stores and updates cognitive reserve', () {
      final domain = MentalBatteryDomainState();
      expect(domain.mentalBattery, equals(82));

      domain.updateBattery(-20);
      expect(domain.mentalBattery, equals(62));

      domain.setCrisisMode(true);
      expect(domain.isCrisisMode, isTrue);
      expect(domain.mentalBattery, equals(42));
    });

    test('AppStateProvider delegates Check-In and Mental Battery and updates ContextSnapshot', () {
      final state = AppStateProvider();
      state.submitDailyCheckIn(5, 5, 4, 1, 8);

      expect(state.hasCheckedInToday, isTrue);
      expect(state.dailyEnergy, equals(5));

      final snapshot = state.currentContextSnapshot;
      expect(snapshot.dailyEnergy, equals(5));
      expect(snapshot.mentalBattery, equals(state.mentalBattery));
      expect(snapshot.auraScore, equals(state.auraScore));
    });
  });
}
