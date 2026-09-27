import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../core/theme/nexii_colors.dart';
import '../experience/models/experience_mode.dart';
import '../experience/models/experience_state.dart';
import '../providers/app_state_provider.dart';

/// Canonical Experience copy keys for Focus (localized via [_FocusStrings]).
enum _FocusSupportCopy { recovery, pressure, priority, checkIn, calm }

/// Focus-only presentation contract derived from the canonical Experience
/// state — the same interpretation Home and Tasks consume.
///
/// Pure presentation: supporting copy emphasis, density, spacing, glow
/// strength, CTA prominence and motion. It never decides priority or
/// modes, never touches timer arithmetic and never triggers timer
/// actions: ExperienceState stays the single authority.
class _FocusPresentation {
  const _FocusPresentation({
    required this.supportCopy,
    required this.secondaryOpacity,
    required this.timerScale,
    required this.timerPaddingV,
    required this.glowStrength,
    required this.contextPaddingV,
    required this.ctaEmphasis,
    required this.transitionDuration,
  });

  /// Grounded, mode-based supporting copy (localized by the screen).
  final _FocusSupportCopy supportCopy;

  /// Opacity of secondary controls (mode pills, ambient sound).
  final double secondaryOpacity;

  /// Subtle scale emphasis on the timer dial (the visual anchor).
  final double timerScale;

  /// Extra breathing room around the timer dial.
  final double timerPaddingV;

  /// Multiplier on the existing dial glow (softer, never alarming, in
  /// Recovery — never implying progress the timer does not have).
  final double glowStrength;

  /// Vertical padding of the context card (more room in Recovery).
  final double contextPaddingV;

  /// Whether the primary CTA gets extra prominence (Pressure/Priority).
  final bool ctaEmphasis;

  /// Single coherent state-transition duration for this mode.
  final Duration transitionDuration;

