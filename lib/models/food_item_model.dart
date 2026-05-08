class FoodItemModel {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String category;
  final bool isAvailable;
  final bool isPopular;
  final bool isVeg;
  final List<String> tags;
  final DateTime createdAt;

  FoodItemModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.category,
    this.isAvailable = true,
    this.isPopular = false,
    this.isVeg = false,
    this.tags = const [],
    required this.createdAt,
  });

  factory FoodItemModel.fromMap(Map<String, dynamic> map, String docId) {
    return FoodItemModel(
      id: docId,
      restaurantId: map['restaurantId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      isPopular: map['isPopular'] ?? false,
      isVeg: map['isVeg'] ?? false,
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'category': category,
      'isAvailable': isAvailable,
      'isPopular': isPopular,
      'isVeg': isVeg,
      'tags': tags,
      'createdAt': createdAt,
    };
  }
}


