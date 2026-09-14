import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/providers/cart_provider.dart';

// CartScreen now reads its data from CartProvider instead of
// keeping its own local list. This means any screen that adds
// a product will automatically appear here.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer<CartProvider> listens to CartProvider.
    // Whenever notifyListeners() is called in CartProvider,
    // only this widget rebuilds — not the whole screen tree.
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Column(
          children: [
            // ── Item list ──────────────────────────────────────────
            Expanded(
              child: cart.items.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'Your cart is empty',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Browse products and tap "Add to Cart"',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final cartItem = cart.items[index];
                        return Card(
                          child: ListTile(
                            // Product thumbnail
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                cartItem.product.thumbnail,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              cartItem.product.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '\$${cartItem.product.price.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.orangeAccent),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Decrease quantity button
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    // context.read<>() is used for one-time actions
                                    // (we don't need to listen/rebuild here)
                                    context
                                        .read<CartProvider>()
                                        .decreaseQuantity(cartItem.product.id);
                                  },
                                ),
                                // Current quantity
                                Text(
                                  '${cartItem.quantity}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                // Increase quantity button
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    context
                                        .read<CartProvider>()
                                        .addProduct(cartItem.product);
                                  },
                                ),
                                // Delete button
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () {
                                    context
                                        .read<CartProvider>()
                                        .removeProduct(cartItem.product.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // ── Summary + Clear button ─────────────────────────────
            if (cart.items.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.black12)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${cart.totalItems} item(s)',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          'Total: \$${cart.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          // Clear all cart items
                          context.read<CartProvider>().clearCart();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Order placed! Cart cleared.')),
                          );
                        },
                        child: const Text('Checkout', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
