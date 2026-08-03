import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<List<TransactionEntity>> getAllTransactions();
  Future<List<TransactionEntity>> getTransactionsByProductId(String productId);
  Future<void> addTransaction(TransactionEntity transaction);
  Future<List<TransactionEntity>> getTransactionsByType(String type);
  Future<List<TransactionEntity>> getTransactionsByDateRange(DateTime start, DateTime end);
  Future<Map<String, dynamic>> getTransactionStats(DateTime start, DateTime end);
  Future<List<Map<String, dynamic>>> getTopSellingProducts(int limit);
  Future<List<Map<String, dynamic>>> getLeastSellingProducts(int limit);
}
