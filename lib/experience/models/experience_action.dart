import '../../intelligence/models/intelligence_models.dart';

/// What Home must execute for a given experience state.
///
/// [actionType] is null when the next step is a local UI ritual with no
/// equivalent in [IntelligentActionType] (e.g. opening the daily check-in
/// dialog, or viewing goals in place).
///
/// [targetTab] mirrors the tab indices already hardcoded in Home today:
/// 0 Home, 1 Tasks, 2 Focus.
class ExperienceAction {
  const ExperienceAction({
    required this.actionType,
    this.targetId,
    required this.targetTab,
    required this.emphasis,
  });

  final IntelligentActionType? actionType;

  /// Optional entity the action applies to (task id, goal id).
  final String? targetId;

  /// Tab Home should navigate to when executing the action.
  final int targetTab;

  final ExperienceEmphasis emphasis;
}

/// Strength of the primary action, derived from N1's [PriorityLevel].
enum ExperienceEmphasis { gentle, standard, elevated }
