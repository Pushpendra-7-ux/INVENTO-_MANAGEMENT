import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/routes/routes.dart';
import '../../../core/utils/snackbars.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/qr_widget.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/section_header.dart';
import '../../widgets/touchable_scale.dart';
import '../../viewmodels/product_detail_viewmodel.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/transaction_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ProductDetailViewModel>();
      final inv = context.read<InventoryProvider>();
      final tx = context.read<TransactionProvider>();
      vm.loadProduct(widget.productId, inv, tx);
    });
  }

  void _showActionSheet(BuildContext context, ProductDetailViewModel vm, bool isSell) {
    final qtyController = TextEditingController(text: '1');
    final remarksController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          top: 24.0,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSell ? 'Sell Product Stock' : 'Add Product Stock',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.whiteColor,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: qtyController,
              label: 'Quantity',
              hint: '1',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: remarksController,
              label: 'Remarks (Optional)',
              hint: isSell ? 'Customer order, retail sale...' : 'Supplier restock, inventory audit...',
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: isSell ? 'Confirm Sale' : 'Confirm Restock',
              onPressed: () async {
                final qty = int.tryParse(qtyController.text) ?? 0;
                if (qty <= 0) {
                  Snackbars.showError(context, 'Please enter a valid quantity');
                  return;
                }

                bool success = false;
                if (isSell) {
                  success = await vm.sellProduct(
                    qty,
                    remarksController.text,
                    ctx.read<InventoryProvider>(),
                    ctx.read<TransactionProvider>(),
                  );
                } else {
                  success = await vm.addStock(
                    qty,
                    remarksController.text,
                    ctx.read<InventoryProvider>(),
                    ctx.read<TransactionProvider>(),
                  );
                }

                if (context.mounted) {
                  if (success) {
                    // Global seamless provider sync
                    context.read<InventoryProvider>().refreshProducts();
                    context.read<DashboardProvider>().refreshDashboard();
                    context.read<TransactionProvider>().fetchAllTransactions();
                    Snackbars.showSuccess(context, isSell ? 'Sold $qty units successfully' : 'Restocked $qty units successfully');
                    Navigator.pop(ctx);
                  } else {
                    Snackbars.showError(context, 'Operation failed. Check available stock.');
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductDetailViewModel>();

    if (vm.isLoading || vm.product == null) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(child: CircularProgressIndicator(color: AppColors.gradient1)),
      );
    }

    final product = vm.product!;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.backgroundColor,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.whiteColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product_img_${product.id}',
                child: product.image?.isNotEmpty == true
                    ? (product.image!.startsWith('http')
                        ? Image.network(product.image!, fit: BoxFit.cover)
                        : Image.file(File(product.image!), fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(
                              color: AppColors.surfaceMedium,
                              child: const Icon(Icons.image_not_supported, color: AppColors.subtitleText, size: 60),
                            ),
                          ))
                    : Container(
                        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                        child: Center(
                          child: Text(
                            product.productName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontSize: 80, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.productName,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.gradient1.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.gradient1.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(color: AppColors.whiteColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildPillBadge('SKU', product.sku ?? 'N/A'),
                      _buildPillBadge('Supplier', product.supplier ?? 'General'),
                      _buildPillBadge('Status', product.status),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderColor, width: 0.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Unit Price', style: TextStyle(color: AppColors.subtitleText, fontSize: 12)),
                              const SizedBox(height: 4),
                              GradientText(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderColor, width: 0.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Stock Quantity', style: TextStyle(color: AppColors.subtitleText, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(
                                '${product.quantity} units',
                                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (product.qrCode != null) ...[
                    const SectionHeader(title: 'QR Code Identifier'),
                    const SizedBox(height: 8),
                    Center(child: QrDisplayWidget(data: product.qrCode!, size: 180)),
                    const SizedBox(height: 24),
                  ],
                  if (product.description?.isNotEmpty == true) ...[
                    const SectionHeader(title: 'Description'),
                    const SizedBox(height: 8),
                    Text(
                      product.description!,
                      style: const TextStyle(color: AppColors.subtitleText, fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                  ],
                  SectionHeader(title: 'Transaction Audit Trail (${vm.productTransactions.length})'),
                  const SizedBox(height: 12),
                  if (vm.productTransactions.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text('No transaction activity recorded yet.', style: TextStyle(color: AppColors.subtitleText)),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: vm.productTransactions.length,
                      itemBuilder: (ctx, index) {
                        return TransactionTile(
                          transaction: vm.productTransactions[index],
                          productName: product.productName,
                        );
                      },
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: AppColors.borderColor, width: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: GradientButton(
                text: 'Sell',
                onPressed: () => _showActionSheet(context, vm, true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TouchableScale(
                onTap: () => _showActionSheet(context, vm, false),
                borderRadius: BorderRadius.circular(12),
                glowColor: AppColors.successColor,
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: AppColors.successColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.successColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('Add Stock', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: AppColors.whiteColor),
              onPressed: () async {
                await Navigator.of(context).pushNamed(Routes.addProduct, arguments: product);
                if (mounted) {
                  context.read<InventoryProvider>().refreshProducts();
                  context.read<DashboardProvider>().refreshDashboard();
                  context.read<TransactionProvider>().fetchAllTransactions();
                  vm.refresh(context.read<InventoryProvider>(), context.read<TransactionProvider>());
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: AppColors.errorColor),
              onPressed: () async {
                final confirmed = await ConfirmationDialog.show(
                  context: context,
                  title: 'Delete Product',
                  message: 'Are you sure you want to delete "${product.productName}"? This action cannot be undone.',
                  confirmText: 'Delete',
                  isDestructive: true,
                );
                if (confirmed == true && context.mounted) {
                  final inv = context.read<InventoryProvider>();
                  final tx = context.read<TransactionProvider>();
                  final dash = context.read<DashboardProvider>();
                  final success = await vm.deleteProduct(inv, tx);
                  if (context.mounted) {
                    if (success) {
                      inv.refreshProducts();
                      dash.refreshDashboard();
                      tx.fetchAllTransactions();
                      Snackbars.showSuccess(context, 'Product deleted successfully');
                      Navigator.pop(context);
                    } else {
                      Snackbars.showError(context, 'Failed to delete product');
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(color: AppColors.subtitleText, fontSize: 12)),
          Text(value, style: const TextStyle(color: AppColors.whiteColor, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
