import 'package:flutter/material.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/product_usecases.dart';
import '../../domain/usecases/transaction_usecases.dart';
import '../../core/constants/constants.dart';

class DashboardProvider extends ChangeNotifier {
  final GetAllProducts _getAllProducts;
  final GetProductStats _getProductStats;
  final GetTransactionStats _getTransactionStats;
  final GetTopSellingProducts _getTopSellingProducts;
  final GetAllTransactions _getAllTransactions;
  final GetTransactionsByDateRange _getTransactionsByDateRange;

  DashboardProvider({
    required GetAllProducts getAllProducts,
    required GetProductStats getProductStats,
    required GetTransactionStats getTransactionStats,
    required GetTopSellingProducts getTopSellingProducts,
    required GetAllTransactions getAllTransactions,
    required GetTransactionsByDateRange getTransactionsByDateRange,
  })  : _getAllProducts = getAllProducts,
        _getProductStats = getProductStats,
        _getTransactionStats = getTransactionStats,
        _getTopSellingProducts = getTopSellingProducts,
        _getAllTransactions = getAllTransactions,
        _getTransactionsByDateRange = getTransactionsByDateRange;

  Map<String, dynamic> _stats = {
    'totalProducts': 0,
    'inStock': 0,
    'soldToday': 0,
    'addedToday': 0,
    'lowStock': 0,
    'outOfStock': 0,
    'totalValue': 0.0,
  };

  List<double> _weeklySalesData = List.filled(7, 0.0);
  Map<String, double> _stockDistribution = {};
  List<TransactionEntity> _recentActivities = [];
  List<Map<String, dynamic>> _topSellingProducts = [];

  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic> get stats => _stats;
  List<double> get weeklySalesData => _weeklySalesData;
  Map<String, double> get stockDistribution => _stockDistribution;
  List<TransactionEntity> get recentActivities => _recentActivities;
  List<Map<String, dynamic>> get topSellingProducts => _topSellingProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearData() {
    _stats = {
      'totalProducts': 0,
      'inStock': 0,
      'soldToday': 0,
      'addedToday': 0,
      'lowStock': 0,
      'outOfStock': 0,
      'totalValue': 0.0,
    };
    _weeklySalesData = List.filled(7, 0.0);
    _stockDistribution = {};
    _recentActivities = [];
    _topSellingProducts = [];
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> refreshDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final productStats = await _getProductStats();

      final now = DateTime.now();
      // TODO: extract date range helpers to core/utils
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
      await _getTransactionStats(startOfDay, endOfDay);
      final todayTransactions = await _getTransactionsByDateRange(startOfDay, endOfDay);

      int soldToday = 0;
      int addedToday = 0;

      for (var t in todayTransactions) {
        if (t.transactionType == K.transactionSold) {
          soldToday += t.quantity;
        } else if (t.transactionType == K.transactionAdded) {
          addedToday += t.quantity;
        }
      }

      _stats = {
        'totalProducts': productStats['totalProducts'] ?? 0,
        'inStock': productStats['totalQuantity'] ?? 0,
        'lowStock': productStats['lowStockCount'] ?? 0,
        'outOfStock': productStats['outOfStockCount'] ?? 0,
        'totalValue': productStats['totalValue'] ?? 0.0,
        'soldToday': soldToday,
        'addedToday': addedToday,
      };

      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      final weekTransactions = await _getTransactionsByDateRange(startOfWeekDate, endOfDay);

      List<double> weekData = List.filled(7, 0.0);
      for (var t in weekTransactions) {
        if (t.transactionType == K.transactionSold) {
          int dayIndex = t.date.weekday - 1;
          weekData[dayIndex] += t.quantity.toDouble();
        }
      }
      _weeklySalesData = weekData;

      final allProducts = await _getAllProducts();
      Map<String, double> distribution = {};
      for (var p in allProducts) {
        if (p.quantity > 0) {
          distribution[p.category] = (distribution[p.category] ?? 0) + p.quantity;
        }
      }
      _stockDistribution = distribution;

      final allTransactions = await _getAllTransactions();
      allTransactions.sort((a, b) => b.date.compareTo(a.date));
      _recentActivities = allTransactions.take(10).toList();

      _topSellingProducts = await _getTopSellingProducts(5);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
