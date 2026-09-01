import 'package:flutter/foundation.dart';

/// Strongly typed model representing a SubTask in Nexii.
@immutable
class SubTask {
  final String id;
  final String title;
  final bool isCompleted;

  const SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  /// Factory constructor to parse a Map safely.
  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      isCompleted: map['isCompleted'] == true,
    );
  }

  /// Converts this SubTask into a Map compatible with Firestore and AppStateProvider.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  /// Creates a copy of this SubTask with updated fields.
  SubTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubTask &&
        other.id == id &&
        other.title == title &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode => Object.hash(id, title, isCompleted);
}

/// Strongly typed model representing a Task in Nexii.
@immutable
class Task {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final bool isCompleted;
  final String priority;
  final String urgency;
  final String difficulty;
  final int estimatedTime;
  final String? duration;
  final String energyNeeded;
  final String linkedGoalId;
  final bool xpAwarded;
  final List<SubTask> subtasks;

  const Task({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.category = 'Pro',
    this.isCompleted = false,
    this.priority = 'Moyenne',
    this.urgency = 'Moyenne',
    this.difficulty = 'Moyen',
    this.estimatedTime = 30,
    this.duration,
    this.energyNeeded = 'Moyenne',
    this.linkedGoalId = '',
    this.xpAwarded = false,
    this.subtasks = const [],
  });

  /// Factory constructor to parse a Map safely (e.g. from Firestore or JSON).
  factory Task.fromMap(Map<String, dynamic> map) {
    final rawSubtasks = map['subtasks'];
    List<SubTask> parsedSubtasks = const [];
    if (rawSubtasks is List) {
      parsedSubtasks = rawSubtasks
          .map((st) {
            if (st is Map<String, dynamic>) {
              return SubTask.fromMap(st);
            } else if (st is Map) {
              return SubTask.fromMap(Map<String, dynamic>.from(st));
            }
            return null;
          })
          .whereType<SubTask>()
          .toList();
    }

    int parsedEstimatedTime = 30;
    if (map['estimatedTime'] is num) {
      parsedEstimatedTime = (map['estimatedTime'] as num).toInt();
    } else if (map['estimatedTime'] is String) {
      parsedEstimatedTime = int.tryParse(map['estimatedTime'] as String) ?? 30;
    }

    return Task(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      subtitle: map['subtitle']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Pro',
      isCompleted: map['isCompleted'] == true,
      priority: map['priority']?.toString() ?? 'Moyenne',
      urgency: map['urgency']?.toString() ?? 'Moyenne',
      difficulty: map['difficulty']?.toString() ?? 'Moyen',
      estimatedTime: parsedEstimatedTime,
      duration: map['duration']?.toString(),
      energyNeeded: map['energyNeeded']?.toString() ?? 'Moyenne',
      linkedGoalId: map['linkedGoalId']?.toString() ?? '',
      xpAwarded: map['xpAwarded'] == true,
      subtasks: List.unmodifiable(parsedSubtasks),
    );
  }

  /// Converts this Task into a Map preserving exact field names for Firestore & AppStateProvider.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'isCompleted': isCompleted,
      'priority': priority,
      'urgency': urgency,
      'difficulty': difficulty,
      'estimatedTime': estimatedTime,
      'energyNeeded': energyNeeded,
      'linkedGoalId': linkedGoalId,
      'xpAwarded': xpAwarded,
      'subtasks': subtasks.map((st) => st.toMap()).toList(),
    };
    if (duration != null) {
      map['duration'] = duration;
    }
    return map;
  }

  /// Creates a copy of this Task with updated fields.
  Task copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? category,
    bool? isCompleted,
    String? priority,
    String? urgency,
    String? difficulty,
    int? estimatedTime,
    String? duration,
    String? energyNeeded,
    String? linkedGoalId,
    bool? xpAwarded,
    List<SubTask>? subtasks,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      urgency: urgency ?? this.urgency,
      difficulty: difficulty ?? this.difficulty,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      duration: duration ?? this.duration,
      energyNeeded: energyNeeded ?? this.energyNeeded,
      linkedGoalId: linkedGoalId ?? this.linkedGoalId,
      xpAwarded: xpAwarded ?? this.xpAwarded,
      subtasks: subtasks ?? this.subtasks,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.category == category &&
        other.isCompleted == isCompleted &&
        other.priority == priority &&
        other.urgency == urgency &&
        other.difficulty == difficulty &&
        other.estimatedTime == estimatedTime &&
        other.duration == duration &&
        other.energyNeeded == energyNeeded &&
        other.linkedGoalId == linkedGoalId &&
        other.xpAwarded == xpAwarded &&
        listEquals(other.subtasks, subtasks);
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        subtitle,
        category,
        isCompleted,
        priority,
        urgency,
        difficulty,
        estimatedTime,
        duration,
        energyNeeded,
        linkedGoalId,
        xpAwarded,
        Object.hashAll(subtasks),
      );
}
