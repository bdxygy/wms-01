import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/models/transaction.dart';
import '../../../core/models/api_requests.dart';
import '../../../core/models/store.dart';
import '../../../core/models/user.dart';
import '../../../core/models/product.dart';
import '../../../core/models/photo.dart';
import '../../../core/services/store_service.dart';
import '../../../core/services/product_service.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/providers/store_context_provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/utils/scanner_launcher.dart';
import 'transaction_photo_upload.dart';

// Transaction form data model
class TransactionFormData {
  final TransactionType type;
  final String storeId;
  final String? destinationStoreId;
  final String? photoProofUrl;
  final String? transferProofUrl;
  final String? customerName;
  final String? customerPhone;
  final String? tradeInProductId;
  final List<TransactionItemRequest> items;
  final Uint8List? pendingPhotoProofBytes;
  final Uint8List? pendingTransferProofBytes;

  TransactionFormData({
    required this.type,
    required this.storeId,
    this.destinationStoreId,
    this.photoProofUrl,
    this.transferProofUrl,
    this.customerName,
    this.customerPhone,
    this.tradeInProductId,
    required this.items,
    this.pendingPhotoProofBytes,
    this.pendingTransferProofBytes,
  });

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }
}

class TransactionForm extends StatefulWidget {
  final Transaction? initialTransaction;
  final bool isEditing;
  final bool isLoading;
  final Function(TransactionFormData) onSave;
  final VoidCallback onCancel;

