import 'food_item_model.dart';

class CartItemModel {
  final FoodItemModel foodItem;
  final String restaurantId;
  final String restaurantName;
  int quantity;

  CartItemModel({
    required this.foodItem,
    required this.restaurantId,
    required this.restaurantName,
    required this.quantity,
  });

  double get totalPrice => foodItem.price * quantity;
}