
import 'package:equatable/equatable.dart';

// The core entity for a user.
class UserEntity extends Equatable {
  final int id;
  final String fullName;
  final String email;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
  });

  @override
  List<Object?> get props => [id, fullName, email];
}
