import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../experience/experience_state.dart';
import '../core/theme/nexii_colors.dart';

// ─── Presentation Layer ───────────────────────────────────────────────────────
// Maps canonical ExperienceState → visual parameters only.
// No intelligence, no decisions, no heuristics.

class _CoachPresentation {
  final Color accentColor;
  final String greeting;
  final String subGreeting;
  final String inputHint;
  final double signatureIntensity; // 0.0–1.0
  final double heroVerticalPadding;
  final Duration breathingDuration;

  const _CoachPresentation._({
    required this.accentColor,
    required this.greeting,
    required this.subGreeting,
    required this.inputHint,
    required this.signatureIntensity,
    required this.heroVerticalPadding,
    required this.breathingDuration,
  });

  factory _CoachPresentation.from(ExperienceState state) {
    switch (state.mode) {
      case ExperienceMode.recovery:
        return const _CoachPresentation._(
          accentColor: NexiiColors.aiAccent,
          greeting: 'Prenons un moment.',
          subGreeting: 'Dis-moi comment tu te sens.',
          inputHint: 'Exprime-toi librement…',
          signatureIntensity: 0.55,
          heroVerticalPadding: 32,
          breathingDuration: Duration(milliseconds: 4200),
        );
      case ExperienceMode.pressure:
        return const _CoachPresentation._(
          accentColor: NexiiColors.warning,
          greeting: 'Beaucoup de choses.',
          subGreeting: 'On s\'y met ensemble.',
          inputHint: 'Qu\'est-ce qui pèse le plus ?',
          signatureIntensity: 0.85,
          heroVerticalPadding: 24,
          breathingDuration: Duration(milliseconds: 2400),
        );
      case ExperienceMode.checkIn:
        return const _CoachPresentation._(
          accentColor: NexiiColors.info,
          greeting: 'C\'est le bon moment.',
          subGreeting: 'Comment s\'est passée ta journée ?',
          inputHint: 'Partage ce que tu ressens…',
          signatureIntensity: 0.70,
          heroVerticalPadding: 28,
          breathingDuration: Duration(milliseconds: 3600),
        );
      case ExperienceMode.priority:
        return const _CoachPresentation._(
          accentColor: NexiiColors.primary,
          greeting: 'Focus.',
          subGreeting: 'De quoi as-tu besoin maintenant ?',
          inputHint: 'Qu\'est-ce qui compte aujourd\'hui ?',
          signatureIntensity: 0.90,
          heroVerticalPadding: 24,
          breathingDuration: Duration(milliseconds: 2800),
        );
      case ExperienceMode.calm:
      default:
        return const _CoachPresentation._(
          accentColor: NexiiColors.success,
          greeting: 'Je suis là.',
          subGreeting: 'Tout est fluide. Comment te sens-tu ?',
          inputHint: 'Écris ce qui te vient…',
          signatureIntensity: 0.50,
          heroVerticalPadding: 36,
          breathingDuration: Duration(milliseconds: 4600),
        );
    }
  }
}

// ─── Nexii Signature ──────────────────────────────────────────────────────────
// A small, breathing ambient presence.
// Outer halo ring + inner solid dot. No orb, no glow, no permanent pulse.

class _NexiiSignature extends StatefulWidget {
  final Color accentColor;
  final double intensity;
  final Duration breathingDuration;
  final double size;

  const _NexiiSignature({
    super.key,
    required this.accentColor,
    required this.intensity,
    required this.breathingDuration,
    this.size = 48,
  });

  @override
  State<_NexiiSignature> createState() => _NexiiSignatureState();
}

