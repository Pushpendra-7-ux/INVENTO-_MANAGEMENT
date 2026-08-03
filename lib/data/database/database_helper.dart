import 'package:sqflite/sqflite.dart';
import 'package:sqflite/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/tables.dart';
import '../../core/constants/constants.dart';
import '../../core/exceptions/exceptions.dart' as app_exceptions;
import '../../core/services/db.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';

class DatabaseHelper {
  Future<Database> get _db async => await SqliteService.instance.database;

  Future<String> _getActiveUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email')?.trim().toLowerCase() ?? '';
  }

  Future<void> insertProduct(ProductModel product) async {
    try {
      final db = await _db;
      final activeUser = product.userId.isNotEmpty ? product.userId : await _getActiveUserId();
      final model = ProductModel.fromEntity(product.copyWith(userId: activeUser));
      await db.insert(
        Tables.productsTable,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw app_exceptions.DatabaseException('Failed to insert product', e);
    }
  }

  Future<List<ProductModel>> getAllProducts() async {
    try {
      final db = await _db;
      final activeUser = await _getActiveUserId();
      final maps = activeUser.isNotEmpty
          ? await db.query(
              Tables.productsTable,
              where: '${Tables.colUserId} = ? OR ${Tables.colUserId} = ""',
              whereArgs: [activeUser],
            )
          : await db.query(Tables.productsTable);
      return maps.map((e) => ProductModel.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException('Failed to fetch products', e);
    }
  }

  Future<ProductModel?> getProductById(String id) async {
    try {
      final db = await _db;
      final maps = await db.query(
        Tables.productsTable,
        where: '${Tables.colId} = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return ProductModel.fromMap(Map<String, dynamic>.from(maps.first));
      }
      return null;
    } catch (e) {
      throw app_exceptions.DatabaseException('Failed to fetch product by ID', e);
    }
  }

  Future<ProductModel?> getProductByQrCode(String qrCode) async {
    try {
      final db = await _db;
      final activeUser = await _getActiveUserId();
      final maps = activeUser.isNotEmpty
          ? await db.query(
              Tables.productsTable,
              where: '${Tables.colQrCode} = ? AND (${Tables.colUserId} = ? OR ${Tables.colUserId} = "")',
              whereArgs: [qrCode, activeUser],
            )
          : await db.query(
              Tables.productsTable,
              where: '${Tables.colQrCode} = ?',
              whereArgs: [qrCode],
            );
      if (maps.isNotEmpty) {
        return ProductModel.fromMap(Map<String, dynamic>.from(maps.first));
      }
      return null;
    } catch (e) {
      throw app_exceptions.DatabaseException('Failed to fetch product by QR', e);
    }
  }

  Future<ProductModel?> getProductBySku(String sku) async {
    try {
      final db = await _db;
      final activeUser = await _getActiveUserId();
      final maps = activeUser.isNotEmpty
          ? await db.query(
              Tables.productsTable,
              where: '${Tables.colSku} = ? AND (${Tables.colUserId} = ? OR ${Tables.colUserId} = "")',
              whereArgs: [sku, activeUser],
            )
          : await db.query(
              Tables.productsTable,
              where: '${Tables.colSku} = ?',
              whereArgs: [sku],
            );
      if (maps.isNotEmpty) {
        return ProductModel.fromMap(Map<String, dynamic>.from(maps.first));
      }
      return null;
    } catch (e) {
      throw app_exceptions.DatabaseException('Failed to fetch product by SKU', e);
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      final db = await _db;
      final activeUser = product.userId.isNotEmpty ? product.userId : await _getActiveUserId();
      final model = ProductModel.fromEntity(product.copyWith(userId: activeUser));
      await db.update(
        Tables.productsTable,
        model.toMap(),
        where: '${Tables.colId} = ?',
        whereArgs: [product.id],
      );
    } catch (e) {
      throw app_exceptions.DatabaseException('Failed to update product', e);
    }
  }

  // TODO: cascade delete associated transactions when sqlite foreign keys are disabled
  Future<void> deleteProduct(String id) async {
    final db = await _db;
    await db.delete(
      Tables.productsTable,
      where: '${Tables.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final db = await _db;
      final activeUser = await _getActiveUserId();
      final maps = activeUser.isNotEmpty
          ? await db.query(
              Tables.productsTable,
              where: '(${Tables.colUserId} = ? OR ${Tables.colUserId} = "") AND (${Tables.colProductName} LIKE ? OR ${Tables.colDescription} LIKE ? OR ${Tables.colCategory} LIKE ?)',
              whereArgs: [activeUser, '%$query%', '%$query%', '%$query%'],
            )
          : await db.query(
              Tables.productsTable,
              where: '${Tables.colProductName} LIKE ? OR ${Tables.colDescription} LIKE ? OR ${Tables.colCategory} LIKE ?',
              whereArgs: ['%$query%', '%$query%', '%$query%'],
            );
      return maps.map((e) => ProductModel.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException('Failed to search products', e);
    }
  }

  Future<void> insertTransaction(TransactionModel transaction) async {
    try {
      final db = await _db;
      final activeUser = transaction.userId.isNotEmpty ? transaction.userId : await _getActiveUserId();
      final model = TransactionModel.fromEntity(TransactionModel(
        id: transaction.id,
        userId: activeUser,
        productId: transaction.productId,
        transactionType: transaction.transactionType,
        quantity: transaction.quantity,
        date: transaction.date,
        remarks: transaction.remarks,
        userName: transaction.userName,
      ));
      await db.insert(
        Tables.transactionsTable,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw app_exceptions.DatabaseException('Failed to insert transaction', e);
    }
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      final db = await _db;
      final activeUser = await _getActiveUserId();
      final maps = activeUser.isNotEmpty
          ? await db.query(
              Tables.transactionsTable,
              where: '${Tables.colUserId} = ? OR ${Tables.colUserId} = ""',
              whereArgs: [activeUser],
              orderBy: '${Tables.colTransactionDate} DESC',
            )
          : await db.query(
              Tables.transactionsTable,
              orderBy: '${Tables.colTransactionDate} DESC',
            );
      return maps.map((e) => TransactionModel.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException('Failed to fetch transactions', e);
    }
  }

  Future<List<TransactionModel>> getTransactionsByProductId(String productId) async {
    try {
      final db = await _db;
      final maps = await db.query(
        Tables.transactionsTable,
        where: '${Tables.colProductId} = ?',
        whereArgs: [productId],
        orderBy: '${Tables.colTransactionDate} DESC',
      );
      return maps.map((e) => TransactionModel.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException('Failed to fetch product transactions', e);
    }
  }

  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    try {
      final db = await _db;
      final activeUser = await _getActiveUserId();
      final maps = activeUser.isNotEmpty
          ? await db.query(
              Tables.transactionsTable,
              where: '${Tables.colTransactionType} = ? AND (${Tables.colUserId} = ? OR ${Tables.colUserId} = "")',
              whereArgs: [type, activeUser],
              orderBy: '${Tables.colTransactionDate} DESC',
            )
          : await db.query(
              Tables.transactionsTable,
              where: '${Tables.colTransactionType} = ?',
              whereArgs: [type],
              orderBy: '${Tables.colTransactionDate} DESC',
            );
      return maps.map((e) => TransactionModel.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException('Failed to fetch transactions by type', e);
    }
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    try {
      final db = await _db;
      final activeUser = await _getActiveUserId();
      final maps = activeUser.isNotEmpty
          ? await db.query(
              Tables.transactionsTable,
              where: '${Tables.colTransactionDate} >= ? AND ${Tables.colTransactionDate} <= ? AND (${Tables.colUserId} = ? OR ${Tables.colUserId} = "")',
              whereArgs: [start.toIso8601String(), end.toIso8601String(), activeUser],
              orderBy: '${Tables.colTransactionDate} DESC',
            )
          : await db.query(
              Tables.transactionsTable,
              where: '${Tables.colTransactionDate} >= ? AND ${Tables.colTransactionDate} <= ?',
              whereArgs: [start.toIso8601String(), end.toIso8601String()],
              orderBy: '${Tables.colTransactionDate} DESC',
            );
      return maps.map((e) => TransactionModel.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException('Failed to fetch transactions by date', e);
    }
  }

  Future<Map<String, dynamic>> getProductStats() async {
    try {
      final db = await _db;
      final activeUser = await _getActiveUserId();
      final userClause = activeUser.isNotEmpty ? 'WHERE ${Tables.colUserId} = ? OR ${Tables.colUserId} = ""' : '';
      final args = activeUser.isNotEmpty ? [activeUser] : <String>[];
      
      final totalRes = await db.rawQuery('SELECT COUNT(*) as count FROM ${Tables.productsTable} $userClause', args);
      final qtyRes = await db.rawQuery('SELECT SUM(${Tables.colQuantity}) as totalQty FROM ${Tables.productsTable} $userClause', args);
      final valueRes = await db.rawQuery('SELECT SUM(${Tables.colPrice} * ${Tables.colQuantity}) as totalValue FROM ${Tables.productsTable} $userClause', args);
      
      final outWhere = userClause.isEmpty ? 'WHERE ${Tables.colQuantity} = 0' : '$userClause AND ${Tables.colQuantity} = 0';
      final lowWhere = userClause.isEmpty
          ? 'WHERE ${Tables.colQuantity} > 0 AND ${Tables.colQuantity} <= ${K.lowStockThreshold}'
          : '$userClause AND ${Tables.colQuantity} > 0 AND ${Tables.colQuantity} <= ${K.lowStockThreshold}';
      
      final outOfStockRes = await db.rawQuery('SELECT COUNT(*) as count FROM ${Tables.productsTable} $outWhere', args);
      final lowStockRes = await db.rawQuery('SELECT COUNT(*) as count FROM ${Tables.productsTable} $lowWhere', args);
      
      final totalQty = (qtyRes.first['totalQty'] as num?)?.toInt() ?? 0;
      final outOfStockCount = firstIntValue(outOfStockRes) ?? 0;
      final lowStockCount = firstIntValue(lowStockRes) ?? 0;

      return {
        'totalProducts': firstIntValue(totalRes) ?? 0,
        'totalQuantity': totalQty,
        'totalValue': (valueRes.first['totalValue'] as num?)?.toDouble() ?? 0.0,
        'outOfStock': outOfStockCount,
        'outOfStockCount': outOfStockCount,
        'lowStock': lowStockCount,
        'lowStockCount': lowStockCount,
        'inStock': totalQty > 0 ? totalQty : 0,
      };
    } catch (e) {
      throw app_exceptions.DatabaseException('Failed to get product stats', e);
    }
  }

  Future<Map<String, dynamic>> getTransactionStats(DateTime start, DateTime end) async {
    try {
      final db = await _db;
      final startStr = start.toIso8601String();
      final endStr = end.toIso8601String();
      final activeUser = await _getActiveUserId();
      
      Future<int> getCount(String type) async {
        final res = activeUser.isNotEmpty
            ? await db.rawQuery(
                'SELECT COUNT(*) as count FROM ${Tables.transactionsTable} WHERE ${Tables.colTransactionType} = ? AND ${Tables.colTransactionDate} >= ? AND ${Tables.colTransactionDate} <= ? AND (${Tables.colUserId} = ? OR ${Tables.colUserId} = "")',
                [type, startStr, endStr, activeUser]
              )
            : await db.rawQuery(
                'SELECT COUNT(*) as count FROM ${Tables.transactionsTable} WHERE ${Tables.colTransactionType} = ? AND ${Tables.colTransactionDate} >= ? AND ${Tables.colTransactionDate} <= ?',
                [type, startStr, endStr]
              );
        return firstIntValue(res) ?? 0;
      }
      
      return {
        'added': await getCount(K.transactionAdded),
        'sold': await getCount(K.transactionSold),
        'returned': await getCount(K.transactionReturned),
        'damaged': await getCount(K.transactionDamaged),
      };
    } catch (e) {
      throw app_exceptions.DatabaseException('Failed to get transaction stats', e);
    }
  }

  Future<List<Map<String, dynamic>>> getTopSellingProducts(int limit) async {
    try {
      final db = await _db;
      final activeUser = await _getActiveUserId();
      if (activeUser.isNotEmpty) {
        return await db.rawQuery('''
          SELECT p.${Tables.colId}, p.${Tables.colProductName}, SUM(t.${Tables.colTransactionQuantity}) as totalSold
          FROM ${Tables.transactionsTable} t
          JOIN ${Tables.productsTable} p ON t.${Tables.colProductId} = p.${Tables.colId}
          WHERE t.${Tables.colTransactionType} = ? AND (t.${Tables.colUserId} = ? OR t.${Tables.colUserId} = "")
          GROUP BY p.${Tables.colId}
          ORDER BY totalSold DESC
          LIMIT ?
        ''', [K.transactionSold, activeUser, limit]);
      } else {
        return await db.rawQuery('''
          SELECT p.${Tables.colId}, p.${Tables.colProductName}, SUM(t.${Tables.colTransactionQuantity}) as totalSold
          FROM ${Tables.transactionsTable} t
          JOIN ${Tables.productsTable} p ON t.${Tables.colProductId} = p.${Tables.colId}
          WHERE t.${Tables.colTransactionType} = ?
          GROUP BY p.${Tables.colId}
          ORDER BY totalSold DESC
          LIMIT ?
        ''', [K.transactionSold, limit]);
      }
    } catch (e) {
      throw app_exceptions.DatabaseException('Failed to get top selling products', e);
    }
  }

  Future<List<Map<String, dynamic>>> getLeastSellingProducts(int limit) async {
    try {
      final db = await _db;
      final activeUser = await _getActiveUserId();
      if (activeUser.isNotEmpty) {
        return await db.rawQuery('''
          SELECT p.${Tables.colId}, p.${Tables.colProductName}, IFNULL(SUM(t.${Tables.colTransactionQuantity}), 0) as totalSold
          FROM ${Tables.productsTable} p
          LEFT JOIN ${Tables.transactionsTable} t ON p.${Tables.colId} = t.${Tables.colProductId} AND t.${Tables.colTransactionType} = ?
          WHERE (p.${Tables.colUserId} = ? OR p.${Tables.colUserId} = "")
          GROUP BY p.${Tables.colId}
          ORDER BY totalSold ASC
          LIMIT ?
        ''', [K.transactionSold, activeUser, limit]);
      } else {
        return await db.rawQuery('''
          SELECT p.${Tables.colId}, p.${Tables.colProductName}, IFNULL(SUM(t.${Tables.colTransactionQuantity}), 0) as totalSold
          FROM ${Tables.productsTable} p
          LEFT JOIN ${Tables.transactionsTable} t ON p.${Tables.colId} = t.${Tables.colProductId} AND t.${Tables.colTransactionType} = ?
          GROUP BY p.${Tables.colId}
          ORDER BY totalSold ASC
          LIMIT ?
        ''', [K.transactionSold, limit]);
      }
    } catch (e) {
      throw app_exceptions.DatabaseException('Failed to get least selling products', e);
    }
  }
}
