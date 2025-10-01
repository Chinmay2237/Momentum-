
import 'package:flutter/material.dart';
import 'package:task_management/domain/entities/user_entity.dart';
import 'package:task_management/domain/repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository userRepository;

  UserProvider({required this.userRepository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserEntity? _user;
  UserEntity? get user => _user;

  String? _error;
  String? get error => _error;

  void setLoading(bool loading) {
    _isLoading = loading;
    _error = null;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    setLoading(true);
    final result = await userRepository.login(email, password);
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (user) {
        _user = user;
      },
    );
    setLoading(false);
  }

  Future<void> register(String email, String password) async {
    setLoading(true);
    final result = await userRepository.register(email, password);
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (user) {
        _user = user;
      },
    );
    setLoading(false);
  }

  Future<void> getCurrentUser() async {
    setLoading(true);
    final result = await userRepository.getCurrentUser();
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (user) {
        _user = user;
      },
    );
    setLoading(false);
  }
}
