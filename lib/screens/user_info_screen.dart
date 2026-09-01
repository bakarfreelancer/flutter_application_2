import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/home.dart';
import 'package:flutter_application_2/services/user_storage.dart';

// Shown only on the first app launch.
// Collects name, contact, and address, then saves them to local storage.
class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Called when the user taps Save
  Future<void> _saveAndContinue() async {
    // Basic check — make sure all fields are filled
    if (_nameController.text.isEmpty ||
        _contactController.text.isEmpty ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Save data to local storage
    await UserStorage.saveUser(
      name: _nameController.text,
      contact: _contactController.text,
      address: _addressController.text,
    );

    if (!mounted) return;

    // Go to the main app — replace so user cannot go back to this screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MyApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tell us about yourself',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'This information will be saved on your device.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Name field
            const Text(
              'Full Name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'e.g. Ali Hassan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Contact field
            const Text(
              'Contact Number',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _contactController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'e.g. 0300-1234567',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Address field
            const Text(
              'Address',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. Street 5, Lahore',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _saveAndContinue,
                child: const Text(
                  'Save & Continue',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
