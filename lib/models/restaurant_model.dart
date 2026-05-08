class RestaurantModel {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String imageUrl;
  final String coverImageUrl;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> categories;
  final double rating;
  final int totalRatings;
  final int deliveryTime; // in minutes
  final double deliveryFee;
  final double minimumOrder;
  final String openingTime;
  final String closingTime;
  final bool isOpen;
  final bool isApproved;
  final bool isFeatured;
  final DateTime createdAt;

  RestaurantModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.coverImageUrl,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.categories,
    this.rating = 0.0,
    this.totalRatings = 0,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.minimumOrder,
    required this.openingTime,
    required this.closingTime,
    this.isOpen = true,
    this.isApproved = false,
    this.isFeatured = false,
    required this.createdAt,
  });

  factory RestaurantModel.fromMap(Map<String, dynamic> map, String docId) {
    return RestaurantModel(
      id: docId,
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      coverImageUrl: map['coverImageUrl'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      categories: List<String>.from(map['categories'] ?? []),
      rating: (map['rating'] ?? 0).toDouble(),
      totalRatings: map['totalRatings'] ?? 0,
      deliveryTime: map['deliveryTime'] ?? 30,
      deliveryFee: (map['deliveryFee'] ?? 0).toDouble(),
      minimumOrder: (map['minimumOrder'] ?? 0).toDouble(),
      openingTime: map['openingTime'] ?? '09:00',
      closingTime: map['closingTime'] ?? '22:00',
      isOpen: map['isOpen'] ?? true,
      isApproved: map['isApproved'] ?? false,
      isFeatured: map['isFeatured'] ?? false,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'coverImageUrl': coverImageUrl,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'categories': categories,
      'rating': rating,
      'totalRatings': totalRatings,
      'deliveryTime': deliveryTime,
      'deliveryFee': deliveryFee,
      'minimumOrder': minimumOrder,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'isOpen': isOpen,
      'isApproved': isApproved,
      'isFeatured': isFeatured,
      'createdAt': createdAt,
    };
  }
}
 