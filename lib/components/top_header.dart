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
    // Lecture 14: Theme.of(context) reads colors from the active theme.
    // .colorScheme.primary       → the main brand color (orange)
    // .colorScheme.onPrimary     → the color that looks good ON TOP of primary (white)
    // When dark mode is on, Flutter automatically adjusts these colors.
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    return Container(
      color: primaryColor, // was: Colors.orangeAccent
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Menu icon
            IconButton(
              icon: Icon(Icons.menu, color: onPrimaryColor), // was: Colors.white
              onPressed: () {},
            ),

            // Center: Title text — comes from the 'title' parameter
            Text(
              title,
              style: TextStyle(
                color: onPrimaryColor, // was: Colors.white
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Right: Notification icon
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: onPrimaryColor), // was: Colors.white
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
