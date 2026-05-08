import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_model.dart';
import '../models/food_item_model.dart';
import '../models/order_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<RestaurantModel>> getApprovedRestaurants() {
    return _db
        .collection('restaurants')
        .where('isApproved', isEqualTo: true)
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => RestaurantModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  Stream<List<RestaurantModel>> getFeaturedRestaurants() {
    return _db
        .collection('restaurants')
        .where('isApproved', isEqualTo: true)
        .where('isFeatured', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => RestaurantModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  Stream<List<RestaurantModel>> getRestaurantsByCategory(String category) {
    return _db
        .collection('restaurants')
        .where('isApproved', isEqualTo: true)
        .where('categories', arrayContains: category)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => RestaurantModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<RestaurantModel?> getRestaurantById(String id) async {
    final doc = await _db.collection('restaurants').doc(id).get();
    if (doc.exists) return RestaurantModel.fromMap(doc.data()!, doc.id);
    return null;
  }

  Future<String> addRestaurant(RestaurantModel restaurant) async {
    final doc = await _db.collection('restaurants').add(restaurant.toMap());
    return doc.id;
  }

  Future<void> updateRestaurant(RestaurantModel restaurant) async {
    await _db
        .collection('restaurants')
        .doc(restaurant.id)
        .update(restaurant.toMap());
  }

  Future<void> approveRestaurant(String restaurantId, bool approve) async {
    await _db.collection('restaurants').doc(restaurantId).update({
      'isApproved': approve,
    });
  }

  Stream<List<FoodItemModel>> getFoodItemsByRestaurant(String restaurantId) {
    return _db
        .collection('foodItems')
        .where('restaurantId', isEqualTo: restaurantId)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => FoodItemModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<void> addFoodItem(FoodItemModel item) async {
    await _db.collection('foodItems').add(item.toMap());
  }

  Future<void> updateFoodItem(FoodItemModel item) async {
    await _db.collection('foodItems').doc(item.id).update(item.toMap());
  }

  Future<void> toggleFoodAvailability(String itemId, bool isAvailable) async {
    await _db.collection('foodItems').doc(itemId).update({
      'isAvailable': isAvailable,
    });
  }

  Future<void> deleteFoodItem(String itemId) async {
    await _db.collection('foodItems').doc(itemId).delete();
  }

  Future<String> placeOrder(OrderModel order) async {
    final doc = await _db.collection('orders').add(order.toMap());
    return doc.id;
  }

  Stream<List<OrderModel>> getCustomerOrders(String customerId) {
    return _db
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  Stream<List<OrderModel>> getRestaurantOrders(String restaurantId) {
    return _db
        .collection('orders')
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  Stream<List<OrderModel>> getAllOrders() {
    return _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _db.collection('orders').doc(orderId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<RestaurantModel>> searchRestaurants(String query) async {
    final lower = query.toLowerCase();
    final snap = await _db
        .collection('restaurants')
        .where('isApproved', isEqualTo: true)
        .get();
    return snap.docs
        .map((doc) => RestaurantModel.fromMap(doc.data(), doc.id))
        .where((r) => r.name.toLowerCase().contains(lower))
        .toList();
  }

  Future<Map<String, dynamic>?> validatePromoCode(String code) async {
    final snap = await _db
        .collection('promoCodes')
        .where('code', isEqualTo: code.toUpperCase())
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first.data();
  }

  Future<Map<String, dynamic>> getAdminStats() async {
    final usersSnap = await _db.collection('users').get();
    final restaurantsSnap = await _db.collection('restaurants').get();
    final ordersSnap = await _db.collection('orders').get();

    double totalRevenue = 0;
    int activeOrders = 0;
    for (final doc in ordersSnap.docs) {
      final data = doc.data();
      totalRevenue += (data['totalAmount'] ?? 0).toDouble();
      final status = data['status'] ?? '';
      if (status != 'delivered' && status != 'cancelled') activeOrders++;
    }

    return {
      'totalUsers': usersSnap.docs.length,
      'totalRestaurants': restaurantsSnap.docs.length,
      'activeOrders': activeOrders,
      'totalRevenue': totalRevenue,
    };
  }
}
 