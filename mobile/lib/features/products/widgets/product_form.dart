import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/models/product.dart';
import '../../../core/models/store.dart';
import '../../../core/models/category.dart';
import '../../../core/services/store_service.dart';
import '../../../core/services/category_service.dart';
import '../../../core/services/product_service.dart';
import '../../../core/validators/product_validators.dart';
import '../../../core/widgets/form_components.dart';
import '../../../core/providers/store_context_provider.dart';
import '../../../core/auth/auth_provider.dart';

/// Form data model for product creation/editing
class ProductFormData {
  final String productName;
  final String sku;
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

/// Single-step product form for create and edit operations
class ProductForm extends StatefulWidget {
  final Product? initialProduct;
  final Future<void> Function(ProductFormData)? onSave;
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
  
  // Service instances
  final StoreService _storeService = StoreService();
  final CategoryService _categoryService = CategoryService();
  final ProductService _productService = ProductService();
  
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
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
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  void _initializeForm() {
    // Guard clause: skip if no initial product
    if (widget.initialProduct == null) return;
    
    final product = widget.initialProduct!;
    _nameController.text = product.name;
    _skuController.text = product.sku;
    _purchasePriceController.text = product.purchasePrice.toStringAsFixed(2);
    _salePriceController.text = product.salePrice?.toStringAsFixed(2) ?? '';
    _quantityController.text = product.quantity.toString();
    _descriptionController.text = ''; // Product model doesn't have description
    _selectedStoreId = product.storeId;
    _selectedCategoryId = product.categoryId;
    _isImeiProduct = product.isImei;
    _photoUrl = null; // Product model doesn't have photoUrl
    
    // Load IMEIs if this is an IMEI product
    if (product.isImei) {
      _loadProductImeis(product.id);
    }
  }
  
  Future<void> _loadFormData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await Future.wait([
        _loadStores(),
        _loadCategories(),
      ]);
      
      // Set defaults after loading
      _setDefaults();
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load form data: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _setDefaults() {
    // Guard clause: skip if editing mode
    if (widget.isEditing) return;
    
    final authProvider = context.read<AuthProvider>();
    final storeProvider = context.read<StoreContextProvider>();
    
    // Auto-select store for non-owners with guard clause
    if (!authProvider.isOwner && storeProvider.hasStoreSelected) {
      _selectedStoreId = storeProvider.selectedStore!.id;
    }
    
    // Generate default SKU only if empty
    if (_skuController.text.isEmpty) {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
      _skuController.text = 'SKU$timestamp';
    }
  }
  
