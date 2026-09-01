import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/agenda_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/task_provider.dart';
import '../providers/focus_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    auth.logout();

    context.read<AppStateProvider>().resetOnboarding();
    context.read<ProfileProvider>().clearProfile();
    context.read<GoalProvider>().clear();
    context.read<TaskProvider>().clear();
    context.read<BudgetProvider>().clear();
    context.read<AgendaProvider>().clear();
    context.read<FocusProvider>().clear();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final profile = profileProvider.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil Nexii'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Déconnexion'),
                  content: const Text(
                      'Voulez-vous vraiment vous déconnecter et vider la session ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Annuler'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Déconnexion'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await _logout(context);
              }
            },
          )
        ],
      ),
      body: profileProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (profile != null) ...[
                  Text('Bonjour, ${profile.name}',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                      'Niveau ${profile.level} | XP: ${profile.xp} | Batterie: ${profile.mentalBattery}%'),
                  const Divider(),
                ],
                const Text('Aujourd\'hui',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                taskProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : taskProvider.tasks.isEmpty
                        ? const Text('Aucune tâche pour le moment.')
                        : Column(
                            children: taskProvider.tasks
                                .map((task) => ListTile(
                                      title: Text(task.title),
                                      subtitle: Text(task.priority),
                                      trailing: Checkbox(
                                        value: task.isCompleted,
                                        onChanged: (val) {
                                          taskProvider.updateTask(
                                              task.copyWith(
                                                  isCompleted: val ?? false),
                                              profileProvider: profileProvider);
                                        },
                                      ),
                                    ))
                                .toList(),
                          )
              ],
            ),
    );
  }
}
