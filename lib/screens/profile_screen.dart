import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  int _feedbackRating = 5;
  bool _isSubmittingFeedback = false;
  String _selectedSubTab = 'badges'; // 'badges', 'stats', 'prefs'

  @override
  void dispose() {
    _nameController.dispose();
    _birthdateController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xff2563eb),
              brightness: Theme.of(context).brightness,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthdateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _showEditProfileDialog(BuildContext context, AppStateProvider state) {
    _nameController.text = state.profileName;
    _birthdateController.text = state.profileBirthdate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(state.translate('edit_profile_title'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.translate('onboarding_name_label'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      state.translate('onboarding_birthdate_label'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _birthdateController,
                      readOnly: true,
                      style: const TextStyle(fontSize: 13),
                      onTap: () async {
                        await _selectDate(context);
                        setDialogState(() {});
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.calendar_today, size: 16),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(state.translate('cancel_btn'), style: const TextStyle(fontSize: 13)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = _nameController.text.trim();
                    final birthdate = _birthdateController.text.trim();
                    if (name.isNotEmpty && birthdate.isNotEmpty) {
                      state.updateProfile(name, birthdate);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563eb),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(state.translate('save_profile_btn'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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

    // Initial letters
    String initials = 'NX';
    final name = state.profileName.isNotEmpty ? state.profileName : 'Alexandre Nexii';
    final parts = name.split(' ');
    if (parts.length > 1) {
      initials = "${parts[0][0]}${parts[1][0]}".toUpperCase();
    } else if (name.isNotEmpty) {
      initials = name.substring(0, (name.length > 1 ? 2 : 1)).toUpperCase();
    }

    // Active sub-tab title translations
    final langCode = state.currentLocale.languageCode;
    final tabBadgesLabel = langCode == 'fr' ? 'Badges' : 'Badges';
    final tabStatsLabel = langCode == 'fr' ? 'Stats' : 'Stats';
    final tabPrefsLabel = langCode == 'fr' ? 'Préférences' : langCode == 'es' ? 'Preferencias' : 'Settings';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.person, color: Color(0xff2563eb)),
            const SizedBox(width: 8),
            Text(
              state.translate('profile_title'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: [
            // Profile Hero Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xff2563eb), Color(0xff8b5cf6)],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Theme.of(context).cardColor,
                          child: CircleAvatar(
                            radius: 26,
                            backgroundColor: const Color(0xff2563eb),
                            child: Text(
                              initials,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff8b5cf6).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Niveau ${state.level}',
                                    style: const TextStyle(color: Color(0xff8b5cf6), fontWeight: FontWeight.bold, fontSize: 10),
                                  ),
                                ),
                                if (state.profileAge > 0) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xff2563eb).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${state.profileAge} ans',
                                      style: const TextStyle(color: Color(0xff2563eb), fontWeight: FontWeight.bold, fontSize: 10),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.translate('joined_date'),
                              style: const TextStyle(color: Colors.grey, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 6),
                  
                  // XP Level Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Progression Niveau',
                            style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${state.xp} / ${state.level * 100} XP',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xff8b5cf6)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (state.xp / (state.level * 100)).clamp(0.0, 1.0),
                          backgroundColor: Theme.of(context).dividerColor,
                          color: const Color(0xff8b5cf6),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  
                  // Edit Info Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showEditProfileDialog(context, state),
                      icon: const Icon(Icons.edit, size: 14),
                      label: Text(
                        state.translate('edit_profile_btn'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: BorderSide(color: const Color(0xff2563eb).withOpacity(0.5)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Activity Streak Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xfff59e0b).withOpacity(0.08),
                    const Color(0xffef4444).withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xfff59e0b).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.translate('activity_streak'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(
                          state.translate('streak_desc'),
                          style: const TextStyle(fontSize: 9, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xfff59e0b).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${state.streak} ${langCode == 'fr' ? 'Jours' : 'Days'}',
                      style: const TextStyle(color: Color(0xffd97706), fontWeight: FontWeight.w900, fontSize: 11),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Interactive Sub-tabs Navigation
            Container(
              padding: const EdgeInsets.all(3.5),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildSubTabButton(context, 'badges', tabBadgesLabel),
                  _buildSubTabButton(context, 'stats', tabStatsLabel),
                  _buildSubTabButton(context, 'prefs', tabPrefsLabel),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Active Sub-tab View Rendering
            _buildActiveSubTabContent(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTabButton(BuildContext context, String id, String label) {
    final isSelected = _selectedSubTab == id;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedSubTab = id;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).cardColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? const Color(0xff2563eb)
                  : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSubTabContent(BuildContext context, AppStateProvider state) {
    switch (_selectedSubTab) {
      case 'badges':
        return _buildBadgesTab(context, state);
      case 'stats':
        return _buildStatsTab(context, state);
      case 'prefs':
        return _buildPrefsTab(context, state);
      default:
        return _buildBadgesTab(context, state);
    }
  }

  // SUBTAB 1: BADGES
  Widget _buildBadgesTab(BuildContext context, AppStateProvider state) {
    final langCode = state.currentLocale.languageCode;
    
    // Dynamic lists of achievements checking values from app state
    final productivityBadges = [
      {
        'name': langCode == 'fr' ? 'Maître d’œuvre' : 'Task Master',
        'desc': langCode == 'fr' ? 'Compléter au moins une tâche dans l’application.' : 'Complete at least one task.',
        'xp': '50 XP',
        'icon': '🎯',
        'unlocked': state.tasks.any((t) => t['isCompleted'] == true),
      },
      {
        'name': langCode == 'fr' ? 'Grand Organisateur' : 'Super Organizer',
        'desc': langCode == 'fr' ? 'Compléter 3 tâches ou plus.' : 'Complete 3 or more tasks.',
        'xp': '100 XP',
        'icon': '👑',
        'unlocked': state.tasks.where((t) => t['isCompleted'] == true).length >= 3,
      },
    ];

    final wellbeingBadges = [
      {
        'name': langCode == 'fr' ? 'Esprit Calme' : 'Calm Mind',
        'desc': langCode == 'fr' ? 'Déclarer une humeur sereine ou positive.' : 'Log a serene or positive mood.',
        'xp': '50 XP',
        'icon': '🧘',
        'unlocked': state.auraPercentage >= 70,
      },
      {
        'name': langCode == 'fr' ? 'Aura Étoilée' : 'Star Aura',
        'desc': langCode == 'fr' ? 'Atteindre un score d’aura de 75% ou plus.' : 'Achieve an aura score of 75% or higher.',
        'xp': '100 XP',
        'icon': '✨',
        'unlocked': state.auraPercentage >= 75,
      },
    ];

    final financeBadges = [
      {
        'name': langCode == 'fr' ? 'Épargne Nexii' : 'Nexii Savings',
        'desc': langCode == 'fr' ? 'Avoir dépensé moins de 50% de son budget total.' : 'Spend less than 50% of total budget.',
        'xp': '100 XP',
        'icon': '💰',
        'unlocked': state.totalBudget > 0 && state.spentBudget <= (state.totalBudget * 0.5),
      },
      {
        'name': langCode == 'fr' ? 'Sérénité Financière' : 'Financial Serenity',
        'desc': langCode == 'fr' ? 'Garder un stress financier faible (budget non dépassé).' : 'Keep financial stress low (within budget).',
        'xp': '80 XP',
        'icon': '🛡️',
        'unlocked': state.totalBudget > 0 && state.spentBudget < state.totalBudget,
      },
    ];

    final focusBadges = [
      {
        'name': langCode == 'fr' ? 'Focus Booster' : 'Focus Starter',
        'desc': langCode == 'fr' ? 'Accumuler au moins 15 minutes de concentration.' : 'Accumulate 15+ minutes of focus.',
        'xp': '50 XP',
        'icon': '⚡',
        'unlocked': state.focusMinutesTotal >= 15,
      },
      {
        'name': langCode == 'fr' ? 'Zen Laser' : 'Zen Laser Focus',
        'desc': langCode == 'fr' ? 'Accumuler au moins 60 minutes de concentration.' : 'Accumulate 60+ minutes of focus.',
        'xp': '120 XP',
        'icon': '🔮',
        'unlocked': state.focusMinutesTotal >= 60,
      },
    ];

    final streakBadges = [
      {
        'name': langCode == 'fr' ? 'Flambeau' : 'Activity Spark',
        'desc': langCode == 'fr' ? 'Maintenir une série d’activité de 3 jours ou plus.' : 'Maintain a 3+ day activity streak.',
        'xp': '100 XP',
        'icon': '🔥',
        'unlocked': state.streak >= 3,
      },
      {
        'name': langCode == 'fr' ? 'Constance Nexii' : 'Nexii Consistency',
        'desc': langCode == 'fr' ? 'Atteindre une série d’activité de 10 jours ou plus.' : 'Achieve a 10+ day activity streak.',
        'xp': '200 XP',
        'icon': '⏳',
        'unlocked': state.streak >= 10,
      },
    ];

    int unlockedCount = 0;
    for (var b in [...productivityBadges, ...wellbeingBadges, ...financeBadges, ...focusBadges, ...streakBadges]) {
      if (b['unlocked'] == true) unlockedCount++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Count Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              langCode == 'fr' ? 'Badges & Succès' : 'Badges & Achievements',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xff2563eb).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$unlockedCount / 10 Unlocked',
                style: const TextStyle(fontSize: 10, color: Color(0xff2563eb), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _buildBadgeGroup(context, langCode == 'fr' ? 'Productivité' : 'Productivity', productivityBadges),
        _buildBadgeGroup(context, langCode == 'fr' ? 'Bien-être' : 'Well-being', wellbeingBadges),
        _buildBadgeGroup(context, langCode == 'fr' ? 'Finance' : 'Finance', financeBadges),
        _buildBadgeGroup(context, langCode == 'fr' ? 'Focus' : 'Focus', focusBadges),
        _buildBadgeGroup(context, langCode == 'fr' ? 'Série' : 'Streak', streakBadges),
      ],
    );
  }

  Widget _buildBadgeGroup(BuildContext context, String groupTitle, List<Map<String, dynamic>> badges) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            groupTitle.toUpperCase(),
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.1),
          ),
          const SizedBox(height: 6),
          ...badges.map((b) {
            final isUnlocked = b['unlocked'] == true;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isUnlocked
                      ? const Color(0xff3b82f6).withOpacity(0.15)
                      : Theme.of(context).dividerColor,
                ),
              ),
              child: Opacity(
                opacity: isUnlocked ? 1.0 : 0.55,
                child: Row(
                  children: [
                    Text(b['icon'], style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            b['desc'],
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? const Color(0xff2563eb).withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isUnlocked ? '+${b['xp']}' : '🔒 Locked',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? const Color(0xff2563eb) : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // SUBTAB 2: STATS
  Widget _buildStatsTab(BuildContext context, AppStateProvider state) {
    final langCode = state.currentLocale.languageCode;
    
    // Line chart mock history data incorporating the real current wellness/aura score
    final double currentAura = state.auraPercentage;
    final List<double> wellnessHistory = [70, 75, 68, 80, 85, 78, currentAura];
    
    // Focus hours history incorporating real current total focus minutes
    final int currentFocus = state.focusMinutesTotal;
    final List<int> focusHistory = [30, 45, 15, 60, 40, 90, currentFocus > 90 ? 90 : currentFocus];

    // Expense breakdown calculation from transactions
    final totals = _getCategoryTotals(state.transactions);
    final totalSpent = totals.values.fold(0.0, (sum, val) => sum + val);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Wellness History Line Chart Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    langCode == 'fr' ? 'Évolution Bien-être (Nexii State)' : 'Well-being Evolution (Nexii State)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
                  ),
                  Text(
                    '${currentAura.round()}% ${langCode == 'fr' ? 'Actuel' : 'Now'}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xff2563eb)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                width: double.infinity,
                child: CustomPaint(
                  painter: WellnessChartPainter(wellnessHistory),
                ),
              ),
              const SizedBox(height: 6),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Lun', style: TextStyle(fontSize: 8, color: Colors.grey, fontFamily: 'monospace')),
                  Text('Mar', style: TextStyle(fontSize: 8, color: Colors.grey, fontFamily: 'monospace')),
                  Text('Mer', style: TextStyle(fontSize: 8, color: Colors.grey, fontFamily: 'monospace')),
                  Text('Jeu', style: TextStyle(fontSize: 8, color: Colors.grey, fontFamily: 'monospace')),
                  Text('Ven', style: TextStyle(fontSize: 8, color: Colors.grey, fontFamily: 'monospace')),
                  Text('Sam', style: TextStyle(fontSize: 8, color: Colors.grey, fontFamily: 'monospace')),
                  Text('Dim', style: TextStyle(fontSize: 8, color: Colors.grey, fontFamily: 'monospace')),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Focus Pomodoro Bar Chart Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    langCode == 'fr' ? 'Heures Concentration (Pomodoro)' : 'Focus Hours (Pomodoro)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
                  ),
                  Text(
                    '$currentFocus mins',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xff8b5cf6)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 100,
                child: FocusBarChart(focusHistory),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Expense Breakdown progress bars
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                langCode == 'fr' ? 'RÉPARTITION DES DÉPENSES' : 'EXPENSE BREAKDOWN',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Colors.grey, letterSpacing: 1.1),
              ),
              const SizedBox(height: 10),
              if (totalSpent == 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor, style: BorderStyle.none),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    langCode == 'fr'
                        ? 'Aucune dépense enregistrée. Ajoutez des transactions.'
                        : 'No expenses recorded yet. Add some transactions.',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...totals.entries.where((e) => e.value > 0).map((e) {
                  final catName = e.key;
                  final amt = e.value;
                  final pct = (amt / totalSpent).clamp(0.0, 1.0);
                  Color catColor = const Color(0xff3b82f6);
                  if (catName == 'Alimentation') catColor = const Color(0xff10b981);
                  if (catName == 'Loisirs') catColor = const Color(0xff6366f1);
                  if (catName == 'Maison') catColor = const Color(0xfff59e0b);
                  if (catName == 'Abonnement') catColor = const Color(0xff8b5cf6);
                  if (catName == 'Bonus') catColor = const Color(0xffec4899);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(catName, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            Text(
                              '${amt.toStringAsFixed(1)} € (${(pct * 100).round()}%)',
                              style: const TextStyle(fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 5,
                            backgroundColor: Theme.of(context).dividerColor,
                            color: catColor,
                          ),
                        )
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // AI coaching insights (Fonction 7)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xff2563eb).withOpacity(0.06),
                const Color(0xff8b5cf6).withOpacity(0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xff2563eb).withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Color(0xff2563eb), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    langCode == 'fr' ? 'NEXII AI REPORTS & TENDANCES' : 'NEXII AI REPORTS & TRENDS',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xff2563eb), letterSpacing: 1.0),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                currentAura < 50
                    ? (langCode == 'fr'
                        ? "🚨 Votre niveau d'énergie est particulièrement bas aujourd'hui. L'IA vous conseille de réduire la difficulté de vos tâches actives, de prioriser le sommeil, et de déléguer ou reporter les tâches non-essentielles."
                        : "🚨 Your energy level is particularly low today. The AI advises you to reduce the difficulty of active tasks, prioritize sleep, and delegate non-essential work.")
                    : (langCode == 'fr'
                        ? "✨ Vos indicateurs de bien-être et de motivation sont excellents ! C'est le moment idéal pour aborder vos tâches complexes à haute valeur ajoutée."
                        : "✨ Your well-being and motivation indicators are excellent! This is the perfect time to tackle your high-value complex tasks."),
                style: const TextStyle(fontSize: 10.5, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Map<String, double> _getCategoryTotals(List<Map<String, dynamic>> transactions) {
    Map<String, double> totals = {
      'Alimentation': 0.0,
      'Loisirs': 0.0,
      'Maison': 0.0,
      'Abonnement': 0.0,
      'Bonus': 0.0,
    };
    for (var tx in transactions) {
      if (tx['isNegative'] == true) {
        String cat = tx['category'] ?? 'Loisirs';
        if (cat == 'Food') cat = 'Alimentation';
        if (cat == 'Leisure' || cat == 'Ocio') cat = 'Loisirs';
        if (cat == 'Home' || cat == 'Casa') cat = 'Maison';
        if (cat == 'Subscription' || cat == 'Suscripción') cat = 'Abonnement';
        
        double amt = (tx['amount'] as num).toDouble().abs();
        totals[cat] = (totals[cat] ?? 0.0) + amt;
      }
    }
    return totals;
  }

  // SUBTAB 3: PREFERENCES (SETTINGS)
  Widget _buildPrefsTab(BuildContext context, AppStateProvider state) {
    final langCode = state.currentLocale.languageCode;
    
    // Success rate computation
    final completedTasks = state.tasks.where((t) => t['isCompleted'] == true).length;
    final totalTasks = state.tasks.length;
    final rate = totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // General Statistics Grid Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.translate('stats_title'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.8,
                children: [
                  _buildStatGridItem('Heures Focus', '${(state.focusMinutesTotal / 60).floor()}h ${(state.focusMinutesTotal % 60).toString().padLeft(2, '0')}m'),
                  _buildStatGridItem('Défis Réussis', '${state.missions.where((m) => m['isCompleted'] == true).length} / ${state.missions.length}'),
                  _buildStatGridItem('Taux Réussite', '$rate%'),
                  _buildStatGridItem('Cohérence Card.', '${state.auraPercentage.round()}%'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _buildSectionHeader(context, state.translate('device_options')),

        // Server URL preference Card
        Card(
          elevation: 0,
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xff2563eb).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.dns, color: Color(0xff2563eb), size: 18),
            ),
            title: Text(
              langCode == 'fr' ? 'Adresse du Serveur API' : 'API Server URL',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            subtitle: Text(
              state.customServerUrl,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit, size: 18, color: Color(0xff2563eb)),
              onPressed: () {
                final controller = TextEditingController(text: state.customServerUrl);
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: Text(
                        langCode == 'fr' ? 'Modifier l\'adresse du Serveur' : 'Edit Server URL',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            langCode == 'fr'
                                ? 'Saisissez l\'URL complète du serveur backend (ex: https://ais-pre-...)'
                                : 'Enter the complete URL of your backend server',
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: controller,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              labelText: 'URL Serveur',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(state.translate('cancel_btn')),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            state.updateServerUrl(controller.text);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(langCode == 'fr' ? 'Serveur mis à jour avec succès !' : 'Server updated successfully!'),
                                backgroundColor: const Color(0xff10b981),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff2563eb),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Dark mode preference
        Card(
          elevation: 0,
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          child: SwitchListTile(
            title: Text(
              state.translate('settings_theme'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            subtitle: const Text(
              'Basculez entre l\'affichage clair et sombre',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
            value: state.isDarkMode,
            activeColor: const Color(0xff2563eb),
            onChanged: (val) {
              state.toggleTheme();
            },
          ),
        ),
        const SizedBox(height: 8),

        // Language Preference
        Card(
          elevation: 0,
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          child: ListTile(
            title: Text(
              state.translate('settings_lang'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            subtitle: Text(
              _getLocaleName(state.currentLocale),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            trailing: DropdownButton<Locale>(
              value: state.currentLocale,
              underline: const SizedBox(),
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  state.setLocale(newLocale);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: Locale('fr', 'FR'),
                  child: Text('Français (FR)', style: TextStyle(fontSize: 12)),
                ),
                DropdownMenuItem(
                  value: Locale('en', 'US'),
                  child: Text('English (US)', style: TextStyle(fontSize: 12)),
                ),
                DropdownMenuItem(
                  value: Locale('es', 'ES'),
                  child: Text('Español (ES)', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Feedback / Customer form
        _buildSectionHeader(context, langCode == 'fr' ? 'Formulaire de retour utilisateur' : 'Send feedback'),
        Card(
          elevation: 0,
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  langCode == 'fr' ? 'Votre avis compte énormément !' : 'Your feedback counts!',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  langCode == 'fr'
                      ? 'Aidez-nous à améliorer Nexii en partageant votre expérience ou en signalant un bug.'
                      : 'Help us improve Nexii by sharing your experience or reporting an issue.',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 12),

                // Star Rating Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starValue = index + 1;
                    return IconButton(
                      icon: Icon(
                        starValue <= _feedbackRating ? Icons.star : Icons.star_border,
                        color: starValue <= _feedbackRating ? Colors.amber : Colors.grey.shade400,
                        size: 24,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          _feedbackRating = starValue;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 10),

                // Comment area
                TextField(
                  controller: _feedbackController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: langCode == 'fr' ? 'Écrivez votre message ici...' : 'Write your message here...',
                    hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(height: 12),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff8b5cf6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                    ),
                    icon: _isSubmittingFeedback
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send, size: 14),
                    label: Text(
                      _isSubmittingFeedback
                          ? (langCode == 'fr' ? 'Envoi en cours...' : 'Sending...')
                          : (langCode == 'fr' ? 'Envoyer mon avis' : 'Submit feedback'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                    ),
                    onPressed: _isSubmittingFeedback
                        ? null
                        : () async {
                            final text = _feedbackController.text.trim();
                            if (text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(langCode == 'fr' ? 'Veuillez saisir un commentaire avant d\'envoyer.' : 'Please write a comment first.'),
                                  backgroundColor: Colors.amber,
                                ),
                              );
                              return;
                            }

                            setState(() {
                              _isSubmittingFeedback = true;
                            });

                            final success = await state.submitFeedback(_feedbackRating, text);

                            if (mounted) {
                              setState(() {
                                _isSubmittingFeedback = false;
                              });
                              if (success) {
                                _feedbackController.clear();
                                setState(() {
                                  _feedbackRating = 5;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(langCode == 'fr' ? 'Merci pour vos retours ! Votre avis a bien été enregistré. 💜' : 'Thank you for your feedback! 💜'),
                                    backgroundColor: const Color(0xff10b981),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(langCode == 'fr' ? 'Une erreur est survenue lors de l\'envoi.' : 'An error occurred while sending.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Disconnect button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffef4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
            ),
            icon: const Icon(Icons.logout, size: 14),
            label: Text(
              langCode == 'fr' ? 'Se déconnecter de Nexii' : 'Log out from Nexii',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            onPressed: () {
              state.signOut();
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildStatGridItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 8.5, color: Colors.grey, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 4.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _getLocaleName(Locale locale) {
    switch (locale.languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return 'Français';
    }
  }
}

// -------------------------------------------------------------
// Beautiful Bezier Curve Custom Painter for Wellness Evolution
// -------------------------------------------------------------
class WellnessChartPainter extends CustomPainter {
  final List<double> dataPoints;
  WellnessChartPainter(this.dataPoints);

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;
    
    final paintLine = Paint()
      ..color = const Color(0xff2563eb)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintArea = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xff2563eb).withOpacity(0.2),
          const Color(0xff2563eb).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final areaPath = Path();

    double stepX = size.width / (dataPoints.length - 1);
    double maxY = 100.0;
    
    double getY(double val) {
      double pct = (val / maxY).clamp(0.0, 1.0);
      return size.height - (pct * size.height * 0.8) - 10; // offset inside area
    }

    path.moveTo(0, getY(dataPoints[0]));
    areaPath.moveTo(0, size.height);
    areaPath.lineTo(0, getY(dataPoints[0]));

    for (int i = 1; i < dataPoints.length; i++) {
      double x = i * stepX;
      double y = getY(dataPoints[i]);
      
      double prevX = (i - 1) * stepX;
      double prevY = getY(dataPoints[i - 1]);
      
      // Control points
      double cx1 = prevX + stepX / 2;
      double cy1 = prevY;
      double cx2 = prevX + stepX / 2;
      double cy2 = y;
      
      path.cubicTo(cx1, cy1, cx2, cy2, x, y);
      areaPath.cubicTo(cx1, cy1, cx2, cy2, x, y);
    }

    areaPath.lineTo(size.width, size.height);
    areaPath.close();

    canvas.drawPath(areaPath, paintArea);
    canvas.drawPath(path, paintLine);

    // Draw dots at points
    final dotPaint = Paint()..color = const Color(0xff2563eb);
    final bgDotPaint = Paint()..color = Colors.white;
    for (int i = 0; i < dataPoints.length; i++) {
      double x = i * stepX;
      double y = getY(dataPoints[i]);
      canvas.drawCircle(Offset(x, y), 4, bgDotPaint);
      canvas.drawCircle(Offset(x, y), 2.2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// -------------------------------------------------------------
// Rounded Focus hours bar chart
// -------------------------------------------------------------
class FocusBarChart extends StatelessWidget {
  final List<int> focusMinutes;
  const FocusBarChart(this.focusMinutes, {super.key});

  @override
  Widget build(BuildContext context) {
    final maxMin = 90;
    final weekdays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final val = focusMinutes[index];
        final pct = (val / maxMin).clamp(0.1, 1.0);
        final isToday = index == DateTime.now().weekday - 1;
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 14,
                  height: 80 * pct, // scaling height
                  decoration: BoxDecoration(
                    color: isToday ? const Color(0xff8b5cf6) : const Color(0xff8b5cf6).withOpacity(0.2),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              weekdays[index],
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? const Color(0xff8b5cf6) : Colors.grey,
              ),
            ),
          ],
        );
      }),
    );
  }
}
