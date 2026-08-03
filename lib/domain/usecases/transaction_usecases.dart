import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class GetAllTransactions {
  final TransactionRepository repository;
  GetAllTransactions(this.repository);

  Future<List<TransactionEntity>> call() async {
    return await repository.getAllTransactions();
  }
}

class GetProductTransactions {
  final TransactionRepository repository;
  GetProductTransactions(this.repository);

  Future<List<TransactionEntity>> call(String productId) async {
    return await repository.getTransactionsByProductId(productId);
  }
}

class AddTransaction {
  final TransactionRepository repository;
  AddTransaction(this.repository);

  Future<void> call(TransactionEntity transaction) async {
    await repository.addTransaction(transaction);
  }
}

class GetTransactionsByType {
  final TransactionRepository repository;
  GetTransactionsByType(this.repository);

  Future<List<TransactionEntity>> call(String type) async {
    return await repository.getTransactionsByType(type);
  }
}

class GetTransactionsByDateRange {
  final TransactionRepository repository;
  GetTransactionsByDateRange(this.repository);

  Future<List<TransactionEntity>> call(DateTime start, DateTime end) async {
    return await repository.getTransactionsByDateRange(start, end);
  }
}

class GetTransactionStats {
  final TransactionRepository repository;
  GetTransactionStats(this.repository);

  Future<Map<String, dynamic>> call(DateTime start, DateTime end) async {
    return await repository.getTransactionStats(start, end);
  }
}

class GetTopSellingProducts {
  final TransactionRepository repository;
  GetTopSellingProducts(this.repository);

  Future<List<Map<String, dynamic>>> call(int limit) async {
    return await repository.getTopSellingProducts(limit);
  }
}

class GetLeastSellingProducts {
  final TransactionRepository repository;
  GetLeastSellingProducts(this.repository);

  Future<List<Map<String, dynamic>>> call(int limit) async {
    return await repository.getLeastSellingProducts(limit);
  }
}
