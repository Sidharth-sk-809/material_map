import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/product_model.dart';
import '../../../logic/providers/search_provider.dart';
import '../product/product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // If category was pre-selected from home, trigger search
    final sp = context.read<SearchProvider>();
    if (sp.selectedCategory != null && sp.searchState == SearchState.loaded) {
      // Already loaded via filterByCategory
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SearchProvider>();

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            sp.clearSearch();
            Navigator.pop(context);
          },
        ),
        title: Hero(
          tag: 'searchBar',
          child: Material(
            color: Colors.transparent,
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: 'Search products, brands...',
                hintStyle: const TextStyle(color: Colors.white60),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () {
                          _searchCtrl.clear();
                          sp.clearSearch();
                        },
                      )
                    : null,
              ),
              onChanged: (val) => sp.search(val),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category chips
          _CategoryChips(selectedCategory: sp.selectedCategory),
          // Results
          Expanded(child: _buildResults(sp)),
        ],
      ),
    );
  }

  Widget _buildResults(SearchProvider sp) {
    switch (sp.searchState) {
      case SearchState.idle:
        return _EmptyState(
          icon: Icons.search,
          title: 'Start Searching',
          subtitle: 'Type a product name or select a category above.',
        );
      case SearchState.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
      case SearchState.error:
        return _EmptyState(
          icon: Icons.error_outline,
          title: 'Something went wrong',
          subtitle: sp.error ?? 'Please try again.',
        );
      case SearchState.loaded:
        if (sp.results.isEmpty) {
          return _EmptyState(
            icon: Icons.search_off,
            title: 'No products found',
            subtitle: 'Try a different name or category.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: sp.results.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _ProductCard(product: sp.results[i]),
        );
    }
  }
}

class _CategoryChips extends StatelessWidget {
  final String? selectedCategory;
  const _CategoryChips({this.selectedCategory});

  @override
  Widget build(BuildContext context) {
    final categories = AppCategories.categories;
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          _Chip(label: 'All', isSelected: selectedCategory == null, onTap: () => context.read<SearchProvider>().clearSearch()),
          ...categories.map((cat) => _Chip(
                label: '${cat['icon']} ${cat['name']}',
                isSelected: selectedCategory == cat['id'],
                onTap: () => context.read<SearchProvider>().filterByCategory(cat['id'] as String),
                color: Color(cat['color'] as int),
              )),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _Chip({required this.label, required this.isSelected, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? c : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? c : AppTheme.divider),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor(product.category);
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: catColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: (product.imageUrl?.isNotEmpty ?? false)
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      child: Image.network(product.imageUrl!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported_outlined, color: Colors.grey)),
                    )
                  : Center(
                      child: Text(_categoryEmoji(product.category),
                          style: const TextStyle(fontSize: 32))),
            ),
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(product.brand,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.category.toUpperCase(),
                        style: TextStyle(
                          color: catColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'grocery': return AppTheme.groceryColor;
      case 'stationery': return AppTheme.stationaryColor;
      case 'vegetables': return AppTheme.vegetableColor;
      case 'household': return AppTheme.householdColor;
      case 'plumbing': return AppTheme.plumbingColor;
      default: return AppTheme.primaryColor;
    }
  }

  String _categoryEmoji(String category) {
    switch (category) {
      case 'grocery': return '🛒';
      case 'stationery': return '📝';
      case 'vegetables': return '🥦';
      case 'household': return '🏠';
      case 'plumbing': return '🔧';
      default: return '📦';
    }
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: AppTheme.textSecondary.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Text(subtitle,
                style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
