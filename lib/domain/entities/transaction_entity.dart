class TransactionEntity {
  final String id;
  final String userId;
  final String productId;
  final String transactionType;
  final int quantity;
  final DateTime date;
  final String? remarks;
  final String? userName;

  const TransactionEntity({
    required this.id,
    this.userId = '',
    required this.productId,
    required this.transactionType,
    required this.quantity,
    required this.date,
    this.remarks,
    this.userName,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is TransactionEntity &&
      other.id == id &&
      other.productId == productId &&
      other.transactionType == transactionType &&
      other.quantity == quantity &&
      other.date == date &&
      other.remarks == remarks &&
      other.userName == userName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      productId.hashCode ^
      transactionType.hashCode ^
      quantity.hashCode ^
      date.hashCode ^
      remarks.hashCode ^
      userName.hashCode;
  }
}
