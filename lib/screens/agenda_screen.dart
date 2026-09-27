import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final TextEditingController _titleController = TextEditingController();
  String _selectedHour = '09';
  String _selectedMin = '00';

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _showAddEventDialog(BuildContext context, AppStateProvider state, _AgendaStrings s) {
    _titleController.clear();
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(s.addEventTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: s.eventTitleLabel,
                        hintText: s.eventTitleHint,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(s.timeLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 18, color: Color(0xff2563eb)),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: _selectedHour,
                          underline: const SizedBox(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          onChanged: (val) {
                            if (val != null) setDialogState(() => _selectedHour = val);
                          },
                          items: List.generate(24, (index) => index.toString().padLeft(2, '0'))
                              .map((hour) => DropdownMenuItem(value: hour, child: Text(hour)))
                              .toList(),
                        ),
                        const Text(' : ', style: TextStyle(fontWeight: FontWeight.bold)),
                        DropdownButton<String>(
                          value: _selectedMin,
                          underline: const SizedBox(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          onChanged: (val) {
                            if (val != null) setDialogState(() => _selectedMin = val);
                          },
                          items: ['00', '15', '30', '45']
                              .map((min) => DropdownMenuItem(value: min, child: Text(min)))
                              .toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(s.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = _titleController.text.trim();
                    if (title.isNotEmpty) {
                      state.addAgendaEvent(title, '$_selectedHour:$_selectedMin');
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563eb),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(s.add),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Parse HH:mm to today's DateTime
  DateTime? _parseEventTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final now = DateTime.now();
        final h = int.parse(parts[0].trim());
        final m = int.parse(parts[1].trim());
        return DateTime(now.year, now.month, now.day, h, m);
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = state.currentLocale.languageCode;
    final s = _AgendaStrings(lang);

    final now = DateTime.now();
    final allEvents = state.agendaEvents;

    // Categorize events based on real time
    Map<String, dynamic>? currentEvent;
    int currentEventIndex = -1;

    Map<String, dynamic>? nextEvent;
    int nextEventIndex = -1;
    Duration? minUpcomingDiff;

    final upcomingEventsWithIndex = <MapEntry<int, Map<String, dynamic>>>[];
    final pastEventsWithIndex = <MapEntry<int, Map<String, dynamic>>>[];

    for (int i = 0; i < allEvents.length; i++) {
      final ev = allEvents[i];
      final eventTime = _parseEventTime(ev['time']?.toString());

      if (eventTime != null) {
        final diff = eventTime.difference(now);
        // If event started less than 60 mins ago and is not finished
        if (diff.inMinutes <= 0 && diff.inMinutes > -60 && currentEvent == null) {
          currentEvent = ev;
          currentEventIndex = i;
        } else if (diff.inMinutes > 0) {
          upcomingEventsWithIndex.add(MapEntry(i, ev));
          if (minUpcomingDiff == null || diff < minUpcomingDiff) {
            minUpcomingDiff = diff;
            nextEvent = ev;
            nextEventIndex = i;
          }
        } else {
          pastEventsWithIndex.add(MapEntry(i, ev));
        }
      } else {
        upcomingEventsWithIndex.add(MapEntry(i, ev));
      }
    }

    // If no active current event, then nextEvent is the primary focus
    final primaryFeatured = currentEvent ?? nextEvent;
    final primaryFeaturedIndex = currentEvent != null ? currentEventIndex : nextEventIndex;
    final bool isCurrentActive = currentEvent != null;

    final remainingUpcoming = upcomingEventsWithIndex
        .where((entry) => entry.key != primaryFeaturedIndex)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.schedule_rounded, color: Color(0xff2563eb)),
            const SizedBox(width: 10),
            Text(
              s.screenTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xff2563eb)),
            tooltip: s.addEventTitle,
            onPressed: () => _showAddEventDialog(context, state, s),
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
                // 1. CONTEXTE TEMPOREL ACTUEL
                _buildTimeContextCard(context, state, isDark, allEvents.length, s),
                const SizedBox(height: 16),

                if (allEvents.isEmpty) ...[
                  _buildEmptyState(context, state, isDark, s),
                ] else ...[
                  // 2. MAINTENANT / PROCHAIN ÉVÉNEMENT
                  if (primaryFeatured != null) ...[
                    _buildSectionHeader(
                      context,
                      isCurrentActive ? s.nowHeader : s.nextHeader,
                      icon: isCurrentActive ? Icons.radio_button_checked : Icons.arrow_forward_rounded,
                      color: isCurrentActive ? const Color(0xff22c55e) : const Color(0xff2563eb),
                    ),
                    const SizedBox(height: 6),
                    _buildFeaturedCard(
                      context,
                      state,
                      primaryFeatured,
                      primaryFeaturedIndex,
                      isCurrentActive,
                      now,
                      isDark,
                      s,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 3. ÉVÉNEMENTS À VENIR
                  if (remainingUpcoming.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      '${s.upcomingHeader} (${remainingUpcoming.length})',
                      icon: Icons.access_time_rounded,
                      color: const Color(0xff2563eb),
                    ),
                    const SizedBox(height: 6),
                    ...remainingUpcoming.map((entry) => _buildEventCard(
                          context,
                          state,
                          entry.value,
                          entry.key,
                          now,
                          isDark,
                          s,
                        )),
                    const SizedBox(height: 12),
                  ],

                  // 4. PLUS TÔT / PASSÉS
                  if (pastEventsWithIndex.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      '${s.earlierHeader} (${pastEventsWithIndex.length})',
                      icon: Icons.history_rounded,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 6),
                    ...pastEventsWithIndex.map((entry) => _buildEventCard(
                          context,
                          state,
                          entry.value,
                          entry.key,
                          now,
                          isDark,
                          s,
                          isPast: true,
                        )),
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

  // --- 1. CONTEXTE TEMPOREL CARD ---
  Widget _buildTimeContextCard(
    BuildContext context,
    AppStateProvider state,
    bool isDark,
    int eventCount,
    _AgendaStrings s,
  ) {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xff2563eb).withValues(alpha: 0.15),
                radius: 18,
                child: const Icon(Icons.wb_sunny_outlined, color: Color(0xff2563eb), size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.timeFieldLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    '$eventCount ${s.scheduledEvents}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xff2563eb).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              timeStr,
              style: const TextStyle(
                color: Color(0xff2563eb),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. FEATURED (MAINTENANT / PROCHAIN) CARD ---
  Widget _buildFeaturedCard(
    BuildContext context,
    AppStateProvider state,
    Map<String, dynamic> ev,
    int index,
    bool isCurrent,
    DateTime now,
    bool isDark,
    _AgendaStrings s,
  ) {
    final eventTime = _parseEventTime(ev['time']?.toString());
    String countdown = '';
    if (eventTime != null && !isCurrent) {
      final diff = eventTime.difference(now);
      if (diff.inMinutes > 0 && diff.inMinutes < 60) {
        countdown = '${s.inMinutes(diff.inMinutes)}';
      } else if (diff.inMinutes >= 60) {
        final hours = diff.inHours;
        final mins = diff.inMinutes % 60;
        countdown = mins > 0 ? '${s.inHoursMins(hours, mins)}' : '${s.inHours(hours)}';
      }
    }

    final accentColor = isCurrent ? const Color(0xff22c55e) : const Color(0xff2563eb);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accentColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.12 : 0.08),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  ev['time']?.toString() ?? '00:00',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ev['title']?.toString() ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xff22c55e).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          s.inProgressBadge,
                          style: const TextStyle(
                            color: Color(0xff15803d),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ] else if (countdown.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        countdown,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                tooltip: s.deleteTooltip,
                onPressed: () => state.removeAgendaEvent(index),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 3. REGULAR EVENT CARD ---
  Widget _buildEventCard(
    BuildContext context,
    AppStateProvider state,
    Map<String, dynamic> ev,
    int index,
    DateTime now,
    bool isDark,
    _AgendaStrings s, {
    bool isPast = false,
  }) {
    final eventTime = _parseEventTime(ev['time']?.toString());
    String countdown = '';
    if (eventTime != null && !isPast) {
      final diff = eventTime.difference(now);
      if (diff.inMinutes > 0 && diff.inMinutes < 60) {
        countdown = s.inMinutes(diff.inMinutes);
      } else if (diff.inMinutes >= 60) {
        final hours = diff.inHours;
        final mins = diff.inMinutes % 60;
        countdown = mins > 0 ? s.inHoursMins(hours, mins) : s.inHours(hours);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isPast
                  ? Colors.grey.withValues(alpha: 0.1)
                  : const Color(0xff2563eb).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              ev['time']?.toString() ?? '00:00',
              style: TextStyle(
                color: isPast ? Colors.grey : const Color(0xff2563eb),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ev['title']?.toString() ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isPast ? Colors.grey : null,
                    decoration: isPast ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (countdown.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    countdown,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: Colors.grey),
            tooltip: s.deleteTooltip,
            onPressed: () => state.removeAgendaEvent(index),
          ),
        ],
      ),
    );
  }

  // --- EMPTY STATE ---
  Widget _buildEmptyState(BuildContext context, AppStateProvider state, bool isDark, _AgendaStrings s) {
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
          Icon(Icons.calendar_today_outlined, size: 44, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            s.noEventsTitle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            s.noEventsSubtitle,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddEventDialog(context, state, s),
            icon: const Icon(Icons.add, size: 16),
            label: Text(s.addEventAction, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff2563eb),
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

class _AgendaStrings {
  final String lang;
  _AgendaStrings(this.lang);

  String get screenTitle => lang == 'en' ? 'Agenda' : (lang == 'es' ? 'Agenda' : 'Agenda');
  String get timeFieldLabel => lang == 'en' ? 'Living Time Field' : (lang == 'es' ? 'Campo de Tiempo Vivo' : 'Temps Réel & Rythme');
  String get scheduledEvents => lang == 'en' ? 'events scheduled' : (lang == 'es' ? 'eventos planificados' : 'activités planifiées');
  String get nowHeader => lang == 'en' ? 'NOW' : (lang == 'es' ? 'AHORA' : 'MAINTENANT');
  String get nextHeader => lang == 'en' ? 'NEXT' : (lang == 'es' ? 'SIGUIENTE' : 'ENSUITE');
  String get upcomingHeader => lang == 'en' ? 'Upcoming Events' : (lang == 'es' ? 'Próximos Eventos' : 'À Venir');
  String get earlierHeader => lang == 'en' ? 'Earlier Today' : (lang == 'es' ? 'Más temprano' : "Plus tôt aujourd'hui");
  String get inProgressBadge => lang == 'en' ? 'In progress' : (lang == 'es' ? 'En curso' : 'En cours');
  String inMinutes(int mins) => lang == 'en' ? 'In ${mins}m' : (lang == 'es' ? 'En ${mins} min' : 'Dans ${mins} min');
  String inHours(int h) => lang == 'en' ? 'In ${h}h' : (lang == 'es' ? 'En ${h} h' : 'Dans ${h} h');
  String inHoursMins(int h, int m) => lang == 'en' ? 'In ${h}h ${m}m' : (lang == 'es' ? 'En ${h} h ${m} min' : 'Dans ${h} h ${m} min');
  String get deleteTooltip => lang == 'en' ? 'Delete' : (lang == 'es' ? 'Eliminar' : 'Supprimer');
  String get addEventTitle => lang == 'en' ? 'Add to Agenda' : (lang == 'es' ? 'Añadir a la Agenda' : "Ajouter à l'agenda");
  String get eventTitleLabel => lang == 'en' ? 'Event title' : (lang == 'es' ? 'Título del evento' : "Titre de l'activité");
  String get eventTitleHint => lang == 'en' ? 'e.g. Yoga, Meeting, Focus...' : (lang == 'es' ? 'ej. Yoga, Reunión, Enfoque...' : 'ex. Séance Yoga, Réunion, Méditation...');
  String get timeLabel => lang == 'en' ? 'Time' : (lang == 'es' ? 'Hora' : 'Heure');
  String get cancel => lang == 'en' ? 'Cancel' : (lang == 'es' ? 'Cancelar' : 'Annuler');
  String get add => lang == 'en' ? 'Add' : (lang == 'es' ? 'Añadir' : 'Ajouter');
  String get noEventsTitle => lang == 'en' ? 'No events planned today.' : (lang == 'es' ? 'No hay actividades planificadas hoy.' : "Aucune activité planifiée aujourd'hui.");
  String get noEventsSubtitle => lang == 'en'
      ? 'Plan your day peacefully without calendar clutter.'
      : (lang == 'es'
          ? 'Planifica tu día con calma sin sobrecargar tu calendario.'
          : 'Organisez votre journée en toute sérénité sans grille surchargée.');
  String get addEventAction => lang == 'en' ? 'Add an activity' : (lang == 'es' ? 'Añadir una actividad' : 'Planifier une activité');
}
