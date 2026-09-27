import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  void _showAddGoalDialog(BuildContext context, AppStateProvider state, _GoalsStrings s) {
    final titleController = TextEditingController();
    String selectedCategory = 'Personnel';
    final categories = ['Personnel', 'Santé', 'Carrière', 'Apprentissage', 'Finances'];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(s.addGoalTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: s.goalTitleLabel,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(s.categoryLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedCategory = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(s.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isNotEmpty) {
                      state.addGoal(title, selectedCategory);
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563eb),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(s.add),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showUpdateProgressDialog(BuildContext context, AppStateProvider state, Map<String, dynamic> goal, _GoalsStrings s) {
    double currentProg = (goal['progress'] as num?)?.toDouble() ?? 0.0;
    double sliderVal = currentProg;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(s.updateProgressTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(goal['title'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Text('${(sliderVal * 100).toInt()}%', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xff2563eb))),
                  Slider(
                    value: sliderVal,
                    min: 0.0,
                    max: 1.0,
                    divisions: 20,
                    activeColor: const Color(0xff2563eb),
                    onChanged: (val) {
                      setDialogState(() => sliderVal = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(s.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    state.updateGoalProgress(goal['id'].toString(), sliderVal);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563eb),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(s.save),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = state.currentLocale.languageCode;
    final s = _GoalsStrings(lang);

    final List<Map<String, dynamic>> allGoals = state.goals;
    final int totalCount = allGoals.length;
    final int completedCount = allGoals.where((g) => ((g['progress'] as num?)?.toDouble() ?? 0.0) >= 1.0).length;
    final double overallProg = totalCount > 0 ? (completedCount / totalCount) : 0.0;

    // Active vs Completed
    final openGoals = allGoals.where((g) => ((g['progress'] as num?)?.toDouble() ?? 0.0) < 1.0).toList();
    final completedGoals = allGoals.where((g) => ((g['progress'] as num?)?.toDouble() ?? 0.0) >= 1.0).toList();

    // Primary goal: active goal with highest progress > 0, or first open goal
    Map<String, dynamic>? primaryGoal;
    if (openGoals.isNotEmpty) {
      final sorted = List<Map<String, dynamic>>.from(openGoals)
        ..sort((a, b) {
          final progA = (a['progress'] as num?)?.toDouble() ?? 0.0;
          final progB = (b['progress'] as num?)?.toDouble() ?? 0.0;
          return progB.compareTo(progA);
        });
      primaryGoal = sorted.first;
    }

    final otherActiveGoals = openGoals.where((g) => g != primaryGoal).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.flag_rounded, color: Color(0xff2563eb)),
            const SizedBox(width: 10),
            Text(
              s.screenTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xff2563eb)),
            tooltip: s.createGoalTooltip,
            onPressed: () => _showAddGoalDialog(context, state, s),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              children: [
                // 1. CONTEXTE ACTUEL
                _buildContextCard(context, state, isDark, totalCount, completedCount, overallProg, s),
                const SizedBox(height: 16),

                if (allGoals.isEmpty) ...[
                  _buildEmptyState(context, state, isDark, s),
                ] else ...[
                  // 2. OBJECTIF PRINCIPAL / ACTIF
                  if (primaryGoal != null) ...[
                    _buildSectionHeader(context, s.primaryGoalHeader, icon: Icons.star_rounded, color: const Color(0xfff59e0b)),
                    const SizedBox(height: 6),
                    _buildPrimaryGoalCard(context, state, primaryGoal, isDark, s),
                    const SizedBox(height: 16),
                  ],

                  // 3. AUTRES OBJECTIFS ACTIFS
                  if (otherActiveGoals.isNotEmpty) ...[
                    _buildSectionHeader(context, '${s.otherActiveGoalsHeader} (${otherActiveGoals.length})', icon: Icons.trending_up, color: const Color(0xff2563eb)),
                    const SizedBox(height: 6),
                    ...otherActiveGoals.map((g) => _buildGoalCard(context, state, g, isDark, s)),
                    const SizedBox(height: 12),
                  ],

                  // 4. OBJECTIFS TERMINÉS
                  if (completedGoals.isNotEmpty) ...[
                    _buildSectionHeader(context, '${s.completedGoalsHeader} (${completedGoals.length})', icon: Icons.check_circle_outline, color: const Color(0xff22c55e)),
                    const SizedBox(height: 6),
                    ...completedGoals.map((g) => _buildGoalCard(context, state, g, isDark, s)),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- CONTEXTE CARD ---
  Widget _buildContextCard(
    BuildContext context,
    AppStateProvider state,
    bool isDark,
    int totalCount,
    int completedCount,
    double overallProg,
    _GoalsStrings s,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xff2563eb).withValues(alpha: 0.15),
                    radius: 16,
                    child: const Icon(Icons.track_changes_rounded, color: Color(0xff2563eb), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.contextTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        '$totalCount ${s.totalGoalsLabel}',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xff22c55e).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedCount / $totalCount ${s.completedBadge}',
                  style: const TextStyle(
                    color: Color(0xff15803d),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: totalCount > 0 ? overallProg : 0.0,
              backgroundColor: isDark ? const Color(0xff1e293b) : const Color(0xfff1f5f9),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff2563eb)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // --- PRIMARY GOAL CARD ---
  Widget _buildPrimaryGoalCard(
    BuildContext context,
    AppStateProvider state,
    Map<String, dynamic> goal,
    bool isDark,
    _GoalsStrings s,
  ) {
    final String goalId = (goal['id'] ?? '').toString();
    final double progress = (goal['progress'] as num?)?.toDouble() ?? 0.0;
    final String category = (goal['category'] ?? s.defaultCategory).toString();

    // Linked tasks from real data
    final linkedTasks = state.tasks.where((t) => t['linkedGoalId']?.toString() == goalId).toList();
    final completedLinkedTasks = linkedTasks.where((t) => t['isCompleted'] == true).length;

    // Linked missions from real data
    final linkedMissions = state.missions.where((m) {
      final mGoalId = m['linkedGoalId'] ?? m['goalId'];
      return mGoalId?.toString() == goalId;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xff2563eb),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff2563eb).withValues(alpha: isDark ? 0.12 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal['title'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xff2563eb).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(color: Color(0xff2563eb), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                tooltip: s.updateProgressTooltip,
                onPressed: () => _showUpdateProgressDialog(context, state, goal, s),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                tooltip: s.deleteGoalTooltip,
                onPressed: () => state.deleteGoal(goalId),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Real Progress Bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark ? const Color(0xff1e293b) : const Color(0xfff1f5f9),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff2563eb)),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(color: Color(0xff2563eb), fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),

          // Éléments qui font avancer l'objectif (si données réelles existent)
          if (linkedTasks.isNotEmpty || linkedMissions.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Text(s.whatDrivesThisHeader, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
            const SizedBox(height: 6),
            if (linkedTasks.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 14, color: Color(0xff22c55e)),
                  const SizedBox(width: 6),
                  Text(
                    '$completedLinkedTasks / ${linkedTasks.length} ${s.linkedTasksDone}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
            if (linkedMissions.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.flag_outlined, size: 14, color: Color(0xff8b5cf6)),
                  const SizedBox(width: 6),
                  Text(
                    '${linkedMissions.length} ${s.linkedMissionsLabel}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ],

          const SizedBox(height: 14),
          // Action button: Toggle progress / Mark completed
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (progress >= 1.0) {
                  state.updateGoalProgress(goalId, 0.0);
                } else {
                  state.updateGoalProgress(goalId, 1.0);
                }
              },
              icon: Icon(progress >= 1.0 ? Icons.replay : Icons.check_circle_outline, size: 16),
              label: Text(
                progress >= 1.0 ? s.resetGoalAction : s.markGoalCompletedAction,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: progress >= 1.0 ? Colors.grey.shade600 : const Color(0xff2563eb),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- REGULAR GOAL CARD ---
  Widget _buildGoalCard(
    BuildContext context,
    AppStateProvider state,
    Map<String, dynamic> goal,
    bool isDark,
    _GoalsStrings s,
  ) {
    final String goalId = (goal['id'] ?? '').toString();
    final double progress = (goal['progress'] as num?)?.toDouble() ?? 0.0;
    final bool isCompleted = progress >= 1.0;
    final String category = (goal['category'] ?? s.defaultCategory).toString();

    // Linked tasks from real data
    final linkedTasks = state.tasks.where((t) => t['linkedGoalId']?.toString() == goalId).toList();
    final completedLinkedTasks = linkedTasks.where((t) => t['isCompleted'] == true).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isCompleted ? const Color(0xff22c55e) : Colors.grey,
                  size: 22,
                ),
                onPressed: () {
                  state.updateGoalProgress(goalId, isCompleted ? 0.0 : 1.0);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  goal['title'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xff2563eb).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category,
                  style: const TextStyle(color: Color(0xff2563eb), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.grey, size: 18),
                onPressed: () => _showUpdateProgressDialog(context, state, goal, s),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 18),
                onPressed: () => state.deleteGoal(goalId),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark ? const Color(0xff1e293b) : const Color(0xfff1f5f9),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? const Color(0xff22c55e) : const Color(0xff2563eb),
                    ),
                    minHeight: 5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: isCompleted ? const Color(0xff22c55e) : const Color(0xff2563eb),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          if (linkedTasks.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '$completedLinkedTasks / ${linkedTasks.length} ${s.linkedTasksDone}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  // --- EMPTY STATE ---
  Widget _buildEmptyState(BuildContext context, AppStateProvider state, bool isDark, _GoalsStrings s) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.flag_outlined, size: 44, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            s.noGoalsTitle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            s.noGoalsSubtitle,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddGoalDialog(context, state, s),
            icon: const Icon(Icons.add, size: 16),
            label: Text(s.createGoalAction, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff2563eb),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {required IconData icon, required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalsStrings {
  final String lang;
  _GoalsStrings(this.lang);

  String get screenTitle => lang == 'en' ? 'Goals' : (lang == 'es' ? 'Objetivos' : 'Objectifs');
  String get createGoalTooltip => lang == 'en' ? 'Create goal' : (lang == 'es' ? 'Crear objetivo' : 'Créer un objectif');
  String get addGoalTitle => lang == 'en' ? 'Create a Goal' : (lang == 'es' ? 'Crear un Objetivo' : 'Créer un Objectif');
  String get goalTitleLabel => lang == 'en' ? 'Goal title' : (lang == 'es' ? 'Título del objetivo' : "Titre de l'objectif");
  String get categoryLabel => lang == 'en' ? 'Category' : (lang == 'es' ? 'Categoría' : 'Catégorie');
  String get cancel => lang == 'en' ? 'Cancel' : (lang == 'es' ? 'Cancelar' : 'Annuler');
  String get add => lang == 'en' ? 'Add' : (lang == 'es' ? 'Añadir' : 'Ajouter');
  String get save => lang == 'en' ? 'Save' : (lang == 'es' ? 'Guardar' : 'Enregistrer');
  String get updateProgressTitle => lang == 'en' ? 'Update Progress' : (lang == 'es' ? 'Actualizar Progreso' : 'Mettre à jour la progression');
  String get updateProgressTooltip => lang == 'en' ? 'Update progress' : (lang == 'es' ? 'Actualizar progreso' : 'Ajuster la progression');
  String get deleteGoalTooltip => lang == 'en' ? 'Delete' : (lang == 'es' ? 'Eliminar' : 'Supprimer');
  String get defaultCategory => lang == 'en' ? 'General' : (lang == 'es' ? 'General' : 'Général');
  String get contextTitle => lang == 'en' ? 'Active Intentions' : (lang == 'es' ? 'Intenciones Activas' : 'Intentions Actives');
  String get totalGoalsLabel => lang == 'en' ? 'goals in total' : (lang == 'es' ? 'objetivos en total' : 'objectifs au total');
  String get completedBadge => lang == 'en' ? 'completed' : (lang == 'es' ? 'completados' : 'terminés');
  String get primaryGoalHeader => lang == 'en' ? 'Primary Goal' : (lang == 'es' ? 'Objetivo Principal' : 'Objectif Principal');
  String get otherActiveGoalsHeader => lang == 'en' ? 'Other Active Goals' : (lang == 'es' ? 'Otros Objetivos Activos' : 'Autres Objectifs Actifs');
  String get completedGoalsHeader => lang == 'en' ? 'Completed Goals' : (lang == 'es' ? 'Objetivos Cumplidos' : 'Objectifs Terminés');
  String get whatDrivesThisHeader => lang == 'en' ? 'WHAT DRIVES THIS GOAL' : (lang == 'es' ? 'LO QUE IMPULSA ESTE OBJETIVO' : 'CE QUI FAIT AVANCER CET OBJECTIF');
  String get linkedTasksDone => lang == 'en' ? 'tasks completed' : (lang == 'es' ? 'tareas completadas' : 'tâches terminées');
  String get linkedMissionsLabel => lang == 'en' ? 'linked mission(s)' : (lang == 'es' ? 'misión(es) vinculada(s)' : 'mission(s) liée(s)');
  String get markGoalCompletedAction => lang == 'en' ? 'Mark as completed' : (lang == 'es' ? 'Marcar como completado' : 'Marquer comme terminé');
  String get resetGoalAction => lang == 'en' ? 'Reopen goal' : (lang == 'es' ? 'Reabrir objetivo' : "Rouvrir l'objectif");
  String get noGoalsTitle => lang == 'en' ? 'No active goals.' : (lang == 'es' ? 'No hay objetivos activos.' : 'Aucun objectif actif.');
  String get noGoalsSubtitle => lang == 'en'
      ? 'Define a clear goal to guide your actions and progress.'
      : (lang == 'es'
          ? 'Define un objetivo claro para guiar tus acciones y progreso.'
          : 'Définissez un objectif clair pour guider vos actions et votre progression.');
  String get createGoalAction => lang == 'en' ? 'Create a goal' : (lang == 'es' ? 'Crear un objetivo' : 'Créer un objectif');
}
