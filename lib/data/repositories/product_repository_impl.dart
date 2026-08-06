import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../database/database_helper.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final DatabaseHelper databaseHelper;

  ProductRepositoryImpl(this.databaseHelper);

  @override
  Future<void> addProduct(ProductEntity product) async {
    final model = ProductModel.fromEntity(product);
    await databaseHelper.insertProduct(model);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await databaseHelper.deleteProduct(id);
  }

  @override
  Future<List<ProductEntity>> getAllProducts() async {
    // Copy into List<ProductEntity> so callers aren't stuck with List<ProductModel> at runtime
    return List<ProductEntity>.from(await databaseHelper.getAllProducts());
  }

  @override
  Future<ProductEntity?> getProductById(String id) async {
    return await databaseHelper.getProductById(id);
  }

  @override
  Future<ProductEntity?> getProductByQrCode(String qrCode) async {
    return await databaseHelper.getProductByQrCode(qrCode);
  }

  @override
  Future<ProductEntity?> getProductBySku(String sku) async {
    return await databaseHelper.getProductBySku(sku);
  }

  @override
  Future<Map<String, dynamic>> getProductStats() async {
    return await databaseHelper.getProductStats();
  }

  @override
  Future<bool> isQrCodeExists(String qrCode, [String? excludeId]) async {
    if (qrCode.trim().isEmpty) return false;
    final product = await databaseHelper.getProductByQrCode(qrCode);
    if (product == null) return false;
    if (excludeId != null && product.id == excludeId) return false;
    return true;
  }

  @override
  Future<bool> isSkuExists(String sku, [String? excludeId]) async {
    if (sku.trim().isEmpty) return false;
    final product = await databaseHelper.getProductBySku(sku);
    if (product == null) return false;
    if (excludeId != null && product.id == excludeId) return false;
    return true;
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    return List<ProductEntity>.from(await databaseHelper.searchProducts(query));
  }

  @override
  Future<void> updateProduct(ProductEntity product) async {
    final model = ProductModel.fromEntity(product);
    await databaseHelper.updateProduct(model);
  }
}
