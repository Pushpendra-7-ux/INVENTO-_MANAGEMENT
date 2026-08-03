import 'package:flutter/material.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/login/login_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/inventory/inventory_screen.dart';
import '../../presentation/screens/add_product/add_product_screen.dart';
import '../../presentation/screens/product_detail/product_detail_screen.dart';
import '../../presentation/screens/scanner/scanner_screen.dart';
import '../../presentation/screens/transactions/transactions_screen.dart';
import '../../presentation/screens/reports/reports_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../domain/entities/product_entity.dart';

abstract final class Routes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const inventory = '/inventory';
  static const addProduct = '/add-product';
  static const productDetail = '/product-detail';
  static const scanner = '/scanner';
  static const transactions = '/transactions';
  static const reports = '/reports';
  static const settings = '/settings';
  static const profile = '/profile';
  static const search = '/search';

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return PageRouteBuilder(
          pageBuilder: (_, animation, __) => const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      case home:
        return _slideRoute(const HomeScreen());
      case inventory:
        return _slideRoute(const InventoryScreen());
      case addProduct:
        if (routeSettings.arguments is ProductEntity) {
          return _slideRoute(AddProductScreen(product: routeSettings.arguments as ProductEntity));
        } else if (routeSettings.arguments is String) {
          return _slideRoute(AddProductScreen(initialQrCode: routeSettings.arguments as String));
        }
        return _slideRoute(const AddProductScreen());
      case productDetail:
        return _slideRoute(ProductDetailScreen(productId: routeSettings.arguments as String));
      case scanner:
        return _slideRoute(const ScannerScreen());
      case transactions:
        return _slideRoute(const TransactionsScreen());
      case reports:
        return _slideRoute(const ReportsScreen());
      case settings:
        return _slideRoute(const SettingsScreen());
      case profile:
        return _slideRoute(const ProfileScreen());
      case search:
        return _slideRoute(const SearchScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }

  static PageRouteBuilder _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) {
        const begin = Offset(1.0, 0.0);
        final tween = Tween(begin: begin, end: Offset.zero).chain(CurveTween(curve: Curves.ease));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}
