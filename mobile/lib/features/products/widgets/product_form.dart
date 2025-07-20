import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/models/product.dart';
import '../../../core/models/store.dart';
import '../../../core/models/category.dart';
import '../../../core/services/store_service.dart';
import '../../../core/services/category_service.dart';
import '../../../core/validators/product_validators.dart';
import '../../../core/widgets/form_components.dart';
import '../../../core/providers/store_context_provider.dart';
import '../../../core/auth/auth_provider.dart';

/// Form data model for product creation/editing
class ProductFormData {
  final String productName;
  final String sku;
  final String barcode;
  final double purchasePrice;
  final double? salePrice;
  final int quantity;
  final String? description;
  final String storeId;
  final String? categoryId;
  final bool isImei;
  final List<String> imeis;
  final String? photoUrl;

  ProductFormData({
    required this.productName,
    required this.sku,
    required this.barcode,
    required this.purchasePrice,
    this.salePrice,
    required this.quantity,
    this.description,
    required this.storeId,
    this.categoryId,
    required this.isImei,
    required this.imeis,
    this.photoUrl,
  });
}

/// Comprehensive product form for create and edit operations
class ProductForm extends StatefulWidget {
  final Product? initialProduct;
  final Function(ProductFormData)? onSave;
  final VoidCallback? onCancel;
  final bool isEditing;

  const ProductForm({
    super.key,
    this.initialProduct,
    this.onSave,
    this.onCancel,
    this.isEditing = false,
  });

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  
  // Service instances
  final StoreService _storeService = StoreService();
  final CategoryService _categoryService = CategoryService();
  
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _purchasePriceController = TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  // Form state
  String? _selectedStoreId;
  String? _selectedCategoryId;
  bool _isImeiProduct = false;
  List<String> _imeis = [];
  String? _photoUrl;
  
  // Data lists
  List<Store> _stores = [];
  List<Category> _categories = [];
  
