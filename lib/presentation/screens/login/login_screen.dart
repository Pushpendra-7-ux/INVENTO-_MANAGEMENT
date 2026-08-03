import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/colors.dart';
import '../../../core/routes/routes.dart';
import '../../../core/utils/snackbars.dart';
import '../../../core/utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_text.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../viewmodels/login_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginViewModel viewModel;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    viewModel = LoginViewModel();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    // Only pre-fill email if "Remember Me" was previously set — do NOT restore session
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('remembered_email');
      if (mounted && savedEmail != null && savedEmail.isNotEmpty) {
        emailController.text = savedEmail;
        viewModel.rememberMe = true;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(BuildContext context) async {
    viewModel.email = emailController.text.trim();
    viewModel.password = passwordController.text.trim();
    
    final authProvider = context.read<AuthProvider>();
    try {
      final success = await viewModel.validateAndLogin(authProvider, context);
      if (success && mounted) {
        // Clear previous user state & fetch new user data
        context.read<InventoryProvider>().clearData();
        context.read<DashboardProvider>().clearData();
        context.read<TransactionProvider>().clearData();

        await context.read<InventoryProvider>().fetchAllProducts();
        await context.read<DashboardProvider>().refreshDashboard();
        await context.read<TransactionProvider>().fetchAllTransactions();

        if (mounted) {
          Snackbars.showSuccess(context, 'Welcome back, ${authProvider.currentUserName}!');
          Navigator.of(context).pushReplacementNamed(Routes.home);
        }
      }
    } catch (e) {
      if (mounted) {
        Snackbars.showError(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  void _showForgotPasswordDialog() {
    final resetController = TextEditingController(text: emailController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email address below and we will send you instructions to reset your password.',
              style: TextStyle(color: AppColors.subtitleText, fontSize: 13),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: resetController,
              label: 'Account Email',
              hint: 'name@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.subtitleText)),
          ),
          GradientButton(
            width: 140,
            text: 'Send Reset',
            onPressed: () {
              final email = resetController.text.trim();
              final err = Validators.email(email);
              if (err != null) {
                Snackbars.showError(ctx, err);
                return;
              }
              Navigator.pop(ctx);
              Snackbars.showSuccess(context, 'Password reset link sent to $email!');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.gradient1.withValues(alpha: 0.2), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.gradient2.withValues(alpha: 0.15), Colors.transparent],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.inventory_2_rounded,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Welcome to',
                                    style: TextStyle(
                                      color: AppColors.subtitleText,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const GradientText(
                                    'StockFlow',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Smart Inventory Management',
                                    style: TextStyle(
                                      color: AppColors.subtitleText,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.cardColor.withValues(alpha: 0.9),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                              border: const Border(
                                top: BorderSide(color: AppColors.borderColor),
                                left: BorderSide(color: AppColors.borderColor),
                                right: BorderSide(color: AppColors.borderColor),
                              ),
                            ),
                            child: Form(
                              key: viewModel.formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomTextField(
                                    controller: emailController,
                                    label: 'Email Address',
                                    hint: 'name@gmail.com',
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon: const Icon(Icons.mail_rounded, color: AppColors.gradient1),
                                    validator: Validators.email,
                                    onSaved: (value) => viewModel.email = value ?? '',
                                  ),
                                  const SizedBox(height: 16),
                                  CustomTextField(
                                    controller: passwordController,
                                    label: 'Password',
                                    hint: 'Enter password',
                                    prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.gradient2),
                                    obscureText: viewModel.obscurePassword,
                                    validator: Validators.password,
                                    onSaved: (value) => viewModel.password = value ?? '',
                                    suffixIcon: TextButton(
                                      onPressed: () => viewModel.togglePasswordVisibility(() => setState(() {})),
                                      child: Text(
                                        viewModel.obscurePassword ? 'Show' : 'Hide',
                                        style: const TextStyle(color: AppColors.gradient1, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: viewModel.rememberMe,
                                        onChanged: (value) => viewModel.toggleRememberMe(value, () => setState(() {})),
                                        activeColor: AppColors.gradient1,
                                      ),
                                      const Text(
                                        'Remember Me',
                                        style: TextStyle(color: AppColors.whiteColor, fontSize: 14),
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: _showForgotPasswordDialog,
                                        child: const GradientText(
                                          'Forgot Password?',
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  GradientButton(
                                    text: 'Sign In →',
                                    isLoading: authProvider.isLoading,
                                    onPressed: () => _handleLogin(context),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
