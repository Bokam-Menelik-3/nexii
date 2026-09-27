import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  void _showAddMissionDialog(BuildContext context, AppStateProvider state) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    int selectedXp = 50;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Créer une Mission', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Titre de la mission',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Récompense XP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      initialValue: selectedXp,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 30, child: Text('+30 XP')),
                        DropdownMenuItem(value: 50, child: Text('+50 XP')),
                        DropdownMenuItem(value: 100, child: Text('+100 XP')),
                        DropdownMenuItem(value: 200, child: Text('+200 XP')),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedXp = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final desc = descController.text.trim();
                    if (title.isNotEmpty) {
                      state.addMission(title, desc.isEmpty ? 'Mission personnalisée' : desc, selectedXp);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff8b5cf6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> allMissions = state.missions;
    final int totalMissions = allMissions.length;
    final int completedCount = allMissions.where((m) => m['isCompleted'] == true).length;
    final double overallProgress = totalMissions > 0 ? (completedCount / totalMissions) : 0.0;

    // Determine priority mission reliably from real data
    final openMissions = allMissions.where((m) => m['isCompleted'] != true).toList();
    Map<String, dynamic>? priorityMission;
    if (openMissions.isNotEmpty) {
      // Pick active mission with highest progress > 0, or highest XP, or first open mission
      openMissions.sort((a, b) {
        final aProg = (a['progress'] as num?)?.toDouble() ?? 0.0;
        final bProg = (b['progress'] as num?)?.toDouble() ?? 0.0;
        if (aProg != bProg) return bProg.compareTo(aProg);
        final aXp = (a['xp'] as num?)?.toInt() ?? 0;
        final bXp = (b['xp'] as num?)?.toInt() ?? 0;
        return bXp.compareTo(aXp);
      });
      priorityMission = openMissions.first;
    }

    final otherOpenMissions = openMissions.where((m) => m != priorityMission).toList();
    final inProgressMissions = otherOpenMissions.where((m) {
      final prog = (m['progress'] as num?)?.toDouble() ?? 0.0;
      return prog > 0.0;
    }).toList();
    final pendingMissions = otherOpenMissions.where((m) {
      final prog = (m['progress'] as num?)?.toDouble() ?? 0.0;
      return prog == 0.0;
    }).toList();
    final completedMissions = allMissions.where((m) => m['isCompleted'] == true).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.flag_rounded, color: Color(0xff2563eb)),
            const SizedBox(width: 10),
            Text(
              state.translate('tab_missions'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xff8b5cf6)),
            tooltip: 'Créer une mission',
            onPressed: () => _showAddMissionDialog(context, state),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              children: [
                // A. CONTEXTE & PROGRESSION RÉELLE
                _buildContextCard(context, state, isDark, totalMissions, completedCount, overallProgress),
                const SizedBox(height: 16),

                if (allMissions.isEmpty) ...[
                  _buildEmptyState(context, state, isDark),
                ] else ...[
                  // B. MISSION PRIORITAIRE
                  if (priorityMission != null) ...[
                    _buildSectionHeader(context, 'Mission Prioritaire', icon: Icons.star_rounded, color: const Color(0xfff59e0b)),
                    const SizedBox(height: 6),
                    _buildPriorityMissionCard(context, state, priorityMission, isDark),
                    const SizedBox(height: 16),
                  ],

                  // C. AUTRES MISSIONS PAR ÉTAT RÉEL
                  if (inProgressMissions.isNotEmpty) ...[
                    _buildSectionHeader(context, 'En cours (${inProgressMissions.length})', icon: Icons.trending_up, color: const Color(0xff2563eb)),
                    const SizedBox(height: 6),
                    ...inProgressMissions.map((m) => _buildMissionCard(context, state, m, isDark)),
                    const SizedBox(height: 12),
                  ],

                  if (pendingMissions.isNotEmpty) ...[
                    _buildSectionHeader(context, 'En attente (${pendingMissions.length})', icon: Icons.schedule, color: Colors.grey),
                    const SizedBox(height: 6),
                    ...pendingMissions.map((m) => _buildMissionCard(context, state, m, isDark)),
                    const SizedBox(height: 12),
                  ],

                  if (completedMissions.isNotEmpty) ...[
                    _buildSectionHeader(context, 'Terminées (${completedMissions.length})', icon: Icons.check_circle_outline, color: const Color(0xff22c55e)),
                    const SizedBox(height: 6),
                    ...completedMissions.map((m) => _buildMissionCard(context, state, m, isDark)),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- A. CONTEXTE ---
  Widget _buildContextCard(
    BuildContext context,
    AppStateProvider state,
    bool isDark,
    int totalMissions,
    int completedCount,
    double overallProgress,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xff8b5cf6).withValues(alpha: 0.15),
                    radius: 16,
                    child: const Icon(Icons.bolt_rounded, color: Color(0xff8b5cf6), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Niveau ${state.level}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        '${state.xp} / ${100 * state.level} XP',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xff2563eb).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedCount / $totalMissions terminées',
                  style: const TextStyle(
                    color: Color(0xff2563eb),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: totalMissions > 0 ? overallProgress : 0.0,
              backgroundColor: isDark ? const Color(0xff1e293b) : const Color(0xfff1f5f9),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff2563eb)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // --- B. MISSION PRIORITAIRE ---
  Widget _buildPriorityMissionCard(
    BuildContext context,
    AppStateProvider state,
    Map<String, dynamic> mission,
    bool isDark,
  ) {
    final String missionId = (mission['id'] ?? '').toString();
    final double progress = (mission['progress'] as num?)?.toDouble() ?? 0.0;
    final bool isCompleted = mission['isCompleted'] == true;
    final bool claimed = mission['claimed'] == true;
    final int xp = (mission['xp'] as num?)?.toInt() ?? 50;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xff8b5cf6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff8b5cf6).withValues(alpha: isDark ? 0.12 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isCompleted ? const Color(0xff22c55e) : const Color(0xff8b5cf6),
                  size: 26,
                ),
                onPressed: () => state.toggleMissionCompleted(missionId),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission['title'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if ((mission['description'] as String?)?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        mission['description'] ?? '',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xff8b5cf6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+$xp XP',
                  style: const TextStyle(
                    color: Color(0xff8b5cf6),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Real progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark ? const Color(0xff1e293b) : const Color(0xfff1f5f9),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff8b5cf6)),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: Color(0xff8b5cf6),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (isCompleted) {
                  if (!claimed) {
                    state.claimMissionXp(missionId);
                  }
                } else {
                  state.toggleMissionCompleted(missionId);
                }
              },
              icon: Icon(
                isCompleted
                    ? (claimed ? Icons.check : Icons.card_giftcard)
                    : Icons.check_circle_outline,
                size: 16,
              ),
              label: Text(
                isCompleted
                    ? (claimed ? state.translate('reward_claimed') : state.translate('claim_xp'))
                    : 'Marquer comme terminée',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompleted ? (claimed ? Colors.grey.shade400 : const Color(0xff22c55e)) : const Color(0xff8b5cf6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- C. CARTE MISSION CLASSIQUE ---
  Widget _buildMissionCard(
    BuildContext context,
    AppStateProvider state,
    Map<String, dynamic> mission,
    bool isDark,
  ) {
    final String missionId = (mission['id'] ?? '').toString();
    final double progress = (mission['progress'] as num?)?.toDouble() ?? 0.0;
    final bool isCompleted = mission['isCompleted'] == true;
    final bool claimed = mission['claimed'] == true;
    final int xp = (mission['xp'] as num?)?.toInt() ?? 50;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isCompleted ? const Color(0xff22c55e) : Colors.grey,
                  size: 22,
                ),
                onPressed: () => state.toggleMissionCompleted(missionId),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  mission['title'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xff8b5cf6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+$xp XP',
                  style: const TextStyle(
                    color: Color(0xff8b5cf6),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              if (missionId != '1' && missionId != '2' && missionId != '3') ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 18),
                  onPressed: () => state.deleteMission(missionId),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
          if ((mission['description'] as String?)?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: Text(
                mission['description'] ?? '',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11, height: 1.3),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark ? const Color(0xff1e293b) : const Color(0xfff1f5f9),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? const Color(0xff22c55e) : const Color(0xff2563eb),
                    ),
                    minHeight: 5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: isCompleted ? const Color(0xff22c55e) : const Color(0xff2563eb),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          if (isCompleted) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: claimed ? null : () => state.claimMissionXp(missionId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff8b5cf6),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xff22c55e).withValues(alpha: 0.1),
                  disabledForegroundColor: const Color(0xff22c55e),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 0,
                ),
                child: Text(
                  claimed ? state.translate('reward_claimed') : state.translate('claim_xp'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- EMPTY STATE ---
  Widget _buildEmptyState(BuildContext context, AppStateProvider state, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.flag_outlined, size: 44, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text(
            'Aucune mission active.',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            'Créez une mission pour définir votre prochaine étape de progression.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddMissionDialog(context, state),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Créer une mission', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff8b5cf6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {required IconData icon, required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
