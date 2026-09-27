import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class AuraScreen extends StatefulWidget {
  const AuraScreen({super.key});

  @override
  State<AuraScreen> createState() => _AuraScreenState();
}

class _AuraScreenState extends State<AuraScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _pulseAnim =
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = state.currentLocale.languageCode;
    final s = _S(lang);

    // ── SOURCE CANONIQUE — AUCUN RECALCUL ──────────────────────────────
    final int score = state.auraScore;
    final Map<String, String> auraInfo = state.auraLevelInfo;
    final String icon = auraInfo['icon'] ?? '✨';
    final String title = auraInfo['title'] ?? '';

    // Composantes réelles disponibles dans le runtime
    final int battery = state.mentalBattery;      // 0–100
    final int recovery = state.recoveryIndex;     // 0–100
    final int fatigue = state.cognitiveFatigue;   // 0–100
    final int emotLoad = state.emotionalLoad;     // 0–100
    final int focusMins = state.focusMinutesTotal;
    final int streak = state.streak;
    final int disc = state.disciplineScore;

    // Score normalisé 0.0–1.0 pour les visuels
    final double scoreNorm = (score / 100.0).clamp(0.0, 1.0);

    // Couleur Aura selon score canonique
    final Color auraColor = _auraColor(score);

    final bool hasData = score > 0 || battery > 0;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xff050a14) : const Color(0xfff5f8ff),
      appBar: _buildAppBar(context, isDark, s, icon, title),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 740),
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
              children: [
                if (!hasData) ...[
                  const SizedBox(height: 60),
                  _buildEmptyState(context, isDark, s, auraColor),
                  const SizedBox(height: 40),
                ] else ...[
                  // ── VISUEL AURA CENTRAL ──────────────────────────────
                  _buildAuraOrb(context, isDark, score, scoreNorm, auraColor, icon, title, s),
                  const SizedBox(height: 28),

                  // ── COMPRÉHENSION — ÉTAT ACTUEL ──────────────────────
                  _buildStateLine(context, isDark, score, auraColor, s),
                  const SizedBox(height: 22),

                  // ── CONTRIBUTIONS RÉELLES ────────────────────────────
                  _buildSectionLabel(s.sectionContrib, isDark),
                  const SizedBox(height: 10),
                  _buildContributions(
                    context,
                    isDark: isDark,
                    s: s,
                    battery: battery,
                    recovery: recovery,
                    fatigue: fatigue,
                    emotLoad: emotLoad,
                    focusMins: focusMins,
                    streak: streak,
                    disc: disc,
                  ),
                  const SizedBox(height: 28),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── COULEUR AURA SELON SCORE CANONIQUE ──────────────────────────────
  Color _auraColor(int score) {
    if (score <= 20) return const Color(0xffef4444); // rouge
    if (score <= 40) return const Color(0xfff59e0b); // orange
    if (score <= 60) return const Color(0xff8b5cf6); // purple
    if (score <= 75) return const Color(0xff2563eb); // blue
    if (score <= 90) return const Color(0xff10b981); // teal
    return const Color(0xff06b6d4);                 // cyan légendaire
  }

  // ── APP BAR ──────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool isDark,
    _S s,
    String icon,
    String title,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 18,
      title: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Text(
            s.screenTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: isDark ? Colors.white : const Color(0xff0f172a),
            ),
          ),
        ],
      ),
    );
  }

  // ── ORB AURA CENTRAL ─────────────────────────────────────────────────
  Widget _buildAuraOrb(
    BuildContext context,
    bool isDark,
    int score,
    double scoreNorm,
    Color auraColor,
    String icon,
    String title,
    _S s,
  ) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        final double pulse = _pulseAnim.value;
        return Center(
          child: Column(
            children: [
              // ── ORB ──────────────────────────────────────────────────
              Stack(
                alignment: Alignment.center,
                children: [
                  // Glow extérieur pulsé
                  Container(
                    width: 200 + 16 * pulse,
                    height: 200 + 16 * pulse,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          auraColor.withValues(
                              alpha: isDark
                                  ? 0.20 + 0.10 * pulse
                                  : 0.12 + 0.06 * pulse),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Glow intermédiaire
                  Container(
                    width: 160 + 8 * pulse,
                    height: 160 + 8 * pulse,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          auraColor.withValues(
                              alpha: isDark
                                  ? 0.30 + 0.12 * pulse
                                  : 0.18 + 0.06 * pulse),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Cercle principal
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? const Color(0xff111827)
                          : Colors.white,
                      border: Border.all(
                        color: auraColor.withValues(
                            alpha: isDark ? 0.50 : 0.35),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: auraColor.withValues(
                              alpha: isDark
                                  ? 0.30 + 0.12 * pulse
                                  : 0.15 + 0.06 * pulse),
                          blurRadius: 28 + 10 * pulse,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(icon,
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text(
                          '$score',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.0,
                            color: isDark
                                ? Colors.white
                                : const Color(0xff0f172a),
                          ),
                        ),
                        Text(
                          '/100',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? const Color(0xff475569)
                                : const Color(0xff94a3b8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // ── TITRE ÉTAT ───────────────────────────────────────────
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: auraColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              // ── BARRE DE SCORE ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Container(
                        height: 8,
                        color: isDark
                            ? const Color(0xff1e293b)
                            : const Color(0xffe8edf8),
                      ),
                      FractionallySizedBox(
                        widthFactor: scoreNorm,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                auraColor.withValues(alpha: 0.7),
                                auraColor,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── ÉTAT / DESCRIPTION ───────────────────────────────────────────────
  Widget _buildStateLine(
    BuildContext context,
    bool isDark,
    int score,
    Color auraColor,
    _S s,
  ) {
    final String description = s.auraDescription(score);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff111827) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: auraColor.withValues(alpha: isDark ? 0.20 : 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: auraColor.withValues(alpha: isDark ? 0.07 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        description,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: isDark
              ? const Color(0xff94a3b8)
              : const Color(0xff475569),
          height: 1.55,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ── SECTION LABEL ────────────────────────────────────────────────────
  Widget _buildSectionLabel(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: isDark
            ? const Color(0xff475569)
            : const Color(0xff94a3b8),
      ),
    );
  }

  // ── CONTRIBUTIONS RÉELLES ─────────────────────────────────────────────
  Widget _buildContributions(
    BuildContext context, {
    required bool isDark,
    required _S s,
    required int battery,
    required int recovery,
    required int fatigue,
    required int focusMins,
    required int streak,
    required int disc,
    required int emotLoad,
  }) {
    // Composantes directement disponibles dans le runtime
    // fatigue et emotLoad sont inversés (plus bas = meilleur)
    final List<_Contrib> contribs = [
      _Contrib(
        label: s.contribBattery,
        value: battery / 100.0,
        color: const Color(0xff10b981),
        icon: Icons.battery_charging_full_rounded,
        display: '$battery%',
      ),
      _Contrib(
        label: s.contribRecovery,
        value: recovery / 100.0,
        color: const Color(0xff2563eb),
        icon: Icons.self_improvement_rounded,
        display: '$recovery%',
      ),
      _Contrib(
        label: s.contribFatigue,
        value: (100 - fatigue) / 100.0,
        color: const Color(0xfff59e0b),
        icon: Icons.psychology_outlined,
        display: '$fatigue%',
        inverted: true,
      ),
      if (focusMins > 0)
        _Contrib(
          label: s.contribFocus,
          value: (focusMins / 120.0).clamp(0.0, 1.0),
          color: const Color(0xff8b5cf6),
          icon: Icons.timer_outlined,
          display: focusMins >= 60
              ? '${focusMins ~/ 60}h${focusMins % 60 > 0 ? " ${focusMins % 60}m" : ""}'
              : '${focusMins}m',
        ),
      if (streak > 0)
        _Contrib(
          label: s.contribStreak,
          value: (streak / 14.0).clamp(0.0, 1.0),
          color: const Color(0xffef4444),
          icon: Icons.local_fire_department_rounded,
          display: '$streak ${s.days}',
        ),
      if (disc > 0)
        _Contrib(
          label: s.contribDisc,
          value: (disc / 100.0).clamp(0.0, 1.0),
          color: const Color(0xff06b6d4),
          icon: Icons.bolt_rounded,
          display: '$disc',
        ),
    ];

    return Column(
      children: contribs
          .map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildContribRow(context, isDark, c),
              ))
          .toList(),
    );
  }

  Widget _buildContribRow(
      BuildContext context, bool isDark, _Contrib c) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff111827) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xff1e293b)
              : const Color(0xffe8edf8),
        ),
        boxShadow: [
          BoxShadow(
            color: c.color.withValues(alpha: isDark ? 0.07 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: c.color.withValues(alpha: isDark ? 0.14 : 0.09),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(c.icon, size: 15, color: c.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      c.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xffcbd5e1)
                            : const Color(0xff334155),
                      ),
                    ),
                    Text(
                      c.display,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: c.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Stack(
                    children: [
                      Container(
                        height: 6,
                        color: isDark
                            ? const Color(0xff1e293b)
                            : const Color(0xfff1f5f9),
                      ),
                      FractionallySizedBox(
                        widthFactor: c.value.clamp(0.0, 1.0),
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                c.color.withValues(alpha: 0.7),
                                c.color,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── EMPTY STATE ───────────────────────────────────────────────────────
  Widget _buildEmptyState(
      BuildContext context, bool isDark, _S s, Color auraColor) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(vertical: 60, horizontal: 28),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xff111827) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? const Color(0xff1e293b)
                  : const Color(0xffe8edf8),
            ),
            boxShadow: [
              BoxShadow(
                color: auraColor.withValues(
                    alpha: isDark
                        ? 0.06 + 0.04 * _pulseAnim.value
                        : 0.03 + 0.02 * _pulseAnim.value),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Column(
        children: [
          const Text('✨', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 16),
          Text(
            s.emptyTitle,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: isDark ? Colors.white : const Color(0xff0f172a),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            s.emptySubtitle,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? const Color(0xff64748b)
                  : const Color(0xff94a3b8),
              height: 1.55,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── DATA MODEL ────────────────────────────────────────────────────────
class _Contrib {
  final String label;
  final double value;
  final Color color;
  final IconData icon;
  final String display;
  final bool inverted;

  const _Contrib({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.display,
    this.inverted = false,
  });
}

// ── LOCALISATION ──────────────────────────────────────────────────────
class _S {
  final String lang;
  const _S(this.lang);

  bool get _en => lang == 'en';
  bool get _es => lang == 'es';

  String get screenTitle =>
      _en ? 'Aura' : (_es ? 'Aura' : 'Aura');

  String get sectionContrib =>
      _en ? 'WHAT SHAPES YOUR AURA' : (_es ? 'LO QUE FORMA TU AURA' : 'CE QUI FORME TON AURA');

  // Description déterministe alignée sur AuraNode (aucun recalcul de score)
  String auraDescription(int score) {
    if (score <= 20) {
      return _en
          ? 'Your energy is at its lowest. Rest is essential right now.'
          : (_es
              ? 'Tu energía está en su punto más bajo. El descanso es esencial ahora.'
              : 'Ton énergie est à son plus bas. Le repos est essentiel en ce moment.');
    } else if (score <= 40) {
      return _en
          ? 'You are in a rebuilding phase. Take care of yourself step by step.'
          : (_es
              ? 'Estás en una fase de reconstrucción. Cuídate paso a paso.'
              : 'Tu es en phase de reconstruction. Prends soin de toi pas à pas.');
    } else if (score <= 60) {
      return _en
          ? 'You are progressing. Your energy is building momentum.'
          : (_es
              ? 'Estás progresando. Tu energía está ganando impulso.'
              : 'Tu progresses. Ton énergie prend de l\'élan.');
    } else if (score <= 75) {
      return _en
          ? 'You are in balance. Your state is stable and sustainable.'
          : (_es
              ? 'Estás en equilibrio. Tu estado es estable y sostenible.'
              : 'Tu es en équilibre. Ton état est stable et durable.');
    } else if (score <= 90) {
      return _en
          ? 'Your Aura is high. You are operating at a strong level.'
          : (_es
              ? 'Tu Aura es alta. Estás operando a un nivel fuerte.'
              : 'Ton Aura est haute. Tu opères à un niveau fort.');
    } else {
      return _en
          ? 'Legendary Aura. You are at your peak state.'
          : (_es
              ? 'Aura Legendaria. Estás en tu estado máximo.'
              : 'Aura Légendaire. Tu es à ton état de pic.');
    }
  }

  // Contributions
  String get contribBattery =>
      _en ? 'Mental Battery' : (_es ? 'Batería Mental' : 'Batterie Mentale');
  String get contribRecovery =>
      _en ? 'Recovery' : (_es ? 'Recuperación' : 'Récupération');
  String get contribFatigue =>
      _en ? 'Cognitive Fatigue' : (_es ? 'Fatiga Cognitiva' : 'Fatigue Cognitive');
  String get contribFocus =>
      _en ? 'Focus Time' : (_es ? 'Tiempo Focus' : 'Temps Focus');
  String get contribStreak =>
      _en ? 'Active Streak' : (_es ? 'Racha Activa' : 'Série Active');
  String get contribDisc =>
      _en ? 'Discipline' : (_es ? 'Disciplina' : 'Discipline');
  String get days =>
      _en ? 'days' : (_es ? 'días' : 'jours');

  // Empty state
  String get emptyTitle => _en
      ? 'Your Aura is building.'
      : (_es ? 'Tu Aura se está formando.' : 'Ton Aura se construit.');
  String get emptySubtitle => _en
      ? 'Your Aura builds with your daily data.\nKeep going.'
      : (_es
          ? 'Tu Aura se construye con tus datos diarios.\nSigue adelante.'
          : 'Ton Aura se construit avec tes données quotidiennes.\nContinue.');
}
