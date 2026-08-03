import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/routes/routes.dart';
import '../../../core/constants/constants.dart';
import '../../providers/inventory_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/loading_widget.dart';
import '../home/app_drawer.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().fetchAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = context.watch<InventoryProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: const Text('Inventory', style: TextStyle(color: AppColors.whiteColor)),
        iconTheme: const IconThemeData(color: AppColors.whiteColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => Navigator.of(context).pushNamed(Routes.search),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded, color: AppColors.gradient1),
            color: AppColors.cardColor,
            onSelected: (val) {
              inventoryProvider.sortProducts(val);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'newest', child: Text('Newest', style: TextStyle(color: AppColors.whiteColor))),
              const PopupMenuItem(value: 'alphabetical', child: Text('Alphabetical', style: TextStyle(color: AppColors.whiteColor))),
              const PopupMenuItem(value: 'highest_stock', child: Text('Highest Stock', style: TextStyle(color: AppColors.whiteColor))),
              const PopupMenuItem(value: 'lowest_stock', child: Text('Lowest Stock', style: TextStyle(color: AppColors.whiteColor))),
              const PopupMenuItem(value: 'price_high', child: Text('Price: High to Low', style: TextStyle(color: AppColors.whiteColor))),
              const PopupMenuItem(value: 'price_low', child: Text('Price: Low to High', style: TextStyle(color: AppColors.whiteColor))),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                CategoryChip(
                  label: 'All',
                  isSelected: inventoryProvider.selectedCategory == 'All' || inventoryProvider.selectedCategory.isEmpty,
                  onTap: () => inventoryProvider.filterByCategory('All'),
                ),
                ...K.categories.map((cat) => Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: CategoryChip(
                        label: cat,
                        isSelected: inventoryProvider.selectedCategory == cat,
                        onTap: () => inventoryProvider.filterByCategory(cat),
                      ),
                    )),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => inventoryProvider.fetchAllProducts(),
              child: inventoryProvider.isLoading
                  ? const LoadingWidget(message: 'Loading inventory...')
                  : inventoryProvider.filteredProducts.isEmpty
                      ? EmptyWidget(
                          icon: Icons.inventory_2_outlined,
                          title: 'No Products Found',
                          subtitle: 'Try adding a new product or changing filters.',
                          actionLabel: 'Add Product',
                          onAction: () => Navigator.of(context).pushNamed(Routes.addProduct),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.82,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                          itemCount: inventoryProvider.filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = inventoryProvider.filteredProducts[index];
                            return ProductCard(
                              product: product,
                              onTap: () => Navigator.of(context).pushNamed(
                                Routes.productDetail,
                                arguments: product.id,
                              ),
                              onEdit: () => Navigator.of(context).pushNamed(
                                Routes.addProduct,
                                arguments: product,
                              ),
                              onDelete: () {
                                inventoryProvider.deleteProduct(product.id);
                              },
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(Routes.addProduct),
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
