import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/routes/routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/drawer_tile.dart';
import '../../widgets/confirmation_dialog.dart';

import '../../providers/inventory_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/transaction_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final authProvider = context.watch<AuthProvider>();

    return Drawer(
      backgroundColor: AppColors.backgroundColor,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + 24,
              bottom: 24,
              left: 24,
              right: 24,
            ),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.surfaceLight,
                    child: Text(
                      authProvider.currentUserName?.isNotEmpty == true ? authProvider.currentUserName![0].toUpperCase() : 'A',
                      style: const TextStyle(fontSize: 24, color: AppColors.whiteColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authProvider.currentUserName?.isEmpty ?? true ? 'Admin User' : authProvider.currentUserName!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authProvider.currentUserEmail?.isEmpty ?? true ? 'admin@stockflow.com' : authProvider.currentUserEmail!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Administrator',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                DrawerTile(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  isSelected: currentRoute == Routes.home,
                  onTap: () => Navigator.of(context).pushReplacementNamed(Routes.home),
                ),
                DrawerTile(
                  icon: Icons.inventory_2_rounded,
                  label: 'Inventory',
                  isSelected: currentRoute == Routes.inventory,
                  onTap: () => Navigator.of(context).pushReplacementNamed(Routes.inventory),
                ),
                DrawerTile(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'QR Scanner',
                  isSelected: currentRoute == Routes.scanner,
                  onTap: () => Navigator.of(context).pushReplacementNamed(Routes.scanner),
                ),
                DrawerTile(
                  icon: Icons.receipt_long_rounded,
                  label: 'Transactions',
                  isSelected: currentRoute == Routes.transactions,
                  onTap: () => Navigator.of(context).pushReplacementNamed(Routes.transactions),
                ),
                DrawerTile(
                  icon: Icons.bar_chart_rounded,
                  label: 'Reports',
                  isSelected: currentRoute == Routes.reports,
                  onTap: () => Navigator.of(context).pushReplacementNamed(Routes.reports),
                ),
                const Divider(color: AppColors.borderColor, height: 32),
                DrawerTile(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: currentRoute == Routes.profile,
                  onTap: () => Navigator.of(context).pushReplacementNamed(Routes.profile),
                ),
                DrawerTile(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  isSelected: currentRoute == Routes.settings,
                  onTap: () => Navigator.of(context).pushReplacementNamed(Routes.settings),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              iconColor: AppColors.errorColor,
              textColor: AppColors.errorColor,
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () async {
                final confirm = await ConfirmationDialog.show(
                  context: context,
                  title: 'Logout',
                  message: 'Are you sure you want to logout?',
                  confirmText: 'Logout',
                  isDestructive: true,
                );
                if (confirm == true && context.mounted) {
                  context.read<InventoryProvider>().clearData();
                  context.read<DashboardProvider>().clearData();
                  context.read<TransactionProvider>().clearData();
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed(Routes.login);
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
