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
import '../../../core/validators/transaction_validators.dart';
import '../widgets/transaction_item_manager.dart';
import '../widgets/photo_proof_picker.dart';

// Transaction form data model
class TransactionFormData {
  final TransactionType type;
  final String storeId;
  final String? destinationStoreId;
  final String? photoProofUrl;
  final String? customerName;
  final String? customerPhone;
  final List<TransactionItemRequest> items;

  TransactionFormData({
    required this.type,
    required this.storeId,
    this.destinationStoreId,
    this.photoProofUrl,
    this.customerName,
    this.customerPhone,
    required this.items,
  });

  TransactionFormData copyWith({
    TransactionType? type,
    String? storeId,
    String? destinationStoreId,
    String? photoProofUrl,
    String? customerName,
    String? customerPhone,
    List<TransactionItemRequest>? items,
  }) {
    return TransactionFormData(
      type: type ?? this.type,
      storeId: storeId ?? this.storeId,
      destinationStoreId: destinationStoreId ?? this.destinationStoreId,
      photoProofUrl: photoProofUrl ?? this.photoProofUrl,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
    );
  }

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }
}

class TransactionForm extends StatefulWidget {
  final Transaction? initialTransaction;
  final bool isEditing;
  final Function(TransactionFormData) onSave;
  final VoidCallback onCancel;

  const TransactionForm({
    super.key,
    this.initialTransaction,
    required this.isEditing,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  final StoreService _storeService = StoreService();
  
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();
  
  TransactionType _selectedType = TransactionType.sale;
  String? _selectedStoreId;
  String? _selectedDestinationStoreId;
  String? _photoProofUrl;
  List<TransactionItemRequest> _items = [];
  
  List<Store> _stores = [];
  
  int _currentStep = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadStores();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    final storeContext = context.read<StoreContextProvider>().selectedStore;
    final user = context.read<AuthProvider>().user;
    
    if (widget.initialTransaction != null) {
      // Edit mode - populate with existing data
      final transaction = widget.initialTransaction!;
      _selectedType = transaction.type;
      _selectedStoreId = transaction.fromStoreId;
      _selectedDestinationStoreId = transaction.toStoreId;
      _photoProofUrl = transaction.photoProofUrl;
      _customerNameController.text = transaction.to ?? '';
      _customerPhoneController.text = transaction.customerPhone ?? '';
      _items = transaction.items?.map((item) => TransactionItemRequest(
        productId: item.productId,
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
      if (user?.role == UserRole.owner) {
        final response = await _storeService.getStores(limit: 100);
        setState(() {
          _stores = response.data;
        });
      }
    } catch (e) {
      debugPrint('Failed to load stores: $e');
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitForm();
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

      if (_selectedType == TransactionType.sale && _photoProofUrl?.isEmpty != false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo proof is required for SALE transactions'),
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
        customerName: _customerNameController.text.trim().isNotEmpty ? _customerNameController.text.trim() : null,
        customerPhone: _customerPhoneController.text.trim().isNotEmpty ? _customerPhoneController.text.trim() : null,
        items: _items,
      );

      widget.onSave(formData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          
          // Form content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildTransactionTypeStep(),
                _buildItemManagementStep(),
                _buildReviewStep(),
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          for (int i = 0; i < 3; i++) ...[
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: i <= _currentStep ? Theme.of(context).primaryColor : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (i < 2) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionTypeStep() {
    final user = context.watch<AuthProvider>().user;
    final storeContext = context.watch<StoreContextProvider>().selectedStore;
    final showStoreSelection = user?.role == UserRole.owner;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Details',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Transaction Type Selection
          Text(
            'Transaction Type',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 24),

          // Store Selection (for OWNER)
          if (showStoreSelection) ...[
            Text(
              'Source Store',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedStoreId,
              decoration: const InputDecoration(
                hintText: 'Select source store',
                border: OutlineInputBorder(),
              ),
              validator: TransactionValidators.validateStoreSelection,
              items: _stores.map((store) => DropdownMenuItem<String>(
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
          ] else if (storeContext != null) ...[
            Text(
              'Store: ${storeContext.name}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Destination Store (for TRANSFER)
          if (_selectedType == TransactionType.transfer) ...[
            Text(
              'Destination Store',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedDestinationStoreId,
              decoration: const InputDecoration(
                hintText: 'Select destination store',
                border: OutlineInputBorder(),
              ),
              validator: _selectedType == TransactionType.transfer 
                  ? TransactionValidators.validateDestinationStore 
                  : null,
              items: _stores.where((store) => store.id != _selectedStoreId).map((store) => 
                DropdownMenuItem<String>(
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
            const SizedBox(height: 16),
          ],

          // Customer Information (for SALE)
          if (_selectedType == TransactionType.sale) ...[
            Text(
              'Customer Information (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _customerNameController,
              decoration: const InputDecoration(
                labelText: 'Customer Name',
                hintText: 'Enter customer name',
                border: OutlineInputBorder(),
              ),
              validator: TransactionValidators.validateCustomerName,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerPhoneController,
              decoration: const InputDecoration(
                labelText: 'Customer Phone',
                hintText: 'Enter customer phone number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: TransactionValidators.validateCustomerPhone,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemManagementStep() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Transaction Items',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: TransactionItemManager(
            items: _items,
            storeId: _selectedStoreId ?? '',
            onItemsChanged: (items) {
              setState(() {
                _items = items;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Transaction',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Transaction Summary
          WMSCard(
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
                  const Divider(),
                  _buildSummaryRow(
                    'Total Amount', 
                    '\$${TransactionFormData(type: _selectedType, storeId: _selectedStoreId!, items: _items).totalAmount.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Photo Proof (for SALE)
          if (_selectedType == TransactionType.sale) ...[
            Text(
              'Photo Proof (Required)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            PhotoProofPicker(
              initialPhotoUrl: _photoProofUrl,
              onPhotoChanged: (photoUrl) {
                setState(() {
                  _photoProofUrl = photoUrl;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isTotal ? Theme.of(context).primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Previous'),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_currentStep == 2 ? 'Create Transaction' : 'Next'),
            ),
          ),
          if (_currentStep == 0) ...[
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: widget.onCancel,
              child: const Text('Cancel'),
            ),
          ],
        ],
      ),
    );
  }
}