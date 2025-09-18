// lib/presentation/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/user_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    print('SplashPage initState called');
    
    // Use addPostFrameCallback to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    try {
      print('Checking auth status...');
      await Future.delayed(const Duration(seconds: 2));
      
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      print('UserProvider obtained');
      
      final isLoggedIn = await userProvider.checkAuthStatus();
      print('Auth status result: $isLoggedIn');
      
      if (isLoggedIn) {
        print('Navigating to /home');
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        print('Navigating to /login');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e, stackTrace) {
      print('Error in splash screen: $e');
      print('Stack trace: $stackTrace');
      // Fallback to login screen on error
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('SplashPage build called');
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}