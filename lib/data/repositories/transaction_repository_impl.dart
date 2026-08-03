import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../database/database_helper.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final DatabaseHelper databaseHelper;

  TransactionRepositoryImpl(this.databaseHelper);

  @override
  Future<void> addTransaction(TransactionEntity transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    await databaseHelper.insertTransaction(model);
  }

  @override
  Future<List<TransactionEntity>> getAllTransactions() async {
    return List<TransactionEntity>.from(await databaseHelper.getAllTransactions());
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    return List<TransactionEntity>.from(await databaseHelper.getTransactionsByDateRange(start, end));
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByProductId(String productId) async {
    return List<TransactionEntity>.from(await databaseHelper.getTransactionsByProductId(productId));
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByType(String type) async {
    return List<TransactionEntity>.from(await databaseHelper.getTransactionsByType(type));
  }

  @override
  Future<Map<String, dynamic>> getTransactionStats(DateTime start, DateTime end) async {
    return await databaseHelper.getTransactionStats(start, end);
  }

  @override
  Future<List<Map<String, dynamic>>> getLeastSellingProducts(int limit) async {
    return await databaseHelper.getLeastSellingProducts(limit);
  }

  @override
  Future<List<Map<String, dynamic>>> getTopSellingProducts(int limit) async {
    return await databaseHelper.getTopSellingProducts(limit);
  }
}
