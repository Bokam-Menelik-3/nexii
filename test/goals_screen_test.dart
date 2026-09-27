import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nexii/providers/app_state_provider.dart';
import 'package:nexii/screens/goals_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GoalsScreen: 2. état vide si aucun objectif', (WidgetTester tester) async {
    final state = AppStateProvider();
    
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppStateProvider>.value(
          value: state,
          child: const GoalsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aucun objectif actif.'), findsOneWidget);
    expect(find.text('0 / 0 terminés'), findsOneWidget);
  });

  testWidgets('GoalsScreen: 1. objectifs réels affichés, 3. progression réelle, 4. action principale', (WidgetTester tester) async {
    final state = AppStateProvider();
    state.addGoal('Préparer mon examen', 'Apprentissage');

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppStateProvider>.value(
          value: state,
          child: const GoalsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Objectif affiché
    expect(find.text('Préparer mon examen'), findsOneWidget);
    expect(find.text('Objectif Principal'), findsOneWidget);

    // 3. Progression réelle (initiale = 0%)
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('0 / 1 terminés'), findsOneWidget);

    // 4. Action principale : marquer comme terminé
    await tester.tap(find.text('Marquer comme terminé'));
    await tester.pumpAndSettle();

    expect(state.goals.first['progress'], 1.0);
    expect(find.text('1 / 1 terminés'), findsOneWidget);
  });
}
