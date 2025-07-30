import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:nanoid2/nanoid2.dart';

import '../../../core/models/product.dart';
import '../../../core/models/store.dart';
import '../../../core/models/category.dart';
import '../../../core/models/photo.dart';
import '../../../core/services/store_service.dart';
import '../../../core/services/category_service.dart';
import '../../../core/services/product_service.dart';
import '../../../core/services/photo_service.dart';
import '../../../core/services/image_picker_service.dart';
import '../../../core/validators/product_validators.dart';
import '../../../core/providers/store_context_provider.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/utils/scanner_launcher.dart';
import '../../../core/utils/number_utils.dart';
import '../../../generated/app_localizations.dart';

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
  final bool isMustCheck;
  final List<String> imeis;
  final String? photoUrl;
  final Uint8List? photoFile;

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
    required this.isMustCheck,
    required this.imeis,
    this.photoUrl,
    this.photoFile,
  });
}

/// Modern, mobile-optimized single-step product form
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
  final PhotoService _photoService = PhotoService();
  final ImagePickerService _imagePickerService = ImagePickerService();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _purchasePriceController =
      TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Form state
  String? _selectedStoreId;
  String? _selectedCategoryId;
  bool _isImeiProduct = false;
  bool _isMustCheck = false;
  List<String> _imeis = [];
  String? _photoUrl;

  // Photo state
  Photo? _selectedPhoto;
  Uint8List? _photoFile;
  bool _isUploadingPhoto = false;
  double _uploadProgress = 0.0;

  // Data lists
  List<Store> _stores = [];
  List<Category> _categories = [];

  // UI state
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadFormData();
    _initializeForm();
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
    _descriptionController.text = product.description ?? '';
    _skuController.text = product.sku;
    _purchasePriceController.text =
        NumberUtils.formatWithDots(product.purchasePrice.toInt());
    _salePriceController.text = product.salePrice != null
        ? NumberUtils.formatWithDots(product.salePrice!.toInt())
        : '';
    _quantityController.text = product.quantity.toString();
    _selectedStoreId = product.storeId;
    _selectedCategoryId = product.categoryId;
    _isImeiProduct = product.isImei;
    _isMustCheck = product.isMustCheck;
    _photoUrl = product.photoUrl;

    // Load IMEIs if this is an IMEI product
    if (product.isImei) {
      _loadProductImeis(product.id);
    }

    // Load existing photo if available
    if (product.photoUrl != null) {
      _loadExistingPhoto(product.id);
    }
  }

  Future<void> _loadFormData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      await Future.wait([
        _loadStores(),
        _loadCategories(),
      ]);

      _setDefaults();
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to load form data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _setDefaults() {
    // Guard clause: skip if editing mode
    if (widget.isEditing) return;

    final authProvider = context.read<AuthProvider>();
    final storeProvider = context.read<StoreContextProvider>();

    // Auto-select store for non-owners
    if (!authProvider.isOwner && storeProvider.hasStoreSelected) {
      _selectedStoreId = storeProvider.selectedStore!.id;
    }

    // Generate default SKU only if empty
    if (_skuController.text.isEmpty) {
      const alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      final sku = nanoid(length: 8, alphabet: alphabet);
      _skuController.text = sku;
    }
  }

  Future<void> _loadStores() async {
    try {
      final response = await _storeService.getStores(limit: 50);
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
        limit: 50,
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
      final response =
          await _productService.getProductImeis(productId, limit: 100);
      if (!mounted) return;

      final imeiList =
          response.data.map((imeiData) => imeiData['imei'] as String).toList();

      setState(() {
        _imeis = imeiList;
      });
    } catch (e) {
      debugPrint('Failed to load product IMEIs: $e');
    }
  }

  Future<void> _loadExistingPhoto(String productId) async {
    try {
      final photo = await _photoService.getProductPhoto(productId);
      if (!mounted) return;

      setState(() {
        _selectedPhoto = photo;
      });
    } catch (e) {
      debugPrint('Failed to load existing photo: $e');
    }
  }

  void _onStoreChanged(String? storeId) {
    setState(() {
      _selectedStoreId = storeId;
      _selectedCategoryId = null;
      _categories = [];
    });

    // Guard clause: only load categories if store is selected
    if (storeId == null) return;

    _loadCategories();
  }

  void _onImeiToggleChanged(bool value) {
    setState(() {
      _isImeiProduct = value;
      // Guard clause: clear IMEIs if toggled off
      if (!value) {
        _imeis.clear();
      } else {
        // For IMEI products, set quantity to 1
        _quantityController.text = '1';
      }
    });
  }

  void _onQuantityChanged(String? value) {
    // Guard clause: prevent quantity changes for IMEI products
    if (_isImeiProduct && value != '1') {
      _quantityController.text = '1';
    }
  }

  void _scanBarcodeForImei(int index) {
    // Guard clause: ensure widget is mounted
    if (!mounted) return;

    ScannerLauncher.forImeiEntry(
      context,
      title: 'Scan IMEI Barcode',
      subtitle: 'Scan barcode to auto-fill IMEI number',
      onImeiScanned: (scannedImei) {
        // Guard clause: ensure widget is mounted after scan
        if (!mounted) return;

        // Guard clause: ensure index is still valid
        if (index >= _imeis.length) return;

        setState(() {
          _imeis[index] = scannedImei;
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'IMEI filled: ${scannedImei.length > 8 ? scannedImei.substring(0, 8) : scannedImei}...'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  void _addImeiWithScan() {
    // Guard clause: ensure widget is mounted
    if (!mounted) return;

    ScannerLauncher.forImeiEntry(
      context,
      title: 'Scan IMEI Barcode',
      subtitle: 'Scan barcode to add new IMEI',
      onImeiScanned: (scannedImei) {
        // Guard clause: ensure widget is mounted after scan
        if (!mounted) return;

        setState(() {
          _imeis.add(scannedImei);
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'IMEI added: ${scannedImei.length > 8 ? scannedImei.substring(0, 8) : scannedImei}...'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  bool _validateForm() {
    // Guard clause: Basic form validation
    if (!_formKey.currentState!.validate()) return false;

    // Guard clause: Check required fields
    if (_nameController.text.trim().isEmpty) {
      _showError('Product name is required');
      return false;
    }

    if (_skuController.text.trim().isEmpty) {
      _showError('SKU is required');
      return false;
    }

    if (_purchasePriceController.text.trim().isEmpty) {
      _showError('Purchase price is required');
      return false;
    }

    if (_quantityController.text.trim().isEmpty) {
      _showError('Quantity is required');
      return false;
    }

    if (_selectedStoreId == null) {
      _showError('Please select a store');
      return false;
    }

    return true;
  }

  Future<void> _saveProduct() async {
    // Guard clause: validate form first
    if (!_validateForm()) return;

    // Guard clause: validate IMEI for IMEI products
    if (_isImeiProduct) {
      final filledImeis =
          _imeis.where((imei) => imei.trim().isNotEmpty).toList();
      final imeiError = ProductValidators.validateImeiList(filledImeis);

      if (imeiError != null) {
        _showError('IMEI Validation Error: $imeiError');
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      String? finalPhotoUrl = _photoUrl;

      // Handle photo upload during product save
      if (_photoFile != null) {
        try {
          final l10n = AppLocalizations.of(context)!;
          _showSuccessMessage(l10n.product_uploading_photo);

          // For new products, we'll upload photo after product creation
          // For existing products, upload immediately
          if (widget.initialProduct != null) {
            final uploadedPhoto = await _photoService.updateProductPhoto(
              widget.initialProduct!.id,
              _photoFile!,
              onProgress: (sent, total) {
                final progress = PhotoService.calculateUploadProgress(sent, total);
                if (mounted) {
                  setState(() => _uploadProgress = progress);
                }
              },
            );
            finalPhotoUrl = uploadedPhoto.secureUrl;
          }
        } catch (e) {
          // Don't block product save if photo upload fails
          debugPrint('Photo upload failed (non-blocking): $e');
          if (mounted) {
            final l10n = AppLocalizations.of(context)!;
            _showError('${l10n.product_photo_upload_failed}: $e');
          }
        }
      }

      final formData = ProductFormData(
        productName: productName,
        sku: sku,
        purchasePrice: purchasePrice,
        salePrice: salePrice,
        quantity: quantity,
        description: description,
        storeId: storeId!,
        categoryId: categoryId,
        isImei: isImei,
        isMustCheck: isMustCheck,
        imeis: imeis,
        photoUrl: finalPhotoUrl,
        photoFile: _photoFile,
      );

      await widget.onSave?.call(formData);

      // For new products, upload photo after product creation
      if (_photoFile != null && widget.initialProduct == null) {
        // This will be handled by the parent component after product creation
        // Pass the photo file through a callback or state management
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to save product: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Guard clause: show loading state
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Single-step form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information Section
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),

                    // Pricing & Inventory Section
                    _buildPricingSection(),
                    const SizedBox(height: 24),

                    // Store & Category Section
                    _buildStoreSection(),
                    const SizedBox(height: 24),

                    // Product Photo Section
                    _buildPhotoSection(),
                    const SizedBox(height: 24),

                    // IMEI Section (if enabled)
                    if (_isImeiProduct) ...[
                      _buildImeiSection(),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),

            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.isEditing ? 'Edit Product' : 'New Product',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (_isImeiProduct) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'IMEI',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Basic Information',
          'Enter product name and identification details',
          Icons.inventory_2,
        ),
        const SizedBox(height: 16),
        _buildCompactTextField(
          label: 'Product Name *',
          controller: _nameController,
          hint: 'Enter product name',
          validator: ProductValidators.validateProductName,
          icon: Icons.shopping_bag,
        ),
        const SizedBox(height: 16),
        _buildCompactTextField(
          label: 'SKU *',
          controller: _skuController,
          hint: 'Enter SKU code',
          validator: ProductValidators.validateSku,
          icon: Icons.qr_code,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9_-]')),
            LengthLimitingTextInputFormatter(30),
          ],
        ),
        const SizedBox(height: 16),
        _buildCompactTextField(
          label: 'Description',
          controller: _descriptionController,
          hint: 'Product description (optional)',
          icon: Icons.description,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Pricing & Inventory',
          'Set prices and manage stock quantity',
          Icons.attach_money,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildCompactTextField(
                label: 'Purchase Price *',
                controller: _purchasePriceController,
                hint: '0',
                validator: ProductValidators.validatePurchasePrice,
                icon: Icons.shopping_cart,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                onChanged: (value) {
                  // Guard clause: handle null value
                  if (value == null) return;

                  final cleanValue = value.replaceAll('.', '');
                  if (cleanValue.isNotEmpty) {
                    final formatted = NumberUtils.formatWithDots(
                        int.tryParse(cleanValue) ?? 0);
                    if (formatted != value) {
                      _purchasePriceController.value = TextEditingValue(
                        text: formatted,
                        selection:
                            TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCompactTextField(
                label: 'Sale Price',
                controller: _salePriceController,
                hint: '0',
                validator: (value) => ProductValidators.validateSalePrice(
                  value,
                  NumberUtils.parseDotFormatted(_purchasePriceController.text),
                ),
                icon: Icons.sell,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                onChanged: (value) {
                  // Guard clause: handle null value
                  if (value == null) return;

                  final cleanValue = value.replaceAll('.', '');
                  if (cleanValue.isNotEmpty) {
                    final formatted = NumberUtils.formatWithDots(
                        int.tryParse(cleanValue) ?? 0);
                    if (formatted != value) {
                      _salePriceController.value = TextEditingValue(
                        text: formatted,
                        selection:
                            TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCompactTextField(
          label: 'Quantity *',
          controller: _quantityController,
          hint: _isImeiProduct ? '1 (Fixed for IMEI)' : 'Enter quantity',
          validator: (value) =>
              ProductValidators.validateQuantityForImei(value, _isImeiProduct),
          onChanged: _onQuantityChanged,
          readOnly: _isImeiProduct,
          icon: Icons.inventory,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 16),
        _buildImeiToggle(),
        const SizedBox(height: 16),
        _buildMustCheckToggle(),
      ],
    );
  }

  Widget _buildStoreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Store & Category',
          'Select store location and product category',
          Icons.store,
        ),
        const SizedBox(height: 16),
        _buildCompactDropdown<String>(
          label: 'Store *',
          value: _stores.isNotEmpty &&
                  _stores.any((store) => store.id == _selectedStoreId)
              ? _selectedStoreId
              : null,
          hint: _stores.isEmpty ? 'Loading stores...' : 'Select store',
          icon: Icons.store,
          items: _stores
              .map((store) => DropdownMenuItem<String>(
                    value: store.id,
                    child: Text(
                      store.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ))
              .toList(),
          onChanged: _stores.isEmpty ? null : _onStoreChanged,
          validator: ProductValidators.validateStore,
        ),
        const SizedBox(height: 16),
        _buildCompactDropdown<String>(
          label: 'Category',
          value: _categories.isNotEmpty &&
                  _categories.any((cat) => cat.id == _selectedCategoryId)
              ? _selectedCategoryId
              : null,
          hint: _selectedStoreId == null
              ? 'Select store first'
              : _categories.isEmpty
                  ? 'Loading categories...'
                  : 'Select category (optional)',
          icon: Icons.category,
          items: _categories
              .map((category) => DropdownMenuItem<String>(
                    value: category.id,
                    child: Text(
                      category.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ))
              .toList(),
          onChanged: _selectedStoreId != null && _categories.isNotEmpty
              ? (value) => setState(() => _selectedCategoryId = value)
              : null,
          enabled: _selectedStoreId != null,
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          l10n.product_photo_section_title,
          l10n.product_photo_section_subtitle,
          Icons.photo_camera,
        ),
        const SizedBox(height: 16),
        _buildPhotoUploadWidget(),
      ],
    );
  }

  Widget _buildImeiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'IMEI Numbers',
          'Manage IMEI numbers for this product',
          Icons.smartphone,
        ),
        const SizedBox(height: 16),
        _buildImeiList(),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
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
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          if (widget.onCancel != null) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      widget.isEditing ? 'Update Product' : 'Create Product'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    String? Function(String?)? validator,
    void Function(String?)? onChanged,
    IconData? icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLines,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines ?? 1,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        isDense: true,
      ),
    );
  }

  Widget _buildCompactDropdown<T>({
    required String label,
    required T? value,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?)? onChanged,
    String? Function(T?)? validator,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        isDense: true,
      ),
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
    );
  }

  Widget _buildImeiToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.smartphone,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IMEI Product',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  'Enable for electronics with IMEI tracking',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Switch(
            value: _isImeiProduct,
            onChanged: _onImeiToggleChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildMustCheckToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Must Check Product',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  'Requires verification before sale',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Switch(
            value: _isMustCheck,
            onChanged: (value) {
              setState(() {
                _isMustCheck = value;
              });
            },
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildImeiList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  Icon(
                    Icons.format_list_numbered,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'IMEI Numbers',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Action buttons row
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _imeis.add('');
                        });
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add IMEI'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _addImeiWithScan(),
                      icon: const Icon(Icons.qr_code_scanner, size: 16),
                      label: const Text('Scan & Add'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_imeis.isEmpty) ...[
            Center(
              child: Text(
                'No IMEI numbers added',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _imeis.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        key: ValueKey('imei_${index}_${_imeis[index]}'),
                        initialValue: _imeis[index],
                        decoration: InputDecoration(
                          hintText: 'Enter IMEI or scan barcode',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          isDense: true,
                          suffixIcon: Container(
                            width: 48,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => _scanBarcodeForImei(index),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      Icons.qr_code_scanner,
                                      color: Theme.of(context).primaryColor,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (index < _imeis.length) {
                            _imeis[index] = value;
                          }
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(15),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _imeis.removeAt(index);
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.delete,
                          size: 16,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoUploadWidget() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedPhoto != null || _photoFile != null) ...[
            // Photo preview
            _buildPhotoPreview(),
            const SizedBox(height: 16),
            // Action buttons for existing photo
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isUploadingPhoto ? null : _changePhoto,
                    icon: const Icon(Icons.edit, size: 16),
                    label: Text(l10n.product_change_photo),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isUploadingPhoto ? null : _removePhoto,
                    icon: const Icon(Icons.delete, size: 16),
                    label: Text(l10n.product_remove_photo),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
            if (_isUploadingPhoto) ...[
              const SizedBox(height: 16),
              _buildUploadProgress(),
            ],
          ] else ...[
            // Add photo button
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.product_no_photo,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isUploadingPhoto ? null : _addPhoto,
                      icon: const Icon(Icons.add_a_photo, size: 16),
                      label: Text(l10n.product_add_photo),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoPreview() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[100],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _photoFile != null
            ? Image.memory(
                _photoFile!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              )
            : _selectedPhoto != null
                ? Image.network(
                    _selectedPhoto!.mediumUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildUploadProgress() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.cloud_upload,
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.product_uploading_photo,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '${_uploadProgress.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _uploadProgress / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  // Photo management methods
  Future<void> _addPhoto() async {
    await _selectAndSetPhoto();
  }

  Future<void> _changePhoto() async {
    await _selectAndSetPhoto();
  }

  Future<void> _selectAndSetPhoto() async {
    try {
      final imageBytes = await _imagePickerService.pickImage(context);
      if (imageBytes == null || !mounted) return;

      setState(() {
        _photoFile = imageBytes;
        _selectedPhoto = null; // Clear network photo when new file is selected
      });

      final l10n = AppLocalizations.of(context)!;
      _showSuccessMessage(l10n.product_photo_selected);
    } catch (e) {
      debugPrint('Error selecting photo: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _showError('${l10n.product_photo_selection_failed}: $e');
      }
    }
  }

  void _removePhoto() {
    setState(() {
      _photoFile = null;
      _selectedPhoto = null;
      _photoUrl = null;
    });

    final l10n = AppLocalizations.of(context)!;
    _showSuccessMessage(l10n.product_photo_removed);
  }

  // Getters for form data using guard clauses
  String get productName => _nameController.text.trim();
  String get sku => _skuController.text.trim();
  double get purchasePrice =>
      NumberUtils.parseDotFormatted(_purchasePriceController.text);
  double? get salePrice {
    final text = _salePriceController.text.trim();
    return text.isEmpty ? null : NumberUtils.parseDotFormatted(text);
  }

  int get quantity => int.tryParse(_quantityController.text) ?? 0;
  String? get description {
    final text = _descriptionController.text.trim();
    return text.isEmpty ? null : text;
  }

  String? get storeId => _selectedStoreId;
  String? get categoryId => _selectedCategoryId;
  bool get isImei => _isImeiProduct;
  bool get isMustCheck => _isMustCheck;
  List<String> get imeis =>
      _imeis.where((imei) => imei.trim().isNotEmpty).toList();
  String? get photoUrl => _photoUrl ?? _selectedPhoto?.secureUrl;
  Uint8List? get photoFile => _photoFile;
}
