import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_model.dart';

class DealDetailScreen extends StatelessWidget {
  final InventoryItem deal;
  final String productName;
  final String category;
  final String storeName;

  const DealDetailScreen({
    super.key,
    required this.deal,
    required this.productName,
    required this.category,
    required this.storeName,
  });

  Color get _categoryColor {
    switch (category) {
      case 'grocery': return AppTheme.groceryColor;
      case 'vegetables': return AppTheme.vegetableColor;
      case 'stationery': return AppTheme.stationaryColor;
      case 'household': return AppTheme.householdColor;
      case 'plumbing': return AppTheme.plumbingColor;
      case 'electronics': return AppTheme.electronicsColor;
      default: return AppTheme.primaryColor;
    }
  }

  String get _categoryEmoji {
    switch (category) {
      case 'grocery': return '🛒';
      case 'vegetables': return '🥕';
      case 'stationery': return '✏️';
      case 'household': return '🧹';
      case 'plumbing': return '🔧';
      case 'electronics': return '💻';
      default: return '📦';
    }
  }

  bool get _isDiscounted => deal.discountPercentage != null && deal.discountPercentage! > 0;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00');
    final dateFormatter = DateFormat('MMM d, yyyy');

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            backgroundColor: _categoryColor,
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
            title: Text(
              'Deal Details',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          
          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _categoryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _categoryColor, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _categoryEmoji,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          category.replaceFirst(
                            category[0],
                            category[0].toUpperCase(),
                          ),
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: _categoryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Product Name
                  Text(
                    productName,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Store Name
                  Row(
                    children: [
                      const Icon(Icons.store, size: 18, color: AppTheme.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        storeName,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Price Section
                  if (_isDiscounted)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Discount Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red, width: 2),
                          ),
                          child: Text(
                            '🎉 ${deal.discountPercentage?.toStringAsFixed(0)}% Discount',
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Pricing Comparison
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Original Price
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Original Price',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${formatter.format(deal.originalPrice ?? deal.price)}',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: Colors.grey,
                                    color: Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            // Arrow
                            Icon(
                              Icons.arrow_forward,
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),

                            // Discounted Price
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Offer Price',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${formatter.format(deal.price)}',
                                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                    color: Colors.green,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${formatter.format(deal.price)}',
                          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            color: AppTheme.primaryColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),

                  // Stock Status
                  Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppTheme.divider),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            deal.quantity > 5 ? Icons.check_circle : Icons.warning,
                            color: deal.quantity > 5 ? Colors.green : Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stock Availability',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${deal.quantity} units in stock',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Offer Validity
                  if (_isDiscounted && deal.offerValidUntil != null)
                    Card(
                      color: Colors.blue.withOpacity(0.05),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Offer Valid Until',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dateFormatter.format(deal.offerValidUntil!),
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Add to cart or buy now functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added $productName to cart at ₹${formatter.format(deal.price)}',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _categoryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.shopping_cart, size: 20),
                      label: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
