
import 'package:flutter/material.dart';
import 'package:momentum/app/screens/home_screen.dart';
import 'package:momentum/app/theme/theme.dart';

void main() {
  runApp(const AuraApp());
}

class AuraApp extends StatelessWidget {
  const AuraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura - Habit Garden',
      theme: appTheme,
      home: const HomeScreen(),
    );
  }
}
