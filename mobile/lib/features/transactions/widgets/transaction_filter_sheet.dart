import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/transaction_service.dart';
import '../../../core/services/store_service.dart';
import '../../../core/models/store.dart';
import '../../../core/models/user.dart';
import '../../../core/auth/auth_provider.dart';

/// Transaction Filter Bottom Sheet
/// 
/// Provides comprehensive filtering options for transactions:
/// - Transaction type (SALE, TRANSFER)
/// - Store selection (for OWNER users)
/// - Completion status (finished/pending)
/// - Date range picker
/// - Amount range (min/max)
/// 
/// Supports role-based filtering options based on user permissions
class TransactionFilterSheet extends StatefulWidget {
  final String? selectedType;
  final String? selectedStoreId;
  final bool? selectedIsFinished;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final Function(Map<String, dynamic>) onFiltersChanged;
  final VoidCallback onClearFilters;

  const TransactionFilterSheet({
    super.key,
    this.selectedType,
    this.selectedStoreId,
    this.selectedIsFinished,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    required this.onFiltersChanged,
    required this.onClearFilters,
  });

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  final StoreService _storeService = StoreService();
  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxAmountController = TextEditingController();

  String? _selectedType;
  String? _selectedStoreId;
  bool? _selectedIsFinished;
  DateTime? _startDate;
  DateTime? _endDate;
  double? _minAmount;
  double? _maxAmount;

  List<Store> _stores = [];
  bool _isLoadingStores = false;

  @override
  void initState() {
    super.initState();
    _initializeFilters();
    _loadStores();
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  void _initializeFilters() {
    _selectedType = widget.selectedType;
    _selectedStoreId = widget.selectedStoreId;
    _selectedIsFinished = widget.selectedIsFinished;
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _minAmount = widget.minAmount;
    _maxAmount = widget.maxAmount;

    _minAmountController.text = _minAmount?.toString() ?? '';
    _maxAmountController.text = _maxAmount?.toString() ?? '';
  }

  Future<void> _loadStores() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user?.role != UserRole.owner) return;

    setState(() {
      _isLoadingStores = true;
    });

    try {
      final response = await _storeService.getStores(limit: 100);
      if (!mounted) return;
      
      setState(() {
        _stores = response.data;
        _isLoadingStores = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoadingStores = false;
      });
      debugPrint('Failed to load stores: $e');
    }
  }

  void _applyFilters() {
    // Parse amount values
    final minAmountText = _minAmountController.text.trim();
    final maxAmountText = _maxAmountController.text.trim();
    
    _minAmount = minAmountText.isNotEmpty ? double.tryParse(minAmountText) : null;
    _maxAmount = maxAmountText.isNotEmpty ? double.tryParse(maxAmountText) : null;

    // Validate amount range
    if (_minAmount != null && _maxAmount != null && _minAmount! > _maxAmount!) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum amount cannot be greater than maximum amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate date range
    if (_startDate != null && _endDate != null && _startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start date cannot be after end date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final filters = <String, dynamic>{
      'type': _selectedType,
      'storeId': _selectedStoreId,
      'isFinished': _selectedIsFinished,
      'startDate': _startDate,
      'endDate': _endDate,
      'minAmount': _minAmount,
      'maxAmount': _maxAmount,
    };

    widget.onFiltersChanged(filters);
    Navigator.of(context).pop();
  }

  void _clearAllFilters() {
    setState(() {
      _selectedType = null;
      _selectedStoreId = null;
      _selectedIsFinished = null;
      _startDate = null;
      _endDate = null;
      _minAmount = null;
      _maxAmount = null;
      _minAmountController.clear();
      _maxAmountController.clear();
    });

    widget.onClearFilters();
    Navigator.of(context).pop();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now());
    final firstDate = DateTime(2020);
    final lastDate = DateTime.now().add(const Duration(days: 365));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: isStartDate ? 'Select start date' : 'Select end date',
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isOwner = authProvider.user?.role == UserRole.owner;
    final userRole = authProvider.user?.role;
    final allowedTypes = userRole != null 
        ? TransactionService.getAllowedTransactionTypes(userRole)
        : <String>[];

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Transactions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: _clearAllFilters,
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Filter content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Transaction Type
                        if (allowedTypes.isNotEmpty) ...[
                          Text(
                            'Transaction Type',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              FilterChip(
                                label: const Text('All'),
                                selected: _selectedType == null,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedType = selected ? null : _selectedType;
                                  });
                                },
                              ),
                              ...allowedTypes.map((type) => FilterChip(
                                label: Text(TransactionTypes.getDisplayName(type)),
                                selected: _selectedType == type,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedType = selected ? type : null;
                                  });
                                },
                              )),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Store Selection (OWNER only)
                        if (isOwner) ...[
                          Text(
                            'Store',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_isLoadingStores)
                            const Center(child: CircularProgressIndicator())
                          else
                            DropdownButtonFormField<String>(
                              value: _selectedStoreId,
                              decoration: const InputDecoration(
                                hintText: 'Select store',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('All Stores'),
                                ),
                                ..._stores.map((store) => DropdownMenuItem<String>(
                                  value: store.id,
                                  child: Text(store.name),
                                )),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedStoreId = value;
                                });
                              },
                            ),
                          const SizedBox(height: 24),
                        ],

                        // Status Filter
                        Text(
                          'Status',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            FilterChip(
                              label: const Text('All'),
                              selected: _selectedIsFinished == null,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedIsFinished = selected ? null : _selectedIsFinished;
                                });
                              },
                            ),
                            FilterChip(
                              label: const Text('Completed'),
                              selected: _selectedIsFinished == true,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedIsFinished = selected ? true : null;
                                });
                              },
                            ),
                            FilterChip(
                              label: const Text('Pending'),
                              selected: _selectedIsFinished == false,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedIsFinished = selected ? false : null;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Date Range
                        Text(
                          'Date Range',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _selectDate(context, true),
                                icon: const Icon(Icons.calendar_today, size: 16),
                                label: Text(
                                  _startDate != null 
                                      ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                      : 'Start Date',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _selectDate(context, false),
                                icon: const Icon(Icons.calendar_today, size: 16),
                                label: Text(
                                  _endDate != null 
                                      ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                      : 'End Date',
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_startDate != null || _endDate != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (_startDate != null)
                                Chip(
                                  label: Text('From: ${_startDate!.day}/${_startDate!.month}'),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () {
                                    setState(() {
                                      _startDate = null;
                                    });
                                  },
                                ),
                              if (_startDate != null && _endDate != null)
                                const SizedBox(width: 8),
                              if (_endDate != null)
                                Chip(
                                  label: Text('To: ${_endDate!.day}/${_endDate!.month}'),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () {
                                    setState(() {
                                      _endDate = null;
                                    });
                                  },
                                ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 24),

                        // Amount Range
                        Text(
                          'Amount Range',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _minAmountController,
                                decoration: const InputDecoration(
                                  labelText: 'Min Amount',
                                  border: OutlineInputBorder(),
                                  prefixText: '\$ ',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _maxAmountController,
                                decoration: const InputDecoration(
                                  labelText: 'Max Amount',
                                  border: OutlineInputBorder(),
                                  prefixText: '\$ ',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Action buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _applyFilters,
                          child: const Text('Apply Filters'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}