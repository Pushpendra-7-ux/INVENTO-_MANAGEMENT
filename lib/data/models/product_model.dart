import '../../core/constants/tables.dart';
import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    super.userId = '',
    required super.productName,
    super.description,
    required super.category,
    required super.price,
    required super.quantity,
    super.qrCode,
    super.sku,
    super.supplier,
    super.image, // image can be file path or url
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map[Tables.colId] as String,
      userId: (map[Tables.colUserId] as String?) ?? '',
      productName: map[Tables.colProductName] as String,
      description: map[Tables.colDescription] as String?,
      category: map[Tables.colCategory] as String,
      price: (map[Tables.colPrice] as num).toDouble(),
      quantity: map[Tables.colQuantity] as int,
      qrCode: map[Tables.colQrCode] as String?,
      sku: map[Tables.colSku] as String?,
      supplier: map[Tables.colSupplier] as String?,
      image: map[Tables.colImage] as String?,
      createdAt: DateTime.parse(map[Tables.colCreatedAt] as String),
      updatedAt: DateTime.parse(map[Tables.colUpdatedAt] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Tables.colId: id,
      Tables.colUserId: userId,
      Tables.colProductName: productName,
      Tables.colDescription: description,
      Tables.colCategory: category,
      Tables.colPrice: price,
      Tables.colQuantity: quantity,
      Tables.colQrCode: qrCode,
      Tables.colSku: sku,
      Tables.colSupplier: supplier,
      Tables.colImage: image,
      Tables.colCreatedAt: createdAt.toIso8601String(),
      Tables.colUpdatedAt: updatedAt.toIso8601String(),
    };
  }

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      userId: entity.userId,
      productName: entity.productName,
      description: entity.description,
      category: entity.category,
      price: entity.price,
      quantity: entity.quantity,
      qrCode: entity.qrCode,
      sku: entity.sku,
      supplier: entity.supplier,
      image: entity.image,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
