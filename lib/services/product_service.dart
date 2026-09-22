import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/models/product.dart';

// ProductService handles all API calls related to products.
// Screens call these methods — they don't need to know how HTTP works.
class ProductService {
  static const String _baseUrl = 'https://dummyjson.com';

  // Fetch a page of products.
  // Lecture 15: Added 'limit' and 'skip' parameters for pagination.
  //   limit = how many products to fetch at once (e.g. 10)
  //   skip  = how many products to skip from the beginning (e.g. 20 → page 3)
  static Future<List<Product>> getProducts({int limit = 10, int skip = 0}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products?limit=$limit&skip=$skip'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);      // parse JSON string → Map
      final List productsJson = data['products'];  // get the 'products' array
      // convert each JSON map into a Product object
      return productsJson.map((p) => Product.fromJson(p)).toList();
    }

    // If the server returns an error code, throw an exception
    throw Exception('Failed to load products');
  }

  // Search products by a query string
  static Future<List<Product>> searchProducts(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products/search?q=$query'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List productsJson = data['products'];
      return productsJson.map((p) => Product.fromJson(p)).toList();
    }

    throw Exception('Failed to search products');
  }
}
