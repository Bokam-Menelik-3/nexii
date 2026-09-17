import 'package:flutter/foundation.dart';
import 'aura_result.dart';

/// Domain State Manager for Aura score, level info, and 6-pillar calculations.
class AuraDomainState extends ChangeNotifier {
  double computeAuraP(List<Map<String, dynamic>> tasks, List<Map<String, dynamic>> livingGoals) {
    final completed = tasks.where((t) => t['isCompleted'] == true).length;
    final total = tasks.isEmpty ? 1 : tasks.length;
    final double tc = (completed / total) * 100;

    double opSum = 0;
    if (livingGoals.isNotEmpty) {
      for (var g in livingGoals) {
        final prog =
            (g['progress'] is num) ? (g['progress'] as num).toDouble() : 0.7;
        opSum += prog * 100;
      }
      opSum /= livingGoals.length;
    } else {
      opSum = 72.0;
    }
    const double m = 65.0; // Milestones
    return (tc * 0.5) + (opSum * 0.3) + (m * 0.2);
  }

  double computeAuraF(int focusMinutesTotal) {
    final double hf = (focusMinutesTotal / 60.0 * 25.0).clamp(0.0, 100.0);
    const double c = 82.0;
    const double d = 78.0;
    return (hf * 0.5) + (c * 0.3) + (d * 0.2);
  }

  double computeAuraE(int dailySleep, String selectedMood) {
    final double s = (dailySleep > 0 ? dailySleep * 10.0 : 80.0);
    const double rc = 85.0;
    double mh = 80.0;
    switch (selectedMood) {
      case 'Stressé':
        mh = 40.0;
        break;
      case 'Neutre':
        mh = 60.0;
        break;
      case 'Bien':
        mh = 80.0;
        break;
      case 'Inspiré':
        mh = 95.0;
        break;
      case 'Serein':
        mh = 100.0;
        break;
    }
    return (s * 0.35) + (rc * 0.35) + (mh * 0.30);
  }

  double computeAuraR(int streak) {
    final double streakScore = (streak * 10.0).clamp(0.0, 100.0);
    const double habitsScore = 80.0;
    return (streakScore * 0.6) + (habitsScore * 0.4);
  }

  double computeAuraG() {
    const double pr = 82.0;
    const double cl = 88.0;
    return (pr * 0.5) + (cl * 0.5);
  }

  double computeAuraW(int cognitiveFatigue) {
    final double stressInversed = (100.0 - cognitiveFatigue).clamp(0.0, 100.0);
    const double emotion = 82.0;
    const double balance = 80.0;
    return (stressInversed * 0.4) + (emotion * 0.3) + (balance * 0.3);
  }

  /// Computes canonical AuraResult given the 6 pillar inputs preserving exact formula
  AuraResult computeAura({
    required List<Map<String, dynamic>> tasks,
    required List<Map<String, dynamic>> livingGoals,
    required int focusMinutesTotal,
    required int dailySleep,
    required String selectedMood,
    required int streak,
    required int cognitiveFatigue,
  }) {
    final auraP = computeAuraP(tasks, livingGoals);
    final auraF = computeAuraF(focusMinutesTotal);
    final auraE = computeAuraE(dailySleep, selectedMood);
    final auraR = computeAuraR(streak);
    final auraG = computeAuraG();
    final auraW = computeAuraW(cognitiveFatigue);

    final double raw = (auraP * 0.25) +
        (auraF * 0.20) +
        (auraE * 0.20) +
        (auraR * 0.15) +
        (auraG * 0.10) +
        (auraW * 0.10);
    final int score = raw.round().clamp(0, 100);

    return getAuraResultForScore(score);
  }

  /// Classifies a score into an AuraResult with level info and icons
  AuraResult getAuraResultForScore(int score) {
    if (score <= 20) {
      return AuraResult(
        score: score,
        level: '0–20',
        icon: '🌑',
        title: 'Recharge nécessaire',
        action: 'Nexii réduit la pression et propose des petites victoires.',
      );
    } else if (score <= 40) {
      return AuraResult(
        score: score,
        level: '21–40',
        icon: '🌘',
        title: 'Reconstruction',
        action: 'Nexii allège le planning et propose des objectifs très accessibles.',
      );
    } else if (score <= 60) {
      return AuraResult(
        score: score,
        level: '41–60',
        icon: '🌗',
        title: 'Progression',
        action: 'Nexii maintient un rythme équilibré et consolide tes habitudes.',
      );
    } else if (score <= 75) {
      return AuraResult(
        score: score,
        level: '61–75',
        icon: '🌕',
        title: 'Équilibre',
        action: 'Excellente harmonie entre effort, focus et bien-être.',
      );
    } else if (score <= 90) {
      return AuraResult(
        score: score,
        level: '76–90',
        icon: '✨',
        title: 'Haute Aura',
        action: 'Nexii augmente progressivement les défis et optimisé ta productivité.',
      );
    } else {
      return AuraResult(
        score: score,
        level: '91–100',
        icon: '🌟',
        title: 'Aura Légendaire',
        action: 'Nexii active le mode "Peak Performance" pour libérer ton plein potentiel.',
      );
    }
  }
}
