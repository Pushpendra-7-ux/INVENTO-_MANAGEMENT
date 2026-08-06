import '../../core/exceptions/exceptions.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetAllProducts {
  final ProductRepository repository;
  GetAllProducts(this.repository);

  Future<List<ProductEntity>> call() async {
    return await repository.getAllProducts();
  }
}

class GetProductById {
  final ProductRepository repository;
  GetProductById(this.repository);

  Future<ProductEntity?> call(String id) async {
    return await repository.getProductById(id);
  }
}

class GetProductByQrCode {
  final ProductRepository repository;
  GetProductByQrCode(this.repository);

  Future<ProductEntity?> call(String qrCode) async {
    return await repository.getProductByQrCode(qrCode);
  }
}

class AddProduct {
  final ProductRepository repository;
  AddProduct(this.repository);

  Future<void> call(ProductEntity product) async {
    if (product.qrCode != null && product.qrCode!.trim().isNotEmpty) {
      final qrExists = await repository.isQrCodeExists(product.qrCode!);
      if (qrExists) {
        throw const DuplicateException('QR Code already exists', 'qrCode');
      }
    }

    if (product.sku != null && product.sku!.trim().isNotEmpty) {
      final skuExists = await repository.isSkuExists(product.sku!);
      if (skuExists) {
        throw const DuplicateException('SKU already exists', 'sku');
      }
    }

    await repository.addProduct(product);
  }
}

class UpdateProduct {
  final ProductRepository repository;
  UpdateProduct(this.repository);

  Future<void> call(ProductEntity product) async {
    if (product.qrCode != null && product.qrCode!.trim().isNotEmpty) {
      final qrExists = await repository.isQrCodeExists(product.qrCode!, product.id);
      if (qrExists) {
        throw const DuplicateException('QR Code already exists', 'qrCode');
      }
    }

    if (product.sku != null && product.sku!.trim().isNotEmpty) {
      final skuExists = await repository.isSkuExists(product.sku!, product.id);
      if (skuExists) {
        throw const DuplicateException('SKU already exists', 'sku');
      }
    }

    await repository.updateProduct(product);
  }
}

class DeleteProduct {
  final ProductRepository repository;
  DeleteProduct(this.repository);

  Future<void> call(String id) async {
    await repository.deleteProduct(id);
  }
}

class SearchProducts {
  final ProductRepository repository;
  SearchProducts(this.repository);

  Future<List<ProductEntity>> call(String query) async {
    return await repository.searchProducts(query);
  }
}

class GetProductStats {
  final ProductRepository repository;
  GetProductStats(this.repository);

  Future<Map<String, dynamic>> call() async {
    return await repository.getProductStats();
  }
}

class CheckQrCodeExists {
  final ProductRepository repository;
  CheckQrCodeExists(this.repository);

  Future<bool> call(String qrCode, [String? excludeId]) async {
    return await repository.isQrCodeExists(qrCode, excludeId);
  }
}

class CheckSkuExists {
  final ProductRepository repository;
  CheckSkuExists(this.repository);

  Future<bool> call(String sku, [String? excludeId]) async {
    return await repository.isSkuExists(sku, excludeId);
  }
}
