import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getAllProducts();
  Future<ProductEntity?> getProductById(String id);
  Future<ProductEntity?> getProductByQrCode(String qrCode);
  Future<ProductEntity?> getProductBySku(String sku);
  Future<void> addProduct(ProductEntity product);
  Future<void> updateProduct(ProductEntity product);
  Future<void> deleteProduct(String id);
  Future<List<ProductEntity>> searchProducts(String query);
  Future<Map<String, dynamic>> getProductStats();
  Future<bool> isQrCodeExists(String qrCode, [String? excludeId]);
  Future<bool> isSkuExists(String sku, [String? excludeId]);
}
