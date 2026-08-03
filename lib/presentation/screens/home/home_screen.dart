import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/routes/routes.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/notifications_sheet.dart';
import 'app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().fetchAllProducts();
      context.read<DashboardProvider>().refreshDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final inventoryProvider = context.watch<InventoryProvider>();
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.whiteColor),
        title: const Text('Dashboard', style: TextStyle(color: AppColors.whiteColor, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.whiteColor),
            onPressed: () => NotificationsSheet.show(context),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceLight,
              child: Text(
                authProvider.currentUserName?.isNotEmpty == true ? authProvider.currentUserName![0].toUpperCase() : 'A',
                style: const TextStyle(color: AppColors.whiteColor),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.gradient1,
        backgroundColor: AppColors.cardColor,
        onRefresh: () async {
          await dashboardProvider.refreshDashboard();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Fmt.greeting(),
                        style: const TextStyle(color: AppColors.subtitleText, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      GradientText(
                        authProvider.currentUserName ?? 'Admin User',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    DashboardCard(
                      title: 'Total Products',
                      value: '${dashboardProvider.stats['totalProducts'] ?? 0}',
                      icon: Icons.inventory_2_rounded,
                      iconBackgroundColor: AppColors.gradient1,
                    ),
                    const SizedBox(width: 12),
                    DashboardCard(
                      title: 'In Stock',
                      value: '${dashboardProvider.stats['inStock'] ?? 0}',
                      icon: Icons.check_circle_rounded,
                      iconBackgroundColor: AppColors.successColor,
                    ),
                    const SizedBox(width: 12),
                    DashboardCard(
                      title: 'Sold Today',
                      value: '${dashboardProvider.stats['soldToday'] ?? 0}',
                      icon: Icons.shopping_cart_rounded,
                      iconBackgroundColor: AppColors.gradient2,
                    ),
                    const SizedBox(width: 12),
                    DashboardCard(
                      title: 'Added Today',
                      value: '${dashboardProvider.stats['addedToday'] ?? 0}',
                      icon: Icons.add_business_rounded,
                      iconBackgroundColor: AppColors.infoColor,
                    ),
                    const SizedBox(width: 12),
                    DashboardCard(
                      title: 'Low Stock',
                      value: '${dashboardProvider.stats['lowStock'] ?? 0}',
                      icon: Icons.warning_amber_rounded,
                      iconBackgroundColor: AppColors.warningColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Weekly Sales Trend',
                actionText: 'Analytics',
                onActionTap: () => Navigator.of(context).pushNamed(Routes.reports),
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderColor, width: 0.5),
                ),
                child: _buildWeeklyBarChart(dashboardProvider),
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Recent Activities',
                actionText: 'See All',
                onActionTap: () => Navigator.of(context).pushNamed(Routes.transactions),
              ),
              const SizedBox(height: 16),
              if (dashboardProvider.recentActivities.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderColor, width: 0.5),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_rounded, color: AppColors.subtitleText, size: 48),
                      SizedBox(height: 12),
                      Text(
                        'No Recent Activities',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Your inventory transactions will appear here.\nAdd stock, sell products, or scan QR codes to get started.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.subtitleText, fontSize: 12, height: 1.5),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dashboardProvider.recentActivities.length,
                  itemBuilder: (context, index) {
                    final tx = dashboardProvider.recentActivities[index];
                    final prod = inventoryProvider.products
                        .where((p) => p.id == tx.productId)
                        .firstOrNull;
                    return TransactionTile(
                      transaction: tx,
                      productName: prod?.productName ?? 'Inventory Item',
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'fab_scanner',
            backgroundColor: AppColors.cardColor,
            onPressed: () => Navigator.of(context).pushNamed(Routes.scanner),
            child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.gradient1),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'fab_add',
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
        ],
      ),
    );
  }

  Widget _buildWeeklyBarChart(DashboardProvider provider) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final data = provider.weeklySalesData;
    double maxVal = 10;
    for (var v in data) {
      if (v > maxVal) maxVal = v;
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.cardColor,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${days[groupIndex]}: ${rod.toY.toInt()} sold',
                const TextStyle(color: AppColors.whiteColor, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(days[index], style: const TextStyle(color: AppColors.subtitleText, fontSize: 11)),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(data.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i],
                gradient: AppColors.buttonGradient,
                width: 14,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
    );
  }
}
