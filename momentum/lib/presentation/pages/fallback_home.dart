// lib/presentation/pages/fallback_home.dart
import 'package:flutter/material.dart';

class FallbackHomePage extends StatelessWidget {
  const FallbackHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Management'),
      ),
      body: const Center(
        child: Text('App is working!'),
      ),
    );
  }
}