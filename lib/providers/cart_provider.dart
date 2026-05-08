import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/food_item_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];
  String? _restaurantId;
  String? _restaurantName;
  String? _promoCode;
  double _discount = 0;

  List<CartItemModel> get items => List.unmodifiable(_items);
  String? get restaurantId => _restaurantId;
  String? get restaurantName => _restaurantName;
  String? get promoCode => _promoCode;
  double get discount => _discount;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);

  double get deliveryFee => subtotal > 0 ? 30 : 0;

  double get totalAmount => subtotal + deliveryFee - _discount;

  bool get isEmpty => _items.isEmpty;

  void addItem(FoodItemModel food, String restId, String restName) {
    if (_restaurantId != null && _restaurantId != restId) {
      throw Exception('different_restaurant');
    }

    _restaurantId = restId;
    _restaurantName = restName;

    final idx = _items.indexWhere((e) => e.foodItem.id == food.id);
    if (idx >= 0) {
      _items[idx].quantity++;
    } else {
      _items.add(CartItemModel(
        foodItem: food,
        restaurantId: restId,
        restaurantName: restName,
        quantity: 1,
      ));
    }
    notifyListeners();
  }

  void removeItem(String foodId) {
    final idx = _items.indexWhere((e) => e.foodItem.id == foodId);
    if (idx < 0) return;
    if (_items[idx].quantity > 1) {
      _items[idx].quantity--;
    } else {
      _items.removeAt(idx);
    }
    if (_items.isEmpty) {
      _restaurantId = null;
      _restaurantName = null;
    }
    notifyListeners();
  }

  void removeItemCompletely(String foodId) {
    _items.removeWhere((e) => e.foodItem.id == foodId);
    if (_items.isEmpty) {
      _restaurantId = null;
      _restaurantName = null;
    }
    notifyListeners();
  }

  void applyPromoCode(String code, double discountAmount) {
    _promoCode = code;
    _discount = discountAmount;
    notifyListeners();
  }

  void removePromoCode() {
    _promoCode = null;
    _discount = 0;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _restaurantId = null;
    _restaurantName = null;
    _promoCode = null;
    _discount = 0;
    notifyListeners();
  }

  int getItemQuantity(String foodId) {
    final idx = _items.indexWhere((e) => e.foodItem.id == foodId);
    return idx >= 0 ? _items[idx].quantity : 0;
  }
}