/// Domain Result Model for Aura Calculation.
class AuraResult {
  final int score; // 0 to 100
  final String level;
  final String icon;
  final String title;
  final String action;

  const AuraResult({
    required this.score,
    required this.level,
    required this.icon,
    required this.title,
    required this.action,
  });

  Map<String, String> toLevelInfoMap() {
    return {
      'level': level,
      'icon': icon,
      'title': title,
      'action': action,
    };
  }
}
