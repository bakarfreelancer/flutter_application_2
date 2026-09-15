import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/providers/auth_provider.dart';
import 'package:flutter_application_2/services/user_storage.dart';
import 'package:flutter_application_2/screens/login_screen.dart';

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
    _loadUser(); // load profile info when the screen opens
  }

  // Reads name/contact/address from local storage
  Future<void> _loadUser() async {
    final data = await UserStorage.getUser();
    setState(() {
      name = data['name']!;
      contact = data['contact']!;
      address = data['address']!;
    });
  }

  // Called when the user taps Logout
  Future<void> _logout() async {
    // Show a confirmation dialog before logging out
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), // Confirm
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    // If user cancelled, do nothing
    if (confirmed != true) return;
    if (!mounted) return;

    // Call AuthProvider.logout() — clears token from SharedPreferences
    await context.read<AuthProvider>().logout();

    if (!mounted) return;

    // Navigate to LoginScreen and remove all previous routes
    // (so the user can't press Back to return to home)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the logged-in user's email from AuthProvider
    final email = context.watch<AuthProvider>().email;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar — uses first letter of name or email
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Colors.orangeAccent,
              child: Text(
                name.isNotEmpty
                    ? name[0].toUpperCase()
                    : email.isNotEmpty
                        ? email[0].toUpperCase()
                        : '?',
                style: const TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Email (from auth)
          _infoTile(icon: Icons.email_outlined, label: 'Email', value: email),
          const SizedBox(height: 16),

          // Name (from local storage — may be empty)
          if (name.isNotEmpty) ...[
            _infoTile(icon: Icons.person, label: 'Name', value: name),
            const SizedBox(height: 16),
          ],

          // Contact
          if (contact.isNotEmpty) ...[
            _infoTile(icon: Icons.phone, label: 'Contact', value: contact),
            const SizedBox(height: 16),
          ],

          // Address
          if (address.isNotEmpty) ...[
            _infoTile(icon: Icons.location_on, label: 'Address', value: address),
            const SizedBox(height: 16),
          ],

          const Spacer(),

          // Logout Button at the bottom
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // A reusable row for displaying one piece of profile info
  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.orangeAccent),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
