// lib/data/models/task_model.dart
import 'package:hive/hive.dart';
import 'package:task_management/domain/entities/task_entity.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final DateTime dueDate;
  
  @HiveField(4)
  final String priority;
  
  @HiveField(5)
  final String status;
  
  @HiveField(6)
  final int assignedUserId;
  
  @HiveField(7)
  final bool isSynced;
  
  @HiveField(8)
  final DateTime? reminderDate;
  
  @HiveField(9)
  final DateTime createdAt;
  
  @HiveField(10)
  final DateTime? updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.assignedUserId,
    this.isSynced = true,
    this.reminderDate,
    required this.createdAt,
    this.updatedAt,
  });

  // Add toEntity method
  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      status: status,
      assignedUserId: assignedUserId,
      isSynced: isSynced,
      reminderDate: reminderDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Add fromEntity factory method
  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      dueDate: entity.dueDate,
      priority: entity.priority,
      status: entity.status,
      assignedUserId: entity.assignedUserId,
      isSynced: entity.isSynced,
      reminderDate: entity.reminderDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'].toString(),
      title: json['title'],
      description: json['description'] ?? '',
      dueDate: DateTime.parse(json['dueDate']),
      priority: json['priority'] ?? 'Medium',
      status: json['status'] ?? 'To-Do',
      assignedUserId: json['assignedUserId'] ?? 1,
      isSynced: json['isSynced'] ?? true,
      reminderDate: json['reminderDate'] != null 
          ? DateTime.parse(json['reminderDate']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
      'status': status,
      'assignedUserId': assignedUserId,
      'isSynced': isSynced,
      'reminderDate': reminderDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    String? status,
    int? assignedUserId,
    bool? isSynced,
    DateTime? reminderDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      isSynced: isSynced ?? this.isSynced,
      reminderDate: reminderDate ?? this.reminderDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}