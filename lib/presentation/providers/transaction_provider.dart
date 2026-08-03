import 'package:flutter/material.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/transaction_usecases.dart';

class TransactionProvider extends ChangeNotifier {
  final GetAllTransactions _getAllTransactions;
  final AddTransaction _addTransaction;
  final GetProductTransactions _getProductTransactions;
  final GetTransactionsByType _getTransactionsByType;

  TransactionProvider({
    required GetAllTransactions getAllTransactions,
    required AddTransaction addTransaction,
    required GetProductTransactions getProductTransactions,
    required GetTransactionsByType getTransactionsByType,
  })  : _getAllTransactions = getAllTransactions,
        _addTransaction = addTransaction,
        _getProductTransactions = getProductTransactions,
        _getTransactionsByType = getTransactionsByType;

  List<TransactionEntity> _allTransactions = [];
  List<TransactionEntity> _filteredTransactions = [];
  
  String _selectedType = 'All';
  bool _isLoading = false;
  String? _errorMessage;

  List<TransactionEntity> get allTransactions => _allTransactions;
  List<TransactionEntity> get filteredTransactions => _filteredTransactions;
  String get selectedType => _selectedType;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearData() {
    _allTransactions = [];
    _filteredTransactions = [];
    _selectedType = 'All';
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchAllTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allTransactions = await _getAllTransactions();
      _applyFilter();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterByType(String type) async {
    _selectedType = type;
    if (type != 'All') {
      try {
        final results = await _getTransactionsByType(type);
        if (results.isNotEmpty) {
          _filteredTransactions = results;
          _filteredTransactions.sort((a, b) => b.date.compareTo(a.date));
          notifyListeners();
          return;
        }
      } catch (_) {}
    }
    _applyFilter();
  }

  void _applyFilter() {
    if (_selectedType == 'All') {
      _filteredTransactions = List.from(_allTransactions);
    } else {
      _filteredTransactions = _allTransactions
          .where((t) => t.transactionType == _selectedType)
          .toList();
    }
    
    // Sort newest first
    _filteredTransactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addTransaction(TransactionEntity transaction) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _addTransaction(transaction);
      await fetchAllTransactions();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<List<TransactionEntity>> getTransactionsForProduct(String productId) async {
    try {
      final transactions = await _getProductTransactions(productId);
      transactions.sort((a, b) => b.date.compareTo(a.date));
      return transactions;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }
}
