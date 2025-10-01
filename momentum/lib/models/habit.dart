
import 'package:flutter/foundation.dart';

class Habit {
  final String id;
  final String name;
  final String description;
  final String plantType;
  final int goal;
  final int progress;
  final DateTime createdAt;
  String? notes;

  Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.plantType,
    required this.goal,
    required this.progress,
    required this.createdAt,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'plantType': plantType,
      'goal': goal,
      'progress': progress,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      plantType: map['plantType'],
      goal: map['goal'],
      progress: map['progress'],
      createdAt: DateTime.parse(map['createdAt']),
      notes: map['notes'],
    );
  }
}
