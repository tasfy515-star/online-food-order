// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/restaurant_provider.dart';
import '../../../models/restaurant_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../home/widgets/restaurant_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<RestaurantModel> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  final List<String> _recentSearches = [
    'Biriyani', 'Burger', 'KFC', 'Pizza'
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() { _isSearching = true; _hasSearched = true; });
    final results = await context.read<RestaurantProvider>().searchRestaurants(query);
    if (mounted) setState(() { _results = results; _isSearching = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppStrings.searchHint,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                setState(() { _results = []; _hasSearched = false; });
              },
            )
                : null,
          ),
          onChanged: (v) {
            setState(() {});
            if (v.length > 2) _search(v);
          },
          onSubmitted: _search,
        ),
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : !_hasSearched
          ? _SearchSuggestions(
        categories: AppStrings.foodCategories,
        recentSearches: _recentSearches,
        onTap: (q) {
          _controller.text = q;
          _search(q);
        },
      )
          : _results.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off,
                size: 64, color: AppColors.textLight),
            const SizedBox(height: 16),
            Text(
              'No results for "${_controller.text}"',
              style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _results.length,
        itemBuilder: (ctx, i) => RestaurantCard(
          restaurant: _results[i],
          isHorizontal: false,
        ),
      ),
    );
  }
}

class _SearchSuggestions extends StatelessWidget {
  final List<String> categories;
  final List<String> recentSearches;
  final Function(String) onTap;

  const _SearchSuggestions({
    required this.categories,
    required this.recentSearches,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Searches',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recentSearches
                .map((s) => GestureDetector(
              onTap: () => onTap(s),
              child: Chip(
                label: Text(s),
                avatar: const Icon(Icons.history, size: 14),
                backgroundColor: Theme.of(context).cardColor,
              ),
            ))
                .toList(),
          ),
          const SizedBox(height: 24),
          const Text('Browse Categories',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories
                .map((cat) => GestureDetector(
              onTap: () => onTap(cat),
              child: Chip(
                label: Text(cat),
                backgroundColor:
                AppColors.primary.withOpacity(0.08),
                labelStyle:
                const TextStyle(color: AppColors.primary),
              ),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
