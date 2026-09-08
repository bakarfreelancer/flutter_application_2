import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/product.dart';
import 'package:flutter_application_2/services/product_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // null = no search done yet, Future = search in progress or done
  Future<List<Product>>? _resultsFuture;

  void _search() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    // Trigger a rebuild with the new Future
    setState(() {
      _resultsFuture = ProductService.searchProducts(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Search bar ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search products...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onSubmitted: (_) => _search(), // search on keyboard done
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
                onPressed: _search,
                child: const Icon(Icons.search),
              ),
            ],
          ),
        ),

        // ── Results ───────────────────────────────────────────────────
        Expanded(
          child: _resultsFuture == null
              // No search yet — show a prompt
              ? const Center(
                  child: Text(
                    'Search for a product above',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : FutureBuilder<List<Product>>(
                  future: _resultsFuture,
                  builder: (context, snapshot) {

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final products = snapshot.data!;

                    if (products.isEmpty) {
                      return const Center(child: Text('No products found'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            // Small thumbnail on the left
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                product.thumbnail,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              product.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(product.category),
                            trailing: Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.orangeAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