  factory _FocusPresentation.from(ExperienceState experience) {
    // Density baseline from the canonical state.
    double secondaryOpacity = switch (experience.informationDensity) {
      ExperienceDensity.standard => 1.0,
      ExperienceDensity.reduced => 0.68,
      ExperienceDensity.minimal => 0.42,
    };
    double timerScale = 1.0;
    double timerPaddingV = 0.0;
    double glowStrength = 1.0;
    double contextPaddingV = NexiiSpacing.md;
    bool ctaEmphasis = false;
    Duration transitionDuration = NexiiMotion.normal;
    _FocusSupportCopy supportCopy = _FocusSupportCopy.calm;

    // Mode modifiers refine the baseline — the Experience layer is the
    // only mode authority; this switch only maps meaning to presentation.
    switch (experience.mode) {
      case ExperienceMode.recovery:
        // Safe, slow, quiet: gentler glow, softer secondary controls,
        // more breathing room, slower motion. Never alarming or demanding.
        supportCopy = _FocusSupportCopy.recovery;
        secondaryOpacity = 0.45;
        timerPaddingV = NexiiSpacing.lg;
        glowStrength = 0.5;
        contextPaddingV = NexiiSpacing.lg;
        transitionDuration = NexiiMotion.slow;
      case ExperienceMode.pressure:
        // One thing at a time: timer and CTA dominant, secondary recedes,
        // quick stabilizing transition.
        supportCopy = _FocusSupportCopy.pressure;
        secondaryOpacity = 0.55;
        timerScale = 1.04;
        timerPaddingV = NexiiSpacing.xs;
        contextPaddingV = NexiiSpacing.sm;
        ctaEmphasis = true;
        transitionDuration = NexiiMotion.fast;
      case ExperienceMode.checkIn:
        // Adaptive and gentle: slightly lower secondary density, normal
        // timer semantics, gentle transition.
        supportCopy = _FocusSupportCopy.checkIn;
        transitionDuration = NexiiMotion.normal;
      case ExperienceMode.priority:
        // The canonical target leads: strongest timer hierarchy, clear
        // CTA, no decorative motion.
        supportCopy = _FocusSupportCopy.priority;
        timerScale = 1.05;
        glowStrength = 1.2;
        ctaEmphasis = true;
        transitionDuration = NexiiMotion.fast;
      case ExperienceMode.calm:
        // Baseline: the existing Focus experience, open and clean.
        supportCopy = _FocusSupportCopy.calm;
        transitionDuration = NexiiMotion.normal;
    }

    return _FocusPresentation(
      supportCopy: supportCopy,
      secondaryOpacity: secondaryOpacity.clamp(0.42, 1.0),
      timerScale: timerScale,
      timerPaddingV: timerPaddingV,
      glowStrength: glowStrength,
      contextPaddingV: contextPaddingV,
      ctaEmphasis: ctaEmphasis,
      transitionDuration: transitionDuration,
    );
  }
}

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> with TickerProviderStateMixin {
  Timer? _timer;
  int _secondsRemaining = 1500; // 25 minutes default
  int _totalDuration = 1500;
  bool _isRunning = false;
  String _mode = 'Pomodoro'; // 'Pomodoro', 'Coherence', 'Flow'

  // Audio Players
  final AudioPlayer _ambientPlayer = AudioPlayer();
  final AudioPlayer _chimePlayer = AudioPlayer();

  final Map<String, String> _soundUrls = {
    'Pluie': 'audio/focus/rain.mp3',
    'Pluie en Forêt': 'audio/focus/rain.mp3',
    'Océan': 'audio/focus/ocean.mp3',
    'Forêt Zen': 'audio/focus/forest.mp3',
  };
  final String _chimeUrl = 'https://assets.mixkit.co/active_storage/sfx/911/911-84.wav';

  // For Cardiac Coherence Breathing Animation
  AnimationController? _breathController;
  Animation<double>? _breathAnimation;
  String _breathText = 'Inspirez';

  @override
  void initState() {
    super.initState();
    _ambientPlayer.setReleaseMode(ReleaseMode.loop);
    _initBreathingAnimation();
  }

  void _initBreathingAnimation() {
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _breathAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _breathController!, curve: Curves.easeInOut),
    );

    _breathController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _breathText = 'Expirez';
          });
        }
        _playChime();
        _breathController!.reverse();
      } else if (status == AnimationStatus.dismissed) {
        if (mounted) {
          setState(() {
            _breathText = 'Inspirez';
          });
        }
        _playChime();
        _breathController!.forward();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathController?.dispose();
    _ambientPlayer.dispose();
    _chimePlayer.dispose();
    super.dispose();
  }

  Future<void> _playAmbient(String sound) async {
    String? assetPath = _soundUrls[sound] ?? _soundUrls['Pluie'];
    if (assetPath != null) {
      if (assetPath.startsWith('assets/')) {
        assetPath = assetPath.substring('assets/'.length);
      }
      try {
        await _ambientPlayer.stop();
        await _ambientPlayer.play(AssetSource(assetPath));
      } catch (e) {
        debugPrint('Error playing ambient audio: $e');
      }
    }
  }

  void _stopAmbient() async {
    try {
      await _ambientPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping ambient audio: $e');
    }
  }

  void _playChime() async {
    try {
      await _chimePlayer.stop();
      await _chimePlayer.play(UrlSource(_chimeUrl));
    } catch (e) {
      debugPrint('Error playing chime: $e');
    }
  }

  void _startTimer(AppStateProvider state) {
    if (_isRunning) return;

    _timer?.cancel();

    setState(() {
      _isRunning = true;
    });

    _playAmbient(state.selectedSound);

    if (_mode == 'Coherence') {
      _playChime();
      _breathController!.forward();
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        _onSessionComplete(state);
      }
    });
  }

  void _onSessionComplete(AppStateProvider state) {
    _stopTimer();
    final mins = _mode == 'Pomodoro' ? 25 : (_mode == 'Flow' ? 50 : 2);
    state.addFocusMinutes(mins);

    state.addNotification(
      _mode == 'Coherence' ? 'Cohérence Réussie 🧘' : 'Concentration Complétée 🍅',
      _mode == 'Coherence'
          ? 'Félicitations ! Vous avez complété une session de respiration de $mins minutes (+4 XP).'
          : 'Excellent ! Vous avez complété une session de concentration de $mins minutes (+50 XP).',
      _mode == 'Coherence' ? 'info' : 'success',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_mode == 'Coherence'
              ? 'Session Cohérence Cardiaque complétée (+2 min, +4 XP)'
              : 'Session Focus complétée (+$mins min, +50 XP)'),
          backgroundColor: const Color(0xff22c55e),
        ),
      );
    }
  }

  void _pauseTimer() {
    _timer?.cancel();
    _breathController?.stop();
    _stopAmbient();
    setState(() {
      _isRunning = false;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _breathController?.reset();
    _stopAmbient();
    setState(() {
      _isRunning = false;
      _secondsRemaining = _getDurationForMode(_mode);
      _totalDuration = _secondsRemaining;
    });
  }

  int _getDurationForMode(String mode) {
    if (mode == 'Coherence') return 120;
    if (mode == 'Flow') return 3000;
    return 1500; // Pomodoro
  }

  void _toggleMode(String newMode) {
    _pauseTimer();
    setState(() {
      _mode = newMode;
      _secondsRemaining = _getDurationForMode(newMode);
      _totalDuration = _secondsRemaining;
    });
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _showSoundPicker(BuildContext context, AppStateProvider state) {
    final lang = state.currentLocale.languageCode;
    final s = _FocusStrings(lang);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final sounds = ['Pluie', 'Océan', 'Forêt Zen'];
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.ambientSoundPicker,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                ...sounds.map((sound) {
                  final isSelected = state.selectedSound == sound;
                  return ListTile(
                    leading: Icon(
                      Icons.graphic_eq_rounded,
                      color: isSelected ? const Color(0xff8b5cf6) : Colors.grey,
                    ),
                    title: Text(
                      sound,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xff8b5cf6) : null,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: Color(0xff8b5cf6))
                        : null,
                    onTap: () {
                      state.setSound(sound);
                      if (_isRunning) {
                        _playAmbient(sound);
                      }
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    // Canonical intelligence interpretation — the very same ExperienceState
    // Home and Tasks consume. Focus presents it; it never re-decides it.
    final experience = state.currentExperienceState;
    final presentation = _FocusPresentation.from(experience);
    // Motion maps to meaning; reduced motion collapses it to zero.
    final Duration motion = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : presentation.transitionDuration;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = state.currentLocale.languageCode;
    final s = _FocusStrings(lang);

    // Active context: the canonical task-focused target when it maps to a
    // real open task, otherwise the screen's existing selection — display
    // only; this never drives the timer.
    final Map<String, dynamic>? activeTask =
        _resolveActiveTask(state, experience);

    final progress = _totalDuration > 0
        ? ((_totalDuration - _secondsRemaining) / _totalDuration).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.blur_on_rounded, color: Color(0xff8b5cf6), size: 24),
            const SizedBox(width: 10),
            Text(
              s.screenTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1. NEXII PULSE — one coherent state header: context
                  // + grounded supporting copy, keyed by the canonical
                  // Experience state (single movement, never per-child).
                  _buildExperiencePulse(
                    motion: motion,
                    experience: experience,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildContextSection(
                            state, activeTask, isDark, s, presentation),
                        const SizedBox(height: 6),
                        Text(
                          s.supportCopy(presentation.supportCopy),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? NexiiColors.deepTextSecondary
                                : NexiiColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. MODE SELECTORS (Pills immersives) — secondary
                  // controls recede with the canonical density.
                  Opacity(
                    opacity: presentation.secondaryOpacity,
                    child: _buildModeSelectors(s),
                  ),

                  // 3. TIMER VISUEL IMMERSIF — the anchor: spacing, scale
                  // and glow respond to the canonical state; the timer's
                  // arithmetic never changes.
                  AnimatedPadding(
                    duration: motion,
                    padding: EdgeInsets.symmetric(
                        vertical: presentation.timerPaddingV),
                    child: AnimatedScale(
                      scale: presentation.timerScale,
                      duration: motion,
                      child: _buildTimerDial(
                          context, progress, isDark, s, presentation),
                    ),
                  ),

                  // 4. SÉLECTEUR DE SONS D'AMBIANCE (secondary)
                  Opacity(
                    opacity: presentation.secondaryOpacity,
                    child: _buildSoundSelector(state, isDark),
                  ),

                  // 5. CONTRÔLES D'ACTION — essential; always fully
                  // visible in every mode.
                  _buildActionControls(state, s, presentation),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Active context task: the canonical task-focused target (the same
  /// ExperienceState Home and Tasks read) when it maps to a real open
  /// task; otherwise the screen's existing selection is preserved
  /// verbatim. Stale/missing canonical targets fall back safely.
  /// Display only — this never drives the timer.
  Map<String, dynamic>? _resolveActiveTask(
    AppStateProvider state,
    ExperienceState experience,
  ) {
    final openTasks =
        state.tasks.where((t) => t['isCompleted'] != true).toList();
    if (openTasks.isEmpty) return null;

    if (experience.dominantFocus == ExperienceDominantFocus.primaryTask) {
      final targetId = experience.primaryAction.targetId;
      final matches =
          openTasks.where((t) => t['id']?.toString() == targetId);
      if (matches.isNotEmpty) return matches.first;
      // Stale/missing canonical target → existing Focus behavior below.
    }
    return openTasks.firstWhere(
      (t) => t['priority'] == 'Haute',
      orElse: () => openTasks.first,
    );
  }

  /// Nexii Pulse: when the canonical Experience state changes, Focus
  /// quietly reorganizes itself through a single coherent movement —
  /// a cross-fade with a small upward settle, mirroring Home's
  /// Experience shift. Never per-child animation; zero duration under
  /// reduced motion; never blocks or feeds the timer.
  Widget _buildExperiencePulse({
    required Duration motion,
    required ExperienceState experience,
    required Widget child,
  }) {
    return AnimatedSwitcher(
      duration: motion,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<String>(
          '${experience.mode.name}:${experience.primaryAction.targetId}',
        ),
        child: child,
      ),
    );
  }

  // --- 1. CONTEXTE ---
  Widget _buildContextSection(
    AppStateProvider state,
    Map<String, dynamic>? activeTask,
    bool isDark,
    _FocusStrings s,
    _FocusPresentation presentation,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: 18, vertical: presentation.contextPaddingV),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.currentIntentionHeader.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff8b5cf6),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  activeTask != null ? (activeTask['title'] ?? '') : s.freeFocusTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (activeTask != null && activeTask['priority'] != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${s.priorityLabel}: ${activeTask['priority']}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xff8b5cf6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.flash_on_rounded, size: 14, color: Color(0xff8b5cf6)),
                const SizedBox(width: 4),
                Text(
                  '${state.focusMinutesTotal} min',
                  style: const TextStyle(
                    color: Color(0xff8b5cf6),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. MODES ---
  Widget _buildModeSelectors(_FocusStrings s) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildModePill('Pomodoro', s.pomodoroMode, _mode == 'Pomodoro'),
        const SizedBox(width: 8),
        _buildModePill('Coherence', s.coherenceMode, _mode == 'Coherence'),
        const SizedBox(width: 8),
        _buildModePill('Flow', s.flowMode, _mode == 'Flow'),
      ],
    );
  }

  Widget _buildModePill(String modeKey, String label, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleMode(modeKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff8b5cf6) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xff8b5cf6) : Colors.grey.withValues(alpha: 0.35),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  // --- 3. TIMER DIAL ---
  Widget _buildTimerDial(
    BuildContext context,
    double progress,
    bool isDark,
    _FocusStrings s,
    _FocusPresentation presentation,
  ) {
    if (_mode == 'Coherence' && _isRunning) {
      return AnimatedBuilder(
        animation: _breathAnimation!,
        builder: (context, child) {
          final scale = _breathAnimation!.value;
          return Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xff8b5cf6).withValues(alpha: 0.08 * scale),
              border: Border.all(
                color: const Color(0xff8b5cf6).withValues(alpha: 0.25 * scale),
                width: 4.0 + (14.0 * scale),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff8b5cf6).withValues(alpha: 0.15 * scale),
                  blurRadius: 36 * scale,
                  spreadRadius: 8 * scale,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _breathText,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff8b5cf6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(_secondsRemaining),
                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Subtle ambient glow
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: const Color(0xff8b5cf6).withValues(
                    alpha: (_isRunning ? 0.18 : 0.06) *
                        presentation.glowStrength),
                blurRadius: _isRunning ? 34 : 16,
                spreadRadius: _isRunning ? 6 : 1,
              ),
            ],
          ),
        ),
        // Circular progress ring
        SizedBox(
          width: 240,
          height: 240,
          child: CircularProgressIndicator(
            value: _isRunning ? (1.0 - progress) : 1.0,
            strokeWidth: 6,
            backgroundColor: isDark ? const Color(0xff1e293b) : const Color(0xfff1f5f9),
            valueColor: AlwaysStoppedAnimation<Color>(
              _isRunning ? const Color(0xff8b5cf6) : const Color(0xff8b5cf6).withValues(alpha: 0.35),
            ),
          ),
        ),
        // Timer center display
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatTime(_secondsRemaining),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _isRunning ? s.activeFocusState : s.readyToFocusState,
              style: TextStyle(
                color: _isRunning ? const Color(0xff8b5cf6) : Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- 4. SOUND PICKER ---
  Widget _buildSoundSelector(AppStateProvider state, bool isDark) {
    return GestureDetector(
      onTap: () => _showSoundPicker(context, state),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.music_note_rounded, color: Color(0xff8b5cf6), size: 16),
            const SizedBox(width: 8),
            Text(
              state.selectedSound,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  // --- 5. ACTION CONTROLS ---
  Widget _buildActionControls(
    AppStateProvider state,
    _FocusStrings s,
    _FocusPresentation presentation,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.rotate_left_rounded, size: 26, color: Colors.grey),
          tooltip: s.resetTooltip,
          onPressed: _stopTimer,
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          key: ValueKey<bool>(presentation.ctaEmphasis),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isRunning ? const Color(0xfff59e0b) : const Color(0xff8b5cf6),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
                horizontal: presentation.ctaEmphasis ? 56 : 44,
                vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            elevation: presentation.ctaEmphasis ? 4 : 2,
          ),
          onPressed: _isRunning ? _pauseTimer : () => _startTimer(state),
          child: Text(
            _isRunning ? s.pauseAction : s.startAction,
            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1, fontSize: 14),
          ),
        ),
        const SizedBox(width: 20),
        IconButton(
          icon: const Icon(Icons.skip_next_rounded, size: 26, color: Colors.grey),
          tooltip: s.finishEarlyTooltip,
          onPressed: () {
            setState(() {
              _secondsRemaining = 0;
            });
            _startTimer(state);
          },
        ),
      ],
    );
  }
}

class _FocusStrings {
  final String lang;
  _FocusStrings(this.lang);

  String get screenTitle => lang == 'en' ? 'Focus Space' : (lang == 'es' ? 'Espacio de Enfoque' : 'Espace Focus');
  String get currentIntentionHeader => lang == 'en' ? 'CURRENT FOCUS' : (lang == 'es' ? 'ENFOQUE ACTUAL' : 'OBJECTIF ACTIF');
  String get freeFocusTitle => lang == 'en' ? 'Autonomous Deep Work' : (lang == 'es' ? 'Trabajo Profundo Autónomo' : 'Session Libre de Deep Work');
  String get priorityLabel => lang == 'en' ? 'Priority' : (lang == 'es' ? 'Prioridad' : 'Priorité');
  String get pomodoroMode => 'Pomodoro (25m)';
  String get coherenceMode => lang == 'en' ? 'Breathing (2m)' : (lang == 'es' ? 'Respiración (2m)' : 'Cohérence (2m)');
  String get flowMode => 'Flow (50m)';
  String get activeFocusState => lang == 'en' ? 'Deep Work Active' : (lang == 'es' ? 'Enfoque Activo' : 'Immersion Active');
  String get readyToFocusState => lang == 'en' ? 'Ready to focus' : (lang == 'es' ? 'Listo para enfocar' : 'Prêt à focaliser');
  String get ambientSoundPicker => lang == 'en' ? 'Ambient Sounds' : (lang == 'es' ? 'Sonidos de Ambiente' : "Sons d'Ambiance");
  String get startAction => lang == 'en' ? 'START' : (lang == 'es' ? 'INICIAR' : 'DÉMARRER');
  String get pauseAction => lang == 'en' ? 'PAUSE' : (lang == 'es' ? 'PAUSA' : 'PAUSE');
  String get resetTooltip => lang == 'en' ? 'Reset timer' : (lang == 'es' ? 'Reiniciar temporizador' : 'Réinitialiser');
  String get finishEarlyTooltip => lang == 'en' ? 'Complete session' : (lang == 'es' ? 'Completar sesión' : 'Terminer la session');

  /// Grounded, mode-based supporting copy — warm, concise, non-judgmental,
  /// and only as strong as the canonical state actually supports.
  String supportCopy(_FocusSupportCopy copy) {
    switch (copy) {
      case _FocusSupportCopy.recovery:
        return lang == 'en'
            ? 'Take it gently.'
            : (lang == 'es' ? 'Ve con calma.' : 'Allez-y doucement.');
      case _FocusSupportCopy.pressure:
        return lang == 'en'
            ? 'One thing at a time.'
            : (lang == 'es' ? 'Una cosa a la vez.' : 'Une chose à la fois.');
      case _FocusSupportCopy.priority:
        return lang == 'en'
            ? 'This is the one to focus on.'
            : (lang == 'es'
                ? 'Esta merece tu foco.'
                : 'Celle-ci mérite votre focus.');
      case _FocusSupportCopy.checkIn:
        return lang == 'en'
            ? "Let's see what fits now."
            : (lang == 'es'
                ? 'Veamos qué encaja ahora.'
                : 'Voyons ce qui convient maintenant.');
      case _FocusSupportCopy.calm:
        return lang == 'en'
            ? "You're clear to focus."
            : (lang == 'es'
                ? 'Puedes enfocarte con calma.'
                : 'Vous êtes libre de vous concentrer.');
    }
  }
}
