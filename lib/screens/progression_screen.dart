import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class ProgressionScreen extends StatefulWidget {
  const ProgressionScreen({super.key});

  @override
  State<ProgressionScreen> createState() => _ProgressionScreenState();
}

class _ProgressionScreenState extends State<ProgressionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _glowAnim =
        CurvedAnimation(parent: _glowController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = state.currentLocale.languageCode;
    final s = _Strings(lang);

    // ── DONNÉES RÉELLES ──────────────────────────────────────────────
    final completedTasks =
        state.tasks.where((t) => t['isCompleted'] == true).toList();
    final completedMissions =
        state.missions.where((m) => m['isCompleted'] == true).toList();
    final int streakVal = state.streak;
    final int xpVal = state.xp;
    final int levelVal = state.level;
    final int focusMins = state.focusMinutesTotal;
    final int aura = state.auraScore;
    final Map<String, String> auraInfo = state.auraLevelInfo;
    final int disc = state.disciplineScore;

    final bool hasActivity = xpVal > 0 ||
        focusMins > 0 ||
        completedTasks.isNotEmpty ||
        completedMissions.isNotEmpty ||
        streakVal > 0 ||
        state.goals.isNotEmpty;

    final int xpNeeded = 100 * levelVal;
    final double levelProgress =
        levelVal > 0 ? (xpVal / xpNeeded).clamp(0.0, 1.0) : 0.0;

    final String focusStr = focusMins >= 60
        ? '${focusMins ~/ 60}h${focusMins % 60 > 0 ? " ${focusMins % 60}m" : ""}'
        : '${focusMins}m';

    final int xpRemaining = (xpNeeded - xpVal).clamp(0, xpNeeded);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xff0a0f1a) : const Color(0xfff8faff),
      appBar: _buildAppBar(context, isDark, s),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 740),
            child: ListView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 18.0, vertical: 10.0),
              children: [
                if (!hasActivity) ...[
                  const SizedBox(height: 40),
                  _buildEmptyState(context, s, isDark),
                  const SizedBox(height: 40),
                ] else ...[
                  // ── HERO: CE QUE TU AS CONSTRUIT ──────────────────
                  _buildHeroCard(
                    context,
                    isDark,
                    s,
                    levelVal,
                    xpVal,
                    xpNeeded,
                    xpRemaining,
                    levelProgress,
                    aura,
                    auraInfo,
                  ),
                  const SizedBox(height: 22),

                  // ── PREUVES RÉELLES ────────────────────────────────
                  _buildSectionLabel(s.sectionProofs, isDark),
                  const SizedBox(height: 10),
                  _buildProofsGrid(
                    context,
                    isDark,
                    s,
                    completedTasks.length,
                    state.tasks.length,
                    completedMissions.length,
                    state.missions.length,
                    streakVal,
                    focusStr,
                    disc,
                  ),
                  const SizedBox(height: 22),

                  // ── OBJECTIFS EN TRAJECTOIRE ───────────────────────
                  if (state.goals.isNotEmpty) ...[
                    _buildSectionLabel(s.sectionGoals, isDark),
                    const SizedBox(height: 10),
                    ...state.goals.map(
                      (g) => _buildGoalTile(context, g, state, isDark, s),
                    ),
                    const SizedBox(height: 22),
                  ],

                  // ── MOMENTUM & DIRECTION ───────────────────────────
                  _buildSectionLabel(s.sectionMomentum, isDark),
                  const SizedBox(height: 10),
                  _buildMomentumCard(
                    context,
                    isDark,
                    s,
                    levelVal,
                    xpRemaining,
                    streakVal,
                    completedTasks,
                    completedMissions,
                  ),
                  const SizedBox(height: 28),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── APP BAR ─────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
      BuildContext context, bool isDark, _Strings s) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 18,
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xff2563eb), Color(0xff8b5cf6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff2563eb).withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.trending_up_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            s.screenTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: isDark ? Colors.white : const Color(0xff0f172a),
            ),
          ),
        ],
      ),
    );
  }

  // ── HERO CARD ────────────────────────────────────────────────────────
  Widget _buildHeroCard(
    BuildContext context,
    bool isDark,
    _Strings s,
    int level,
    int xp,
    int xpNeeded,
    int xpRemaining,
    double levelProgress,
    int aura,
    Map<String, String> auraInfo,
  ) {
    const Color blue = Color(0xff2563eb);
    const Color purple = Color(0xff8b5cf6);

    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xff111827) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? const Color(0xff1e293b)
                  : const Color(0xffe8edf8),
            ),
            boxShadow: [
              BoxShadow(
                color: blue.withValues(
                  alpha: isDark
                      ? 0.10 + 0.06 * _glowAnim.value
                      : 0.06 + 0.03 * _glowAnim.value,
                ),
                blurRadius: 28 + 8 * _glowAnim.value,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: purple.withValues(
                  alpha: isDark
                      ? 0.06 + 0.04 * _glowAnim.value
                      : 0.03 + 0.02 * _glowAnim.value,
                ),
                blurRadius: 20,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: child,
        );
      },
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
                      s.heroQuestion,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: const Color(0xff2563eb)
                            .withValues(alpha: isDark ? 0.9 : 0.75),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.levelLabel(level),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        color: isDark ? Colors.white : const Color(0xff0f172a),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$xp / $xpNeeded XP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xff64748b)
                            : const Color(0xff94a3b8),
                      ),
                    ),
                  ],
                ),
              ),
              _buildAuraBadge(aura, auraInfo, isDark),
            ],
          ),
          const SizedBox(height: 18),
          _buildXpBar(levelProgress, xpRemaining, isDark, s),
        ],
      ),
    );
  }

  Widget _buildAuraBadge(
      int aura, Map<String, String> auraInfo, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color:
            const Color(0xff8b5cf6).withValues(alpha: isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xff8b5cf6)
              .withValues(alpha: isDark ? 0.28 : 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(auraInfo['icon'] ?? '✨',
              style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            'Aura $aura',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xff8b5cf6),
            ),
          ),
          if ((auraInfo['title'] ?? '').isNotEmpty)
            Text(
              auraInfo['title']!,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xff94a3b8)
                    : const Color(0xff64748b),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildXpBar(
      double progress, int xpRemaining, bool isDark, _Strings s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Container(
                height: 10,
                color: isDark
                    ? const Color(0xff1e293b)
                    : const Color(0xfff1f5f9),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 10,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xff2563eb), Color(0xff8b5cf6)],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        Text(
          s.xpToNextLevel(xpRemaining),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark
                ? const Color(0xff64748b)
                : const Color(0xff94a3b8),
          ),
        ),
      ],
    );
  }

  // ── SECTION LABEL ────────────────────────────────────────────────────
  Widget _buildSectionLabel(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color:
            isDark ? const Color(0xff475569) : const Color(0xff94a3b8),
      ),
    );
  }

  // ── PREUVES GRILLE ────────────────────────────────────────────────────
  Widget _buildProofsGrid(
    BuildContext context,
    bool isDark,
    _Strings s,
    int completedTasks,
    int totalTasks,
    int completedMissions,
    int totalMissions,
    int streak,
    String focusStr,
    int disc,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildProofTile(
                context,
                isDark: isDark,
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xff10b981),
                value: '$completedTasks / $totalTasks',
                label: s.proofTasks,
                sub: s.proofTasksSub,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildProofTile(
                context,
                isDark: isDark,
                icon: Icons.timer_outlined,
                color: const Color(0xff8b5cf6),
                value: focusStr,
                label: s.proofFocus,
                sub: s.proofFocusSub,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildProofTile(
                context,
                isDark: isDark,
                icon: Icons.flag_outlined,
                color: const Color(0xff2563eb),
                value: '$completedMissions / $totalMissions',
                label: s.proofMissions,
                sub: s.proofMissionsSub,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildProofTile(
                context,
                isDark: isDark,
                icon: Icons.local_fire_department_rounded,
                color: const Color(0xfff59e0b),
                value: '$streak ${s.daysSuffix}',
                label: s.proofStreak,
                sub: streak > 0
                    ? s.proofStreakActive
                    : s.proofStreakStart,
              ),
            ),
          ],
        ),
        if (disc > 0) ...[
          const SizedBox(height: 12),
          _buildProofTile(
            context,
            isDark: isDark,
            icon: Icons.bolt_rounded,
            color: const Color(0xffef4444),
            value: '$disc',
            label: s.proofDiscipline,
            sub: s.proofDisciplineSub,
            fullWidth: true,
          ),
        ],
      ],
    );
  }

  Widget _buildProofTile(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required Color color,
    required String value,
    required String label,
    required String sub,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff111827) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isDark ? const Color(0xff1e293b) : const Color(0xffe8edf8),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.14 : 0.09),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 15, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xff64748b)
                        : const Color(0xff94a3b8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: isDark ? Colors.white : const Color(0xff0f172a),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? const Color(0xff475569)
                  : const Color(0xffb0bec5),
            ),
          ),
        ],
      ),
    );
  }

  // ── GOAL TILE ──────────────────────────────────────────────────────────
  Widget _buildGoalTile(
    BuildContext context,
    Map<String, dynamic> goal,
    AppStateProvider state,
    bool isDark,
    _Strings s,
  ) {
    final double prog =
        (goal['progress'] as num?)?.toDouble().clamp(0.0, 1.0) ?? 0.0;
    final String goalId = (goal['id'] ?? '').toString();
    final linkedTasks = state.tasks
        .where((t) => t['linkedGoalId']?.toString() == goalId)
        .toList();
    final int completedLinked =
        linkedTasks.where((t) => t['isCompleted'] == true).length;
    final bool isComplete = goal['isCompleted'] == true || prog >= 1.0;

    final Color progColor = isComplete
        ? const Color(0xff10b981)
        : prog >= 0.6
            ? const Color(0xff2563eb)
            : const Color(0xff8b5cf6);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff111827) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isComplete
              ? const Color(0xff10b981)
                  .withValues(alpha: isDark ? 0.3 : 0.2)
              : isDark
                  ? const Color(0xff1e293b)
                  : const Color(0xffe8edf8),
        ),
        boxShadow: [
          BoxShadow(
            color: progColor.withValues(alpha: isDark ? 0.07 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal['title'] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color:
                        isDark ? Colors.white : const Color(0xff0f172a),
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color:
                      progColor.withValues(alpha: isDark ? 0.14 : 0.09),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(prog * 100).round()}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: progColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(
                  height: 7,
                  color: isDark
                      ? const Color(0xff1e293b)
                      : const Color(0xfff1f5f9),
                ),
                FractionallySizedBox(
                  widthFactor: prog,
                  child: Container(
                    height: 7,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isComplete
                            ? [
                                const Color(0xff10b981),
                                const Color(0xff06b6d4),
                              ]
                            : [
                                const Color(0xff2563eb),
                                const Color(0xff8b5cf6),
                              ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (linkedTasks.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              '$completedLinked / ${linkedTasks.length} ${s.linkedTasksDone}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? const Color(0xff475569)
                    : const Color(0xffb0bec5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── MOMENTUM CARD ────────────────────────────────────────────────────
  Widget _buildMomentumCard(
    BuildContext context,
    bool isDark,
    _Strings s,
    int level,
    int xpRemaining,
    int streak,
    List<Map<String, dynamic>> completedTasks,
    List<Map<String, dynamic>> completedMissions,
  ) {
    final String? lastTaskTitle = completedTasks.isNotEmpty
        ? (completedTasks.last['title'] as String?)
        : null;
    final String? lastMissionTitle = completedMissions.isNotEmpty
        ? (completedMissions.last['title'] as String?)
        : null;

    final List<_MomentumPoint> signals = [];
    if (completedTasks.isNotEmpty) {
      signals.add(_MomentumPoint(
        icon: Icons.check_circle_outline_rounded,
        color: const Color(0xff10b981),
        text: s.momentumTask(completedTasks.length),
      ));
    }
    if (completedMissions.isNotEmpty) {
      signals.add(_MomentumPoint(
        icon: Icons.flag_rounded,
        color: const Color(0xff2563eb),
        text: s.momentumMission(completedMissions.length),
      ));
    }
    if (streak > 0) {
      signals.add(_MomentumPoint(
        icon: Icons.local_fire_department_rounded,
        color: const Color(0xfff59e0b),
        text: s.momentumStreak(streak),
      ));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff111827) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xff8b5cf6)
              .withValues(alpha: isDark ? 0.22 : 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff8b5cf6)
                .withValues(alpha: isDark ? 0.09 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xff8b5cf6), Color(0xff2563eb)],
                  ),
                ),
                child: const Icon(Icons.auto_awesome,
                    size: 14, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Text(
                s.momentumHeader,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color:
                      isDark ? Colors.white : const Color(0xff0f172a),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...signals.map(
            (sig) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(sig.icon, size: 14, color: sig.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sig.text,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xff94a3b8)
                            : const Color(0xff475569),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (signals.isNotEmpty) const SizedBox(height: 4),
          if (lastTaskTitle != null || lastMissionTitle != null) ...[
            Divider(
              color: isDark
                  ? const Color(0xff1e293b)
                  : const Color(0xffe8edf8),
              height: 16,
            ),
            Text(
              s.lastAction,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: isDark
                    ? const Color(0xff475569)
                    : const Color(0xffb0bec5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '"${lastTaskTitle ?? lastMissionTitle}"',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xffcbd5e1)
                    : const Color(0xff334155),
                fontStyle: FontStyle.italic,
                height: 1.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xff2563eb)
                  .withValues(alpha: isDark ? 0.12 : 0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.arrow_forward_rounded,
                    size: 14, color: Color(0xff2563eb)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.nextTarget(level + 1, xpRemaining),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff2563eb),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── EMPTY STATE ────────────────────────────────────────────────────────
  Widget _buildEmptyState(
      BuildContext context, _Strings s, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff111827) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? const Color(0xff1e293b)
              : const Color(0xffe8edf8),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff2563eb)
                .withValues(alpha: isDark ? 0.06 : 0.04),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (context, child) {
              return Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xff2563eb).withValues(
                          alpha: 0.14 + 0.06 * _glowAnim.value),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: child,
              );
            },
            child: const Icon(Icons.timeline_rounded,
                size: 36, color: Color(0xff2563eb)),
          ),
          const SizedBox(height: 20),
          Text(
            s.emptyTitle,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: isDark ? Colors.white : const Color(0xff0f172a),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            s.emptySubtitle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: isDark
                  ? const Color(0xff64748b)
                  : const Color(0xff94a3b8),
              height: 1.55,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── DATA MODEL ───────────────────────────────────────────────────────────
class _MomentumPoint {
  final IconData icon;
  final Color color;
  final String text;
  const _MomentumPoint(
      {required this.icon, required this.color, required this.text});
}

// ── LOCALISATION ─────────────────────────────────────────────────────────
class _Strings {
  final String lang;
  const _Strings(this.lang);

  bool get _en => lang == 'en';
  bool get _es => lang == 'es';

  String get screenTitle =>
      _en ? 'Progression' : (_es ? 'Progresión' : 'Progression');

  String get heroQuestion => _en
      ? 'WHAT YOU BUILT'
      : (_es ? 'LO QUE HAS CONSTRUIDO' : 'CE QUE TU AS CONSTRUIT');

  String levelLabel(int lvl) =>
      _en ? 'Level $lvl' : (_es ? 'Nivel $lvl' : 'Niveau $lvl');

  String xpToNextLevel(int xp) => _en
      ? '$xp XP to next level'
      : (_es
          ? '$xp XP para el siguiente nivel'
          : '$xp XP vers le prochain niveau');

  String get sectionProofs => _en
      ? 'REAL PROOFS OF ACTION'
      : (_es ? 'PRUEBAS REALES' : "PREUVES RÉELLES D'ACTION");

  String get sectionGoals => _en
      ? 'GOALS TRAJECTORY'
      : (_es ? 'TRAYECTORIA DE OBJETIVOS' : 'TRAJECTOIRE DES OBJECTIFS');

  String get sectionMomentum => _en
      ? 'MOMENTUM & DIRECTION'
      : (_es ? 'MOMENTO Y DIRECCIÓN' : 'MOMENTUM & DIRECTION');

  String get proofTasks =>
      _en ? 'Tasks Done' : (_es ? 'Tareas Hechas' : 'Tâches validées');
  String get proofTasksSub =>
      _en ? 'Completed' : (_es ? 'Completadas' : 'Actions concrétisées');
  String get proofFocus =>
      _en ? 'Focus Time' : (_es ? 'Tiempo Focus' : 'Temps Focus');
  String get proofFocusSub =>
      _en ? 'Deep work done' : (_es ? 'Trabajo profundo' : 'Immersion réalisée');
  String get proofMissions =>
      _en ? 'Missions' : (_es ? 'Misiones' : 'Missions réussies');
  String get proofMissionsSub =>
      _en ? 'Quests completed' : (_es ? 'Desafíos cumplidos' : 'Défis complétés');
  String get proofStreak =>
      _en ? 'Active Streak' : (_es ? 'Racha Activa' : 'Série Active');
  String get daysSuffix =>
      _en ? 'days' : (_es ? 'días' : 'jours');
  String get proofStreakActive => _en
      ? 'Consecutive active days'
      : (_es ? 'Días consecutivos' : "Jours consécutifs d'activité");
  String get proofStreakStart => _en
      ? 'Validate an action today'
      : (_es ? 'Valida una acción hoy' : "Validez une action aujourd'hui");
  String get proofDiscipline =>
      _en ? 'Discipline' : (_es ? 'Disciplina' : 'Discipline');
  String get proofDisciplineSub =>
      _en ? 'Consistency score' : (_es ? 'Puntuación de constancia' : 'Score de constance');

  String get linkedTasksDone => _en
      ? 'linked tasks done'
      : (_es ? 'tareas vinculadas listas' : 'tâches liées validées');

  String get momentumHeader => _en
      ? 'Progress Dynamic'
      : (_es ? 'Dinámica de Avance' : "Dynamique d'avancement");

  String momentumTask(int n) => _en
      ? '$n task${n > 1 ? "s" : ""} accomplished'
      : (_es
          ? '$n tarea${n > 1 ? "s" : ""} completada${n > 1 ? "s" : ""}'
          : '$n tâche${n > 1 ? "s" : ""} accomplie${n > 1 ? "s" : ""}');

  String momentumMission(int n) => _en
      ? '$n mission${n > 1 ? "s" : ""} completed'
      : (_es
          ? '$n misión${n > 1 ? "es" : ""} completada${n > 1 ? "s" : ""}'
          : '$n mission${n > 1 ? "s" : ""} complétée${n > 1 ? "s" : ""}');

  String momentumStreak(int n) => _en
      ? '$n-day active streak'
      : (_es
          ? 'Racha activa de $n día${n > 1 ? "s" : ""}'
          : 'Série active de $n jour${n > 1 ? "s" : ""}');

  String get lastAction => _en
      ? 'LAST CONCRETE ACTION'
      : (_es ? 'ÚLTIMA ACCIÓN CONCRETA' : 'DERNIÈRE ACTION CONCRÉTISÉE');

  String nextTarget(int nextLvl, int xpNeeded) => _en
      ? 'Next: Level $nextLvl — $xpNeeded XP remaining'
      : (_es
          ? 'Siguiente: Nivel $nextLvl — $xpNeeded XP restantes'
          : 'Prochain cap : Niveau $nextLvl — $xpNeeded XP restants');

  String get emptyTitle => _en
      ? 'Your progress begins here.'
      : (_es ? 'Tu progreso comienza aquí.' : 'Ta progression commence ici.');

  String get emptySubtitle => _en
      ? 'Every accomplished action\nwill build your authentic journey.'
      : (_es
          ? 'Cada acción realizada\nconstruirá tu trayectoria auténtica.'
          : 'Chaque action accomplie\nviendra construire ton historique.');
}
