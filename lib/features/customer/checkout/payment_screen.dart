// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../models/order_model.dart';
import '../../../core/constants/app_colors.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.cashOnDelivery;

  final List<_PaymentOption> _options = [
    _PaymentOption(
      method: PaymentMethod.cashOnDelivery,
      icon: Icons.money,
      label: 'Cash on Delivery',
      subtitle: 'Pay when food arrives',
      color: AppColors.success,
    ),
    _PaymentOption(
      method: PaymentMethod.bkash,
      icon: Icons.account_balance_wallet,
      label: 'bKash',
      subtitle: 'Pay via bKash mobile banking',
      color: Color(0xFFE2136E),
    ),
    _PaymentOption(
      method: PaymentMethod.card,
      icon: Icons.credit_card,
      label: 'Card Payment',
      subtitle: 'Visa, Mastercard, DBBL',
      color: AppColors.info,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Payment Method',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),

            ...(_options.map((opt) => GestureDetector(
              onTap: () =>
                  setState(() => _selectedMethod = opt.method),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _selectedMethod == opt.method
                      ? opt.color.withOpacity(0.08)
                      : Theme.of(context).cardColor,
                  border: Border.all(
                    color: _selectedMethod == opt.method
                        ? opt.color
                        : Colors.grey.shade200,
                    width: _selectedMethod == opt.method ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: opt.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(opt.icon, color: opt.color, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(opt.label,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _selectedMethod == opt.method
                                    ? opt.color
                                    : null,
                              )),
                          Text(opt.subtitle,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Radio<PaymentMethod>(
                      value: opt.method,
                      groupValue: _selectedMethod,
                      onChanged: (v) =>
                          setState(() => _selectedMethod = v!),
                      activeColor: opt.color,
                    ),
                  ],
                ),
              ),
            ))),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Order Summary',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  _SummaryRow('Subtotal',
                      '৳${cart.subtotal.toStringAsFixed(0)}'),
                  _SummaryRow('Delivery Fee',
                      '৳${cart.deliveryFee.toStringAsFixed(0)}'),
                  if (cart.discount > 0)
                    _SummaryRow('Discount',
                        '-৳${cart.discount.toStringAsFixed(0)}',
                        color: AppColors.success),
                  const Divider(height: 20),
                  _SummaryRow(
                    'Total',
                    '৳${cart.totalAmount.toStringAsFixed(0)}',
                    isBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: orderProvider.isLoading
                    ? null
                    : () => _placeOrder(context),
                child: orderProvider.isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
                    : Text(
                  'Pay ৳${cart.totalAmount.toStringAsFixed(0)}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context) async {
    final cart = context.read<CartProvider>();
    final auth = context.read<AuthProvider>();
    final orderProvider = context.read<OrderProvider>();

    final orderId = await orderProvider.placeOrder(
      customerId: auth.user!.uid,
      customerName: auth.user!.fullName,
      customerPhone: auth.user!.phone,
      restaurantId: cart.restaurantId!,
      restaurantName: cart.restaurantName!,
      cartItems: cart.items.toList(),
      subtotal: cart.subtotal,
      deliveryFee: cart.deliveryFee,
      discount: cart.discount,
      paymentMethod: _selectedMethod,
      deliveryAddress: 'Dhaka, Bangladesh',
      promoCode: cart.promoCode,
    );

    if (orderId != null) {
      cart.clearCart();
      if (mounted) context.go('/customer/order-confirmation');
    }
  }
}

class _PaymentOption {
  final PaymentMethod method;
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  const _PaymentOption({
    required this.method,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
  });
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;
  const _SummaryRow(this.label, this.value,
      {this.isBold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isBold ? 15 : 13,
                  fontWeight:
                  isBold ? FontWeight.w700 : FontWeight.normal,
                  color: color ?? AppColors.textSecondary)),
          Text(value,
              style: TextStyle(
                  fontSize: isBold ? 16 : 13,
                  fontWeight:
                  isBold ? FontWeight.w700 : FontWeight.w500,
                  color: color ?? (isBold ? AppColors.primary : null))),
        ],
      ),
    );
  }
}