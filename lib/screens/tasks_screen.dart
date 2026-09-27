import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/nexii_colors.dart';
import '../core/widgets/adaptive_living_widgets.dart';
import '../experience/models/experience_mode.dart';
import '../experience/models/experience_state.dart';
import '../intelligence/models/intelligence_models.dart';
import '../providers/app_state_provider.dart';

// Particle for completion celebration
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
      final currentY = p.y + p.vy * progress * 140 + 0.5 * 250 * progress * progress;
      final currentOpacity = (1.0 - progress).clamp(0.0, 1.0);

      paint.color = p.color.withValues(alpha: currentOpacity);

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(p.angle + p.rotationSpeed * progress * 6.28);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => true;
}

/// Tasks-only presentation configuration derived from the Experience state.
///
/// Same structure as Home's presentation layer: the canonical decision of
/// what matters now comes from [ExperienceState] — Tasks only tunes
/// emphasis. Essential task controls are never hidden by density or mode;
/// only secondary metadata quiets down, so tasks stay accessible in every
/// mode (Recovery included).
class _TasksPresentation {
  const _TasksPresentation({
    required this.secondaryOpacity,
    required this.nowAccentAlpha,
    required this.restAdvice,
  });

  /// Opacity of secondary task metadata (badges, subtitles).
  final double secondaryOpacity;

  /// Accent strength of the canonical "Now" card.
  final double nowAccentAlpha;

  /// True in Recovery: the context bar leads with rest advice coming from
  /// the canonical mode instead of a local battery threshold.
  final bool restAdvice;

  factory _TasksPresentation.from(ExperienceState experience) {
    // Density baseline (ExperienceLayer information density).
    double secondaryOpacity = switch (experience.informationDensity) {
      ExperienceDensity.standard => 1.0,
      ExperienceDensity.reduced => 0.68,
      ExperienceDensity.minimal => 0.42,
    };
    double nowAccentAlpha = 0.6;
    bool restAdvice = false;

    // Mode modifiers refine the density baseline — the same canonical
    // modes Home reacts to: Recovery / Pressure / CheckIn / Priority / Calm.
    // Modes never reorder tasks: ranking stays a canonical N1 decision.
    switch (experience.mode) {
      case ExperienceMode.recovery:
        // Reduce unnecessary pressure without removing anything: gentler
        // emphasis, quieter metadata, rest advice. No guilt, no shaming.
        secondaryOpacity = 0.45;
        nowAccentAlpha = 0.38;
        restAdvice = true;
      case ExperienceMode.pressure:
        // Triage clarity: the canonical Now task leads and competing
        // visual emphasis recedes.
        secondaryOpacity = 0.55;
        nowAccentAlpha = 0.68;
      case ExperienceMode.checkIn:
      case ExperienceMode.priority:
      case ExperienceMode.calm:
        break; // Density baseline only — no extra urgency, no reordering.
    }

    return _TasksPresentation(
      secondaryOpacity: secondaryOpacity.clamp(0.42, 1.0),
      nowAccentAlpha: nowAccentAlpha,
      restAdvice: restAdvice,
    );
  }
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _taskTitleController = TextEditingController();
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

