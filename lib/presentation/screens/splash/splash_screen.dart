import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/routes/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/transaction_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initSession();
  }

  Future<void> _initSession() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    try {
      final authProvider = context.read<AuthProvider>();
      final isLoggedIn = await authProvider.checkSession();

      if (!mounted) return;

      if (isLoggedIn) {
        try {
          await context.read<InventoryProvider>().fetchAllProducts();
          await context.read<DashboardProvider>().refreshDashboard();
          await context.read<TransactionProvider>().fetchAllTransactions();
        } catch (e) {
          debugPrint('Error loading initial data: $e');
        }
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(Routes.home);
      } else {
        Navigator.of(context).pushReplacementNamed(Routes.login);
      }
    } catch (e) {
      debugPrint('Error checking session on splash: $e');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(Routes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.inventory_2_rounded,
                size: 50,
                color: Colors.white,
              ),
            )
                .animate()
                .scale(
                  duration: 800.ms,
                  curve: Curves.bounceOut,
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                ),
            const SizedBox(height: 24),
            Text(
              'Welcome to',
              style: TextStyle(
                color: AppColors.subtitleText,
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
            const SizedBox(height: 8),
            ShaderMask(
              shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
              child: const Text(
                'StockFlow',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
            const SizedBox(height: 8),
            Text(
              'Smart Inventory Management',
              style: TextStyle(
                color: AppColors.subtitleText,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
