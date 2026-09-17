import '../models/intelligence_models.dart';
import 'intelligence_node.dart';

class AnticipateNode extends IntelligenceNode {
  AnticipateNode();

  @override
  String get nodeId => 'anticipate';

  @override
  int get priority => 40;

  @override
  bool isRelevant(ContextSnapshot snapshot) {
    return snapshot.openTasks.isNotEmpty ||
        snapshot.mentalBattery < 55 ||
        snapshot.dailyStress != null ||
        snapshot.focusMinutesTotal > 0;
  }

  AnticipationModel evaluateAnticipation(ContextSnapshot snapshot) {
    final situation = SituationModel.fromSnapshot(snapshot);
    return AnticipationModel.evaluate(snapshot, situation);
  }

  @override
  IntelligenceResult execute(ContextSnapshot snapshot) {
    final anticipation = evaluateAnticipation(snapshot);
    final openTaskCount = snapshot.openTasks.length;
    final battery = snapshot.mentalBattery;
    final stress = snapshot.dailyStress ?? 0;
    final focusMinutes = snapshot.focusMinutesTotal;
    final goals = snapshot.goals;

    final observations = <String>[];
    final riskFlags = <String>[];

    int riskScore = 0;

    if (openTaskCount >= 3) {
      riskScore += 2;
      observations.add('plusieurs tâches ouvertes : $openTaskCount');
    }
    if (battery < 45) {
      riskScore += 2;
      observations.add('batterie mentale faible : $battery%');
    }
    if (stress >= 60) {
      riskScore += 2;
      observations.add('stress actuel élevé : $stress');
    }
    if (focusMinutes < 30 && goals.isNotEmpty) {
      riskScore += 1;
      observations.add('faible cadence de focus : $focusMinutes minutes');
    }

    if (riskScore >= 5) {
      observations.add(
          'si la situation actuelle continue, le risque de surcharge ou de retard demeure élevé');
      riskFlags.add('anticipation_risk');
      return IntelligenceResult(
        nodeId: nodeId,
        status: IntelligenceStatus.warning,
        confidence: 0.76,
        observations: observations,
        riskFlags: riskFlags,
        generatedAt: DateTime.now(),
        metadata: {
          'riskScore': riskScore,
          'openTaskCount': openTaskCount,
          'mentalBattery': battery,
          'dailyStress': stress,
          'focusMinutes': focusMinutes,
        },
      );
    }

    observations
        .add('aucun risque immédiat détecté selon les données actuelles');
    observations.add('batterie mentale : $battery%');
    return IntelligenceResult(
      nodeId: nodeId,
      status: IntelligenceStatus.ok,
      confidence: 0.68,
      observations: observations,
      generatedAt: DateTime.now(),
      metadata: {
        'riskScore': riskScore,
        'openTaskCount': openTaskCount,
        'mentalBattery': battery,
        'dailyStress': stress,
        'focusMinutes': focusMinutes,
        'anticipationType': anticipation.type,
        'anticipationDescription': anticipation.description,
        'anticipationHorizon': anticipation.horizon,
        'anticipationConfidence': anticipation.confidence,
        'affectedDomain': anticipation.affectedDomain,
      },
    );
  }
}
