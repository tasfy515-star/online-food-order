import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../models/restaurant_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/restaurant_provider.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final bool isHorizontal;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.isHorizontal,
  });

  void _onTap(BuildContext context) {

    context.read<RestaurantProvider>().selectRestaurant(restaurant);
    context.push('/customer/restaurant/${restaurant.id}');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onTap(context),
      child: isHorizontal
          ? _HorizontalCard(restaurant: restaurant)
          : _VerticalCard(restaurant: restaurant),
    );
  }
}


class _HorizontalCard extends StatelessWidget {
  final RestaurantModel restaurant;

  const _HorizontalCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          ClipRRect(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16)),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: restaurant.imageUrl,
                  height: 115,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 115,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.restaurant,
                          size: 40, color: Colors.grey),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 115,
                    color: AppColors.primary.withOpacity(0.1),
                    child: const Center(
                      child: Icon(Icons.restaurant,
                          size: 40, color: AppColors.primary),
                    ),
                  ),
                ),

                if (!restaurant.isOpen)
                  Container(
                    height: 115,
                    color: Colors.black.withOpacity(0.4),
                    child: const Center(
                      child: Text('CLOSED',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
              ],
            ),
          ),


          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star,
                        size: 12, color: Color(0xFFFFD700)),
                    const SizedBox(width: 2),
                    Text(
                      restaurant.rating.toStringAsFixed(1),
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.access_time,
                        size: 11, color: AppColors.textLight),
                    const SizedBox(width: 2),
                    Text(
                      '${restaurant.deliveryTime}m',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '৳${restaurant.deliveryFee.toStringAsFixed(0)} delivery',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _VerticalCard extends StatelessWidget {
  final RestaurantModel restaurant;

  const _VerticalCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          ClipRRect(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16)),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: restaurant.coverImageUrl.isNotEmpty
                      ? restaurant.coverImageUrl
                      : restaurant.imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 160,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.restaurant,
                          size: 60, color: Colors.grey),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 160,
                    color: AppColors.primary.withOpacity(0.1),
                    child: const Center(
                      child: Icon(Icons.restaurant,
                          size: 60, color: AppColors.primary),
                    ),
                  ),
                ),


                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: restaurant.isOpen
                          ? AppColors.success
                          : AppColors.error,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      restaurant.isOpen ? 'Open' : 'Closed',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),


                if (restaurant.isFeatured)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '⭐ Featured',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),


                if (!restaurant.isOpen)
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16)),
                    ),
                    child: const Center(
                      child: Text(
                        'CLOSED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),


          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        restaurant.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Icon(Icons.star,
                        size: 14, color: Color(0xFFFFD700)),
                    const SizedBox(width: 2),
                    Text(
                      restaurant.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      ' (${restaurant.totalRatings})',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),


                Text(
                  restaurant.categories.join(' • '),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),


                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 13,
                        color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text(
                      '${restaurant.deliveryTime} min',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.delivery_dining,
                        size: 13,
                        color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text(
                      '৳${restaurant.deliveryFee.toStringAsFixed(0)} delivery',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.shopping_bag_outlined,
                        size: 13,
                        color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text(
                      'Min ৳${restaurant.minimumOrder.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}