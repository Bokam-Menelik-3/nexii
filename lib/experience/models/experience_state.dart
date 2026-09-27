import 'experience_action.dart';
import 'experience_mode.dart';

/// What the current context means for presentation.
///
/// Immutable, Flutter-independent, produced only by ExperienceEngine.
class ExperienceState {
  const ExperienceState({
    required this.mode,
    required this.dominantFocus,
    required this.primaryAction,
    required this.informationDensity,
    required this.tone,
    required this.reasons,
  });

  final ExperienceMode mode;

  /// The single thing Home should make dominant for this state.
  final ExperienceDominantFocus dominantFocus;

  /// The single next step Home should offer to execute.
  final ExperienceAction primaryAction;

  final ExperienceDensity informationDensity;

  final ExperienceTone tone;

  /// Stable, human-readable keys explaining why this state was chosen.
  final List<String> reasons;
}

/// What the dominant surface is about.
enum ExperienceDominantFocus { recovery, triage, checkIn, primaryTask, goal, calm }

/// How much information Home should expose at once.
enum ExperienceDensity { minimal, reduced, standard }

/// Voice Home should use for the dominant surface.
enum ExperienceTone { gentle, neutral, encouraging }
