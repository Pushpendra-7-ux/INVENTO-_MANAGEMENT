import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/routes/routes.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/product_card.dart';
import '../../widgets/touchable_scale.dart';
import '../home/app_drawer.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  Widget _buildPeriodChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.gradient1 : AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.gradient1 : AppColors.borderColor,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.whiteColor : AppColors.subtitleText,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSalesTrendLineChart(DashboardProvider provider) {
    final data = provider.weeklySalesData;
    List<FlSpot> spots = [];
    double maxVal = 10;
    for (int i = 0; i < data.length; i++) {
      if (data[i] > maxVal) maxVal = data[i];
      spots.add(FlSpot(i.toDouble(), data[i]));
    }

    return Padding(
      padding: const EdgeInsets.only(right: 18, left: 12, top: 24, bottom: 12),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  int idx = val.toInt();
                  if (idx >= 0 && idx < days.length) {
                    return Text(days[idx], style: const TextStyle(color: AppColors.subtitleText, fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: maxVal * 1.2,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: AppColors.buttonGradient,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.gradient1.withValues(alpha: 0.3),
                    AppColors.gradient2.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final inventoryProvider = context.watch<InventoryProvider>();

    final lowStockProducts = inventoryProvider.products.where((p) => p.quantity > 0 && p.quantity <= 10).toList();
    final outOfStockProducts = inventoryProvider.products.where((p) => p.quantity == 0).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Reports & Analytics', style: TextStyle(color: AppColors.whiteColor, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.whiteColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildPeriodChip('Daily', false),
                const SizedBox(width: 8),
                _buildPeriodChip('Weekly', true),
                const SizedBox(width: 8),
                _buildPeriodChip('Monthly', false),
              ],
            ),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  DashboardCard(
                    title: 'Total Portfolio Value',
                    value: '\$${(dashboardProvider.stats['totalValue'] ?? 0.0).toStringAsFixed(0)}',
                    icon: Icons.attach_money_rounded,
                    iconBackgroundColor: AppColors.successColor,
                  ),
                  const SizedBox(width: 12),
                  DashboardCard(
                    title: 'Items Sold Today',
                    value: '${dashboardProvider.stats['soldToday'] ?? 0}',
                    icon: Icons.shopping_cart_rounded,
                    iconBackgroundColor: AppColors.gradient1,
                  ),
                  const SizedBox(width: 12),
                  DashboardCard(
                    title: 'Items Restocked Today',
                    value: '${dashboardProvider.stats['addedToday'] ?? 0}',
                    icon: Icons.add_business_rounded,
                    iconBackgroundColor: AppColors.gradient2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Sales Trend Curve'),
            const SizedBox(height: 16),
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor, width: 0.5),
              ),
              child: _buildSalesTrendLineChart(dashboardProvider),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Top Performing Products'),
            const SizedBox(height: 16),
            SizedBox(
              height: 190,
              child: inventoryProvider.products.isEmpty
                  ? const Center(child: Text('No inventory data', style: TextStyle(color: AppColors.subtitleText)))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: inventoryProvider.products.length < 6 ? inventoryProvider.products.length : 6,
                      itemBuilder: (context, index) {
                        final product = inventoryProvider.products[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: SizedBox(
                            width: 170,
                            child: ProductCard(
                              product: product,
                              onTap: () => Navigator.of(context).pushNamed(Routes.productDetail, arguments: product.id),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 24),
            SectionHeader(title: 'Low Stock Warnings (${lowStockProducts.length})'),
            const SizedBox(height: 16),
            if (lowStockProducts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('All products have adequate stock levels.', style: TextStyle(color: AppColors.subtitleText)),
              )
            else
              ...lowStockProducts.map((p) => TouchableScale(
                    onTap: () => Navigator.of(context).pushNamed(Routes.productDetail, arguments: p.id),
                    borderRadius: BorderRadius.circular(12),
                    glowColor: AppColors.warningColor,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.warningColor.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.cardColor,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.warning_amber_rounded, color: AppColors.warningColor),
                        title: Text(p.productName, style: const TextStyle(color: AppColors.whiteColor, fontWeight: FontWeight.bold)),
                        subtitle: Text('SKU: ${p.sku ?? "N/A"}', style: const TextStyle(color: AppColors.subtitleText, fontSize: 12)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warningColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('${p.quantity} left', style: const TextStyle(color: AppColors.warningColor, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                    ),
                  )),
            const SizedBox(height: 24),
            SectionHeader(title: 'Out of Stock (${outOfStockProducts.length})'),
            const SizedBox(height: 16),
            if (outOfStockProducts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('No products currently out of stock.', style: TextStyle(color: AppColors.subtitleText)),
              )
            else
              ...outOfStockProducts.map((p) => TouchableScale(
                    onTap: () => Navigator.of(context).pushNamed(Routes.productDetail, arguments: p.id),
                    borderRadius: BorderRadius.circular(12),
                    glowColor: AppColors.errorColor,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.errorColor.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.cardColor,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.error_outline_rounded, color: AppColors.errorColor),
                        title: Text(p.productName, style: const TextStyle(color: AppColors.whiteColor, fontWeight: FontWeight.bold)),
                        subtitle: Text('SKU: ${p.sku ?? "N/A"}', style: const TextStyle(color: AppColors.subtitleText, fontSize: 12)),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gradient1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => Navigator.of(context).pushNamed(Routes.addProduct, arguments: p),
                          child: const Text('Restock', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ),
                  )),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
