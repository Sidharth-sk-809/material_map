import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../logic/providers/auth_provider.dart' as auth;
import '../../../logic/providers/location_provider.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/models/product_model.dart';
import '../search/search_screen.dart';
import '../auth/login_screen.dart';
import '../category/category_items_screen.dart';
import '../location/location_setup_screen.dart';
import '../deals/deal_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize location detection after UI is built
    Future.microtask(() {
      context.read<LocationProvider>().initializeIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProv = context.read<auth.AuthProvider>();
    final loc = context.watch<LocationProvider>();

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.logout_outlined, color: Colors.white),
                onPressed: () async {
                  await authProv.signOut();
                  if (context.mounted) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()));
                  }
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Material Map',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  // Location chip
                  Row(
                    children: [
                      Icon(
                        loc.status == LocationStatus.ready
                            ? Icons.location_on
                            : Icons.location_searching,
                        color: Colors.white70,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        loc.status == LocationStatus.loading
                            ? 'Detecting location...'
                            : loc.locationLabel,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF004D40), Color(0xFF00897B)],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Set Radius Section
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LocationSetupScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                      ),
                      child: Consumer<LocationProvider>(
                        builder: (context, locProvider, _) {
                          return Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Set your radius',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppTheme.textSecondary,
                                            fontSize: 12,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Current: ${locProvider.radiusLabel}',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: AppTheme.primaryColor,
                                size: 16,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SearchBar(),
                  const SizedBox(height: 24),
                  Text('Shop by Category',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 14),
                  _CategoryGrid(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Nearby Deals',
                          style: Theme.of(context).textTheme.titleLarge),
                      TextButton(onPressed: () {}, child: const Text('See All')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _NearbyDealsRow(),
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

// ── Search Bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SearchScreen()),
      ),
      child: Hero(
        tag: 'searchBar',
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withAlpha(30),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppTheme.primaryColor, size: 22),
                const SizedBox(width: 12),
                Text(
                  'Search for a product or brand...',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Category Grid ────────────────────────────────────────────────────────────

class _CategoryGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final categories = AppCategories.categories;
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.88,
      ),
      itemCount: categories.length,
      itemBuilder: (_, i) {
        final cat = categories[i];
        final color = Color(cat['color'] as int);
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    CategoryItemsScreen(category: cat['id'] as String),
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withAlpha(60), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(cat['icon'] as String,
                        style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  cat['name'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Nearby Deals ─────────────────────────────────────────────────────────────

class _NearbyDealsRow extends StatefulWidget {
  const _NearbyDealsRow();

  @override
  State<_NearbyDealsRow> createState() => _NearbyDealsRowState();
}

class _NearbyDealsRowState extends State<_NearbyDealsRow> {
  late Future<List<_DealItem>> _dealsFuture;
  final _repo = ProductRepository();

  @override
  void initState() {
    super.initState();
    _dealsFuture = _loadDeals();
  }

  Future<List<_DealItem>> _loadDeals() async {
    try {
      final products = await _repo.getAllProducts();
      final deals = <_DealItem>[];

      for (final product in products.take(8)) {
        try {
          final inventory = await _repo.getInventoryForProduct(product.id);
          if (inventory.isNotEmpty) {
            deals.add(_DealItem(
              title: product.name,
              storeName: inventory[0].store?.name ?? 'Store',
              price: inventory[0].price,
              category: product.category,
              emoji: _getCategoryEmoji(product.category),
              inventory: inventory[0],  // Pass the full inventory item
            ));
          }
        } catch (_) {}
        if (deals.length >= 6) break;
      }

      return deals;
    } catch (_) {
      return [];
    }
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'grocery': return '🛒';
      case 'vegetables': return '🥦';
      case 'stationery': return '📝';
      case 'household': return '🏠';
      case 'plumbing': return '🔧';
      case 'electronics': return '💡';
      default: return '📦';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'grocery': return AppTheme.groceryColor;
      case 'vegetables': return AppTheme.vegetableColor;
      case 'stationery': return AppTheme.stationaryColor;
      case 'household': return AppTheme.householdColor;
      case 'plumbing': return const Color(0xFF1976D2);
      case 'electronics': return const Color(0xFFF57C00);
      default: return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_DealItem>>(
      future: _dealsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 175,
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(height: 175);
        }

        final deals = snapshot.data!;
        return SizedBox(
          height: 175,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: deals.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final deal = deals[i];
              final color = _getCategoryColor(deal.category);
              return _DealCard(
                deal: deal,
                color: color,
              );
            },
          ),
        );
      },
    );
  }
}

class _DealItem {
  final String title;
  final String storeName;
  final double price;
  final String category;
  final String emoji;
  final InventoryItem inventory;  // Full inventory item with offer data

  _DealItem({
    required this.title,
    required this.storeName,
    required this.price,
    required this.category,
    required this.emoji,
    required this.inventory,
  });
}

class _DealCard extends StatelessWidget {
  final _DealItem deal;
  final Color color;

  const _DealCard({required this.deal, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DealDetailScreen(
              deal: deal.inventory,
              productName: deal.title,
              category: deal.category,
              storeName: deal.storeName,
            ),
          ),
        );
      },
      child: Container(
        width: 145,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 65,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Center(child: Text(deal.emoji, style: const TextStyle(fontSize: 28))),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Discount Badge
                  if (deal.inventory.discountPercentage != null && deal.inventory.discountPercentage! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        '-${deal.inventory.discountPercentage?.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 7,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (deal.inventory.discountPercentage != null && deal.inventory.discountPercentage! > 0)
                    const SizedBox(height: 2),
                  Text(deal.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: AppTheme.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 1),
                  Text(deal.storeName,
                      style: const TextStyle(
                          fontSize: 9, color: AppTheme.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('₹${deal.price.toStringAsFixed(0)}',
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                      const Spacer(),
                      Icon(Icons.arrow_forward_ios, size: 8, color: color),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
