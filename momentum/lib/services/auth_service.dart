
import 'package:momentum/models/user.dart';
import 'package:momentum/services/database_helper.dart';

class AuthService {
  final DatabaseHelper _db = DatabaseHelper();

  Future<User?> signUp(String username, String password) async {
    // Check if username already exists
    final existingUser = await _db.getUserByUsername(username);
    if (existingUser != null) {
      return null; // Username already exists
    }

    final userId = await _db.createUser(username, password);
    return User(id: userId, username: username, password: password);
  }

  Future<User?> login(String username, String password) async {
    final userMap = await _db.getUserByUsername(username);
    if (userMap == null) {
      return null; // User not found
    }

    if (userMap['password'] == password) {
      return User(
        id: userMap['id'],
        username: userMap['username'],
        password: userMap['password'],
      );
    }

    return null; // Incorrect password
  }
}
