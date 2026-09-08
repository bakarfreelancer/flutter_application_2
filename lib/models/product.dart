// Product is a model class — it represents one product from the API.
// Each field maps to a key in the JSON response from dummyjson.com.
class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String thumbnail; // image URL
  final double rating;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.thumbnail,
    required this.rating,
  });

  // factory constructor — converts a JSON map into a Product object
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id:          json['id'],
      title:       json['title'],
      price:       (json['price'] as num).toDouble(),
      description: json['description'],
      category:    json['category'],
      thumbnail:   json['thumbnail'],
      rating:      (json['rating'] as num).toDouble(),
    );
  }
}
