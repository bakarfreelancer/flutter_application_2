import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/providers/cart_provider.dart';
import 'package:flutter_application_2/providers/auth_provider.dart';
import 'package:flutter_application_2/providers/theme_provider.dart'; // NEW (Lecture 14)
import 'package:flutter_application_2/screens/splash.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // NEW (Lecture 14)
      ],
      // Consumer<ThemeProvider> listens to theme changes and rebuilds MaterialApp.
      // This is the ONLY place we need to rebuild — changing themeMode here
      // automatically applies the new theme to every widget in the whole app.
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'My App',
            debugShowCheckedModeBanner: false,

            // ThemeMode decides which theme Flutter uses right now.
            // ThemeProvider.themeMode returns ThemeMode.light or ThemeMode.dark.
            themeMode: themeProvider.themeMode, // NEW

            // Light theme — used when isDark is false
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.orange, // our brand color
              ),
              useMaterial3: true,
            ),

            // Dark theme — used when isDark is true
            // The only difference is brightness: Brightness.dark
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.orange,
                brightness: Brightness.dark, // makes Flutter generate dark colors
              ),
              useMaterial3: true,
            ),

            home: const SplashScreen(),
          );
        },
      ),
    ),
  );
}
