import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final TextEditingController _eventController = TextEditingController();
  final TextEditingController _postController = TextEditingController();
  String _selectedTimeHour = '09';
  String _selectedTimeMin = '00';
  int _selectedDayIndex = 3; // default: JEU 16

  final List<Map<String, String>> _weekDays = [
    {'day': 'LUN', 'num': '13'},
    {'day': 'MAR', 'num': '14'},
    {'day': 'MER', 'num': '15'},
    {'day': 'JEU', 'num': '16'},
    {'day': 'VEN', 'num': '17'},
    {'day': 'SAM', 'num': '18'},
    {'day': 'DIM', 'num': '19'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1); // Open Agenda tab by default to match screenshot
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _eventController.dispose();
    _postController.dispose();
    super.dispose();
  }

  void _triggerAutoPlan(AppStateProvider state) {
    // Add default balanced activities
    state.addAgendaEvent('Méditation du matin 🧘', '08:30');
    state.addAgendaEvent('Repas conscient 🍎', '12:30');
    state.addAgendaEvent('Yoga de fin de journée 🤸', '18:00');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nexii a synchronisé 3 activités équilibrées dans votre agenda !'),
        backgroundColor: Color(0xff2563eb),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber),
            const SizedBox(width: 8),
            const Text(
              'Mon Agenda Bien-être',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xff2563eb),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xff2563eb),
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'Défis & XP'),
            Tab(text: 'Agenda'),
            Tab(text: 'Communauté'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Défis & XP
            _buildDefisTab(context, state),

            // Tab 2: Agenda
            _buildAgendaTab(context, state),

            // Tab 3: Communauté
            _buildCommunityTab(context, state, isDark),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: DEFIS & XP ---
  Widget _buildDefisTab(BuildContext context, AppStateProvider state) {
    final dailyMissions = state.missions.where((m) => m['id'] != '3').toList();
    final weeklyMissions = state.missions.where((m) => m['id'] == '3').toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // XP Progress Header Card
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xff8b5cf6),
                        radius: 14,
                        child: Icon(Icons.star, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Niveau ${state.level}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  Text(
                    '${state.xp} / ${100 * state.level} XP',
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: state.xp / (100 * state.level),
                  backgroundColor: Theme.of(context).dividerColor,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff8b5cf6)),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                state.translate('overall_progress'),
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ),

        _buildSectionHeader(context, 'Missions Quotidiennes'),
        if (dailyMissions.isEmpty)
          const Center(child: Text('Aucune mission quotidienne active.'))
        else
          ...dailyMissions.map((m) => _buildMissionCard(context, state, m)),

        const SizedBox(height: 16),
        _buildSectionHeader(context, 'Missions Hebdomadaires'),
        if (weeklyMissions.isEmpty)
          const Center(child: Text('Aucune mission hebdomadaire active.'))
        else
          ...weeklyMissions.map((m) => _buildMissionCard(context, state, m)),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0, left: 4.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15, color: Colors.grey),
      ),
    );
  }

  Widget _buildMissionCard(
    BuildContext context,
    AppStateProvider state,
    Map<String, dynamic> mission,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double progress = (mission['progress'] as num).toDouble();
    final bool isCompleted = mission['isCompleted'] as bool;
    final bool claimed = mission['claimed'] as bool;
    final String missionId = mission['id'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Expanded(
                child: Text(
                  mission['title'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xff8b5cf6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${mission['xp']} XP',
                  style: const TextStyle(color: Color(0xff8b5cf6), fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            mission['description'] ?? '',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.3),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? const Color(0xff22c55e) : const Color(0xff2563eb),
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isCompleted ? '100%' : '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: isCompleted ? const Color(0xff22c55e) : const Color(0xff2563eb),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          if (isCompleted) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: claimed ? null : () => state.claimMissionXp(missionId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff8b5cf6),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xff22c55e).withOpacity(0.1),
                  disabledForegroundColor: const Color(0xff22c55e),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 0,
                ),
                child: Text(
                  claimed ? state.translate('reward_claimed') : state.translate('claim_xp'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- TAB 2: MON AGENDA ---
  Widget _buildAgendaTab(BuildContext context, AppStateProvider state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizontal Calendar selector (Image 5)
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _weekDays.length,
              itemBuilder: (context, idx) {
                final day = _weekDays[idx];
                final isSelected = idx == _selectedDayIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDayIndex = idx;
                    });
                  },
                  child: Container(
                    width: 50,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xff2563eb)
                          : (isDark ? const Color(0xff1e293b) : const Color(0xfff1f5f9)),
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected
                          ? null
                          : Border.all(color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day['day']!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          day['num']!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Planning header (Image 5)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PLANNINGS DE LA JOURNÉE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.8,
                ),
              ),
              TextButton.icon(
                onPressed: () => _triggerAutoPlan(state),
                icon: const Icon(Icons.auto_awesome, size: 14, color: Color(0xff2563eb)),
                label: const Text(
                  '+ Nexii Auto-Plan',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff2563eb),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Events list
          if (state.agendaEvents.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: const Column(
                children: [
                  Icon(Icons.calendar_today, size: 36, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'Aucune activité planifiée pour aujourd\'hui.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...state.agendaEvents.asMap().entries.map((entry) {
              final idx = entry.key;
              final ev = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xff2563eb).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ev['time'] ?? '08:00',
                        style: const TextStyle(
                          color: Color(0xff2563eb),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        ev['title'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                      onPressed: () {
                        state.removeAgendaEvent(idx);
                      },
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 24),

          // Add to Agenda Section (Image 5)
          const Text(
            'AJOUTER À L\'AGENDA',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _eventController,
                  decoration: InputDecoration(
                    hintText: 'Séance Yoga, Gym, Méditer...',
                    hintStyle: const TextStyle(fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: _selectedTimeHour,
                            underline: const SizedBox(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedTimeHour = val;
                                });
                              }
                            },
                            items: List.generate(24, (index) => index.toString().padLeft(2, '0'))
                                .map((hour) => DropdownMenuItem(value: hour, child: Text(hour)))
                                .toList(),
                          ),
                          const Text(' : '),
                          DropdownButton<String>(
                            value: _selectedTimeMin,
                            underline: const SizedBox(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedTimeMin = val;
                                });
                              }
                            },
                            items: ['00', '15', '30', '45']
                                .map((min) => DropdownMenuItem(value: min, child: Text(min)))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final title = _eventController.text.trim();
                        if (title.isNotEmpty) {
                          state.addAgendaEvent(title, '$_selectedTimeHour:$_selectedTimeMin');
                          _eventController.clear();
                          FocusScope.of(context).unfocus();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2563eb),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        elevation: 0,
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, size: 16),
                          SizedBox(width: 4),
                          Text('Planifier', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 3: COMMUNAUTE ---
  Widget _buildCommunityTab(BuildContext context, AppStateProvider state, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Peer guidance intro card
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xff8b5cf6), Color(0xffa855f7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.people, color: Colors.white, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Réseau d\'Entraide Nexii',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Partagez vos victoires, inspirez vos pairs et restez motivé ensemble !',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Write a post card
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xff6366f1),
                    radius: 16,
                    child: Icon(Icons.edit, color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _postController,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        hintText: 'Quoi de neuf aujourd\'hui ? Partagez une réussite...',
                        hintStyle: TextStyle(fontSize: 12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  final text = _postController.text.trim();
                  if (text.isNotEmpty) {
                    state.addCommunityPost(text);
                    _postController.clear();
                    FocusScope.of(context).unfocus();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Votre message a été partagé !')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2563eb),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  elevation: 0,
                ),
                icon: const Icon(Icons.send, size: 12),
                label: const Text('Partager', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),

        const Text(
          'FLUX BIEN-ÊTRE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),

        ...state.communityPosts.map((post) {
          final int colorVal = post['avatarColorValue'] as int? ?? 0xff8b5cf6;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(colorVal),
                      radius: 16,
                      child: Text(
                        (post['author'] as String? ?? 'M')[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post['author'] as String? ?? 'Anonyme',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            post['time'] as String? ?? 'À l\'instant',
                            style: const TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xff2563eb).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        post['tag'] as String? ?? '#BienEtre',
                        style: const TextStyle(color: Color(0xff2563eb), fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  post['text'] as String? ?? '',
                  style: const TextStyle(fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        state.toggleLikePost(post['id'] as String);
                      },
                      child: Row(
                        children: [
                          Icon(
                            (post['hasLiked'] as bool? ?? false) ? Icons.favorite : Icons.favorite_border,
                            color: (post['hasLiked'] as bool? ?? false) ? Colors.red : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post['likes'] ?? 0}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Row(
                      children: [
                        Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 18),
                        SizedBox(width: 4),
                        Text('Commenter', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
