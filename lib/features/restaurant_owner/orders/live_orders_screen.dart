import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/order_provider.dart';
import '../../../models/order_model.dart';
import '../../../core/constants/app_colors.dart';

class LiveOrdersScreen extends StatelessWidget {
  const LiveOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context
        .watch<OrderProvider>()
        .restaurantOrders
        .where((o) =>
    o.status != OrderStatus.delivered &&
        o.status != OrderStatus.cancelled)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Live Orders')),
      body: orders.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64, color: AppColors.textLight),
            SizedBox(height: 16),
            Text('No active orders',
                style: TextStyle(
                    fontSize: 16, color: AppColors.textSecondary)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (ctx, i) => _LiveOrderCard(order: orders[i]),
      ),
    );
  }
}

class _LiveOrderCard extends StatelessWidget {
  final OrderModel order;
  const _LiveOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07), blurRadius: 8)
        ],
      ),
      child: Column(
        children: [

          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(order.customerName,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(order.customerPhone,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text('${item.quantity}×',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary)),
                      const SizedBox(width: 6),
                      Expanded(
                          child: Text(item.foodName,
                              style: const TextStyle(fontSize: 13))),
                      Text('৳${item.totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                )),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    Text('৳${order.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                if (order.status == OrderStatus.pending)
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Accept'),
                      onPressed: () => context
                          .read<OrderProvider>()
                          .updateOrderStatus(
                          order.id, OrderStatus.preparing),
                    ),
                  )
                else if (order.status == OrderStatus.preparing)
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.done_all, size: 16),
                      label: const Text('Ready for Pickup'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success),
                      onPressed: () => context
                          .read<OrderProvider>()
                          .updateOrderStatus(
                          order.id, OrderStatus.readyForPickup),
                    ),
                  ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  icon: const Icon(Icons.close, size: 16,
                      color: AppColors.error),
                  label: const Text('Cancel',
                      style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error)),
                  onPressed: () => context
                      .read<OrderProvider>()
                      .updateOrderStatus(order.id, OrderStatus.cancelled),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}