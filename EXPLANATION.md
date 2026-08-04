# 📖 StockFlow — The Complete, In-Depth Explanation

### (Written so simply that even a kid could understand it)

---

## 🤔 What Is This App, Really?

Imagine you own a **toy shop**. You have hundreds of toys on your shelves — action figures, board games, stuffed animals. Every day:

- New toys arrive from the factory 📦
- Kids come in and buy toys 🛒
- Sometimes toys are broken and you have to throw them away 🗑️
- Sometimes a kid returns a toy they didn't like 🔄

Now, how do you keep track of *everything*? How many Spider-Man figures do you have left? Did you sell more Lego sets or Hot Wheels this week? Which toys are almost out of stock?

**StockFlow** is a mobile app that does all of this for you. It's a **digital notebook** on your phone that tracks every single product in your shop — what came in, what went out, how much you have, how much it's all worth. And it does it with pretty charts, a barcode scanner, and a beautiful dark-themed interface.

> **In one sentence**: StockFlow is a smart, offline inventory management app built with Flutter that helps you track products, manage stock, scan QR codes, and view analytics — all from your phone.

---

## 🧱 How Is The App Built? (The Big Picture)

The app is built using **Flutter** (Google's toolkit for building beautiful mobile apps) and **Dart** (the programming language Flutter uses). It runs on both **Android** and **iOS** phones.

Think of the app like a **layered cake** 🎂. Each layer has a specific job, and they all stack on top of each other:

```
┌─────────────────────────────────────────────────┐
│            🖥️  PRESENTATION LAYER               │
│     (What you SEE — screens, buttons, colors)    │
├─────────────────────────────────────────────────┤
│              🧠  DOMAIN LAYER                    │
│   (The BRAIN — business rules and logic)         │
├─────────────────────────────────────────────────┤
│              💾  DATA LAYER                      │
│   (The MEMORY — database, storage, models)       │
├─────────────────────────────────────────────────┤
│              ⚙️  CORE LAYER                      │
│  (The TOOLBOX — helpers, colors, routes, utils)  │
└─────────────────────────────────────────────────┘
```

This is called **Clean Architecture**. Why do we use it? Same reason you don't store your clothes in the kitchen — *everything has its place*, and if you want to change something in one layer, you don't accidentally break another.

Let's explore each layer from the bottom up, like building a house from the foundation to the roof.

---

---

# ⚙️ LAYER 1: THE CORE (The Toolbox)

**Location**: `lib/core/`

The Core is like a **toolbox** 🧰 that every other part of the app reaches into when it needs something. It doesn't do any "business" work itself — it just provides useful tools, settings, and helpers.

---

## 📋 1.1 Constants (`core/constants/`)

### What are constants?

Constants are values that **never change** while the app runs. Think of them as sticky notes posted on the wall that everyone can read:

### `constants.dart` — The App's Sticky Notes

```
App Name:          StockFlow
App Version:       1.0.0
App Tagline:       Smart Inventory Management
```

This file defines:

| Constant | Value | What It Means |
|---|---|---|
| `appName` | `'StockFlow'` | The name of the app, used in titles and headers |
| `splashDuration` | `2 seconds` | How long the splash screen shows before transitioning |
| `animationFast` | `200 milliseconds` | Speed for quick animations |
| `animationNormal` | `300 milliseconds` | Speed for regular animations |
| `animationSlow` | `500 milliseconds` | Speed for slow, dramatic animations |
| `lowStockThreshold` | `10` | If a product has ≤10 items, it's considered "low stock" ⚠️ |
| `outOfStockThreshold` | `0` | If a product has 0 items, it's "out of stock" 🚫 |

It also defines the **product categories** (like aisles in a supermarket):
- Electronics, Food & Beverages, Clothing, Office Supplies, Health & Beauty, Home & Kitchen, Sports & Outdoors, Tools & Hardware, Toys & Games, Automotive, Books & Stationery, Other

And the **transaction types** (what can happen to a product):
- `Stock Added` — New items arrived
- `Sold` — Items were sold to a customer
- `Returned` — Customer brought items back
- `Damaged` — Items were broken/lost
- `Deleted` — Product was removed from the system

There are also **mock login credentials** for testing:
- Email: `admin@stockflow.com`
- Password: `password123`

### `tables.dart` — The Database Blueprint

This file is like the **blueprint for your filing cabinet**. It tells the database exactly what columns (fields) each table should have:

**Products table columns:**
| Column Name | What It Stores |
|---|---|
| `id` | Unique ID for each product (like a social security number for toys) |
| `userId` | Which user owns this product |
| `productName` | Name of the product (e.g., "Wireless Mouse") |
| `description` | A short description |
| `category` | Which category it belongs to |
| `price` | How much it costs |
| `quantity` | How many are in stock right now |
| `qrCode` | A unique QR code string |
| `sku` | Stock Keeping Unit — a short code like `SKU-ELEC-12345` |
| `supplier` | Who supplies this product |
| `image` | Path to the product image |
| `createdAt` | When this product was first added |
| `updatedAt` | When it was last modified |

**Transactions table columns:**
| Column Name | What It Stores |
|---|---|
| `id` | Unique ID for this transaction |
| `userId` | Which user did this |
| `productId` | Which product was affected |
| `transactionType` | What happened (Sold, Stock Added, etc.) |
| `quantity` | How many items |
| `date` | When it happened |
| `remarks` | Optional notes |
| `userName` | Name of the person who did it |

---

## 🚨 1.2 Exceptions (`core/exceptions/`)

### What are exceptions?

When something goes **wrong**, the app needs to tell you *what* went wrong. Exceptions are like **alarm bells** 🔔 with specific labels:

| Exception | When It Happens | Example |
|---|---|---|
| `DatabaseException` | Something failed with the database | "Couldn't save the product" |
| `ValidationException` | User entered bad data | "Price cannot be negative" |
| `NotFoundException` | Couldn't find what we were looking for | "No product with that ID" |
| `DuplicateException` | Trying to create something that already exists | "QR Code already exists" |

Each exception carries a `message` (human-readable explanation) and optionally a `field` (which input field caused the problem).

---

## 🧩 1.3 Extensions (`core/extensions/`)

### What are extensions?

Extensions are like **superpowers** you give to existing things. Dart has strings, numbers, and contexts — extensions let you add new abilities to them:

### `string_extensions.dart` — Superpowers for Text
- `"hello".capitalize` → `"Hello"` (first letter uppercase)
- `"hello world".titleCase` → `"Hello World"` (every word capitalized)
- `"this is a very long text".truncate(10)` → `"this is a ..."` (cut off with dots)
- `"test@email.com".isValidEmail` → `true` (checks if it's a real email format)
- `"John Doe".initials` → `"JD"` (gets the first letters)

### `number_extensions.dart` — Superpowers for Numbers
- `1234.56.asCurrency` → `"$1,234.56"` (formatted as money)
- `1500000.compact` → `"1.5M"` (shortened for display)
- `5.asQuantity` → `"5 units"` (adds "unit/units")

### `context_extensions.dart` — Superpowers for Screens
- `context.screenWidth` → gets the phone screen width
- `context.isDarkMode` → checks if dark mode is on
- `context.pushNamed('/home')` → navigate to the home screen
- `context.pop()` → go back to the previous screen
- `context.unfocus()` → dismiss the keyboard

---

## 🗺️ 1.4 Routes (`core/routes/`)

### What are routes?

Routes are like a **map of all the rooms** in a house 🏠. Each screen in the app has an "address" (a route name), and when you want to go somewhere, you tell the app "take me to `/home`" or "take me to `/scanner`".

### The Route Map:

| Route Path | Screen | What It Shows |
|---|---|---|
| `/` | Splash Screen | App logo animation when you first open it |
| `/login` | Login Screen | Email and password login form |
| `/home` | Home/Dashboard | Stats, charts, recent activity |
| `/inventory` | Inventory Screen | Grid of all your products |
| `/add-product` | Add Product Screen | Form to create/edit a product |
| `/product-detail` | Product Detail | Full info about one product |
| `/scanner` | QR Scanner | Camera view to scan barcodes |
| `/transactions` | Transactions | History of all stock movements |
| `/reports` | Reports | Charts and analytics |
| `/search` | Search | Search across all products |
| `/profile` | Profile | User info and account details |
| `/settings` | Settings | Theme toggle, data management |

### Page Transitions (Animations):

When you navigate between screens, the app doesn't just *jump* — it *slides* or *fades* smoothly:

- **SlidePageRoute**: The new screen slides in from the right → used for most screens
- **FadePageRoute**: The new screen gently fades in → used for splash and login
- **ScalePageRoute**: The new screen zooms in slightly → used for special moments

---

## 💾 1.5 Services (`core/services/`)

### `db.dart` — The Database Manager

This is the **librarian** 📚 of the app. It manages the SQLite database — opening it, creating tables, upgrading it, and even backing it up.

**What it does step by step:**

1. **First time the app opens**: It creates the database file `stockflow.db` on the phone
2. **Creates two tables**: `products` and `transactions` (using the blueprint from `tables.dart`)
3. **Creates indexes**: Special fast-lookup shortcuts for QR codes, user IDs, product IDs, and dates
4. **Handles upgrades**: If the database version changes (e.g., v1 → v2), it adds new columns like `userId` for multi-user support
5. **Backup**: Can copy the entire database to a backup file
6. **Restore**: Can restore from a backup
7. **Reset**: Can delete everything and start fresh

The database uses the **Singleton pattern** — there's only ever ONE instance of it running. It's like having one librarian, not ten different ones all trying to manage the same books.

### `navigation_service.dart` — The GPS

A simple helper that lets any part of the app navigate to any screen, even without having direct access to the screen context. Think of it as a universal remote control for navigation.

---

## 🎨 1.6 Theme (`core/theme/`)

### `colors.dart` — The Color Palette

Every color used in the entire app is defined here. This is like the **paint swatches** 🎨 an interior designer uses:

| Color Name | Hex/RGB | What It's Used For |
|---|---|---|
| `backgroundColor` | Dark charcoal `rgb(18,18,18)` | Main background of every screen |
| `cardColor` | Slightly lighter `rgb(30,30,30)` | Background of cards and containers |
| `borderColor` | Subtle grey `rgb(52,51,67)` | Thin borders around cards |
| `gradient1` | Purple `rgb(187,63,221)` | Primary brand color |
| `gradient2` | Pink `rgb(251,109,169)` | Secondary brand color |
| `gradient3` | Coral `rgb(255,159,124)` | Accent brand color |
| `successColor` | Green `#4CAF50` | "Success!" messages |
| `warningColor` | Orange `#FF9800` | "Watch out!" messages |
| `errorColor` | Red (RedAccent) | "Something went wrong!" messages |
| `infoColor` | Blue `#2196F3` | "FYI" messages |

The **gradient** (the purple-to-pink-to-coral blend) is the signature look of StockFlow. It appears on buttons, the login icon, the splash screen, and throughout the UI.

### `theme.dart` — The Complete Design System

This file takes all the colors and combines them with **typography** (font styles), **component styles** (how buttons, cards, inputs look), and **Material Design 3** settings to create a complete, consistent look.

Key design decisions:
- **Font**: Poppins (from Google Fonts) — clean, modern, friendly
- **Dark theme** is the primary theme (the default)
- **Light theme** is also available (toggled in Settings)
- **All corners are rounded** (12px–20px radius) — gives a soft, modern feel
- **Cards have subtle borders** (0.5px) for definition without being harsh
- **Input fields glow purple** when focused — a nice interactive touch

---

## 🛠️ 1.7 Utils (`core/utils/`)

### `formatters.dart` — The Date & Time Translator

Dates in computers look like `2026-08-04T14:30:00.000` — not very friendly! This utility translates them:

| Method | Input | Output |
|---|---|---|
| `formatFull()` | Aug 4, 2026 | `Aug 04, 2026` |
| `formatShort()` | Aug 4, 2026 | `04/08/2026` |
| `formatWithTime()` | Aug 4, 2026 2:30pm | `Aug 04, 2026 • 02:30 PM` |
| `timeAgo()` | 5 minutes ago | `5 mins ago` |
| `timeAgo()` | Yesterday | `Yesterday` |
| `timeAgo()` | 3 weeks ago | `3 weeks ago` |
| `greeting()` | (depends on time of day) | `Good Morning` / `Good Afternoon` / `Good Evening` |

It also calculates **date ranges**: "today's range", "this week's range", "this month's range" — used by the dashboard to filter transactions.

### `validators.dart` — The Bouncer at the Door

Before any data gets saved, it has to pass the **validator** — like a bouncer checking IDs:

| Validator | What It Checks | Example Error |
|---|---|---|
| `required()` | Is the field empty? | "This field is required" |
| `email()` | Is it a valid email? | "Enter a valid email ending in @gmail.com" |
| `password()` | Is it at least 6 characters? | "Password must be at least 6 characters" |
| `price()` | Is it a valid, non-negative number? | "Price cannot be negative" |
| `quantity()` | Is it a valid whole number ≥ 0? | "Please enter a whole number" |

### `snackbars.dart` — The Notification Toaster

When something happens (success, error, warning), a little message pops up at the bottom of the screen — called a **snackbar**. This utility makes them look consistent:

- 🟢 **Success** — green icon, e.g., "Product saved successfully!"
- 🔴 **Error** — red icon, e.g., "Failed to save product"
- 🟡 **Warning** — orange icon, e.g., "Low stock warning"
- 🔵 **Info** — blue icon, e.g., "Database backup created"

---

---

# 💾 LAYER 2: THE DATA LAYER (The Memory)

**Location**: `lib/data/`

If the Core is the toolbox, the Data Layer is the **filing cabinet** 🗄️. It's responsible for storing, retrieving, and organizing all the product and transaction data.

---

## 🗃️ 2.1 Database (`data/database/`)

### `database_helper.dart` — The Filing Clerk

This is the hardest-working part of the app. It's the person who actually **opens the filing cabinet, pulls out folders, writes new entries, and puts everything back**. Let's look at everything it can do:

#### Products Operations:

| Method | What It Does | Think of It As... |
|---|---|---|
| `insertProduct()` | Saves a new product to the database | Putting a new folder in the cabinet |
| `getAllProducts()` | Gets every product (filtered by current user) | Pulling out ALL folders |
| `getProductById()` | Finds one specific product by ID | Looking up a folder by its label |
| `getProductByQrCode()` | Finds a product by its QR code | Scanning a barcode to find the folder |
| `getProductBySku()` | Finds a product by its SKU | Looking up by the short code |
| `updateProduct()` | Changes a product's info | Erasing and rewriting a folder |
| `deleteProduct()` | Removes a product forever | Shredding a folder 🗑️ |
| `searchProducts()` | Searches by name, description, or category | Flipping through folders looking for a keyword |

#### Transaction Operations:

| Method | What It Does |
|---|---|
| `insertTransaction()` | Records a new stock movement |
| `getAllTransactions()` | Gets all transaction history (sorted newest first) |
| `getTransactionsByProductId()` | Gets history for one specific product |
| `getTransactionsByType()` | Gets only "Sold" or only "Stock Added" transactions |
| `getTransactionsByDateRange()` | Gets transactions between two dates |

#### Statistics Operations:

| Method | What It Returns |
|---|---|
| `getProductStats()` | Total products, total quantity, total value ($), out-of-stock count, low-stock count |
| `getTransactionStats()` | How many items were Added/Sold/Returned/Damaged in a date range |
| `getTopSellingProducts()` | The top N products by total units sold |
| `getLeastSellingProducts()` | The bottom N products by total units sold |

**Important detail**: The database is **multi-tenant** — it stores a `userId` with each record. When you log in as `alice@example.com`, you only see Alice's products. When Bob logs in, he sees his own. This is done by filtering queries with `WHERE userId = ?`.

### `seed_data.dart` — The Starter Kit

When the app is brand new (no products yet), this file could pre-populate the database with sample data. Currently, it's an empty stub (`return;`) — meaning the app starts with a blank inventory and lets the user add their own products.

---

## 📦 2.2 Models (`data/models/`)

### What are models?

Models are like **translators** 🔄. The database stores data as raw maps (key-value pairs). The app needs it as nice Dart objects. Models convert between the two.

### `product_model.dart`

This extends `ProductEntity` (from the domain layer) and adds two abilities:

1. **`fromMap()`** — Takes a raw database row (like `{'id': 'abc', 'productName': 'Mouse', ...}`) and converts it into a proper `ProductModel` object
2. **`toMap()`** — Takes a `ProductModel` object and converts it back into a raw database row for storage
3. **`fromEntity()`** — Converts a domain-level `ProductEntity` into a `ProductModel`

Think of it like this:
```
Database row (raw) ←→ ProductModel (Dart object) ←→ ProductEntity (business object)
```

### `transaction_model.dart`

Same idea, but for transactions. Converts between database rows and `TransactionEntity` objects.

---

## 🔗 2.3 Repositories Implementation (`data/repositories/`)

### What are repositories?

A repository is like a **middleman** 🤝. The brain of the app (domain layer) says "I need all products" — but it doesn't want to know *how* to talk to SQLite. The repository handles that dirty work.

### `product_repository_impl.dart`

This class **implements** the `ProductRepository` interface (defined in the domain layer). It takes every business request and forwards it to the `DatabaseHelper`:

```
Domain Layer: "Give me all products!"
    → ProductRepositoryImpl: "Sure, let me ask the database..."
        → DatabaseHelper: "Here you go!" (returns data)
    → ProductRepositoryImpl: "Here's the data, cleaned up."
Domain Layer: "Thanks!"
```

Special methods:
- `isQrCodeExists()` — Checks if a QR code is already used by another product (to prevent duplicates)
- `isSkuExists()` — Same check for SKU codes

### `transaction_repository_impl.dart`

Same pattern for transactions — takes requests from the domain layer, forwards them to the database, returns results.

---

---

# 🧠 LAYER 3: THE DOMAIN LAYER (The Brain)

**Location**: `lib/domain/`

This is the **brain** of the app 🧠. It defines:
1. What a "product" IS (entities)
2. What operations ARE POSSIBLE (repository contracts)
3. HOW to perform those operations (use cases)

The domain layer knows **nothing** about databases, screens, or buttons. It's pure business logic.

---

## 🏷️ 3.1 Entities (`domain/entities/`)

### What are entities?

Entities are the **definition** of what something is. Like a dictionary entry:

### `ProductEntity` — "What is a Product?"

A product is something with:

| Field | Type | Required? | Description |
|---|---|---|---|
| `id` | String | ✅ | Unique identifier |
| `userId` | String | No | Who owns this product |
| `productName` | String | ✅ | e.g., "Wireless Mouse" |
| `description` | String? | No | Optional longer description |
| `category` | String | ✅ | e.g., "Electronics" |
| `price` | double | ✅ | e.g., 29.99 |
| `quantity` | int | ✅ | How many in stock |
| `qrCode` | String? | No | Unique QR code identifier |
| `sku` | String? | No | Stock Keeping Unit code |
| `supplier` | String? | No | Who supplies this product |
| `image` | String? | No | File path or URL to an image |
| `createdAt` | DateTime | ✅ | When it was first created |
| `updatedAt` | DateTime | ✅ | When it was last modified |

It also has a smart **`status`** property that automatically calculates:
- Quantity = 0 → `"Out of Stock"` 🔴
- Quantity ≤ 10 → `"Low Stock"` 🟡
- Quantity > 10 → `"In Stock"` 🟢

And a **`copyWith()`** method — instead of changing the original product (which could cause bugs), you create a *copy* with just the fields you want changed. Like photocopying a document and editing only the copy.

### `TransactionEntity` — "What is a Transaction?"

A transaction is a record of "something happened to a product":

| Field | Type | Description |
|---|---|---|
| `id` | String | Unique identifier |
| `userId` | String | Who performed this action |
| `productId` | String | Which product was affected |
| `transactionType` | String | "Sold", "Stock Added", "Returned", "Damaged", "Deleted" |
| `quantity` | int | How many units |
| `date` | DateTime | When it happened |
| `remarks` | String? | Optional notes |
| `userName` | String? | Name of the person who did it |

---

## 📜 3.2 Repository Contracts (`domain/repositories/`)

### What are repository contracts?

A contract (also called an "interface" or "abstract class") is like a **job description** 📋. It says "whoever takes this job MUST be able to do these things" — but doesn't say *how* to do them.

### `ProductRepository` — The Product Manager Job Description

"The product manager must be able to:"
- Get all products
- Get a product by ID, QR code, or SKU
- Add, update, and delete products
- Search products by keyword
- Get product statistics
- Check if a QR code or SKU already exists

### `TransactionRepository` — The Transaction Manager Job Description

"The transaction manager must be able to:"
- Get all transactions
- Get transactions for a specific product
- Add a new transaction
- Filter transactions by type or date range
- Get transaction statistics
- Get top-selling and least-selling products

The **data layer** then "applies for the job" by implementing these contracts (see `ProductRepositoryImpl` and `TransactionRepositoryImpl`).

---

## 🎯 3.3 Use Cases (`domain/usecases/`)

### What are use cases?

A use case is a **single, specific action** that the app can perform. Each one is its own class with a single `call()` method. Think of them as **buttons on a remote control** — each button does exactly one thing.

### Product Use Cases:

| Use Case Class | What It Does |
|---|---|
| `GetAllProducts` | Fetches the complete product list |
| `GetProductById` | Fetches one product by its unique ID |
| `GetProductByQrCode` | Looks up a product using a scanned QR code |
| `AddProduct` | Creates a new product (after checking for duplicate QR/SKU) |
| `UpdateProduct` | Modifies an existing product (after checking for duplicate QR/SKU) |
| `DeleteProduct` | Permanently removes a product |
| `SearchProducts` | Searches products by a text query |
| `GetProductStats` | Gets inventory-wide statistics |
| `CheckQrCodeExists` | Checks if a QR code is already taken |
| `CheckSkuExists` | Checks if a SKU is already taken |

**Important**: `AddProduct` and `UpdateProduct` don't just blindly save — they first check that the QR code and SKU aren't duplicates. If they are, they throw a `DuplicateException`. This prevents two products from having the same barcode.

### Transaction Use Cases:

| Use Case Class | What It Does |
|---|---|
| `GetAllTransactions` | Fetches complete transaction history |
| `GetProductTransactions` | Gets history for one product |
| `AddTransaction` | Records a new stock movement |
| `GetTransactionsByType` | Filters by type (Sold, Added, etc.) |
| `GetTransactionsByDateRange` | Gets transactions between two dates |
| `GetTransactionStats` | Counts transactions by type in a date range |
| `GetTopSellingProducts` | Ranks products by total units sold |
| `GetLeastSellingProducts` | Ranks products by fewest units sold |

---

---

# 🖥️ LAYER 4: THE PRESENTATION LAYER (What You See & Touch)

**Location**: `lib/presentation/`

This is the **face** of the app 😊 — everything you see on screen, every button you tap, every animation that plays. It's divided into four parts: Providers (state managers), ViewModels (screen logic), Screens (actual pages), and Widgets (reusable building blocks).

---

## 🔄 4.1 Providers — The State Managers

Providers are like **managers** 👔 who keep track of what's happening and tell the screen to update when something changes. They use Flutter's `ChangeNotifier` + `Provider` pattern.

### `AuthProvider` — The Security Guard 🔐

Manages login/logout and user sessions.

**How login works (step by step):**
1. User types their email and password
2. `AuthProvider.login()` is called
3. It validates the email format and password length
4. It simulates a 600ms delay (to feel like a real server call)
5. It saves the session to `SharedPreferences` (phone's local storage)
6. It derives the user's name from their email (e.g., `john.doe@gmail.com` → `John Doe`)
7. All screens listening to this provider automatically update

**How logout works:**
1. Clears all stored session data
2. Resets all provider states
3. Navigates back to the login screen

**Remember Me**: If checked, the email is saved and pre-filled next time you open the app.

**Multi-user support**: Each email creates a separate "tenant" — different users see different products and transactions.

### `ThemeProvider` — The Light Switch 💡

Controls whether the app is in **dark mode** or **light mode**.

- Defaults to dark mode
- Saves the preference to `SharedPreferences`
- When toggled, every screen instantly redraws with the new theme

### `InventoryProvider` — The Warehouse Manager 📦

Manages the product list, searching, filtering, and sorting.

**Features:**
- **Category filtering**: Show only "Electronics" or only "Food & Beverages"
- **Text search**: Search across product name, SKU, and category
- **Sorting options**: Newest, Oldest, Highest Stock, Lowest Stock, Price High→Low, Price Low→High, Alphabetical
- **CRUD operations**: Add, update, delete products (then auto-refreshes the list)

### `TransactionProvider` — The Accountant 📒

Manages the transaction history list.

- Fetches all transactions (sorted newest first)
- Filters by type: "All", "Sold", "Stock Added", "Returned", "Damaged"
- Can fetch transactions for a specific product

### `DashboardProvider` — The Analyst 📊

The most complex provider. It gathers data from multiple sources to power the dashboard:

**What it calculates:**
- Total number of products
- Total stock quantity across all products
- Total inventory value (price × quantity for each product, summed up)
- How many items are low-stock or out-of-stock
- How many units were sold today
- How many units were added today
- Weekly sales data (Mon–Sun) for the bar chart
- Stock distribution by category (for pie charts)
- The 10 most recent transactions
- The top 5 best-selling products

All of this data is fetched in parallel using `Future.wait()` for speed.

### `ScannerProvider` — The Barcode Detective 🔍

Manages the QR code scanning workflow:

1. **Scan**: Camera detects a QR code → `processScannedCode()` is called
2. **Lookup**: Searches the database for a product with that QR code
3. **Found?** → Shows the product info
4. **Not found?** → Shows an error with option to create a new product
5. **Action**: User can perform stock actions (Add Stock, Sell, Return, Damaged)
6. **Process**: Updates the product quantity and records a transaction
7. **Clear**: Resets the scan state for the next scan

---

## 🎭 4.2 ViewModels — The Screen Directors

ViewModels contain the **logic specific to one screen**. They're like directors telling actors (widgets) what to do.

### `LoginViewModel`

Manages the login screen's local state:
- Email and password text fields
- Form validation
- Password visibility toggle (show/hide the password)
- "Remember Me" checkbox state
- Coordinates with `AuthProvider` for the actual login

### `ProductFormViewModel`

Manages the "Add/Edit Product" form:
- All text controllers (name, description, price, quantity, supplier)
- Category selection
- Image picking (from phone gallery via `image_picker`)
- Auto-generates unique SKU codes (e.g., `SKU-ELEC-849271`)
- Auto-generates QR codes (using UUID)
- Can initialize for new product OR pre-fill for editing an existing one
- Validates the form and saves via `InventoryProvider`

### `ProductDetailViewModel`

Manages the product detail screen:
- Loads a product and its transaction history
- Can sell stock (decreases quantity, records a "Sold" transaction)
- Can add stock (increases quantity, records a "Stock Added" transaction)
- Can delete the product (records a "Deleted" transaction, then removes it)
- All actions update both the product record and create a transaction log

---

## 📱 4.3 Screens — The Actual Pages

Each screen is a full page the user sees. Here's every single screen:

### 🌟 Splash Screen (`screens/splash/`)
**What you see**: The StockFlow logo and name with a gradient animation.
**What happens behind the scenes**:
1. Shows for 2 seconds
2. Checks if the user has an active session (via `AuthProvider.checkSession()`)
3. If logged in → goes to Dashboard
4. If not → goes to Login

### 🔑 Login Screen (`screens/login/`)
**What you see**: A beautiful dark screen with purple gradient circles in the background, the StockFlow logo, email and password fields, a "Remember Me" checkbox, and a gradient login button.

**Cool details**:
- Background has animated gradient circles for visual flair
- Email field has a purple mail icon
- Password field has a pink lock icon with a visibility toggle (eye icon)
- "Forgot Password?" link opens a dialog (currently shows a simulated reset)
- After successful login, clears old data and fetches fresh data for the new user
- Shows a welcome snackbar: "Welcome back, John!"

### 🏠 Home/Dashboard Screen (`screens/home/`)
**What you see**: A greeting ("Good Morning, John"), horizontally scrollable stat cards, a weekly sales bar chart, and a list of recent transactions.

**Dashboard cards** (scroll horizontally):
1. 📦 **Total Products** (purple) — how many products exist
2. ✅ **In Stock** (green) — total units across all products
3. 🛒 **Sold Today** (pink) — units sold today
4. ➕ **Added Today** (blue) — units restocked today
5. ⚠️ **Low Stock** (orange) — how many products are running low

**Weekly Sales Chart**: A bar chart (using `fl_chart`) showing sales for each day of the current week (Mon–Sun). Bars use the signature purple-pink gradient. Tap a bar to see a tooltip.

**Recent Activities**: The last 10 transactions, each shown as a tile with type, quantity, and product name.

**Floating Action Buttons**: Two FABs stacked vertically:
- Small one: QR Scanner shortcut
- Big gradient one: Add new product

**App Drawer** (side menu): Access to Dashboard, Inventory, QR Scanner, Transactions, Reports, Profile, Settings, and Logout.

### 📦 Inventory Screen (`screens/inventory/`)
**What you see**: A grid of product cards with category filter chips at the top.

**Features**:
- **Category chips**: Horizontal scroll of "All", "Electronics", "Food & Beverages", etc. Tap one to filter
- **Sort menu**: Tap the sort icon in the app bar to sort by newest, alphabetical, stock level, or price
- **Search**: Tap the search icon to go to the search screen
- **Product grid**: 2-column grid of cards, each showing the product image (or a gradient placeholder with the first letter), name, SKU, price, quantity, and status badge
- **Long press a card**: Opens a bottom sheet with quick actions (Edit, Delete) and the product's QR code
- **Pull to refresh**: Swipe down to reload the inventory
- **Empty state**: If no products, shows a friendly message with an "Add Product" button

### ➕ Add Product Screen (`screens/add_product/`)
**What you see**: A form with sections for Basic Info, Identifiers, Supplier, and Image.

**Form fields**:
- Product Name (required)
- Description (optional, multi-line)
- Category (dropdown picker)
- Price and Quantity (side by side, required)
- SKU (auto-generated, shown but not editable)
- QR Code (auto-generated UUID, shown but not editable)
- Supplier Name (optional)
- Product Image (tap to pick from gallery)

**If opened from QR scanner**: Shows a special purple banner "Registering Scanned QR Code" with the scanned code. The QR code field is pre-filled.

**If editing**: All fields pre-populate with the existing product's data.

After saving, it syncs all providers (inventory, dashboard, transactions) so everything stays up-to-date.

### 🔍 Product Detail Screen (`screens/product_detail/`)
**What you see**: Full product info with a hero image, price, stock status, QR code display, and transaction history.

**Actions available**:
- **Add Stock**: Opens a dialog to input quantity and remarks → increases stock
- **Sell**: Opens a dialog → decreases stock (won't allow selling more than available)
- **Edit**: Navigates to the Add Product screen in edit mode
- **Delete**: Shows a confirmation dialog → records a deletion transaction and removes the product

### 📷 Scanner Screen (`screens/scanner/`)
**What you see**: A full-screen camera viewfinder with a scanning overlay.

**Workflow**:
1. Camera opens using `mobile_scanner` package
2. Point at any QR code
3. Code detected → looks up the product in the database
4. **Found** → Shows product info card with action buttons (Add Stock, Sell, Return, Damaged)
5. **Not found** → Shows error with an option to "Register New Product" (navigates to Add Product with the QR pre-filled)
6. After any action, user can scan again

### 📊 Transactions Screen (`screens/transactions/`)
**What you see**: A list of all stock movements with filter chips at the top.

**Filter chips**: All, Stock Added, Sold, Returned, Damaged
Each transaction tile shows:
- Icon and color based on type (green arrow up for Added, red arrow down for Sold, etc.)
- Transaction type and quantity
- Product name
- Date and time (formatted as "time ago")
- Optional remarks

### 📈 Reports Screen (`screens/reports/`)
**What you see**: Analytics charts and data visualizations.

**Charts include**:
- Stock distribution by category (shows how inventory is spread)
- Sales trends over time
- Top-selling products ranking

### 🔎 Search Screen (`screens/search/`)
**What you see**: A search bar at the top with live results below.

As you type, products matching the query (by name, SKU, or category) appear instantly. Tap any result to go to its detail page.

### 👤 Profile Screen (`screens/profile/`)
**What you see**: User's avatar (first letter of name), full name, email, role, last login time, and account creation date.

### ⚙️ Settings Screen (`screens/settings/`)
**What you see**: Theme toggle (dark/light mode), data management options.

**Options**:
- Toggle dark/light theme
- Backup database
- Restore from backup
- Reset all data (with confirmation)

---

## 🧩 4.4 Widgets — The Reusable Building Blocks

Widgets are like **LEGO bricks** 🧱 — small, reusable pieces that screens are built from. Here's every custom widget in the app:

### Interactive Widgets

| Widget | What It Is | Where It's Used |
|---|---|---|
| `TouchableScale` | Wraps any widget to add a shrink-on-press animation and optional glow effect | Everywhere — cards, buttons, chips |
| `GradientButton` | A button with the purple-pink gradient, loading spinner, and optional icon | Login, Add Product, dialogs |
| `CustomTextField` | A text input with animated gradient border that rotates when focused | Login, Add Product, Search |
| `CategoryChip` | A small pill-shaped button for category filtering | Inventory screen |
| `ConfirmationDialog` | A popup asking "Are you sure?" with Cancel/Confirm buttons | Delete product, Logout |

### Display Widgets

| Widget | What It Is | Where It's Used |
|---|---|---|
| `GradientText` | Text rendered with the purple-pink gradient color | Titles, prices, branding |
| `DashboardCard` | A stat card showing an icon, title, and value. Tappable to show detail sheet | Dashboard |
| `ProductCard` | A grid card showing product image, name, SKU, price, quantity, and status | Inventory grid |
| `TransactionTile` | A list tile showing a transaction's type, quantity, product, and date | Dashboard, Transactions |
| `StatusBadge` | A small colored label: "In Stock" (green), "Low Stock" (orange), "Out of Stock" (red) | Product cards and details |
| `InfoRow` | A simple label-value row (like "Category: Electronics") | Product detail |
| `SectionHeader` | A bold title with an optional "See All" action link | Dashboard sections |
| `CustomAppBar` | A styled app bar with a circular back button | Various screens |
| `CustomCard` | A styled container with optional gradient border and tap effects | Various |
| `QrDisplayWidget` | Renders a QR code image from a string using `qr_flutter` | Product detail, product card sheet |
| `DrawerTile` | A navigation item in the side drawer with icon, label, and selection highlight | App drawer |

### State Widgets

| Widget | What It Is |
|---|---|
| `LoadingWidget` | A circular progress indicator with optional gradient text message |
| `LoadingOverlay` | Dims the screen and shows a loading spinner on top of content |
| `ShimmerLoading` | An animated shimmer placeholder (like a skeleton loader) |
| `EmptyWidget` | A friendly "nothing here" message with icon, title, subtitle, and action button |
| `NotificationsSheet` | A bottom sheet showing low-stock warnings and recent system activity |

### The `CustomTextField` Deserves Special Attention 🌟

This is one of the fanciest widgets in the app. When you tap a text field:
1. The label text turns white and bold
2. The border transitions from a subtle grey to a **rotating gradient** (purple→pink→coral→purple) that continuously spins around the field
3. A purple glow shadow appears beneath the field
4. Your phone gives a subtle haptic vibration

This is achieved with an `AnimationController` running a continuous rotation, and the gradient's `begin`/`end` alignments are calculated using `cos()` and `sin()` of the animation value. It's pure math creating visual magic!

---

---

# 🚀 How It All Comes Together: The App Startup

**File**: `lib/main.dart`

Here's what happens when you tap the StockFlow icon on your phone:

```
1. WidgetsFlutterBinding.ensureInitialized()
   → "Hey Flutter, wake up and get ready!"

2. DatabaseHelper() is created
   → "Prepare the filing cabinet"

3. SqliteService.instance.database
   → "Open the database (or create it if it's the first time)"

4. Check if products table is empty
   → If yes: SeedData.seedDatabase() (currently does nothing)
   → If no: Skip, data already exists

5. Create repositories
   → ProductRepositoryImpl — connects products to the database
   → TransactionRepositoryImpl — connects transactions to the database

6. Create ALL providers with their use cases:
   → ThemeProvider (dark/light mode)
   → AuthProvider (login state)
   → ProductDetailViewModel (product detail page state)
   → InventoryProvider (with 6 product use cases)
   → TransactionProvider (with 4 transaction use cases)
   → ScannerProvider (with QR lookup + stock update + transaction logging)
   → DashboardProvider (with 6 analytics use cases)

7. Launch MyApp
   → Sets up MaterialApp
   → Chooses theme based on ThemeProvider
   → Starts at the Splash screen ('/')
   → Uses Routes.onGenerateRoute for navigation
```

---

# 📐 How Data Flows Through the App

Let's trace a real example: **User scans a QR code and sells 5 units**

```
📷 Camera detects QR code "ABC123"
    │
    ▼
🔍 ScannerProvider.processScannedCode("ABC123")
    │
    ▼
🎯 GetProductByQrCode use case is called
    │
    ▼
🔗 ProductRepositoryImpl.getProductByQrCode("ABC123")
    │
    ▼
💾 DatabaseHelper queries: SELECT * FROM products WHERE qrCode = "ABC123"
    │
    ▼
📦 Product found! "Wireless Mouse", quantity: 20
    │
    ▼
🖥️ Screen shows the product card with action buttons
    │
    ▼
👆 User taps "Sell" and enters quantity: 5
    │
    ▼
🔄 ScannerProvider.performAction("Sold", 5, "Customer walk-in")
    │
    ├── Check: 5 ≤ 20 (current stock)? ✅ Yes
    │
    ├── Calculate: new quantity = 20 - 5 = 15
    │
    ├── UpdateProduct use case: Update quantity to 15
    │   └── DatabaseHelper: UPDATE products SET quantity = 15 WHERE id = "..."
    │
    └── AddTransaction use case: Record the sale
        └── DatabaseHelper: INSERT INTO transactions (type: "Sold", qty: 5, ...)
    │
    ▼
✅ Done! Product now shows quantity: 15
   Snackbar: "Successfully sold 5 units"
```

---

# 📱 Key Design Decisions Explained

### Why Clean Architecture?
Imagine you want to switch from SQLite to a cloud database (like Firebase). With Clean Architecture, you only change the **data layer** — the domain and presentation layers don't even know the difference. The brain doesn't care where data is stored, only that it can get it.

### Why Provider (and not Bloc, Riverpod, etc.)?
Provider is the simplest and most beginner-friendly state management solution in Flutter. For an app of this size, it's the perfect balance of power and simplicity. No boilerplate, easy to understand, officially recommended by Flutter.

### Why SQLite (and not Firebase/Hive/etc.)?
Because this is an **offline-first** app. You might be in a warehouse with no internet. SQLite stores everything on the phone — no WiFi needed. It's also the industry standard for relational data on mobile.

### Why dark theme by default?
Dark themes reduce eye strain (especially in dimly lit warehouses), save battery on OLED screens, and look more modern/premium. A light theme is available for those who prefer it.

### Why auto-generate SKU and QR codes?
To prevent human error. Instead of asking the user to type a unique code (and risk duplicates or typos), the app generates them automatically using UUIDs (universally unique identifiers — random strings that are practically guaranteed to never repeat).

---

# 🔐 Authentication Explained Simply

The current login system is **local-only** (no real server):

1. User enters any valid email (e.g., `alice@example.com`) and any password ≥6 chars
2. The app validates the format (is it a real email? is the password long enough?)
3. If valid, it saves the session locally using `SharedPreferences`
4. The email becomes the user's "tenant ID" — it filters products and transactions
5. The user's display name is derived from the email: `alice.smith@gmail.com` → `Alice Smith`

> ⚠️ This is a **demo/prototype** auth system. A real production app would use a backend server with proper password hashing, JWT tokens, etc.

---

# 📊 The Charts Explained

### Weekly Sales Bar Chart (Dashboard)
- Shows 7 bars (Monday through Sunday)
- Each bar = total units sold on that day
- Bars use the gradient (purple → pink)
- Touch a bar to see a tooltip: "Wed: 15 sold"
- Data comes from filtering transactions by type "Sold" and grouping by weekday

### Stock Distribution (Reports)
- Shows how inventory is spread across categories
- Calculated by summing quantities per category

---

# 🎨 The Visual Design System

StockFlow's design is built around a few key principles:

### The Gradient
The app's signature is its **purple → pink → coral gradient**:
- `#BB3FDD` (purple) → `#FB6DA9` (pink) → `#FF9F7C` (coral)
- Used in: buttons, the login icon, text highlights, chart bars, splash screen, drawer header

### The Dark Palette
- Background: `rgb(18,18,18)` — nearly black
- Cards: `rgb(30,30,30)` — slightly lighter
- Borders: `rgb(52,51,67)` — subtle purple-tinted grey
- This creates a "layers of darkness" effect that adds depth

### Typography
- Font: **Poppins** (Google Fonts) — a geometric sans-serif that's friendly but professional
- Titles: white, semi-bold to bold
- Subtitles: grey `#A7A7A7`
- Body: slightly lighter grey

### Micro-Animations
- **TouchableScale**: Every tappable card/button shrinks slightly on press (0.95x scale) and bounces back
- **Rotating border**: Text fields have a continuously rotating gradient border when focused
- **Page transitions**: Screens slide in from the right or fade in
- **Hero animations**: Product images transition smoothly between the grid and detail view

---

# 🗂️ Complete File Map

Here's every single file in the project:

```
lib/
├── main.dart                                    ← App entry point
│
├── core/
│   ├── constants/
│   │   ├── constants.dart                       ← App-wide settings & values
│   │   └── tables.dart                          ← Database column names
│   ├── exceptions/
│   │   └── exceptions.dart                      ← Custom error types
│   ├── extensions/
│   │   ├── context_extensions.dart              ← BuildContext helpers
│   │   ├── number_extensions.dart               ← Number formatting
│   │   └── string_extensions.dart               ← String utilities
│   ├── routes/
│   │   ├── page_transitions.dart                ← Slide/Fade/Scale animations
│   │   └── routes.dart                          ← Route map & generator
│   ├── services/
│   │   ├── db.dart                              ← SQLite database service
│   │   └── navigation_service.dart              ← Global navigation
│   ├── theme/
│   │   ├── colors.dart                          ← Color palette
│   │   └── theme.dart                           ← ThemeData configuration
│   └── utils/
│       ├── formatters.dart                      ← Date/time formatting
│       ├── snackbars.dart                       ← Toast notifications
│       └── validators.dart                      ← Form validation
│
├── data/
│   ├── database/
│   │   ├── database_helper.dart                 ← All SQL operations
│   │   └── seed_data.dart                       ← Initial data seeder
│   ├── models/
│   │   ├── product_model.dart                   ← Product ↔ DB converter
│   │   └── transaction_model.dart               ← Transaction ↔ DB converter
│   └── repositories/
│       ├── product_repository_impl.dart         ← Product repo implementation
│       └── transaction_repository_impl.dart     ← Transaction repo implementation
│
├── domain/
│   ├── entities/
│   │   ├── product_entity.dart                  ← Product definition
│   │   └── transaction_entity.dart              ← Transaction definition
│   ├── repositories/
│   │   ├── product_repository.dart              ← Product repo contract
│   │   └── transaction_repository.dart          ← Transaction repo contract
│   └── usecases/
│       ├── product_usecases.dart                ← 10 product actions
│       └── transaction_usecases.dart            ← 8 transaction actions
│
└── presentation/
    ├── providers/
    │   ├── auth_provider.dart                   ← Login/logout state
    │   ├── dashboard_provider.dart              ← Dashboard analytics
    │   ├── inventory_provider.dart              ← Product list management
    │   ├── scanner_provider.dart                ← QR scan workflow
    │   ├── theme_provider.dart                  ← Dark/light toggle
    │   └── transaction_provider.dart            ← Transaction list management
    ├── viewmodels/
    │   ├── login_viewmodel.dart                 ← Login form logic
    │   ├── product_detail_viewmodel.dart         ← Detail page logic
    │   └── product_form_viewmodel.dart          ← Add/Edit form logic
    ├── screens/
    │   ├── splash/splash_screen.dart            ← Startup animation
    │   ├── login/login_screen.dart              ← Authentication UI
    │   ├── home/
    │   │   ├── home_screen.dart                 ← Dashboard UI
    │   │   └── app_drawer.dart                  ← Side navigation menu
    │   ├── inventory/inventory_screen.dart       ← Product grid
    │   ├── add_product/add_product_screen.dart   ← Create/edit form
    │   ├── product_detail/product_detail_screen.dart ← Product info page
    │   ├── scanner/scanner_screen.dart           ← Camera QR scanner
    │   ├── transactions/transactions_screen.dart ← Transaction history
    │   ├── reports/reports_screen.dart           ← Charts & analytics
    │   ├── search/search_screen.dart            ← Live product search
    │   ├── profile/profile_screen.dart          ← User profile
    │   └── settings/settings_screen.dart        ← App settings
    └── widgets/
        ├── category_chip.dart                   ← Filter pill button
        ├── confirmation_dialog.dart             ← "Are you sure?" popup
        ├── custom_app_bar.dart                  ← Styled navigation bar
        ├── custom_button.dart                   ← Gradient action button
        ├── custom_card.dart                     ← Styled container
        ├── custom_text_field.dart               ← Animated input field
        ├── dashboard_card.dart                  ← Stat card widget
        ├── drawer_tile.dart                     ← Drawer menu item
        ├── empty_widget.dart                    ← "Nothing here" state
        ├── gradient_text.dart                   ← Gradient-colored text
        ├── info_row.dart                        ← Label-value row
        ├── loading_widget.dart                  ← Spinner & shimmer loaders
        ├── notifications_sheet.dart             ← Alerts bottom sheet
        ├── product_card.dart                    ← Product grid tile
        ├── qr_widget.dart                       ← QR code renderer
        ├── search_bar_widget.dart               ← Search input
        ├── section_header.dart                  ← Section title with action
        ├── statistic_card.dart                  ← Stats display card
        ├── status_badge.dart                    ← Stock status label
        ├── touchable_scale.dart                 ← Press animation wrapper
        └── transaction_tile.dart                ← Transaction list item
```

**Total**: ~60+ Dart files, organized into 4 clean layers.

---

# 🎁 Summary: What Makes StockFlow Special?

1. **Offline-first** — Works without internet, data lives on your phone
2. **Clean Architecture** — Code is organized, testable, and maintainable
3. **Beautiful UI** — Dark theme with gradient accents, smooth animations, and premium feel
4. **QR Scanner** — Scan any barcode to instantly find or register a product
5. **Real-time Analytics** — Dashboard with live stats, charts, and trends
6. **Multi-user** — Different email logins see different data
7. **Complete Audit Trail** — Every stock change is logged as a transaction
8. **Smart Auto-generation** — SKUs and QR codes are auto-created to prevent errors
9. **Reusable Widgets** — 21+ custom widgets following consistent design patterns
10. **Production-ready Structure** — Ready to swap SQLite for Firebase, add real auth, or scale up

---

*Built with ❤️ using Flutter, Dart, SQLite, Provider, fl_chart, mobile_scanner, qr_flutter, and google_fonts.*
