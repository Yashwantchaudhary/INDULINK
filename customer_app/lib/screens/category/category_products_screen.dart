import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../models/category.dart';
import '../../providers/product_provider.dart';
import '../product/product_detail_screen.dart';

/// Category products screen
class CategoryProductsScreen extends ConsumerStatefulWidget {
  final String categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryName,
  });

  @override
  ConsumerState<CategoryProductsScreen> createState() =>
      _CategoryProductsScreenState();
}

class _CategoryProductsScreenState
    extends ConsumerState<CategoryProductsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch products for this category
    Future.microtask(() {
      ref
          .read(productProvider.notifier)
          .fetchProductsByCategory(widget.categoryName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productState = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: productState.isLoading && productState.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : productState.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: () => ref
                      .read(productProvider.notifier)
                      .fetchProductsByCategory(widget.categoryName),
                  child: GridView.builder(
                    padding: AppConstants.paddingPage,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppConstants.spacing12,
                      mainAxisSpacing: AppConstants.spacing12,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: productState.products.length,
                    itemBuilder: (context, index) {
                      final product = productState.products[index];
                      return _buildProductCard(product, index);
                    },
                  ),
                ),
    );
  }

  Widget _buildProductCard(product, int index) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productId: product.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.grey.shade100,
                width: double.infinity,
                child: product.images.isNotEmpty
                    ? Image.network(
                        product.images[0],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Icon(
                          Icons.image,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                      )
                    : Icon(
                        Icons.image,
                        size: 48,
                        color: Colors.grey.shade300,
                      ),
              ),
            ),

            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: AppConstants.paddingAll12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Rs ${product.price.toStringAsFixed(0)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: AppConstants.durationNormal)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: AppConstants.durationNormal,
          delay: Duration(milliseconds: index * 50),
        );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: AppConstants.paddingPage,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 100,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: AppConstants.spacing24),
            Text(
              'No Products Found',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              'No products available in this category yet',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacing24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Browse Other Categories'),
            ),
          ],
        ),
      ),
    );
  }
}
