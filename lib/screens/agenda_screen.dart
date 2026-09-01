import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/agenda_provider.dart';
import '../providers/task_provider.dart';
import '../models/agenda_event_model.dart';
import 'package:intl/intl.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgendaProvider>().loadEvents();
    });
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    String? selectedTaskId;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setState) {
          final tasks = context.read<TaskProvider>().tasks;

          return AlertDialog(
            title: const Text('Planifier un événement'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration:
                      const InputDecoration(labelText: 'Titre de l\'événement'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) setState(() => selectedDate = date);
                        },
                        child:
                            Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (time != null) setState(() => selectedTime = time);
                        },
                        child: Text(selectedTime.format(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  initialValue: selectedTaskId,
                  decoration: const InputDecoration(
                      labelText: 'Lier à une tâche (Optionnel)'),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('Aucune tâche')),
                    ...tasks.map((t) => DropdownMenuItem(
                          value: t.id,
                          child: Text(t.title),
                        )),
                  ],
                  onChanged: (val) {
                    setState(() {
                      selectedTaskId = val;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Annuler')),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.trim().isNotEmpty) {
                    final start = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );
                    final newEvent = AgendaEvent(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text.trim(),
                      startTime: start,
                      endTime: start.add(const Duration(hours: 1)),
                      linkedTaskId: selectedTaskId,
                    );
                    context.read<AgendaProvider>().addEvent(newEvent);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Planifier'),
              ),
            ],
          );
        });
      },
    );
  }

  void _confirmDeleteEvent(AgendaEvent event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: Text('Voulez-vous vraiment annuler "${event.title}" ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Non')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<AgendaProvider>().deleteEvent(event.id);
              Navigator.pop(ctx);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final agendaProvider = context.watch<AgendaProvider>();
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        actions: [
          IconButton(
              icon: const Icon(Icons.add), onPressed: _showAddEventDialog),
        ],
      ),
      body: agendaProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (agendaProvider.events.isEmpty)
                  const Center(
                      child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('Aucun événement planifié.',
                        style: TextStyle(color: Colors.grey)),
                  )),
                ...agendaProvider.events.map((event) {
                  final linkedTask = event.linkedTaskId != null
                      ? taskProvider.tasks
                          .where((t) => t.id == event.linkedTaskId)
                          .firstOrNull
                      : null;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      title: Text(event.title,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${DateFormat('dd MMM HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}'),
                          if (linkedTask != null)
                            Text('Tâche: ${linkedTask.title}',
                                style: const TextStyle(
                                    color: Colors.blue,
                                    fontStyle: FontStyle.italic)),
                        ],
                      ),
                      leading: const Icon(Icons.event, color: Colors.blue),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red, size: 20),
                        onPressed: () => _confirmDeleteEvent(event),
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
