import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../providers/inventory_provider.dart';
import '../providers/dashboard_provider.dart';

class NotificationsSheet extends StatelessWidget {
  const NotificationsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const NotificationsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = context.watch<InventoryProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();

    final lowStockItems = inventoryProvider.products.where((p) => p.quantity <= 10).toList();
    final recentActivities = dashboardProvider.recentActivities;

    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.paddingOf(context).bottom + 20,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.subtitleText.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.notifications_active_rounded, color: AppColors.gradient1, size: 24),
              SizedBox(width: 10),
              Text(
                'Notifications & Alerts',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                if (lowStockItems.isEmpty && recentActivities.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_outline_rounded, color: AppColors.successColor, size: 48),
                        SizedBox(height: 12),
                        Text('All systems normal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('No inventory warnings or alerts at this time.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.subtitleText, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                if (lowStockItems.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('⚠️ Low Stock Warnings',
                      style: TextStyle(color: AppColors.warningColor, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  ...lowStockItems.map((p) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.warningColor.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.warningColor.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.warning_amber_rounded, color: AppColors.warningColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.productName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('Category: ${p.category} • SKU: ${p.sku ?? "N/A"}', style: const TextStyle(color: AppColors.subtitleText, fontSize: 11)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warningColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('${p.quantity} left', style: const TextStyle(color: AppColors.warningColor, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 16),
                ],

                if (recentActivities.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('📋 Recent System Activity',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  ...recentActivities.take(5).map((tx) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColor, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.history_rounded, color: AppColors.gradient1, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${tx.transactionType}: ${tx.quantity} units',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(tx.remarks?.isNotEmpty == true ? tx.remarks! : 'Logged transaction',
                                style: const TextStyle(color: AppColors.subtitleText, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Text('${tx.date.hour.toString().padLeft(2, "0")}:${tx.date.minute.toString().padLeft(2, "0")}',
                          style: const TextStyle(color: AppColors.subtitleText, fontSize: 11),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
