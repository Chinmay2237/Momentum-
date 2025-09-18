// lib/core/constants/api_constants.dart
class ApiConstants {
  static const String baseUrl = 'https://reqres.in/api';
  static const String jsonPlaceholderBaseUrl = 'https://jsonplaceholder.typicode.com';
  
  static const String register = '/register';
  static const String login = '/login';
  static const String users = '/users';
  
  static const String todos = '/todos';
}

// lib/core/constants/app_constants.dart
class AppConstants {
  static const String appName = 'Task Management';
  static const String hiveTasksBox = 'tasks_box';
  static const String hiveUsersBox = 'users_box';
  static const String hiveSettingsBox = 'settings_box';
  
  static const List<String> priorities = ['High', 'Medium', 'Low'];
  static const List<String> statuses = ['To-Do', 'In Progress', 'Done'];
  
  static const int syncIntervalMinutes = 15;
}

// lib/core/constants/route_constants.dart
class RouteConstants {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String taskForm = '/task_form';
  static const String taskDetail = '/task_detail';
  static const String profile = '/profile';
  static const String settings = '/settings';
}