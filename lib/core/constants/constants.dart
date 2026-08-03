abstract final class K {
  static const appName = 'StockFlow';
  static const appVersion = '1.0.0';
  static const appTagline = 'Smart Inventory Management';

  static const splashDuration = Duration(seconds: 2);
  static const animationFast = Duration(milliseconds: 200);
  static const animationNormal = Duration(milliseconds: 300);
  static const animationSlow = Duration(milliseconds: 500);

  static const categories = [
    'Electronics',
    'Food & Beverages',
    'Clothing',
    'Office Supplies',
    'Health & Beauty',
    'Home & Kitchen',
    'Sports & Outdoors',
    'Tools & Hardware',
    'Toys & Games',
    'Automotive',
    'Books & Stationery',
    'Other',
  ];

  static const transactionAdded = 'Stock Added';
  static const transactionSold = 'Sold';
  static const transactionReturned = 'Returned';
  static const transactionDamaged = 'Damaged';
  static const transactionDeleted = 'Deleted';

  static const transactionTypes = [
    transactionAdded,
    transactionSold,
    transactionReturned,
    transactionDamaged,
    transactionDeleted,
  ];

  // TODO: move these to env or secure storage
  static const mockUserName = 'Admin User';
  static const mockUserEmail = 'admin@stockflow.com';
  static const mockUserRole = 'Administrator';
  static const mockPassword = 'password123';

  static const lowStockThreshold = 10;
  static const outOfStockThreshold = 0;
}
