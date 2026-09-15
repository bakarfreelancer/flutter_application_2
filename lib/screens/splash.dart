import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/providers/auth_provider.dart';
import 'package:flutter_application_2/screens/home.dart';
import 'package:flutter_application_2/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate(); // start navigation logic after splash delay
  }

  // Waits 2 seconds, then checks if the user has a saved auth token.
  // Routes to Login or Home accordingly.
  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Ask AuthProvider to check SharedPreferences for a saved token.
    // If a token exists, AuthProvider sets isLoggedIn = true.
    await context.read<AuthProvider>().checkAuthStatus();

    if (!mounted) return;

    final isLoggedIn = context.read<AuthProvider>().isLoggedIn;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => isLoggedIn
            ? const MyApp()       // token found → go straight to home
            : const LoginScreen(), // no token → ask user to log in
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/logo.jpg', width: 200, height: 200),
      ),
    );
  }
}