  void _triggerCompletionCelebration(Offset position) {
    final random = math.Random();
    final colors = [
      NexiiColors.success,
      NexiiColors.primary,
      NexiiColors.aiAccent,
      NexiiColors.warning,
      NexiiColors.cyanGlow,
    ];

    _particles = List.generate(35, (_) {
      final angle = random.nextDouble() * 2 * math.pi;
      final speed = 1.5 + random.nextDouble() * 3.5;
      return ConfettiParticle(
        x: position.dx,
        y: position.dy,
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed - 2.5,
        color: colors[random.nextInt(colors.length)],
        size: 6.0 + random.nextDouble() * 7.0,
        angle: random.nextDouble() * math.pi,
        rotationSpeed: (random.nextDouble() - 0.5) * 4.0,
      );
    });

    _showConfetti = true;
    _confettiController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final snapshot = state.currentContextSnapshot;
    final n1 = state.currentN1Summary;
    // Canonical intelligence interpretation — the very same ExperienceState
    // Home consumes. Tasks never re-decides what matters: it presents it.
    final experience = state.currentExperienceState;
    final presentation = _TasksPresentation.from(experience);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = state.currentLocale.languageCode;
    final s = _TasksStrings(lang);

    // Filter tasks from real runtime data
    final allTasks = state.tasks;
    final openTasks = allTasks.where((t) => t['isCompleted'] != true).toList();
    final completedTasks = allTasks.where((t) => t['isCompleted'] == true).toList();

    // 1. "Maintenant" (Now): the canonical task-focused target from
    // ExperienceState — the exact task Home renders as dominant — with the
    // screen's existing fallback when there is no task-focused dominant
    // state (or the target went stale/missing). Tasks adds no ranking of
    // its own: this is a view of one canonical decision.
    Map<String, dynamic>? nowTask;
    bool isCanonicalNow = false;
    final remainingOpenTasks = <Map<String, dynamic>>[];

    if (openTasks.isNotEmpty) {
      final String? canonicalTargetId =
          experience.dominantFocus == ExperienceDominantFocus.primaryTask
              ? experience.primaryAction.targetId
              : null;
      final matchedIndex = canonicalTargetId == null
          ? -1
          : openTasks.indexWhere((t) => t['id']?.toString() == canonicalTargetId);

      if (matchedIndex != -1) {
        // Same target ID as Home's dominant surface.
        nowTask = openTasks[matchedIndex];
        isCanonicalNow = true;
        for (int i = 0; i < openTasks.length; i++) {
          if (i != matchedIndex) remainingOpenTasks.add(openTasks[i]);
        }
      } else {
        // Existing Tasks fallback behavior (no task-focused state, or a
        // stale target): first high-priority task, else the first open one.
        final highPrioIndex =
            openTasks.indexWhere((t) => t['priority'] == 'Haute');
        if (highPrioIndex != -1) {
          nowTask = openTasks[highPrioIndex];
          for (int i = 0; i < openTasks.length; i++) {
            if (i != highPrioIndex) remainingOpenTasks.add(openTasks[i]);
          }
        } else {
          nowTask = openTasks.first;
          remainingOpenTasks.addAll(openTasks.skip(1));
        }
      }
    }

    // 2. "Ensuite" (Next): Medium priority tasks or upcoming
    final ensuiteTasks = remainingOpenTasks.where((t) => t['priority'] != 'Basse').toList();

    // 3. "Plus tard" (Later): Low priority tasks
    final plusTardTasks = remainingOpenTasks.where((t) => t['priority'] == 'Basse').toList();

    return Scaffold(
      backgroundColor: isDark ? NexiiColors.deepBackground : NexiiColors.lightBackground,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: NexiiColors.primary, size: 22),
            const SizedBox(width: NexiiSpacing.sm),
            Text(
              s.screenTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? NexiiColors.deepTextPrimary : NexiiColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: s.addTaskBtn,
            icon: const Icon(Icons.add_circle, color: NexiiColors.primary, size: 26),
            onPressed: () => _showAddTaskDialog(context, state),
          ),
          const SizedBox(width: NexiiSpacing.sm),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth >= 768;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isTablet ? 900 : 600),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: NexiiSpacing.lg,
                        vertical: NexiiSpacing.sm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Contexte actuel
                          _buildCurrentContextBar(context, state, snapshot, openTasks.length, presentation, s, isDark),
                          const SizedBox(height: NexiiSpacing.lg),

