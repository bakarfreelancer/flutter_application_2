import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/home.dart';
import 'package:flutter_application_2/screens/user_info_screen.dart';
import 'package:flutter_application_2/services/user_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate(); // start the navigation logic after splash
  }

  // Waits 2 seconds, then checks if user data exists in local storage.
  // Navigates to the correct screen based on the result.
  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final userExists = await UserStorage.hasUser();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => userExists
            ? const MyApp() // data found → go to home
            : const UserInfoScreen(), // no data → ask for info
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: Scaffold(
        body: Center(
          child: Image.asset('assets/images/logo.jpg', width: 200, height: 200),
        ),
      ),
    );
  }
}
