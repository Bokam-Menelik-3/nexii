import 'package:flutter/foundation.dart';

@immutable
class UserProfile {
  final String uid;
  final String name;
  final DateTime? birthdate;
  final int xp;
  final int level;
  final int streak;
  final int mentalBattery;
  final List<String> primaryGoals;
  final Map<String, dynamic> preferences;
  final Map<String, dynamic> constraints;

  const UserProfile({
    required this.uid,
    this.name = '',
    this.birthdate,
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
    this.mentalBattery = 100,
    this.primaryGoals = const [],
    this.preferences = const {},
    this.constraints = const {},
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      name: map['name']?.toString() ?? '',
      birthdate: map['birthdate'] != null
          ? DateTime.tryParse(map['birthdate'].toString())
          : null,
      xp: (map['xp'] as num?)?.toInt() ?? 0,
      level: (map['level'] as num?)?.toInt() ?? 1,
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      mentalBattery: (map['mentalBattery'] as num?)?.toInt() ?? 100,
      primaryGoals: List<String>.from(map['primaryGoals'] ?? []),
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      constraints: Map<String, dynamic>.from(map['constraints'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'birthdate': birthdate?.toIso8601String(),
      'xp': xp,
      'level': level,
      'streak': streak,
      'mentalBattery': mentalBattery,
      'primaryGoals': primaryGoals,
      'preferences': preferences,
      'constraints': constraints,
    };
  }

  UserProfile copyWith({
    String? uid,
    String? name,
    DateTime? birthdate,
    int? xp,
    int? level,
    int? streak,
    int? mentalBattery,
    List<String>? primaryGoals,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? constraints,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      birthdate: birthdate ?? this.birthdate,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      mentalBattery: mentalBattery ?? this.mentalBattery,
      primaryGoals: primaryGoals ?? this.primaryGoals,
      preferences: preferences ?? this.preferences,
      constraints: constraints ?? this.constraints,
    );
  }
}
