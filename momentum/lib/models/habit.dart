
import 'package:flutter/foundation.dart';

class Habit {
  final String id;
  final String name;
  final String description;
  final String plantType;
  final int goal;
  final int progress;
  final DateTime createdAt;

  Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.plantType,
    required this.goal,
    required this.progress,
    required this.createdAt,
  });
}
