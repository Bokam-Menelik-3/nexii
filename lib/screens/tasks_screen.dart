import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double size;
  double angle;
  double rotationSpeed;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.angle,
    required this.rotationSpeed,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      final currentX = p.x + p.vx * progress * 140;
      final currentY =
          p.y + p.vy * progress * 140 + 0.5 * 250 * progress * progress;
      final currentOpacity = (1.0 - progress).clamp(0.0, 1.0);

      paint.color = p.color.withValues(alpha: currentOpacity);

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(p.angle + p.rotationSpeed * progress * 6.28);
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset.zero, width: p.size, height: p.size * 0.6),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => true;
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _taskTitleController = TextEditingController();
  int _selectedTab = 0; // 0: Tâches, 1: Objectifs Vivants

  late AnimationController _confettiController;
  List<ConfettiParticle> _particles = [];
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )
      ..addListener(() {
        if (mounted) setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (mounted) {
            setState(() {
              _showConfetti = false;
            });
          }
        }
      });
  }

  @override
  void dispose() {
    _taskTitleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _triggerTaskCompletionCelebration(Offset position) {
    final random = math.Random();
    final colors = [
      const Color(0xff22c55e),
      const Color(0xff2563eb),
      const Color(0xff8b5cf6),
      const Color(0xffeab308),
      const Color(0xffec4899),
      const Color(0xff06b6d4),
      const Color(0xfff97316),
    ];

    _particles = List.generate(40, (_) {
      final angle = random.nextDouble() * 2 * math.pi;
      final speed = 1.5 + random.nextDouble() * 4.0;
      return ConfettiParticle(
        x: position.dx,
        y: position.dy,
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed - 2.5,
        color: colors[random.nextInt(colors.length)],
        size: 7.0 + random.nextDouble() * 8.0,
        angle: random.nextDouble() * math.pi,
        rotationSpeed: (random.nextDouble() - 0.5) * 5.0,
      );
    });

    _showConfetti = true;
    _confettiController.forward(from: 0.0);
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

    final TextEditingController subtaskInputController =
        TextEditingController();
    final List<String> draftSubtasks = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(state.translate('add_task'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _taskTitleController,
                      decoration: InputDecoration(
                        hintText: state.translate('placeholder_add_task'),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Catégorie',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.grey)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedCategory = val;
                          });
                        }
                      },
                      items: [
                        'Travail',
                        'Bien-être',
                        'Santé',
                        'Finance',
                        'Loisirs'
                      ]
                          .map((cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Priorité',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.grey)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: selectedPriority,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedPriority = val;
                          });
                        }
                      },
                      items: ['Haute', 'Moyenne', 'Basse']
                          .map((prio) =>
                              DropdownMenuItem(value: prio, child: Text(prio)))
                          .toList(),
                    ),

                    const SizedBox(height: 16),
                    // Subtasks in creation dialog
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Sous-tâches',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.grey)),
                        if (draftSubtasks.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xff8b5cf6)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${draftSubtasks.length}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: Color(0xff8b5cf6)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: subtaskInputController,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Ajouter une sous-tâche...',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              isDense: true,
                            ),
                            onSubmitted: (val) {
                              if (val.trim().isNotEmpty) {
                                setDialogState(() {
                                  draftSubtasks.add(val.trim());
                                  subtaskInputController.clear();
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: () {
                            final val = subtaskInputController.text.trim();
                            if (val.isNotEmpty) {
                              setDialogState(() {
                                draftSubtasks.add(val);
                                subtaskInputController.clear();
                              });
                            }
                          },
                          icon: const Icon(Icons.add_circle,
                              color: Color(0xff8b5cf6), size: 26),
                          tooltip: 'Ajouter',
                        ),
                      ],
                    ),
                    if (draftSubtasks.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Column(
                        children: List.generate(draftSubtasks.length, (index) {
                          final st = draftSubtasks[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .cardColor
                                  .withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.grey.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.subdirectory_arrow_right,
                                    size: 14, color: Colors.grey),
                                const SizedBox(width: 6),
                                Expanded(
                                    child: Text(st,
                                        style: const TextStyle(fontSize: 12))),
                                InkWell(
                                  onTap: () {
                                    setDialogState(() {
                                      draftSubtasks.removeAt(index);
                                    });
                                  },
                                  child: const Icon(Icons.close,
                                      size: 16, color: Colors.redAccent),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],

                    const SizedBox(height: 16),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setDialogState(() {
                            showAdvanced = !showAdvanced;
                          });
                        },
                        icon: Icon(
                          showAdvanced
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
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
                      const Text('Urgence',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.grey)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: selectedUrgency,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedUrgency = val;
                            });
                          }
                        },
                        items: ['Haute', 'Moyenne', 'Basse']
                            .map((u) =>
                                DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Difficulté',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.grey)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: selectedDifficulty,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedDifficulty = val;
                            });
                          }
                        },
                        items: ['Facile', 'Moyen', 'Difficile']
                            .map((d) =>
                                DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Temps estimé',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.grey)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        initialValue: selectedDuration,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedDuration = val;
                            });
                          }
                        },
                        items: [10, 15, 30, 45, 60, 90, 120]
                            .map((d) => DropdownMenuItem(
                                value: d, child: Text('$d min')))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Énergie nécessaire',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.grey)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: selectedEnergy,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedEnergy = val;
                            });
                          }
                        },
                        items: ['Basse', 'Moyenne', 'Haute']
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Lier à un objectif',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.grey)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: selectedGoalId,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedGoalId = val;
                            });
                          }
                        },
                        items: [
                          const DropdownMenuItem(
                              value: '', child: Text('Aucun')),
                          ...state.goals.map((g) => DropdownMenuItem(
                              value: g['id'] as String,
                              child: Text(g['title'] as String))),
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
                      final formattedSubtasks = draftSubtasks
                          .map((stTitle) => {
                                'id': DateTime.now()
                                        .microsecondsSinceEpoch
                                        .toString() +
                                    '_' +
                                    math.Random().nextInt(1000).toString(),
                                'title': stTitle,
                                'isCompleted': false,
                              })
                          .toList();

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
                        subtasks: formattedSubtasks,
                      );
                      _taskTitleController.clear();
                      subtaskInputController.dispose();
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563eb),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
          state.isGeneratingAiTasks
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xff8b5cf6)),
                  ),
                )
              : IconButton(
                  tooltip: "Générer des missions avec l'IA Gemini",
                  icon: const Icon(Icons.auto_awesome,
                      color: Color(0xff8b5cf6), size: 26),
                  onPressed: () {
                    state.generateAiTasksFromBackend();
                  },
                ),
          IconButton(
            icon: const Icon(Icons.add_circle,
                color: Color(0xff2563eb), size: 30),
            onPressed: () {
              if (_selectedTab == 0) {
                _showAddTaskDialog(context, state);
              } else {
                _showAddGoalDialog(context, state);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Realtime sync banner
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: const Color(0xff22c55e).withValues(alpha: 0.08),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xff22c55e),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Firestore Base de Données • Synchronisé en temps réel",
                        style: TextStyle(
                          color: Color(0xff15803d),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Top Segmented Tab Switcher (Tâches vs Objectifs Vivants)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: _selectedTab == 0
                                    ? const Color(0xff2563eb)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_box_outlined,
                                      size: 16,
                                      color: _selectedTab == 0
                                          ? Colors.white
                                          : Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Tâches (${state.tasks.length})',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: _selectedTab == 0
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: _selectedTab == 1
                                    ? const Color(0xff10b981)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.center_focus_strong,
                                      size: 16,
                                      color: _selectedTab == 1
                                          ? Colors.white
                                          : Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Objectifs (${state.livingGoals.length})',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: _selectedTab == 1
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Content View
                Expanded(
                  child: _selectedTab == 0
                      ? (state.tasks.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.assignment_turned_in_outlined,
                                      size: 64, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  Text(
                                    state.translate('all_completed'),
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              itemCount: state.tasks.length,
                              itemBuilder: (context, index) {
                                final task = state.tasks[index];
                                return _buildTaskTile(
                                  context,
                                  state,
                                  task,
                                );
                              },
                            ))
                      : _buildLivingGoalsView(context, state),
                ),
              ],
            ),
          ),
          if (_showConfetti)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: ConfettiPainter(
                    particles: _particles,
                    progress: _confettiController.value,
                  ),
                ),
              ),
            ),
        ],
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

    final List subtasks = List.from(task['subtasks'] ?? []);
    final int totalSubtasks = subtasks.length;
    final int completedSubtasks =
        subtasks.where((st) => st['isCompleted'] == true).length;

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
          Builder(
            builder: (tileContext) {
              return ListTile(
                leading: Transform.scale(
                  scale: isCompleted ? 1.15 : 1.0,
                  child: Checkbox(
                    value: isCompleted,
                    activeColor: const Color(0xff22c55e),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    onChanged: (val) {
                      if (val == true) {
                        RenderBox? box =
                            tileContext.findRenderObject() as RenderBox?;
                        Offset pos = const Offset(200, 300);
                        if (box != null) {
                          pos = box
                              .localToGlobal(Offset(30, box.size.height / 2));
                        }
                        _triggerTaskCompletionCelebration(pos);

                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.stars,
                                    color: Color(0xffeab308), size: 22),
                                SizedBox(width: 10),
                                Text(
                                  'Tâche accomplie ! Bravo ! 🎉',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xff0f172a),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                      state.toggleTask(id);
                    },
                  ),
                ),
                title: Text(
                  title,
                  style: TextStyle(
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: isCompleted
                        ? Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: 0.5)
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                subtitle: Text(
                  "$subtitle • $category • 🕒 ${estimatedTime}m",
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 20),
                  onPressed: () {
                    state.deleteTask(id);
                  },
                ),
              );
            },
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 58.0, bottom: 8.0, right: 16.0),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _buildSmallChip("Prio : $priority", const Color(0xffef4444)),
                _buildSmallChip("Urgence : $urgency", const Color(0xfff97316)),
                _buildSmallChip("Diff : $difficulty", const Color(0xff8b5cf6)),
                _buildSmallChip(
                    "Énergie : $energyNeeded", const Color(0xff22c55e)),
                if (totalSubtasks > 0)
                  _buildSmallChip(
                      "Sous-tâches : $completedSubtasks/$totalSubtasks",
                      const Color(0xff2563eb)),
              ],
            ),
          ),
          if (!isCompleted)
            Padding(
              padding:
                  const EdgeInsets.only(left: 58.0, bottom: 8.0, right: 16.0),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: const BorderSide(color: Color(0xff8b5cf6), width: 0.8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon:
                    const Icon(Icons.bolt, size: 14, color: Color(0xff8b5cf6)),
                label: const Text(
                    '⚡ Micro-actions 2 min (Anti-Procrastination)',
                    style: TextStyle(
                        fontSize: 11,
                        color: Color(0xff8b5cf6),
                        fontWeight: FontWeight.bold)),
                onPressed: () => state.decomposeTaskToMicroActions(id),
              ),
            ),
          // Subtasks list and inline add
          Padding(
            padding:
                const EdgeInsets.only(left: 58.0, bottom: 12.0, right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtasks.isNotEmpty) ...[
                  const Divider(height: 12, thickness: 0.5),
                  ...subtasks.map((st) {
                    final stMap = Map<String, dynamic>.from(st as Map);
                    final stId = stMap['id'] as String;
                    final stTitle = stMap['title'] as String;
                    final stCompleted = stMap['isCompleted'] == true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xff1e293b)
                            : const Color(0xfff8fafc),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: Checkbox(
                              value: stCompleted,
                              activeColor: const Color(0xff8b5cf6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              onChanged: (_) {
                                state.toggleSubTask(id, stId);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              stTitle,
                              style: TextStyle(
                                fontSize: 12,
                                decoration: stCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: stCompleted
                                    ? Colors.grey
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              state.deleteSubTask(id, stId);
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(Icons.close,
                                  size: 14, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 4),
                _InlineAddSubtaskWidget(
                  onAdd: (subtaskTitle) {
                    state.addSubTask(id, subtaskTitle);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context, AppStateProvider state) {
    final TextEditingController goalTitleController = TextEditingController();
    final TextEditingController goalDeadlineController =
        TextEditingController();
    String selectedImportance = 'Haute';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Text('🎯', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text('Créer un Objectif Vivant',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: goalTitleController,
                      decoration: InputDecoration(
                        labelText: 'Intitulé de l\'objectif',
                        hintText: 'Ex: Examen Flutter, Lancement Produit...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: goalDeadlineController,
                      decoration: InputDecoration(
                        labelText: 'Échéance / Date limite',
                        hintText: 'Ex: 15 jours, 1er Septembre...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Niveau d\'importance',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedImportance,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      items: ['Haute (Priorité 1)', 'Stratégique', 'Moyenne']
                          .map((imp) =>
                              DropdownMenuItem(value: imp, child: Text(imp)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null)
                          setDialogState(() => selectedImportance = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff10b981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final title = goalTitleController.text.trim();
                    if (title.isNotEmpty) {
                      state.addLivingGoal(
                        title,
                        goalDeadlineController.text.trim(),
                        selectedImportance,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Créer l\'Objet'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLivingGoalsView(BuildContext context, AppStateProvider state) {
    final goals = state.livingGoals;

    if (goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.center_focus_weak, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Aucun Objectif Vivant actif',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff10b981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Créer mon premier Objectif Vivant'),
              onPressed: () => _showAddGoalDialog(context, state),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: goals.length + 1,
      itemBuilder: (context, index) {
        if (index == goals.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xff10b981),
                side: const BorderSide(color: Color(0xff10b981)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text('Créer un autre Objectif Vivant',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () => _showAddGoalDialog(context, state),
            ),
          );
        }

        final goal = goals[index];
        final completion = goal['completion'] as int;
        final probability = goal['successProbability'] as int;

        return Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          padding: const EdgeInsets.all(18.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color(0xff10b981).withValues(alpha: 0.3),
                width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      goal['title'] as String,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xff10b981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Probabilité : $probability%',
                      style: const TextStyle(
                          color: Color(0xff059669),
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              Row(
                children: [
                  const Icon(Icons.event, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Échéance : ${goal['deadline']}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 12),
                  const Icon(Icons.flag_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${goal['importance']}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 14),

              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progression : $completion%',
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold)),
                      Text('${goal['autoAdjustCount']} réajustements IA',
                          style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xff10b981),
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: completion / 100.0,
                      minHeight: 8,
                      backgroundColor:
                          const Color(0xff10b981).withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xff10b981)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Live state message
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xff10b981).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome,
                        size: 16, color: Color(0xff10b981)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        goal['liveStateMessage'] as String,
                        style: const TextStyle(fontSize: 11, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Dependent tasks
              const Text('Tâches dépendantes :',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 6),
              Column(
                children: (goal['dependentTasks'] as List<String>).map((t) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            size: 13, color: Color(0xff10b981)),
                        const SizedBox(width: 6),
                        Expanded(
                            child:
                                Text(t, style: const TextStyle(fontSize: 11))),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Actions
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff10b981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.bolt, size: 16),
                  label: const Text('Auto-Optimiser le Planning ⚡',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () => state
                      .triggerLivingGoalAutoOptimization(goal['id'] as String),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InlineAddSubtaskWidget extends StatefulWidget {
  final Function(String) onAdd;
  const _InlineAddSubtaskWidget({required this.onAdd});

  @override
  State<_InlineAddSubtaskWidget> createState() =>
      _InlineAddSubtaskWidgetState();
}

class _InlineAddSubtaskWidgetState extends State<_InlineAddSubtaskWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _isEditing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onAdd(text);
      _controller.clear();
      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isEditing) {
      return InkWell(
        onTap: () {
          setState(() {
            _isEditing = true;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.add_circle_outline,
                  size: 14, color: Color(0xff8b5cf6)),
              SizedBox(width: 4),
              Text(
                'Ajouter une sous-tâche',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff8b5cf6)),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 32,
            child: TextField(
              controller: _controller,
              autofocus: true,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Intitulé de la sous-tâche...',
                hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                isDense: true,
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.check_circle,
              color: Color(0xff8b5cf6), size: 22),
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
          onPressed: _submit,
        ),
        const SizedBox(width: 2),
        IconButton(
          icon: const Icon(Icons.cancel_outlined, color: Colors.grey, size: 22),
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
          onPressed: () {
            setState(() {
              _isEditing = false;
              _controller.clear();
            });
          },
        ),
      ],
    );
  }
}
