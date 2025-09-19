// lib/data/models/user_model.dart
import 'package:hive/hive.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String email;
  
  @HiveField(2)
  final String fullName;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
  });

  // Add toEntity method
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      fullName: fullName,
    );
  }

  // Add fromEntity factory method
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      fullName: entity.fullName,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'] ?? json['fullName'] ?? '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
    };
  }
}