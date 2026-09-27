import '../models/intelligence_models.dart';
import 'intelligence_node.dart';

class MeasureNode extends IntelligenceNode {
  MeasureNode();

  @override
  String get nodeId => 'measure';

  @override
  int get priority => 50;

  @override
  bool isRelevant(ContextSnapshot snapshot) {
    return snapshot.tasks.isNotEmpty ||
        snapshot.goals.isNotEmpty ||
        snapshot.missions.isNotEmpty ||
        snapshot.focusMinutesTotal > 0 ||
        snapshot.xp > 0 ||
        snapshot.streak > 0 ||
        snapshot.auraScore > 0;
  }

  @override
  IntelligenceResult execute(ContextSnapshot snapshot) {
    final completedCount =
        snapshot.tasks.where((task) => task.isCompleted).length;
    final openCount = snapshot.openTasks.length;
    final goalProgress = snapshot.goals.isEmpty
        ? null
        : snapshot.goals.fold<double>(0, (sum, goal) => sum + goal.progress) /
            snapshot.goals.length;
    final avgMissionProgress = snapshot.missions.isEmpty
        ? null
        : snapshot.missions
                .fold<double>(0, (sum, mission) => sum + mission.progress) /
            snapshot.missions.length;

    final observations = <String>[];
    observations.add('tâches complétées : $completedCount');
    observations.add('tâches ouvertes : $openCount');
    observations.add('focus total : ${snapshot.focusMinutesTotal} minutes');
    observations.add('xp : ${snapshot.xp}');
    observations.add('streak : ${snapshot.streak}');
    observations.add('aura score : ${snapshot.auraScore}');

    if (goalProgress != null) {
      observations.add(
          'progression moyenne des objectifs : ${(goalProgress * 100).round()}%');
    }
    if (avgMissionProgress != null) {
      observations.add(
          'progression moyenne des missions : ${(avgMissionProgress * 100).round()}%');
    }

    return IntelligenceResult(
      nodeId: nodeId,
      status: IntelligenceStatus.ok,
      confidence: 0.75,
      observations: observations,
      generatedAt: DateTime.now(),
      metadata: {
        'completedTaskCount': completedCount,
        'openTaskCount': openCount,
        'focusMinutes': snapshot.focusMinutesTotal,
        'xp': snapshot.xp,
        'streak': snapshot.streak,
        'auraScore': snapshot.auraScore,
        'averageGoalProgress': goalProgress,
        'averageMissionProgress': avgMissionProgress,
      },
    );
  }
}
