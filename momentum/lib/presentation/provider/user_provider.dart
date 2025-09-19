// lib/presentation/provider/user_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management/domain/repositories/user_repository.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/entities/user_entity.dart';

class UserProvider with ChangeNotifier {
  final UserRepository userRepository;
  final SharedPreferences sharedPreferences;

  UserProvider({
    required this.userRepository,
    required this.sharedPreferences,
  });

  bool _isLoading = false;
  String? _error;
  String? _token;
  List<UserEntity> _users = []; // Add users list

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _token;
  List<UserEntity> get users => _users; // Add users getter

// lib/presentation/provider/user_provider.dart
Future<bool> checkAuthStatus() async {
  try {
    print('🔐 Checking token in SharedPreferences');
    final token = sharedPreferences.getString('token');
    print('📋 Token value: $token');
    final isLoggedIn = token != null && token.isNotEmpty;
    print('🔑 Is logged in: $isLoggedIn');
    return isLoggedIn;
  } catch (e) {
    print('❌ Error checking auth status: $e');
    return false;
  }
}

  // Load users
  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await userRepository.getUsers();
      result.fold(
        (failure) {
          _error = failure.message;
          _isLoading = false;
          notifyListeners();
        },
        (users) {
          _users = users; // Store the loaded users
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Register user
  Future<void> register(String email, String password,) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await userRepository.register(email, password);
      result.fold(
        (failure) {
          _error = failure.message;
          _isLoading = false;
          notifyListeners();
        },
        (token) {
          _token = token as String?;
          sharedPreferences.setString('token', token as String);
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Login user
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await userRepository.login(email, password);
      result.fold(
        (failure) {
          _error = failure.message;
          _isLoading = false;
          notifyListeners();
        },
        (token) {
          _token = token as String?;
          sharedPreferences.setString('token', token as String);
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Logout user
  Future<void> logout() async {
    await sharedPreferences.remove('token');
    _token = null;
    _users = []; // Clear users on logout
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
