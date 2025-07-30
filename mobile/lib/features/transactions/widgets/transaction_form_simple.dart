import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/transaction.dart';
import '../../../core/models/api_requests.dart';
import '../../../core/models/store.dart';
import '../../../core/models/user.dart';
import '../../../core/services/store_service.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/providers/store_context_provider.dart';
import '../../../core/widgets/cards.dart';
import '../widgets/transaction_item_manager.dart';
import '../widgets/photo_proof_picker.dart';

// Transaction form data model
class TransactionFormData {
  final TransactionType type;
  final String storeId;
  final String? destinationStoreId;
  final String? photoProofUrl;
  final String? transferProofUrl;
  final String? customerName;
  final String? customerPhone;
  final List<TransactionItemRequest> items;

  TransactionFormData({
    required this.type,
    required this.storeId,
    this.destinationStoreId,
    this.photoProofUrl,
    this.transferProofUrl,
    this.customerName,
    this.customerPhone,
    required this.items,
  });

  double get totalAmount => items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
}

/// Single-step transaction form widget
class TransactionForm extends StatefulWidget {
  final Transaction? initialTransaction;
  final bool isEditing;
  final Function(TransactionFormData) onSave;
  final VoidCallback? onCancel;

  const TransactionForm({
    super.key,
    this.initialTransaction,
    required this.isEditing,
    required this.onSave,
    this.onCancel,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _storeService = StoreService();

  // Transaction details
  TransactionType _selectedType = TransactionType.sale;
  String? _selectedStoreId;
  String? _selectedDestinationStoreId;
  String? _photoProofUrl;
  String? _transferProofUrl;
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();

  // Items
  List<TransactionItemRequest> _items = [];
  
  // Data
  List<Store> _stores = [];
  final bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Defer context-dependent initialization to didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize form after providers are available, but only once
    if (!_isInitialized) {
      _isInitialized = true;
      debugPrint('TransactionForm: Initializing form...');
      _initializeForm();
      debugPrint('TransactionForm: Form initialized, loading stores...');
      // Load stores asynchronously without blocking UI - fire and forget
      unawaited(_loadStores());
      debugPrint('TransactionForm: Store loading initiated');
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    final user = context.read<AuthProvider>().user;
    final storeContext = context.read<StoreContextProvider>().selectedStore;
    
    if (widget.initialTransaction != null) {
      // Edit mode - populate from transaction
      final transaction = widget.initialTransaction!;
      _selectedType = transaction.type;
      _selectedStoreId = transaction.fromStoreId;
      _selectedDestinationStoreId = transaction.toStoreId;
      // Photo URLs are now managed through separate photos table
      // _photoProofUrl = null; // Will be fetched from photos service if needed
      // _transferProofUrl = null; // Will be fetched from photos service if needed
      _customerNameController.text = transaction.to ?? '';
      _customerPhoneController.text = transaction.customerPhone ?? '';
      _items = transaction.items?.map((item) => TransactionItemRequest(
        productId: item.productId,
        name: item.name,
        quantity: item.quantity,
        price: item.price,
      )).toList() ?? [];
    } else {
      // Create mode - set defaults
      if (user?.role != UserRole.owner && storeContext != null) {
        _selectedStoreId = storeContext.id;
      }
    }
  }

  Future<void> _loadStores() async {
    try {
      final user = context.read<AuthProvider>().user;
      debugPrint('TransactionForm: User role: ${user?.role}');
      if (user?.role == UserRole.owner) {
        debugPrint('TransactionForm: Loading stores for owner...');
        
        // Add explicit timeout to prevent hanging
        final response = await _storeService.getStores(limit: 100)
            .timeout(const Duration(seconds: 10), onTimeout: () {
          debugPrint('TransactionForm: Store loading timed out');
          throw Exception('Store loading timed out');
        });
        
        debugPrint('TransactionForm: Loaded ${response.data.length} stores');
        if (mounted) {
          setState(() {
            _stores = response.data;
          });
        }
      } else {
        debugPrint('TransactionForm: Non-owner user, skipping store loading');
        if (mounted) {
          setState(() {
            _stores = [];
          });
        }
      }
    } catch (e) {
      debugPrint('TransactionForm: Failed to load stores: $e');
      // Continue even if store loading fails
      if (mounted) {
        setState(() {
          _stores = [];
        });
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one item to the transaction'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final formData = TransactionFormData(
        type: _selectedType,
        storeId: _selectedStoreId!,
        destinationStoreId: _selectedDestinationStoreId,
        photoProofUrl: _photoProofUrl,
        transferProofUrl: _transferProofUrl,
        customerName: _customerNameController.text.trim().isNotEmpty ? _customerNameController.text.trim() : null,
        customerPhone: _customerPhoneController.text.trim().isNotEmpty ? _customerPhoneController.text.trim() : null,
        items: _items,
      );

      widget.onSave(formData);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Single form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction Type Section
                  _buildTransactionTypeSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Item Management Section
                  _buildItemManagementSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Customer Info Section (for SALE transactions)
                  if (_selectedType == TransactionType.sale) ...[
                    _buildCustomerInfoSection(),
                    const SizedBox(height: 24),
                  ],
                  
                  // Photo Proof Section (for SALE transactions)
                  if (_selectedType == TransactionType.sale) ...[
                    _buildPhotoProofSection(),
                    const SizedBox(height: 24),
                  ],
                  
                  // Transfer Proof Section (for TRANSFER transactions)
                  if (_selectedType == TransactionType.transfer) ...[
                    _buildTransferProofSection(),
                    const SizedBox(height: 24),
                  ],
                  
                  // Transaction Summary
                  _buildTransactionSummary(),
                ],
              ),
            ),
          ),
          
          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildTransactionTypeSection() {
    final user = context.watch<AuthProvider>().user;
    final showStoreSelection = user?.role == UserRole.owner;

    return WMSCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Transaction Type Selection
            Row(
              children: [
                Expanded(
                  child: RadioListTile<TransactionType>(
                    title: const Text('Sale'),
                    subtitle: const Text('Sell products to customers'),
                    value: TransactionType.sale,
                    groupValue: _selectedType,
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                        _selectedDestinationStoreId = null;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<TransactionType>(
                    title: const Text('Transfer'),
                    subtitle: const Text('Move products between stores'),
                    value: TransactionType.transfer,
                    groupValue: _selectedType,
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Store Selection (for OWNER role)
            if (showStoreSelection) ...[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'From Store',
                  border: OutlineInputBorder(),
                ),
                value: _selectedStoreId,
                validator: (value) => value == null ? 'Please select a store' : null,
                items: _stores.map((store) => DropdownMenuItem(
                  value: store.id,
                  child: Text(store.name),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStoreId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],
            
            // Destination Store Selection (for TRANSFER)
            if (_selectedType == TransactionType.transfer) ...[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'To Store',
                  border: OutlineInputBorder(),
                ),
                value: _selectedDestinationStoreId,
                validator: (value) => value == null ? 'Please select destination store' : null,
                items: _stores.where((store) => store.id != _selectedStoreId).map((store) => 
                  DropdownMenuItem(
                    value: store.id,
                    child: Text(store.name),
                  )
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDestinationStoreId = value;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemManagementSection() {
    return WMSCard(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Transaction Items',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TransactionItemManager(
            items: _items,
            storeId: _selectedStoreId ?? '',
            onItemsChanged: (items) {
              setState(() {
                _items = items;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoSection() {
    return WMSCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerNameController,
              decoration: const InputDecoration(
                labelText: 'Customer Name (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerPhoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number (Optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoProofSection() {
    return WMSCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Photo Proof (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            PhotoProofPicker(
              initialPhotoUrl: _photoProofUrl,
              onPhotoChanged: (url) {
                setState(() {
                  _photoProofUrl = url;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferProofSection() {
    return WMSCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transfer Proof (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            PhotoProofPicker(
              initialPhotoUrl: _transferProofUrl,
              onPhotoChanged: (url) {
                setState(() {
                  _transferProofUrl = url;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionSummary() {
    return WMSCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Type', _selectedType.name.toUpperCase()),
            if (_selectedDestinationStoreId != null)
              _buildSummaryRow('Destination', _stores.firstWhere((s) => s.id == _selectedDestinationStoreId).name),
            if (_customerNameController.text.isNotEmpty)
              _buildSummaryRow('Customer', _customerNameController.text),
            if (_customerPhoneController.text.isNotEmpty)
              _buildSummaryRow('Phone', _customerPhoneController.text),
            _buildSummaryRow('Items', '${_items.length}'),
            if (_items.isNotEmpty) ...[
              const Divider(),
              ..._items.map((item) => _buildItemSummary(item)),
              const Divider(),
            ],
            _buildSummaryRow(
              'Total Amount', 
              _selectedStoreId != null 
                ? TransactionFormData(type: _selectedType, storeId: _selectedStoreId!, items: _items).totalAmount.toInt().toString()
                : '0',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemSummary(TransactionItemRequest item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              item.name, // Show product name instead of ID
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${item.quantity}x',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 8),
          Text(
            '${item.price.toInt()}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 8),
          Text(
            '= ${(item.price * item.quantity).toInt()}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: isTotal 
                ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                : Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: isTotal 
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  )
                : Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onCancel,
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.isEditing ? 'Update Transaction' : 'Create Transaction'),
            ),
          ),
        ],
      ),
    );
  }
}