import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/product_usecases.dart';

class InventoryProvider extends ChangeNotifier {
  final GetAllProducts _getAllProducts;
  final AddProduct _addProduct;
  final UpdateProduct _updateProduct;
  final DeleteProduct _deleteProduct;
  final SearchProducts _searchProductsUseCase;
  final GetProductByQrCode _getProductByQrCode;

  InventoryProvider({
    required GetAllProducts getAllProducts,
    required AddProduct addProduct,
    required UpdateProduct updateProduct,
    required DeleteProduct deleteProduct,
    required SearchProducts searchProducts,
    required GetProductByQrCode getProductByQrCode,
  })  : _getAllProducts = getAllProducts,
        _addProduct = addProduct,
        _updateProduct = updateProduct,
        _deleteProduct = deleteProduct,
        _searchProductsUseCase = searchProducts,
        _getProductByQrCode = getProductByQrCode;

  List<ProductEntity> _products = [];
  List<ProductEntity> _filteredProducts = [];

  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortBy = 'newest';

  bool _isLoading = false;
  String? _errorMessage;

  List<ProductEntity> get products => _products;
  List<ProductEntity> get filteredProducts => _filteredProducts;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get sortBy => _sortBy;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearData() {
    _products = [];
    _filteredProducts = [];
    _searchQuery = '';
    _selectedCategory = 'All';
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchAllProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _getAllProducts();
      _applyFilters();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // TODO: Add pagination for large inventories

  Future<void> addProduct(ProductEntity product) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _addProduct(product);
      await fetchAllProducts();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProduct(ProductEntity product) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _updateProduct(product);
      await fetchAllProducts();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _deleteProduct(id);
      await fetchAllProducts();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    if (query.trim().isNotEmpty) {
      try {
        final results = await _searchProductsUseCase(query);
        if (results.isNotEmpty) {
          _filteredProducts = results;
          notifyListeners();
          return;
        }
      } catch (_) {}
    }
    _applyFilters();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void sortProducts(String sortByOption) {
    if (_sortBy == sortByOption) return;
    _sortBy = sortByOption;
    _applyFilters();
  }

  Future<ProductEntity?> getProductByQrCode(String qrCode) async {
    try {
      return await _getProductByQrCode(qrCode);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> refreshProducts() async => fetchAllProducts();

  void _applyFilters() {
    var result = List<ProductEntity>.from(_products);

    if (_selectedCategory != 'All') {
      result = result.where((p) => p.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((p) {
        return p.productName.toLowerCase().contains(q) ||
            (p.sku?.toLowerCase().contains(q) ?? false) ||
            (p.category.toLowerCase().contains(q));
      }).toList();
    }

    switch (_sortBy) {
      case 'newest':
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'highest_stock':
        result.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      case 'lowest_stock':
        result.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case 'alphabetical':
        result.sort((a, b) => a.productName.toLowerCase().compareTo(b.productName.toLowerCase()));
        break;
      case 'price_high':
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'price_low':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
    }

    _filteredProducts = result;
    notifyListeners();
  }
}
