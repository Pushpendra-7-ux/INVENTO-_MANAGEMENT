import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/tables.dart';

class SqliteService {
  SqliteService._();
  static final instance = SqliteService._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), Tables.databaseName);
    return await openDatabase(
      path,
      version: Tables.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${Tables.productsTable} (
        ${Tables.colId} TEXT PRIMARY KEY,
        ${Tables.colUserId} TEXT NOT NULL DEFAULT '',
        ${Tables.colProductName} TEXT NOT NULL,
        ${Tables.colDescription} TEXT,
        ${Tables.colCategory} TEXT NOT NULL,
        ${Tables.colPrice} REAL NOT NULL,
        ${Tables.colQuantity} INTEGER NOT NULL DEFAULT 0,
        ${Tables.colQrCode} TEXT UNIQUE,
        ${Tables.colSku} TEXT UNIQUE,
        ${Tables.colSupplier} TEXT,
        ${Tables.colImage} TEXT,
        ${Tables.colCreatedAt} TEXT NOT NULL,
        ${Tables.colUpdatedAt} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${Tables.transactionsTable} (
        ${Tables.colTransactionId} TEXT PRIMARY KEY,
        ${Tables.colUserId} TEXT NOT NULL DEFAULT '',
        ${Tables.colProductId} TEXT NOT NULL,
        ${Tables.colTransactionType} TEXT NOT NULL,
        ${Tables.colTransactionQuantity} INTEGER NOT NULL,
        ${Tables.colTransactionDate} TEXT NOT NULL,
        ${Tables.colRemarks} TEXT,
        ${Tables.colUserName} TEXT,
        FOREIGN KEY (${Tables.colProductId}) 
          REFERENCES ${Tables.productsTable}(${Tables.colId})
          ON DELETE CASCADE
      )
    ''');

    // indexes for common queries
    await db.execute('CREATE INDEX idx_products_qr ON ${Tables.productsTable}(${Tables.colQrCode})');
    await db.execute('CREATE INDEX idx_products_user ON ${Tables.productsTable}(${Tables.colUserId})');
    await db.execute('CREATE INDEX idx_transactions_product ON ${Tables.transactionsTable}(${Tables.colProductId})');
    await db.execute('CREATE INDEX idx_transactions_date ON ${Tables.transactionsTable}(${Tables.colTransactionDate})');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // add userId column for multi-tenant support
      try { await db.execute('ALTER TABLE ${Tables.productsTable} ADD COLUMN ${Tables.colUserId} TEXT NOT NULL DEFAULT ""'); } catch (_) {}
      try { await db.execute('ALTER TABLE ${Tables.transactionsTable} ADD COLUMN ${Tables.colUserId} TEXT NOT NULL DEFAULT ""'); } catch (_) {}
    }
  }

  Future<String> backupDatabase() async {
    final db = await database;
    final dbPath = db.path;
    final docs = await getApplicationDocumentsDirectory();
    final backupPath = join(docs.path, 'stockflow_backup_${DateTime.now().millisecondsSinceEpoch}.db');

    await db.close();
    _database = null;
    await File(dbPath).copy(backupPath);
    _database = await _initDatabase();

    return backupPath;
  }

  Future<void> restoreDatabase(String backupPath) async {
    final db = await database;
    final dbPath = db.path;

    await db.close();
    _database = null;

    final backupFile = File(backupPath);
    if (await backupFile.exists()) {
      await backupFile.copy(dbPath);
    }
    _database = await _initDatabase();
  }

  Future<void> resetAllData() async {
    final db = await database;
    await db.delete(Tables.transactionsTable);
    await db.delete(Tables.productsTable);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
