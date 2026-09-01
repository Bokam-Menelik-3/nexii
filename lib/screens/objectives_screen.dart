import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';
import '../providers/task_provider.dart';
import '../models/goal_model.dart';
import '../models/task_model.dart';
import '../providers/profile_provider.dart';

class ObjectivesScreen extends StatefulWidget {
  const ObjectivesScreen({super.key});

  @override
  State<ObjectivesScreen> createState() => _ObjectivesScreenState();
}

class _ObjectivesScreenState extends State<ObjectivesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalProvider>().loadGoals();
      context.read<TaskProvider>().loadTasks();
    });
  }

  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouvel Objectif'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Titre de l\'objectif'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                final newGoal = Goal(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text.trim(),
                );
                context.read<GoalProvider>().addGoal(newGoal);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog({String? initialGoalId}) {
    final titleController = TextEditingController();
    String? selectedGoalId = initialGoalId;
    String selectedPriority = 'Moyenne';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final goals = context.read<GoalProvider>().goals;
            return AlertDialog(
              title: const Text('Nouvelle Tâche'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration:
                        const InputDecoration(labelText: 'Titre de la tâche'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedPriority,
                    decoration: const InputDecoration(labelText: 'Priorité'),
                    items: const [
                      DropdownMenuItem(
                          value: 'Haute', child: Text('Haute (15 XP)')),
                      DropdownMenuItem(
                          value: 'Moyenne', child: Text('Moyenne (10 XP)')),
                      DropdownMenuItem(
                          value: 'Basse', child: Text('Basse (5 XP)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => selectedPriority = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String?>(
                    initialValue: selectedGoalId,
                    decoration: const InputDecoration(
                        labelText: 'Liée à un objectif (Optionnel)'),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Aucun objectif')),
                      ...goals.map((g) => DropdownMenuItem(
                            value: g.id,
                            child: Text(g.title),
                          )),
                    ],
                    onChanged: (val) {
                      setState(() {
                        selectedGoalId = val;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isNotEmpty) {
                      final newTask = Task(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text.trim(),
                        linkedGoalId: selectedGoalId ?? '',
                        priority: selectedPriority,
                      );
                      context.read<TaskProvider>().addTask(newTask);
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteGoal(Goal goal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cet objectif ?'),
        content: Text('Voulez-vous vraiment supprimer "${goal.title}" ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<GoalProvider>().deleteGoal(goal.id);
              Navigator.pop(ctx);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTask(Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette tâche ?'),
        content: Text('Voulez-vous vraiment supprimer "${task.title}" ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<TaskProvider>().deleteTask(task.id);
              Navigator.pop(ctx);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goalProvider = context.watch<GoalProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final profileProvider = context.read<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Objectifs & Tâches'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'goal') _showAddGoalDialog();
              if (val == 'task') _showAddTaskDialog();
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                  value: 'goal', child: Text('Créer un Objectif')),
              const PopupMenuItem(
                  value: 'task', child: Text('Créer une Tâche')),
            ],
          )
        ],
      ),
      body: goalProvider.isLoading || taskProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Mes Objectifs',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _showAddGoalDialog),
                  ],
                ),
                if (goalProvider.goals.isEmpty) const Text('Aucun objectif.'),
                ...goalProvider.goals.map((goal) {
                  final goalTasks = taskProvider.tasks
                      .where((t) => t.linkedGoalId == goal.id)
                      .toList();
                  final completedCount =
                      goalTasks.where((t) => t.isCompleted).length;
                  final totalCount = goalTasks.length;
                  final progress =
                      totalCount > 0 ? (completedCount / totalCount) : 0.0;

                  // Mise à jour automatique de la progression (calcul local)
                  if (goal.progress != progress) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      goalProvider
                          .updateGoal(goal.copyWith(progress: progress));
                    });
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ExpansionTile(
                      title: Text(goal.title),
                      subtitle:
                          Text('Progression: ${(progress * 100).toInt()}%'),
                      leading: const Icon(Icons.flag),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_task),
                            onPressed: () =>
                                _showAddTaskDialog(initialGoalId: goal.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDeleteGoal(goal),
                          ),
                        ],
                      ),
                      children: [
                        if (goalTasks.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('Aucune tâche associée.'),
                          ),
                        ...goalTasks.map((task) => ListTile(
                              title: Text(
                                task.title,
                                style: TextStyle(
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null),
                              ),
                              leading: Checkbox(
                                value: task.isCompleted,
                                onChanged: (val) {
                                  final newVal = val ?? false;
                                  taskProvider.updateTask(
                                      task.copyWith(isCompleted: newVal),
                                      profileProvider: profileProvider);
                                },
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () => _confirmDeleteTask(task),
                              ),
                            )),
                      ],
                    ),
                  );
                }),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tâches orphelines',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _showAddTaskDialog),
                  ],
                ),
                ...taskProvider.tasks
                    .where((t) => t.linkedGoalId.isEmpty)
                    .map((task) => ListTile(
                          title: Text(
                            task.title,
                            style: TextStyle(
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null),
                          ),
                          leading: Checkbox(
                            value: task.isCompleted,
                            onChanged: (val) {
                              final newVal = val ?? false;
                              taskProvider.updateTask(
                                  task.copyWith(isCompleted: newVal),
                                  profileProvider: profileProvider);
                            },
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            onPressed: () => _confirmDeleteTask(task),
                          ),
                        )),
              ],
            ),
    );
  }
}
