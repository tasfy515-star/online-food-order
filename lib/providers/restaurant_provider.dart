import 'package:flutter/material.dart';
import '../models/restaurant_model.dart';
import '../models/food_item_model.dart';
import '../services/firestore_service.dart';

class RestaurantProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<RestaurantModel> _allRestaurants = [];
  List<RestaurantModel> _featuredRestaurants = [];
  List<RestaurantModel> _filteredRestaurants = [];
  List<FoodItemModel> _currentMenuItems = [];
  RestaurantModel? _selectedRestaurant;

  bool _isLoading = false;
  bool _isMenuLoading = false;
  String? _selectedCategory;

  List<RestaurantModel> get restaurants =>
      _selectedCategory != null
          ? _filteredRestaurants
          : _allRestaurants;

  List<RestaurantModel> get featuredRestaurants =>
      _selectedCategory != null
          ? _filteredRestaurants.where((r) => r.isFeatured).toList()
          : _featuredRestaurants;

  List<FoodItemModel> get currentMenuItems => _currentMenuItems;
  RestaurantModel? get selectedRestaurant => _selectedRestaurant;
  bool get isLoading => _isLoading;
  bool get isMenuLoading => _isMenuLoading;
  String? get selectedCategory => _selectedCategory;

  void listenToRestaurants() {
    _isLoading = true;
    notifyListeners();

    _service.getApprovedRestaurants().listen((data) {
      _allRestaurants = data;
      if (_selectedCategory != null) {
        _applyFilter(_selectedCategory!);
      }
      _isLoading = false;
      notifyListeners();
    });

    _service.getFeaturedRestaurants().listen((data) {
      _featuredRestaurants = data;
      notifyListeners();
    });
  }

  Future<void> loadRestaurantById(String id) async {
    if (_selectedRestaurant?.id == id) {
      _loadMenuItems(id);
      return;
    }
    final local = _allRestaurants.where((r) => r.id == id).toList();
    if (local.isNotEmpty) {
      _selectedRestaurant = local.first;
      notifyListeners();
      _loadMenuItems(id);
      return;
    }

    final restaurant = await _service.getRestaurantById(id);
    if (restaurant != null) {
      _selectedRestaurant = restaurant;
      notifyListeners();
      _loadMenuItems(id);
    }
  }

  void selectRestaurant(RestaurantModel restaurant) {
    _selectedRestaurant = restaurant;
    notifyListeners();
    _loadMenuItems(restaurant.id);
  }

  void _loadMenuItems(String restaurantId) {
    _isMenuLoading = true;
    _currentMenuItems = [];
    notifyListeners();

    _service.getFoodItemsByRestaurant(restaurantId).listen((items) {
      _currentMenuItems = items;
      _isMenuLoading = false;
      notifyListeners();
    });
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilter(category);
    notifyListeners();
  }

  void clearCategoryFilter() {
    _selectedCategory = null;
    _filteredRestaurants = [];
    notifyListeners();
  }

  void _applyFilter(String category) {
    _filteredRestaurants = _allRestaurants
        .where((r) => r.categories.contains(category))
        .toList();
  }

  Future<List<RestaurantModel>> searchRestaurants(
      String query) async {
    return await _service.searchRestaurants(query);
  }
}