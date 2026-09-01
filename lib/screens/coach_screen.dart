import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/task_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/agenda_provider.dart';
import '../core/services/nexii_api_client.dart';
import '../core/platform_host_io.dart'
    if (dart.library.html) '../core/platform_host_web.dart';
import '../core/intelligence/progress_engine.dart';
import '../core/intelligence/action_engine_service.dart';
import '../models/task_model.dart';
import '../models/goal_model.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final Map<String, dynamic>? intent;

  ChatMessage({required this.text, required this.isUser, this.intent});
}

class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  late NexiiApiClient _apiClient;

  @override
  void initState() {
    super.initState();
    // Choose base url depending on platform. Web builds should use localhost
    // or configured env. For Android emulator, 10.0.2.2 is correct.
    String base = 'http://localhost:3000';
    try {
      // Import guarded to avoid web build failure
      base = getDefaultApiBaseUrl();
    } catch (_) {}
    _apiClient = NexiiApiClient(baseUrl: base);
    _messages.add(ChatMessage(
        text:
            "Bonjour ! Je suis Nexii, ton coach personnel. Comment puis-je t'aider aujourd'hui ?",
        isUser: false));
  }

  @override
  void dispose() {
    _textController.dispose();
    _apiClient.dispose();
    super.dispose();
  }

  Future<void> _handleIntentAccept(Map<String, dynamic> intent) async {
    if (intent['action'] == 'reschedule_task') {
      final taskId = intent['taskId'];
      final newStart = intent['newStartTime'] ?? intent['date'];
      final newEnd = intent['newEndTime'];
      try {
        final engine = Provider.of<ActionEngineService>(context, listen: false);
        final success = await engine.executeIntent({
          'action': 'reschedule_task',
          'taskId': taskId,
          'newStartTime': newStart,
          'newEndTime': newEnd,
        });
        if (success) {
          try {
            final agendaProv =
                Provider.of<AgendaProvider>(context, listen: false);
            await agendaProv.loadEvents();
          } catch (e) {}

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text('Action exécutée : reschedule $taskId à $newStart')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Échec lors du replanification de la tâche')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Action exécutée localement : reschedule $taskId')));
      }
    } else if (intent['action'] == 'create_task') {
      final title = intent['title'];
      try {
        final engine = Provider.of<ActionEngineService>(context, listen: false);
        final success = await engine.executeIntent({
          'action': 'create_task',
          'title': title?.toString() ?? 'Nouvelle Tâche IA'
        });
        if (success) {
          // Refresh local providers so UI reflects the persisted change immediately
          try {
            final taskProv = Provider.of<TaskProvider>(context, listen: false);
            await taskProv.loadTasks();
          } catch (e) {}
          // Only the TaskProvider needs refreshing for a created task.

          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Action exécutée : Tâche créée')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Échec lors de la création de la tâche')));
        }
      } catch (e) {
        final taskProvider = context.read<TaskProvider>();
        taskProvider.addTask(Task(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: title?.toString() ?? 'Nouvelle Tâche IA'));
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Action exécutée : Tâche créée')));
      }
    } else if (intent['action'] == 'create_goal') {
      final title = intent['title'];
      try {
        final engine = Provider.of<ActionEngineService>(context, listen: false);
        final success = await engine.executeIntent({
          'action': 'create_goal',
          'title': title?.toString() ?? 'Nouvel Objectif IA'
        });
        if (success) {
          try {
            final goalProv = Provider.of<GoalProvider>(context, listen: false);
            await goalProv.loadGoals();
          } catch (e) {}

          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Action exécutée : Objectif créé')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Échec lors de la création de l\'objectif')));
        }
      } catch (e) {
        final goalProv = context.read<GoalProvider>();
        goalProv.addGoal(Goal(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: title?.toString() ?? 'Nouvel Objectif IA'));
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Action exécutée : Objectif créé')));
      }
    } else if (intent['action'] == 'create_event') {
      // Minimal handling: execute and refresh AgendaProvider
      final title = intent['title'];
      final start = intent['startTime'];
      final end = intent['endTime'];
      try {
        final engine = Provider.of<ActionEngineService>(context, listen: false);
        final success = await engine.executeIntent({
          'action': 'create_event',
          'title': title,
          'startTime': start,
          'endTime': end,
        });
        if (success) {
          try {
            final agendaProv =
                Provider.of<AgendaProvider>(context, listen: false);
            await agendaProv.loadEvents();
          } catch (e) {}

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Action exécutée : Événement créé')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Échec lors de la création de l\'événement')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Action exécutée : Événement créé')));
      }
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _textController.clear();

    try {
      final profileProvider = context.read<ProfileProvider>();
      final taskProvider = context.read<TaskProvider>();

      final profile = profileProvider.profile;

      int totalTasks = taskProvider.tasks.length;
      int completedTasks =
          taskProvider.tasks.where((t) => t.isCompleted).length;

      Map<String, dynamic>? progressContext;
      try {
        final engine = Provider.of<ProgressEngine>(context, listen: false);
        final summary = await engine.compute7DaySummary(DateTime.now());
        final snap = summary.snapshot;
        progressContext = {
          'periodStart': snap.start.toIso8601String(),
          'periodEnd': snap.end.toIso8601String(),
          'totalTasks': snap.totalTasks,
          'completedTasks': snap.completedTasks,
          'completionRate': snap.completionRate,
          'focusMinutes': snap.focusMinutes,
          'focusSessions': snap.focusSessions,
          'activeDays': snap.activeDays,
          'goalsCount': snap.goalsCount,
          'tasksLinkedToGoals': snap.tasksLinkedToGoals,
          'insights': summary.insights
              .map((i) => {
                    'title': i.title,
                    'description': i.description,
                    'trend': i.trend.toString().split('.').last
                  })
              .toList(),
        };
      } catch (e) {
        // If progress context cannot be built, proceed without it.
        debugPrint('Progress context unavailable: $e');
      }

      final response = await _apiClient.getCoachAdvice(
        userMessage: text,
        nexiiState: profile?.mentalBattery ?? 100,
        completedTasksCount: completedTasks,
        totalTasksCount: totalTasks,
        contextMood: 'Neutre',
        userAge: 25,
        provider: 'gemini',
        progressContext: progressContext,
      );

      setState(() {
        _messages.add(ChatMessage(
            text: response.text, isUser: false, intent: response.intent));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
            text: "Erreur de connexion au serveur.", isUser: false));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coach IA')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Column(
                  crossAxisAlignment: msg.isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: msg.isUser
                            ? const Color(0xff6366f1)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                            color: msg.isUser ? Colors.white : Colors.black87),
                      ),
                    ),
                    if (msg.intent != null && !msg.isUser)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _handleIntentAccept(msg.intent!);
                                setState(() {
                                  _messages.removeAt(index);
                                  _messages.insert(
                                      index,
                                      ChatMessage(
                                          text:
                                              msg.text + "\n[Action acceptée]",
                                          isUser: false));
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              child: const Text('Accepter'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _messages.removeAt(index);
                                  _messages.insert(
                                      index,
                                      ChatMessage(
                                          text: msg.text + "\n[Action refusée]",
                                          isUser: false));
                                });
                              },
                              child: const Text('Refuser'),
                            ),
                          ],
                        ),
                      )
                  ],
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                        hintText: 'Posez une question...',
                        border: OutlineInputBorder()),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _sendMessage(_textController.text)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
