import 'package:flutter/foundation.dart';

@immutable
class Goal {
  final String id;
  final String title;
  final String category;
  final double progress;
  final String priority;
  final DateTime? deadline;
  final String status;

  const Goal({
    required this.id,
    required this.title,
    this.category = 'Personnel',
    this.progress = 0.0,
    this.priority = 'Moyenne',
    this.deadline,
    this.status = 'active',
  });

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Personnel',
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      priority: map['priority']?.toString() ?? 'Moyenne',
      deadline: map['deadline'] != null
          ? DateTime.tryParse(map['deadline'].toString())
          : null,
      status: map['status']?.toString() ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'progress': progress,
      'priority': priority,
      'deadline': deadline?.toIso8601String(),
      'status': status,
    };
  }

  Goal copyWith({
    String? id,
    String? title,
    String? category,
    double? progress,
    String? priority,
    DateTime? deadline,
    String? status,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      progress: progress ?? this.progress,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
    );
  }
}