                          // If no tasks at all
                          if (allTasks.isEmpty)
                            _buildEmptyState(context, state, s, isDark)
                          // If all tasks completed
                          else if (openTasks.isEmpty)
                            _buildAllDoneState(context, state, completedTasks, presentation, s, isDark)
                          else ...[
                            // 2. Section "Maintenant" (Now)
                            if (nowTask != null) ...[
                              _buildSectionHeader(s.sectionNow, NexiiColors.primary, Icons.play_arrow_rounded, isDark),
                              const SizedBox(height: NexiiSpacing.sm),
                              _buildNowTaskCard(context, state, nowTask, n1, presentation, isCanonicalNow, s, isDark),
                              const SizedBox(height: NexiiSpacing.xl),
                            ],

                            // 3. Section "Ensuite" (Next)
                            if (ensuiteTasks.isNotEmpty) ...[
                              _buildSectionHeader(s.sectionNext, NexiiColors.aiAccent, Icons.redo_rounded, isDark),
                              const SizedBox(height: NexiiSpacing.sm),
                              ...ensuiteTasks.map((t) => _buildStandardTaskTile(context, state, t, presentation, s, isDark)),
                              const SizedBox(height: NexiiSpacing.lg),
                            ],

                            // 4. Section "Plus tard" (Later)
                            if (plusTardTasks.isNotEmpty) ...[
                              _buildSectionHeader(s.sectionLater, isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary, Icons.schedule, isDark),
                              const SizedBox(height: NexiiSpacing.sm),
                              ...plusTardTasks.map((t) => _buildStandardTaskTile(context, state, t, presentation, s, isDark)),
                              const SizedBox(height: NexiiSpacing.lg),
                            ],

                            // 5. Completed tasks (if any)
                            if (completedTasks.isNotEmpty) ...[
                              _buildCompletedSection(context, state, completedTasks, presentation, s, isDark),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
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
        backgroundColor: NexiiColors.primary,
        foregroundColor: Colors.white,
        tooltip: s.addTaskBtn,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Contexte Actuel
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildCurrentContextBar(
    BuildContext context,
    AppStateProvider state,
    ContextSnapshot snapshot,
    int openCount,
    _TasksPresentation presentation,
    _TasksStrings s,
    bool isDark,
  ) {
    final battery = state.mentalBattery;
    // Low battery reads as "protective" (warning), never alarming (error) —
    // same convention as Home; the displayed number carries the precision.
    final Color batteryColor =
        battery >= 65 ? NexiiColors.success : NexiiColors.warning;

    // Advice follows the canonical Experience mode (Recovery reads as rest)
    // instead of a local battery threshold duplicated from intelligence.
    String energyAdvice;
    if (presentation.restAdvice) {
      energyAdvice = s.lowEnergyAdvice;
    } else if (battery >= 70) {
      energyAdvice = s.highEnergyAdvice;
    } else {
      energyAdvice = s.normalEnergyAdvice;
    }

    return AdaptiveSurface(
      tier: SurfaceTier.secondary,
      padding: const EdgeInsets.symmetric(horizontal: NexiiSpacing.lg, vertical: NexiiSpacing.md),
      child: Row(
        children: [
          Icon(Icons.bolt, color: batteryColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${s.mentalBattery} $battery%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: batteryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: NexiiColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(NexiiRadii.sm),
                      ),
                      child: Text(
                        '$openCount ${s.openTasks}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: NexiiColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  energyAdvice,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Section Headers
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, Color color, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Maintenant (Now) — Dominant Card
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildNowTaskCard(
    BuildContext context,
    AppStateProvider state,
    Map<String, dynamic> task,
    N1Summary n1,
    _TasksPresentation presentation,
    bool isCanonicalNow,
    _TasksStrings s,
    bool isDark,
  ) {
    final id = task['id']?.toString() ?? '';
    final title = task['title']?.toString() ?? '';
    final subtitle = task['subtitle']?.toString() ?? '';
    final category = task['category']?.toString() ?? '';
    final priority = task['priority']?.toString() ?? 'Haute';
    final urgency = task['urgency']?.toString();
    final difficulty = task['difficulty']?.toString();
    final estimatedTime = task['estimatedTime'] ?? 30;
    final energyNeeded = task['energyNeeded']?.toString();
    final linkedGoalId = task['linkedGoalId']?.toString() ?? '';

    // Real linked goal if any
    Map<String, dynamic>? linkedGoal;
    if (linkedGoalId.isNotEmpty) {
      final matches = state.goals.where((g) => g['id'] == linkedGoalId);
      if (matches.isNotEmpty) linkedGoal = matches.first;
    }

    final subtasks = List.from(task['subtasks'] ?? []);
    final int completedSubtasks = subtasks.where((st) => st['isCompleted'] == true).length;

    // Why this task: canonical intelligence first. When this is the
    // canonical dominant task (same target Home shows), N1 already explains
    // the choice — show that human reason instead of rebuilding one from
    // raw task fields. The field-based explanation remains for the
    // fallback card, where no canonical reason targets this task.
    // No internal scores or node terminology are ever exposed.
    final whyParts = <String>[];
    if (isCanonicalNow && n1.primaryReason.isNotEmpty) {
      whyParts.add(n1.primaryReason);
    } else {
      if (priority == 'Haute') whyParts.add(s.whyHighPriority);
      if (urgency == 'Haute') whyParts.add(s.whyUrgent);
      if (linkedGoal != null) {
        whyParts.add('${s.whyLinkedGoal} "${linkedGoal['title']}"');
      }
      if (whyParts.isEmpty && n1.primaryReason.isNotEmpty) {
        whyParts.add(n1.primaryReason);
      }
    }

    return AdaptiveSurface(
      tier: SurfaceTier.dominant,
      customAccent: NexiiColors.primary.withValues(alpha: presentation.nowAccentAlpha),
      padding: const EdgeInsets.all(NexiiSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Checkbox + Title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(
                builder: (cbContext) {
                  return InkWell(
                    onTap: () {
                      RenderBox? box = cbContext.findRenderObject() as RenderBox?;
                      Offset pos = const Offset(150, 300);
                      if (box != null) {
                        pos = box.localToGlobal(Offset(15, box.size.height / 2));
                      }
                      _triggerCompletionCelebration(pos);
                      _showCompletionSnackBar(context, s);
                      state.toggleTask(id);
                    },
                    borderRadius: BorderRadius.circular(NexiiRadii.sm),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: NexiiColors.primary, width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.check, size: 16, color: Colors.transparent),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: NexiiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? NexiiColors.deepTextPrimary : NexiiColors.lightTextPrimary,
                            height: 1.25,
                          ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                tooltip: s.deleteTooltip,
                onPressed: () => state.deleteTask(id),
              ),
            ],
          ),
          const SizedBox(height: NexiiSpacing.md),

          // Real context tags — quieter under reduced density / Recovery,
          // never removed (badges stay visible and tappable).
          Opacity(
            opacity: presentation.secondaryOpacity,
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _buildContextBadge(priority, NexiiColors.error),
                if (urgency != null && urgency.isNotEmpty) _buildContextBadge(urgency, NexiiColors.warning),
                if (difficulty != null && difficulty.isNotEmpty) _buildContextBadge(difficulty, NexiiColors.aiAccent),
                _buildContextBadge('${estimatedTime}m', NexiiColors.primary),
                if (energyNeeded != null && energyNeeded.isNotEmpty) _buildContextBadge(energyNeeded, NexiiColors.success),
                if (category.isNotEmpty) _buildContextBadge(category, isDark ? NexiiColors.deepSurfaceSecondary : NexiiColors.lightSurfaceSecondary, textColor: isDark ? NexiiColors.deepTextPrimary : NexiiColors.lightTextPrimary),
              ],
            ),
          ),

          // Linked Goal tag if real
          if (linkedGoal != null) ...[
            const SizedBox(height: NexiiSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: NexiiColors.aiAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(NexiiRadii.sm),
                border: Border.all(color: NexiiColors.aiAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.track_changes, size: 12, color: NexiiColors.aiAccent),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${s.linkedGoalPrefix} ${linkedGoal['title']}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: NexiiColors.aiAccent),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // "Pourquoi cette tâche ?" (Why this task?) based strictly on real data
          if (whyParts.isNotEmpty) ...[
            const SizedBox(height: NexiiSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(NexiiRadii.md),
                border: Border.all(color: isDark ? NexiiColors.deepBorder : NexiiColors.lightBorder, width: 0.8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, size: 14, color: NexiiColors.aiAccent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.whyNow,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: NexiiColors.aiAccent),
                        ),
                        Text(
                          whyParts.join(' • '),
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Subtasks (if any)
          if (subtasks.isNotEmpty) ...[
            const SizedBox(height: NexiiSpacing.md),
            Text(
              '${s.subtasksLabel} ($completedSubtasks/${subtasks.length})',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 4),
            ...subtasks.map((st) {
              final subId = st['id']?.toString() ?? '';
              final subTitle = st['title']?.toString() ?? '';
              final subDone = st['isCompleted'] == true;

              return Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: subDone,
                        activeColor: NexiiColors.success,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (_) => state.toggleSubTask(id, subId),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        subTitle,
                        style: TextStyle(
                          fontSize: 12,
                          decoration: subDone ? TextDecoration.lineThrough : null,
                          color: subDone
                              ? (isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary)
                              : (isDark ? NexiiColors.deepTextPrimary : NexiiColors.lightTextPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          const SizedBox(height: NexiiSpacing.lg),

          // Primary Actions: Complete + Focus
          Row(
            children: [
              Expanded(
                flex: 6,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showCompletionSnackBar(context, s);
                    state.toggleTask(id);
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(s.completeBtn, maxLines: 1, overflow: TextOverflow.ellipsis),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NexiiColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: NexiiSpacing.md),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NexiiRadii.lg)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: NexiiSpacing.sm),
              Flexible(
                flex: 4,
                child: OutlinedButton.icon(
                  onPressed: () => state.setTabIndex(2), // Focus space
                  icon: const Icon(Icons.timer_outlined, size: 18),
                  label: Text(s.focusBtn, maxLines: 1, overflow: TextOverflow.ellipsis),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: NexiiColors.primary,
                    side: const BorderSide(color: NexiiColors.primary),
                    padding: const EdgeInsets.symmetric(horizontal: NexiiSpacing.sm, vertical: NexiiSpacing.md),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NexiiRadii.lg)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Ensuite & Plus Tard — Standard Task Tile
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildStandardTaskTile(
    BuildContext context,
    AppStateProvider state,
    Map<String, dynamic> task,
    _TasksPresentation presentation,
    _TasksStrings s,
    bool isDark,
  ) {
    final id = task['id']?.toString() ?? '';
    final title = task['title']?.toString() ?? '';
    final subtitle = task['subtitle']?.toString() ?? '';
    final category = task['category']?.toString() ?? '';
    final priority = task['priority']?.toString() ?? 'Moyenne';
    final estimatedTime = task['estimatedTime'] ?? 30;
    final isCompleted = task['isCompleted'] == true;

    return AdaptiveSurface(
      tier: SurfaceTier.secondary,
      padding: const EdgeInsets.all(NexiiSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Builder(
            builder: (cbContext) {
              return Transform.scale(
                scale: 1.1,
                child: Checkbox(
                  value: isCompleted,
                  activeColor: NexiiColors.success,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  onChanged: (val) {
                    if (val == true) {
                      RenderBox? box = cbContext.findRenderObject() as RenderBox?;
                      Offset pos = const Offset(150, 300);
                      if (box != null) {
                        pos = box.localToGlobal(Offset(15, box.size.height / 2));
                      }
                      _triggerCompletionCelebration(pos);
                      _showCompletionSnackBar(context, s);
                    }
                    state.toggleTask(id);
                  },
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted
                        ? (isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary)
                        : (isDark ? NexiiColors.deepTextPrimary : NexiiColors.lightTextPrimary),
                  ),
                ),
                const SizedBox(height: 2),
                // Secondary metadata — quiets down with density/mode while
                // title, checkbox and delete stay fully prominent.
                Opacity(
                  opacity: presentation.secondaryOpacity,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (category.isNotEmpty)
                        Text(
                          category,
                          style: TextStyle(fontSize: 11, color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary),
                        ),
                      Text(
                        '• 🕒 ${estimatedTime}m',
                        style: TextStyle(fontSize: 11, color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary),
                      ),
                      if (priority == 'Haute')
                        _buildContextBadge(priority, NexiiColors.error)
                      else if (priority == 'Basse')
                        _buildContextBadge(priority, Colors.grey),
                    ],
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Opacity(
                    opacity: presentation.secondaryOpacity,
                    child: Text(
                      subtitle,
                      style: TextStyle(fontSize: 11, color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
            tooltip: s.deleteTooltip,
            onPressed: () => state.deleteTask(id),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Completed Section
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildCompletedSection(
    BuildContext context,
    AppStateProvider state,
    List<Map<String, dynamic>> completedTasks,
    _TasksPresentation presentation,
    _TasksStrings s,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          '${s.sectionCompleted} (${completedTasks.length})',
          isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary,
          Icons.done_all,
          isDark,
        ),
        const SizedBox(height: NexiiSpacing.sm),
        ...completedTasks.map((t) => _buildStandardTaskTile(context, state, t, presentation, s, isDark)),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Empty & All Done States
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context, AppStateProvider state, _TasksStrings s, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: NexiiSpacing.xxxl),
        child: Column(
          children: [
            Icon(Icons.assignment_outlined, size: 56, color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary),
            const SizedBox(height: NexiiSpacing.md),
            Text(
              s.emptyTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? NexiiColors.deepTextPrimary : NexiiColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              s.emptySubtitle,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: NexiiSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => _showAddTaskDialog(context, state),
              icon: const Icon(Icons.add, size: 18),
              label: Text(s.addTaskBtn),
              style: ElevatedButton.styleFrom(
                backgroundColor: NexiiColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NexiiRadii.lg)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllDoneState(
    BuildContext context,
    AppStateProvider state,
    List<Map<String, dynamic>> completedTasks,
    _TasksPresentation presentation,
    _TasksStrings s,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdaptiveSurface(
          tier: SurfaceTier.secondary,
          padding: const EdgeInsets.all(NexiiSpacing.xl),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.celebration_outlined, size: 48, color: NexiiColors.success),
                const SizedBox(height: NexiiSpacing.md),
                Text(
                  s.allDoneTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? NexiiColors.deepTextPrimary : NexiiColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  s.allDoneSubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        if (completedTasks.isNotEmpty) ...[
          const SizedBox(height: NexiiSpacing.lg),
          _buildCompletedSection(context, state, completedTasks, presentation, s, isDark),
        ],
      ],
    );
  }

  Widget _buildContextBadge(String label, Color color, {Color textColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(NexiiRadii.sm),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  void _showCompletionSnackBar(BuildContext context, _TasksStrings s) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          s.celebrationMsg,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
        ),
        backgroundColor: NexiiColors.deepElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NexiiRadii.md)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Add Task Dialog
  // ──────────────────────────────────────────────────────────────────────────
  void _showAddTaskDialog(BuildContext context, AppStateProvider state) {
    String selectedCategory = 'Travail';
    String selectedPriority = 'Haute';
    String selectedUrgency = 'Haute';
    String selectedDifficulty = 'Moyen';
    int selectedDuration = 30;
    String selectedEnergy = 'Moyenne';
    String selectedGoalId = '';

    final TextEditingController titleCtrl = TextEditingController();
    final TextEditingController subtitleCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NexiiRadii.xxl)),
              title: Text(
                state.translate('add_task'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        hintText: state.translate('placeholder_add_task'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(NexiiRadii.md)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: subtitleCtrl,
                      decoration: InputDecoration(
                        hintText: 'Sous-titre / détails (optionnel)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(NexiiRadii.md)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedPriority,
                            decoration: InputDecoration(
                              labelText: 'Priorité',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(NexiiRadii.md)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            ),
                            items: ['Haute', 'Moyenne', 'Basse']
                                .map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 12))))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setDialogState(() => selectedPriority = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedCategory,
                            decoration: InputDecoration(
                              labelText: 'Catégorie',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(NexiiRadii.md)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            ),
                            items: ['Travail', 'Bien-être', 'Santé', 'Finance', 'Personnel']
                                .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12))))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setDialogState(() => selectedCategory = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    if (state.goals.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedGoalId,
                        decoration: InputDecoration(
                          labelText: 'Objectif lié (optionnel)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(NexiiRadii.md)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        items: [
                          const DropdownMenuItem(value: '', child: Text('Aucun', style: TextStyle(fontSize: 12))),
                          ...state.goals.map((g) => DropdownMenuItem(
                                value: g['id']?.toString() ?? '',
                                child: Text(g['title']?.toString() ?? '', style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                              )),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedGoalId = val);
                        },
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text(state.translate('cancel_btn')),
                ),
                ElevatedButton(
                  onPressed: () {
                    final text = titleCtrl.text.trim();
                    if (text.isNotEmpty) {
                      state.addTask(
                        text,
                        subtitleCtrl.text.trim(),
                        selectedCategory,
                        priority: selectedPriority,
                        urgency: selectedUrgency,
                        difficulty: selectedDifficulty,
                        estimatedTime: selectedDuration,
                        energyNeeded: selectedEnergy,
                        linkedGoalId: selectedGoalId,
                      );
                    }
                    Navigator.pop(dialogCtx);
                  },
                  child: Text(state.translate('onboarding_submit')),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Localization Dictionary for Tasks Screen
// ──────────────────────────────────────────────────────────────────────────
class _TasksStrings {
  final String lang;
  _TasksStrings(this.lang);

  String get screenTitle => lang == 'en' ? 'Living Tasks' : (lang == 'es' ? 'Tareas Vivas' : 'Champ de Tâches');
  String get mentalBattery => lang == 'en' ? 'Energy' : (lang == 'es' ? 'Energía' : 'Énergie');
  String get openTasks => lang == 'en' ? 'active' : (lang == 'es' ? 'activas' : 'actives');
  String get lowEnergyAdvice => lang == 'en' ? 'Low energy: prefer micro-tasks or breaks.' : (lang == 'es' ? 'Baja energía: prefiere microtareas o pausas.' : 'Énergie basse : privilégiez des micro-actions ou du repos.');
  String get highEnergyAdvice => lang == 'en' ? 'High energy: perfect for priority work.' : (lang == 'es' ? 'Alta energía: perfecto para tareas prioritarias.' : 'Haute énergie : moment idéal pour vos priorités.');
  String get normalEnergyAdvice => lang == 'en' ? 'Steady rhythm: tackle tasks sequentially.' : (lang == 'es' ? 'Ritmo constante: avanza tarea a tarea.' : 'Rythme régulier : avancez posément tâche par tâche.');

  String get sectionNow => lang == 'en' ? 'MAINTENANT • NOW' : (lang == 'es' ? 'AHORA' : 'MAINTENANT');
  String get sectionNext => lang == 'en' ? 'ENSUITE • NEXT' : (lang == 'es' ? 'LUEGO' : 'ENSUITE');
  String get sectionLater => lang == 'en' ? 'PLUS TARD • LATER' : (lang == 'es' ? 'MÁS TARDE' : 'PLUS TARD');
  String get sectionCompleted => lang == 'en' ? 'COMPLETED' : (lang == 'es' ? 'COMPLETADAS' : 'TERMINÉES');

  String get whyNow => lang == 'en' ? 'Why now?' : (lang == 'es' ? '¿Por qué ahora?' : 'Pourquoi maintenant ?');
  String get whyHighPriority => lang == 'en' ? 'High priority' : (lang == 'es' ? 'Prioridad alta' : 'Priorité haute');
  String get whyUrgent => lang == 'en' ? 'Immediate urgency' : (lang == 'es' ? 'Urgencia inmediata' : 'Urgence immédiate');
  String get whyLinkedGoal => lang == 'en' ? 'Linked to goal' : (lang == 'es' ? 'Vinculada al objetivo' : 'Liée à l\'objectif');

  String get subtasksLabel => lang == 'en' ? 'Subtasks' : (lang == 'es' ? 'Subtareas' : 'Sous-tâches');
  String get linkedGoalPrefix => lang == 'en' ? 'Goal:' : (lang == 'es' ? 'Objetivo:' : 'Objectif :');

  String get completeBtn => lang == 'en' ? 'Complete' : (lang == 'es' ? 'Completar' : 'Terminer');
  String get focusBtn => lang == 'en' ? 'Focus' : (lang == 'es' ? 'Enfoque' : 'Focus');
  String get deleteTooltip => lang == 'en' ? 'Delete' : (lang == 'es' ? 'Eliminar' : 'Supprimer');

  String get emptyTitle => lang == 'en' ? 'No tasks yet' : (lang == 'es' ? 'Sin tareas por ahora' : 'Aucune tâche pour le moment');
  String get emptySubtitle => lang == 'en' ? 'Add your first task to activate your Living Task Field.' : (lang == 'es' ? 'Añade tu primera tarea para activar tu espacio.' : 'Ajoutez votre première tâche pour activer votre Living Task Field.');
  String get allDoneTitle => lang == 'en' ? 'All tasks completed! 🎉' : (lang == 'es' ? '¡Todas las tareas completadas! 🎉' : 'Toutes les tâches sont accomplies ! 🎉');
  String get allDoneSubtitle => lang == 'en' ? 'Take time to recharge or prepare next objectives.' : (lang == 'es' ? 'Tómate un tiempo para recargar o preparar el siguiente paso.' : 'Prenez le temps de vous ressourcer ou de préparer la suite.');
  String get addTaskBtn => lang == 'en' ? 'Add Task' : (lang == 'es' ? 'Añadir Tarea' : 'Ajouter une tâche');
  String get celebrationMsg => lang == 'en' ? 'Task completed! Well done! 🎉' : (lang == 'es' ? '¡Tarea cumplida! ¡Bravo! 🎉' : 'Tâche accomplie ! Bravo ! 🎉');
}
