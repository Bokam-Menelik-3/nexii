import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _taskTitleController = TextEditingController();
  String _selectedCategory = 'Travail';
  String _selectedPriority = 'Haute';

  @override
  void dispose() {
    _taskTitleController.dispose();
    super.dispose();
  }

  void _showAddTaskDialog(BuildContext context, AppStateProvider state) {
    String selectedCategory = 'Travail';
    String selectedPriority = 'Haute';
    String selectedUrgency = 'Haute';
    String selectedDifficulty = 'Moyen';
    int selectedDuration = 30;
    String selectedEnergy = 'Moyenne';
    String selectedGoalId = '';
    bool showAdvanced = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(state.translate('add_task'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _taskTitleController,
                      decoration: InputDecoration(
                        hintText: state.translate('placeholder_add_task'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Catégorie', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedCategory = val;
                          });
                        }
                      },
                      items: ['Travail', 'Bien-être', 'Santé', 'Finance', 'Loisirs']
                          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Priorité', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedPriority,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedPriority = val;
                          });
                        }
                      },
                      items: ['Haute', 'Moyenne', 'Basse']
                          .map((prio) => DropdownMenuItem(value: prio, child: Text(prio)))
                          .toList(),
                    ),
                    
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setDialogState(() {
                            showAdvanced = !showAdvanced;
                          });
                        },
                        icon: Icon(
                          showAdvanced ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 16,
                          color: const Color(0xff8b5cf6),
                        ),
                        label: Text(
                          showAdvanced ? 'Options simples' : 'Options avancées',
                          style: const TextStyle(
                            color: Color(0xff8b5cf6),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),

                    if (showAdvanced) ...[
                      const SizedBox(height: 8),
                      const Text('Urgence', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedUrgency,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedUrgency = val;
                            });
                          }
                        },
                        items: ['Haute', 'Moyenne', 'Basse']
                            .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Difficulté', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedDifficulty,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedDifficulty = val;
                            });
                          }
                        },
                        items: ['Facile', 'Moyen', 'Difficile']
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Temps estimé', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: selectedDuration,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedDuration = val;
                            });
                          }
                        },
                        items: [10, 15, 30, 45, 60, 90, 120]
                            .map((d) => DropdownMenuItem(value: d, child: Text('$d min')))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Énergie nécessaire', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedEnergy,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedEnergy = val;
                            });
                          }
                        },
                        items: ['Basse', 'Moyenne', 'Haute']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Lier à un objectif', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedGoalId,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedGoalId = val;
                            });
                          }
                        },
                        items: [
                          const DropdownMenuItem(value: '', child: Text('Aucun')),
                          ...state.goals.map((g) => DropdownMenuItem(value: g['id'] as String, child: Text(g['title'] as String))),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(state.translate('cancel_btn')),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = _taskTitleController.text.trim();
                    if (title.isNotEmpty) {
                      final subtitle = "Aujourd'hui • $selectedPriority";
                      state.addTask(
                        title, 
                        subtitle, 
                        selectedCategory,
                        priority: selectedPriority,
                        urgency: selectedUrgency,
                        difficulty: selectedDifficulty,
                        estimatedTime: selectedDuration,
                        energyNeeded: selectedEnergy,
                        linkedGoalId: selectedGoalId,
                      );
                      _taskTitleController.clear();
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563eb),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.check_box, color: Color(0xff2563eb)),
            const SizedBox(width: 8),
            Text(
              state.translate('tasks_title'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xff2563eb), size: 30),
            onPressed: () => _showAddTaskDialog(context, state),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: state.tasks.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      state.translate('all_completed'),
                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: state.tasks.length,
                itemBuilder: (context, index) {
                  final task = state.tasks[index];
                  return _buildTaskTile(
                    context,
                    state,
                    task,
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context, state),
        backgroundColor: const Color(0xff2563eb),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskTile(
    BuildContext context,
    AppStateProvider state,
    Map<String, dynamic> task,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final id = task['id'] as String;
    final title = task['title'] as String;
    final subtitle = task['subtitle'] as String;
    final category = task['category'] as String;
    final isCompleted = task['isCompleted'] as bool;
    
    final priority = task['priority'] ?? 'Moyenne';
    final urgency = task['urgency'] ?? 'Moyenne';
    final difficulty = task['difficulty'] ?? 'Moyen';
    final estimatedTime = task['estimatedTime'] ?? 30;
    final energyNeeded = task['energyNeeded'] ?? 'Moyenne';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Checkbox(
              value: isCompleted,
              activeColor: const Color(0xff2563eb),
              onChanged: (val) {
                state.toggleTask(id);
              },
            ),
            title: Text(
              title,
              style: TextStyle(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: isCompleted
                    ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            subtitle: Text(
              "$subtitle • $category • 🕒 ${estimatedTime}m",
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: () {
                state.deleteTask(id);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 58.0, bottom: 12.0, right: 16.0),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _buildSmallChip("Prio : $priority", const Color(0xffef4444)),
                _buildSmallChip("Urgence : $urgency", const Color(0xfff97316)),
                _buildSmallChip("Diff : $difficulty", const Color(0xff8b5cf6)),
                _buildSmallChip("Énergie : $energyNeeded", const Color(0xff22c55e)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSmallChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}
