import 'package:flutter/material.dart';
import 'package:momentum/screens/login_screen.dart';
import 'package:momentum/theme/theme.dart';

void main() {
  runApp(const MomentumApp());
}

class MomentumApp extends StatelessWidget {
  const MomentumApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momentum',
      theme: appTheme,
      home: const LoginScreen(),
    );
  }
}
