import 'package:flutter/material.dart';

// Create Simple My App Widget
class Profile extends StatefulWidget {
  const Profile({super.key, required this.personName});

  final String personName;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String inputName = '';
  final TextEditingController nameInputController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: Scaffold(
        appBar: AppBar(
          title: Text("Personal App"),
          backgroundColor: Colors.orangeAccent,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Column(children: [Text('Welcome ${widget.personName}.')]),
        ),
        bottomNavigationBar: Text("Bottom Navigation"),
      ),
    );
  }
}
