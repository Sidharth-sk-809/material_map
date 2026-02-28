import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_model.dart';
import '../../../logic/providers/search_provider.dart';
import '../../../logic/providers/location_provider.dart';
import '../product/product_detail_screen.dart';
import '../../widgets/product_item_card.dart';

// Maps category to display metadata
const _catMeta = {
  'grocery':     {'emoji': '🛒', 'label': 'Grocery'},
  'vegetables':  {'emoji': '🥦', 'label': 'Vegetables'},
  'stationery':  {'emoji': '📝', 'label': 'Stationery'},
  'household':   {'emoji': '🏠', 'label': 'Household'},
  'plumbing':    {'emoji': '🔧', 'label': 'Plumbing'},
  'electronics': {'emoji': '💡', 'label': 'Electronics'},
};

const _catColor = {
  'grocery':     AppTheme.groceryColor,
  'vegetables':  AppTheme.vegetableColor,
  'stationery':  AppTheme.stationaryColor,
  'household':   AppTheme.householdColor,
  'plumbing':    AppTheme.plumbingColor,
  'electronics': AppTheme.electronicsColor,
};

class CategoryItemsScreen extends StatelessWidget {
  final String category;
  const CategoryItemsScreen({super.key, required this.category});

  Color get color => _catColor[category] ?? AppTheme.primaryColor;
  String get emoji => _catMeta[category]?['emoji'] ?? '📦';
  String get label => _catMeta[category]?['label'] ?? category;

  @override
  Widget build(BuildContext context) {
    final sp = context.read<SearchProvider>();

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: color,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withAlpha(220), color],
                  ),
                ),
              ),
            ),
          ),

          // Location banner
          SliverToBoxAdapter(
            child: _LocationBanner(),
          ),

          // Products Grid
          FutureBuilder<List<ProductModel>>(
            future: sp.getProductsByCategory(category),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No products found',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                );
              }

              final products = snapshot.data!;
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.58,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => ProductItemCard(
                      product: products[i],
                      categoryColor: color,
                      categoryEmoji: emoji,
                    ),
                    childCount: products.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LocationBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocationProvider>();
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Icon(
            loc.status == LocationStatus.ready
                ? Icons.location_on
                : Icons.location_searching,
            color: AppTheme.primaryColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              loc.status == LocationStatus.ready
                  ? 'Showing stores near you • ${loc.locationLabel}'
                  : loc.locationLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          if (loc.status == LocationStatus.loading)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor),
            ),
        ],
      ),
    );
  }
}
