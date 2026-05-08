import 'package:flutter/material.dart';
import '../../../services/firestore_service.dart';
import '../../../models/restaurant_model.dart';
import '../../../core/constants/app_colors.dart';

class RestaurantManagementScreen extends StatelessWidget {
  const RestaurantManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Management')),
      body: StreamBuilder<List<RestaurantModel>>(
        stream: service.getApprovedRestaurants(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final restaurants = snap.data ?? [];
          if (restaurants.isEmpty) {
            return const Center(
                child: Text('No restaurants',
                    style: TextStyle(color: AppColors.textSecondary)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: restaurants.length,
            itemBuilder: (ctx, i) {
              final r = restaurants[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6)
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.name,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          Text(r.address,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 12,
                                  color: Color(0xFFFFD700)),
                              Text(' ${r.rating}',
                                  style:
                                  const TextStyle(fontSize: 12)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: r.isApproved
                                      ? AppColors.success
                                      .withOpacity(0.1)
                                      : AppColors.warning
                                      .withOpacity(0.1),
                                  borderRadius:
                                  BorderRadius.circular(4),
                                ),
                                child: Text(
                                  r.isApproved
                                      ? 'Approved'
                                      : 'Pending',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: r.isApproved
                                        ? AppColors.success
                                        : AppColors.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == 'approve') {
                          service.approveRestaurant(r.id, true);
                        } else if (val == 'reject') {
                          service.approveRestaurant(r.id, false);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                            value: 'approve',
                            child: Text('Approve')),
                        const PopupMenuItem(
                            value: 'reject',
                            child: Text('Reject')),
                        const PopupMenuItem(
                            value: 'block',
                            child: Text('Block')),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}