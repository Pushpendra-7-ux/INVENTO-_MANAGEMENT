import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/snackbars.dart';
import '../../../core/routes/routes.dart';
import '../../providers/scanner_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/touchable_scale.dart';
import '../../widgets/gradient_text.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessingScan = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _resetScanner() {
    final provider = context.read<ScannerProvider>();
    provider.clearScan();
    controller.start();
    if (mounted) setState(() => _isProcessingScan = false);
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessingScan) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() => _isProcessingScan = true);
    HapticFeedback.mediumImpact();
    controller.stop();

    await _processCode(code);
  }

  Future<void> _processCode(String code) async {
    final provider = context.read<ScannerProvider>();
    await provider.processScannedCode(code);

    if (!mounted) return;

    if (provider.scannedProduct != null) {
      // REGISTERED QR: Show Add/Remove stock sheet directly
      _showAddRemoveSheet(provider);
    } else {
      // UNREGISTERED QR: Navigate to Add Product form with QR pre-filled
      provider.clearScan();
      Navigator.of(context).pushNamed(
        Routes.addProduct,
        arguments: code,
      );
      // Reset scanner when we come back
      if (mounted) setState(() => _isProcessingScan = false);
    }
  }

  /// The core Add/Remove stock sheet for registered QR codes
  void _showAddRemoveSheet(ScannerProvider provider) {
    final product = provider.scannedProduct!;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.subtitleText.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Product info header
              Row(
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      gradient: AppColors.buttonGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        product.productName.isNotEmpty ? product.productName[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.productName,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        Text('${product.category} • ${product.sku ?? "N/A"}',
                          style: const TextStyle(color: AppColors.subtitleText, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stock info bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderColor, width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Current Stock', style: TextStyle(color: AppColors.subtitleText, fontSize: 11)),
                        Text('${product.quantity} units',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Unit Price', style: TextStyle(color: AppColors.subtitleText, fontSize: 11)),
                        GradientText('₹${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text('What do you want to do?',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),

              // Add / Remove buttons
              Row(
                children: [
                  Expanded(
                    child: TouchableScale(
                      onTap: () {
                        Navigator.pop(ctx);
                        _showQuantityDialog(provider, isAdd: true);
                      },
                      borderRadius: BorderRadius.circular(16),
                      glowColor: AppColors.successColor,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: AppColors.successColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.successColor, width: 1.5),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.add_circle_rounded, color: AppColors.successColor, size: 36),
                            SizedBox(height: 8),
                            Text('ADD STOCK', style: TextStyle(color: AppColors.successColor, fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TouchableScale(
                      onTap: () {
                        if (product.quantity <= 0) {
                          Snackbars.showError(ctx, 'Product is out of stock!');
                          return;
                        }
                        Navigator.pop(ctx);
                        _showQuantityDialog(provider, isAdd: false);
                      },
                      borderRadius: BorderRadius.circular(16),
                      glowColor: AppColors.gradient2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: AppColors.gradient2.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.gradient2, width: 1.5),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.remove_circle_rounded, color: AppColors.gradient2, size: 36),
                            SizedBox(height: 8),
                            Text('REMOVE STOCK', style: TextStyle(color: AppColors.gradient2, fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Done / Scan Again
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.subtitleText,
                    side: const BorderSide(color: AppColors.borderColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _resetScanner();
                  },
                  child: const Text('Scan Another QR Code'),
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      // If user dismisses sheet by swiping down
      _resetScanner();
    });
  }

  /// Quantity input dialog for Add or Remove stock
  void _showQuantityDialog(ScannerProvider provider, {required bool isAdd}) {
    final qtyController = TextEditingController(text: '1');
    final remarksController = TextEditingController();
    final product = provider.scannedProduct!;
    final actionType = isAdd ? 'Stock Added' : 'Sold';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isAdd ? Icons.add_circle_rounded : Icons.remove_circle_rounded,
              color: isAdd ? AppColors.successColor : AppColors.gradient2,
            ),
            const SizedBox(width: 10),
            Text(
              isAdd ? 'Add Stock' : 'Remove Stock',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product: ${product.productName}',
              style: const TextStyle(color: AppColors.subtitleText, fontSize: 13),
            ),
            Text('Current Stock: ${product.quantity} units',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: qtyController,
              label: 'Quantity',
              hint: '1',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: remarksController,
              label: 'Remarks (Optional)',
              hint: isAdd ? 'Supplier shipment...' : 'Customer order...',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resetScanner();
            },
            child: const Text('Cancel', style: TextStyle(color: AppColors.subtitleText)),
          ),
          GradientButton(
            width: 140,
            text: isAdd ? 'Confirm Add' : 'Confirm Remove',
            onPressed: () async {
              final qty = int.tryParse(qtyController.text.trim()) ?? 0;
              if (qty <= 0) {
                Snackbars.showError(context, 'Enter a valid quantity');
                return;
              }
              if (!isAdd && product.quantity < qty) {
                Snackbars.showError(context, 'Insufficient stock! Available: ${product.quantity}');
                return;
              }

              Navigator.pop(ctx);

              final success = await provider.performAction(
                actionType, qty,
                remarksController.text.trim().isNotEmpty
                    ? remarksController.text.trim()
                    : 'Via QR Scanner',
              );

              if (!mounted) return;

              if (success) {
                context.read<InventoryProvider>().refreshProducts();
                context.read<DashboardProvider>().refreshDashboard();
                context.read<TransactionProvider>().fetchAllTransactions();
                Snackbars.showSuccess(
                  context,
                  isAdd
                      ? 'Added $qty units to ${product.productName}'
                      : 'Removed $qty units from ${product.productName}',
                );
              } else {
                Snackbars.showError(context, provider.errorMessage ?? 'Operation failed');
              }

              _resetScanner();
            },
          ),
        ],
      ),
    ).whenComplete(() {
      _resetScanner();
    });
  }

  void _showManualInputDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Enter QR Code Manually', style: TextStyle(color: Colors.white)),
        content: CustomTextField(
          controller: textController,
          label: 'QR Code String',
          hint: 'e.g. QR-ELEC-1001',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.subtitleText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gradient1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final code = textController.text.trim();
              Navigator.pop(ctx);
              if (code.isNotEmpty) {
                setState(() => _isProcessingScan = true);
                HapticFeedback.mediumImpact();
                controller.stop();
                await _processCode(code);
              }
            },
            child: const Text('Lookup Code', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(controller: controller, onDetect: _onDetect),
          Container(color: Colors.black.withValues(alpha: 0.5)),
          Center(
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gradient1, width: 3),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: AppColors.gradient1.withValues(alpha: 0.4), blurRadius: 24, spreadRadius: 2),
                ],
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.qr_code_scanner_rounded, color: Colors.white70, size: 48),
                    SizedBox(height: 12),
                    Text('Point camera at QR code',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text('Registered → Add / Remove Stock\nNew → Register Product',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
                    onPressed: () => controller.toggleTorch(),
                  ),
                  TextButton.icon(
                    onPressed: _showManualInputDialog,
                    icon: const Icon(Icons.keyboard_rounded, color: AppColors.gradient1),
                    label: const Text('Enter Manually', style: TextStyle(color: AppColors.gradient1, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cameraswitch_rounded, color: Colors.white),
                    onPressed: () => controller.switchCamera(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
