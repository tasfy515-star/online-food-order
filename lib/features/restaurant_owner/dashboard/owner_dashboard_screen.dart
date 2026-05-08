// lib/features/restaurant_owner/dashboard/owner_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../models/order_model.dart';
import '../../../core/constants/app_colors.dart';

class OwnerDashboardScreen extends StatelessWidget {
  final String restaurantName;

  const OwnerDashboardScreen({
    super.key,
    this.restaurantName = 'My Restaurant',
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orders = context.watch<OrderProvider>().restaurantOrders;
    final now = DateTime.now();

    final todayOrders = orders.where((o) =>
    o.createdAt.day == now.day &&
        o.createdAt.month == now.month &&
        o.createdAt.year == now.year).toList();

    final pending = orders.where((o) =>
    o.status == OrderStatus.pending ||
        o.status == OrderStatus.confirmed ||
        o.status == OrderStatus.preparing).toList();

    final completed = orders
        .where((o) => o.status == OrderStatus.delivered)
        .toList();

    final earnings =
    completed.fold(0.0, (s, o) => s + o.totalAmount);

    return Scaffold(
      appBar: AppBar(
        // Restaurant name show করবে
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(restaurantName,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800)),
            const Text('Owner Dashboard',
                style: TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome! 👋 ${auth.user?.fullName.split(' ').first ?? ''}',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(restaurantName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text(
                          '${todayOrders.length} orders today',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.restaurant,
                        color: Colors.white, size: 30),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Overview Cards
            const Text('Overview',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                _StatCard(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Total Orders',
                  value: '${orders.length}',
                  sub: 'All time',
                  color: AppColors.primary,
                ),
                _StatCard(
                  icon: Icons.pending_actions_outlined,
                  title: 'Pending',
                  value: '${pending.length}',
                  sub: 'Need action',
                  color: AppColors.warning,
                ),
                _StatCard(
                  icon: Icons.check_circle_outline,
                  title: 'Completed',
                  value: '${completed.length}',
                  sub: 'Delivered',
                  color: AppColors.success,
                ),
                _StatCard(
                  icon: Icons.monetization_on_outlined,
                  title: 'Earnings',
                  value: '৳${earnings.toStringAsFixed(0)}',
                  sub: 'Total revenue',
                  color: const Color(0xFF9C27B0),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Orders
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Orders',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700)),
                TextButton(
                    onPressed: () {},
                    child: const Text('See all')),
              ],
            ),
            const SizedBox(height: 8),

            if (orders.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 48, color: AppColors.textLight),
                    SizedBox(height: 12),
                    Text('No orders yet',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text(
                      'When customers place orders,\nthey will appear here',
                      style: TextStyle(
                          color: AppColors.textLight, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...orders.take(5).map((o) => _OrderTile(order: o)),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String sub;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: color)),
              Text(title,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
              Text(sub,
                  style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final OrderModel order;
  const _OrderTile({required this.order});

  Color get _color {
    switch (order.status) {
      case OrderStatus.pending: return AppColors.warning;
      case OrderStatus.confirmed: return AppColors.info;
      case OrderStatus.preparing: return const Color(0xFF9C27B0);
      case OrderStatus.delivered: return AppColors.success;
      case OrderStatus.cancelled: return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }

  String get _label {
    switch (order.status) {
      case OrderStatus.pending: return 'Pending';
      case OrderStatus.confirmed: return 'Confirmed';
      case OrderStatus.preparing: return 'Preparing';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
      default: return order.status.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04), blurRadius: 6),
        ],
      ),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
              color: _color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child:
          Icon(Icons.receipt_long, color: _color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.customerName,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
              Text(
                  '${order.items.length} items • ৳${order.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: _color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6)),
          child: Text(_label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _color)),
        ),
      ]),
    );
  }
}