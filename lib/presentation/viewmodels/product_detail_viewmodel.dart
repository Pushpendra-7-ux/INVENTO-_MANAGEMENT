import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/inventory_provider.dart';
import '../providers/transaction_provider.dart';
import '../../core/constants/constants.dart';
import 'package:uuid/uuid.dart';

class ProductDetailViewModel extends ChangeNotifier {
  ProductEntity? _product;
  List<TransactionEntity> _productTransactions = [];
  bool _isLoading = false;

  ProductEntity? get product => _product;
  List<TransactionEntity> get productTransactions => _productTransactions;
  bool get isLoading => _isLoading;

  /// Loads product and its transaction history
  Future<void> loadProduct(String productId, InventoryProvider inventoryProvider, TransactionProvider transactionProvider) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Find product in existing state or fetch via provider (assuming products are already fetched in InventoryProvider)
      _product = inventoryProvider.products.firstWhere((p) => p.id == productId);
      _productTransactions = await transactionProvider.getTransactionsForProduct(productId);
    } catch (e) {
      _product = null;
      _productTransactions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sells a specified quantity of the product
  Future<bool> sellProduct(int qty, String? remarks, InventoryProvider inventoryProvider, TransactionProvider transactionProvider, {String userName = K.mockUserName}) async {
    if (_product == null || qty <= 0 || _product!.quantity < qty) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedProduct = _product!.copyWith(
        quantity: _product!.quantity - qty,
        updatedAt: DateTime.now(),
      );

      await inventoryProvider.updateProduct(updatedProduct);

      final transaction = TransactionEntity(
        id: const Uuid().v4(),
        productId: _product!.id,
        transactionType: K.transactionSold,
        quantity: qty,
        date: DateTime.now(),
        remarks: remarks,
        userName: userName,
      );

      await transactionProvider.addTransaction(transaction);
      
      // Update local state
      _product = updatedProduct;
      _productTransactions = await transactionProvider.getTransactionsForProduct(_product!.id);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Adds stock for the product
  Future<bool> addStock(int qty, String? remarks, InventoryProvider inventoryProvider, TransactionProvider transactionProvider, {String userName = K.mockUserName}) async {
    if (_product == null || qty <= 0) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedProduct = _product!.copyWith(
        quantity: _product!.quantity + qty,
        updatedAt: DateTime.now(),
      );

      await inventoryProvider.updateProduct(updatedProduct);

      final transaction = TransactionEntity(
        id: const Uuid().v4(),
        productId: _product!.id,
        transactionType: K.transactionAdded,
        quantity: qty,
        date: DateTime.now(),
        remarks: remarks,
        userName: userName,
      );

      await transactionProvider.addTransaction(transaction);
      
      // Update local state
      _product = updatedProduct;
      _productTransactions = await transactionProvider.getTransactionsForProduct(_product!.id);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Deletes the product completely
  Future<bool> deleteProduct(InventoryProvider inventoryProvider, TransactionProvider transactionProvider, {String userName = K.mockUserName}) async {
    if (_product == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // First, optionally record a deletion transaction (though the product won't exist anymore)
      final transaction = TransactionEntity(
        id: const Uuid().v4(),
        productId: _product!.id,
        transactionType: K.transactionDeleted,
        quantity: _product!.quantity, // remaining quantity that was deleted
        date: DateTime.now(),
        remarks: 'Product Deleted',
        userName: userName,
      );
      await transactionProvider.addTransaction(transaction);

      // Delete product
      await inventoryProvider.deleteProduct(_product!.id);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Refreshes the current product data
  Future<void> refresh(InventoryProvider inventoryProvider, TransactionProvider transactionProvider) async {
    if (_product != null) {
      await loadProduct(_product!.id, inventoryProvider, transactionProvider);
    }
  }
}