class _NexiiSignatureState extends State<_NexiiSignature>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _breathe;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.breathingDuration);
    _breathe = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!MediaQuery.of(context).disableAnimations && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_NexiiSignature old) {
    super.didUpdateWidget(old);
    if (old.breathingDuration != widget.breathingDuration) {
      _controller.duration = widget.breathingDuration;
      if (_controller.isAnimating) _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return AnimatedBuilder(
      animation: _breathe,
      builder: (context, _) {
        final t = reduceMotion ? 0.94 : _breathe.value;
        return Transform.scale(
          scale: t,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer halo
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.accentColor.withValues(alpha: widget.intensity * 0.10 * t),
                    border: Border.all(
                      color: widget.accentColor.withValues(alpha: widget.intensity * 0.28 * t),
                      width: 1.0,
                    ),
                  ),
                ),
                // Inner dot
                Container(
                  width: widget.size * 0.26,
                  height: widget.size * 0.26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.accentColor.withValues(
                      alpha: widget.intensity * (0.55 + 0.35 * t),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Send Button ──────────────────────────────────────────────────────────────

class _SendButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color accentColor;

  const _SendButton({required this.onTap, required this.accentColor});

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) {
        _press.reverse();
        widget.onTap();
      },
      onTapCancel: () => _press.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: widget.accentColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_upward_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

// ─── Coach Screen ─────────────────────────────────────────────────────────────

class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();
  bool _isVoiceMode = false;
  bool _inputFocused = false;

  @override
  void initState() {
    super.initState();
    _inputFocus.addListener(() {
      if (mounted) setState(() => _inputFocused = _inputFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _handleSend(AppStateProvider state) {
    final text = _chatController.text.trim();
    if (text.isNotEmpty) {
      state.sendCoachMessage(text);
      _chatController.clear();
      _scrollToBottom();
      Future.delayed(const Duration(milliseconds: 120), _scrollToBottom);
      Future.delayed(const Duration(milliseconds: 1000), _scrollToBottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final p = _CoachPresentation.from(state.currentExperienceState);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasMessages = state.messages.isNotEmpty;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final textPrimary =
        isDark ? NexiiColors.deepTextPrimary : NexiiColors.lightTextPrimary;
    final textSecondary =
        isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary;

    if (hasMessages && !_isVoiceMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    return Scaffold(
      backgroundColor:
          isDark ? NexiiColors.deepBackground : NexiiColors.lightBackground,
      appBar: _buildAppBar(state, p, isDark, textPrimary, textSecondary),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 360),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.985, end: 1.0).animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          ),
          child: _isVoiceMode
              ? _buildVoiceMode(p, textPrimary, textSecondary)
              : _buildChatMode(
                  context, state, p, isDark, hasMessages,
                  textPrimary, textSecondary),
        ),
      ),
    );
  }

  // ─── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
    AppStateProvider state,
    _CoachPresentation p,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            child: _NexiiSignature(
              key: ValueKey(p.accentColor.value),
              accentColor: p.accentColor,
              intensity: p.signatureIntensity,
              breathingDuration: p.breathingDuration,
              size: 32,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            state.translate('coach_title'),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: textPrimary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isVoiceMode ? Icons.chat_bubble_outline : Icons.mic_none,
              key: ValueKey(_isVoiceMode),
              size: 20,
              color: textSecondary,
            ),
          ),
          onPressed: () => setState(() => _isVoiceMode = !_isVoiceMode),
          tooltip: _isVoiceMode ? 'Mode conversation' : 'Mode vocal',
        ),
      ],
    );
  }

  // ─── Chat Mode ─────────────────────────────────────────────────────────────

  Widget _buildChatMode(
    BuildContext context,
    AppStateProvider state,
    _CoachPresentation p,
    bool isDark,
    bool hasMessages,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Column(
      key: const ValueKey('chat'),
      children: [
        if (!hasMessages)
          Expanded(child: _buildHero(p, textPrimary, textSecondary))
        else
          Expanded(child: _buildConversation(context, state, p, isDark, textPrimary)),
        if (state.isCoachTyping) _buildTypingIndicator(p, textSecondary),
        _buildInput(context, state, p, isDark, textSecondary),
      ],
    );
  }

  // ─── Hero: empty state ─────────────────────────────────────────────────────

  Widget _buildHero(
    _CoachPresentation p,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: p.heroVerticalPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 3),
          _NexiiSignature(
            accentColor: p.accentColor,
            intensity: p.signatureIntensity,
            breathingDuration: p.breathingDuration,
            size: 48,
          ),
          SizedBox(height: p.heroVerticalPadding * 0.75),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 380),
            child: Align(
              key: ValueKey(p.greeting),
              alignment: Alignment.centerLeft,
              child: Text(
                p.greeting,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.6,
                  height: 1.15,
                  color: textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 380),
            child: Align(
              key: ValueKey(p.subGreeting),
              alignment: Alignment.centerLeft,
              child: Text(
                p.subGreeting,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: textSecondary,
                ),
              ),
            ),
          ),
          const Spacer(flex: 4),
        ],
      ),
    );
  }

  // ─── Conversation ──────────────────────────────────────────────────────────

  Widget _buildConversation(
    BuildContext context,
    AppStateProvider state,
    _CoachPresentation p,
    bool isDark,
    Color textPrimary,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      itemCount: state.messages.length,
      itemBuilder: (context, index) =>
          _buildBubble(context, state.messages[index], p, isDark, textPrimary),
    );
  }

  Widget _buildBubble(
    BuildContext context,
    Map<String, dynamic> msg,
    _CoachPresentation p,
    bool isDark,
    Color textPrimary,
  ) {
    final bool isUser = msg['isUser'] as bool;
    final String text = msg['text'] as String;
    final double maxW = MediaQuery.of(context).size.width * 0.78;

    return Padding(
      padding: EdgeInsets.only(
        top: 3, bottom: 3,
        left: isUser ? 56 : 0,
        right: isUser ? 0 : 56,
      ),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: maxW),
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: isUser
                ? p.accentColor
                : (isDark
                    ? NexiiColors.deepSurfacePrimary.withValues(alpha: 0.55)
                    : NexiiColors.lightSurfaceSecondary),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isUser ? 18 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 18),
            ),
            border: isUser
                ? null
                : Border.all(
                    color: isDark
                        ? NexiiColors.deepBorder.withValues(alpha: 0.35)
                        : NexiiColors.lightBorder,
                    width: 0.8,
                  ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              height: 1.45,
              color: isUser ? Colors.white : textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Typing indicator ──────────────────────────────────────────────────────

  Widget _buildTypingIndicator(_CoachPresentation p, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(strokeWidth: 1.5, color: p.accentColor),
          ),
          const SizedBox(width: 9),
          Text(
            'Nexii réfléchit…',
            style: TextStyle(
              fontSize: 12,
              color: textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Input ─────────────────────────────────────────────────────────────────

  Widget _buildInput(
    BuildContext context,
    AppStateProvider state,
    _CoachPresentation p,
    bool isDark,
    Color textSecondary,
  ) {
    final surfaceColor = isDark ? NexiiColors.deepElevated : NexiiColors.lightElevated;
    final borderColor = _inputFocused
        ? p.accentColor.withValues(alpha: 0.45)
        : (isDark ? NexiiColors.deepBorder : NexiiColors.lightBorder);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor, width: _inputFocused ? 1.4 : 1.0),
          boxShadow: _inputFocused
              ? [BoxShadow(color: p.accentColor.withValues(alpha: 0.07), blurRadius: 18, offset: const Offset(0, 4))]
              : const [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _chatController,
                focusNode: _inputFocus,
                onSubmitted: (_) => _handleSend(state),
                maxLines: 5,
                minLines: 1,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: isDark ? NexiiColors.deepTextPrimary : NexiiColors.lightTextPrimary,
                ),
                decoration: InputDecoration(
                  hintText: p.inputHint,
                  hintStyle: TextStyle(fontSize: 15, color: textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.fromLTRB(20, 14, 8, 14),
                  isDense: true,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              child: _SendButton(onTap: () => _handleSend(state), accentColor: p.accentColor),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Voice Mode ────────────────────────────────────────────────────────────

  Widget _buildVoiceMode(_CoachPresentation p, Color textPrimary, Color textSecondary) {
    return Padding(
      key: const ValueKey('voice'),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          _NexiiSignature(
            accentColor: p.accentColor,
            intensity: (p.signatureIntensity * 1.2).clamp(0.0, 1.0),
            breathingDuration: const Duration(milliseconds: 2400),
            size: 64,
          ),
          const SizedBox(height: 36),
          Text(
            'Nexii est à l\'écoute.',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, letterSpacing: -0.4, color: textPrimary),
          ),
          const SizedBox(height: 10),
          Text('Parlez naturellement.', style: TextStyle(fontSize: 14, color: textSecondary)),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

import '../core/widgets/adaptive_living_widgets.dart';

class _CoachPresentation {
  final Color accentColor;
  final IconData ambientIcon;
  final String contextualGreeting;
  final double opacity;
  
  _CoachPresentation._({
    required this.accentColor,
    required this.ambientIcon,
    required this.contextualGreeting,
    required this.opacity,
  });

  factory _CoachPresentation.from(ExperienceState state, AppStateProvider appState) {
    switch (state.mode) {
      case ExperienceMode.recovery:
        return _CoachPresentation._(
          accentColor: NexiiColors.aiAccent,
          ambientIcon: Icons.self_improvement,
          contextualGreeting: 'Je vois que l\'énergie est basse. Que puis-je faire pour alléger ta charge ?',
          opacity: 0.6,
        );
      case ExperienceMode.pressure:
        return _CoachPresentation._(
          accentColor: NexiiColors.warning,
          ambientIcon: Icons.crisis_alert,
          contextualGreeting: 'Beaucoup de choses en cours. On s\'y met ensemble ?',
          opacity: 0.8,
        );
      case ExperienceMode.checkIn:
        return _CoachPresentation._(
          accentColor: NexiiColors.info,
          ambientIcon: Icons.edit_note,
          contextualGreeting: 'C\'est le moment idéal pour faire le point.',
          opacity: 1.0,
        );
      case ExperienceMode.priority:
        return _CoachPresentation._(
          accentColor: NexiiColors.primary,
          ambientIcon: Icons.adjust,
          contextualGreeting: 'Focus sur l\'essentiel. De quoi as-tu besoin ?',
          opacity: 1.0,
        );
      case ExperienceMode.calm:
      default:
        return _CoachPresentation._(
          accentColor: NexiiColors.success,
          ambientIcon: Icons.spa,
          contextualGreeting: 'Tout est fluide. Comment te sens-tu ?',
          opacity: 1.0,
        );
    }
  }
}

class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isVoiceMode = false;

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend(AppStateProvider state) {
    final text = _chatController.text.trim();
    if (text.isNotEmpty) {
      state.sendCoachMessage(text);
      _chatController.clear();
      _scrollToBottom();
      
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      Future.delayed(const Duration(milliseconds: 1000), _scrollToBottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final experience = state.currentExperienceState;
    final presentation = _CoachPresentation.from(experience, state);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_isVoiceMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    return Scaffold(
      backgroundColor: isDark ? NexiiColors.deepBackground : NexiiColors.lightBackground,
      appBar: AppBar(
        title: Row(
          children: [
            AnimatedSwitcher(
              duration: NexiiMotion.normal,
              child: Icon(
                presentation.ambientIcon, 
                key: ValueKey(presentation.ambientIcon),
                color: presentation.accentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: NexiiSpacing.sm),
            Text(
              state.translate('coach_title'),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isVoiceMode ? Icons.chat_bubble_outline : Icons.mic_none,
              color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary,
            ),
            onPressed: () {
              setState(() {
                _isVoiceMode = !_isVoiceMode;
              });
            },
            tooltip: _isVoiceMode ? 'Passer en mode Chat' : 'Passer en mode Vocal',
          )
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: MediaQuery.of(context).disableAnimations ? Duration.zero : NexiiMotion.slow,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          ),
          child: _isVoiceMode
              ? _buildVoiceMode(context, state, presentation, isDark)
              : _buildChatMode(context, state, presentation, isDark),
        ),
      ),
    );
  }

  Widget _buildVoiceMode(BuildContext context, AppStateProvider state, _CoachPresentation presentation, bool isDark) {
    return Container(
      key: const ValueKey('voiceMode'),
      width: double.infinity,
      padding: const EdgeInsets.all(NexiiSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: NexiiMotion.slow,
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: presentation.accentColor.withValues(alpha: 0.1),
              border: Border.all(
                color: presentation.accentColor.withValues(alpha: 0.3),
                width: 1.0,
              ),
            ),
            child: Icon(Icons.mic, size: 48, color: presentation.accentColor),
          ),
          const SizedBox(height: NexiiSpacing.xxl),
          Text(
            'Nexii est à l\'écoute...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: presentation.accentColor,
            ),
          ),
          const SizedBox(height: NexiiSpacing.sm),
          Text(
            'Parlez naturellement.',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMode(BuildContext context, AppStateProvider state, _CoachPresentation presentation, bool isDark) {
    return Column(
      key: const ValueKey('chatMode'),
      children: [
        // AI Contextual Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: NexiiSpacing.lg, vertical: NexiiSpacing.sm),
          child: AnimatedOpacity(
            duration: NexiiMotion.normal,
            opacity: presentation.opacity,
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 14, color: presentation.accentColor),
                const SizedBox(width: NexiiSpacing.sm),
                Expanded(
                  child: Text(
                    presentation.contextualGreeting,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Messages list
        Expanded(
          child: state.messages.isEmpty
              ? Center(
                  child: Text(
                    'Aucun message. Dites bonjour à votre coach !',
                    style: TextStyle(
                      color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary,
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: NexiiSpacing.lg, vertical: NexiiSpacing.md),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final msg = state.messages[index];
                    return _buildMessageBubble(context, state, msg, presentation, isDark);
                  },
                ),
        ),

        // Typing Indicator
        if (state.isCoachTyping)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: NexiiSpacing.xl, vertical: NexiiSpacing.sm),
            child: Row(
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2, color: presentation.accentColor),
                ),
                const SizedBox(width: NexiiSpacing.sm),
                Text(
                  'Le coach réfléchit...',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        
        // Chat entry box
        Padding(
          padding: const EdgeInsets.all(NexiiSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: NexiiSpacing.lg),
                  decoration: BoxDecoration(
                    color: isDark ? NexiiColors.deepElevated : NexiiColors.lightElevated,
                    borderRadius: BorderRadius.circular(NexiiRadii.xxl),
                    border: Border.all(
                      color: isDark ? NexiiColors.deepBorder : NexiiColors.lightBorder,
                    ),
                  ),
                  child: TextField(
                    controller: _chatController,
                    onSubmitted: (_) => _handleSend(state),
                    style: TextStyle(
                      color: isDark ? NexiiColors.deepTextPrimary : NexiiColors.lightTextPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: state.translate('placeholder_chat'),
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: isDark ? NexiiColors.deepTextSecondary : NexiiColors.lightTextSecondary,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: NexiiSpacing.md),
              GestureDetector(
                onTap: () => _handleSend(state),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: presentation.accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(
    BuildContext context, 
    AppStateProvider state, 
    Map<String, dynamic> msg,
    _CoachPresentation presentation,
    bool isDark,
  ) {
    final bool isUser = msg['isUser'] as bool;
    final String text = msg['text'] as String;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: NexiiSpacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: NexiiSpacing.lg, vertical: NexiiSpacing.md),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser 
              ? presentation.accentColor 
              : (isDark ? NexiiColors.deepElevated : NexiiColors.lightElevated),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(NexiiRadii.xl),
            topRight: const Radius.circular(NexiiRadii.xl),
            bottomLeft: isUser ? const Radius.circular(NexiiRadii.xl) : const Radius.circular(NexiiRadii.xs),
            bottomRight: isUser ? const Radius.circular(NexiiRadii.xs) : const Radius.circular(NexiiRadii.xl),
          ),
          border: isUser 
              ? null 
              : Border.all(
                  color: isDark ? NexiiColors.deepBorder : NexiiColors.lightBorder,
                ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : (isDark ? NexiiColors.deepTextPrimary : NexiiColors.lightTextPrimary),
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

