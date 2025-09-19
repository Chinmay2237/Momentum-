
import 'package:equatable/equatable.dart';

// The core entity representing a task. It is immutable and uses Equatable
// to ensure value-based equality, which is crucial for state management.
class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority;
  final String status;
  final int assignedUserId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isSynced; // Indicates if the task is synced with the server
  final DateTime? reminderDate; // For local notifications

  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.assignedUserId,
    required this.createdAt,
    this.updatedAt,
    this.isSynced = false, // Default to not synced
    this.reminderDate,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        dueDate,
        priority,
        status,
        assignedUserId,
        createdAt,
        updatedAt,
        isSynced,
        reminderDate,
      ];

  // A helper method to create a copy of the entity with updated fields.
  // This is useful for maintaining immutability while updating state.
  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    String? status,
    int? assignedUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    DateTime? reminderDate,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      reminderDate: reminderDate ?? this.reminderDate,
    );
  }
}
