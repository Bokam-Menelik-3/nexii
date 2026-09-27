import '../models/intelligence_models.dart';

abstract class IntelligenceNode {
  String get nodeId;

  int get priority => 50;

  bool isRelevant(ContextSnapshot snapshot);

  IntelligenceResult execute(ContextSnapshot snapshot);
}