  const TransactionForm({
    super.key,
    this.initialTransaction,
    required this.isEditing,
    this.isLoading = false,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _storeService = StoreService();
  final _productService = ProductService();

  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _tradeInSearchController = TextEditingController();

  // Store photo data for upload after transaction creation
  Uint8List? _pendingPhotoProofBytes;
  Uint8List? _pendingTransferProofBytes;

  TransactionType _selectedType = TransactionType.sale;
  String? _selectedStoreId;
  String? _selectedDestinationStoreId;
  String? _photoProofUrl;
  String? _photoProofId;
  String? _transferProofUrl;
  String? _transferProofId;
  String? _selectedTradeInProductId;
  Product? _selectedTradeInProduct;
  List<TransactionItemRequest> _items = [];

  List<Store> _stores = [];
  List<Product> _searchResults = [];
  bool _isSearching = false;
  List<Product> _tradeInSearchResults = [];
  bool _isTradeInSearching = false;
  bool _showTradeInSearchResults = false;
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadStores();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _searchController.dispose();
    _quantityController.dispose();
    _tradeInSearchController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    final storeContext = context.read<StoreContextProvider>().selectedStore;
    final user = context.read<AuthProvider>().user;

    // Guard clause: Handle edit mode
    if (widget.initialTransaction != null) {
      _populateFromTransaction(widget.initialTransaction!);
      
      // Guard clause: Ensure CASHIER users can only access SALE transactions
      if (user?.role == UserRole.cashier && _selectedType != TransactionType.sale) {
        _selectedType = TransactionType.sale;
      }
      return;
    }

    // Guard clause: Set default transaction type for CASHIER users
    if (user?.role == UserRole.cashier) {
      _selectedType = TransactionType.sale;
    }

    // Guard clause: Set store for non-owner users
    if (user?.role != UserRole.owner && storeContext != null) {
      _selectedStoreId = storeContext.id;
    }
  }

  void _populateFromTransaction(Transaction transaction) {
    _selectedType = transaction.type;
    _selectedStoreId = transaction.fromStoreId;
    _selectedDestinationStoreId = transaction.toStoreId;
    // Photo URLs are now managed through separate photos table
    // _photoProofUrl = null; // Will be fetched from photos service if needed
    // _transferProofUrl = null; // Will be fetched from photos service if needed
    // Note: Photo IDs are not available in Transaction model
    // They would need to be fetched separately if needed for editing
    _customerNameController.text = transaction.to ?? '';
    _customerPhoneController.text = transaction.customerPhone ?? '';
    _items = transaction.items
            ?.map((item) => TransactionItemRequest(
                  productId: item.productId,
                  name: item.name,
                  quantity: item.quantity,
                  price: item.price,
                ))
            .toList() ??
        [];
  }

  Future<void> _loadStores() async {
    final user = context.read<AuthProvider>().user;

    // Guard clause: Only load stores for owners
    if (user?.role != UserRole.owner) return;

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

  Future<void> _searchProducts(String query) async {
    // Guard clause: Empty query
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    // Guard clause: No store selected
    if (_selectedStoreId == null) return;

    setState(() {
      _isSearching = true;
      _showSearchResults = true;
    });

    try {
      final response = await _productService.getProducts(
        search: query.trim(),
        storeId: _selectedStoreId!,
        limit: 8, // Reduced for mobile
      );

      if (!mounted) return;

      setState(() {
        _searchResults = response.data;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _searchTradeInProducts(String query) async {
    // Guard clause: Empty query
    if (query.trim().isEmpty) {
      setState(() {
        _tradeInSearchResults = [];
        _showTradeInSearchResults = false;
      });
      return;
    }

    // Guard clause: No store selected
    if (_selectedStoreId == null) return;

    setState(() {
      _isTradeInSearching = true;
      _showTradeInSearchResults = true;
    });

    try {
      final response = await _productService.getProducts(
        search: query.trim(),
        storeId: _selectedStoreId!,
        limit: 8, // Reduced for mobile
      );

      if (!mounted) return;

      setState(() {
        _tradeInSearchResults = response.data;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trade-in search failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isTradeInSearching = false);
      }
    }
  }

  void _selectTradeInProduct(Product product) {
    setState(() {
      _selectedTradeInProduct = product;
      _selectedTradeInProductId = product.id;
      _tradeInSearchController.clear();
      _tradeInSearchResults = [];
      _showTradeInSearchResults = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Trade-in product selected: ${product.name}'),
        backgroundColor: Colors.purple,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  bool _addProduct(Product product) {
    // Guard clause: Product out of stock
    if (product.quantity <= 0) {
      _showError('Product "${product.name}" is out of stock and cannot be added');
      return false;
    }

    // Guard clause: Invalid quantity input
    final quantity = int.tryParse(_quantityController.text) ?? 1;
    if (quantity <= 0) {
      _showError('Quantity must be greater than 0 to add items');
      return false;
    }

    final existingIndex =
        _items.indexWhere((item) => item.productId == product.id);

    if (existingIndex >= 0) {
      // Update existing item quantity
      final existingItem = _items[existingIndex];
      _items[existingIndex] = TransactionItemRequest(
        productId: existingItem.productId,
        name: existingItem.name,
        quantity: existingItem.quantity + quantity,
        price: existingItem.price,
      );
    } else {
      // Add new item
      _items.add(TransactionItemRequest(
        productId: product.id,
        name: product.name,
        quantity: quantity,
        price: product.salePrice ?? product.purchasePrice ?? 0.0,
      ));
    }

    setState(() {
      _searchController.clear();
      _quantityController.text = '1';
      _searchResults = [];
      _showSearchResults = false;
    });
    
    return true;
  }

  void _removeItem(int index) {
    // Guard clause: Invalid index
    if (index < 0 || index >= _items.length) return;

    setState(() {
      _items.removeAt(index);
    });
  }

  void _updateItemQuantity(int index, int newQuantity) {
    // Guard clause: Invalid conditions
    if (index < 0 || index >= _items.length || newQuantity <= 0) return;

    setState(() {
      final item = _items[index];
      _items[index] = TransactionItemRequest(
        productId: item.productId,
        name: item.name,
        quantity: newQuantity,
        price: item.price,
      );
    });
  }

  void _scanBarcodeForProduct() {
    // Guard clause: ensure widget is mounted
    if (!mounted) return;

    // Guard clause: ensure store is selected
    if (_selectedStoreId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a store first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ScannerLauncher.forProductSearch(
      context,
      title: 'Scan Product Barcode',
      subtitle: 'Scan barcode to add product to transaction',
      onProductFound: (product) {
        // Guard clause: ensure widget is mounted after scan
        if (!mounted) return;

        // Guard clause: validate product belongs to selected store
        if (product.storeId != _selectedStoreId) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Product "${product.name}" does not belong to the selected store'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        }

        // Auto-add the found product and show success only if added
        final wasAdded = _addProduct(product);
        
        if (wasAdded && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Product added: ${product.name}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      onProductNotFound: (barcode) {
        // Guard clause: ensure widget is mounted after scan
        if (!mounted) return;

        // Show product not found message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No product found with barcode: $barcode'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Search Manually',
              textColor: Colors.white,
              onPressed: () {
                _searchController.text = barcode;
                _searchProducts(barcode);
              },
            ),
          ),
        );
      },
    );
  }

  bool _validateForm() {
    final user = context.read<AuthProvider>().user;
    
    // Guard clause: Form validation
    if (!_formKey.currentState!.validate()) return false;

    // Guard clause: Role-based transaction type validation
    if (user?.role == UserRole.cashier && _selectedType != TransactionType.sale) {
      _showError('Cashier users can only create SALE transactions');
      return false;
    }

    // Guard clause: No items
    if (_items.isEmpty) {
      _showError('Please add at least one item');
      return false;
    }

    // Guard clause: Store selection
    if (_selectedStoreId == null) {
      _showError('Please select a store');
      return false;
    }

    // Guard clause: Transfer destination
    if (_selectedType == TransactionType.transfer &&
        _selectedDestinationStoreId == null) {
      _showError('Please select destination store for transfer');
      return false;
    }

    // Guard clause: Trade-in product
    if (_selectedType == TransactionType.trade &&
        _selectedTradeInProductId == null) {
      _showError('Please select a product for trade-in');
      return false;
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// Handle photo proof changes
  void _onPhotoProofChanged(String? photoUrl, String? photoId, [Uint8List? imageBytes]) {
    setState(() {
      _photoProofUrl = photoUrl;
      _photoProofId = photoId;
      if (imageBytes != null) {
        _pendingPhotoProofBytes = imageBytes;
      }
    });
  }

  /// Handle transfer proof changes
  void _onTransferProofChanged(String? photoUrl, String? photoId, [Uint8List? imageBytes]) {
    setState(() {
      _transferProofUrl = photoUrl;
      _transferProofId = photoId;
      if (imageBytes != null) {
        _pendingTransferProofBytes = imageBytes;
      }
    });
  }

  void _submitForm() {
    // Guard clause: Don't submit if already loading
    if (widget.isLoading) return;
    
    // Guard clause: Form validation
    if (!_validateForm()) return;

    final formData = TransactionFormData(
      type: _selectedType,
      storeId: _selectedStoreId!,
      destinationStoreId: _selectedDestinationStoreId,
      photoProofUrl: _photoProofUrl,
      transferProofUrl: _transferProofUrl,
      customerName: _customerNameController.text.trim().isEmpty
          ? null
          : _customerNameController.text.trim(),
      customerPhone: _customerPhoneController.text.trim().isEmpty
          ? null
          : _customerPhoneController.text.trim(),
      tradeInProductId: _selectedTradeInProductId,
      items: _items,
      pendingPhotoProofBytes: _pendingPhotoProofBytes,
      pendingTransferProofBytes: _pendingTransferProofBytes,
    );

    widget.onSave(formData);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header with type selection
            _buildCompactHeader(),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildStoreSection(),
                    const SizedBox(height: 16),
                    if (_selectedType == TransactionType.trade) ...[
                      _buildTradeInProductSection(),
                      const SizedBox(height: 16),
                    ],
                    _buildProductSearchSection(),
                    const SizedBox(height: 16),
                    _buildItemsList(),
                    const SizedBox(height: 16),
                    if (_selectedType == TransactionType.sale) ...[
                      _buildCustomerSection(),
                      const SizedBox(height: 16),
                    ],
                    _buildPhotoSections(),
                    const SizedBox(height: 16),
                    _buildCompactSummary(),
                    const SizedBox(height: 16),
                    _buildActionButtons(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isEditing ? 'Edit Transaction' : 'New Transaction',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          // Type selection as chips (role-based filtering)
          _buildTransactionTypeChips(),
        ],
      ),
    );
  }

  Widget _buildTransactionTypeChips() {
    final user = context.watch<AuthProvider>().user;
    
    // Guard clause: Handle null user case - default to SALE only
    if (user == null) {
      return _buildTypeChip(TransactionType.sale, 'Sale', Icons.shopping_cart);
    }
    
    // Define available transaction types based on role permissions:
    // - CASHIER: SALE only (as per role-permissions.md)
    // - OWNER/ADMIN: All transaction types (SALE, TRANSFER, TRADE)
    // - STAFF: Not typically creating transactions, but default to SALE if needed
    final List<Map<String, dynamic>> availableTypes = [];
    
    // SALE is always available for all roles
    availableTypes.add({
      'type': TransactionType.sale,
      'label': 'Sale',
      'icon': Icons.shopping_cart,
    });
    
    // TRANSFER and TRADE are restricted to OWNER and ADMIN roles only
    if (user.role == UserRole.owner || user.role == UserRole.admin) {
      availableTypes.addAll([
        {
          'type': TransactionType.transfer,
          'label': 'Transfer',
          'icon': Icons.swap_horiz,
        },
        {
          'type': TransactionType.trade,
          'label': 'Trade',
          'icon': Icons.swap_calls,
        },
      ]);
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableTypes
          .map((typeData) => _buildTypeChip(
                typeData['type'] as TransactionType,
                typeData['label'] as String,
                typeData['icon'] as IconData,
              ))
          .toList(),
    );
  }

  Widget _buildTypeChip(TransactionType type, String label, IconData icon) {
    final user = context.watch<AuthProvider>().user;
    final isSelected = _selectedType == type;
    
    // Check if this transaction type is available for the current user role
    final isAvailable = user == null || 
        type == TransactionType.sale || 
        (user.role == UserRole.owner || user.role == UserRole.admin);
    
    return InkWell(
      onTap: isAvailable ? () {
        setState(() {
          _selectedType = type;
          _selectedDestinationStoreId = null;
        });
      } : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreSection() {
    final user = context.watch<AuthProvider>().user;
    final storeContext = context.watch<StoreContextProvider>().selectedStore;
    final isOwner = user?.role == UserRole.owner;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Source Store
        if (isOwner) ...[
          _buildSectionLabel('Source Store'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedStoreId,
            decoration: _buildCompactInputDecoration('Select store'),
            validator: (value) => value == null ? 'Store required' : null,
            items: _stores
                .map((store) => DropdownMenuItem(
                      value: store.id,
                      child: Text(
                        store.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedStoreId = value;
                _selectedDestinationStoreId = null;
                _selectedTradeInProduct = null;
                _selectedTradeInProductId = null;
                _items.clear();
                _searchResults.clear();
                _showSearchResults = false;
              });
            },
          ),
        ] else if (storeContext != null) ...[
          _buildSectionLabel('Store'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.store,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    storeContext.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Destination Store (for transfers)
        if (_selectedType == TransactionType.transfer) ...[
          const SizedBox(height: 16),
          _buildSectionLabel('Destination Store'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedDestinationStoreId,
            decoration: _buildCompactInputDecoration('Select destination'),
            validator: _selectedType == TransactionType.transfer
                ? (value) => value == null ? 'Destination required' : null
                : null,
            items: _stores
                .where((store) => store.id != _selectedStoreId)
                .map((store) => DropdownMenuItem(
                      value: store.id,
                      child: Text(
                        store.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedDestinationStoreId = value;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildTradeInProductSection() {
    // Guard clause: No store selected
    if (_selectedStoreId == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.store_outlined,
              size: 32,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Select a store first',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Trade-In Product'),
        const SizedBox(height: 8),
        
        // Trade-in product selection section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.withValues(alpha: 0.1),
                Colors.purple.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.purple.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.swap_calls,
                    color: Colors.purple,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Scan or search for trade-in product',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.purple[700],
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Search bar with scan button (similar to items form)
              if (_selectedTradeInProduct == null) ...[
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _tradeInSearchController,
                        decoration: _buildCompactInputDecoration('Search trade-in products...').copyWith(
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: _isTradeInSearching
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : null,
                        ),
                        onChanged: _searchTradeInProducts,
                        onTap: () {
                          if (_tradeInSearchController.text.isNotEmpty) {
                            setState(() => _showTradeInSearchResults = true);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Barcode scan button
                    InkWell(
                      onTap: _scanBarcodeForTradeInProduct,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.purple.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Icon(
                          Icons.qr_code_scanner,
                          color: Colors.purple,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                // Search Results for trade-in products
                if (_showTradeInSearchResults && _tradeInSearchResults.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _tradeInSearchResults.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: Colors.purple.withValues(alpha: 0.2),
                      ),
                      itemBuilder: (context, index) {
                        final product = _tradeInSearchResults[index];
                        final price = product.salePrice ?? product.purchasePrice ?? 0.0;
                        final formattedPrice = Provider.of<AppProvider>(context, listen: false).formatCurrency(price);
                        return ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          title: Text(
                            product.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          subtitle: Text(
                            'Price: $formattedPrice | Stock: ${product.quantity}',
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.add_circle, size: 20, color: Colors.purple),
                            onPressed: () => _selectTradeInProduct(product),
                          ),
                          onTap: () => _selectTradeInProduct(product),
                        );
                      },
                    ),
                  ),
                ],
              ] else ...[
                // Selected trade-in product display
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.purple.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.devices,
                          color: Colors.purple,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedTradeInProduct!.name,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ID: ${_selectedTradeInProduct!.id}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                    fontFamily: 'monospace',
                                  ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedTradeInProduct = null;
                            _selectedTradeInProductId = null;
                          });
                        },
                        icon: const Icon(Icons.close, size: 20),
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.all(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _scanBarcodeForTradeInProduct() {
    // Guard clause: ensure widget is mounted
    if (!mounted) return;

    // Guard clause: ensure store is selected
    if (_selectedStoreId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a store first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ScannerLauncher.forProductSearch(
      context,
      title: 'Scan Trade-In Product',
      subtitle: 'Scan barcode of product to accept for trade-in',
      onProductFound: (product) {
        // Guard clause: ensure widget is mounted after scan
        if (!mounted) return;

        // Guard clause: validate product belongs to selected store
        if (product.storeId != _selectedStoreId) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Product "${product.name}" does not belong to the selected store'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        }

        // Set the trade-in product using the new method
        _selectTradeInProduct(product);
      },
      onProductNotFound: (barcode) {
        // Guard clause: ensure widget is mounted after scan
        if (!mounted) return;

        // Show product not found message with manual search option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No trade-in product found with barcode: $barcode'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Search Manually',
              textColor: Colors.white,
              onPressed: () {
                _tradeInSearchController.text = barcode;
                _searchTradeInProducts(barcode);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductSearchSection() {
    // Guard clause: No store selected
    if (_selectedStoreId == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.store_outlined,
              size: 32,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Select a store first',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Add Products'),
        const SizedBox(height: 8),

        // Search bar with scan button and quantity
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _searchController,
                decoration:
                    _buildCompactInputDecoration('Search products...').copyWith(
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _isSearching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                ),
                onChanged: _searchProducts,
                onTap: () {
                  if (_searchController.text.isNotEmpty) {
                    setState(() => _showSearchResults = true);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            // Barcode scan button
            InkWell(
              onTap: _scanBarcodeForProduct,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  Icons.qr_code_scanner,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 70,
              child: TextFormField(
                controller: _quantityController,
                decoration: _buildCompactInputDecoration('Qty'),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),

        // Search Results
        if (_showSearchResults && _searchResults.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Theme.of(context).dividerColor,
              ),
              itemBuilder: (context, index) {
                final product = _searchResults[index];
                final price = product.salePrice ?? product.purchasePrice ?? 0.0;
                final formattedPrice =
                    Provider.of<AppProvider>(context, listen: false)
                        .formatCurrency(price);
                return ListTile(
                  dense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  title: Text(
                    product.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  subtitle: Text(
                    'Price: $formattedPrice | Stock: ${product.quantity}',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle, size: 20),
                    onPressed: () => _addProduct(product),
                  ),
                  onTap: () => _addProduct(product),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildItemsList() {
    // Guard clause: No items
    if (_items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 32,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'No items added yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionLabel('Items (${_items.length})'),
            if (_items.isNotEmpty)
              Text(
                'Total: ${Provider.of<AppProvider>(context, listen: false).formatCurrency(_items.fold(0.0, (sum, item) => sum + (item.price * item.quantity)))}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Theme.of(context).dividerColor,
            ),
            itemBuilder: (context, index) {
              final item = _items[index];
              return ListTile(
                dense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                title: Text(
                  item.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                subtitle: Text(
                  '${Provider.of<AppProvider>(context, listen: false).formatCurrency(item.price)} × ${item.quantity} = ${Provider.of<AppProvider>(context, listen: false).formatCurrency(item.price * item.quantity)}',
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildQuantityButton(
                      Icons.remove,
                      () => _updateItemQuantity(index, item.quantity - 1),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${item.quantity}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    _buildQuantityButton(
                      Icons.add,
                      () => _updateItemQuantity(index, item.quantity + 1),
                    ),
                    const SizedBox(width: 4),
                    _buildQuantityButton(
                      Icons.delete_outline,
                      () => _removeItem(index),
                      color: Colors.red,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed,
      {Color? color}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: (color ?? Theme.of(context).colorScheme.primary)
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          size: 16,
          color: color ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildCustomerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Customer (Optional)'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _customerNameController,
                decoration: _buildCompactInputDecoration('Name').copyWith(
                  prefixIcon: const Icon(Icons.person, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _customerPhoneController,
                decoration: _buildCompactInputDecoration('Phone').copyWith(
                  prefixIcon: const Icon(Icons.phone, size: 20),
                ),
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photo Proof section (for all transaction types)
        TransactionPhotoUpload(
          type: PhotoType.photoProof,
          initialPhotoUrl: _photoProofUrl,
          existingPhotoId: _photoProofId,
          transactionId: widget.initialTransaction?.id,
          onPhotoChanged: _onPhotoProofChanged,
          title: 'Photo Proof',
          subtitle: 'Optional photo evidence for this transaction',
          isRequired: false,
        ),

        // Transfer Proof section (only for TRANSFER transactions)
        if (_selectedType == TransactionType.transfer) ...[
          const SizedBox(height: 16),
          TransactionPhotoUpload(
            type: PhotoType.transferProof,
            initialPhotoUrl: _transferProofUrl,
            existingPhotoId: _transferProofId,
            transactionId: widget.initialTransaction?.id,
            onPhotoChanged: _onTransferProofChanged,
            title: 'Transfer Proof',
            subtitle: 'Photo proof of goods being transferred',
            isRequired: false,
          ),
        ],
      ],
    );
  }

  Widget _buildCompactSummary() {
    final totalAmount =
        _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.05),
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaction Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _selectedType.name.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Total',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            Provider.of<AppProvider>(context, listen: false)
                .formatCurrency(totalAmount),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Items: ${_items.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_customerNameController.text.isNotEmpty)
                Flexible(
                  child: Text(
                    'Customer: ${_customerNameController.text}',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  InputDecoration _buildCompactInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[500],
          ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      isDense: true,
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: widget.isLoading ? null : widget.onCancel,
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
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: widget.isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(widget.isEditing
                            ? 'Updating...'
                            : 'Creating...'),
                      ],
                    )
                  : Text(widget.isEditing
                      ? 'Update Transaction'
                      : 'Create Transaction'),
            ),
          ),
        ],
      ),
    );
  }
}
