import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/bottom_nav_bar.dart';
import 'package:flutter_application_2/components/top_header.dart';
import 'package:flutter_application_2/screens/cart_screen.dart';
import 'package:flutter_application_2/screens/profile.dart';
import 'package:flutter_application_2/screens/search_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Tracks the currently selected tab
  int _currentIndex = 0;

  // One title per tab — index matches the BottomNavBar items
  final List<String> _titles = ['Home', 'Search', 'Cart', 'Profile'];

  // One screen per tab — IndexedStack keeps all of them alive
  final List<Widget> _screens = [
    const _HomeContent(),
    const SearchScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // Title changes automatically based on the active tab
        appBar: TopHeader(title: _titles[_currentIndex]),

        // IndexedStack shows only the active screen
        // but keeps all screens in memory (no rebuild on tab switch)
        body: IndexedStack(index: _currentIndex, children: _screens),

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

// ── Home tab content ──────────────────────────────────────────────────────────
// Kept as a private widget inside this file since it belongs to the Home tab.
class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  String inputName = '';
  final TextEditingController nameInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Image.asset('assets/images/logo.jpg', width: 200, height: 200),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Enter Your Name:",
              style: TextStyle(
                fontSize: 20,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(controller: nameInputController),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    inputName = nameInputController.text;
                  });
                },
                child: Text("Submit"),
              ),
            ),
          ),
          Text('Welcome $inputName.'),
        ],
      ),
    );
  }
}
