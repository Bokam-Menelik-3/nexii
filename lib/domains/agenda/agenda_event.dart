/// Model representing an event entry in the well-being and productivity agenda.
class AgendaEvent {
  final String id;
  final String title;
  final String time;
  final bool isCompleted;

  const AgendaEvent({
    required this.id,
    required this.title,
    required this.time,
    this.isCompleted = false,
  });

  /// Convert to Map for backward compatibility and serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'isCompleted': isCompleted,
    };
  }

  /// Factory constructor from Map representation
  factory AgendaEvent.fromMap(Map<String, dynamic> map) {
    return AgendaEvent(
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title']?.toString() ?? '',
      time: map['time']?.toString() ?? '',
      isCompleted: map['isCompleted'] == true,
    );
  }

  AgendaEvent copyWith({
    String? id,
    String? title,
    String? time,
    bool? isCompleted,
  }) {
    return AgendaEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
