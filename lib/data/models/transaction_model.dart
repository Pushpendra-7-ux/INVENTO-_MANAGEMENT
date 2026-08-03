import '../../core/constants/tables.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    super.userId = '',
    required super.productId,
    required super.transactionType,
    required super.quantity,
    required super.date,
    super.remarks,
    super.userName,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map[Tables.colTransactionId] as String,
      userId: (map[Tables.colUserId] as String?) ?? '',
      productId: map[Tables.colProductId] as String,
      transactionType: map[Tables.colTransactionType] as String,
      quantity: map[Tables.colTransactionQuantity] as int,
      date: DateTime.parse(map[Tables.colTransactionDate] as String),
      remarks: map[Tables.colRemarks] as String?,
      userName: map[Tables.colUserName] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Tables.colTransactionId: id,
      Tables.colUserId: userId,
      Tables.colProductId: productId,
      Tables.colTransactionType: transactionType,
      Tables.colTransactionQuantity: quantity,
      Tables.colTransactionDate: date.toIso8601String(),
      Tables.colRemarks: remarks,
      Tables.colUserName: userName,
    };
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      userId: entity.userId,
      productId: entity.productId,
      transactionType: entity.transactionType,
      quantity: entity.quantity,
      date: entity.date,
      remarks: entity.remarks,
      userName: entity.userName,
    );
  }
}
