import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/confirmation_dialog.dart';
import '../home/app_drawer.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: AppColors.whiteColor)),
        backgroundColor: AppColors.backgroundColor,
        iconTheme: const IconThemeData(color: AppColors.whiteColor),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CustomCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Appearance', style: TextStyle(color: AppColors.gradient1, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Dark Mode', style: TextStyle(color: AppColors.whiteColor)),
                  subtitle: Text(themeProvider.isDarkMode ? 'Enabled' : 'Disabled', style: const TextStyle(color: AppColors.subtitleText)),
                  value: themeProvider.isDarkMode,
                  onChanged: (val) => themeProvider.toggleTheme(),
                  activeThumbColor: AppColors.gradient1,
                  activeTrackColor: AppColors.gradient1.withValues(alpha: 0.5),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CustomCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Database', style: TextStyle(color: AppColors.gradient1, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.gradient1),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Backup Database', style: TextStyle(color: AppColors.gradient1)),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Restore Database', style: TextStyle(color: AppColors.subtitleText)),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () async {
                    await ConfirmationDialog.show(
                      context: context,
                      title: 'Reset Data',
                      message: 'This will delete all products and transactions permanently.',
                      confirmText: 'Reset',
                      isDestructive: true,
                    );
                  },
                  child: const Text('Reset All Data', style: TextStyle(color: AppColors.errorColor)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CustomCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('About', style: TextStyle(color: AppColors.gradient1, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('App Name', style: TextStyle(color: AppColors.subtitleText)),
                  trailing: Text('StockFlow', style: TextStyle(color: AppColors.whiteColor, fontWeight: FontWeight.bold)),
                ),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Version', style: TextStyle(color: AppColors.subtitleText)),
                  trailing: Text('1.0.0', style: TextStyle(color: AppColors.whiteColor, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
