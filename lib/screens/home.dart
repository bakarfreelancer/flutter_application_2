import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/bottom_nav_bar.dart';
import 'package:flutter_application_2/components/top_header.dart';
import 'package:flutter_application_2/models/product.dart';
import 'package:flutter_application_2/screens/cart_screen.dart';
import 'package:flutter_application_2/screens/profile.dart';
import 'package:flutter_application_2/screens/search_screen.dart';
import 'package:flutter_application_2/screens/product_detail_screen.dart';
import 'package:flutter_application_2/services/product_service.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  final List<String> _titles = ['Home', 'Search', 'Cart', 'Profile'];

  final List<Widget> _screens = [
    const _HomeContent(),
    const SearchScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopHeader(title: _titles[_currentIndex]),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// ── Home tab ─────────────────────────────────────────────────────────────────
// Lecture 15: Rebuilt from FutureBuilder to a stateful list that supports
//   - Pull-to-refresh (RefreshIndicator)
//   - Infinite scroll / pagination (ScrollController)
class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  // --- State variables ---

  // The list of products currently shown on screen
  final List<Product> _products = [];

  // How many items to load per page
  static const int _pageSize = 10;

  // How many products we have already loaded (used as the 'skip' value)
  int _skip = 0;

  // True while the very first load is happening (shows a full-screen spinner)
  bool _isLoading = true;

  // True while a subsequent page is being loaded (shows a spinner at the bottom)
  bool _isLoadingMore = false;

  // True once the API returns fewer items than _pageSize (no more pages left)
  bool _hasMore = true;

  // Error message — non-null means the first load failed
  String? _error;

  // ScrollController lets us detect when the user reaches the bottom of the list
  final ScrollController _scrollController = ScrollController();

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    // Load the first page when the screen opens
    _loadProducts();

    // Attach a scroll listener — called every time the user scrolls
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // Always dispose controllers to avoid memory leaks
    _scrollController.dispose();
    super.dispose();
  }

  // ── Scroll listener ────────────────────────────────────────────────────────

  void _onScroll() {
    // _scrollController.position.pixels  = current scroll position (in pixels)
    // _scrollController.position.maxScrollExtent = total scrollable height
    // When these are equal the user has reached the very bottom of the list.
    final atBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;
    // The '- 200' loads the next page a little BEFORE the user hits the very
    // last pixel, so there is no visible gap between pages.

    if (atBottom && !_isLoadingMore && _hasMore) {
      _loadMore();
    }
  }

  // ── Data loading ───────────────────────────────────────────────────────────

  // Load the first page (called on init and on pull-to-refresh)
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await ProductService.getProducts(
        limit: _pageSize,
        skip: 0, // always start from the beginning
      );

      setState(() {
        _products.clear();           // throw away any old products
        _products.addAll(results);   // put in the fresh first page
        _skip = results.length;      // next page will skip past these
        _hasMore = results.length == _pageSize; // if we got fewer, no more pages
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Load the next page and APPEND it to the existing list
  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);

    try {
      final results = await ProductService.getProducts(
        limit: _pageSize,
        skip: _skip, // skip past everything already loaded
      );

      setState(() {
        _products.addAll(results);          // append — don't clear!
        _skip += results.length;            // advance the pointer
        _hasMore = results.length == _pageSize;
        _isLoadingMore = false;
      });
    } catch (_) {
      // If pagination fails, just hide the spinner and let the user scroll again
      setState(() => _isLoadingMore = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // State 1: first load is in progress
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // State 2: first load failed
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text('Something went wrong', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    // State 3: data loaded — show the list wrapped in RefreshIndicator
    //
    // RefreshIndicator shows the pull-to-refresh spinner when the user
    // swipes down from the top of the list. We pass _loadProducts as the
    // onRefresh callback so it reloads from page 1.
    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: ListView.builder(
        controller: _scrollController, // connect the scroll listener
        padding: const EdgeInsets.all(12),

        // Add 1 extra item at the end for the loading-more spinner
        itemCount: _products.length + (_isLoadingMore || _hasMore ? 1 : 0),

        itemBuilder: (context, index) {
          // If we're at the extra item at the end, show the spinner (or nothing)
          if (index == _products.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          // Otherwise show the product card as before
          return _ProductCard(product: _products[index]);
        },
      ),
    );
  }
}

// ── Product card widget ───────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.thumbnail,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey[200],
                      child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category,
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
