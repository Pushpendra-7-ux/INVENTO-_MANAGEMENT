import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/tables.dart';
import '../../core/constants/constants.dart';
import '../../core/services/db.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';

class DatabaseHelper {
  Future<Database> get _db async => await SqliteService.instance.database;

  Future<String> _getActiveUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email')?.trim().toLowerCase() ?? '';
  }

  Future<List<ProductModel>> _loadWebProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await _getActiveUserId();
      final key = userId.isNotEmpty ? 'stockflow_products_$userId' : 'stockflow_web_products';
      final raw = prefs.getString(key);
      if (raw == null || raw.isEmpty) return [];
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => ProductModel.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveWebProducts(List<ProductModel> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await _getActiveUserId();
      final key = userId.isNotEmpty ? 'stockflow_products_$userId' : 'stockflow_web_products';
      final encoded = jsonEncode(products.map((p) => p.toMap()).toList());
      await prefs.setString(key, encoded);
    } catch (_) {}
  }

  Future<List<TransactionModel>> _loadWebTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await _getActiveUserId();
      final key = userId.isNotEmpty ? 'stockflow_transactions_$userId' : 'stockflow_web_transactions';
      final raw = prefs.getString(key);
      if (raw == null || raw.isEmpty) return [];
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => TransactionModel.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveWebTransactions(List<TransactionModel> txs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await _getActiveUserId();
      final key = userId.isNotEmpty ? 'stockflow_transactions_$userId' : 'stockflow_web_transactions';
      final encoded = jsonEncode(txs.map((t) => t.toMap()).toList());
      await prefs.setString(key, encoded);
    } catch (_) {}
  }

  // --- PRODUCTS ---

  Future<void> insertProduct(ProductModel product) async {
    final activeUser = product.userId.isNotEmpty ? product.userId : await _getActiveUserId();
    final model = ProductModel.fromEntity(product.copyWith(userId: activeUser));

    if (kIsWeb) {
      final all = await _loadWebProducts();
      all.removeWhere((p) => p.id == model.id);
      all.add(model);
      await _saveWebProducts(all);
      return;
    }

    final db = await _db;
    await db.insert(
      Tables.productsTable,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ProductModel>> getAllProducts() async {
    if (kIsWeb) {
      return await _loadWebProducts();
    }

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
  }

  Future<ProductModel?> getProductById(String id) async {
    if (kIsWeb) {
      final all = await _loadWebProducts();
      return all.where((p) => p.id == id).firstOrNull;
    }

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
  }

  Future<ProductModel?> getProductByQrCode(String qrCode) async {
    if (kIsWeb) {
      final all = await _loadWebProducts();
      return all.where((p) => p.qrCode == qrCode).firstOrNull;
    }

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
    } catch (_) {
      return null;
    }
  }

  Future<ProductModel?> getProductBySku(String sku) async {
    if (kIsWeb) {
      final all = await _loadWebProducts();
      return all.where((p) => p.sku == sku).firstOrNull;
    }

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
    } catch (_) {
      return null;
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    final activeUser = product.userId.isNotEmpty ? product.userId : await _getActiveUserId();
    final model = ProductModel.fromEntity(product.copyWith(userId: activeUser));

    if (kIsWeb) {
      final all = await _loadWebProducts();
      final index = all.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        all[index] = model;
      } else {
        all.add(model);
      }
      await _saveWebProducts(all);
      return;
    }

    final db = await _db;
    await db.update(
      Tables.productsTable,
      model.toMap(),
      where: '${Tables.colId} = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> deleteProduct(String id) async {
    if (kIsWeb) {
      final all = await _loadWebProducts();
      all.removeWhere((p) => p.id == id);
      await _saveWebProducts(all);
      return;
    }

    final db = await _db;
    await db.delete(
      Tables.productsTable,
      where: '${Tables.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final q = query.toLowerCase();
    if (kIsWeb) {
      final all = await getAllProducts();
      return all.where((p) {
        return p.productName.toLowerCase().contains(q) ||
            (p.description?.toLowerCase().contains(q) ?? false) ||
            p.category.toLowerCase().contains(q) ||
            (p.sku?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

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
  }

  // --- TRANSACTIONS ---

  Future<void> insertTransaction(TransactionModel transaction) async {
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

    if (kIsWeb) {
      final all = await _loadWebTransactions();
      all.removeWhere((t) => t.id == model.id);
      all.add(model);
      await _saveWebTransactions(all);
      return;
    }

    final db = await _db;
    await db.insert(
      Tables.transactionsTable,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    if (kIsWeb) {
      final all = await _loadWebTransactions();
      final sorted = List<TransactionModel>.from(all);
      sorted.sort((a, b) => b.date.compareTo(a.date));
      return sorted;
    }

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
  }

  Future<List<TransactionModel>> getTransactionsByProductId(String productId) async {
    if (kIsWeb) {
      final all = await getAllTransactions();
      return all.where((t) => t.productId == productId).toList();
    }

    final db = await _db;
    final maps = await db.query(
      Tables.transactionsTable,
      where: '${Tables.colProductId} = ?',
      whereArgs: [productId],
      orderBy: '${Tables.colTransactionDate} DESC',
    );
    return maps.map((e) => TransactionModel.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    if (kIsWeb) {
      final all = await getAllTransactions();
      return all.where((t) => t.transactionType == type).toList();
    }

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
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    if (kIsWeb) {
      final all = await getAllTransactions();
      return all.where((t) => t.date.isAfter(start.subtract(const Duration(seconds: 1))) && t.date.isBefore(end.add(const Duration(seconds: 1)))).toList();
    }

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
  }

  // --- STATS ---

  Future<Map<String, dynamic>> getProductStats() async {
    if (kIsWeb) {
      final products = await getAllProducts();
      int totalProducts = products.length;
      int totalQuantity = 0;
      double totalValue = 0;
      int outOfStock = 0;
      int lowStock = 0;

      for (var p in products) {
        totalQuantity += p.quantity;
        totalValue += (p.price * p.quantity);
        if (p.quantity == 0) {
          outOfStock++;
        } else if (p.quantity <= K.lowStockThreshold) {
          lowStock++;
        }
      }

      return {
        'totalProducts': totalProducts,
        'totalQuantity': totalQuantity,
        'totalValue': totalValue,
        'outOfStock': outOfStock,
        'outOfStockCount': outOfStock,
        'lowStock': lowStock,
        'lowStockCount': lowStock,
        'inStock': totalQuantity > 0 ? totalQuantity : 0,
      };
    }

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
  }

  Future<Map<String, dynamic>> getTransactionStats(DateTime start, DateTime end) async {
    if (kIsWeb) {
      final txs = await getTransactionsByDateRange(start, end);
      int added = txs.where((t) => t.transactionType == K.transactionAdded).length;
      int sold = txs.where((t) => t.transactionType == K.transactionSold).length;
      int returned = txs.where((t) => t.transactionType == K.transactionReturned).length;
      int damaged = txs.where((t) => t.transactionType == K.transactionDamaged).length;
      return {
        'added': added,
        'sold': sold,
        'returned': returned,
        'damaged': damaged,
      };
    }

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
  }

  Future<List<Map<String, dynamic>>> getTopSellingProducts(int limit) async {
    if (kIsWeb) {
      final txs = await getAllTransactions();
      final products = await getAllProducts();
      final soldTxs = txs.where((t) => t.transactionType == K.transactionSold).toList();
      
      final Map<String, int> soldMap = {};
      for (var t in soldTxs) {
        soldMap[t.productId] = (soldMap[t.productId] ?? 0) + t.quantity;
      }

      final List<Map<String, dynamic>> list = [];
      soldMap.forEach((prodId, totalSold) {
        final prod = products.where((p) => p.id == prodId).firstOrNull;
        if (prod != null) {
          list.add({
            Tables.colId: prod.id,
            Tables.colProductName: prod.productName,
            'totalSold': totalSold,
          });
        }
      });

      list.sort((a, b) => (b['totalSold'] as int).compareTo(a['totalSold'] as int));
      return list.take(limit).toList();
    }

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
  }

  Future<List<Map<String, dynamic>>> getLeastSellingProducts(int limit) async {
    if (kIsWeb) {
      final txs = await getAllTransactions();
      final products = await getAllProducts();
      final soldTxs = txs.where((t) => t.transactionType == K.transactionSold).toList();
      
      final Map<String, int> soldMap = {};
      for (var t in soldTxs) {
        soldMap[t.productId] = (soldMap[t.productId] ?? 0) + t.quantity;
      }

      final List<Map<String, dynamic>> list = [];
      for (var prod in products) {
        list.add({
          Tables.colId: prod.id,
          Tables.colProductName: prod.productName,
          'totalSold': soldMap[prod.id] ?? 0,
        });
      }

      list.sort((a, b) => (a['totalSold'] as int).compareTo(b['totalSold'] as int));
      return list.take(limit).toList();
    }

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
  }
}