  // UI state
  bool _isLoading = true;
  bool _isSaving = false;
  int _currentStep = 0;
  final int _totalSteps = 3;
  
  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadFormData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _pageController.dispose();
    super.dispose();
  }
  
  void _initializeForm() {
    if (widget.initialProduct != null) {
      final product = widget.initialProduct!;
      _nameController.text = product.name;
      _skuController.text = product.sku;
      _barcodeController.text = product.barcode;
      _purchasePriceController.text = product.purchasePrice.toStringAsFixed(2);
      _salePriceController.text = product.salePrice?.toStringAsFixed(2) ?? '';
      _quantityController.text = product.quantity.toString();
      _descriptionController.text = ''; // Product model doesn't have description
      _selectedStoreId = product.storeId;
      _selectedCategoryId = product.categoryId;
      _isImeiProduct = product.isImei;
      _photoUrl = null; // Product model doesn't have photoUrl
      // Note: IMEI list would need to be loaded separately if editing
    }
  }
  
  Future<void> _loadFormData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await Future.wait([
        _loadStores(),
        _loadCategories(),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load form data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _loadStores() async {
    try {
      final response = await _storeService.getStores(limit: 100);
      setState(() {
        _stores = response.data;
        
        // Auto-select store for non-owner users
        final authProvider = context.read<AuthProvider>();
        final storeProvider = context.read<StoreContextProvider>();
        
        if (!authProvider.isOwner && storeProvider.hasStoreSelected) {
          _selectedStoreId = storeProvider.selectedStore!.id;
        }
      });
    } catch (e) {
      debugPrint('Failed to load stores: $e');
    }
  }
  
  Future<void> _loadCategories() async {
    try {
      final response = await _categoryService.getCategories(
        storeId: _selectedStoreId,
        limit: 100,
      );
      setState(() {
        _categories = response.data;
      });
    } catch (e) {
      debugPrint('Failed to load categories: $e');
    }
  }
  
  void _onStoreChanged(String? storeId) {
    setState(() {
      _selectedStoreId = storeId;
      _selectedCategoryId = null; // Reset category when store changes
      _categories = []; // Clear categories
    });
    
    if (storeId != null) {
      _loadCategories(); // Reload categories for new store
    }
  }
  
  void _onImeiToggleChanged(bool value) {
    setState(() {
      _isImeiProduct = value;
      if (!value) {
        _imeis.clear(); // Clear IMEIs if toggled off
      }
    });
  }
  
  void _onQuantityChanged(String? value) {
    // Update IMEI count based on quantity when IMEI product
    if (_isImeiProduct && value != null && value.isNotEmpty) {
      final quantity = int.tryParse(value);
      if (quantity != null && quantity != _imeis.length) {
        setState(() {
          if (quantity > _imeis.length) {
            // Add empty IMEIs
            _imeis.addAll(List.filled(quantity - _imeis.length, ''));
          } else if (quantity < _imeis.length) {
            // Remove excess IMEIs
            _imeis = _imeis.take(quantity).toList();
          }
        });
      }
    }
  }
  
  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Basic Information
        return ProductValidators.validateProductName(_nameController.text) == null &&
               ProductValidators.validateSku(_skuController.text) == null &&
               ProductValidators.validateBarcode(_barcodeController.text) == null;
      case 1: // Pricing & Inventory
        final purchasePriceError = ProductValidators.validatePurchasePrice(_purchasePriceController.text);
        final salePriceError = ProductValidators.validateSalePrice(
          _salePriceController.text,
          double.tryParse(_purchasePriceController.text),
        );
        final quantityError = ProductValidators.validateQuantity(_quantityController.text);
        return purchasePriceError == null && salePriceError == null && quantityError == null;
      case 2: // Store & Additional Info
        return ProductValidators.validateStore(_selectedStoreId) == null;
      default:
        return true;
    }
  }
  
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      // Create form data object
      final formData = ProductFormData(
        productName: productName,
        sku: sku,
        barcode: barcode,
        purchasePrice: purchasePrice,
        salePrice: salePrice,
        quantity: quantity,
        description: description,
        storeId: storeId!,
        categoryId: categoryId,
        isImei: isImei,
        imeis: imeis,
        photoUrl: photoUrl,
      );
      
      // Call parent save handler
      widget.onSave?.call(formData);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save product: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          
          const SizedBox(height: 16),
          
          // Form content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildBasicInfoStep(),
                _buildPricingStep(),
                _buildStoreAndAdditionalInfoStep(),
              ],
            ),
          ),
          
          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }
  
  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: isCompleted || isActive 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
  
  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          WMSTextFormField(
            label: 'Product Name *',
            controller: _nameController,
            hint: 'Enter product name',
            validator: ProductValidators.validateProductName,
            prefixIcon: const Icon(Icons.inventory_2),
          ),
          
          const SizedBox(height: 16),
          
          WMSTextFormField(
            label: 'SKU *',
            controller: _skuController,
            hint: 'Enter SKU (e.g., PROD001)',
            validator: ProductValidators.validateSku,
            prefixIcon: const Icon(Icons.qr_code),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9_-]')),
              LengthLimitingTextInputFormatter(50),
            ],
          ),
          
          const SizedBox(height: 16),
          
          WMSTextFormField(
            label: 'Barcode *',
            controller: _barcodeController,
            hint: 'Enter or scan barcode',
            validator: ProductValidators.validateBarcode,
            prefixIcon: const Icon(Icons.barcode_reader),
            suffixIcon: IconButton(
              onPressed: () {
                // TODO: Implement barcode scanner
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Barcode scanner coming soon!')),
                );
              },
              icon: const Icon(Icons.qr_code_scanner),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
              LengthLimitingTextInputFormatter(50),
            ],
          ),
          
          const SizedBox(height: 16),
          
          WMSTextFormField(
            label: 'Description',
            controller: _descriptionController,
            hint: 'Enter product description (optional)',
            validator: ProductValidators.validateDescription,
            maxLines: 3,
            prefixIcon: const Icon(Icons.description),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPricingStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pricing & Inventory',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          WMSCurrencyFormField(
            label: 'Purchase Price *',
            controller: _purchasePriceController,
            hint: 'Enter purchase price',
            validator: ProductValidators.validatePurchasePrice,
          ),
          
          const SizedBox(height: 16),
          
          WMSCurrencyFormField(
            label: 'Sale Price',
            controller: _salePriceController,
            hint: 'Enter sale price (optional)',
            validator: (value) => ProductValidators.validateSalePrice(
              value,
              double.tryParse(_purchasePriceController.text),
            ),
          ),
          
          const SizedBox(height: 16),
          
          WMSTextFormField(
            label: 'Quantity *',
            controller: _quantityController,
            hint: 'Enter quantity',
            keyboardType: TextInputType.number,
            validator: ProductValidators.validateQuantity,
            onChanged: _onQuantityChanged,
            prefixIcon: const Icon(Icons.inventory),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
          ),
          
          const SizedBox(height: 24),
          
          WMSSwitchFormField(
            label: 'IMEI Product',
            subtitle: 'Enable if this product requires IMEI tracking',
            value: _isImeiProduct,
            onChanged: _onImeiToggleChanged,
          ),
          
          if (_isImeiProduct) ...[
            const SizedBox(height: 16),
            WMSImeiArrayFormField(
              label: 'IMEI Numbers',
              initialImeis: _imeis,
              expectedQuantity: int.tryParse(_quantityController.text),
              onChanged: (imeis) {
                setState(() {
                  _imeis = imeis;
                });
              },
              validator: (imeis) {
                final quantity = int.tryParse(_quantityController.text) ?? 0;
                return ProductValidators.validateImeiList(imeis ?? [], quantity);
              },
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildStoreAndAdditionalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Store & Additional Information',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          WMSDropdownFormField<String>(
            label: 'Store *',
            hint: 'Select store',
            value: _selectedStoreId,
            items: _stores.map((store) {
              return DropdownMenuItem<String>(
                value: store.id,
                child: Text('${store.name} - ${store.address}'),
              );
            }).toList(),
            onChanged: _onStoreChanged,
            validator: ProductValidators.validateStore,
            prefixIcon: const Icon(Icons.store),
          ),
          
          const SizedBox(height: 16),
          
          WMSDropdownFormField<String>(
            label: 'Category',
            hint: 'Select category (optional)',
            value: _selectedCategoryId,
            items: _categories.map((category) {
              return DropdownMenuItem<String>(
                value: category.id,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategoryId = value;
              });
            },
            validator: ProductValidators.validateCategory,
            prefixIcon: const Icon(Icons.category),
            enabled: _selectedStoreId != null,
          ),
          
          const SizedBox(height: 16),
          
          WMSPhotoFormField(
            label: 'Product Photo',
            imageUrl: _photoUrl,
            onChanged: (url) {
              setState(() {
                _photoUrl = url;
              });
            },
            onImagePicked: () {
              // TODO: Implement image picker
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Image picker coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            TextButton(
              onPressed: _previousStep,
              child: const Text('Previous'),
            ),
            const SizedBox(width: 16),
          ],
          
          if (widget.onCancel != null) ...[
            TextButton(
              onPressed: widget.onCancel,
              child: const Text('Cancel'),
            ),
            const Spacer(),
          ] else if (_currentStep > 0) ...[
            const Spacer(),
          ],
          
          if (_currentStep < _totalSteps - 1)
            ElevatedButton(
              onPressed: _validateCurrentStep() ? _nextStep : null,
              child: const Text('Next'),
            )
          else
            ElevatedButton(
              onPressed: _isSaving ? null : _saveProduct,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.isEditing ? 'Update Product' : 'Create Product'),
            ),
        ],
      ),
    );
  }
  
  // Getters for form data
  String get productName => _nameController.text.trim();
  String get sku => _skuController.text.trim();
  String get barcode => _barcodeController.text.trim();
  double get purchasePrice => double.tryParse(_purchasePriceController.text) ?? 0.0;
  double? get salePrice {
    final text = _salePriceController.text.trim();
    return text.isEmpty ? null : double.tryParse(text);
  }
  int get quantity => int.tryParse(_quantityController.text) ?? 0;
  String? get description {
    final text = _descriptionController.text.trim();
    return text.isEmpty ? null : text;
  }
  String? get storeId => _selectedStoreId;
  String? get categoryId => _selectedCategoryId;
  bool get isImei => _isImeiProduct;
  List<String> get imeis => _imeis.where((imei) => imei.trim().isNotEmpty).toList();
  String? get photoUrl => _photoUrl;
}