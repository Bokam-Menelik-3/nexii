import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/focus_provider.dart';
import '../providers/auth_provider.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final focusProvider = context.watch<FocusProvider>();
    final uid = context.read<AuthProvider>().uid;

    final initialSeconds = focusProvider.currentMode == 'Flow'
        ? 40 * 60
        : focusProvider.currentMode == 'Tired'
            ? 20 * 60
            : 25 * 60;

    return Scaffold(
      appBar: AppBar(title: const Text('Focus / Pomodoro')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Productive (25m)'),
                  selected: focusProvider.currentMode == 'Productive',
                  onSelected: focusProvider.isFocusing
                      ? null
                      : (v) => focusProvider.setMode('Productive'),
                ),
                ChoiceChip(
                  label: const Text('Flow (40m)'),
                  selected: focusProvider.currentMode == 'Flow',
                  onSelected: focusProvider.isFocusing
                      ? null
                      : (v) => focusProvider.setMode('Flow'),
                ),
                ChoiceChip(
                  label: const Text('Tired (20m)'),
                  selected: focusProvider.currentMode == 'Tired',
                  onSelected: focusProvider.isFocusing
                      ? null
                      : (v) => focusProvider.setMode('Tired'),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              _formatTime(focusProvider.secondsRemaining),
              style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!focusProvider.isFocusing &&
                    focusProvider.secondsRemaining == initialSeconds)
                  ElevatedButton(
                    onPressed: () => focusProvider.startFocus(),
                    child: const Text('Démarrer'),
                  ),
                if (focusProvider.isFocusing)
                  ElevatedButton(
                    onPressed: () => focusProvider.pauseFocus(),
                    child: const Text('Pause'),
                  ),
                if (!focusProvider.isFocusing &&
                    focusProvider.secondsRemaining > 0 &&
                    focusProvider.secondsRemaining < initialSeconds)
                  ElevatedButton(
                    onPressed: () => focusProvider.resumeFocus(),
                    child: const Text('Reprendre'),
                  ),
                const SizedBox(width: 16),
                if (focusProvider.secondsRemaining < initialSeconds)
                  OutlinedButton(
                    onPressed: () =>
                        focusProvider.stopFocus(completed: false, uid: uid),
                    child: const Text('Arrêter'),
                  ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
                'Temps total de focus: ${focusProvider.focusMinutesTotal} minutes',
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
