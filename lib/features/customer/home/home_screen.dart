

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/restaurant_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import 'widgets/promo_banner.dart';
import 'widgets/food_categories.dart';
import 'widgets/restaurant_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedLocation = 'Dhaka, Bangladesh';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantProvider>().listenToRestaurants();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final restaurantProvider = context.watch<RestaurantProvider>();

    final selectedCategory = restaurantProvider.selectedCategory;
    final restaurants = restaurantProvider.restaurants;
    final featuredRestaurants = restaurantProvider.featuredRestaurants;

    return Scaffold(
      body: CustomScrollView(
        slivers: [

          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(16, 44, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 4),
                        Expanded(
                          child: GestureDetector(
                            onTap: _showLocationPicker,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedLocation,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down,
                                    size: 18),
                              ],
                            ),
                          ),
                        ),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor:
                          AppColors.primary.withOpacity(0.1),
                          child: Text(
                            (auth.user?.fullName.isNotEmpty == true)
                                ? auth.user!.fullName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hi, ${auth.user?.fullName.split(' ').first ?? 'there'}! 👋',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      'What would you like to eat?',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: GestureDetector(
                    onTap: () => context.go('/customer/search'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search,
                              color: AppColors.textLight, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            AppStrings.searchHint,
                            style: TextStyle(
                                color: AppColors.textLight, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                if (selectedCategory == null) ...[
                  const SizedBox(height: 20),
                  const PromoBanner(),
                ],

                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Categories',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),
                const FoodCategories(),

                if (selectedCategory != null) ...[
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$selectedCategory Restaurants',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${restaurants.length} found',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (restaurants.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.restaurant,
                                size: 60, color: AppColors.textLight),
                            const SizedBox(height: 12),
                            Text(
                              'No $selectedCategory restaurants found',
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: restaurants.length,
                      itemBuilder: (ctx, i) => RestaurantCard(
                        restaurant: restaurants[i],
                        isHorizontal: false,
                      ),
                    ),
                ],

                if (selectedCategory == null) ...[
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Popular Restaurants',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (restaurantProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (featuredRestaurants.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text('No restaurants available',
                            style: TextStyle(
                                color: AppColors.textSecondary)),
                      ),
                    )
                  else
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: featuredRestaurants.length,
                        itemBuilder: (ctx, i) => RestaurantCard(
                          restaurant: featuredRestaurants[i],
                          isHorizontal: true,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'All Restaurants',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: restaurants.length,
                    itemBuilder: (ctx, i) => RestaurantCard(
                      restaurant: restaurants[i],
                      isHorizontal: false,
                    ),
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Set Location',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.my_location,
                  color: AppColors.primary),
              title: const Text('Use Current Location'),
              onTap: () {
                setState(() =>
                _selectedLocation = 'Current Location');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_location_alt_outlined),
              title: const Text('Add New Address'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}