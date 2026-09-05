import 'package:flutter_test/flutter_test.dart';
import 'package:nexii/providers/app_state_provider.dart';

import 'dart:io';

void main() {
  HttpOverrides.global = null;

  test('Coach IA connects to Express backend on port 3000 and receives gemini response', () async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    // Target the active Express backend on 127.0.0.1:3000
    provider.updateServerUrl('http://127.0.0.1:3000');
    expect(provider.selectedAiProvider, 'gemini');

    // Send a message via Coach IA
    await provider.sendCoachMessage('Bonjour coach, aide-moi à rester concentré aujourd\'hui');

    // Verify a response was received and provider is 'gemini'
    expect(provider.messages.length, greaterThanOrEqualTo(2));
    final lastMessage = provider.messages.last;
    expect(lastMessage['isUser'], false);
    expect(lastMessage['provider'], 'gemini');
    expect((lastMessage['text'] as String).isNotEmpty, true);
    expect(lastMessage['actions'], isNotNull);
  });

  test('Coach IA falls back to local heuristic when selected provider is local', () async {
    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    provider.updateServerUrl('http://127.0.0.1:3000');
    provider.setSelectedAiProvider('local');
    expect(provider.selectedAiProvider, 'local');

    await provider.sendCoachMessage('Je me sens un peu stressé par mon budget');

    expect(provider.messages.length, greaterThanOrEqualTo(2));
    final lastMessage = provider.messages.last;
    expect(lastMessage['isUser'], false);
    expect(lastMessage['provider'], 'local');
    expect((lastMessage['text'] as String).isNotEmpty, true);
  });
}
