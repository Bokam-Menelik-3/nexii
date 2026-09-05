import '../models/intelligence_models.dart';
import 'intelligence_node.dart';

class ObserveNode extends IntelligenceNode {
  ObserveNode();

  @override
  String get nodeId => 'observe';

  @override
  int get priority => 10;

  @override
  bool isRelevant(ContextSnapshot snapshot) {
    return true;
  }

  @override
  IntelligenceResult execute(ContextSnapshot snapshot) {
    final observations = <String>[];

    final taskCount = snapshot.tasks.length;
    final openTaskCount = snapshot.openTasks.length;
    final completedTaskCount = taskCount - openTaskCount;

    if (taskCount == 0) {
      observations.add('aucune tâche dans le snapshot');
    } else {
      observations.add('$taskCount tâches au total');
      observations.add('$openTaskCount tâches ouvertes');
      observations.add('$completedTaskCount tâches terminées');
    }

    final agendaCount = snapshot.agendaEvents.length;
    if (agendaCount == 0) {
      observations.add('aucun événement planifié');
    } else {
      observations.add('$agendaCount événement(s) planifié(s)');
    }

    final upcomingCount = snapshot.upcomingEvents.length;
    if (upcomingCount == 0) {
      observations.add('aucun événement à venir');
    } else {
      observations.add('$upcomingCount événement(s) à venir');
    }

    final goalCount = snapshot.goals.length;
    if (goalCount == 0) {
      observations.add('aucun objectif actif');
    } else {
      observations.add('$goalCount objectif(s) actif(s)');
    }

    final missionCount = snapshot.missions.length;
    if (missionCount == 0) {
      observations.add('aucune mission active');
    } else {
      observations.add('$missionCount mission(s) active(s)');
    }

    final focusMinutes = snapshot.focusMinutesTotal;
    observations.add('${focusMinutes} minutes de focus');

    final mentalBattery = snapshot.mentalBattery;
    observations.add('mental battery : $mentalBattery');

    if (snapshot.currentMood != null) {
      observations.add('humeur actuelle : ${snapshot.currentMood}');
    } else {
      observations.add('humeur actuelle : non renseignée');
    }

    if (snapshot.dailyEnergy != null) {
      observations.add('énergie du jour : ${snapshot.dailyEnergy}');
    }
    if (snapshot.dailyMotivation != null) {
      observations.add('motivation du jour : ${snapshot.dailyMotivation}');
    }
    if (snapshot.dailyStress != null) {
      observations.add('stress du jour : ${snapshot.dailyStress}');
    }
    if (snapshot.dailySleep != null) {
      observations.add('sommeil du jour : ${snapshot.dailySleep} heures');
    }

    observations.add('xp : ${snapshot.xp}');
    observations.add('niveau : ${snapshot.level}');
    observations.add('streak : ${snapshot.streak}');
    observations.add('aura score : ${snapshot.auraScore}');

    final state = snapshot.mentalBattery >= 70
        ? IntelligenceStatus.ok
        : snapshot.mentalBattery >= 40
            ? IntelligenceStatus.warning
            : IntelligenceStatus.critical;

    return IntelligenceResult(
      nodeId: nodeId,
      status: state,
      confidence: 0.9,
      observations: observations,
      riskFlags: snapshot.riskFlags,
      generatedAt: DateTime.now(),
      metadata: {
        'taskCount': taskCount,
        'openTaskCount': openTaskCount,
        'agendaCount': agendaCount,
        'upcomingCount': upcomingCount,
        'goalCount': goalCount,
        'missionCount': missionCount,
        'focusMinutes': focusMinutes,
        'mentalBattery': mentalBattery,
        'auraScore': snapshot.auraScore,
      },
    );
  }
}
