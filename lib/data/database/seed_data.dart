import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';
import '../../core/constants/constants.dart';

class SeedData {
  static Future<void> seedDatabase(DatabaseHelper db) async {
    final now = DateTime.now();
    const uuid = Uuid();

    final sampleProducts = [
      ProductModel(
        id: 'seed-prod-1',
        productName: 'Wireless Noise-Canceling Headphones',
        description: 'Premium over-ear Bluetooth headphones with active noise cancellation.',
        category: 'Electronics',
        price: 249.99,
        quantity: 18,
        qrCode: 'QR-HEADPHONES-01',
        sku: 'SKU-ELEC-882101',
        supplier: 'AudioTech Logistics',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      ),
      ProductModel(
        id: 'seed-prod-2',
        productName: 'Ergonomic Mesh Office Chair',
        description: 'Breathable lumbar support chair with adjustable armrests.',
        category: 'Furniture',
        price: 189.50,
        quantity: 7,
        qrCode: 'QR-CHAIR-02',
        sku: 'SKU-FURN-443202',
        supplier: 'ComfortSeat Co.',
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now,
      ),
      ProductModel(
        id: 'seed-prod-3',
        productName: 'RGB Mechanical Gaming Keyboard',
        description: 'Tactile mechanical switches with customizable RGB backlighting.',
        category: 'Electronics',
        price: 119.00,
        quantity: 24,
        qrCode: 'QR-KEYBOARD-03',
        sku: 'SKU-ELEC-991303',
        supplier: 'GamerGear Inc.',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now,
      ),
      ProductModel(
        id: 'seed-prod-4',
        productName: 'Smart Fitness Watch Series 5',
        description: 'Heart rate monitor, GPS tracking, and 7-day battery life.',
        category: 'Electronics',
        price: 159.99,
        quantity: 4,
        qrCode: 'QR-WATCH-04',
        sku: 'SKU-ELEC-112404',
        supplier: 'Pulse Gear Labs',
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now,
      ),
      ProductModel(
        id: 'seed-prod-5',
        productName: '4K UltraHD 27" IPS Monitor',
        description: 'Color-accurate 4K display with USB-C power delivery.',
        category: 'Electronics',
        price: 349.00,
        quantity: 12,
        qrCode: 'QR-MONITOR-05',
        sku: 'SKU-ELEC-553505',
        supplier: 'Vision Display Corp',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now,
      ),
      ProductModel(
        id: 'seed-prod-6',
        productName: 'Stainless Steel Water Bottle (1L)',
        description: 'Double-wall vacuum insulated flask, keeps cold for 24h.',
        category: 'Other',
        price: 24.99,
        quantity: 0,
        qrCode: 'QR-BOTTLE-06',
        sku: 'SKU-OTHR-774606',
        supplier: 'EcoLife Goods',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now,
      ),
    ];

    for (var prod in sampleProducts) {
      await db.insertProduct(prod);
    }

    // Seed sample transactions for weekly graphs
    final sampleTransactions = [
      TransactionModel(
        id: uuid.v4(),
        productId: 'seed-prod-1',
        transactionType: K.transactionSold,
        quantity: 3,
        date: now.subtract(const Duration(days: 4)),
        remarks: 'Online Customer Sale',
        userName: 'Admin User',
      ),
      TransactionModel(
        id: uuid.v4(),
        productId: 'seed-prod-3',
        transactionType: K.transactionSold,
        quantity: 5,
        date: now.subtract(const Duration(days: 3)),
        remarks: 'Retail Store Order',
        userName: 'Admin User',
      ),
      TransactionModel(
        id: uuid.v4(),
        productId: 'seed-prod-2',
        transactionType: K.transactionSold,
        quantity: 2,
        date: now.subtract(const Duration(days: 2)),
        remarks: 'Corporate Order',
        userName: 'Admin User',
      ),
      TransactionModel(
        id: uuid.v4(),
        productId: 'seed-prod-4',
        transactionType: K.transactionSold,
        quantity: 4,
        date: now.subtract(const Duration(days: 1)),
        remarks: 'Flash Sale Item',
        userName: 'Admin User',
      ),
      TransactionModel(
        id: uuid.v4(),
        productId: 'seed-prod-5',
        transactionType: K.transactionSold,
        quantity: 2,
        date: now,
        remarks: 'Standard Order',
        userName: 'Admin User',
      ),
      TransactionModel(
        id: uuid.v4(),
        productId: 'seed-prod-1',
        transactionType: K.transactionAdded,
        quantity: 10,
        date: now,
        remarks: 'Stock Restock from Supplier',
        userName: 'Admin User',
      ),
    ];

    for (var tx in sampleTransactions) {
      await db.insertTransaction(tx);
    }
  }
}
