abstract final class Tables {
  static const databaseName = 'stockflow.db';
  static const databaseVersion = 2;

  static const colUserId = 'userId';

  // products
  static const productsTable = 'products';
  static const colId = 'id';
  static const colProductName = 'productName';
  static const colDescription = 'description';
  static const colCategory = 'category';
  static const colPrice = 'price';
  static const colQuantity = 'quantity';
  static const colQrCode = 'qrCode';
  static const colSku = 'sku';
  static const colSupplier = 'supplier';
  static const colImage = 'image';
  static const colCreatedAt = 'createdAt';
  static const colUpdatedAt = 'updatedAt';

  // transactions
  static const transactionsTable = 'transactions';
  static const colTransactionId = 'id';
  static const colProductId = 'productId';
  static const colTransactionType = 'transactionType';
  static const colTransactionQuantity = 'quantity';
  static const colTransactionDate = 'date';
  static const colRemarks = 'remarks';
  static const colUserName = 'userName';
}
