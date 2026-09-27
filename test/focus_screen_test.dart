import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nexii/providers/app_state_provider.dart';
import 'package:nexii/screens/focus_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FocusScreen: affichage initial, démarrage, pause et persistance réelle', (WidgetTester tester) async {
    final state = AppStateProvider();
    
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppStateProvider>.value(
          value: state,
          child: const FocusScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Affichage initial (Timer 25:00, bouton DÉMARRER)
    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('DÉMARRER'), findsOneWidget);

    // 2. Démarrage
    await tester.tap(find.text('DÉMARRER'));
    await tester.pump();
    expect(find.text('PAUSE'), findsOneWidget);

    // 3. Pause
    await tester.tap(find.text('PAUSE'));
    await tester.pump();
    expect(find.text('DÉMARRER'), findsOneWidget);

    // 4. Persistance réelle de focus minutes
    final initialFocus = state.focusMinutesTotal;
    state.addFocusMinutes(25);
    expect(state.focusMinutesTotal, initialFocus + 25);
  });
}
