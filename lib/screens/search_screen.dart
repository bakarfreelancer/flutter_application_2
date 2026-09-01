import 'package:flutter/material.dart';

// SearchScreen demonstrates a basic ListView with a fixed list of items.
// Use ListView when you have a small, known number of items.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  // A simple fixed list of strings
  static const List<String> _items = [
    'Flutter',
    'Dart',
    'Android',
    'iOS',
    'React Native',
    'Kotlin',
    'Swift',
    'Firebase',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      // Each item in the list is turned into a ListTile manually
      children: _items.map((item) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.search, color: Colors.orangeAccent),
            title: Text(item),
          ),
        );
      }).toList(),
    );
  }
}
