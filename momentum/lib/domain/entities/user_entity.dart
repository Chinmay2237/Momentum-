
import 'package:equatable/equatable.dart';

// The core entity representing a user. It is immutable and uses Equatable
// to ensure value-based equality, which is crucial for state management.
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
