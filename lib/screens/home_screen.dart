import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _agendaController = TextEditingController();
  bool _hasMadeWish = false;
  bool _isPersonalizationExpanded = false;
  bool _showAdvancedHomePanels = false;

  @override
  void dispose() {
    _agendaController.dispose();
    super.dispose();
  }

  void _showNotificationsBottomSheet(
      BuildContext context, AppStateProvider state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final unreadCount =
                state.notifications.where((n) => n['read'] == false).length;

            return FractionallySizedBox(
              heightFactor: 0.75,
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.notifications_active,
                                  color: Color(0xff8b5cf6)),
                              const SizedBox(width: 8),
                              const Text(
                                'Notifications',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              if (unreadCount > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$unreadCount non lues',
                                    style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Actions row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: state.notifications.isEmpty
                                ? null
                                : () {
                                    state.markAllNotificationsAsRead();
                                    setModalState(() {});
                                  },
                            child: const Text('Tout marquer lu',
                                style: TextStyle(
                                    color: Color(0xff8b5cf6),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ),
                          TextButton(
                            onPressed: state.notifications.isEmpty
                                ? null
                                : () {
                                    state.clearAllNotifications();
                                    setModalState(() {});
                                  },
                            child: const Text('Tout effacer',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      // Notification List
                      Expanded(
                        child: state.notifications.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.notifications_none,
                                        size: 64, color: Colors.grey.shade300),
                                    const SizedBox(height: 12),
                                    const Text(
                                        'Aucune notification pour le moment',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 13)),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: state.notifications.length,
                                itemBuilder: (context, index) {
                                  final n = state.notifications[index];
                                  final isUnread = n['read'] == false;

                                  // Determine type icon & color
                                  IconData iconData = Icons.info_outline;
                                  Color typeColor = Colors.blue;
                                  if (n['type'] == 'success') {
                                    iconData = Icons.check_circle_outline;
                                    typeColor = Colors.green;
                                  } else if (n['type'] == 'warning') {
                                    iconData = Icons.warning_amber_outlined;
                                    typeColor = Colors.amber;
                                  } else if (n['type'] == 'xp') {
                                    iconData = Icons.star_border;
                                    typeColor = Colors.purple;
                                  }

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isUnread
                                          ? const Color(0xff8b5cf6)
                                              .withValues(alpha: 0.04)
                                          : Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isUnread
                                            ? const Color(0xff8b5cf6)
                                                .withValues(alpha: 0.15)
                                            : Theme.of(context)
                                                .dividerColor
                                                .withValues(alpha: 0.5),
                                        width: isUnread ? 1.5 : 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: typeColor.withValues(
                                                alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(iconData,
                                              color: typeColor, size: 18),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      n['title'] ?? '',
                                                      style: TextStyle(
                                                        fontWeight: isUnread
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                  if (isUnread)
                                                    Container(
                                                      width: 6,
                                                      height: 6,
                                                      decoration:
                                                          const BoxDecoration(
                                                        color:
                                                            Color(0xff8b5cf6),
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                n['content'] ?? '',
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                n['date'] != null
                                                    ? DateTime.parse(n['date'])
                                                        .toLocal()
                                                        .toString()
                                                        .substring(0, 16)
                                                    : '',
                                                style: TextStyle(
                                                  color: Colors.grey.shade400,
                                                  fontSize: 9,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    // Calculate task completion rate
    double completionRate = 0.0;
    if (state.tasks.isNotEmpty) {
      final completed =
          state.tasks.where((t) => t['isCompleted'] == true).length;
      completionRate = (completed / state.tasks.length) * 100;
    }

    // Completed challenges
    final completedChallenges = state.missions
        .where((m) => m['isCompleted'] == true || m['claimed'] == true)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xff2563eb)),
            const SizedBox(width: 8),
            Text(
              state.translate('app_name'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          // Notification Bell Icon with dynamic Badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, size: 24),
                onPressed: () => _showNotificationsBottomSheet(context, state),
              ),
              if (state.notifications
                  .where((n) => n['read'] == false)
                  .isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 24),
            tooltip: 'Profil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6.0, left: 4.0),
            child: GestureDetector(
              onTap: () => _showHpiDialog(context, state),
              child: Chip(
                avatar:
                    const Icon(Icons.star, size: 14, color: Color(0xfff59e0b)),
                label: Text(
                  'HPI ${state.humanPerformanceIndex}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: Color(0xfff59e0b)),
                ),
                backgroundColor: const Color(0xfff59e0b).withValues(alpha: 0.1),
                side: const BorderSide(color: Color(0xfff59e0b), width: 0.5),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0, left: 2.0),
            child: Chip(
              label: Text(
                'Niv. ${state.level}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              backgroundColor: const Color(0xff8b5cf6).withValues(alpha: 0.1),
              side: const BorderSide(color: Color(0xff8b5cf6), width: 0.5),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Mode Crise Banner ---
              if (state.isCrisisMode)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xfffef2f2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xfffca5a5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xffef4444).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shield,
                            color: Color(0xffef4444), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'MODE CRISE ACTIVÉ 🛡️',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xff991b1b)),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Interface allégée. Seule la priorité vitale est conservée pour préserver ton énergie.',
                              style: TextStyle(
                                  fontSize: 11, color: Color(0xff7f1d1d)),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => state.toggleCrisisMode(),
                        child: const Text('Quitter',
                            style: TextStyle(
                                color: Color(0xffef4444),
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                    ],
                  ),
                ),

              // Welcome text
              Text(
                '${state.translate('welcome_back')}${state.profileName.isNotEmpty ? ", ${state.profileName}" : ""}',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Productivité naturelle • IA invisible & bienveillante',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // --- 🎭 0. CHARTE D'HUMEUR ("VOTRE HUMEUR DU JOUR") ---
              _buildMoodSelectorCard(context, state),
              const SizedBox(height: 16),

              // --- 🎯 1. MA MISSION ---
              _buildMaMissionCard(context, state),
              const SizedBox(height: 16),

              // --- 🧠 2. MON ÉTAT ---
              _buildMonEtatCard(context, state),
              const SizedBox(height: 16),

              // --- 🟦 3. NEXII PULSE (ONLY WHEN ACTIVE / RELEVANT) ---
              if (state.isPulseActive || state.cognitiveFatigue > 40) ...[
                _buildNexiiPulseCard(context, state),
                const SizedBox(height: 16),
              ],

              // --- 📅 4. AUJOURD'HUI ---
              _buildAujourdhuiSummaryCard(context, state),
              const SizedBox(height: 16),

              // --- 🤫 PERSONNALISATION DISCRÈTE (OPTIONAL ACCORDION) ---
              if (_showAdvancedHomePanels)
                _buildDiscreetPersonalizationCard(context, state),
              const SizedBox(height: 24),

              if (_showAdvancedHomePanels) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.5)),
                  ),
                  child: const Text(
                    'Surface avancée masquée en beta — réservée aux diagnostics internes.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],

              if (state.isTodayBirthday) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xfff59e0b),
                        Color(0xffec4899),
                        Color(0xff8b5cf6)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xffec4899).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '🎉 🎂 🎈',
                            style: TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.translate('birthday_title'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        state.translate('birthday_desc'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!_hasMadeWish)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xffec4899),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.star,
                                color: Color(0xfff59e0b)),
                            label: Text(
                              state.translate('birthday_action'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            onPressed: () {
                              setState(() {
                                _hasMadeWish = true;
                              });
                              state.addFocusMinutes(
                                  10); // Award XP and minutes as a gift
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      state.translate('birthday_wish_success')),
                                  backgroundColor: const Color(0xffec4899),
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                state.translate('birthday_wish_success'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              if (_showAdvancedHomePanels) ...[
                // Aura Status Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff2563eb), Color(0xff8b5cf6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff2563eb).withValues(alpha: 0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.spa,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${state.translate('aura_title')} (${state.auraLabel})',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.auraDescription,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 68,
                            height: 68,
                            child: CircularProgressIndicator(
                              value: state.auraPercentage / 100,
                              strokeWidth: 6,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xff22c55e)),
                            ),
                          ),
                          Text(
                            '${state.auraPercentage.toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Streak & Validation Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.local_fire_department,
                              color: Colors.amber, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.translate('activity_streak'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                state.translate('streak_desc'),
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${state.streak} ${state.translate('active_state')}',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.isDayValidated
                            ? null
                            : () => state.validateDay(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2563eb),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              const Color(0xff22c55e).withValues(alpha: 0.2),
                          disabledForegroundColor: const Color(0xff22c55e),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: Text(
                          state.isDayValidated
                              ? state.translate('already_validated')
                              : state.translate('validate_day'),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 😊 Check-in Quotidien Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: state.hasCheckedInToday
                      ? const Color(0xff22c55e).withValues(alpha: 0.08)
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: state.hasCheckedInToday
                        ? const Color(0xff22c55e).withValues(alpha: 0.2)
                        : Theme.of(context).dividerColor,
                  ),
                ),
                child: state.hasCheckedInToday
                    ? Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Color(0xff22c55e), size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Bilan quotidien complété !',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xff16a34a)),
                                ),
                                Text(
                                  'Humeur : ${state.dailyMood}/5 • Énergie : ${state.dailyEnergy}/5 • Stress : ${state.dailyStress}/5',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.emoji_emotions,
                                  color: Color(0xffeab308), size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Check-in Quotidien',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Prenez 10 secondes pour évaluer votre état afin que le Coach IA ajuste votre journée.',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 11, height: 1.3),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                _showCheckInDialog(context, state);
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                side:
                                    const BorderSide(color: Color(0xff2563eb)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                              ),
                              child: const Text(
                                'Faire mon bilan',
                                style: TextStyle(
                                    color: Color(0xff2563eb),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 20),

              // Overview Header
              Text(
                state.translate('quick_view'),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 12),

              // Overview List (Tasks Completion Indicator)
              _buildOverviewCard(
                context,
                icon: Icons.playlist_add_check,
                iconColor: const Color(0xff2563eb),
                title:
                    '${state.tasks.length} ${state.translate('daily_tasks')}',
                subtitle: state.tasks.isNotEmpty
                    ? state.tasks.map((t) => t['title']).join(' • ')
                    : state.translate('all_completed'),
                trailing: '${completionRate.toInt()}%',
              ),
              const SizedBox(height: 12),

              // Focus recommendation
              _buildOverviewCard(
                context,
                icon: Icons.timer,
                iconColor: const Color(0xff8b5cf6),
                title: state.translate('recommended_focus'),
                subtitle: '25 mins • Ambiance ${state.selectedSound}',
                trailing: state.translate('start_action'),
                onTap: () => state.setTabIndex(2),
              ),
              const SizedBox(height: 24),

              // Objectives (Objectifs) Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🎯 Vos Objectifs Actifs',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        size: 20, color: Color(0xff2563eb)),
                    onPressed: () {
                      _showAddGoalDialog(context, state);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: state.goals.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text(
                            'Aucun objectif actif. Ajoutez-en un !',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                      )
                    : Column(
                        children: state.goals.map<Widget>((goal) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: InkWell(
                              onTap: () {
                                _showEditGoalDialog(context, state, goal);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            goal['title'] as String,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          '${((goal['progress'] as num) * 100).toInt()}%',
                                          style: const TextStyle(
                                              color: Color(0xff2563eb),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: (goal['progress'] as num)
                                            .toDouble(),
                                        minHeight: 6,
                                        backgroundColor:
                                            Colors.grey.withValues(alpha: 0.1),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                Color(0xff2563eb)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 24),

              // Agenda Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.translate('agenda_title'),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontSize: 16),
                  ),
                  const Icon(Icons.calendar_today,
                      size: 18, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),

              // Agenda Items
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  children: [
                    if (state.agendaEvents.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          state.translate('no_events'),
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      )
                    else
                      ...state.agendaEvents.map((event) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xff2563eb)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  event['time'] ?? '08:00',
                                  style: const TextStyle(
                                    color: Color(0xff2563eb),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  event['title'] ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    const Divider(height: 24),
                    // Quick add agenda
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _agendaController,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: state.translate('placeholder_event'),
                              hintStyle: const TextStyle(fontSize: 12),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle,
                              color: Color(0xff2563eb)),
                          onPressed: () {
                            final text = _agendaController.text.trim();
                            if (text.isNotEmpty) {
                              // Generate random hour/time
                              final hour =
                                  8 + (state.agendaEvents.length * 2) % 12;
                              final timeStr =
                                  "${hour.toString().padLeft(2, '0')}:00";
                              state.addAgendaEvent(text, timeStr);
                              _agendaController.clear();
                            }
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // General Stats block
              Text(
                state.translate('stats_title'),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  _buildStatItem(
                      context,
                      state.translate('focus_hours'),
                      '${(state.focusMinutesTotal / 60).toStringAsFixed(1)} h',
                      Icons.access_time),
                  const SizedBox(width: 12),
                  _buildStatItem(
                      context,
                      state.translate('challenges_completed'),
                      '$completedChallenges',
                      Icons.emoji_events),
                  const SizedBox(width: 12),
                  _buildStatItem(context, state.translate('success_rate'),
                      '${completionRate.toInt()}%', Icons.trending_up),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xff2563eb).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              trailing,
              style: const TextStyle(
                color: Color(0xff2563eb),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: content,
    );
  }

  Widget _buildStatItem(
      BuildContext context, String label, String val, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: const Color(0xff2563eb)),
            const SizedBox(height: 8),
            Text(
              val,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckInDialog(BuildContext context, AppStateProvider state) {
    int mood = 3;
    int energy = 3;
    int motivation = 3;
    int stress = 3;
    int sleep = 3;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget buildRatingRow(
                String label, int currentVal, Function(int) onChanged) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$label : $currentVal/5',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(5, (index) {
                      final val = index + 1;
                      final isSelected = val == currentVal;
                      return IconButton(
                        icon: Icon(
                          isSelected ? Icons.star : Icons.star_border,
                          color: isSelected
                              ? const Color(0xffeab308)
                              : Colors.grey,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            onChanged(val);
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text('Check-in Quotidien',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildRatingRow('Humeur', mood, (v) => mood = v),
                    buildRatingRow('Énergie', energy, (v) => energy = v),
                    buildRatingRow(
                        'Motivation', motivation, (v) => motivation = v),
                    buildRatingRow('Stress', stress, (v) => stress = v),
                    buildRatingRow('Sommeil', sleep, (v) => sleep = v),
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
                    state.submitDailyCheckIn(
                        mood, energy, motivation, stress, sleep);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563eb),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Valider'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddGoalDialog(BuildContext context, AppStateProvider state) {
    final titleController = TextEditingController();
    String category = 'Scolaire';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text('Ajouter un Objectif',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Ex: Finir mon projet d\'art',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Catégorie',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          category = val;
                        });
                      }
                    },
                    items: [
                      'Scolaire',
                      'Professionnel',
                      'Financier',
                      'Sportif',
                      'Personnel'
                    ]
                        .map((cat) =>
                            DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isNotEmpty) {
                      state.addGoal(title, category);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563eb),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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

  void _showEditGoalDialog(
      BuildContext context, AppStateProvider state, Map<String, dynamic> goal) {
    double progress = (goal['progress'] as num).toDouble();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(goal['title'] as String,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Catégorie: ${goal['category']}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 16),
                  Text('Progression: ${(progress * 100).toInt()}%',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  Slider(
                    value: progress,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (val) {
                      setDialogState(() {
                        progress = val;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    state.deleteGoal(goal['id'] as String);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Objectif supprimé')),
                    );
                  },
                  child: const Text('Supprimer',
                      style: TextStyle(color: Colors.redAccent)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    state.updateGoalProgress(goal['id'] as String, progress);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563eb),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ignore: unused_element
  void _showTimelineDialog(BuildContext context, AppStateProvider state) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.history, color: Color(0xff8b5cf6)),
              SizedBox(width: 8),
              Text('Frise Chronologique Nexii 📜',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: state.personalTimeline.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item['period'] as String,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff2563eb),
                                    fontSize: 13)),
                            Text(item['date'] as String,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 10)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text('Humeur : ${item['mood']}',
                                style: const TextStyle(fontSize: 11)),
                            const SizedBox(width: 12),
                            Text('Énergie : ${item['battery']}',
                                style: const TextStyle(
                                    fontSize: 11, color: Color(0xff22c55e))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                            'Tâches: ${item['tasksDone']} • Focus: ${item['focus']}',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 6),
                        Text(item['highlight'] as String,
                            style: const TextStyle(
                                fontSize: 11, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  // --- NEXT GEN MODAL DIALOGS ---

  void _showHpiDialog(BuildContext context, AppStateProvider state) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.star, color: Color(0xfff59e0b)),
              SizedBox(width: 8),
              Text('Human Performance Index 🌟',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xfff59e0b).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${state.humanPerformanceIndex} / 100',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                            color: Color(0xfff59e0b)),
                      ),
                      const SizedBox(height: 4),
                      const Text('Indice global de performance humaine',
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  children: state.humanPerformanceBreakdown.entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.key,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500)),
                          Text('${e.value}%',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff2563eb))),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  // ignore: unused_element
  void _showLifeGraphDialog(BuildContext context, AppStateProvider state) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Text('🧬', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text('Life Graph (Graphe de Vie)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nexii relie automatiquement tes projets, tâches, personnes, émotions et notes dans ton graphe de connaissances personnel :',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: state.lifeGraphNodes.map((node) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(node['icon'] as String,
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(node['label'] as String,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff8b5cf6)
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(node['category'] as String,
                                            style: const TextStyle(
                                                fontSize: 9,
                                                color: Color(0xff8b5cf6),
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(node['details'] as String,
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  // ignore: unused_element
  void _showDigitalTwinDialog(BuildContext context, AppStateProvider state) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Text('🔮', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text('Digital Twin 2.0 (Simulateur)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                      'Simulation multi-scénarios du futur de tes objectifs :',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 12),
                  Column(
                    children: state.digitalTwinScenarios.map((scen) {
                      final bool isRec = scen['recommended'] == true;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isRec
                              ? const Color(0xff2563eb).withValues(alpha: 0.06)
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: isRec
                                  ? const Color(0xff2563eb)
                                  : Theme.of(context).dividerColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Text(scen['name'] as String,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12))),
                                Text('Risque : ${scen['failureRisk']}%',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                        color: scen['failureRisk'] > 50
                                            ? Colors.red
                                            : Colors.green)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                                'Charge : ${scen['workload']} • Fin estimée : ${scen['completionDate']}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 6),
                            Text(scen['desc'] as String,
                                style: const TextStyle(
                                    fontSize: 11, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  void _showCognitiveLoadDialog(BuildContext context, AppStateProvider state) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Text('🧠', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text('Cognitive Load Engine',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Charge Mentale Actuelle :',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(state.cognitiveLoadLevel,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.amber)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: state.cognitiveLoadFactors.map((f) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(f['label'] as String,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                              Text(f['val'] as String,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: Color(0xff8b5cf6))),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(f['desc'] as String,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff10b981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.spa, size: 16),
                        label: Text(
                            state.isRecoveryMode
                                ? 'Quitter Récupération'
                                : 'Activer Mode Récupération 🌿',
                            style: const TextStyle(fontSize: 11)),
                        onPressed: () {
                          state.toggleRecoveryMode();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  // ignore: unused_element
  void _showGoalDecomposerDialog(BuildContext context, AppStateProvider state) {
    final TextEditingController goalCtrl =
        TextEditingController(text: "Obtenir mon GCE / Examen");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Text('🎯', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text('Goal Decomposer IA',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'Entre ton grand objectif, l\'IA le découpera automatiquement en micro-actions :',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 10),
                TextField(
                  controller: goalCtrl,
                  decoration: InputDecoration(
                    labelText: 'Ton grand objectif',
                    hintText: 'Ex: Obtenir mon GCE, Lancer mon app...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2563eb),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                state.injectDecomposedGoalIntoTasks(goalCtrl.text);
                Navigator.pop(context);
              },
              child: const Text('Décomposer & Injecter 🚀'),
            ),
          ],
        );
      },
    );
  }

  // ignore: unused_element
  void _showMonthlyStoryDialog(BuildContext context, AppStateProvider state) {
    final story = state.monthlyStoryData;
    final stats = story['stats'] as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Text('📖', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(story['monthTitle'] as String,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15))),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(story['summary'] as String,
                      style: const TextStyle(fontSize: 12, height: 1.4)),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xffec4899).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Tâches validées: ${stats['tasksDone']}',
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.bold)),
                            Text('Focus: ${stats['focusHours']}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xffec4899))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Série max: ${stats['bestStreak']}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                            Text('Domaine clé: ${stats['topDomain']}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Moments Forts du Mois :',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (story['keyMoments'] as List<String>).map((m) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(m, style: const TextStyle(fontSize: 11)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  // ignore: unused_element
  void _showWeeklyMeetingDialog(BuildContext context, AppStateProvider state) {
    final meeting = state.weeklyMeetingSummary;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(meeting['title'] as String,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15))),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date : ${meeting['date']}',
                      style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('Ordre du jour :',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (meeting['agenda'] as List<String>)
                        .map((a) => Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child:
                                  Text(a, style: const TextStyle(fontSize: 11)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text('Décisions & Recommandations IA :',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xff6366f1))),
                  const SizedBox(height: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (meeting['decisions'] as List<String>)
                        .map((d) => Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child:
                                  Text(d, style: const TextStyle(fontSize: 11)),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  // ignore: unused_element
  void _showMemoryReplayDialog(BuildContext context, AppStateProvider state) {
    String selectedMonth = "Mars 2026";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final data = state.replayMonthData(selectedMonth);

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Text('⏳', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text('Memory Replay (Time Machine)',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<String>(
                      value: selectedMonth,
                      isExpanded: true,
                      items:
                          ["Mars 2026", "Juin 2026", "Juillet 2026"].map((m) {
                        return DropdownMenuItem(value: m, child: Text(m));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedMonth = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Période rejouée : ${data['period']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xff14b8a6))),
                          const SizedBox(height: 6),
                          Text(
                              'Humeur : ${data['mood']} • Batterie moyenne : ${data['battery']}',
                              style: const TextStyle(fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(
                              'Tâches: ${data['tasksDone']} • Focus: ${data['focusHours']}',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 8),
                          Text(data['highlight'] as String,
                              style: const TextStyle(
                                  fontSize: 11, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ignore: unused_element
  void _showKnowledgeEngineDialog(
      BuildContext context, AppStateProvider state) {
    final TextEditingController queryCtrl = TextEditingController();
    String answer = "";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Text('🔎', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text('Mémoire IA QA',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                        'Pose n\'importe quelle question sur ton historique, tes fiches, objectifs et habitudes :',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: queryCtrl,
                      decoration: InputDecoration(
                        labelText: 'Question...',
                        hintText: 'Ex: Quand ai-je commencé Flutter ?',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        suffixIcon: IconButton(
                          icon:
                              const Icon(Icons.send, color: Color(0xff2563eb)),
                          onPressed: () {
                            setState(() {
                              answer =
                                  state.queryPersonalKnowledge(queryCtrl.text);
                            });
                          },
                        ),
                      ),
                    ),
                    if (answer.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xff2563eb).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(answer,
                            style: const TextStyle(fontSize: 12, height: 1.3)),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildNexiiPulseCard(BuildContext context, AppStateProvider state) {
    final pulse = state.activePulse;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xff2563eb).withValues(alpha: 0.18),
            const Color(0xff3b82f6).withValues(alpha: 0.12),
            const Color(0xff1d4ed8).withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: const Color(0xff2563eb).withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff2563eb).withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xff2563eb),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff2563eb).withValues(alpha: 0.8),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Nexii Pulse',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xff2563eb)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xff2563eb).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Intervention Proactive',
                  style: TextStyle(
                      color: Color(0xff2563eb),
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Message Body
          const Text(
            'J\'ai détecté une baisse de concentration depuis trois jours.',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, height: 1.3),
          ),
          const SizedBox(height: 6),
          Text(
            'Pour augmenter tes chances d\'atteindre ton objectif, j\'ai préparé un planning alternatif qui réduit ta charge de ${pulse['chargeReduction']} tout en maintenant la même date de fin.',
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withValues(alpha: 0.85),
                height: 1.4),
          ),
          const SizedBox(height: 14),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563eb),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.bolt, size: 16),
                  label: const Text('Appliquer',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () => state.applyPulseAction(),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xff2563eb),
                  side: const BorderSide(color: Color(0xff2563eb)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                onPressed: () => _showPulseWhyDialog(context, state),
                child: const Text('Voir pourquoi',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPulseWhyDialog(BuildContext context, AppStateProvider state) {
    final pulse = state.activePulse;
    final reasons = pulse['reasons'] as List<String>;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Text('🟦', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text('Analyse & Repères du Pulse',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xff2563eb).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Modèle Détecté :',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: Color(0xff2563eb))),
                        const SizedBox(height: 2),
                        Text(pulse['detectedPattern'] as String,
                            style: const TextStyle(fontSize: 11)),
                        const SizedBox(height: 8),
                        Text('Impact sur l\'échéance :',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: Color(0xff2563eb))),
                        const SizedBox(height: 2),
                        Text(pulse['impact'] as String,
                            style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Pourquoi ce réajustement fonctionne :',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: reasons.map((r) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Text(r,
                            style: const TextStyle(fontSize: 11, height: 1.3)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2563eb),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                state.applyPulseAction();
              },
              child: const Text('Appliquer maintenant'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLivingGoalCard(BuildContext context, AppStateProvider state) {
    final goals = state.livingGoals;
    if (goals.isEmpty) return const SizedBox.shrink();
    final topGoal = goals.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xff10b981).withValues(alpha: 0.15),
            const Color(0xff059669).withValues(alpha: 0.08),
            const Color(0xff3b82f6).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: const Color(0xff10b981).withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff10b981).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xff10b981),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.center_focus_strong,
                        color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Objectif Vivant (Living Goal) 🎯',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xff10b981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Probabilité : ${topGoal['successProbability']}%',
                  style: const TextStyle(
                      color: Color(0xff059669),
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Goal Title & Deadline
          Text(
            topGoal['title'] as String,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.event, size: 13, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Échéance : ${topGoal['deadline']} • Importance : ${topGoal['importance']}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Completion Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Progression : ${topGoal['completion']}%',
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600)),
                  Text('${topGoal['autoAdjustCount']} réajustements IA',
                      style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xff10b981),
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (topGoal['completion'] as int) / 100.0,
                  minHeight: 7,
                  backgroundColor:
                      const Color(0xff10b981).withValues(alpha: 0.15),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xff10b981)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Live State AI Insight
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome,
                    size: 16, color: Color(0xff10b981)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    topGoal['liveStateMessage'] as String,
                    style: const TextStyle(fontSize: 11, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff10b981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.bolt, size: 16),
                  label: const Text('Auto-Optimiser ⚡',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  onPressed: () => state.triggerLivingGoalAutoOptimization(
                      topGoal['id'] as String),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xff059669),
                  side: const BorderSide(color: Color(0xff10b981)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onPressed: () =>
                    _showLivingGoalDetailDialog(context, state, topGoal),
                child: const Text('Inspecter l\'Objet',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLivingGoalDetailDialog(
      BuildContext context, AppStateProvider state, Map<String, dynamic> goal) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                  child: Text('Living Goal : ${goal['title']}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15))),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xff10b981).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Probabilité de succès :',
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.bold)),
                            Text('${goal['successProbability']}%',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff059669))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Échéance :',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                            Text(goal['deadline'] as String,
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Santé de l\'Objet :',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                            Text(goal['aiHealth'] as String,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff10b981))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Tâches & Dépendances Associées :',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (goal['dependentTasks'] as List<String>).map((t) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                size: 14, color: Color(0xff10b981)),
                            const SizedBox(width: 6),
                            Expanded(
                                child: Text(t,
                                    style: const TextStyle(fontSize: 11))),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  const Text('Régulation Automatique IA :',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    'Cet objectif ajuste continuellement sa sous-arborescence de tâches selon tes variations d\'énergie et ta charge mentale calculée.',
                    style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.8),
                        height: 1.3),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff10b981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                state.triggerLivingGoalAutoOptimization(goal['id'] as String);
                Navigator.pop(context);
              },
              child: const Text('Déclencher Auto-Ajustement'),
            ),
          ],
        );
      },
    );
  }

  // ignore: unused_element
  Widget _buildCapabilityPill(
    BuildContext context, {
    required String icon,
    required String title,
    required String badge,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: TextStyle(
                    fontSize: 9, color: color, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 🎭 CHARTE D'HUMEUR ("VOTRE HUMEUR DU JOUR") ---
  Widget _buildMoodSelectorCard(BuildContext context, AppStateProvider state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Map<String, String>> moods = [
      {'emoji': '😔', 'label': 'Stressé'},
      {'emoji': '😐', 'label': 'Neutre'},
      {'emoji': '🙂', 'label': 'Bien'},
      {'emoji': '🤩', 'label': 'Inspiré'},
      {'emoji': '🧘', 'label': 'Serein'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1e293b) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0),
          width: 1,
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
          Text(
            'VOTRE HUMEUR DU JOUR',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: isDark ? const Color(0xff94a3b8) : const Color(0xff64748b),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: moods.map((m) {
              final String label = m['label']!;
              final String emoji = m['emoji']!;
              final bool isSelected = state.selectedMood == label;

              return Expanded(
                child: GestureDetector(
                  onTap: () => state.setMood(label),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                              ? const Color(0xff1e3a8a).withValues(alpha: 0.5)
                              : const Color(0xffeff6ff))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xff3b82f6)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          emoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xff2563eb)
                                : (isDark
                                    ? const Color(0xffcbd5e1)
                                    : const Color(0xff64748b)),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- 🤫 DISCREET & CALM PERSONALIZATION PANEL ---
  Widget _buildDiscreetPersonalizationCard(
      BuildContext context, AppStateProvider state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xff1e293b).withValues(alpha: 0.7)
            : const Color(0xfff8fafc),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isPersonalizationExpanded = !_isPersonalizationExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xff8b5cf6).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.tune_rounded,
                          color: Color(0xff8b5cf6), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Personnalisation & Bilans Intelligents',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          state.isPulseActive
                              ? '1 recommandation d\'allègement disponible • Appuyer pour voir'
                              : 'Ajustements fluides en tâche de fond • Discret',
                          style:
                              TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  _isPersonalizationExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
          if (_isPersonalizationExpanded) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),

            // Living Goal compact view
            _buildLivingGoalCard(context, state),
            const SizedBox(height: 12),

            // Pulse if active
            if (state.isPulseActive) ...[
              _buildNexiiPulseCard(context, state),
              const SizedBox(height: 12),
            ],

            // 🌦️ Mode Vie Réelle (Context Awareness)
            _buildContextAwarenessSelector(context, state),
            const SizedBox(height: 12),

            // 🎚️ Niveau d'Autonomie Nexii
            _buildAutonomyLevelSelector(context, state),
            const SizedBox(height: 12),

            // 🌱 Nexii Identity Summary
            _buildIdentitySummaryCard(context, state),
            const SizedBox(height: 12),

            // 🧬 Nexii Learning Loop ("Ce que Nexii a appris sur toi")
            _buildLearningLoopCard(context, state),
            const SizedBox(height: 12),

            // 🏆 Nexii Moments (Timeline)
            _buildNexiiMomentsCard(context, state),
            const SizedBox(height: 12),

            // 🧪 Nexii Labs Toggle
            _buildNexiiLabsToggle(context, state),
            const SizedBox(height: 12),

            // AI Action Quick Trigger
            OutlinedButton.icon(
              onPressed: () => state.applyAIStrategy(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.auto_awesome,
                  size: 16, color: Color(0xff8b5cf6)),
              label: const Text('Harmoniser mon emploi du temps avec Nexii',
                  style: TextStyle(fontSize: 12, color: Color(0xff8b5cf6))),
            )
          ],
        ],
      ),
    );
  }

  // --- 🎯 CARD 1: MA MISSION ---
  Widget _buildMaMissionCard(BuildContext context, AppStateProvider state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topGoal = state.livingGoals.isNotEmpty
        ? state.livingGoals.first
        : {
            'title': 'Réussir le devoir de Maths',
            'progress': 0.72,
            'nextStep': 'Réviser les fonctions pendant 25 min',
          };

    final String title = topGoal['title'] ?? 'Réussir le devoir de Maths';
    final double progress = (topGoal['progress'] is num)
        ? (topGoal['progress'] as num).toDouble()
        : 0.72;
    final String nextStep =
        topGoal['nextStep'] ?? 'Réviser les fonctions pendant 25 min';

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xff2563eb).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.center_focus_strong,
                        color: Color(0xff2563eb), size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Ma Mission 🎯',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xff2563eb).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                      color: Color(0xff2563eb),
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor:
                  isDark ? Colors.white12 : const Color(0xffe2e8f0),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xff2563eb)),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xff0f172a) : const Color(0xfff8fafc),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: isDark
                      ? const Color(0xff334155)
                      : const Color(0xffe2e8f0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Color(0xff2563eb)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Prochaine étape :',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(nextStep,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2563eb),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: const Text('Commencer',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              onPressed: () {
                state.addNotification('Session Démarrée ⏱️',
                    'Concentration maximale sur : $nextStep', 'info');
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- 🧠 CARD 2: MON ÉTAT & NEXII AURA SCORE ---
  Widget _buildMonEtatCard(BuildContext context, AppStateProvider state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auraInfo = state.auraLevelInfo;
    final auraScore = state.auraScore;

    return GestureDetector(
      onTap: () => _showCognitiveLoadDialog(context, state),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff1e293b) : Colors.white,
          borderRadius: BorderRadius.circular(20),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xff10b981).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${state.mentalBattery}%',
                style: const TextStyle(
                    color: Color(0xff10b981),
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Mon État 🧠',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xff8b5cf6).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${auraInfo['icon']} $auraScore Aura',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff8b5cf6)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${auraInfo['title']} • ${auraInfo['action']}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xff10b981),
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  // --- 📅 CARD 4: AUJOURD'HUI ---
  Widget _buildAujourdhuiSummaryCard(
      BuildContext context, AppStateProvider state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completedCount =
        state.tasks.where((t) => t['isCompleted'] == true).length;
    final totalCount = state.tasks.length;

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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xff8b5cf6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.today, color: Color(0xff8b5cf6), size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Aujourd\'hui 📅',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryGridTile(
                  context,
                  icon: Icons.priority_high_rounded,
                  color: const Color(0xffef4444),
                  label: 'Tâches prioritaires',
                  value: '$completedCount/$totalCount',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryGridTile(
                  context,
                  icon: Icons.access_time_filled_rounded,
                  color: const Color(0xff3b82f6),
                  label: 'Temps disponible',
                  value: '4h 15m',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSummaryGridTile(
                  context,
                  icon: Icons.timer,
                  color: const Color(0xff8b5cf6),
                  label: 'Prochaine Focus',
                  value: '25 min',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryGridTile(
                  context,
                  icon: Icons.flag,
                  color: const Color(0xff10b981),
                  label: 'Objectif quotidien',
                  value: '80% accompli',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGridTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff0f172a) : const Color(0xfff8fafc),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0)),
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
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // --- 🌦️ CONTEXT AWARENESS (MODE VIE RÉELLE) ---
  Widget _buildContextAwarenessSelector(
      BuildContext context, AppStateProvider state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final modes = [
      {'label': 'Normal', 'emoji': '🌤️'},
      {'label': 'Examens', 'emoji': '📚'},
      {'label': 'Vacances', 'emoji': '🏖️'},
      {'label': 'Maladie', 'emoji': '🛌'},
      {'label': 'Journée chargée', 'emoji': '⚡'},
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff0f172a) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.thunderstorm_outlined,
                  size: 16, color: Color(0xff0284c7)),
              const SizedBox(width: 8),
              const Text(
                'Mode Vie Réelle (Context Awareness) 🌦️',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: modes.map((m) {
                final isSelected = state.realLifeContext == m['label'];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text('${m['emoji']} ${m['label']}',
                        style: const TextStyle(fontSize: 11)),
                    selected: isSelected,
                    onSelected: (_) => state.setRealLifeContext(m['label']!),
                    selectedColor:
                        const Color(0xff0284c7).withValues(alpha: 0.2),
                    backgroundColor: isDark
                        ? const Color(0xff1e293b)
                        : const Color(0xfff1f5f9),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? const Color(0xff0284c7)
                          : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // --- 🎚️ AUTONOMY LEVEL SELECTOR ---
  Widget _buildAutonomyLevelSelector(
      BuildContext context, AppStateProvider state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff0f172a) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.tune, size: 16, color: Color(0xff8b5cf6)),
                  SizedBox(width: 8),
                  Text(
                    'Niveau d\'Autonomie Nexii 🎚️',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              Text(
                'Lvl ${state.autonomyLevel}/4',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff8b5cf6)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            state.autonomyLevelDescription,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(4, (index) {
              final lvl = index + 1;
              final isSelected = state.autonomyLevel == lvl;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      backgroundColor: isSelected
                          ? const Color(0xff8b5cf6)
                          : (isDark
                              ? const Color(0xff1e293b)
                              : const Color(0xfff1f5f9)),
                      foregroundColor: isSelected ? Colors.white : Colors.grey,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => state.setAutonomyLevel(lvl),
                    child: Text(
                      'Lvl $lvl',
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // --- 🌱 NEXII IDENTITY SUMMARY CARD ---
  Widget _buildIdentitySummaryCard(
      BuildContext context, AppStateProvider state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff0f172a) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_outlined,
                  size: 16, color: Color(0xff10b981)),
              const SizedBox(width: 8),
              const Text(
                'Profil Évolutif — Nexii Identity 🌱',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xff10b981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Profil : ${state.userArchetype}',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff10b981)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.workStyle,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 🧬 NEXII LEARNING LOOP CARD WITH FEEDBACK ---
  Widget _buildLearningLoopCard(BuildContext context, AppStateProvider state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff0f172a) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.biotech_outlined, size: 16, color: Color(0xfff59e0b)),
              SizedBox(width: 8),
              Text(
                'Ce que Nexii a appris sur toi 🧬',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...state.learningLoopInsights.map((insight) {
            final id = insight['id']!;
            final currentFeedback = state.recommendationFeedbacks[id];

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xff1e293b) : const Color(0xfff8fafc),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isDark
                        ? const Color(0xff334155)
                        : const Color(0xffe2e8f0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        insight['topic'] ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text(
                        insight['date'] ?? '',
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    insight['insight'] ?? '',
                    style: const TextStyle(fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '💡 ${insight['impact']}',
                          style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xff2563eb),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      // Feedback buttons: 👍 👎 ⏳
                      Row(
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              Icons.thumb_up_alt_outlined,
                              size: 14,
                              color: currentFeedback == 'useful'
                                  ? const Color(0xff10b981)
                                  : Colors.grey,
                            ),
                            onPressed: () =>
                                state.sendRecommendationFeedback(id, 'useful'),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              Icons.thumb_down_alt_outlined,
                              size: 14,
                              color: currentFeedback == 'not_suited'
                                  ? const Color(0xffef4444)
                                  : Colors.grey,
                            ),
                            onPressed: () => state.sendRecommendationFeedback(
                                id, 'not_suited'),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              Icons.hourglass_empty_rounded,
                              size: 14,
                              color: currentFeedback == 'later'
                                  ? const Color(0xfff59e0b)
                                  : Colors.grey,
                            ),
                            onPressed: () =>
                                state.sendRecommendationFeedback(id, 'later'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // --- 🏆 NEXII MOMENTS (TIMELINE ÉMOTIONNELLE) ---
  Widget _buildNexiiMomentsCard(BuildContext context, AppStateProvider state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff0f172a) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.military_tech_outlined,
                  size: 16, color: Color(0xffec4899)),
              SizedBox(width: 8),
              Text(
                'Nexii Moments (Souvenirs & Victoires) 🏆',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...state.nexiiMoments.map((moment) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(moment['badge'] ?? '✨',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          moment['title'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(
                          moment['subtitle'] ?? '',
                          style:
                              const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    moment['date'] ?? '',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // --- 🧪 NEXII LABS TOGGLE & QA DIAGNOSTIC CENTER ---
  Widget _buildNexiiLabsToggle(BuildContext context, AppStateProvider state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff0f172a) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.science_outlined,
                      size: 16, color: Color(0xff8b5cf6)),
                  SizedBox(width: 8),
                  Text(
                    'Nexii Labs 🧪 (Centre de Diagnostic & QA)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              Switch(
                value: state.isLabsEnabled,
                onChanged: (val) => state.toggleLabs(val),
                activeThumbColor: const Color(0xff8b5cf6),
              ),
            ],
          ),
          if (state.isLabsEnabled) ...[
            const Divider(height: 16),
            const Text(
              '🧪 CENTRE DE QUALIFICATION & TESTS (PHASES 1 À 5)',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: Color(0xff8b5cf6)),
            ),
            const SizedBox(height: 10),

            // Execute Full QA Suite Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff8b5cf6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: state.isQARunning
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.playlist_add_check_circle, size: 18),
                label: Text(
                  state.isQARunning
                      ? 'Exécution du Diagnostic...'
                      : 'Lancer les Tests de Qualification (Phases 1 à 5)',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12),
                ),
                onPressed: state.isQARunning
                    ? null
                    : () => state.runQAFunctionalTestSuite(),
              ),
            ),
            const SizedBox(height: 12),

            // QA Test Results Checklist
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xff1e293b) : const Color(0xfff8fafc),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isDark
                        ? const Color(0xff334155)
                        : const Color(0xffe2e8f0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Dernier diagnostic : ${state.qaResults['lastRunTimestamp']}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(height: 6),
                  _buildQAResultRow('Phase 1 - Fonctionnel',
                      state.qaResults['phase1_functional']),
                  _buildQAResultRow('Phase 2 - Sync & Données',
                      state.qaResults['phase2_data_sync']),
                  _buildQAResultRow('Phase 3 - Performance',
                      state.qaResults['phase3_performance']),
                  _buildQAResultRow('Phase 4 - Scénarios Réels',
                      state.qaResults['phase4_scenarios']),
                  _buildQAResultRow(
                      'Phase 5 - UX & Bugs', state.qaResults['phase5_ux_bugs']),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Real Scenario Simulators
            const Text('🐛 SCÉNARIOS DE TEST EN 1-CLIC :',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => state.simulateQAScenario('student_exam'),
                    child: const Text('📚 Étudiant',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () =>
                        state.simulateQAScenario('overload_recovery'),
                    child: const Text('⚡ Surcharge',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () =>
                        state.simulateQAScenario('peak_performance'),
                    child: const Text('🌟 Peak Aura',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Bug Tracking Table
            const Text('📋 BUG TRACKING SYSTEM :',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            const SizedBox(height: 6),
            ...state.qaBugList.map((bug) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xff8b5cf6).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(bug['id']!,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff8b5cf6))),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(bug['title']!,
                          style: const TextStyle(fontSize: 11),
                          overflow: TextOverflow.ellipsis),
                    ),
                    Text(bug['status']!,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildQAResultRow(String phase, String result) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: Color(0xff10b981), size: 14),
          const SizedBox(width: 6),
          Text('$phase : ',
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          Expanded(
              child: Text(result,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
