/// Domain Model representing a Focus Session.
class FocusSession {
  final String id;
  final int minutes;
  final String mode;
  final String sound;
  final DateTime timestamp;

  const FocusSession({
    required this.id,
    required this.minutes,
    required this.mode,
    required this.sound,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'minutes': minutes,
      'mode': mode,
      'sound': sound,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory FocusSession.fromMap(Map<String, dynamic> map) {
    return FocusSession(
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      minutes: map['minutes'] is num ? (map['minutes'] as num).toInt() : 0,
      mode: map['mode']?.toString() ?? 'Pomodoro',
      sound: map['sound']?.toString() ?? 'Pluie',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
