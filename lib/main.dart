import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/providers/cart_provider.dart';
import 'package:flutter_application_2/screens/splash.dart';

void main() {
  runApp(
    // ChangeNotifierProvider creates ONE CartProvider and makes it
    // available to EVERY widget in the app below it.
    // This is how we share state across screens without passing
    // data manually through constructors.
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        title: 'My App',
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    ),
  );
}
