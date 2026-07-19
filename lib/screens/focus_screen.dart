import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/app_state_provider.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> with TickerProviderStateMixin {
  Timer? _timer;
  int _secondsRemaining = 1500; // 25 minutes default
  bool _isRunning = false;
  String _mode = 'Pomodoro'; // 'Pomodoro' or 'Coherence'
  
  // Audio Players
  final AudioPlayer _ambientPlayer = AudioPlayer();
  final AudioPlayer _chimePlayer = AudioPlayer();

  final Map<String, String> _soundUrls = {
    'Pluie': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    'Océan': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
    'Forêt Zen': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
    'Feu de Bois': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
    'Bruit Blanc': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-12.mp3',
  };
  final String _chimeUrl = 'https://assets.mixkit.co/active_storage/sfx/911/911-84.wav';

  // For Cardiac Coherence Breathing Animation
  AnimationController? _breathController;
  Animation<double>? _breathAnimation;
  String _breathText = 'Inspirez'; // 'Inspirez' (Inhale) or 'Expirez' (Exhale)

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
        setState(() {
          _breathText = 'Expirez';
        });
        _playChime();
        _breathController!.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _breathText = 'Inspirez';
        });
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

  void _playAmbient(String sound) async {
    final url = _soundUrls[sound];
    if (url != null) {
      try {
        await _ambientPlayer.stop();
        await _ambientPlayer.play(UrlSource(url));
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

    _timer?.cancel(); // Cancel any existing timer before starting a new one

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
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _stopTimer();
        // Finished! Add focus minutes
        final mins = _mode == 'Pomodoro' ? 25 : 2;
        state.addFocusMinutes(mins);
        
        // Push local in-app notification
        state.addNotification(
          _mode == 'Pomodoro' ? 'Concentration Complétée 🍅' : 'Cohérence Réussie 🧘',
          _mode == 'Pomodoro'
              ? 'Excellent ! Vous avez complété une session de concentration de $mins minutes (+50 XP).'
              : 'Félicitations ! Vous avez complété une session de respiration de $mins minutes (+4 XP).',
          _mode == 'Pomodoro' ? 'success' : 'info',
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_mode == 'Pomodoro'
                ? 'Excellent ! Session Pomodoro complétée (+25 min, +50 XP)'
                : 'Session Cohérence Cardiaque complétée (+2 min, +4 XP)'),
            backgroundColor: const Color(0xff22c55e),
          ),
        );
      }
    });
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
      _secondsRemaining = _mode == 'Pomodoro' ? 1500 : 120;
    });
  }

  void _toggleMode(String newMode) {
    _pauseTimer();
    setState(() {
      _mode = newMode;
      _secondsRemaining = newMode == 'Pomodoro' ? 1500 : 120;
    });
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _showSoundPicker(BuildContext context, AppStateProvider state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final sounds = ['Pluie', 'Océan', 'Forêt Zen', 'Feu de Bois', 'Bruit Blanc'];
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.translate('sound_picker'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                ...sounds.map((sound) {
                  final isSelected = state.selectedSound == sound;
                  return ListTile(
                    leading: Icon(
                      Icons.music_note,
                      color: isSelected ? const Color(0xff8b5cf6) : Colors.grey,
                    ),
                    title: Text(
                      sound,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xff8b5cf6) : null,
                      ),
                    ),
                    trailing: isSelected ? const Icon(Icons.check, color: Color(0xff8b5cf6)) : null,
                    onTap: () {
                      state.setSound(sound);
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

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.timer, color: Color(0xff8b5cf6)),
            const SizedBox(width: 8),
            Text(
              state.translate('focus_title'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mode Selectors
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildModeButton('Pomodoro', _mode == 'Pomodoro'),
                    const SizedBox(width: 12),
                    _buildModeButton('Coherence', _mode == 'Coherence'),
                  ],
                ),
                const SizedBox(height: 40),

                // Timer Visual Ring or Cardiac breathing circle
                _mode == 'Coherence' && _isRunning
                    ? AnimatedBuilder(
                        animation: _breathAnimation!,
                        builder: (context, child) {
                          return Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xff8b5cf6).withOpacity(0.1 * _breathAnimation!.value),
                              border: Border.all(
                                color: const Color(0xff8b5cf6).withOpacity(0.3 * _breathAnimation!.value),
                                width: 4.0 + (16.0 * _breathAnimation!.value),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xff8b5cf6).withOpacity(0.1),
                                  blurRadius: 30,
                                  spreadRadius: 10 * _breathAnimation!.value,
                                )
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _breathText,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff8b5cf6),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatTime(_secondsRemaining),
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).cardColor,
                          border: Border.all(
                            color: const Color(0xff8b5cf6).withOpacity(0.2),
                            width: 10,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff8b5cf6).withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _formatTime(_secondsRemaining),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _mode == 'Pomodoro' ? 'Focus Actif' : 'Cohérence Card.',
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                const SizedBox(height: 40),

                // Sound selector
                GestureDetector(
                  onTap: () => _showSoundPicker(context, state),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.music_note, color: Color(0xff8b5cf6), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          state.selectedSound,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.rotate_left, size: 28),
                      onPressed: _stopTimer,
                    ),
                    const SizedBox(width: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRunning ? Colors.amber : const Color(0xff2563eb),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 2,
                      ),
                      onPressed: _isRunning ? _pauseTimer : () => _startTimer(state),
                      child: Text(
                        _isRunning ? 'PAUSE' : 'DÉMARRER',
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 15),
                      ),
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      icon: const Icon(Icons.skip_next, size: 28),
                      onPressed: () {
                        setState(() {
                          _secondsRemaining = 0;
                        });
                        _startTimer(state); // will trigger finish next second
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(String modeName, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleMode(modeName),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff8b5cf6) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xff8b5cf6) : Colors.grey.shade400,
          ),
        ),
        child: Text(
          modeName == 'Coherence' ? 'Cohérence Cardiaque' : 'Pomodoro',
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
