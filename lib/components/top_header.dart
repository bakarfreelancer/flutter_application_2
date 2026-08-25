import 'package:flutter/material.dart';

// TopHeader is a reusable component (widget) we create once and use in any screen.
// We pass a 'title' parameter so the same component can show different titles.
class TopHeader extends StatelessWidget implements PreferredSizeWidget {
  // 'title' is a parameter — whoever uses this widget must provide it
  final String title;

  const TopHeader({super.key, required this.title});

  // PreferredSizeWidget requires this so Scaffold knows the AppBar height
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orangeAccent, // Same color used throughout the app
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Menu icon
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {},
            ),

            // Center: Title text — comes from the 'title' parameter
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Right: Notification icon
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
