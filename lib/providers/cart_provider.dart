import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/product.dart';
import 'package:flutter_application_2/services/cart_database.dart'; // NEW (Lecture 19)

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
//  Lecture 19: CartProvider now works with TWO layers:
//    1. In-memory list (_items) — fast, drives the UI instantly
//    2. SQLite database (CartDatabase) — persists across app restarts
//
//  Rule: always update the in-memory list first (so the UI
//  responds immediately), then write to the database in the
//  background (so the data survives a restart).
// ─────────────────────────────────────────────────────────────
class CartProvider extends ChangeNotifier {
  // Private in-memory list — the UI reads from this
  final List<CartItem> _items = [];

  // Reference to the database service
  final CartDatabase _db = CartDatabase.instance;

  // Public getter — returns an unmodifiable copy
  List<CartItem> get items => List.unmodifiable(_items);

  // Total number of individual products (used for the cart badge)
  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  // Total price of everything in the cart
  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.product.price * item.quantity);

  // ── Constructor ──────────────────────────────────────────────
  // Lecture 19: When CartProvider is created (on app start),
  // we immediately load any saved cart from the database.
  // This is the same pattern used in ThemeProvider (Lecture 14).
  CartProvider() {
    _loadFromDatabase();
  }

  // ── Load from DB on startup ──────────────────────────────────
  Future<void> _loadFromDatabase() async {
    final savedItems = await _db.getAllItems();
    if (savedItems.isNotEmpty) {
      _items.addAll(savedItems);
      notifyListeners(); // rebuild the UI with the restored cart
    }
  }

  // ── Add a product ────────────────────────────────────────────
  void addProduct(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }

    notifyListeners(); // update the UI immediately

    // Write the updated item to the database in the background.
    // We use the current state of the item, not a snapshot.
    final updatedItem = _items.firstWhere((i) => i.product.id == product.id);
    _db.insertOrUpdate(updatedItem); // no await — fire and forget
  }

  // ── Remove a product completely ──────────────────────────────
  void removeProduct(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
    _db.deleteItem(productId); // remove from database too
  }

  // ── Decrease quantity by 1, remove if it reaches 0 ──────────
  void decreaseQuantity(int productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index < 0) return;

    if (_items[index].quantity > 1) {
      _items[index].quantity--;
      notifyListeners();
      _db.insertOrUpdate(_items[index]); // update the quantity in DB
    } else {
      _items.removeAt(index);
      notifyListeners();
      _db.deleteItem(productId); // quantity hit 0 — remove from DB
    }
  }

  // ── Clear all items (e.g. after checkout) ────────────────────
  void clearCart() {
    _items.clear();
    notifyListeners();
    _db.clearAll(); // wipe the entire table
  }
}
