import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/task_model.dart';

/// Response model for Coach API calls (/api/coach).
@immutable
class CoachApiResponse {
  final String text;
  final String provider;
  final Map<String, dynamic>? intent;

  const CoachApiResponse({
    required this.text,
    required this.provider,
    this.intent,
  });

  factory CoachApiResponse.fromMap(Map<String, dynamic> map,
      {String defaultProvider = 'local'}) {
    return CoachApiResponse(
      text: map['text']?.toString() ?? '',
      provider: map['provider']?.toString() ?? defaultProvider,
      intent: map['intent'] as Map<String, dynamic>?,
    );
  }
}

/// Response model for Task Generation API calls (/api/tasks/generate).
@immutable
class GenerateTasksApiResponse {
  final List<Task> tasks;

  const GenerateTasksApiResponse({
    required this.tasks,
  });
}

/// Dedicated HTTP client for Nexii Backend communication.
class NexiiApiClient {
  final String baseUrl;
  final http.Client _client;
  final Duration timeoutDuration;

  NexiiApiClient({
    required this.baseUrl,
    http.Client? client,
    this.timeoutDuration = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  /// Sends a request to POST /api/coach to retrieve AI or local coach advice.
  Future<CoachApiResponse> getCoachAdvice({
    required String userMessage,
    required int nexiiState,
    required int completedTasksCount,
    required int totalTasksCount,
    required String contextMood,
    required int userAge,
    required String provider,
    Map<String, dynamic>? progressContext,
    bool? hasDoneCheckIn,
    Object? checkInMood,
    int? checkInEnergy,
    int? checkInMotivation,
    int? checkInStress,
    int? checkInSleep,
    int? budgetProgress,
  }) async {
    final Uri url = Uri.parse('$baseUrl/api/coach');

    final Map<String, dynamic> body = {
      'userMessage': userMessage,
      'nexiiState': nexiiState,
      'completedTasksCount': completedTasksCount,
      'totalTasksCount': totalTasksCount,
      'contextMood': contextMood,
      'userAge': userAge,
      'provider': provider,
    };

    if (hasDoneCheckIn != null) body['hasDoneCheckIn'] = hasDoneCheckIn;
    if (checkInMood != null) body['checkInMood'] = checkInMood;
    if (checkInEnergy != null) body['checkInEnergy'] = checkInEnergy;
    if (checkInMotivation != null)
      body['checkInMotivation'] = checkInMotivation;
    if (checkInStress != null) body['checkInStress'] = checkInStress;
    if (checkInSleep != null) body['checkInSleep'] = checkInSleep;
    if (budgetProgress != null) body['budgetProgress'] = budgetProgress;
    if (progressContext != null) body['progressContext'] = progressContext;

    try {
      final response = await _client
          .post(
            url,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return CoachApiResponse.fromMap(data, defaultProvider: provider);
      } else {
        throw NexiiHttpException(
          'Backend returned status code ${response.statusCode}',
          uri: url,
        );
      }
    } catch (e) {
      debugPrint('NexiiApiClient.getCoachAdvice error: $e');
      rethrow;
    }
  }

  /// Sends a request to POST /api/tasks/generate to generate AI task recommendations.
  Future<GenerateTasksApiResponse> generateAiTasks({
    required int nexiiState,
    required String mood,
    required String lang,
    required int userAge,
  }) async {
    final Uri url = Uri.parse('$baseUrl/api/tasks/generate');

    final Map<String, dynamic> body = {
      'nexiiState': nexiiState,
      'mood': mood,
      'lang': lang,
      'userAge': userAge,
    };

    try {
      final response = await _client
          .post(
            url,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List tasksList = data['tasks'] as List? ?? [];

        final List<Task> parsedTasks = [];
        int count = 0;
        final timestamp = DateTime.now().millisecondsSinceEpoch;

        for (var t in tasksList) {
          if (t is Map) {
            count++;
            final Map<String, dynamic> taskMap = Map<String, dynamic>.from(t);

            final List rawSubList = taskMap['subtasks'] as List? ?? [];
            final List<SubTask> parsedSubtasks = [];
            int stCount = 0;

            for (var st in rawSubList) {
              stCount++;
              parsedSubtasks.add(SubTask(
                id: 'st_ai_${timestamp}_${count}_$stCount',
                title: st.toString(),
                isCompleted: false,
              ));
            }

            parsedTasks.add(Task(
              id: 'task_ai_${timestamp}_$count',
              title: taskMap['title']?.toString() ?? 'Mission IA Nexii',
              subtitle: 'Suggéré par Nexii Copilote IA',
              category: taskMap['category']?.toString() ?? 'Pro',
              priority: taskMap['priority']?.toString() ?? 'Moyenne',
              urgency: taskMap['urgency']?.toString() ?? 'Moyenne',
              difficulty: taskMap['difficulty']?.toString() ?? 'Facile',
              duration: taskMap['duration']?.toString() ?? '15 min',
              energyNeeded: taskMap['energyNeeded']?.toString() ?? 'Bas',
              isCompleted: false,
              subtasks: parsedSubtasks,
            ));
          }
        }

        return GenerateTasksApiResponse(tasks: parsedTasks);
      } else {
        throw NexiiHttpException(
          'Backend returned status code ${response.statusCode}',
          uri: url,
        );
      }
    } catch (e) {
      debugPrint('NexiiApiClient.generateAiTasks error: $e');
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}

class NexiiHttpException implements Exception {
  final String message;
  final Uri? uri;
  NexiiHttpException(this.message, {this.uri});

  @override
  String toString() =>
      'NexiiHttpException: $message${uri != null ? ' ($uri)' : ''}';
}
