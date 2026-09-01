import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nexii/core/services/nexii_api_client.dart';

void main() {
  group('NexiiApiClient Tests', () {
    test('getCoachAdvice returns CoachApiResponse on 200 OK', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/coach');
        expect(request.method, 'POST');
        final body = jsonDecode(request.body);
        expect(body['userMessage'], 'Bonjour');
        expect(body['nexiiState'], 80);

        return http.Response(
          jsonEncode({
            'text': 'Conseil IA test',
            'provider': 'gemini',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = NexiiApiClient(
        baseUrl: 'http://localhost:3000',
        client: mockClient,
      );

      final response = await apiClient.getCoachAdvice(
        userMessage: 'Bonjour',
        nexiiState: 80,
        completedTasksCount: 2,
        totalTasksCount: 5,
        contextMood: 'Zen',
        userAge: 25,
        provider: 'gemini',
      );

      expect(response.text, 'Conseil IA test');
      expect(response.provider, 'gemini');
    });

    test('generateAiTasks parses tasks correctly on 200 OK', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/tasks/generate');
        expect(request.method, 'POST');

        return http.Response(
          jsonEncode({
            'tasks': [
              {
                'title': 'Tâche IA 1',
                'category': 'Pro',
                'priority': 'Haute',
                'urgency': 'Moyenne',
                'difficulty': 'Facile',
                'duration': '10 min',
                'energyNeeded': 'Bas',
                'subtasks': ['Sous-tâche 1', 'Sous-tâche 2']
              }
            ]
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = NexiiApiClient(
        baseUrl: 'http://localhost:3000',
        client: mockClient,
      );

      final response = await apiClient.generateAiTasks(
        nexiiState: 75,
        mood: 'Zen',
        lang: 'fr',
        userAge: 25,
      );

      expect(response.tasks.length, 1);
      final task = response.tasks.first;
      expect(task.title, 'Tâche IA 1');
      expect(task.category, 'Pro');
      expect(task.subtasks.length, 2);
      expect(task.subtasks.first.title, 'Sous-tâche 1');
    });

    test('throws NexiiHttpException on non-200 status code', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Error', 500);
      });

      final apiClient = NexiiApiClient(
        baseUrl: 'http://localhost:3000',
        client: mockClient,
      );

      expect(
        apiClient.getCoachAdvice(
          userMessage: 'Test',
          nexiiState: 50,
          completedTasksCount: 0,
          totalTasksCount: 0,
          contextMood: 'Neutre',
          userAge: 20,
          provider: 'local',
        ),
        throwsA(isA<NexiiHttpException>()),
      );
    });
  });
}
