/// Domain Model representing a Task Item.
class TaskItem {
  final String id;
  final String title;
  final String? subtitle;
  final String category;
  final String priority;
  final bool isCompleted;
  final String? urgency;
  final String? difficulty;
  final int? estimatedTimeMinutes;
  final String? energyNeeded;
  final String? linkedGoalId;
  final List<Map<String, dynamic>> subtasks;

  const TaskItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.category,
    required this.priority,
    this.isCompleted = false,
    this.urgency,
    this.difficulty,
    this.estimatedTimeMinutes,
    this.energyNeeded,
    this.linkedGoalId,
    this.subtasks = const <Map<String, dynamic>>[],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      'category': category,
      'priority': priority,
      'isCompleted': isCompleted,
      'urgency': urgency,
      'difficulty': difficulty,
      'estimatedTime': estimatedTimeMinutes,
      'energyNeeded': energyNeeded,
      'linkedGoalId': linkedGoalId,
      'subtasks': subtasks,
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title']?.toString() ?? '',
      subtitle: map['subtitle']?.toString(),
      category: map['category']?.toString() ?? 'Général',
      priority: map['priority']?.toString() ?? 'Moyenne',
      isCompleted: map['isCompleted'] == true,
      urgency: map['urgency']?.toString(),
      difficulty: map['difficulty']?.toString(),
      estimatedTimeMinutes: map['estimatedTime'] is num ? (map['estimatedTime'] as num).toInt() : null,
      energyNeeded: map['energyNeeded']?.toString(),
      linkedGoalId: map['linkedGoalId']?.toString(),
      subtasks: (map['subtasks'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? <Map<String, dynamic>>[],
    );
  }

  TaskItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? category,
    String? priority,
    bool? isCompleted,
    String? urgency,
    String? difficulty,
    int? estimatedTimeMinutes,
    String? energyNeeded,
    String? linkedGoalId,
    List<Map<String, dynamic>>? subtasks,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      urgency: urgency ?? this.urgency,
      difficulty: difficulty ?? this.difficulty,
      estimatedTimeMinutes: estimatedTimeMinutes ?? this.estimatedTimeMinutes,
      energyNeeded: energyNeeded ?? this.energyNeeded,
      linkedGoalId: linkedGoalId ?? this.linkedGoalId,
      subtasks: subtasks ?? this.subtasks,
    );
  }
}
