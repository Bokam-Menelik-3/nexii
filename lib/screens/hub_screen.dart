import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import 'agenda_screen.dart';
import 'aura_screen.dart';
import 'budget_screen.dart';
import 'goals_screen.dart';
import 'missions_screen.dart';
import 'profile_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NEXII — Hub Screen
// Surface d'orientation vers tous les espaces réels de l'application.
// Aucune donnée fictive.
// Tab destinations : state.setTabIndex(n) — indices inchangés (0-4).
// Push destinations : Navigator.push → écrans hors bottom nav.
// ─────────────────────────────────────────────────────────────────────────────

class HubScreen extends StatelessWidget {
  const HubScreen({super.key});

  static const _blue   = Color(0xff2563eb);
  static const _green  = Color(0xff22c55e);
  static const _purple = Color(0xff7c3aed);
  static const _amber  = Color(0xfff59e0b);
  static const _indigo = Color(0xff4f46e5);
  static const _teal   = Color(0xff0d9488);
  static const _rose   = Color(0xffe11d48);
  static const _cyan   = Color(0xff0891b2);
  static const _orange = Color(0xffea580c);

  @override
  Widget build(BuildContext context) {
    final state   = Provider.of<AppStateProvider>(context);
    final theme   = Theme.of(context);
    final isDark  = theme.brightness == Brightness.dark;
    final name    = state.profileName.isNotEmpty ? state.profileName : null;

    // ── Destinations tab (indices bottom-nav existants 0-4) ──────────────────
    final lang = state.currentLocale.languageCode;
    final tabDests = <_Dest>[
      _Dest(
        icon: Icons.home_outlined,
        label: lang == 'en' ? "Today" : (lang == 'es' ? "Hoy" : "Aujourd'hui"),
        color: _blue,
        onTap: () => state.setTabIndex(0),
      ),
      _Dest(
        icon: Icons.check_circle_outline,
        label: lang == 'en' ? "Tasks" : (lang == 'es' ? "Tareas" : "Tâches"),
        color: _green,
        onTap: () => state.setTabIndex(1),
      ),
      _Dest(
        icon: Icons.timer_outlined,
        label: "Focus",
        color: _purple,
        onTap: () => state.setTabIndex(2),
      ),
      _Dest(
        icon: Icons.trending_up_outlined,
        label: lang == 'en' ? "Progress" : (lang == 'es' ? "Progresión" : "Progression"),
        color: _amber,
        onTap: () => state.setTabIndex(3),
      ),
      _Dest(
        icon: Icons.auto_awesome_outlined,
        label: "Coach",
        color: _indigo,
        onTap: () => state.setTabIndex(4),
      ),
    ];

    // ── Destinations push (écrans hors bottom-nav) ────────────────────────────
    final pushDests = <_Dest>[
      _Dest(icon: Icons.calendar_month_outlined,         label: 'Agenda',   color: _teal,
            onTap: () => _push(context, const AgendaScreen())),
      _Dest(icon: Icons.rocket_launch_outlined,          label: 'Missions', color: _rose,
            onTap: () => _push(context, const MissionsScreen())),
      _Dest(icon: Icons.track_changes_outlined,          label: 'Buts',     color: _cyan,
            onTap: () => _push(context, const GoalsScreen())),
      _Dest(icon: Icons.account_balance_wallet_outlined, label: 'Finance',  color: _green,
            onTap: () => _push(context, const BudgetScreen())),
      _Dest(icon: Icons.auto_fix_high_outlined,          label: 'Aura',     color: _purple,
            onTap: () => _push(context, const AuraScreen())),
      _Dest(icon: Icons.person_outline,                  label: 'Profil',   color: _orange,
            onTap: () => _push(context, const ProfileScreen())),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER ───────────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _blue.withValues(alpha: isDark ? 0.22 : 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.all_inclusive, color: _blue, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nexii',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                      ),
                      if (name != null)
                        Text(name, style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Où souhaitez-vous aller ?',
                style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13),
              ),
              const SizedBox(height: 28),

              // ── ESPACES PRINCIPAUX ────────────────────────────────────────────
              _sectionLabel('ESPACES PRINCIPAUX', theme),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tabDests.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (_, i) => _DestCard(dest: tabDests[i], isDark: isDark),
              ),
              const SizedBox(height: 24),

              // ── AUTRES ESPACES ────────────────────────────────────────────────
              _sectionLabel('AUTRES ESPACES', theme),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pushDests.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (_, i) => _DestCard(dest: pushDests[i], isDark: isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  static Widget _sectionLabel(String text, ThemeData theme) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: theme.textTheme.bodySmall?.color,
        letterSpacing: 1.2,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────────────────────────────────────

class _Dest {
  const _Dest({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData    icon;
  final String      label;
  final Color       color;
  final VoidCallback onTap;
}

// ─────────────────────────────────────────────────────────────────────────────
// CARD
// ─────────────────────────────────────────────────────────────────────────────

class _DestCard extends StatelessWidget {
  const _DestCard({required this.dest, required this.isDark});
  final _Dest dest;
  final bool  isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: dest.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: dest.color.withValues(alpha: isDark ? 0.13 : 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: dest.color.withValues(alpha: isDark ? 0.18 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(dest.icon, color: dest.color, size: 22),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                dest.label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
