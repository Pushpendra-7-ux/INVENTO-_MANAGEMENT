class ProductEntity {
  final String id;
  final String userId;
  final String productName;
  final String? description;
  final String category;
  final double price;
  final int quantity;
  final String? qrCode;
  final String? sku;
  final String? supplier;
  final String? image;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductEntity({
    required this.id,
    this.userId = '',
    required this.productName,
    this.description,
    required this.category,
    required this.price,
    required this.quantity,
    this.qrCode,
    this.sku,
    this.supplier,
    this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  String get status {
    if (quantity == 0) return 'Out of Stock';
    if (quantity <= 10) return 'Low Stock'; // threshold is in constants.dart
    return 'In Stock';
  }

  ProductEntity copyWith({
    String? id,
    String? userId,
    String? productName,
    String? description,
    String? category,
    double? price,
    int? quantity,
    String? qrCode,
    String? sku,
    String? supplier,
    String? image,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      qrCode: qrCode ?? this.qrCode,
      sku: sku ?? this.sku,
      supplier: supplier ?? this.supplier,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ProductEntity &&
      other.id == id &&
      other.productName == productName &&
      other.description == description &&
      other.category == category &&
      other.price == price &&
      other.quantity == quantity &&
      other.qrCode == qrCode &&
      other.sku == sku &&
      other.supplier == supplier &&
      other.image == image &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      productName.hashCode ^
      description.hashCode ^
      category.hashCode ^
      price.hashCode ^
      quantity.hashCode ^
      qrCode.hashCode ^
      sku.hashCode ^
      supplier.hashCode ^
      image.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
}
