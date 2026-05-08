// lib/features/restaurant_owner/owner_main_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../core/constants/app_colors.dart';
import 'dashboard/owner_dashboard_screen.dart';
import 'menu/menu_management_screen.dart';
import 'orders/live_orders_screen.dart';
import 'orders/owner_order_history_screen.dart';
import 'profile/shop_profile_screen.dart';
import 'reviews/reviews_screen.dart';

class OwnerMainScreen extends StatefulWidget {
  const OwnerMainScreen({super.key});

  @override
  State<OwnerMainScreen> createState() => _OwnerMainScreenState();
}

class _OwnerMainScreenState extends State<OwnerMainScreen> {
  int _index = 0;
  String _restaurantName = 'My Restaurant';
  String _restaurantId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRestaurantInfo();
    });
  }

  Future<void> _loadRestaurantInfo() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;

    // Owner এর restaurant খুঁজে বের করো
    final snap = await FirebaseFirestore.instance
        .collection('restaurants')
        .where('ownerId', isEqualTo: auth.user!.uid)
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      setState(() {
        _restaurantName = snap.docs.first.data()['name'] ?? 'My Restaurant';
        _restaurantId = snap.docs.first.id;
      });
    }

    // Orders listen করো
    context.read<OrderProvider>().listenToRestaurantOrders(
        _restaurantId.isNotEmpty ? _restaurantId : auth.user!.uid);
  }

  Widget get _currentScreen {
    switch (_index) {
      case 0: return OwnerDashboardScreen(restaurantName: _restaurantName);
      case 1: return const LiveOrdersScreen();
      case 2: return MenuManagementScreen(restaurantId: _restaurantId);
      case 3: return const OwnerOrderHistoryScreen();
      case 4: return const ShopProfileScreen();
      default: return OwnerDashboardScreen(restaurantName: _restaurantName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      drawer: _SideDrawer(
        auth: auth,
        restaurantName: _restaurantName,
        currentIndex: _index,
        onNavigate: (i) => setState(() => _index = i),
      ),
      body: _currentScreen,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Theme.of(context).cardColor,
        indicatorColor: AppColors.primary.withOpacity(0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon:
            Icon(Icons.dashboard, color: AppColors.primary),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon:
            Icon(Icons.receipt_long, color: AppColors.primary),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon:
            Icon(Icons.restaurant_menu, color: AppColors.primary),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon:
            Icon(Icons.history, color: AppColors.primary),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.store_outlined),
            selectedIcon: Icon(Icons.store, color: AppColors.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ── Side Drawer ───────────────────────────────────

class _SideDrawer extends StatelessWidget {
  final AuthProvider auth;
  final String restaurantName;
  final int currentIndex;
  final Function(int) onNavigate;

  const _SideDrawer({
    required this.auth,
    required this.restaurantName,
    required this.currentIndex,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
            decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.restaurant,
                      color: Colors.white, size: 32),
                ),
                const SizedBox(height: 12),
                Text(restaurantName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
                Text(auth.user?.fullName ?? '',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13)),
                Text(auth.user?.email ?? '',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Restaurant Owner',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                  vertical: 8, horizontal: 8),
              children: [
                _DrawerItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  selected: currentIndex == 0,
                  onTap: () {
                    onNavigate(0);
                    Navigator.pop(context);
                  },
                ),
                _DrawerItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Live Orders',
                  selected: currentIndex == 1,
                  onTap: () {
                    onNavigate(1);
                    Navigator.pop(context);
                  },
                ),
                _DrawerItem(
                  icon: Icons.restaurant_menu_outlined,
                  label: 'Manage Menu',
                  selected: currentIndex == 2,
                  onTap: () {
                    onNavigate(2);
                    Navigator.pop(context);
                  },
                ),
                _DrawerItem(
                  icon: Icons.history_outlined,
                  label: 'Order History',
                  selected: currentIndex == 3,
                  onTap: () {
                    onNavigate(3);
                    Navigator.pop(context);
                  },
                ),
                _DrawerItem(
                  icon: Icons.store_outlined,
                  label: 'Shop Profile',
                  selected: currentIndex == 4,
                  onTap: () {
                    onNavigate(4);
                    Navigator.pop(context);
                  },
                ),
                _DrawerItem(
                  icon: Icons.star_outline,
                  label: 'Reviews',
                  selected: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ReviewsScreen()),
                    );
                  },
                ),
                const Divider(height: 24),
                _DrawerItem(
                  icon: Icons.logout,
                  label: 'Logout',
                  selected: false,
                  color: AppColors.error,
                  onTap: () {
                    Navigator.pop(context);
                    _confirmLogout(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            onPressed: () {
              context.read<AuthProvider>().signOut();
              Navigator.pop(context);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: selected ? c.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon,
            color: selected ? c : AppColors.textSecondary,
            size: 22),
        title: Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight:
                selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? c : color)),
        onTap: onTap,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        horizontalTitleGap: 0,
        dense: true,
      ),
    );
  }
}