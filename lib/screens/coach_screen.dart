import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isVoiceMode = false;
  bool _isSimulatingSpeech = false;

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
      state.sendMessage(text);
      _chatController.clear();
      _scrollToBottom();
      
      // Delay to scroll again after simulated reply starts typing/responding
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom();
      });
      Future.delayed(const Duration(milliseconds: 1600), () {
        _scrollToBottom();
      });
    }
  }

  String _getLatestCoachMessage(AppStateProvider state) {
    if (state.messages.isEmpty) {
      return "Salut ! Je t'écoute. Comment te sens-tu aujourd'hui ?";
    }
    for (int i = state.messages.length - 1; i >= 0; i--) {
      final msg = state.messages[i];
      if (msg['isUser'] == false) {
        return msg['text'] as String;
      }
    }
    return "Salut ! Je t'écoute. Comment te sens-tu aujourd'hui ?";
  }

  void _simulateVoiceCommand(AppStateProvider state) {
    if (_isSimulatingSpeech) return;
    
    final simulatedInputs = [
      "Je me sens un peu fatigué aujourd'hui mais j'ai des devoirs importants à rendre.",
      "Aujourd'hui, j'ai une énergie au top ! Planifie mes tâches les plus dures.",
      "Je me sens stressé par mon budget."
    ];
    
    // Pick a random input
    final random = DateTime.now().millisecond % simulatedInputs.length;
    final randomInput = simulatedInputs[random];
    
    setState(() {
      _isSimulatingSpeech = true;
    });
    
    // Send user message and trigger response in State Provider
    state.sendMessage("🎤 [Vocal User] \"$randomInput\"");
    
    // After 1.5s, complete simulation animation
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isSimulatingSpeech = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    // Call scroll on build if list changes and in chat mode
    if (!_isVoiceMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.psychology, color: Color(0xff8b5cf6)),
            const SizedBox(width: 8),
            Text(
              state.translate('coach_title'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isVoiceMode ? Icons.chat_bubble : Icons.mic,
              color: const Color(0xff8b5cf6),
            ),
            onPressed: () {
              setState(() {
                _isVoiceMode = !_isVoiceMode;
                if (_isVoiceMode) {
                  // Pre-fill voice greeting if last message isn't already vocal
                  final latest = _getLatestCoachMessage(state);
                  if (!latest.startsWith('🎤')) {
                    state.sendMessage("🎤 [Coach Vocal] Salut ! Je t'écoute. Comment te sens-tu aujourd'hui ?");
                  }
                }
              });
            },
            tooltip: _isVoiceMode ? 'Passer en mode Chat' : 'Passer en mode Vocal',
          )
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isVoiceMode) ...[
              // Vocal dashboard Layout
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xff8b5cf6).withOpacity(0.12),
                        const Color(0xff2563eb).withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xff8b5cf6).withOpacity(0.25)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pulsing Mic Icon
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: const Color(0xff8b5cf6).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 85,
                            height: 85,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xff8b5cf6), Color(0xff3b82f6)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xff8b5cf6).withOpacity(0.35),
                                  blurRadius: 18,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.mic, color: Colors.white, size: 36),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Status Texts
                      Text(
                        _isSimulatingSpeech ? 'Nexii écoute...' : 'Nexii Vocal est à l\'écoute...',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff8b5cf6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Exprimez-vous ou simulez une commande vocale pour continuer',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      
                      // Waveform Animation
                      WaveformBouncer(active: !_isSimulatingSpeech),
                      const SizedBox(height: 24),
                      
                      // Latest response bubble
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Theme.of(context).dividerColor),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.record_voice_over, size: 14, color: Color(0xff8b5cf6)),
                                    SizedBox(width: 6),
                                    Text(
                                      'Réponse du Coach Vocal :',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff8b5cf6),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _getLatestCoachMessage(state),
                                  style: const TextStyle(fontSize: 13, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Simuler button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2563eb),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.record_voice_over, size: 18),
                        label: const Text(
                          'Simuler une commande vocale',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        onPressed: () {
                          _simulateVoiceCommand(state);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // AI coach header tip
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xff8b5cf6).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xff8b5cf6).withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xff8b5cf6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.spa, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Compagnon IA Nexii',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff8b5cf6)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Je suis là pour vous aider à équilibrer votre vie, gérer vos émotions et atteindre vos buts calmement.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Messages list
              Expanded(
                child: state.messages.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucun message. Dites bonjour à votre coach !',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final msg = state.messages[index];
                          final bool isUser = msg['isUser'] as bool;
                          final String text = msg['text'] as String;
                          return _buildMessageBubble(context, text: text, isUser: isUser);
                        },
                      ),
              ),

              // Typing Indicator
              if (state.isCoachTyping)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xff8b5cf6)),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Le coach réfléchit...',
                              style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Chat entry box
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: TextField(
                          controller: _chatController,
                          onSubmitted: (_) => _handleSend(state),
                          decoration: InputDecoration(
                            hintText: state.translate('placeholder_chat'),
                            hintStyle: const TextStyle(fontSize: 13),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xff2563eb),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 20),
                        onPressed: () => _handleSend(state),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, {required String text, required bool isUser}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser 
              ? const Color(0xff2563eb) 
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
          ),
          border: isUser 
              ? null 
              : Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class WaveformBouncer extends StatefulWidget {
  final bool active;
  const WaveformBouncer({super.key, required this.active});

  @override
  State<WaveformBouncer> createState() => _WaveformBouncerState();
}

class _WaveformBouncerState extends State<WaveformBouncer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.active) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant WaveformBouncer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.active && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(15, (index) {
            final double progress = _controller.value;
            final double factor = (index % 3 + 1) * 0.3;
            double heightFactor = 0.2 + 0.8 * (0.5 + 0.5 * progress * factor);
            if (heightFactor > 1.0) heightFactor = 1.0;
            if (!widget.active) heightFactor = 0.2;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              width: 4,
              height: 25 * heightFactor,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xff8b5cf6),
                    Color(0xff3b82f6),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
