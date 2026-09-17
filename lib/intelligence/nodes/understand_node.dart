import '../models/intelligence_models.dart';
import 'intelligence_node.dart';

class UnderstandNode extends IntelligenceNode {
  UnderstandNode();

  @override
  String get nodeId => 'understand';

  @override
  int get priority => 20;

  @override
  bool isRelevant(ContextSnapshot snapshot) {
    return snapshot.tasks.isNotEmpty ||
        snapshot.openTasks.isNotEmpty ||
        snapshot.mentalBattery != 0 ||
        snapshot.focusMinutesTotal != 0 ||
        snapshot.dailyStress != null ||
        snapshot.dailySleep != null;
  }

  SituationModel evaluateSituation(ContextSnapshot snapshot) {
    return SituationModel.fromSnapshot(snapshot);
  }

  @override
  IntelligenceResult execute(ContextSnapshot snapshot) {
    final situation = evaluateSituation(snapshot);
    final openTaskCount = snapshot.openTasks.length;
    final taskCount = snapshot.tasks.length;
    final battery = snapshot.mentalBattery;
    final focusMinutes = snapshot.focusMinutesTotal;
    final stress = snapshot.dailyStress ?? 0;
    final sleep = snapshot.dailySleep ?? 0;
    final mood = snapshot.currentMood ?? 'non renseignée';

    final observations = <String>[];
    String signal;

    if (taskCount == 0 && openTaskCount == 0) {
      signal = 'état stable';
      observations.add('aucune tâche active détectée dans le snapshot');
    } else if (openTaskCount >= 3 || (taskCount >= 5 && battery < 45)) {
      signal = 'charge de travail élevée';
      observations
          .add('charge de travail élevée : $openTaskCount tâches ouvertes');
      observations.add('batterie mentale : $battery%');
      if (focusMinutes < 30) {
        observations.add(
            'baisse d\'activité à surveiller : seulement $focusMinutes minutes de focus');
      }
    } else if (battery < 45 || stress >= 60 || sleep <= 6) {
      signal = 'baisse d\'activité à surveiller';
      observations.add('baisse d\'activité à surveiller');
      observations.add('batterie mentale : $battery%');
      observations.add('stress du jour : $stress');
      observations.add('sommeil du jour : $sleep heures');
    } else {
      signal = 'état stable';
      observations.add('état stable : la charge actuelle reste gérable');
      observations.add('batterie mentale : $battery%');
      observations.add('humeur actuelle : $mood');
    }

    if (focusMinutes > 0) {
      observations.add('focus total : $focusMinutes minutes');
    }

    final status = battery < 35
        ? IntelligenceStatus.critical
        : battery < 50 || stress >= 70
            ? IntelligenceStatus.warning
            : IntelligenceStatus.ok;

    return IntelligenceResult(
      nodeId: nodeId,
      status: status,
      confidence: 0.82,
      observations: observations,
      riskFlags:
          battery < 35 || stress >= 70 ? const ['workload_pressure'] : const [],
      generatedAt: DateTime.now(),
      metadata: {
        'signal': signal,
        'openTaskCount': openTaskCount,
        'taskCount': taskCount,
        'mentalBattery': battery,
        'focusMinutes': focusMinutes,
        'dailyStress': stress,
        'dailySleep': sleep,
        'capacityLevel': situation.capacityLevel,
        'workloadLevel': situation.workloadLevel,
        'currentFriction': situation.currentFriction,
      },
    );
  }
}
