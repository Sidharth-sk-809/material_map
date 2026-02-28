import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../logic/providers/search_provider.dart';
import '../../../logic/providers/location_provider.dart';
import '../../../main.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _repo = ProductRepository();
  late Future<List<InventoryItem>> _inventoryFuture;

  @override
  void initState() {
    super.initState();
    // Use real Firebase for inventory data
    _inventoryFuture = _repo.getInventoryForProduct(widget.product.id);
  }

  Color get _catColor {
    switch (widget.product.category) {
      case 'grocery': return AppTheme.groceryColor;
      case 'stationery': return AppTheme.stationaryColor;
      case 'vegetables': return AppTheme.vegetableColor;
      case 'household': return AppTheme.householdColor;
      case 'plumbing': return AppTheme.plumbingColor;
      default: return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: CustomScrollView(
        slivers: [
          // Product Image Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: _catColor,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: AppTheme.textPrimary, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: _catColor.withOpacity(0.1),
                child: (product.imageUrl?.isNotEmpty ?? false)
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(_categoryEmoji(), style: const TextStyle(fontSize: 80)),
                        ),
                      )
                    : Center(child: Text(_categoryEmoji(), style: const TextStyle(fontSize: 80))),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _catColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                product.category.toUpperCase(),
                                style: TextStyle(color: _catColor, fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.business_outlined, size: 14, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text('Brand: ${product.brand}',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                        if (product.unit != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.scale_outlined, size: 14, color: AppTheme.textSecondary),
                              const SizedBox(width: 4),
                              Text('Unit: ${product.unit}',
                                  style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ],
                        if (product.description != null && product.description!.isNotEmpty) ...[
                          const Divider(height: 20),
                          Text(product.description!,
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Availability Section
                  Text(
                    'Available at Nearby Stores',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  
                  // Radius Filter Buttons
                  Consumer<LocationProvider>(
                    builder: (context, locProvider, _) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _RadiusButton(
                              label: 'No Boundary',
                              isSelected: locProvider.selectedRadiusKm == null,
                              onTap: () => locProvider.setRadiusFilter(null),
                            ),
                            const SizedBox(width: 8),
                            _RadiusButton(
                              label: '2 km',
                              isSelected: locProvider.selectedRadiusKm == 2,
                              onTap: () => locProvider.setRadiusFilter(2),
                            ),
                            const SizedBox(width: 8),
                            _RadiusButton(
                              label: '5 km',
                              isSelected: locProvider.selectedRadiusKm == 5,
                              onTap: () => locProvider.setRadiusFilter(5),
                            ),
                            const SizedBox(width: 8),
                            _RadiusButton(
                              label: '10 km',
                              isSelected: locProvider.selectedRadiusKm == 10,
                              onTap: () => locProvider.setRadiusFilter(10),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Prices sorted from lowest to highest',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),

                  // Inventory List
                  Consumer<LocationProvider>(
                    builder: (context, locProvider, _) {
                      return FutureBuilder<List<InventoryItem>>(
                        future: _inventoryFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                          }
                          if (snapshot.hasError) {
                            return _ErrorCard();
                          }
                          final items = snapshot.data ?? [];
                          // Filter by radius
                          final filteredItems = items.where((item) {
                            return locProvider.isWithinRadius(
                              item.store?.latitude,
                              item.store?.longitude,
                            );
                          }).toList();
                          
                          if (items.isEmpty) {
                            return _UnavailableCard();
                          }
                          if (filteredItems.isEmpty) {
                            return _NoStoresInRadiusCard(
                              radius: locProvider.radiusLabel,
                            );
                          }
                          return Column(
                            children: filteredItems
                                .asMap()
                                .entries
                                .map((e) => _InventoryCard(
                                  item: e.value,
                                  rank: e.key,
                                  distance: locProvider.distanceTo(
                                    e.value.store?.latitude,
                                    e.value.store?.longitude,
                                  ),
                                  productUnit: product.unit,
                                ))
                                .toList(),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _categoryEmoji() {
    switch (widget.product.category) {
      case 'grocery': return '🛒';
      case 'stationery': return '📝';
      case 'vegetables': return '🥦';
      case 'household': return '🏠';
      case 'plumbing': return '🔧';
      default: return '📦';
    }
  }
}

class _InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final int rank;
  final double? distance;
  final String? productUnit;
  const _InventoryCard({
    required this.item, 
    required this.rank, 
    this.distance,
    this.productUnit,
  });

  @override
  Widget build(BuildContext context) {
    final isBest = rank == 0;
    final statusColor = item.stockStatus == StockStatus.inStock
        ? AppTheme.successGreen
        : item.stockStatus == StockStatus.lowStock
            ? AppTheme.warningOrange
            : AppTheme.errorRed;
    final statusLabel = item.stockStatus == StockStatus.inStock
        ? 'In Stock'
        : item.stockStatus == StockStatus.lowStock
            ? 'Low Stock'
            : 'Out of Stock';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isBest ? AppTheme.primaryColor : AppTheme.divider,
          width: isBest ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          if (isBest)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(13),
                  topRight: Radius.circular(13),
                ),
              ),
              child: const Center(
                child: Text(
                  '🏆  BEST PRICE',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Store Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(child: Text('🏪', style: TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 12),
                // Store Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.store?.name ?? 'Store ${item.storeId}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (item.store?.address != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.store!.address,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (distance != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '📍 ${distance! < 1 ? '${(distance! * 1000).round()}m' : '${distance!.toStringAsFixed(1)}km'}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(width: 6, height: 6,
                                    decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                                const SizedBox(width: 5),
                                Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          if (item.quantity > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '📦 ${item.quantity}${productUnit != null ? ' x $productUnit' : ''}',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${item.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isBest ? AppTheme.primaryColor : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.errorRed.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.error_outline, color: AppTheme.errorRed),
          SizedBox(width: 12),
          Text('Could not load inventory. Check your connection.'),
        ],
      ),
    );
  }
}

class _UnavailableCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          const Text('😕', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text('Not available at nearby stores', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('Try expanding your search area.', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _NoStoresInRadiusCard extends StatelessWidget {
  final String radius;
  const _NoStoresInRadiusCard({required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          const Text('🔍', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text('No stores within $radius', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('Try selecting a larger radius.', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _RadiusButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RadiusButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.divider,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
