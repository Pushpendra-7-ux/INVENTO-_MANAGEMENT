import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/constants/constants.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/snackbars.dart';
import '../../../core/routes/routes.dart';
import '../../../domain/entities/product_entity.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/section_header.dart';
import '../../widgets/custom_button.dart';
import '../../viewmodels/product_form_viewmodel.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/transaction_provider.dart';

class AddProductScreen extends StatelessWidget {
  final ProductEntity? product;
  final String? initialQrCode;

  const AddProductScreen({super.key, this.product, this.initialQrCode});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = ProductFormViewModel();
        if (product != null) {
          vm.initForEdit(product!);
        } else {
          vm.initForNew(customQrCode: initialQrCode);
        }
        return vm;
      },
      child: _AddProductContent(
        isEdit: product != null,
        scannedQrCode: initialQrCode,
      ),
    );
  }
}

class _AddProductContent extends StatelessWidget {
  final bool isEdit;
  final String? scannedQrCode;

  const _AddProductContent({
    required this.isEdit,
    this.scannedQrCode,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductFormViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text(isEdit ? 'Edit Product' : 'Add Product', style: const TextStyle(color: AppColors.whiteColor)),
        iconTheme: const IconThemeData(color: AppColors.whiteColor),
      ),
      body: Form(
        key: vm.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (scannedQrCode != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.buttonGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gradient1.withValues(alpha: 0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 32),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Registering Scanned QR Code',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'QR: $scannedQrCode',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            const SectionHeader(title: 'Basic Info'),
            const SizedBox(height: 16),
            CustomTextField(
              controller: vm.nameController,
              label: 'Product Name',
              hint: 'Enter product name',
              validator: Validators.required,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: vm.descriptionController,
              label: 'Description',
              hint: 'Enter description',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: vm.selectedCategory?.isNotEmpty == true ? vm.selectedCategory : K.categories.first,
              dropdownColor: AppColors.surfaceMedium,
              style: const TextStyle(color: AppColors.whiteColor, fontFamily: 'Poppins'),
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: const TextStyle(color: AppColors.subtitleText),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
              ),
              items: K.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) {
                if (val != null) vm.setCategory(val);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: vm.priceController,
                    label: 'Price',
                    hint: '0.00',
                    keyboardType: TextInputType.number,
                    validator: Validators.price,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: vm.quantityController,
                    label: 'Quantity',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: Validators.quantity,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Identifiers'),
            const SizedBox(height: 16),
            const Text('SKU', style: TextStyle(color: AppColors.whiteColor, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Text(
                vm.sku ?? 'Auto-generated SKU',
                style: const TextStyle(color: AppColors.whiteColor, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            const Text('QR Code', style: TextStyle(color: AppColors.whiteColor, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Text(
                vm.qrCode ?? 'Auto-generated QR',
                style: const TextStyle(color: AppColors.subtitleText, fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Supplier'),
            const SizedBox(height: 16),
            CustomTextField(
              controller: vm.supplierController,
              label: 'Supplier Name',
              hint: 'Enter supplier name',
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Image'),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: vm.pickImage,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gradient1, style: BorderStyle.solid),
                ),
                child: vm.imagePath?.isEmpty ?? true
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_rounded, color: AppColors.gradient1, size: 32),
                          SizedBox(height: 8),
                          Text('Tap to add image', style: TextStyle(color: AppColors.gradient1)),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: vm.imagePath!.startsWith('http')
                            ? Image.network(vm.imagePath!, fit: BoxFit.cover)
                            : Image.file(File(vm.imagePath!), fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => const Center(
                                  child: Icon(Icons.image_not_supported, color: AppColors.subtitleText, size: 40),
                                ),
                              ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
            GradientButton(
              text: vm.isEditMode ? 'Update Product' : 'Save Product',
              isLoading: vm.isLoading,
              onPressed: () async {
                final inventoryProvider = context.read<InventoryProvider>();
                final success = await vm.saveProduct(inventoryProvider);
                if (!context.mounted) return;

                if (success) {
                  // Sync all providers
                  inventoryProvider.refreshProducts();
                  context.read<DashboardProvider>().refreshDashboard();
                  context.read<TransactionProvider>().fetchAllTransactions();

                  Snackbars.showSuccess(
                    context,
                    isEdit ? 'Product updated successfully!' : 'Product saved successfully!',
                  );

                  // If it was a new product from QR scan, navigate to product detail
                  // so user can immediately add/remove stock
                  if (!isEdit && scannedQrCode != null) {
                    // Find the product we just added by QR code
                    final newProduct = await inventoryProvider.getProductByQrCode(scannedQrCode!);
                    if (context.mounted && newProduct != null) {
                      Navigator.of(context).pushReplacementNamed(
                        Routes.productDetail,
                        arguments: newProduct.id,
                      );
                    } else if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  } else {
                    Navigator.of(context).pop();
                  }
                } else {
                  // Show meaningful error
                  final errorMsg = inventoryProvider.errorMessage ?? 'Failed to save product. Please check all fields.';
                  Snackbars.showError(context, errorMsg);
                }
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

