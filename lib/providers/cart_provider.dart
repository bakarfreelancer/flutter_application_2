import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/product.dart';

// ─────────────────────────────────────────────────────────────
//  CartItem — one entry in the cart
//  Holds the product + how many the user wants
// ─────────────────────────────────────────────────────────────
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

// ─────────────────────────────────────────────────────────────
//  CartProvider — the "single source of truth" for cart data
//
//  It extends ChangeNotifier.
//  ChangeNotifier is a class that can send a signal ("notify")
//  to all widgets that are listening to it.
//  When we call notifyListeners(), every Consumer widget that
//  depends on this provider will automatically rebuild.
// ─────────────────────────────────────────────────────────────
class CartProvider extends ChangeNotifier {
  // Private list — only CartProvider can modify this directly.
  // Other screens can only READ through the getter below.
  final List<CartItem> _items = [];

  // Public getter — returns an unmodifiable copy so no one
  // can accidentally change the list from outside this class.
  List<CartItem> get items => List.unmodifiable(_items);

  // Total number of individual products (used for the cart badge)
  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  // Total price of everything in the cart
  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.product.price * item.quantity);

  // ── Add a product ────────────────────────────────────────────
  // If the product is already in the cart, just increase its quantity.
  // If it's new, add it as a new CartItem.
  void addProduct(Product product) {
    // indexWhere returns -1 if no match is found
    final index = _items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      // Product already exists → increase quantity
      _items[index].quantity++;
    } else {
      // New product → add to list
      _items.add(CartItem(product: product));
    }

    // Tell all listening widgets to rebuild with the new data
    notifyListeners();
  }

  // ── Remove a product completely ──────────────────────────────
  void removeProduct(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  // ── Decrease quantity by 1, remove if it reaches 0 ──────────
  void decreaseQuantity(int productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  // ── Clear all items (e.g. after checkout) ────────────────────
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
