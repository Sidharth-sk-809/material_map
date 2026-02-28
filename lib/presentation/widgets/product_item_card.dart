import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/product_model.dart';
import '../../logic/providers/search_provider.dart';
import '../../logic/providers/location_provider.dart';
import '../screens/product/product_detail_screen.dart';

/// Reusable card widget for displaying a product with top-3 store prices
/// 
/// Shows:
/// - Product image or emoji fallback
/// - Product name and unit
/// - Top 3 cheapest stores with prices and optional distance
class ProductItemCard extends StatelessWidget {
  final ProductModel product;
  final Color categoryColor;
  final String categoryEmoji;

  const ProductItemCard({
    super.key,
    required this.product,
    required this.categoryColor,
    required this.categoryEmoji,
  });

  @override
  Widget build(BuildContext context) {
    final sp = context.read<SearchProvider>();
    final loc = context.read<LocationProvider>();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / Emoji area
            Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: categoryColor.withAlpha(25),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: (product.imageUrl?.isNotEmpty ?? false)
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(
                            categoryEmoji,
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        categoryEmoji,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
            ),

            // Product info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: SizedBox(
                height: 140,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product.unit != null)
                      Text(
                        product.unit!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 9,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 5),
                    const Divider(height: 1, color: AppTheme.divider),
                    const SizedBox(height: 5),

                    // Top 3 price rows - using FutureBuilder
                    Expanded(
                      child: FutureBuilder<List<InventoryItem>>(
                        future: sp.getTop3Inventory(product.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          }
                          
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text(
                                'No prices',
                                style: TextStyle(fontSize: 9, color: AppTheme.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }

                          return SingleChildScrollView(
                            child: Column(
                              children: snapshot.data!.map((item) {
                                final dist = loc.distanceTo(
                                  item.store?.latitude,
                                  item.store?.longitude,
                                );
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: SizedBox(
                                    height: 32,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Text('🏪', style: TextStyle(fontSize: 11)),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.store?.name ?? 'Store',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: AppTheme.textSecondary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (dist != null)
                                                Text(
                                                  loc.formatDistance(dist),
                                                  style: const TextStyle(
                                                    fontSize: 8,
                                                    color: AppTheme.textSecondary,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        SizedBox(
                                          width: 45,
                                          child: Text(
                                            '₹${item.price.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: categoryColor,
                                            ),
                                            textAlign: TextAlign.right,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Map product names to their emoji representations
  String _getProductEmoji() {
    const emojis = {
      'Tomato': '🍅',
      'Potato': '🥔',
      'Onion': '🧅',
      'Carrot': '🥕',
      'Broccoli': '🥦',
      'Capsicum': '🫑',
      'Jasmine Rice': '🍚',
      'Cooking Oil': '🛢️',
      'Whole Wheat Atta': '🌾',
      'Toor Dal': '🫘',
      'Sugar': '🍬',
      'Salt': '🧂',
      'Classmate Notebook': '📒',
      'Reynolds Pen': '🖊️',
      'Drawing Pencils': '✏️',
      'Stapler': '📎',
      'Eraser': '🧹',
      'Scale / Ruler': '📏',
      'Surf Excel': '🧺',
      'Vim Dish Soap': '🧴',
      'Paper Towels': '🧻',
      'Trash Bags': '🗑️',
      'Chrome Faucet': '🚿',
      'Adjustable Wrench': '🔧',
      'PVC Pipe': '🔩',
      'Teflon Tape': '🧷',
      'LED Bulb 9W': '💡',
      'Extension Cord': '🔌',
      'USB-C Charger': '⚡',
      'AA Batteries': '🔋',
    };
    return emojis[product.name] ?? '📦';
  }
}
