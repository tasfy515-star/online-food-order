import 'package:flutter/material.dart';
import '../models/food_item_model.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../services/firestore_service.dart';

class OrderProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<OrderModel> _customerOrders = [];
  List<OrderModel> _restaurantOrders = [];
  List<OrderModel> _allOrders = [];
  OrderModel? _lastPlacedOrder;
  bool _isLoading = false;

  List<OrderModel> get customerOrders => _customerOrders;
  List<OrderModel> get restaurantOrders => _restaurantOrders;
  List<OrderModel> get allOrders => _allOrders;
  OrderModel? get lastPlacedOrder => _lastPlacedOrder;
  bool get isLoading => _isLoading;

  Future<String?> placeOrder({
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String restaurantId,
    required String restaurantName,
    required List<CartItemModel> cartItems,
    required double subtotal,
    required double deliveryFee,
    required double discount,
    required PaymentMethod paymentMethod,
    required String deliveryAddress,
    String? promoCode,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final order = OrderModel(
        id: '',
        customerId: customerId,
        customerName: customerName,
        customerPhone: customerPhone,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        items: cartItems
            .map((c) => OrderItemModel(
          foodItemId: c.foodItem.id,
          foodName: c.foodItem.name,
          foodImage: c.foodItem.imageUrl,
          price: c.foodItem.price,
          quantity: c.quantity,
        ))
            .toList(),
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        discount: discount,
        totalAmount: subtotal + deliveryFee - discount,
        paymentMethod: paymentMethod,
        deliveryAddress: deliveryAddress,
        promoCode: promoCode,
        createdAt: DateTime.now(),
      );

      final orderId = await _service.placeOrder(order);
      _lastPlacedOrder = order.copyWith(status: OrderStatus.confirmed);
      return orderId;
    } catch (e) {
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void listenToCustomerOrders(String customerId) {
    _service.getCustomerOrders(customerId).listen((orders) {
      _customerOrders = orders;
      notifyListeners();
    });
  }

  void listenToRestaurantOrders(String restaurantId) {
    _service.getRestaurantOrders(restaurantId).listen((orders) {
      _restaurantOrders = orders;
      notifyListeners();
    });
  }

  void listenToAllOrders() {
    _service.getAllOrders().listen((orders) {
      _allOrders = orders;
      notifyListeners();
    });
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _service.updateOrderStatus(orderId, status);
  }
}
