import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  late SharedPreferences _prefs;

  AuthService(this._apiService) {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> register(String email, String password) async {
    final response = await _apiService.register(email, password);
    // Assuming the API returns a token
    final token = response['token'];
    await _prefs.setString('token', token);
  }

  Future<void> login(String email, String password) async {
    final response = await _apiService.login(email, password);
    // Assuming the API returns a token
    final token = response['token'];
    await _prefs.setString('token', token);
  }

  Future<void> logout() async {
    await _prefs.remove('token');
  }

  Future<bool> isLoggedIn() async {
    final token = _prefs.getString('token');
    return token != null;
  }
}
