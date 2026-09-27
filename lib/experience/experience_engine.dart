import '../intelligence/models/intelligence_models.dart';
import 'models/experience_action.dart';
import 'models/experience_mode.dart';
import 'models/experience_state.dart';

/// Translates existing intelligence ([N1Summary] + [ContextSnapshot]) into an
/// immutable [ExperienceState].
///
/// Pure Dart: no Flutter, no navigation, no persistence, no side effects.
/// Deterministic: identical inputs always produce an identical state.
class ExperienceEngine {
  const ExperienceEngine();

  /// Precedence: Recovery > Pressure > CheckIn > Priority > Calm.
  /// Pressure covers backlog, agenda conflict, elevated workload and
  /// anticipated future risk (canonical `anticipation_risk` flag from N1,
  /// promoted from the Anticipate node's own accumulation — the engine
  /// never re-scores risk). Goal urgency ranks below task priority: an
  /// at-risk goal (canonical `goal_at_risk` flag from N1) only annotates an
  /// existing surface or selects the dominant goal — it never changes the
  /// mode itself.
  ExperienceState derive({
    required N1Summary n1,
    required ContextSnapshot snapshot,
    required int currentTab,
    DateTime? now,
  }) {
    // 1. Recovery: critical battery (same triggers Home hardcodes today) or
    // a recovery-grade Pulse signal promoted by N1 (`pulse_recovery_needed`).
    // The engine only reads the canonical risk flag — it never sees PulseNode.
    final batteryCritical = snapshot.mentalBattery < 35 ||
        n1.riskFlags.contains('mental_battery_low') ||
        n1.riskFlags.contains('low_mental_battery') ||
        snapshot.riskFlags.contains('low_mental_battery');
    final pulseRecovery = n1.riskFlags.contains('pulse_recovery_needed');
    // Canonical Living Goals signal (N1 decision): at-risk goal context.
    final goalAtRisk = n1.riskFlags.contains('goal_at_risk');
    if (batteryCritical || pulseRecovery) {
      return ExperienceState(
        mode: ExperienceMode.recovery,
        dominantFocus: ExperienceDominantFocus.recovery,
        primaryAction: const ExperienceAction(
          actionType: IntelligentActionType.takeBreak,
          targetTab: 2, // Focus space, as Home hardcodes today.
          emphasis: ExperienceEmphasis.gentle,
        ),
        informationDensity: ExperienceDensity.minimal,
        tone: ExperienceTone.gentle,
        reasons: <String>[
          if (batteryCritical) 'mental_battery_critical',
          if (pulseRecovery) 'pulse_recovery_needed',
        ],
      );
    }

    // 2. Pressure: backlog, conflict, elevated workload or a compounding
    // future risk justifies a triage surface. `workload_elevated` and
    // `anticipation_risk` are canonical N1 promotions — the engine only
    // reads the flags; it never re-scores workload or risk here.
    // Anticipation stays advisory: it selects the existing preventive
    // surface, never an automatic task/goal change — the user still chooses.
    final backlog = snapshot.openTasks.length > 5 ||
        snapshot.riskFlags.contains('task_backlog_high') ||
        n1.riskFlags.contains('task_backlog_high');
    final conflict = n1.riskFlags.contains('agenda_conflict_possible');
    final workload = n1.riskFlags.contains('workload_elevated');
    final anticipation = n1.riskFlags.contains('anticipation_risk');
    if (backlog || conflict || workload || anticipation) {
      return ExperienceState(
        mode: ExperienceMode.pressure,
        dominantFocus: ExperienceDominantFocus.triage,
        primaryAction: const ExperienceAction(
          actionType: IntelligentActionType.adjustPriority,
          targetTab: 1, // Tasks space, for triage.
          emphasis: ExperienceEmphasis.elevated,
        ),
        informationDensity: ExperienceDensity.reduced,
        tone: ExperienceTone.neutral,
        reasons: <String>[
          if (backlog) 'task_backlog_high',
          if (conflict) 'agenda_conflict_possible',
          if (workload) 'workload_elevated',
          if (anticipation) 'anticipation_risk',
        ],
      );
    }

    // 3. CheckIn: daily context is incomplete.
    if (!snapshot.hasCheckedInToday) {
      return ExperienceState(
        mode: ExperienceMode.checkIn,
        dominantFocus: ExperienceDominantFocus.checkIn,
        primaryAction: ExperienceAction(
          actionType: null, // Local ritual: Home opens the check-in dialog.
          targetTab: currentTab, // Stays in place, as Home does today.
          emphasis: ExperienceEmphasis.standard,
        ),
        informationDensity: ExperienceDensity.reduced,
        tone: ExperienceTone.encouraging,
        reasons: const <String>['daily_check_in_missing'],
      );
    }

    // 4. Priority: N1 selected an open task; reuse its selection as-is.
    // Goal urgency never outranks task priority: an at-risk goal only adds
    // canonical context (reason) — mode, focus and target stay on the task.
    final openTasks = snapshot.openTasks;
    if (openTasks.isNotEmpty) {
      final n1TargetId = n1.primaryAction?.targetId;
      final taskId = (n1TargetId != null &&
              openTasks.any((task) => task.id == n1TargetId))
          ? n1TargetId
          : openTasks.first.id;
      return ExperienceState(
        mode: ExperienceMode.priority,
        dominantFocus: ExperienceDominantFocus.primaryTask,
        primaryAction: ExperienceAction(
          actionType: IntelligentActionType.completeTask,
          targetId: taskId,
          targetTab: currentTab, // Completion happens in place.
          emphasis: _emphasisFrom(n1.priorityLevel),
        ),
        informationDensity: ExperienceDensity.standard,
        tone: ExperienceTone.neutral,
        reasons: <String>[
          'open_task_available',
          if (goalAtRisk) 'goal_at_risk',
        ],
      );
    }

    // 5. Calm: no urgent work; keep goals available without forcing a task.
    // The dominant goal is the canonical primary from N1 (Living Goals
    // ranking) — never a second ranking computed here — falling back to the
    // first goal when the signal is absent.
    final goals = snapshot.goals;
    if (goals.isNotEmpty) {
      final n1GoalId = n1.primaryGoalId;
      final goalId = (n1GoalId != null && goals.any((g) => g.id == n1GoalId))
          ? n1GoalId
          : goals.first.id;
      return ExperienceState(
        mode: ExperienceMode.calm,
        dominantFocus: ExperienceDominantFocus.goal,
        primaryAction: ExperienceAction(
          actionType: null, // Local step: Home navigates to the Tasks space.
          targetId: goalId,
          targetTab: 1,
          emphasis: ExperienceEmphasis.standard,
        ),
        informationDensity: ExperienceDensity.standard,
        tone: ExperienceTone.encouraging,
        reasons: <String>[
          'goal_progress_available',
          if (goalAtRisk) 'goal_at_risk',
        ],
      );
    }

    return const ExperienceState(
      mode: ExperienceMode.calm,
      dominantFocus: ExperienceDominantFocus.calm,
      primaryAction: ExperienceAction(
        actionType: IntelligentActionType.startFocus,
        targetTab: 2, // Free focus session, as Home hardcodes today.
        emphasis: ExperienceEmphasis.standard,
      ),
      informationDensity: ExperienceDensity.standard,
      tone: ExperienceTone.encouraging,
      reasons: <String>['no_urgent_work'],
    );
  }

  ExperienceEmphasis _emphasisFrom(PriorityLevel priorityLevel) {
    return switch (priorityLevel) {
      PriorityLevel.critical || PriorityLevel.high => ExperienceEmphasis.elevated,
      PriorityLevel.medium => ExperienceEmphasis.standard,
      PriorityLevel.low => ExperienceEmphasis.gentle,
    };
  }
}
