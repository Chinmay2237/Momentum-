// lib/presentation/routes/app_routes.dart (updated)
import 'package:flutter/material.dart';

import '../../data/models/task_model.dart';
import '../pages/fallback_home.dart';
import '../pages/home_screen.dart';
import '../pages/login_page.dart';
import '../pages/splash_screen.dart';
import '../widget/task_form.dart';

// lib/presentation/routes/app_routes.dart (updated with more debug prints)
class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    print('🔀 Generating route for: ${settings.name}');
    
    switch (settings.name) {
      case '/':
        print('➡️ Navigating to SplashPage');
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case '/login':
        print('➡️ Navigating to LoginPage');
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/home':
        print('➡️ Navigating to HomePage');
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/task_form':
        final task = settings.arguments is TaskModel 
            ? settings.arguments as TaskModel 
            : null;
        print('➡️ Navigating to TaskForm with task: ${task?.id}');
        return MaterialPageRoute(
          builder: (_) => TaskForm(task: task),
        );
      default:
        print('❌ Unknown route: ${settings.name}');
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}