import 'package:flutter/material.dart';
import 'package:momentum/screens/canvas_screen.dart';
import 'package:momentum/screens/daily_routine_screen.dart';
import 'package:momentum/screens/home_screen.dart';
import 'package:momentum/screens/login_screen.dart';
import 'package:momentum/screens/reminders_screen.dart';
import 'package:momentum/services/notification_service.dart';
import 'package:momentum/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const MomentumApp());
}

class MomentumApp extends StatelessWidget {
  const MomentumApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momentum',
      theme: appTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/canvas': (context) => const CanvasScreen(),
        '/daily_routine': (context) => const DailyRoutineScreen(),
        '/reminders': (context) => const RemindersScreen(),
      },
    );
  }
}
