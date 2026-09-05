import '../models/intelligence_models.dart';
import 'intelligence_node.dart';

class LivingGoalsNode extends IntelligenceNode {
  LivingGoalsNode();

  @override
  String get nodeId => 'living_goals';

  @override
  int get priority => 35;

  @override
  bool isRelevant(ContextSnapshot snapshot) {
    return snapshot.goals.isNotEmpty || snapshot.missions.isNotEmpty;
  }

  @override
  IntelligenceResult execute(ContextSnapshot snapshot) {
    final goals = snapshot.goals;
    final missions = snapshot.missions;
    final observations = <String>[];
    final riskFlags = <String>[];

    if (goals.isEmpty) {
      observations.add('aucun objectif actif détecté');
      return IntelligenceResult(
        nodeId: nodeId,
        status: IntelligenceStatus.idle,
        confidence: 0.5,
        observations: observations,
        generatedAt: DateTime.now(),
        metadata: {
          'goalCount': 0,
          'missionCount': missions.length,
          'primaryGoal': null,
        },
      );
    }

    final primaryGoal = goals.reduce((a, b) {
      if (a.progress == b.progress) return a;
      return a.progress > b.progress ? a : b;
    });

    final avgProgress =
        goals.fold<double>(0, (sum, goal) => sum + goal.progress) /
            goals.length;
    final openMissions =
        missions.where((mission) => !mission.isCompleted).length;

    observations.add('objectif principal : ${primaryGoal.title}');
    observations
        .add('progression actuelle : ${(primaryGoal.progress * 100).round()}%');
    observations.add(
        'progression moyenne des objectifs : ${(avgProgress * 100).round()}%');

    if (openMissions > 0) {
      observations.add('missions ouvertes : $openMissions');
    }

    IntelligenceStatus status;
    if (primaryGoal.progress < 0.35 || avgProgress < 0.35) {
      status = IntelligenceStatus.warning;
      riskFlags.add('goal_lag');
      observations.add('progression faible à surveiller');
    } else if (primaryGoal.progress >= 0.75 && avgProgress >= 0.7) {
      status = IntelligenceStatus.ok;
      observations.add('objectif principal en bonne trajectoire');
    } else {
      status = IntelligenceStatus.warning;
      observations.add('objectif vivant dans une trajectoire stable');
    }

    if (primaryGoal.progress < 0.25) {
      riskFlags.add('goal_at_risk');
    }

    return IntelligenceResult(
      nodeId: nodeId,
      status: status,
      confidence: 0.83,
      observations: observations,
      riskFlags: riskFlags,
      generatedAt: DateTime.now(),
      metadata: {
        'goalCount': goals.length,
        'missionCount': missions.length,
        'primaryGoalId': primaryGoal.id,
        'primaryGoalProgress': primaryGoal.progress,
        'averageGoalProgress': avgProgress,
        'openMissionCount': openMissions,
      },
    );
  }
}
