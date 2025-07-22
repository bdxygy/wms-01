import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_bars.dart';
import '../../../core/services/transaction_service.dart';
import '../../../core/models/transaction.dart';
import '../../../core/models/user.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/routing/app_router.dart';
import '../widgets/transaction_form.dart';

/// Edit Transaction Screen
/// 
/// Allows editing existing transactions with role-based permissions:
/// - OWNER/ADMIN: Can edit all transaction fields
/// - CASHIER: Can edit SALE transactions (limited fields)
/// - Validation ensures business rules are maintained
/// 
/// Features:
/// - Pre-populated form with existing transaction data
/// - Role-based field restrictions
/// - Photo/transfer proof updates
/// - Customer information updates
/// - Item management (add/remove/edit items)
class EditTransactionScreen extends StatefulWidget {
  final String transactionId;

  const EditTransactionScreen({
    super.key,
    required this.transactionId,
  });

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final TransactionService _transactionService = TransactionService();
  
  Transaction? _transaction;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final transaction = await _transactionService.getTransactionById(widget.transactionId);
      
      if (!mounted) return;
      
      setState(() {
        _transaction = transaction;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateTransaction(TransactionFormData formData) async {
    if (_transaction == null) return;
    
    final authProvider = context.read<AuthProvider>();
    final userRole = authProvider.currentUser?.role;
    
    if (userRole == null || !TransactionService.canUpdateTransaction(userRole)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have permission to edit transactions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Convert form items to backend items
      final backendItems = formData.items.map((item) => 
        TransactionItemBackendRequest(
          productId: item.productId,
          name: 'Product ${item.productId}', // TODO: Get actual product name from ProductService
          price: item.price,
          quantity: item.quantity,
          amount: item.price * item.quantity,
        )
      ).toList();

      // Create update request
      final updateRequest = UpdateTransactionBackendRequest(
        photoProofUrl: formData.photoProofUrl,
        transferProofUrl: formData.transferProofUrl,
        to: formData.customerName,
        customerPhone: formData.customerPhone,
        items: backendItems,
      );
      
      // Validate update request
      if (userRole == UserRole.cashier && 
          _transaction!.type != TransactionType.sale) {
        throw Exception('CASHIER users can only edit SALE transactions');
      }
      
      final updatedTransaction = await _transactionService.updateTransaction(
        _transaction!.id,
        updateRequest,
      );
      
      // Success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction updated successfully! Total: ${updatedTransaction.calculatedAmount.toInt()}'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                AppRouter.goToTransactionDetail(context, updatedTransaction.id);
              },
            ),
          ),
        );
        
        // Navigate back to transaction detail
        AppRouter.goToTransactionDetail(context, updatedTransaction.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update transaction: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _cancelEdit() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WMSAppBar(
        title: 'Edit Transaction',
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load transaction',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTransaction,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_transaction == null) {
      return const Center(
        child: Text('Transaction not found'),
      );
    }

    // Check if user can edit this transaction
    final authProvider = context.watch<AuthProvider>();
    final userRole = authProvider.user?.role;
    
    if (userRole == null || !TransactionService.canUpdateTransaction(userRole)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Access Denied',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'You do not have permission to edit transactions',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    // Additional check for CASHIER role
    if (userRole == UserRole.cashier && 
        _transaction!.type != TransactionType.sale) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_outlined,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              'Cannot Edit Transaction',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'CASHIER users can only edit SALE transactions',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    return TransactionForm(
      initialTransaction: _transaction,
      isEditing: true,
      onSave: _updateTransaction,
      onCancel: _cancelEdit,
    );
  }
}