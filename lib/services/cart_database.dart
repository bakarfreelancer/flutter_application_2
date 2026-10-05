import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_application_2/models/product.dart';
import 'package:flutter_application_2/providers/cart_provider.dart';

// CartDatabase is responsible for ONE thing: saving and loading cart items
// from a local SQLite database file on the device.
//
// It is a service class — it has no UI and knows nothing about providers or
// widgets. CartProvider will call these methods to read/write data.
class CartDatabase {
  // ── Singleton pattern ────────────────────────────────────────────────────
  // We only ever want ONE database connection open at a time.
  // The singleton pattern ensures that no matter how many times we call
  // CartDatabase(), we always get back the exact same instance.
  static final CartDatabase instance = CartDatabase._internal();
  CartDatabase._internal(); // private constructor — prevents "new CartDatabase()"

  // The actual SQLite database object — null until first use
  Database? _db;

  // Returns the open database, opening it first if needed.
  // This is called a "lazy initialiser" — we only open the DB when we need it.
  Future<Database> get database async {
    if (_db != null) return _db!; // already open — return it
    _db = await _openDatabase();  // first time — open it
    return _db!;
  }

  // ── Open / Create ────────────────────────────────────────────────────────
  Future<Database> _openDatabase() async {
    // getDatabasesPath() returns the folder where the OS keeps databases.
    // join() builds the full file path: ".../databases/cart.db"
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cart.db');

    return openDatabase(
      path,
      version: 1, // database version — increase this when you change the schema

      // onCreate only runs the very first time the database file is created.
      // It never runs again unless the user uninstalls the app.
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cart_items (
            product_id  INTEGER PRIMARY KEY,
            title       TEXT    NOT NULL,
            price       REAL    NOT NULL,
            thumbnail   TEXT    NOT NULL,
            quantity    INTEGER NOT NULL DEFAULT 1
          )
        ''');
        // product_id is the PRIMARY KEY — it is also unique, so the same
        // product can never appear twice in the table.
      },
    );
  }

  // ── INSERT or UPDATE ─────────────────────────────────────────────────────
  // Saves one cart item. If the product_id already exists, it replaces the
  // whole row (updating the quantity). If it doesn't exist, it inserts a new row.
  Future<void> insertOrUpdate(CartItem item) async {
    final db = await database;
    await db.insert(
      'cart_items',
      {
        'product_id': item.product.id,
        'title':      item.product.title,
        'price':      item.product.price,
        'thumbnail':  item.product.thumbnail,
        'quantity':   item.quantity,
      },
      // conflictAlgorithm.replace = if a row with this product_id already
      // exists, delete it and insert the new row (effectively an update).
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ── READ ALL ─────────────────────────────────────────────────────────────
  // Returns every row from the cart_items table as a list of CartItem objects.
  // Called when the app starts to restore the cart from the last session.
  Future<List<CartItem>> getAllItems() async {
    final db = await database;
    final rows = await db.query('cart_items'); // SELECT * FROM cart_items

    // Convert each raw Map row into a CartItem object
    return rows.map((row) {
      final product = Product(
        id:          row['product_id'] as int,
        title:       row['title']      as String,
        price:       row['price']      as double,
        thumbnail:   row['thumbnail']  as String,
        // These fields are not stored in the cart table, so we use defaults.
        // They are not needed for the cart display.
        description: '',
        category:    '',
        rating:      0.0,
      );
      return CartItem(
        product:  product,
        quantity: row['quantity'] as int,
      );
    }).toList();
  }

  // ── DELETE ONE ───────────────────────────────────────────────────────────
  // Removes a single product from the cart table by its product_id.
  Future<void> deleteItem(int productId) async {
    final db = await database;
    await db.delete(
      'cart_items',
      where: 'product_id = ?', // the ? prevents SQL injection
      whereArgs: [productId],
    );
  }

  // ── DELETE ALL ───────────────────────────────────────────────────────────
  // Removes every row — used when the user checks out or logs out.
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('cart_items'); // DELETE FROM cart_items
  }
}
