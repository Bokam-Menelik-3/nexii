import '../models/intelligence_models.dart';
import 'intelligence_node.dart';

class AuraNode extends IntelligenceNode {
  AuraNode();

  @override
  String get nodeId => 'aura';

  @override
  int get priority => 30;

  @override
  bool isRelevant(ContextSnapshot snapshot) {
    return snapshot.auraScore != 0 ||
        snapshot.mentalBattery != 0 ||
        snapshot.focusMinutesTotal != 0 ||
        snapshot.currentMood != null;
  }

  @override
  IntelligenceResult execute(ContextSnapshot snapshot) {
    final score = snapshot.auraScore;
    final battery = snapshot.mentalBattery;
    final mood = snapshot.currentMood ?? 'non renseignée';

    String level;
    String title;
    IntelligenceStatus status;

    if (score <= 20) {
      level = '0–20';
      title = 'Recharge nécessaire';
      status = IntelligenceStatus.critical;
    } else if (score <= 40) {
      level = '21–40';
      title = 'Reconstruction';
      status = IntelligenceStatus.warning;
    } else if (score <= 60) {
      level = '41–60';
      title = 'Progression';
      status = IntelligenceStatus.warning;
    } else if (score <= 75) {
      level = '61–75';
      title = 'Équilibre';
      status = IntelligenceStatus.ok;
    } else if (score <= 90) {
      level = '76–90';
      title = 'Haute Aura';
      status = IntelligenceStatus.ok;
    } else {
      level = '91–100';
      title = 'Aura Légendaire';
      status = IntelligenceStatus.ok;
    }

    final observations = <String>[
      'Aura actuelle : $score/100',
      'niveau Aura : $level',
      'état Aura : $title',
      'batterie mentale : $battery%',
      'humeur actuelle : $mood',
    ];

    return IntelligenceResult(
      nodeId: nodeId,
      status: status,
      confidence: 0.9,
      observations: observations,
      generatedAt: DateTime.now(),
      metadata: {
        'auraScore': score,
        'auraLevel': level,
        'auraTitle': title,
        'mentalBattery': battery,
      },
    );
  }
}
