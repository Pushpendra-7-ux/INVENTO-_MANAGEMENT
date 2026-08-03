import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/product_usecases.dart';
import '../../domain/usecases/transaction_usecases.dart';
import 'package:uuid/uuid.dart';

class ScannerProvider extends ChangeNotifier {
  final GetProductByQrCode _getProductByQrCode;
  final UpdateProduct _updateProduct;
  final AddTransaction _addTransaction;

  ScannerProvider({
    required GetProductByQrCode getProductByQrCode,
    required UpdateProduct updateProduct,
    required AddTransaction addTransaction,
  })  : _getProductByQrCode = getProductByQrCode,
        _updateProduct = updateProduct,
        _addTransaction = addTransaction;

  String? _scannedCode;
  ProductEntity? _scannedProduct;
  bool _isProcessing = false;
  String? _errorMessage;

  String? get scannedCode => _scannedCode;
  ProductEntity? get scannedProduct => _scannedProduct;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;

  /// Process the scanned code to find the associated product
  Future<void> processScannedCode(String code) async {
    _isProcessing = true;
    _scannedCode = code;
    _scannedProduct = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final product = await _getProductByQrCode(code);
      if (product != null) {
        _scannedProduct = product;
      } else {
        _errorMessage = 'No product found for QR code: $code';
      }
    } catch (e) {
      _errorMessage = 'Error looking up product: ${e.toString()}';
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Perform a stock action on the scanned product
  Future<bool> performAction(String actionType, int quantity, String? remarks, {String userName = 'Admin'}) async {
    if (_scannedProduct == null) {
      _errorMessage = 'No product selected';
      notifyListeners();
      return false;
    }

    if (quantity <= 0) {
      _errorMessage = 'Quantity must be greater than 0';
      notifyListeners();
      return false;
    }

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      int newQuantity = _scannedProduct!.quantity;
      
      // Calculate new quantity based on action type
      if (actionType == 'Stock Added' || actionType == 'Returned') {
        newQuantity += quantity;
      } else if (actionType == 'Sold' || actionType == 'Damaged') {
        if (newQuantity < quantity) {
          throw Exception('Insufficient stock. Current stock: $newQuantity');
        }
        newQuantity -= quantity;
      } else {
        throw Exception('Unknown action type: $actionType');
      }

      // Update product
      final updatedProduct = _scannedProduct!.copyWith(
        quantity: newQuantity,
        updatedAt: DateTime.now(),
      );
      await _updateProduct(updatedProduct);

      // Record transaction
      final transaction = TransactionEntity(
        id: const Uuid().v4(),
        productId: _scannedProduct!.id,
        transactionType: actionType,
        quantity: quantity,
        date: DateTime.now(),
        remarks: remarks,
        userName: userName,
      );
      await _addTransaction(transaction);

      // Update local state
      _scannedProduct = updatedProduct;
      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  /// Clears the current scan state
  void clearScan() {
    _scannedCode = null;
    _scannedProduct = null;
    _errorMessage = null;
    _isProcessing = false;
    notifyListeners();
  }
}
