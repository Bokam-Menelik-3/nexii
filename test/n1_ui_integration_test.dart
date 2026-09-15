import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nexii/providers/app_state_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('N1 Recommendation Card displays in French, English, and Spanish', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    // Setup low battery and difficult task to trigger CAPACITY_FRICTION
    provider.updateMentalBattery(-50); // mental battery = 32
    provider.addTask('Examen Final', 'Sub', 'Pro', difficulty: 'Difficile', estimatedTime: 60);

    // Test French locale
    provider.setLocale(const Locale('fr', 'FR'));
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          locale: provider.currentLocale,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Text('Home'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(provider.translate('n1_header_title'), 'Nexii Intelligence');
    expect(provider.translate('n1_action_recovery_mode'), 'Activer le Mode Récupération 🌿');

    // Test English locale
    provider.setLocale(const Locale('en', 'US'));
    expect(provider.translate('n1_header_title'), 'Nexii Intelligence');
    expect(provider.translate('n1_action_recovery_mode'), 'Enable Recovery Mode 🌿');

    // Test Spanish locale
    provider.setLocale(const Locale('es', 'ES'));
    expect(provider.translate('n1_header_title'), 'Nexii Intelligence');
    expect(provider.translate('n1_action_recovery_mode'), 'Activar Modo Recuperación 🌿');
  });

  testWidgets('N1 UI reacts dynamically when task state changes', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    provider.addTask('Task 1', 'Sub', 'Pro');
    final summary1 = provider.currentN1Summary;
    expect(summary1.primaryAction, isNotNull);

    // Complete task
    final taskId = provider.tasks.first['id'].toString();
    provider.toggleTask(taskId);

    final summary2 = provider.currentN1Summary;
    expect(summary2.primaryAction, isNull);
  });
}
