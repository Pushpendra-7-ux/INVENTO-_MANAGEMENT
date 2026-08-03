import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/routes/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/statistic_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/confirmation_dialog.dart';
import '../home/app_drawer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().fetchAllProducts();
      context.read<TransactionProvider>().fetchAllTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final inventoryProvider = context.watch<InventoryProvider>();
    final transactionProvider = context.watch<TransactionProvider>();

    final totalProducts = inventoryProvider.products.length;
    final totalTransactions = transactionProvider.allTransactions.length;

    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    final lastLoginStr = authProvider.lastLogin != null
        ? '${dateFormat.format(authProvider.lastLogin!)}, ${timeFormat.format(authProvider.lastLogin!)}'
        : 'Just Now';

    final createdStr = authProvider.accountCreatedDate != null
        ? dateFormat.format(authProvider.accountCreatedDate!)
        : 'Today';

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: AppColors.whiteColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.whiteColor),
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + 56, bottom: 32),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: AppColors.surfaceMedium,
                    child: Text(
                      authProvider.currentUserName?.isNotEmpty == true ? authProvider.currentUserName![0].toUpperCase() : 'A',
                      style: const TextStyle(fontSize: 38, color: AppColors.whiteColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  authProvider.currentUserName?.isEmpty ?? true ? 'Admin User' : authProvider.currentUserName!,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  authProvider.currentUserEmail?.isEmpty ?? true ? 'admin@stockflow.com' : authProvider.currentUserEmail!,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(authProvider.currentUserRole ?? 'Administrator',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StatisticCard(
                        label: 'Total Products',
                        value: '$totalProducts',
                        icon: Icons.inventory_2_rounded,
                        color: AppColors.gradient1,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatisticCard(
                        label: 'Transactions',
                        value: '$totalTransactions',
                        icon: Icons.receipt_long_rounded,
                        color: AppColors.gradient2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.access_time_rounded, color: AppColors.gradient1),
                        title: const Text('Last Login', style: TextStyle(color: AppColors.subtitleText)),
                        trailing: Text(lastLoginStr, style: const TextStyle(color: AppColors.whiteColor, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      const Divider(color: AppColors.borderColor),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today_rounded, color: AppColors.gradient2),
                        title: const Text('Account Registered', style: TextStyle(color: AppColors.subtitleText)),
                        trailing: Text(createdStr, style: const TextStyle(color: AppColors.whiteColor, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                GradientButton(
                  text: 'Sign Out Account',
                  onPressed: () async {
                    final confirm = await ConfirmationDialog.show(
                      context: context,
                      title: 'Logout',
                      message: 'Are you sure you want to log out of your account?',
                      confirmText: 'Sign Out',
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
