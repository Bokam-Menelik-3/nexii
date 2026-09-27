import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/nexii_colors.dart';
import '../core/widgets/adaptive_living_widgets.dart';
import '../experience/models/experience_mode.dart';
import '../experience/models/experience_state.dart';
import '../intelligence/models/intelligence_models.dart';
import '../providers/app_state_provider.dart';
import 'profile_screen.dart';

/// Home-only presentation configuration derived from the Experience state.
///
/// Same structure, different expression: density and mode tune emphasis,
/// spacing and visible secondary context without changing Home's layout.
/// Essential actions (dominant CTA) are never dimmed — only supporting
/// context recedes, so reduced density never reads as disabled.
class _HomePresentation {
  const _HomePresentation({
    required this.secondaryOpacity,
    required this.sectionGap,
    required this.visibleSecondaryItems,
    required this.accentAlpha,
    required this.titleFontSize,
    required this.ctaHeight,
    required this.fullWidthCta,
    required this.dominantPadding,
  });

  /// Opacity of supporting (non-essential) secondary content.
  final double secondaryOpacity;

  /// Vertical rhythm between the main Home sections.
  final double sectionGap;

  /// Number of agenda / goals items shown in the secondary column.
  final int visibleSecondaryItems;

  /// Accent strength (border + glow) of the dominant surface.
  final double accentAlpha;

  /// Dominant surface title size (Priority carries the strongest hierarchy).
  final double titleFontSize;

  /// Minimum height of the primary CTA (>= 44dp touch target).
  final double ctaHeight;

  /// Whether the primary CTA spans the full surface width.
  final bool fullWidthCta;

  /// Internal padding of the dominant surface.
  final EdgeInsetsGeometry dominantPadding;

