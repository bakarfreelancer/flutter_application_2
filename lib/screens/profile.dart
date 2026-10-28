import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';           // NEW (Lecture 22)
import 'package:shared_preferences/shared_preferences.dart'; // NEW (Lecture 22)
import 'package:flutter_application_2/providers/auth_provider.dart';
import 'package:flutter_application_2/providers/theme_provider.dart';
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

  // Lecture 22: holds the profile image chosen from camera or gallery
  File? _profileImage;

  // The key we use to persist the image path in SharedPreferences
  static const String _imagePathKey = 'profile_image_path';

  @override
  void initState() {
    super.initState();
    _loadUser();          // load name/contact/address
    _loadProfileImage();  // load saved profile photo (Lecture 22)
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

  // ── Lecture 22: Image loading & picking ────────────────────────────────────

  // Load the previously saved image path from SharedPreferences.
  // If a file exists at that path, show it as the profile photo.
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString(_imagePathKey);
    if (savedPath != null && File(savedPath).existsSync()) {
      setState(() => _profileImage = File(savedPath));
    }
  }

  // Open camera or gallery, let the user pick a photo, then save the path.
  Future<void> _pickImage(ImageSource source) async {
    // ImagePicker is the main class from the image_picker package.
    // pickImage() opens the camera or gallery and returns an XFile
    // (XFile = cross-platform file wrapper).
    final XFile? picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,   // compress to 80% quality to save storage
      maxWidth: 512,      // resize to max 512px wide — enough for an avatar
    );

    // User cancelled the picker (tapped back) — do nothing
    if (picked == null) return;

    // Save the file path so it survives app restarts
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_imagePathKey, picked.path);

    // Rebuild the widget to show the new photo immediately
    setState(() => _profileImage = File(picked.path));
  }

  // Show a bottom sheet asking the user where to get the photo from.
  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min, // sheet height = content height
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Change Profile Photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(ctx); // close sheet first
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
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

    // Lecture 14: Get theme info from ThemeProvider
    // isDark tells us the current state so we can set the Switch value
    final themeProvider = context.watch<ThemeProvider>();

    // Lecture 14: Get the primary color from the active theme
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Lecture 22: Avatar with camera icon overlay ──────────────────
          // GestureDetector makes the whole avatar tappable.
          // Stack lets us draw the small camera badge on top of the avatar.
          Center(
            child: GestureDetector(
              onTap: _showImageSourceSheet, // tap → bottom sheet
              child: Stack(
                children: [
                  // The avatar circle — shows picked photo or initials
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: primaryColor,
                    // If the user picked a photo, show it; otherwise show initials
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? Text(
                            name.isNotEmpty
                                ? name[0].toUpperCase()
                                : email.isNotEmpty
                                    ? email[0].toUpperCase()
                                    : '?',
                            style: TextStyle(
                              fontSize: 40,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : null, // hide text when image is showing
                  ),

                  // Small camera badge at the bottom-right of the avatar
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ─────────────────────────────────────────────────────────────────
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

          // ── Lecture 14: Dark Mode Toggle ────────────────────────────────────
          // A simple row with a label on the left and a Switch on the right.
          // When the user flips it, ThemeProvider.toggleTheme() is called,
          // which saves the preference and notifies all listeners to rebuild.
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      themeProvider.isDark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 12),
                    const Text('Dark Mode', style: TextStyle(fontSize: 16)),
                  ],
                ),
                // Switch reads isDark from ThemeProvider and calls toggleTheme() on change
                Switch(
                  value: themeProvider.isDark,
                  onChanged: (_) => context.read<ThemeProvider>().toggleTheme(),
                  activeThumbColor: primaryColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // ────────────────────────────────────────────────────────────────────

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
        Icon(icon, color: Theme.of(context).colorScheme.primary), // was: Colors.orangeAccent
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
