import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_bars.dart';
import '../../../core/services/transaction_service.dart';
import '../../../core/models/transaction.dart';
import '../../../core/models/user.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/auth/auth_provider.dart';
import '../widgets/transaction_form.dart';
import '../../../core/utils/number_utils.dart';

class CreateTransactionScreen extends StatefulWidget {
  const CreateTransactionScreen({super.key});

  @override
  State<CreateTransactionScreen> createState() => _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  final TransactionService _transactionService = TransactionService();
  bool _isLoading = false;

  Future<void> _createTransaction(TransactionFormData formData) async {
    final authProvider = context.read<AuthProvider>();
    
    // Validate permissions using TransactionService
    final userRole = authProvider.currentUser?.role;
    if (userRole == null || !TransactionService.canCreateTransactions(userRole)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have permission to create transactions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);
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

      // Create transaction request with backend-compatible structure
      final request = CreateTransactionBackendRequest(
        type: TransactionTypes.fromTransactionTypeEnum(formData.type),
        fromStoreId: formData.type == TransactionType.sale ? formData.storeId : formData.storeId,
        toStoreId: formData.destinationStoreId,
        photoProofUrl: formData.photoProofUrl,
        transferProofUrl: formData.transferProofUrl,
        to: formData.customerName,
        customerPhone: formData.customerPhone,
        items: backendItems,
      );
      
      // Get user role for validation
      final userRole = authProvider.currentUser?.role;
      
      // Validate transaction before creation
      final validationErrors = _transactionService.validateTransaction(
        request,
        userRole: userRole,
      );
      if (validationErrors.isNotEmpty) {
        throw Exception(validationErrors.values.first);
      }
      
      final transaction = await _transactionService.createTransaction(request);
      
      // Success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction created successfully! Total: ${NumberUtils.formatDoubleAsInt(transaction.calculatedAmount)}'),
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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