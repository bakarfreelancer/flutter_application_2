import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/providers/cart_provider.dart';
import 'package:flutter_application_2/providers/auth_provider.dart'; // NEW (Lecture 13)
import 'package:flutter_application_2/screens/splash.dart';

void main() {
  runApp(
    // MultiProvider lets us register MORE THAN ONE provider.
    // Before Lecture 13 we only had CartProvider.
    // Now we also have AuthProvider for authentication state.
    MultiProvider(
      providers: [
        // Cart state — available to all screens
        ChangeNotifierProvider(create: (_) => CartProvider()),
        // Auth state — tracks login/logout status
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'My App',
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    ),
  );
}
