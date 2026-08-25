import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/bottom_nav_bar.dart'; // import component
import 'package:flutter_application_2/components/top_header.dart';     // import component
import 'package:flutter_application_2/screens/profile.dart';

// Create Simple My App Widget
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String inputName = '';
  final TextEditingController nameInputController = TextEditingController();

  // Tracks which bottom nav tab is selected
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: Scaffold(
        // ── Use TopHeader component ──
        // We pass 'title' as a parameter — same component, different title per screen
        appBar: TopHeader(title: 'Personal App'),

        body: SingleChildScrollView(
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Profile(personName: inputName),
                        ),
                      );
                    },
                    child: Text("Show Profile"),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Use BottomNavBar component ──
        // We pass the current index and update it with setState when user taps
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