  Future<void> _loadStores() async {
    try {
      final response = await _storeService.getStores(limit: 100);
      if (!mounted) return;
      
      setState(() {
        _stores = response.data;
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
      if (!mounted) return;
      
      setState(() {
        _categories = response.data;
      });
    } catch (e) {
      debugPrint('Failed to load categories: $e');
    }
  }
  
  Future<void> _loadProductImeis(String productId) async {
    try {
      final response = await _productService.getProductImeis(productId, limit: 100);
      if (!mounted) return;
      
      // Extract IMEI codes from the response
      final imeiList = response.data.map((imeiData) => imeiData['imei'] as String).toList();
      
      setState(() {
        _imeis = imeiList;
      });
    } catch (e) {
      debugPrint('Failed to load product IMEIs: $e');
      // Don't show error to user for IMEIs loading failure
    }
  }
  
  void _onStoreChanged(String? storeId) {
    setState(() {
      _selectedStoreId = storeId;
      _selectedCategoryId = null; // Reset category when store changes
      _categories = []; // Clear categories
    });
    
    // Guard clause: only load categories if store is selected
    if (storeId == null) return;
    
    _loadCategories(); // Reload categories for new store
  }
  
  void _onImeiToggleChanged(bool value) {
    setState(() {
      _isImeiProduct = value;
      // Guard clause: clear IMEIs if toggled off
      if (!value) {
        _imeis.clear();
      } else {
        // For IMEI products, set quantity to 1 and make it read-only
        _quantityController.text = '1';
      }
    });
  }
  
  void _onQuantityChanged(String? value) {
    // Guard clause: prevent quantity changes for IMEI products
    if (_isImeiProduct && value != '1') {
      // Reset to 1 for IMEI products
      _quantityController.text = '1';
    }
  }
  
  Future<void> _saveProduct() async {
    // Guard clause: validate form first
    if (!_formKey.currentState!.validate()) return;
    
    // Guard clause: validate IMEI for IMEI products
    if (_isImeiProduct) {
      final filledImeis = _imeis.where((imei) => imei.trim().isNotEmpty).toList();
      final imeiError = ProductValidators.validateImeiList(filledImeis);
      
      if (imeiError != null) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('IMEI Validation Error: $imeiError'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
    }
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      // Create form data object
      final formData = ProductFormData(
        productName: this.productName,
        sku: this.sku,
        purchasePrice: this.purchasePrice,
        salePrice: this.salePrice,
        quantity: this.quantity,
        description: this.description,
        storeId: this.storeId!,
        categoryId: this.categoryId,
        isImei: this.isImei,
        imeis: this.imeis,
        photoUrl: this.photoUrl,
      );
      
      // Call parent save handler and wait for completion
      await widget.onSave?.call(formData);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save product: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (!mounted) return;
      
      setState(() {
        _isSaving = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Guard clause: show loading state
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Single scrollable form
          Expanded(
            child: _buildSingleStepForm(),
          ),
          
          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }
  
  Widget _buildSingleStepForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Information Section
          _buildSectionHeader('Basic Information'),
          const SizedBox(height: 16),
          _buildBasicInfoFields(),
          
          const SizedBox(height: 32),
          
          // Pricing & Inventory Section
          _buildSectionHeader('Pricing & Inventory'),
          const SizedBox(height: 16),
          _buildPricingFields(),
          
          const SizedBox(height: 32),
          
          // Store & Category Section
          _buildSectionHeader('Store & Category'),
          const SizedBox(height: 16),
          _buildStoreFields(),
          
          const SizedBox(height: 32),
          
          // Additional Information Section
          _buildSectionHeader('Additional Information'),
          const SizedBox(height: 16),
          _buildAdditionalFields(),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
  
  Widget _buildBasicInfoFields() {
    return Column(
      children: [
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
          label: 'Description',
          controller: _descriptionController,
          hint: 'Enter product description (optional)',
          validator: ProductValidators.validateDescription,
          maxLines: 3,
          prefixIcon: const Icon(Icons.description),
        ),
      ],
    );
  }
  
  Widget _buildPricingFields() {
    return Column(
      children: [
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
          hint: _isImeiProduct ? 'Fixed at 1 for IMEI products' : 'Enter quantity',
          keyboardType: TextInputType.number,
          validator: (value) => ProductValidators.validateQuantityForImei(value, _isImeiProduct),
          onChanged: _onQuantityChanged,
          readOnly: _isImeiProduct,
          enabled: !_isImeiProduct,
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
            onChanged: (imeis) {
              setState(() {
                _imeis = imeis;
              });
            },
            validator: (imeis) {
              return ProductValidators.validateImeiList(imeis ?? []);
            },
          ),
        ],
      ],
    );
  }
  
  Widget _buildStoreFields() {
    return Column(
      children: [
        WMSDropdownFormField<String>(
          label: 'Store *',
          hint: _stores.isEmpty ? 'Loading stores...' : 'Select store',
          value: _stores.isNotEmpty && _stores.any((store) => store.id == _selectedStoreId) ? _selectedStoreId : null,
          items: _stores.map((store) {
            return DropdownMenuItem<String>(
              value: store.id,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text(
                  '${store.name} - ${store.address}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            );
          }).toList(),
          onChanged: _stores.isEmpty ? null : _onStoreChanged,
          validator: ProductValidators.validateStore,
          prefixIcon: const Icon(Icons.store),
        ),
        
        const SizedBox(height: 16),
        
        WMSDropdownFormField<String>(
          label: 'Category',
          hint: _selectedStoreId == null 
              ? 'Select store first' 
              : _categories.isEmpty 
                  ? 'Loading categories...' 
                  : 'Select category (optional)',
          value: _categories.isNotEmpty && _categories.any((category) => category.id == _selectedCategoryId) ? _selectedCategoryId : null,
          items: _categories.map((category) {
            return DropdownMenuItem<String>(
              value: category.id,
              child: Text(category.name),
            );
          }).toList(),
          onChanged: _selectedStoreId != null && _categories.isNotEmpty ? (value) {
            setState(() {
              _selectedCategoryId = value;
            });
          } : null,
          validator: ProductValidators.validateCategory,
          prefixIcon: const Icon(Icons.category),
          enabled: _selectedStoreId != null,
        ),
      ],
    );
  }
  
  Widget _buildAdditionalFields() {
    return Column(
      children: [
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
    );
  }
  
  Widget _buildActionButtons() {
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
          // Cancel button with guard clause
          if (widget.onCancel != null) ...[
            TextButton(
              onPressed: widget.onCancel,
              child: const Text('Cancel'),
            ),
            const Spacer(),
          ] else ...[
            const Spacer(),
          ],
          
          // Save button
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
  
  // Getters for form data using guard clauses
  String get productName => _nameController.text.trim();
  String get sku => _skuController.text.trim();
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