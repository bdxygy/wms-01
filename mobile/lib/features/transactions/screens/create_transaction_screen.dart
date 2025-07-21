import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_bars.dart';
import '../../../core/services/transaction_service.dart';
import '../../../core/models/api_requests.dart';
import '../../../core/models/transaction.dart';
import '../../../core/models/user.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../generated/app_localizations.dart';
import '../widgets/transaction_form.dart';

class CreateTransactionScreen extends StatefulWidget {
  const CreateTransactionScreen({super.key});

  @override
  State<CreateTransactionScreen> createState() => _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  final TransactionService _transactionService = TransactionService();

  Future<void> _createTransaction(TransactionFormData formData) async {
    final authProvider = context.read<AuthProvider>();
    
    // Validate permissions
    if (!authProvider.canCreateTransactions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have permission to create transactions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Create transaction request
      final request = CreateTransactionRequest(
        type: formData.type.name.toUpperCase(),
        storeId: formData.storeId,
        destinationStoreId: formData.destinationStoreId,
        photoProofUrl: formData.photoProofUrl,
        items: formData.items,
      );
      
      // Validate transaction before creation
      _transactionService.validateTransaction(request);
      
      final transaction = await _transactionService.createTransaction(request);
      
      // Success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction created successfully! Total: ${transaction.calculatedAmount.toStringAsFixed(2)}'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                AppRouter.goToTransactionDetail(context, transaction.id);
              },
            ),
          ),
        );
        
        // Navigate to transaction detail screen as per business workflow
        AppRouter.goToTransactionDetail(context, transaction.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create transaction: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _cancelCreation() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WMSAppBar(
        title: 'Create Transaction',
      ),
      body: TransactionForm(
        isEditing: false,
        onSave: _createTransaction,
        onCancel: _cancelCreation,
      ),
    );
  }
}

// Extension to add transaction permissions to AuthProvider
extension TransactionPermissions on AuthProvider {
  bool get canCreateTransactions {
    final userRole = user?.role;
    return userRole == UserRole.owner || 
           userRole == UserRole.admin || 
           userRole == UserRole.cashier;
  }
  
  bool get canEditTransactions {
    final userRole = user?.role;
    return userRole == UserRole.owner || userRole == UserRole.admin;
  }
  
  bool get canDeleteTransactions {
    return user?.role == UserRole.owner;
  }
}