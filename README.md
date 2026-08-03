# StockFlow — Modern Inventory Management System

[![Flutter](https://img.shields.io/badge/Flutter-^3.7.0-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-^3.7.0-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![SQLite](https://img.shields.io/badge/SQLite-Local_Storage-003B57?style=for-the-badge&logo=sqlite&logoColor=white)](https://sqlite.org)
[![Architecture](https://img.shields.io/badge/Architecture-Clean_Architecture-4A90E2?style=for-the-badge)](https://flutter.dev)

**StockFlow** is a modern, offline-first mobile application designed to streamline product tracking, stock auditing, and inventory analytics. Built with **Flutter** using **Clean Architecture** and **Provider**, it features real-time charts, camera barcode scanning, QR tag generation, and local SQLite data persistence.

---

## Key Features

- 📊 **Dashboard & Visual Analytics**: Real-time overview of total inventory value, low-stock warnings, and transaction trends rendered using `fl_chart`.
- 📦 **Product Management**: Create, update, search, and filter inventory items across custom categories.
- 📷 **Barcode & QR Scanner**: Scan product barcodes directly with your device's camera (`mobile_scanner`) and generate QR tags (`qr_flutter`) for rapid stock lookups.
- 🔁 **Stock Transactions**: Record Stock-In and Stock-Out operations with detailed transaction history logs.
- 🌙 **Dark & Light Mode**: Custom-themed user interface with dynamic theme switching and micro-animations (`flutter_animate`).
- 💾 **Offline-First Storage**: Powered by a local `sqflite` database so your data remains accessible anywhere without internet dependency. Pre-populated with seed data on first launch.

---

## 🏗️ Project Architecture

This application strictly follows **Clean Architecture** principles to separate concerns into decoupled, testable layers:

```text
lib/
├── core/                  # App constants, routes, database services, and UI utilities
│   ├── constants/
│   ├── routes/
│   ├── services/
│   ├── theme/
│   └── utils/
├── data/                  # Data layer: SQLite helper, data models, and repository implementations
│   ├── database/
│   ├── models/
│   └── repositories/
├── domain/                # Business logic: Entities, repository interfaces, and use cases
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/          # UI layer: Screens, widgets, state management (Providers), and ViewModels
    ├── providers/
    ├── screens/
    ├── viewmodels/
    └── widgets/
```

---

## 🛠️ Tech Stack & Dependencies

| Category | Package / Tool | Purpose |
| :--- | :--- | :--- |
| **Framework** | Flutter (SDK ^3.7.0) | Cross-platform UI toolkit |
| **State Management** | [`provider`](https://pub.dev/packages/provider) | App-wide reactive state management |
| **Database** | [`sqflite`](https://pub.dev/packages/sqflite) | Offline relational database storage |
| **Scanner & QR** | [`mobile_scanner`](https://pub.dev/packages/mobile_scanner) & [`qr_flutter`](https://pub.dev/packages/qr_flutter) | Barcode scanning & QR rendering |
| **Charts** | [`fl_chart`](https://pub.dev/packages/fl_chart) | Dynamic analytical charts & trends |
| **Styling & Motion** | [`google_fonts`](https://pub.dev/packages/google_fonts) & [`flutter_animate`](https://pub.dev/packages/flutter_animate) | Custom typography & micro-interactions |

---

## 🚀 Getting Started

### Prerequisites

Make sure you have installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.7.0 or higher)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / Xcode (for running on emulator or physical devices)

### Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Pushpendra-7-ux/INVENTO-_MANAGEMENT.git
   cd INVENTO-_MANAGEMENT
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

---

## 📱 Supported Platforms

- 🤖 **Android** (API Level 21+)
- 🍎 **iOS** (iOS 12.0+)

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
