// lib/presentation/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management/presentation/provider/user_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    print('🎯 SplashPage initState called');
    
    // Add a small delay to ensure context is available
    Future.delayed(const Duration(milliseconds: 100), () {
      print('🎯 Starting auth check after delay');
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    try {
      print('🔍 Step 1: Starting auth status check');
      
      // Test if Provider is working
      print('🔍 Step 2: Getting UserProvider');
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      print('✅ UserProvider obtained successfully');
      
      print('🔍 Step 3: Checking auth status');
      final isLoggedIn = await userProvider.checkAuthStatus();
      print('🔐 Auth status result: $isLoggedIn');
      
      print('🔍 Step 4: Preparing to navigate');
      await Future.delayed(const Duration(seconds: 1));
      
      if (isLoggedIn) {
        print('🏠 Navigating to /home');
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        print('🔓 Navigating to /login');
        Navigator.pushReplacementNamed(context, '/login');
      }
      print('✅ Navigation command sent');
      
    } catch (e, stackTrace) {
      print('❌ ERROR in splash screen: $e');
      print('📋 Stack trace: $stackTrace');
      
      // Fallback - try direct navigation
      print('🔄 Fallback: Trying direct navigation to login');
      try {
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e2) {
        print('❌ Fallback navigation also failed: $e2');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 SplashPage build called');
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              'Loading Task Management...',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Build: ${DateTime.now().toIso8601String()}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}