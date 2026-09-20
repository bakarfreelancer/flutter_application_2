import 'package:flutter/material.dart';

// BottomNavBar is a reusable component for the bottom navigation.
// 'currentIndex' — which tab is active right now
// 'onTap'        — what to do when user taps a tab (decided by the parent screen)
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,

      // Lecture 14: Use theme color instead of hardcoded orange.
      // In light mode → deep orange. In dark mode → lighter orange.
      selectedItemColor: Theme.of(context).colorScheme.primary, // was: Colors.orangeAccent
      unselectedItemColor: Colors.grey,
      // backgroundColor is removed — Material3 handles it automatically,
      // giving a dark background in dark mode and white in light mode.

      // 'fixed' means labels always visible (not hidden when inactive)
      type: BottomNavigationBarType.fixed,

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          activeIcon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          activeIcon: Icon(Icons.shopping_cart),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
