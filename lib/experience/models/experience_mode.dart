/// V1 Experience modes derived from the existing Home behavior.
///
/// This is a V1 product model, not a permanent final taxonomy.
/// Precedence (highest first): Recovery > Pressure > CheckIn > Priority > Calm.
enum ExperienceMode {
  recovery,
  pressure,
  checkIn,
  priority,
  calm;

  /// Precedence rank, lower index wins. Used by [ExperienceEngine] ordering
  /// and asserted directly by tests.
  int get precedenceIndex => switch (this) {
        ExperienceMode.recovery => 0,
        ExperienceMode.pressure => 1,
        ExperienceMode.checkIn => 2,
        ExperienceMode.priority => 3,
        ExperienceMode.calm => 4,
      };
}
