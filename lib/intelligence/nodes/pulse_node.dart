import '../models/intelligence_models.dart';
import 'intelligence_node.dart';

class PulseNode extends IntelligenceNode {
  PulseNode();

  @override
  String get nodeId => 'pulse';

  @override
  int get priority => 25;

  @override
  bool isRelevant(ContextSnapshot snapshot) {
    return snapshot.mentalBattery != 0 ||
        snapshot.dailyEnergy != null ||
        snapshot.dailyMotivation != null ||
        snapshot.dailyStress != null ||
        snapshot.dailySleep != null ||
        snapshot.focusMinutesTotal != 0;
  }

  @override
  IntelligenceResult execute(ContextSnapshot snapshot) {
    final battery = snapshot.mentalBattery;
    final energy = snapshot.dailyEnergy ?? 0;
    final motivation = snapshot.dailyMotivation ?? 0;
    final stress = snapshot.dailyStress ?? 0;
    final sleep = snapshot.dailySleep ?? 0;
    final focus = snapshot.focusMinutesTotal;
    final mood = snapshot.currentMood ?? 'non renseignée';

    String pulseState;
    IntelligenceStatus status;

    if (battery < 35 || stress >= 75) {
      pulseState = 'recovery_needed';
      status = IntelligenceStatus.critical;
    } else if (battery < 55 || energy < 45 || motivation < 45) {
      pulseState = 'watch';
      status = IntelligenceStatus.warning;
    } else if (battery >= 70 && stress <= 40 && energy >= 60) {
      pulseState = 'stable';
      status = IntelligenceStatus.ok;
    } else {
      pulseState = 'mixed';
      status = IntelligenceStatus.warning;
    }

    final observations = <String>[
      'batterie mentale : $battery%',
      'focus total : $focus minutes',
      'énergie du jour : $energy',
      'motivation du jour : $motivation',
      'humeur actuelle : $mood',
    ];

    if (snapshot.dailyStress != null) {
      observations.add('stress du jour : $stress');
    }
    if (snapshot.dailySleep != null) {
      observations.add('sommeil du jour : $sleep heures');
    }

    return IntelligenceResult(
      nodeId: nodeId,
      status: status,
      confidence: 0.8,
      observations: observations,
      riskFlags: pulseState == 'recovery_needed' || pulseState == 'watch'
          ? const ['pulse_watch']
          : const [],
      generatedAt: DateTime.now(),
      metadata: {
        'pulseState': pulseState,
        'mentalBattery': battery,
        'focusMinutes': focus,
        'dailyEnergy': energy,
        'dailyMotivation': motivation,
        'dailyStress': stress,
        'dailySleep': sleep,
      },
    );
  }
}
