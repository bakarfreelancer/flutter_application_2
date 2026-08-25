import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/bottom_nav_bar.dart'; // import component
import 'package:flutter_application_2/components/top_header.dart';     // import component

// Create Simple My App Widget
class Profile extends StatefulWidget {
  const Profile({super.key, required this.personName});

  final String personName;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // Tracks which bottom nav tab is selected
  int _currentIndex = 3; // Start on Profile tab (index 3)

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: Scaffold(
        // ── Same TopHeader component, different title ──
        appBar: TopHeader(title: 'My Profile'),

        body: SingleChildScrollView(
          child: Column(
            children: [
              Text('Welcome ${widget.personName}.'),
            ],
          ),
        ),

        // ── Same BottomNavBar component ──
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
