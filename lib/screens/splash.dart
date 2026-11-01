import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/home.dart';

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

  // Waits 2 seconds then navigates to Home.
  // Firebase Auth restores the previous session automatically via
  // authStateChanges — no manual token check needed (Lecture 23).
  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MyApp()),
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
