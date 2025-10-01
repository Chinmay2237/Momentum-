
import 'package:flutter/material.dart';

class Routine {
  final int id;
  final String title;
  final TimeOfDay time;
  bool isCompleted;
  DateTime? completedAt;

  Routine({
    required this.id,
    required this.title,
    required this.time,
    this.isCompleted = false,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'hour': time.hour,
      'minute': time.minute,
      'isCompleted': isCompleted ? 1 : 0,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  static Routine fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'],
      title: map['title'],
      time: TimeOfDay(hour: map['hour'], minute: map['minute']),
      isCompleted: map['isCompleted'] == 1,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
    );
  }
}
