import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_state_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/agenda_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/focus_provider.dart';
import 'core/services/firebase_service.dart';
import 'core/services/task_service.dart';
import 'core/services/goal_service.dart';
import 'core/services/agenda_service.dart';
import 'core/services/profile_service.dart';
import 'core/services/focus_service.dart';
import 'core/services/budget_service.dart';
import 'providers/budget_provider.dart';
import 'core/intelligence/action_engine_service.dart';
import 'core/intelligence/progress_engine.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final firebaseService = FirebaseService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(firebaseService)),
        ChangeNotifierProvider(create: (_) {
          final service = TaskService(firebaseService);
          return TaskProvider(service);
        }),
        ChangeNotifierProvider(create: (_) {
          final service = GoalService(firebaseService);
          return GoalProvider(service);
        }),
        ChangeNotifierProvider(create: (_) {
          final service = AgendaService(firebaseService);
          return AgendaProvider(service);
        }),
        ChangeNotifierProvider(create: (_) {
          final service = ProfileService(firebaseService);
          return ProfileProvider(service);
        }),
        ChangeNotifierProvider(create: (_) {
          final service = FocusService(firebaseService);
          return FocusProvider(service);
        }),
        ChangeNotifierProvider(create: (_) {
          final service = BudgetService(firebaseService);
          return BudgetProvider(service);
        }),
        // ActionEngine service for wiring AI intents to real actions
        Provider(create: (_) {
          final taskService = TaskService(firebaseService);
          final goalService = GoalService(firebaseService);
          final agendaService = AgendaService(firebaseService);
          return ActionEngineService(
            taskService: taskService,
            goalService: goalService,
            agendaService: agendaService,
          );
        }),
        // ProgressEngine provider to compute user progress summaries
        Provider(create: (_) {
          final taskService = TaskService(firebaseService);
          final goalService = GoalService(firebaseService);
          final focusService = FocusService(firebaseService);
          final profileService = ProfileService(firebaseService);
          return ProgressEngine(
            taskService: taskService,
            goalService: goalService,
            focusService: focusService,
            profileService: profileService,
          );
        }),
      ],
      child: const NexiiApp(),
    ),
  );
}

class NexiiApp extends StatelessWidget {
  const NexiiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    return MaterialApp(
      title: 'Nexii',
      debugShowCheckedModeBanner: false,
      themeMode: state.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      locale: state.currentLocale,
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
      home: const AppEntry(),
    );
  }
}
