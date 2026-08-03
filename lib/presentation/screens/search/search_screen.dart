import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/routes/routes.dart';
import '../../providers/inventory_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/empty_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = context.watch<InventoryProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Search', style: TextStyle(color: AppColors.whiteColor)),
        backgroundColor: AppColors.backgroundColor,
        iconTheme: const IconThemeData(color: AppColors.whiteColor),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBarWidget(
              autofocus: true,
              onChanged: (val) => inventoryProvider.searchProducts(val),
              onFilterTap: () => setState(() => _showFilters = !_showFilters),
            ),
          ),
          if (_showFilters)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sort By', style: TextStyle(color: AppColors.whiteColor, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSortChip('A-Z', inventoryProvider),
                      _buildSortChip('Z-A', inventoryProvider),
                      _buildSortChip('Highest Stock', inventoryProvider),
                      _buildSortChip('Lowest Stock', inventoryProvider),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: inventoryProvider.filteredProducts.isEmpty
                ? const EmptyWidget(
                    icon: Icons.search_off_rounded,
                    title: 'No Results Found',
                    subtitle: 'Try adjusting your search or filters.',
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
                        onTap: () => Navigator.of(context).pushNamed(Routes.productDetail, arguments: product.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, InventoryProvider provider) {
    final isSelected = provider.sortBy == label;
    return InkWell(
      onTap: () {
        provider.sortProducts(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gradient1 : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: const TextStyle(color: AppColors.whiteColor, fontSize: 12)),
      ),
    );
  }
}
