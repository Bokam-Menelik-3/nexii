import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nexii/core/theme/app_theme.dart';
import 'package:nexii/providers/app_state_provider.dart';
import 'package:nexii/screens/tasks_screen.dart';

Widget buildTestableTasksScreen(
  AppStateProvider provider, {
  Size screenSize = const Size(390, 844),
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AppStateProvider>.value(value: provider),
    ],
    child: Builder(
      builder: (context) {
        return MediaQuery(
          data: MediaQueryData(size: screenSize),
          child: MaterialApp(
            themeMode: provider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            locale: provider.currentLocale,
            supportedLocales: const [
              Locale('fr', 'FR'),
              Locale('en', 'US'),
              Locale('es', 'ES'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const TasksScreen(),
          ),
        );
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('✓ 0 tâche: affiche état vide avec action d\'ajout', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    await tester.pumpWidget(buildTestableTasksScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(TasksScreen), findsOneWidget);
    expect(find.text('Aucune tâche pour le moment'), findsOneWidget);
    expect(find.text('Ajouter une tâche'), findsWidgets);
  });

  testWidgets('✓ 1 tâche: affiche dans Maintenant', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    provider.addTask('Lire un chapitre', 'Livre Clean Code', 'Développement');

    await tester.pumpWidget(buildTestableTasksScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('MAINTENANT'), findsOneWidget);
    expect(find.text('Lire un chapitre'), findsOneWidget);
    expect(find.text('Terminer'), findsOneWidget);
  });

  testWidgets('✓ plusieurs tâches: répartit dans Maintenant, Ensuite, Plus tard', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    provider.addTask('Tâche Urgente', 'Critique', 'Pro', priority: 'Haute', urgency: 'Haute');
    provider.addTask('Tâche Moyenne', 'Régulière', 'Travail', priority: 'Moyenne');
    provider.addTask('Tâche Basse', 'Quand j\'ai le temps', 'Perso', priority: 'Basse');

    await tester.pumpWidget(buildTestableTasksScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('MAINTENANT'), findsOneWidget);
    expect(find.text('Tâche Urgente'), findsOneWidget);

    expect(find.text('ENSUITE'), findsOneWidget);
    expect(find.text('Tâche Moyenne'), findsOneWidget);

    expect(find.text('PLUS TARD'), findsOneWidget);
    expect(find.text('Tâche Basse'), findsOneWidget);
  });

  testWidgets('✓ tâche prioritaire: dominante avec tags et pourquoi', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    provider.addGoal('Objectif Q3', 'Pro');
    final goalId = provider.goals.first['id'].toString();
    provider.addTask(
      'Présentation Client',
      'Préparation slides',
      'Travail',
      priority: 'Haute',
      urgency: 'Haute',
      estimatedTime: 45,
      energyNeeded: 'Haute',
      linkedGoalId: goalId,
    );

    await tester.pumpWidget(buildTestableTasksScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Présentation Client'), findsOneWidget);
    expect(find.text('Priorité haute • Urgence immédiate • Liée à l\'objectif "Objectif Q3"'), findsOneWidget);
    expect(find.text('45m'), findsOneWidget);
  });

  testWidgets('✓ tâche terminée: complétion via bouton et bascule en terminées', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    provider.addTask('Tâche à faire', 'Détails', 'Général');

    await tester.pumpWidget(buildTestableTasksScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('MAINTENANT'), findsOneWidget);

    // Tap Terminer
    await tester.tap(find.text('Terminer'));
    await tester.pump(const Duration(milliseconds: 100));

    // Now it is in all done state
    expect(find.text('Toutes les tâches sont accomplies ! 🎉'), findsOneWidget);
    expect(find.textContaining('TERMINÉES'), findsOneWidget);
  });

  testWidgets('✓ suppression d\'une tâche', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    provider.addTask('Tâche à supprimer', 'Détails', 'Test');

    await tester.pumpWidget(buildTestableTasksScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Tâche à supprimer'), findsOneWidget);

    // Tap delete icon
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Tâche à supprimer'), findsNothing);
    expect(find.text('Aucune tâche pour le moment'), findsOneWidget);
  });

  testWidgets('✓ Light & Dark themes', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    // Light
    await tester.pumpWidget(buildTestableTasksScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(TasksScreen), findsOneWidget);

    // Dark
    provider.toggleTheme();
    await tester.pumpWidget(buildTestableTasksScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(TasksScreen), findsOneWidget);
  });

  testWidgets('✓ FR, EN, ES localization', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    // FR
    provider.setLocale(const Locale('fr', 'FR'));
    await tester.pumpWidget(buildTestableTasksScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Champ de Tâches'), findsOneWidget);

    // EN
    provider.setLocale(const Locale('en', 'US'));
    await tester.pumpWidget(buildTestableTasksScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Living Tasks'), findsOneWidget);

    // ES
    provider.setLocale(const Locale('es', 'ES'));
    await tester.pumpWidget(buildTestableTasksScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Tareas Vivas'), findsOneWidget);
  });
}
