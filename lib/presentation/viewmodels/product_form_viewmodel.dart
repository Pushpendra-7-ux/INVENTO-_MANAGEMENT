import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/inventory_provider.dart';
import '../../core/constants/constants.dart';

class ProductFormViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController supplierController = TextEditingController();
  
  String? _id;
  String? _qrCode;
  String? _sku;
  String? _selectedCategory;
  String? _imagePath;
  DateTime? _createdAt;
  
  bool _isEditMode = false;
  bool _isLoading = false;

  String? get selectedCategory => _selectedCategory;
  String? get imagePath => _imagePath;
  bool get isEditMode => _isEditMode;
  bool get isLoading => _isLoading;
  String? get sku => _sku;
  String? get qrCode => _qrCode;

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void initForNew({String? customQrCode}) {
    _isEditMode = false;
    _id = const Uuid().v4();
    _qrCode = customQrCode ?? const Uuid().v4(); // Use scanned QR code if provided
    _selectedCategory = K.categories.first;
    _createdAt = DateTime.now();
    
    // Clear controllers
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    quantityController.clear();
    supplierController.clear();
    _imagePath = null;
    
    generateSku();
  }

  void initForEdit(ProductEntity product) {
    _isEditMode = true;
    _id = product.id;
    _qrCode = product.qrCode;
    _sku = product.sku;
    _selectedCategory = product.category;
    _imagePath = product.image;
    _createdAt = product.createdAt;

    nameController.text = product.productName;
    descriptionController.text = product.description ?? '';
    priceController.text = product.price.toString();
    quantityController.text = product.quantity.toString();
    supplierController.text = product.supplier ?? '';
  }

  void generateSku() {
    if (_selectedCategory == null) return;
    
    // Generate SKU based on category, e.g. SKU-ELEC-1234567 format
    String catPrefix = _selectedCategory!.toUpperCase();
    if (catPrefix.length > 4) {
      catPrefix = catPrefix.substring(0, 4);
    }
    
    // Use full microsecond timestamp to ensure uniqueness
    final now = DateTime.now();
    final suffix = '${now.millisecondsSinceEpoch % 1000000}${now.microsecond % 100}';
    _sku = 'SKU-$catPrefix-$suffix';
    notifyListeners();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _imagePath = image.path;
        notifyListeners();
      }
    } catch (e) {
      // Handle error optionally
    }
  }

  Future<bool> saveProduct(InventoryProvider provider) async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return false;
    }
    
    if (_selectedCategory == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final product = ProductEntity(
        id: _id ?? const Uuid().v4(),
        productName: nameController.text.trim(),
        description: descriptionController.text.trim(),
        category: _selectedCategory!,
        price: double.parse(priceController.text.trim()),
        quantity: int.parse(quantityController.text.trim()),
        qrCode: _qrCode,
        sku: _sku,
        supplier: supplierController.text.trim(),
        image: _imagePath,
        createdAt: _createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditMode) {
        await provider.updateProduct(product);
      } else {
        await provider.addProduct(product);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false; // Error handled by provider mostly
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    quantityController.dispose();
    supplierController.dispose();
    super.dispose();
  }
}
