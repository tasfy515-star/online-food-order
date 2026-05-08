// lib/features/restaurant_owner/menu/menu_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../models/food_item_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class MenuManagementScreen extends StatelessWidget {
  final String restaurantId;

  const MenuManagementScreen({
    super.key,
    this.restaurantId = '',
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final service = FirestoreService();
    final restId = restaurantId.isNotEmpty
        ? restaurantId
        : auth.user!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () =>
                _showSheet(context, service, restId),
          ),
        ],
      ),
      body: StreamBuilder<List<FoodItemModel>>(
        stream: service.getFoodItemsByRestaurant(restId),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator());
          }
          final items = snap.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.restaurant_menu,
                      size: 72, color: AppColors.textLight),
                  const SizedBox(height: 16),
                  const Text('No menu items yet',
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Item'),
                    onPressed: () =>
                        _showSheet(context, service, restId),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (ctx, i) => _MenuTile(
              item: items[i],
              service: service,
              onEdit: () => _showSheet(
                  context, service, restId,
                  existing: items[i]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSheet(context, service, restId),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Item',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showSheet(
      BuildContext context, FirestoreService service, String restId,
      {FoodItemModel? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FoodSheet(
        service: service,
        restaurantId: restId,
        existing: existing,
      ),
    );
  }
}

// ── Menu Item Tile ────────────────────────────────

class _MenuTile extends StatelessWidget {
  final FoodItemModel item;
  final FirestoreService service;
  final VoidCallback onEdit;

  const _MenuTile({
    required this.item,
    required this.service,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.imageUrl.isNotEmpty
                ? Image.network(
              item.imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imgPlaceholder(),
            )
                : _imgPlaceholder(),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(item.category,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text('৳${item.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary)),
              ],
            ),
          ),

          // Stock Switch
          Column(
            children: [
              Switch(
                value: item.isAvailable,
                activeColor: AppColors.primary,
                onChanged: (v) =>
                    service.toggleFoodAvailability(item.id, v),
              ),
              Text(
                item.isAvailable ? 'In Stock' : 'Out',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: item.isAvailable
                        ? AppColors.success
                        : AppColors.error),
              ),
            ],
          ),
          const SizedBox(width: 4),

          // Edit & Delete
          Column(
            children: [
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      color: AppColors.info, size: 18),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => _confirmDelete(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: AppColors.error, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
    width: 70,
    height: 70,
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Icon(Icons.fastfood,
        color: Colors.grey, size: 30),
  );

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete item?'),
        content:
        Text('Remove "${item.name}" from menu?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            onPressed: () {
              service.deleteFoodItem(item.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Add / Edit Food Sheet ─────────────────────────

class _FoodSheet extends StatefulWidget {
  final FirestoreService service;
  final String restaurantId;
  final FoodItemModel? existing;

  const _FoodSheet({
    required this.service,
    required this.restaurantId,
    this.existing,
  });

  @override
  State<_FoodSheet> createState() => _FoodSheetState();
}

class _FoodSheetState extends State<_FoodSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _imgCtrl;
  late String _category;
  late bool _inStock;
  late bool _isVeg;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _priceCtrl = TextEditingController(
        text: e != null ? e.price.toStringAsFixed(0) : '');
    _imgCtrl = TextEditingController(text: e?.imageUrl ?? '');
    _category = e?.category ?? AppStrings.foodCategories.first;
    _inStock = e?.isAvailable ?? true;
    _isVeg = e?.isVeg ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _imgCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final item = FoodItemModel(
      id: widget.existing?.id ?? '',
      restaurantId: widget.restaurantId,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      imageUrl: _imgCtrl.text.trim(),
      price: double.parse(_priceCtrl.text.trim()),
      category: _category,
      isAvailable: _inStock,
      isVeg: _isVeg,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    if (_isEdit) {
      await widget.service.updateFoodItem(item);
    } else {
      await widget.service.addFoodItem(item);
    }

    if (mounted) Navigator.pop(context);
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                _isEdit ? 'Edit Menu Item' : 'Add Menu Item',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),

              // Food Name
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Food Name *',
                  prefixIcon: Icon(Icons.fastfood_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter food name'
                    : null,
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
              ),
              const SizedBox(height: 12),

              // Price
              TextFormField(
                controller: _priceCtrl,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Price (৳) *',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Enter price';
                  }
                  if (double.tryParse(v.trim()) == null) {
                    return 'Invalid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Image URL
              TextFormField(
                controller: _imgCtrl,
                decoration: const InputDecoration(
                  labelText: 'Image URL (optional)',
                  prefixIcon: Icon(Icons.image_outlined),
                  hintText: 'https://...',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '💡 Google এ image খুঁজে right click → Copy image address',
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),

              // Category
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: AppStrings.foodCategories
                    .map((c) => DropdownMenuItem(
                    value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _category = v!),
              ),
              const SizedBox(height: 12),

              // Toggles row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _inStock
                            ? AppColors.success.withOpacity(0.08)
                            : AppColors.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _inStock
                              ? AppColors.success.withOpacity(0.3)
                              : AppColors.error.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _inStock
                                ? Icons.check_circle_outline
                                : Icons.cancel_outlined,
                            color: _inStock
                                ? AppColors.success
                                : AppColors.error,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _inStock ? 'In Stock' : 'Out of Stock',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _inStock
                                    ? AppColors.success
                                    : AppColors.error),
                          ),
                          const Spacer(),
                          Switch(
                            value: _inStock,
                            onChanged: (v) =>
                                setState(() => _inStock = v),
                            activeColor: AppColors.success,
                            materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isVeg
                            ? AppColors.success.withOpacity(0.08)
                            : Colors.grey.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isVeg
                              ? AppColors.success.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.eco_outlined,
                            color: _isVeg
                                ? AppColors.success
                                : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Veg',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _isVeg
                                    ? AppColors.success
                                    : Colors.grey),
                          ),
                          const Spacer(),
                          Switch(
                            value: _isVeg,
                            onChanged: (v) =>
                                setState(() => _isVeg = v),
                            activeColor: AppColors.success,
                            materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2))
                      : Text(
                      _isEdit
                          ? 'Update Item'
                          : 'Add to Menu',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}