import 'package:flutter/foundation.dart';

@immutable
class AgendaEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String? linkedTaskId;
  final String? linkedGoalId;

  const AgendaEvent({
    required this.id,
    required this.title,
    this.description = '',
    required this.startTime,
    required this.endTime,
    this.linkedTaskId,
    this.linkedGoalId,
  });

  factory AgendaEvent.fromMap(Map<String, dynamic> map) {
    return AgendaEvent(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      startTime: DateTime.parse(map['startTime'].toString()),
      endTime: DateTime.parse(map['endTime'].toString()),
      linkedTaskId: map['linkedTaskId']?.toString(),
      linkedGoalId: map['linkedGoalId']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'linkedTaskId': linkedTaskId,
      'linkedGoalId': linkedGoalId,
    };
  }

  AgendaEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? linkedTaskId,
    String? linkedGoalId,
  }) {
    return AgendaEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      linkedTaskId: linkedTaskId ?? this.linkedTaskId,
      linkedGoalId: linkedGoalId ?? this.linkedGoalId,
    );
  }
}
