import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class ProgressionScreen extends StatefulWidget {
  const ProgressionScreen({super.key});

  @override
  State<ProgressionScreen> createState() => _ProgressionScreenState();
}

class _ProgressionScreenState extends State<ProgressionScreen> {
  int _selectedTimeHorizon = 1; // 0: Aujourd'hui, 1: Cette semaine, 2: Ce mois, 3: Cette année

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('📈', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('Ma Progression', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time Horizon Segmented Control
              Container(
                height: 46,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xff1e293b) : const Color(0xfff1f5f9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildTimePill('Aujourd\'hui', 0),
                    _buildTimePill('Cette semaine', 1),
                    _buildTimePill('Ce mois', 2),
                    _buildTimePill('Cette année', 3),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ✨ NEXII AURA SCORE CARD (0–100)
              _buildAuraScoreCard(context, state),
              const SizedBox(height: 20),

              // Question 1: Ai-je progressé ?
              _buildSectionCard(
                context,
                title: '1. Ai-je progressé ? 🎯',
                subtitle: 'Aperçu global de ton évolution',
                color: const Color(0xff2563eb),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            context,
                            label: 'Tâches accomplies',
                            value: '${state.tasks.where((t) => t['isCompleted'] == true).length}/${state.tasks.length}',
                            subtext: '+12% vs semaine passée',
                            icon: Icons.check_circle_outline,
                            color: const Color(0xff10b981),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricTile(
                            context,
                            label: 'Temps Focus total',
                            value: '${state.focusMinutesTotal ~/ 60}h ${state.focusMinutesTotal % 60}m',
                            subtext: 'Rythme régulier',
                            icon: Icons.timer_outlined,
                            color: const Color(0xff8b5cf6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            context,
                            label: 'Objectifs Vivants',
                            value: '${state.livingGoals.length} actifs',
                            subtext: '82% de réussite moy.',
                            icon: Icons.center_focus_strong,
                            color: const Color(0xfff59e0b),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricTile(
                            context,
                            label: 'Série (Streak)',
                            value: '${state.streakDays} jours 🔥',
                            subtext: 'Excellente régularité',
                            icon: Icons.local_fire_department_outlined,
                            color: const Color(0xffef4444),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Question 2: Qu'est-ce qui m'a aidé ?
              _buildSectionCard(
                context,
                title: '2. Qu\'est-ce qui m\'a aidé ? 💡',
                subtitle: 'Facteurs de succès identifiés par Nexii',
                color: const Color(0xff10b981),
                child: Column(
                  children: [
                    _buildInsightItem(
                      context,
                      icon: Icons.wb_sunny_outlined,
                      iconColor: const Color(0xfff59e0b),
                      title: 'Pic de concentration le matin',
                      description: 'Tu es 24% plus efficace entre 8h et 11h. Vos sessions Focus de matinée ont un taux de réussite de 94%.',
                    ),
                    const SizedBox(height: 10),
                    _buildInsightItem(
                      context,
                      icon: Icons.battery_charging_full,
                      iconColor: const Color(0xff10b981),
                      title: 'Maintien de la batterie mentale',
                      description: 'Prendre des micro-pauses de 5 min a permis d\'éviter la fatigue de 15h.',
                    ),
                    const SizedBox(height: 10),
                    _buildInsightItem(
                      context,
                      icon: Icons.auto_awesome,
                      iconColor: const Color(0xff8b5cf6),
                      title: 'Ajustement proactif Nexii Pulse',
                      description: 'L\'allègement automatique du planning mardi t\'a évité une surcharge cognitive.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Question 3: Que puis-je améliorer ?
              _buildSectionCard(
                context,
                title: '3. Que puis-je améliorer ? 🌱',
                subtitle: 'Recommandations simples et douces',
                color: const Color(0xff8b5cf6),
                child: Column(
                  children: [
                    _buildImprovementItem(
                      context,
                      title: 'Découper les sessions de fin d\'après-midi',
                      description: 'Après 16h, ta durée maximale de Focus optimale est de 20 min au lieu de 45 min.',
                      actionLabel: 'Ajuster les réglages Focus',
                      onAction: () => state.addNotification('Réglage Focus ⏱️', 'Durée Focus après-midi adaptée à 20 min.', 'info'),
                    ),
                    const SizedBox(height: 10),
                    _buildImprovementItem(
                      context,
                      title: 'Anticiper les tâches complexes',
                      description: 'Placer tes devoirs et projets importants directement en début de journée.',
                      actionLabel: 'Activer le tri intelligent',
                      onAction: () => state.applyAIStrategy(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 🧠 NEXII STATE (Productivité, Focus, Bien-être)
              _buildSectionCard(
                context,
                title: '🧠 Nexii State',
                subtitle: 'Niveaux actuels d\'équilibre mental et performance',
                color: const Color(0xff06b6d4),
                child: Column(
                  children: [
                    _buildStateBar(context, label: 'Productivité', value: 0.75, color: const Color(0xff2563eb)),
                    const SizedBox(height: 10),
                    _buildStateBar(context, label: 'Focus', value: 0.85, color: const Color(0xff8b5cf6)),
                    const SizedBox(height: 10),
                    _buildStateBar(context, label: 'Bien-être', value: 0.70, color: const Color(0xff10b981)),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 🏆 NEXII MOMENTS
              _buildSectionCard(
                context,
                title: '🏆 Nexii Moments',
                subtitle: 'Tes étapes marquantes et trophées débloqués',
                color: const Color(0xfff59e0b),
                child: Column(
                  children: [
                    _buildMomentTile(
                      context,
                      title: '⭐ Première semaine réussie',
                      date: 'Obtenu cette semaine',
                      icon: Icons.emoji_events,
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 8),
                    _buildMomentTile(
                      context,
                      title: '⭐ 100 heures Focus',
                      date: 'Objectif à 82%',
                      icon: Icons.timer,
                      color: const Color(0xff8b5cf6),
                    ),
                    const SizedBox(height: 8),
                    _buildMomentTile(
                      context,
                      title: '⭐ Objectif Examen terminé',
                      date: 'Validé avec succès',
                      icon: Icons.task_alt,
                      color: const Color(0xff10b981),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 💰 FINANCE (Ressources liées aux objectifs)
              _buildSectionCard(
                context,
                title: '💰 Finance & Ressources',
                subtitle: 'Gestion du budget lié à tes objectifs de vie',
                color: const Color(0xff10b981),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Solde restant', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text(
                              '${state.remainingBudget.toStringAsFixed(0)} FCFA',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xff10b981)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xff10b981).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.laptop_mac, size: 16, color: Color(0xff10b981)),
                              SizedBox(width: 6),
                              Text(
                                'Acheter un ordinateur',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xff10b981)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Progression objectif matériel', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        Text('60%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xff2563eb))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: const LinearProgressIndicator(
                        value: 0.60,
                        backgroundColor: Colors.black12,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xff2563eb)),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xff8b5cf6).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xff8b5cf6).withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.auto_awesome, color: Color(0xff8b5cf6), size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'IA Finance : "À ce rythme d\'épargne, ton objectif sera atteint dans 4 mois !"',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xff8b5cf6)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePill(String label, int index) {
    final isSelected = _selectedTimeHorizon == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTimeHorizon = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xff2563eb) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected && !isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? (isDark ? Colors.white : const Color(0xff1e293b))
                  : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1e293b) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String label,
    required String value,
    required String subtext,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xff94a3b8) : const Color(0xff64748b),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImprovementItem(
    BuildContext context, {
    required String title,
    required String description,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.3)),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xff8b5cf6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onAction,
              icon: const Icon(Icons.arrow_forward, size: 12),
              label: Text(actionLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // --- ✨ NEXII AURA SCORE CARD (0–100) ---
  Widget _buildAuraScoreCard(BuildContext context, AppStateProvider state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final score = state.auraScore;
    final info = state.auraLevelInfo;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xff1e1b4b), const Color(0xff311b92)]
              : [const Color(0xffeff6ff), const Color(0xfff3e8ff)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xff8b5cf6).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff8b5cf6).withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xff8b5cf6).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Color(0xff8b5cf6), size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nexii Aura Score ✨',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Score dynamique d\'équilibre & productivité (0–100)',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xff8b5cf6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Text(info['icon'] ?? '✨', style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '$score',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Current Level Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.white70,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xff8b5cf6).withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Text(info['icon'] ?? '✨', style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Niveau : ${info['title']} (${info['level']})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff8b5cf6)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        info['action'] ?? '',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'DÉCOMPOSITION MATHÉMATIQUE DE L\'AURA :',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Colors.grey),
          ),
          const SizedBox(height: 10),

          // 6 Formula Components Grid
          Row(
            children: [
              Expanded(
                child: _buildAuraSubComponentTile(
                  context,
                  label: 'Progression (P)',
                  weight: '25%',
                  score: state.auraP.round(),
                  color: const Color(0xff2563eb),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAuraSubComponentTile(
                  context,
                  label: 'Focus (F)',
                  weight: '20%',
                  score: state.auraF.round(),
                  color: const Color(0xff8b5cf6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildAuraSubComponentTile(
                  context,
                  label: 'Énergie (E)',
                  weight: '20%',
                  score: state.auraE.round(),
                  color: const Color(0xff10b981),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAuraSubComponentTile(
                  context,
                  label: 'Régularité (R)',
                  weight: '15%',
                  score: state.auraR.round(),
                  color: const Color(0xfff59e0b),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildAuraSubComponentTile(
                  context,
                  label: 'Objectifs (G)',
                  weight: '10%',
                  score: state.auraG.round(),
                  color: const Color(0xff06b6d4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAuraSubComponentTile(
                  context,
                  label: 'Bien-être (W)',
                  weight: '10%',
                  score: state.auraW.round(),
                  color: const Color(0xffec4899),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuraSubComponentTile(
    BuildContext context, {
    required String label,
    required String weight,
    required int score,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.black38 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Poids : $weight',
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$score',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateBar(BuildContext context, {required String label, required double value, required Color color}) {
    final pct = (value * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text('$pct%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildMomentTile(
    BuildContext context, {
    required String title,
    required String date,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : const Color(0xfff8fafc),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Icon(Icons.stars, color: color, size: 16),
        ],
      ),
    );
  }
}
