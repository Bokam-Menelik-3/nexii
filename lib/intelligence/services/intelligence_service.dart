import '../context/context_snapshot_builder.dart';
import '../engines/n1_decision_engine.dart';
import '../models/intelligence_models.dart';
import '../nodes/anticipate_node.dart';
import '../nodes/aura_node.dart';
import '../nodes/living_goals_node.dart';
import '../nodes/measure_node.dart';
import '../nodes/observe_node.dart';
import '../nodes/pulse_node.dart';
import '../nodes/recommend_node.dart';
import '../nodes/understand_node.dart';

class IntelligenceService {
  IntelligenceService({
    this.snapshotBuilder = const ContextSnapshotBuilder(),
    this.n1DecisionEngine = const N1DecisionEngine(),
    ObserveNode? observeNode,
    UnderstandNode? understandNode,
    PulseNode? pulseNode,
    AuraNode? auraNode,
    LivingGoalsNode? livingGoalsNode,
    AnticipateNode? anticipateNode,
    RecommendNode? recommendNode,
    MeasureNode? measureNode,
  })  : observeNode = observeNode ?? ObserveNode(),
        understandNode = understandNode ?? UnderstandNode(),
        pulseNode = pulseNode ?? PulseNode(),
        auraNode = auraNode ?? AuraNode(),
        livingGoalsNode = livingGoalsNode ?? LivingGoalsNode(),
        anticipateNode = anticipateNode ?? AnticipateNode(),
        recommendNode = recommendNode ?? RecommendNode(),
        measureNode = measureNode ?? MeasureNode();

  final ContextSnapshotBuilder snapshotBuilder;
  final N1DecisionEngine n1DecisionEngine;
  final ObserveNode observeNode;
  final UnderstandNode understandNode;
  final PulseNode pulseNode;
  final AuraNode auraNode;
  final LivingGoalsNode livingGoalsNode;
  final AnticipateNode anticipateNode;
  final RecommendNode recommendNode;
  final MeasureNode measureNode;

  ContextSnapshot buildSnapshot({
    required String? userId,
    required String? displayName,
    required int? age,
    required bool isAnonymous,
    required String locale,
    required bool onboardingComplete,
    required List<Map<String, dynamic>> tasks,
    required List<Map<String, dynamic>> agendaEvents,
    required List<Map<String, dynamic>> goals,
    required List<Map<String, dynamic>> missions,
    required int xp,
    required int level,
    required int streak,
    required int disciplineScore,
    required int auraScore,
    required String? currentMood,
    required int? dailyMood,
    required int? dailyEnergy,
    required int? dailyMotivation,
    required int? dailyStress,
    required int? dailySleep,
    required bool hasCheckedInToday,
    required int mentalBattery,
    required int focusMinutesTotal,
    required double totalBudget,
    required double remainingBudget,
    required DateTime now,
    List<String>? riskFlags,
    RiskLevel riskLevel = RiskLevel.low,
  }) {
    return snapshotBuilder.build(
      userId: userId,
      displayName: displayName,
      age: age,
      isAnonymous: isAnonymous,
      locale: locale,
      onboardingComplete: onboardingComplete,
      tasks: tasks,
      agendaEvents: agendaEvents,
      goals: goals,
      missions: missions,
      xp: xp,
      level: level,
      streak: streak,
      disciplineScore: disciplineScore,
      auraScore: auraScore,
      currentMood: currentMood,
      dailyMood: dailyMood,
      dailyEnergy: dailyEnergy,
      dailyMotivation: dailyMotivation,
      dailyStress: dailyStress,
      dailySleep: dailySleep,
      hasCheckedInToday: hasCheckedInToday,
      mentalBattery: mentalBattery,
      focusMinutesTotal: focusMinutesTotal,
      totalBudget: totalBudget,
      remainingBudget: remainingBudget,
      now: now,
      riskFlags: riskFlags,
      riskLevel: riskLevel,
    );
  }

  SituationModel understandSituation(ContextSnapshot snapshot) {
    return understandNode.evaluateSituation(snapshot);
  }

  N1Summary evaluateN1(ContextSnapshot snapshot) {
    return n1DecisionEngine.evaluate(snapshot);
  }

  IntelligenceResult runObserve(ContextSnapshot snapshot) {
    return observeNode.execute(snapshot);
  }

  IntelligenceResult runUnderstand(ContextSnapshot snapshot) {
    return understandNode.execute(snapshot);
  }

  IntelligenceResult runPulse(ContextSnapshot snapshot) {
    return pulseNode.execute(snapshot);
  }

  IntelligenceResult runAura(ContextSnapshot snapshot) {
    return auraNode.execute(snapshot);
  }

  IntelligenceResult runLivingGoals(ContextSnapshot snapshot) {
    return livingGoalsNode.execute(snapshot);
  }

  IntelligenceResult runAnticipate(ContextSnapshot snapshot) {
    return anticipateNode.execute(snapshot);
  }

  IntelligenceResult runRecommend(ContextSnapshot snapshot) {
    return recommendNode.execute(snapshot);
  }

  IntelligenceResult runMeasure(ContextSnapshot snapshot) {
    return measureNode.execute(snapshot);
  }
}
