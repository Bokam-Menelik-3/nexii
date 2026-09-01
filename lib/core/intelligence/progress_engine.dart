import '../services/task_service.dart';
import '../services/goal_service.dart';
import '../services/focus_service.dart';
import '../services/profile_service.dart';

enum Trend { improvement, stagnation, decline, unknown }

class ProgressSnapshot {
  final DateTime start;
  final DateTime end;
  final int totalTasks;
  final int completedTasks;
  final double completionRate;
  final int focusSessions;
  final int focusMinutes;
  final int activeDays;
  final int goalsCount;
  final int tasksLinkedToGoals;

  ProgressSnapshot({
    required this.start,
    required this.end,
    required this.totalTasks,
    required this.completedTasks,
    required this.completionRate,
    required this.focusSessions,
    required this.focusMinutes,
    required this.activeDays,
    required this.goalsCount,
    required this.tasksLinkedToGoals,
  });
}

class ProgressInsight {
  final String title;
  final String description;
  final Trend trend;

  ProgressInsight(
      {required this.title,
      required this.description,
      this.trend = Trend.unknown});
}

class WeeklyProgressSummary {
  final ProgressSnapshot snapshot;
  final List<ProgressInsight> insights;

  WeeklyProgressSummary({required this.snapshot, this.insights = const []});
}

/// Minimal deterministic Progress Engine using real services.
class ProgressEngine {
  final TaskService _taskService;
  final GoalService _goalService;
  final FocusService _focusService;
  final ProfileService _profileService;

  ProgressEngine({
    required TaskService taskService,
    required GoalService goalService,
    required FocusService focusService,
    required ProfileService profileService,
  })  : _taskService = taskService,
        _goalService = goalService,
        _focusService = focusService,
        _profileService = profileService;

  /// Compute a progress snapshot between [start] and [end].
  Future<ProgressSnapshot> computeSnapshot(DateTime start, DateTime end) async {
    // Tasks
    final tasks = await _taskService.fetchTasks();
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final completionRate = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

    // Goals
    final goals = await _goalService.fetchGoals();
    final goalsCount = goals.length;

    // Tasks linked to goals
    final tasksLinkedToGoals =
        tasks.where((t) => t.linkedGoalId.isNotEmpty).length;

    // Focus sessions
    final sessions = await _focusService.fetchSessions();
    final sessionsInRange = sessions
        .where(
            (s) => !_isBefore(s.endedAt, start) && !_isAfter(s.startedAt, end))
        .toList();
    final focusSessions = sessionsInRange.length;
    final focusMinutes =
        sessionsInRange.fold<int>(0, (acc, s) => acc + (s.duration));

    // Active days (from focus sessions and agenda events if available via sessions)
    final activeDaysSet = <DateTime>{};
    for (var s in sessionsInRange) {
      activeDaysSet
          .add(DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day));
    }

    final activeDays = activeDaysSet.length;

    return ProgressSnapshot(
      start: start,
      end: end,
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      completionRate: completionRate,
      focusSessions: focusSessions,
      focusMinutes: focusMinutes,
      activeDays: activeDays,
      goalsCount: goalsCount,
      tasksLinkedToGoals: tasksLinkedToGoals,
    );
  }

  /// Compute a 7-day weekly summary ending at [referenceEnd].
  Future<WeeklyProgressSummary> compute7DaySummary(
      DateTime referenceEnd) async {
    final end = DateTime(
        referenceEnd.year, referenceEnd.month, referenceEnd.day, 23, 59, 59);
    final start = end.subtract(const Duration(days: 6));

    final snapshot = await computeSnapshot(start, end);

    // Build simple insights using baseline if available.
    final insights = <ProgressInsight>[];

    final profile = await _profileService.fetchProfile();
    if (profile != null) {
      final baseline = profile.preferences['baselineSnapshot'];
      if (baseline is Map) {
        final baselineTasks = (baseline['tasksCount'] as num?)?.toInt() ?? 0;
        final baselineCompleted =
            (baseline['completedTasks'] as num?)?.toInt() ?? 0;
        final baselineFocus = (baseline['focusMinutes'] as num?)?.toInt() ?? 0;

        final baselineCompletionRate =
            baselineTasks == 0 ? 0.0 : baselineCompleted / baselineTasks;

        // Completion trend
        if (snapshot.completionRate > baselineCompletionRate + 0.05) {
          insights.add(ProgressInsight(
            title: 'Taux de complétion en hausse',
            description:
                'Ton taux de complétion a augmenté par rapport au baseline initial.',
            trend: Trend.improvement,
          ));
        } else if (snapshot.completionRate < baselineCompletionRate - 0.05) {
          insights.add(ProgressInsight(
            title: 'Taux de complétion en baisse',
            description:
                'Ton taux de complétion est en baisse par rapport au baseline initial.',
            trend: Trend.decline,
          ));
        } else {
          insights.add(ProgressInsight(
            title: 'Taux de complétion stable',
            description:
                'Ton taux de complétion est stable par rapport au baseline initial.',
            trend: Trend.stagnation,
          ));
        }

        // Focus trend
        if (snapshot.focusMinutes > baselineFocus + 10) {
          insights.add(ProgressInsight(
              title: 'Plus de concentration',
              description: 'Tu as passé plus de temps en focus cette semaine.',
              trend: Trend.improvement));
        } else if (snapshot.focusMinutes < baselineFocus - 10) {
          insights.add(ProgressInsight(
              title: 'Moins de concentration',
              description: 'Tu as moins de minutes de focus cette semaine.',
              trend: Trend.decline));
        } else {
          insights.add(ProgressInsight(
              title: 'Concentration stable',
              description:
                  'Ton temps de concentration est resté proche du baseline.',
              trend: Trend.stagnation));
        }
      }
    } else {
      insights.add(ProgressInsight(
          title: 'Pas encore de profil',
          description:
              'Ton profil n\'est pas encore chargé ; commence par créer des tâches et sessions de focus.',
          trend: Trend.unknown));
    }

    return WeeklyProgressSummary(snapshot: snapshot, insights: insights);
  }

  bool _isBefore(DateTime a, DateTime b) => a.isBefore(b);
  bool _isAfter(DateTime a, DateTime b) => a.isAfter(b);
}