  factory _HomePresentation.from(ExperienceState experience) {
    // Density baseline (ExperienceLayer information density).
    double secondaryOpacity = switch (experience.informationDensity) {
      ExperienceDensity.standard => 1.0,
      ExperienceDensity.reduced => 0.68,
      ExperienceDensity.minimal => 0.42,
    };
    int visibleSecondaryItems = switch (experience.informationDensity) {
      ExperienceDensity.standard => 3,
      ExperienceDensity.reduced => 2,
      ExperienceDensity.minimal => 1,
    };
    double sectionGap = switch (experience.informationDensity) {
      ExperienceDensity.standard => NexiiSpacing.xl,
      ExperienceDensity.reduced => NexiiSpacing.lg,
      ExperienceDensity.minimal => NexiiSpacing.lg,
    };

    double accentAlpha = 0.5;
    double titleFontSize = 20;
    double ctaHeight = 46;
    bool fullWidthCta = false;
    EdgeInsetsGeometry dominantPadding = const EdgeInsets.all(NexiiSpacing.xl);

    // Mode modifiers refine the density baseline.
    switch (experience.mode) {
      case ExperienceMode.recovery:
        secondaryOpacity = 0.45;
        visibleSecondaryItems = 1;
        sectionGap = NexiiSpacing.xxl;
        accentAlpha = 0.38; // softer, calmer emphasis
        ctaHeight = 48;
        dominantPadding = const EdgeInsets.all(NexiiSpacing.xxl);
      case ExperienceMode.pressure:
        secondaryOpacity = 0.55;
        visibleSecondaryItems = 2;
        sectionGap = NexiiSpacing.xl;
        accentAlpha = 0.58;
        ctaHeight = 48;
        fullWidthCta = true; // one clear triage action
      case ExperienceMode.checkIn:
        secondaryOpacity = 0.75;
        visibleSecondaryItems = 2;
        sectionGap = NexiiSpacing.xl;
        accentAlpha = 0.5;
        ctaHeight = 48;
        fullWidthCta = true; // inviting, obvious CTA
      case ExperienceMode.priority:
        titleFontSize = 22; // strongest productive hierarchy
        sectionGap = NexiiSpacing.xl;
        accentAlpha = 0.6;
        fullWidthCta = true;
      case ExperienceMode.calm:
        sectionGap = NexiiSpacing.xxxl; // generous breathing room
        accentAlpha = 0.45;
        dominantPadding = const EdgeInsets.all(NexiiSpacing.xxxl);
    }

    return _HomePresentation(
      secondaryOpacity: secondaryOpacity.clamp(0.42, 1.0),
      sectionGap: sectionGap,
      visibleSecondaryItems: visibleSecondaryItems,
      accentAlpha: accentAlpha,
      titleFontSize: titleFontSize,
      ctaHeight: ctaHeight,
      fullWidthCta: fullWidthCta,
      dominantPadding: dominantPadding,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final snapshot = state.currentContextSnapshot;
    final n1 = state.currentN1Summary;
    final experience = state.currentExperienceState;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = state.currentLocale.languageCode;
    final s = _HomeStrings(lang);
    final presentation = _HomePresentation.from(experience);

    return Scaffold(
      backgroundColor: isDark ? NexiiColors.deepBackground : NexiiColors.lightBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 768;

            if (isTablet) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: NexiiSpacing.xxl,
                      vertical: NexiiSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIdentityHeader(context, state, s, isDark, lang),
                        const SizedBox(height: NexiiSpacing.xl),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Main Column: Current State + What Matters Now & Next Action
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildCurrentStateSection(context, state, s, isDark),
                                  SizedBox(height: presentation.sectionGap),
                                  _buildExperienceShift(
                                    experience: experience,
                                    child: _buildWhatMattersNowCard(context, state, snapshot, n1, experience, s, isDark),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: NexiiSpacing.xxl),
                            // Secondary Column: Context (Agenda, Goals, Rhythm)
                            Expanded(
                              flex: 4,
                              child: _buildSecondaryContextColumn(context, state, s, isDark, presentation),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Mobile Single-Column Flow
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: NexiiSpacing.lg,
                    vertical: NexiiSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIdentityHeader(context, state, s, isDark, lang),
                      const SizedBox(height: NexiiSpacing.lg),
                      _buildCurrentStateSection(context, state, s, isDark),
                      SizedBox(height: presentation.sectionGap),
                      _buildExperienceShift(
                        experience: experience,
                        child: _buildWhatMattersNowCard(context, state, snapshot, n1, experience, s, isDark),
                      ),
                      SizedBox(height: presentation.sectionGap),
                      _buildSecondaryContextColumn(context, state, s, isDark, presentation),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Adaptive motion duration: instant when the platform requests
  /// reduced motion (accessibility).
  Duration _motionDuration(BuildContext context) =>
      MediaQuery.of(context).disableAnimations ? Duration.zero : NexiiMotion.normal;

  /// Intelligence Shift: when the Experience mode (or its primary target)
  /// changes, the dominant surface cross-fades in with a subtle upward
  /// slide. Keyed by mode + primary action target so ordinary state
  /// updates never re-trigger the transition.
  Widget _buildExperienceShift({
    required ExperienceState experience,
    required Widget child,
  }) {
    return AnimatedSwitcher(
      duration: _motionDuration(context),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (animationChild, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: animationChild,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey('${experience.mode.name}:${experience.primaryAction.targetId}'),
        child: child,
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 1. IDENTITY
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildIdentityHeader(
    BuildContext context,
    AppStateProvider state,
    _HomeStrings s,
    bool isDark,
    String lang,
  ) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour, state.profileName, lang);
    final dateStr = _formatContextualDate(now, lang);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Greeting & Temporal Context
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: isDark ? NexiiColors.deepTextPrimary : NexiiColors.lightTextPrimary,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 13,
                    color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateStr,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: NexiiSpacing.md),
        // Crisis mode badge if active
        if (state.isCrisisMode)
          Semantics(
            button: true,
            excludeSemantics: true,
            label: s.crisisModeBadge,
            child: GestureDetector(
              onTap: () => state.toggleCrisisMode(),
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                margin: const EdgeInsets.only(right: NexiiSpacing.sm),
                decoration: BoxDecoration(
                  color: NexiiColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(NexiiRadii.pill),
                  border: Border.all(color: NexiiColors.error.withValues(alpha: 0.5)),
                ),
                child: Text(
                  s.crisisModeBadge,
                  style: const TextStyle(
                    color: NexiiColors.error,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        // Profile Avatar Button
        Semantics(
          label: s.profileTooltip,
          button: true,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              borderRadius: BorderRadius.circular(NexiiRadii.pill),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? NexiiColors.deepSurfacePrimary : NexiiColors.lightSurfaceSecondary,
                  border: Border.all(
                    color: NexiiColors.primary.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: state.profileName.trim().isNotEmpty
                      ? Text(
                          state.profileName.trim().substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: NexiiColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      : const Icon(
                          Icons.person_outline,
                          color: NexiiColors.primary,
                          size: 22,
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStateSection(
    BuildContext context,
    AppStateProvider state,
    _HomeStrings s,
    bool isDark,
  ) {
    final auraScore = state.auraScore;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NexiiSpacing.xs, vertical: NexiiSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                AuraVisualWidget(score: auraScore, size: 12),
                const SizedBox(width: NexiiSpacing.sm),
                Expanded(
                  child: Text(
                    'Aura: ${state.auraLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: NexiiSpacing.sm),
          Semantics(
            button: true,
            label: state.hasCheckedInToday ? s.checkInDone : s.checkInPending,
            child: GestureDetector(
              onTap: () => _showCheckInDialog(context, state),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(NexiiRadii.md),
                ),
                child: Row(
                  children: [
                    Icon(
                      state.hasCheckedInToday ? Icons.check : Icons.edit_note,
                      size: 14,
                      color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      state.hasCheckedInToday ? s.checkInDone : s.doCheckInBtn,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 3. WHAT MATTERS NOW & 4. NEXT ACTION
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildWhatMattersNowCard(
    BuildContext context,
    AppStateProvider state,
    ContextSnapshot snapshot,
    N1Summary n1,
    ExperienceState experience,
    _HomeStrings s,
    bool isDark,
  ) {
    // Presentation + action execution only: mode selection comes from
    // AppStateProvider.currentExperienceState (Experience Layer).
    final mentalBattery = state.mentalBattery; // raw value for display only
    final openTasks = snapshot.openTasks;

    if (experience.mode == ExperienceMode.recovery) {
      return _buildDominantSurface(
        context: context,
        experience: experience,
        s: s,
        
        badgeColor: NexiiColors.warning,
        badgeIcon: Icons.shield_outlined,
        title: s.recoveryTitle,
        description: s.recoveryDesc(mentalBattery),
        recommendation: n1.recommendations.isNotEmpty ? n1.recommendations.first : null,
        isDark: isDark,
        actionButton: ElevatedButton.icon(
          onPressed: () => state.setTabIndex(2), // Navigate to Focus space
          icon: const Icon(Icons.self_improvement, size: 18),
          label: Text(s.startCalmPauseBtn),
          style: ElevatedButton.styleFrom(
            backgroundColor: NexiiColors.warning,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: NexiiSpacing.lg, vertical: NexiiSpacing.md),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NexiiRadii.lg)),
            elevation: 0,
          ),
        ),
      );
    }

    if (experience.mode == ExperienceMode.pressure) {
      return _buildDominantSurface(
        context: context,
        experience: experience,
        s: s,
        
        badgeColor: NexiiColors.cyanGlow,
        badgeIcon: Icons.bolt,
        title: s.pressureTitle,
        description: s.pressureDesc(openTasks.length),
        isDark: isDark,
        actionButton: ElevatedButton.icon(
          onPressed: () =>
              state.setTabIndex(experience.primaryAction.targetTab),
          icon: const Icon(Icons.checklist, size: 18),
          label: Text(s.triageBtn),
          style: ElevatedButton.styleFrom(
            backgroundColor: NexiiColors.cyanGlow,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: NexiiSpacing.lg, vertical: NexiiSpacing.md),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(NexiiRadii.lg)),
            elevation: 0,
          ),
        ),
      );
    }

    if (experience.mode == ExperienceMode.checkIn) {
      return _buildDominantSurface(
        context: context,
        experience: experience,
        s: s,
        
        badgeColor: NexiiColors.aiAccent,
        badgeIcon: Icons.auto_awesome,
        title: s.checkInPromptTitle,
        description: s.checkInPromptDesc,
        isDark: isDark,
        actionButton: ElevatedButton.icon(
          onPressed: () => _showCheckInDialog(context, state),
          icon: const Icon(Icons.favorite_border, size: 18),
          label: Text(s.doCheckInBtn),
          style: ElevatedButton.styleFrom(
            backgroundColor: NexiiColors.aiAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: NexiiSpacing.lg, vertical: NexiiSpacing.md),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(NexiiRadii.lg)),
            elevation: 0,
          ),
        ),
      );
    }

    if (experience.mode == ExperienceMode.priority) {
      final experienceTargetId = experience.primaryAction.targetId;
      final TaskSummary topTask = experienceTargetId != null
          ? openTasks.firstWhere(
              (t) => t.id == experienceTargetId,
              orElse: () => openTasks.first,
            )
          : openTasks.first;

      return _buildDominantSurface(
        context: context,
        experience: experience,
        s: s,
        
        badgeColor: NexiiColors.primary,
        badgeIcon: Icons.flag,
        title: topTask.title,
        metadataWidget: Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (topTask.priority != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: NexiiColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(NexiiRadii.sm),
                ),
                child: Text(
                  topTask.priority!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: NexiiColors.primary,
                  ),
                ),
              ),
            if (topTask.urgency != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: NexiiColors.aiAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(NexiiRadii.sm),
                ),
                child: Text(
                  topTask.urgency!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: NexiiColors.aiAccent,
                  ),
                ),
              ),
            if (topTask.category != null && topTask.category!.isNotEmpty)
              Text(
                topTask.category!,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary,
                ),
              ),
          ],
        ),
        description: n1.primaryReason,
        recommendation: n1.recommendations.isNotEmpty ? n1.recommendations.first : null,
        isDark: isDark,
        actionButton: Row(
          children: [
            Expanded(
              flex: 6,
              child: ElevatedButton.icon(
                onPressed: () => state.toggleTask(topTask.id), // Direct task completion
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: Text(
                  s.completeTaskBtn,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
                onPressed: () => state.setTabIndex(2), // Focus on task
                icon: const Icon(Icons.timer_outlined, size: 18),
                label: Text(
                  s.focusOnTaskBtn,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
      );
    }

    if (experience.mode == ExperienceMode.calm &&
        experience.dominantFocus == ExperienceDominantFocus.goal) {
      final goalTargetId = experience.primaryAction.targetId;
      final goal = goalTargetId != null
          ? state.goals.firstWhere(
              (g) => g['id'].toString() == goalTargetId,
              orElse: () => state.goals.first,
            )
          : state.goals.first;
      final progressNum = (goal['progress'] is num) ? (goal['progress'] as num).toDouble() : 0.0;
      final progressPct = (progressNum * 100).toInt();

      return _buildDominantSurface(
        context: context,
        experience: experience,
        s: s,
        
        badgeColor: NexiiColors.primary,
        badgeIcon: Icons.track_changes,
        title: goal['title']?.toString() ?? s.activeGoalTitle,
        description: s.goalProgressDesc(progressPct),
        recommendation: n1.recommendations.isNotEmpty ? n1.recommendations.first : null,
        isDark: isDark,
        actionButton: ElevatedButton.icon(
          onPressed: () => state.setTabIndex(1), // Navigate to Goals / Tasks tab
          icon: const Icon(Icons.arrow_forward, size: 18),
          label: Text(s.viewGoalsBtn),
          style: ElevatedButton.styleFrom(
            backgroundColor: NexiiColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: NexiiSpacing.lg, vertical: NexiiSpacing.md),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NexiiRadii.lg)),
            elevation: 0,
          ),
        ),
      );
    }

    // Calm: no urgent actionable work (Experience Layer fallback state)
    return _buildDominantSurface(
      context: context,
      experience: experience,
      s: s,
      
      badgeColor: NexiiColors.success,
      badgeIcon: Icons.spa,
      title: s.calmStateTitle,
      description: s.calmStateDesc,
      isDark: isDark,
      actionButton: ElevatedButton.icon(
        onPressed: () => state.setTabIndex(2), // Free focus session
        icon: const Icon(Icons.play_arrow, size: 18),
        label: Text(s.freeFocusBtn),
        style: ElevatedButton.styleFrom(
          backgroundColor: NexiiColors.success,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: NexiiSpacing.lg, vertical: NexiiSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NexiiRadii.lg)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildDominantSurface({
    required BuildContext context,
    required ExperienceState experience,
    required _HomeStrings s,
    required Color badgeColor,
    required IconData badgeIcon,
    required String title,
    Widget? metadataWidget,
    required String description,
    String? recommendation,
    required Widget actionButton,
    required bool isDark,
  }) {
    final presentation = _HomePresentation.from(experience);
    // Primary CTA: dominant modes get a commanding full-width action,
    // always at least a 44dp touch target (grows with text scaling).
    final Widget cta = presentation.fullWidthCta
        ? SizedBox(
            width: double.infinity,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: presentation.ctaHeight),
              child: actionButton,
            ),
          )
        : ConstrainedBox(
            constraints: BoxConstraints(minHeight: presentation.ctaHeight),
            child: actionButton,
          );

    return AdaptiveSurface(
      tier: SurfaceTier.dominant,
      customAccent: badgeColor.withValues(alpha: presentation.accentAlpha),
      padding: presentation.dominantPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dominant Header
          Row(
            children: [
              Icon(badgeIcon, size: 16, color: badgeColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  s.modeLabel(experience.mode).toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: NexiiSpacing.md),
          // Dominant Title (semantic header for screen readers)
          Semantics(
            header: true,
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: presentation.titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: isDark ? NexiiColors.deepTextPrimary : NexiiColors.lightTextPrimary,
                    height: 1.25,
                  ),
            ),
          ),
          if (metadataWidget != null) ...[
            const SizedBox(height: NexiiSpacing.sm),
            metadataWidget,
          ],
          const SizedBox(height: NexiiSpacing.sm),
          // Description / Meaning
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary,
                  height: 1.4,
                ),
          ),
          // Subtle Recommendation note (from N1Summary if available)
          if (recommendation != null && recommendation.isNotEmpty) ...[
            const SizedBox(height: NexiiSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(NexiiRadii.md),
                border: Border.all(
                  color: isDark ? NexiiColors.deepBorder : NexiiColors.lightBorder,
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, size: 14, color: NexiiColors.aiAccent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: NexiiSpacing.lg),
          // Next Action
          cta,
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 5. SECONDARY CONTEXT
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildSecondaryContextColumn(
    BuildContext context,
    AppStateProvider state,
    _HomeStrings s,
    bool isDark,
    _HomePresentation presentation,
  ) {
    final Duration motion = _motionDuration(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Agenda Context (shown only if real events exist)
        if (state.agendaEvents.isNotEmpty) ...[
          AnimatedOpacity(
            duration: motion,
            opacity: presentation.secondaryOpacity,
            child: _buildAgendaContext(context, state, s, isDark, presentation.visibleSecondaryItems),
          ),
          const SizedBox(height: NexiiSpacing.md),
        ],

        // Active Goals Context (shown only if real goals exist)
        if (state.goals.isNotEmpty) ...[
          _buildGoalsContext(context, state, s, isDark, presentation, motion),
          const SizedBox(height: NexiiSpacing.md),
        ],

        // Rhythm & Continuity
        _buildRhythmContext(context, state, s, isDark),
      ],
    );
  }

  Widget _buildAgendaContext(
    BuildContext context,
    AppStateProvider state,
    _HomeStrings s,
    bool isDark,
    int visibleItems,
  ) {
    return AdaptiveSurface(
      tier: SurfaceTier.secondary,
      padding: const EdgeInsets.all(NexiiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: NexiiColors.primary),
              const SizedBox(width: 6),
              Text(
                s.secondaryAgendaTitle.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: NexiiSpacing.md),
          ...state.agendaEvents.take(visibleItems).map((event) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: NexiiColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(NexiiRadii.sm),
                    ),
                    child: Text(
                      event['time'] ?? '08:00',
                      style: const TextStyle(
                        color: NexiiColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event['title'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? NexiiColors.deepTextPrimary : NexiiColors.lightTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGoalsContext(
    BuildContext context,
    AppStateProvider state,
    _HomeStrings s,
    bool isDark,
    _HomePresentation presentation,
    Duration motion,
  ) {
    return AdaptiveSurface(
      tier: SurfaceTier.secondary,
      padding: const EdgeInsets.all(NexiiSpacing.lg),
      onTap: () => state.setTabIndex(1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.flag_outlined, size: 14, color: NexiiColors.aiAccent),
                  const SizedBox(width: 6),
                  Text(
                    s.secondaryGoalsTitle.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            ],
          ),
          const SizedBox(height: NexiiSpacing.md),
          AnimatedOpacity(
            duration: motion,
            opacity: presentation.secondaryOpacity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...state.goals.take(presentation.visibleSecondaryItems).map((goal) {
            final double progress = (goal['progress'] is num) ? (goal['progress'] as num).toDouble() : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          goal['title'] as String? ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? NexiiColors.deepTextPrimary : NexiiColors.lightTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: NexiiColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 4,
                      backgroundColor: isDark ? Colors.white12 : const Color(0xffe2e8f0),
                      valueColor: const AlwaysStoppedAnimation<Color>(NexiiColors.primary),
                    ),
                  ),
                ],
              ),
            );
          }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRhythmContext(
    BuildContext context,
    AppStateProvider state,
    _HomeStrings s,
    bool isDark,
  ) {
    return AdaptiveSurface(
      tier: SurfaceTier.secondary,
      padding: const EdgeInsets.all(NexiiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department, size: 16, color: Colors.amber),
                  const SizedBox(width: 6),
                  Text(
                    '${state.streak} ${s.streakLabel}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_outlined, size: 14, color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${(state.focusMinutesTotal / 60).toStringAsFixed(1)} h',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? NexiiColors.deepTextPrimary : NexiiColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: NexiiSpacing.md),
          SizedBox(
            width: double.infinity,
            child: state.isDayValidated
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: NexiiColors.success, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          s.dayValidated,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: NexiiColors.success,
                          ),
                        ),
                      ],
                    ),
                  )
                : OutlinedButton(
                    onPressed: () => state.validateDay(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: NexiiColors.primary,
                      side: const BorderSide(color: NexiiColors.primary, width: 1.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NexiiRadii.md)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: const Size(0, 44),
                    ),
                    child: Text(
                      s.validateDayBtn,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Check-In Dialog
  // ──────────────────────────────────────────────────────────────────────────
  void _showCheckInDialog(BuildContext context, AppStateProvider state) {
    int mood = state.dailyMood > 0 ? state.dailyMood : 3;
    int energy = state.dailyEnergy > 0 ? state.dailyEnergy : 3;
    int motivation = state.dailyMotivation > 0 ? state.dailyMotivation : 3;
    int stress = state.dailyStress > 0 ? state.dailyStress : 3;
    int sleep = state.dailySleep > 0 ? state.dailySleep : 7;

    final lang = state.currentLocale.languageCode;
    final s = _HomeStrings(lang);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            Widget buildRatingRow(String label, int currentVal, ValueChanged<int> onChanged, {int max = 5}) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$label : $currentVal/$max',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(max, (index) {
                      final val = index + 1;
                      final isSelected = val <= currentVal;
                      return InkWell(
                        onTap: () => setDialogState(() => onChanged(val)),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Icon(
                            isSelected ? Icons.star : Icons.star_border,
                            color: isSelected ? const Color(0xffeab308) : Colors.grey.shade400,
                            size: 24,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NexiiRadii.xxl)),
              title: Text(s.checkInPromptTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildRatingRow(s.mood, mood, (v) => mood = v),
                    buildRatingRow(s.energy, energy, (v) => energy = v),
                    buildRatingRow(s.motivation, motivation, (v) => motivation = v),
                    buildRatingRow(s.stress, stress, (v) => stress = v),
                    buildRatingRow(
                      lang == 'en' ? 'Sleep (hours)' : (lang == 'es' ? 'Sueño (horas)' : 'Sommeil (heures)'),
                      sleep,
                      (v) => sleep = v,
                      max: 10,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(state.translate('cancel_btn')),
                ),
                ElevatedButton(
                  onPressed: () {
                    state.submitDailyCheckIn(mood, energy, motivation, stress, sleep);
                    Navigator.pop(dialogContext);
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

  // ──────────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────────
  String _getGreeting(int hour, String profileName, String lang) {
    String base;
    if (lang == 'en') {
      base = hour < 12 ? 'Good morning' : (hour < 18 ? 'Good afternoon' : 'Good evening');
    } else if (lang == 'es') {
      base = hour < 13 ? 'Buenos días' : (hour < 20 ? 'Buenas tardes' : 'Buenas noches');
    } else {
      base = hour < 18 ? 'Bonjour' : 'Bonsoir';
    }
    return profileName.trim().isNotEmpty ? '$base, ${profileName.trim()}' : base;
  }

  String _formatContextualDate(DateTime date, String lang) {
    const daysFr = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    const monthsFr = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];
    const daysEn = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const monthsEn = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    const daysEs = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    const monthsEs = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];

    final dayName = lang == 'en' ? daysEn[date.weekday - 1] : (lang == 'es' ? daysEs[date.weekday - 1] : daysFr[date.weekday - 1]);
    final monthName = lang == 'en' ? monthsEn[date.month - 1] : (lang == 'es' ? monthsEs[date.month - 1] : monthsFr[date.month - 1]);

    if (lang == 'en') {
      return '$dayName, $monthName ${date.day}';
    } else if (lang == 'es') {
      return '$dayName, ${date.day} de $monthName';
    } else {
      return '$dayName ${date.day} $monthName';
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Localization Dictionary for Home Screen
// ──────────────────────────────────────────────────────────────────────────
class _HomeStrings {
  final String lang;
  _HomeStrings(this.lang);

  String get profileTooltip => lang == 'en' ? 'Profile' : (lang == 'es' ? 'Perfil' : 'Profil');
  String get crisisModeBadge => lang == 'en' ? 'Crisis Mode 🛡️' : (lang == 'es' ? 'Modo Crisis 🛡️' : 'Mode Crise 🛡️');

  String get currentStateTitle => lang == 'en' ? 'Current State' : (lang == 'es' ? 'Estado Actual' : 'État Actuel');
  String get mentalBattery => lang == 'en' ? 'Mental Battery' : (lang == 'es' ? 'Batería Mental' : 'Batterie Mentale');
  String get checkInPending => lang == 'en' ? 'Check-in pending' : (lang == 'es' ? 'Check-in pendiente' : 'Bilan en attente');
  String get checkInDone => lang == 'en' ? 'Bilan complété' : (lang == 'es' ? 'Completado' : 'Bilan complété');
  String get mood => lang == 'en' ? 'Mood' : (lang == 'es' ? 'Ánimo' : 'Humeur');
  String get energy => lang == 'en' ? 'Energy' : (lang == 'es' ? 'Energía' : 'Énergie');
  String get stress => lang == 'en' ? 'Stress' : (lang == 'es' ? 'Estrés' : 'Stress');
  String get motivation => lang == 'en' ? 'Motivation' : (lang == 'es' ? 'Motivación' : 'Motivation');
  String get doCheckInBtn => lang == 'en' ? 'Daily check-in' : (lang == 'es' ? 'Hacer balance' : 'Faire mon bilan');

  String get whatMattersNowBadge => lang == 'en' ? 'WHAT MATTERS NOW' : (lang == 'es' ? 'LO QUE IMPORTA AHORA' : 'CE QUI COMPTE MAINTENANT');
  String modeLabel(ExperienceMode mode) {
    switch (mode) {
      case ExperienceMode.recovery:
        return lang == 'en' ? 'Recovery' : (lang == 'es' ? 'Recuperación' : 'Récupération');
      case ExperienceMode.pressure:
        return lang == 'en' ? 'Triage' : (lang == 'es' ? 'Por ordenar' : 'À trier');
      case ExperienceMode.checkIn:
        return lang == 'en' ? 'Check-in' : (lang == 'es' ? 'Balance' : 'Bilan');
      case ExperienceMode.priority:
        return lang == 'en' ? 'Your moment' : (lang == 'es' ? 'Tu momento' : 'Ton moment');
      case ExperienceMode.calm:
        return lang == 'en' ? 'Your time' : (lang == 'es' ? 'Tu tiempo' : 'Temps pour toi');
    }
  }
  String get checkInPromptTitle => lang == 'en' ? 'Daily Check-in' : (lang == 'es' ? 'Balance Diario' : 'Bilan Quotidien');
  String get checkInPromptDesc => lang == 'en'
      ? 'Take 10 seconds to assess your energy and state to adapt recommendations.'
      : (lang == 'es'
          ? 'Tómate 10 segundos para evaluar tu energía y adaptar las recomendaciones.'
          : 'Prenez 10 secondes pour évaluer votre énergie et état afin d\'adapter les recommandations.');

  String get recoveryTitle => lang == 'en' ? 'Recovery Needed' : (lang == 'es' ? 'Recuperación Necesaria' : 'Récupération Nécessaire');
  String recoveryDesc(int battery) => lang == 'en'
      ? 'Your mental battery is at $battery%. Lightening the load now protects your focus and your streak.'
      : (lang == 'es'
          ? 'Tu batería mental está al $battery%. Aligerar la carga ahora protege tu claridad y tu constancia.'
          : 'Votre batterie mentale est à $battery%. Alléger la charge maintenant protège votre clarté et votre rythme.');
  String get startCalmPauseBtn => lang == 'en' ? 'Start Calming Session' : (lang == 'es' ? 'Iniciar Sesión Calma' : 'Démarrer une session calme');

  String get pressureTitle => lang == 'en' ? 'Backlog Needs Triage' : (lang == 'es' ? 'Pendiente por Ordenar' : 'Arriéré à Trier');
  String pressureDesc(int count) => lang == 'en'
      ? '$count open tasks competing for attention. Take one clear triage step.'
      : (lang == 'es'
          ? '$count tareas abiertas compitiendo por tu atención. Da un solo paso de orden.'
          : '$count tâches ouvertes se disputent votre attention. Faites une seule action de tri.');
  String get triageBtn => lang == 'en' ? 'Triage My Tasks' : (lang == 'es' ? 'Ordenar Mis Tareas' : 'Trier mes tâches');

  String get completeTaskBtn => lang == 'en' ? 'Complete Task' : (lang == 'es' ? 'Completar Tarea' : 'Valider la tâche');
  String get focusOnTaskBtn => lang == 'en' ? 'Focus' : (lang == 'es' ? 'Enfoque' : 'Focus');

  String get activeGoalTitle => lang == 'en' ? 'Active Goal' : (lang == 'es' ? 'Objetivo Activo' : 'Objectif Actif');
  String goalProgressDesc(int pct) => lang == 'en'
      ? '$pct% completed. Steady progress on your main goal.'
      : (lang == 'es'
          ? '$pct% completado. Progreso constante hacia tu objetivo.'
          : '$pct% accompli. Progression constante sur votre objectif.');
  String get viewGoalsBtn => lang == 'en' ? 'View Goals' : (lang == 'es' ? 'Ver Objetivos' : 'Consulter mes objectifs');

  String get calmStateTitle => lang == 'en' ? 'Calm & Balanced' : (lang == 'es' ? 'Calma y Equilibrio' : 'État Calme & Équilibré');
  String get calmStateDesc => lang == 'en'
      ? 'All active priorities are handled. Take this moment to recharge or focus freely.'
      : (lang == 'es'
          ? 'Todas las prioridades están bajo control. Tómate este momento para descansar o enfocarte.'
          : 'Toutes les priorités sont sous contrôle. Prenez ce moment pour respirer ou planifier sereinement.');
  String get freeFocusBtn => lang == 'en' ? 'Start Focus' : (lang == 'es' ? 'Iniciar Enfoque' : 'Démarrer un Focus');

  String get secondaryAgendaTitle => lang == 'en' ? 'Today\'s Agenda' : (lang == 'es' ? 'Agenda de Hoy' : 'Agenda du jour');
  String get secondaryGoalsTitle => lang == 'en' ? 'Active Goals' : (lang == 'es' ? 'Objetivos Activos' : 'Objectifs actifs');
  String get streakLabel => lang == 'en' ? 'day streak' : (lang == 'es' ? 'días de racha' : 'jours de série');
  String get validateDayBtn => lang == 'en' ? 'Validate Day (+30 XP)' : (lang == 'es' ? 'Validar Día (+30 XP)' : 'Valider ma journée (+30 XP)');
  String get dayValidated => lang == 'en' ? 'Day validated! 🔥' : (lang == 'es' ? '¡Día validado! 🔥' : 'Journée validée ! 🔥');
}
