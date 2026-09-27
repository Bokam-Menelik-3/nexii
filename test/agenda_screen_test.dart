import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nexii/providers/app_state_provider.dart';
import 'package:nexii/screens/agenda_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AgendaScreen: 1. aucun événement (état vide)', (WidgetTester tester) async {
    final state = AppStateProvider();
    
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppStateProvider>.value(
          value: state,
          child: const AgendaScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Aucune activité planifiée aujourd'hui."), findsOneWidget);
    expect(find.text('0 activités planifiées'), findsOneWidget);
  });

  testWidgets('AgendaScreen: 2. événement réel, 3. prochain identifié, 4. + Add', (WidgetTester tester) async {
    final state = AppStateProvider();
    // 4. Test + Add
    state.addAgendaEvent('Séance Yoga', '23:30');

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppStateProvider>.value(
          value: state,
          child: const AgendaScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 2. Événement réel affiché
    expect(find.text('Séance Yoga'), findsOneWidget);
    expect(find.text('23:30'), findsOneWidget);

    // 3. Prochain événement identifié en ENSUITE
    expect(find.text('ENSUITE'), findsOneWidget);
    expect(find.text('1 activités planifiées'), findsOneWidget);
  });
}
