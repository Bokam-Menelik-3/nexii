import 'package:flutter/foundation.dart';

@immutable
class FocusSession {
  final String id;
  final String userId;
  final String? linkedTaskId;
  final DateTime startedAt;
  final DateTime endedAt;
  final int duration;
  final bool completed;
  final String mode;

  const FocusSession({
    required this.id,
    required this.userId,
    this.linkedTaskId,
    required this.startedAt,
    required this.endedAt,
    required this.duration,
    this.completed = true,
    this.mode = 'Productive',
  });

  factory FocusSession.fromMap(Map<String, dynamic> map) {
    return FocusSession(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      linkedTaskId: map['linkedTaskId']?.toString(),
      startedAt: map['startedAt'] != null
          ? DateTime.parse(map['startedAt'].toString())
          : DateTime.now(),
      endedAt: map['endedAt'] != null
          ? DateTime.parse(map['endedAt'].toString())
          : DateTime.now(),
      duration: (map['duration'] as num?)?.toInt() ?? 0,
      completed: map['completed'] == true,
      mode: map['mode']?.toString() ?? 'Productive',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'linkedTaskId': linkedTaskId,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt.toIso8601String(),
      'duration': duration,
      'completed': completed,
      'mode': mode,
    };
  }
}
