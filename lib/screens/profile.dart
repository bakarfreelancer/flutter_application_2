import 'package:flutter/material.dart';
import 'package:flutter_application_2/services/user_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '';
  String contact = '';
  String address = '';

  @override
  void initState() {
    super.initState();
    _loadUser(); // load user data when the screen is first created
  }

  // Reads user data from local storage and updates the UI
  Future<void> _loadUser() async {
    final data = await UserStorage.getUser();
    setState(() {
      name = data['name']!;
      contact = data['contact']!;
      address = data['address']!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Colors.orangeAccent,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Name
          _infoTile(icon: Icons.person, label: 'Name', value: name),
          const SizedBox(height: 16),

          // Contact
          _infoTile(icon: Icons.phone, label: 'Contact', value: contact),
          const SizedBox(height: 16),

          // Address
          _infoTile(icon: Icons.location_on, label: 'Address', value: address),
        ],
      ),
    );
  }

  // A simple reusable row for displaying one piece of info
  Widget _infoTile({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.orangeAccent),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
