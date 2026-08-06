import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'core/services/db.dart';
import 'core/routes/routes.dart';
import 'core/theme/colors.dart';
import 'data/database/database_helper.dart';
import 'data/repositories/product_repository_impl.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'domain/usecases/product_usecases.dart';
import 'domain/usecases/transaction_usecases.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/dashboard_provider.dart';
import 'presentation/providers/inventory_provider.dart';
import 'presentation/providers/scanner_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/transaction_provider.dart';
import 'presentation/viewmodels/product_detail_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set the web database factory before anything else
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  
  final dbHelper = DatabaseHelper();
  
  // Initialize database — wrapped in try-catch so the app always starts
  try {
    await SqliteService.instance.database;
  } catch (e) {
    debugPrint('Database initialization error: $e');
  }
  
  final productRepository = ProductRepositoryImpl(dbHelper);
  final transactionRepository = TransactionRepositoryImpl(dbHelper);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductDetailViewModel()),
        ChangeNotifierProvider(create: (_) => InventoryProvider(
          getAllProducts: GetAllProducts(productRepository),
          addProduct: AddProduct(productRepository),
          updateProduct: UpdateProduct(productRepository),
          deleteProduct: DeleteProduct(productRepository),
          searchProducts: SearchProducts(productRepository),
          getProductByQrCode: GetProductByQrCode(productRepository),
        )),
        ChangeNotifierProvider(create: (_) => TransactionProvider(
          getAllTransactions: GetAllTransactions(transactionRepository),
          addTransaction: AddTransaction(transactionRepository),
          getProductTransactions: GetProductTransactions(transactionRepository),
          getTransactionsByType: GetTransactionsByType(transactionRepository),
        )),
        ChangeNotifierProvider(create: (_) => ScannerProvider(
          getProductByQrCode: GetProductByQrCode(productRepository),
          updateProduct: UpdateProduct(productRepository),
          addTransaction: AddTransaction(transactionRepository),
        )),
        ChangeNotifierProvider(create: (_) => DashboardProvider(
          getAllProducts: GetAllProducts(productRepository),
          getProductStats: GetProductStats(productRepository),
          getTransactionStats: GetTransactionStats(transactionRepository),
          getTopSellingProducts: GetTopSellingProducts(transactionRepository),
          getAllTransactions: GetAllTransactions(transactionRepository),
          getTransactionsByDateRange: GetTransactionsByDateRange(transactionRepository),
        )),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return MaterialApp(
      title: 'StockFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.backgroundColor,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.gradient1,
          secondary: AppColors.gradient2,
          surface: AppColors.cardColor,
        ),
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: Routes.splash,
      onGenerateRoute: Routes.onGenerateRoute,
    );
  }
}
