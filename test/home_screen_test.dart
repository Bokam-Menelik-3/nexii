import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nexii/core/theme/app_theme.dart';
import 'package:nexii/providers/app_state_provider.dart';
import 'package:nexii/screens/home_screen.dart';

Widget buildTestableHomeScreen(
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
            home: const HomeScreen(),
          ),
        );
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('✓ Home avec données réelles', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    provider.completeOnboarding('Alice', '2000-05-15');
    provider.addTask('Préparer la réunion', 'Notes', 'Pro', priority: 'Haute');
    provider.addGoal('Certification Cloud', 'Formation');
    provider.submitDailyCheckIn(4, 4, 3, 2, 7);

    await tester.pumpWidget(buildTestableHomeScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.textContaining('Alice'), findsOneWidget);
    expect(find.textContaining('Aura'), findsWidgets);
    expect(find.text('Préparer la réunion'), findsOneWidget);
  });

  testWidgets('✓ Home sans tâche', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    provider.completeOnboarding('Bob', '1995-10-10');
    provider.submitDailyCheckIn(4, 4, 4, 2, 8);

    await tester.pumpWidget(buildTestableHomeScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(HomeScreen), findsOneWidget);
    // When no tasks and no goals, displays calm & balanced state
    expect(find.text('État Calme & Équilibré'), findsOneWidget);
  });

  testWidgets('✓ Home avec tâche prioritaire', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    provider.completeOnboarding('Charlie', '1998-01-01');
    provider.addTask('Rapport critique', 'Urgent', 'Pro', priority: 'Haute', urgency: 'Haute');
    provider.submitDailyCheckIn(4, 4, 4, 2, 7);

    await tester.pumpWidget(buildTestableHomeScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Rapport critique'), findsOneWidget);
    expect(find.text('Valider la tâche'), findsOneWidget);
  });

  testWidgets('✓ Home avec Mental Battery basse', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    provider.completeOnboarding('Diana', '1992-03-12');
    provider.submitDailyCheckIn(2, 1, 1, 5, 4);
    // Lower mental battery below 35
    provider.updateMentalBattery(-60);

    await tester.pumpWidget(buildTestableHomeScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Récupération Nécessaire'), findsOneWidget);
    expect(find.text('Démarrer une session calme'), findsOneWidget);
  });

  testWidgets('✓ Home avec situation normale', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    provider.completeOnboarding('Eve', '1999-07-21');
    provider.submitDailyCheckIn(4, 3, 3, 2, 7);
    provider.addTask('Lecture 20 min', 'Perso', 'Bien-être');

    await tester.pumpWidget(buildTestableHomeScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Lecture 20 min'), findsOneWidget);
    expect(find.textContaining('Aura: '), findsOneWidget);
  });

  testWidgets('✓ Home avec recommandation réelle', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    // The Experience Layer ranks CheckIn above Priority: check in first so
    // the Priority surface (with the N1 recommendation) is the applicable mode.
    provider.completeOnboarding('Margot', '1990-06-21');
    provider.submitDailyCheckIn(5, 5, 5, 1, 8);
    provider.addTask('Dossier fiscal', 'Finance', 'Admin', priority: 'Haute');

    await tester.pumpWidget(buildTestableHomeScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));

    // N1Summary produces a recommendation to start with Dossier fiscal
    expect(find.byIcon(Icons.lightbulb_outline), findsWidgets);
  });

  testWidgets('✓ Home sans recommandation', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    provider.completeOnboarding('Gaston', '1985-04-14');
    provider.submitDailyCheckIn(5, 5, 5, 1, 8);

    await tester.pumpWidget(buildTestableHomeScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));

    // With 0 open tasks and high energy, no task recommendation is shown
    expect(find.text('État Calme & Équilibré'), findsOneWidget);
  });

  testWidgets('✓ changement de données → Home mis à jour', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    provider.completeOnboarding('Helene', '1994-09-09');
    provider.submitDailyCheckIn(4, 4, 4, 2, 7);
    provider.addTask('Tâche active', 'Description', 'Pro');

    await tester.pumpWidget(buildTestableHomeScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Tâche active'), findsOneWidget);

    // Complete the task
    final taskId = provider.tasks.first['id'].toString();
    provider.toggleTask(taskId);

    await tester.pump(const Duration(milliseconds: 100));

    // Now task is completed, Home automatically updates to calm state
    expect(find.text('État Calme & Équilibré'), findsOneWidget);
  });

  testWidgets('✓ Light theme', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    provider.completeOnboarding('Iris', '1996-12-12');

    await tester.pumpWidget(buildTestableHomeScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('✓ Dark theme', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    provider.toggleTheme(); // switches to dark
    expect(provider.isDarkMode, true);

    await tester.pumpWidget(buildTestableHomeScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('✓ FR', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    provider.setLocale(const Locale('fr', 'FR'));

    await tester.pumpWidget(buildTestableHomeScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Aura: '), findsOneWidget);
    expect(find.text('BILAN'), findsOneWidget);
  });

  testWidgets('✓ EN', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    provider.setLocale(const Locale('en', 'US'));

    await tester.pumpWidget(buildTestableHomeScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Aura: '), findsOneWidget);
    expect(find.text('CHECK-IN'), findsOneWidget);
  });

  testWidgets('✓ ES', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    provider.setLocale(const Locale('es', 'ES'));

    await tester.pumpWidget(buildTestableHomeScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Aura: '), findsOneWidget);
    expect(find.text('BALANCE'), findsOneWidget);
  });

  testWidgets('✓ Mobile layout', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestableHomeScreen(provider, screenSize: const Size(390, 844)));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('✓ Tablet layout', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestableHomeScreen(provider, screenSize: const Size(1024, 768)));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(Row), findsWidgets);
  });

  testWidgets('✓ Pressure : une seule CTA primaire avec 6 tâches ouvertes', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    provider.completeOnboarding('Hugo', '1993-05-20');
    provider.submitDailyCheckIn(4, 4, 4, 2, 7);
    for (final title in ['Tâche A', 'Tâche B', 'Tâche C', 'Tâche D', 'Tâche E', 'Tâche F']) {
      provider.addTask(title, 'Description', 'Pro');
    }

    await tester.pumpWidget(buildTestableHomeScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));

    // Pressure mode (backlog > 5 open tasks): title + localized mode label.
    expect(find.text('Arriéré à Trier'), findsOneWidget);
    expect(find.text('À TRIER'), findsOneWidget);
    // Exactly one primary ElevatedButton (full-width triage CTA) on screen.
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Trier mes tâches'), findsOneWidget);
  });

  testWidgets('✓ Densité : agenda adaptatif (CheckIn 2 / Recovery 1)', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    provider.completeOnboarding('Salomé', '1996-08-08');
    provider.addAgendaEvent('Événement A', '08:00');
    provider.addAgendaEvent('Événement B', '10:00');
    provider.addAgendaEvent('Événement C', '15:00');
    // Pas de check-in → mode CheckIn (densité réduite → 2 éléments).

    await tester.pumpWidget(buildTestableHomeScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Bilan Quotidien'), findsOneWidget);
    expect(find.text('Événement A'), findsOneWidget);
    expect(find.text('Événement B'), findsOneWidget);
    expect(find.text('Événement C'), findsNothing);

    // Batterie critique → mode Recovery (densité minimale → 1 élément).
    provider.updateMentalBattery(-100);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Récupération Nécessaire'), findsOneWidget);
    expect(find.text('Événement A'), findsOneWidget);
    expect(find.text('Événement B'), findsNothing);
    expect(find.text('Événement C'), findsNothing);
  });

  testWidgets('✓ Intelligence Shift : Calm devient Recovery', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    provider.completeOnboarding('Inès', '1997-02-02');
    provider.submitDailyCheckIn(5, 5, 5, 1, 8);

    await tester.pumpWidget(buildTestableHomeScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('État Calme & Équilibré'), findsOneWidget);
    expect(find.text('TEMPS POUR TOI'), findsOneWidget);

    // La batterie chute sous le seuil critique → Recovery devient actif.
    provider.updateMentalBattery(-100);
    await tester.pump(const Duration(milliseconds: 100));
    // Laisser la transition (Intelligence Shift) se terminer, puis inspecter
    // l'état final plutôt que l'animation intermédiaire.
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Récupération Nécessaire'), findsOneWidget);
    expect(find.text('Démarrer une session calme'), findsOneWidget);
    expect(find.text('TEMPS POUR TOI'), findsNothing);
  });

  testWidgets('✓ Étiquette de mode Recovery localisée', (WidgetTester tester) async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    provider.completeOnboarding('Diana', '1992-03-12');
    provider.submitDailyCheckIn(2, 1, 1, 5, 4);
    provider.updateMentalBattery(-60);

    await tester.pumpWidget(buildTestableHomeScreen(provider));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Récupération Nécessaire'), findsOneWidget);
    expect(find.text('RÉCUPÉRATION'), findsOneWidget);
  });
}
