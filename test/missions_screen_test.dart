import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nexii/providers/app_state_provider.dart';
import 'package:nexii/screens/missions_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MissionsScreen: 1. aucune mission (empty state)', (WidgetTester tester) async {
    final state = AppStateProvider();
    
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppStateProvider>.value(
          value: state,
          child: const MissionsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aucune mission active.'), findsOneWidget);
    expect(find.text('0 / 0 terminées'), findsOneWidget);
  });

  testWidgets('MissionsScreen: 2. mission réelle affichée, 3. progression réelle, 4. completion', (WidgetTester tester) async {
    final state = AppStateProvider();
    state.addMission('Méditation matinale', '10 minutes de calme', 50);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppStateProvider>.value(
          value: state,
          child: const MissionsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 2. Mission affichée comme prioritaire
    expect(find.text('Méditation matinale'), findsOneWidget);
    expect(find.text('Mission Prioritaire'), findsOneWidget);

    // 3. Progression réelle
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('0 / 1 terminées'), findsOneWidget);

    // 4. Action de complétion
    await tester.tap(find.text('Marquer comme terminée'));
    await tester.pumpAndSettle();

    expect(state.missions.first['isCompleted'], isTrue);
    expect(find.text('1 / 1 terminées'), findsOneWidget);
  });
}
