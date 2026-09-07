import 'package:flutter/material.dart';

// A simple data model for a cart item
class CartItem {
  final String name;
  final double price;

  CartItem({required this.name, required this.price});
}

// CartScreen demonstrates ListView.builder with a dynamic list.
// Items can be added and removed — the list rebuilds automatically via setState.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // The list of items currently in the cart
  final List<CartItem> _cartItems = [
    CartItem(name: 'Flutter Book', price: 1200),
    CartItem(name: 'Wireless Mouse', price: 850),
    CartItem(name: 'USB-C Cable', price: 350),
  ];

  // Sample items to add — cycles through this list on button press
  final List<CartItem> _sampleItems = [
    CartItem(name: 'Mechanical Keyboard', price: 3500),
    CartItem(name: 'Monitor Stand', price: 1800),
    CartItem(name: 'Webcam', price: 2200),
    CartItem(name: 'Laptop Bag', price: 1500),
  ];
  int _nextSample = 0;

  // Adds the next sample item to the cart
  void _addItem() {
    setState(() {
      _cartItems.add(_sampleItems[_nextSample % _sampleItems.length]);
      _nextSample++;
    });
  }

  // Removes an item at a given index
  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  // Calculates the total price of all items
  double get _total => _cartItems.fold(0, (sum, item) => sum + item.price);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Item list ──────────────────────────────────────────────────
        Expanded(
          child: _cartItems.isEmpty
              ? const Center(child: Text('Your cart is empty'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  // itemCount tells Flutter how many items to build
                  itemCount: _cartItems.length,
                  // itemBuilder is called once per item — index goes 0, 1, 2 ...
                  itemBuilder: (context, index) {
                    final item = _cartItems[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orangeAccent,
                          // Show the item number (index + 1)
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(item.name),
                        subtitle: Text('Rs. ${item.price.toStringAsFixed(0)}'),
                        // Delete button on the right
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _removeItem(index),
                        ),
                      ),
                    );
                  },
                ),
        ),

        // ── Total + Add button ─────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.black12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: Rs. ${_total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
                onPressed: _addItem,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
