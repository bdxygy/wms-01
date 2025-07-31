import 'package:flutter/foundation.dart';
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
import '../../../core/services/photo_service.dart';
import '../../../core/models/photo.dart';

class CreateTransactionScreen extends StatefulWidget {
  const CreateTransactionScreen({super.key});

  @override
  State<CreateTransactionScreen> createState() => _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  final TransactionService _transactionService = TransactionService();
  final PhotoService _photoService = PhotoService();
  
  bool _isCreating = false;

  Future<void> _createTransaction(TransactionFormData formData) async {
    // Set loading state
    setState(() {
      _isCreating = true;
    });

    final authProvider = context.read<AuthProvider>();
    
    // Validate permissions using TransactionService
    final userRole = authProvider.currentUser?.role;
    if (userRole == null || !TransactionService.canCreateTransactions(userRole)) {
      setState(() {
        _isCreating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have permission to create transactions'),
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

      // Create transaction request with backend-compatible structure
      final request = CreateTransactionBackendRequest(
        type: TransactionTypes.fromTransactionTypeEnum(formData.type),
        fromStoreId: formData.type == TransactionType.sale ? formData.storeId : formData.storeId,
        toStoreId: formData.destinationStoreId,
        photoProofUrl: formData.photoProofUrl,
        transferProofUrl: formData.transferProofUrl,
        to: formData.customerName,
        customerPhone: formData.customerPhone,
        tradeInProductId: formData.tradeInProductId,
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
      
      // Handle photo uploads if any pending photos exist
      bool hasPhotoUploads = formData.pendingPhotoProofBytes != null || 
                             formData.pendingTransferProofBytes != null;
      
      if (hasPhotoUploads) {
        await _uploadPendingPhotos(transaction.id, formData);
      }
      
      // Success feedback
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
        
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
        setState(() {
          _isCreating = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create transaction: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Upload pending photos after transaction creation
  Future<void> _uploadPendingPhotos(String transactionId, TransactionFormData formData) async {
    List<Future<void>> uploadTasks = [];
    
    // Upload photo proof if exists
    if (formData.pendingPhotoProofBytes != null) {
      uploadTasks.add(_uploadPhoto(
        transactionId, 
        formData.pendingPhotoProofBytes!, 
        PhotoType.photoProof,
        'Photo proof'
      ));
    }
    
    // Upload transfer proof if exists
    if (formData.pendingTransferProofBytes != null) {
      uploadTasks.add(_uploadPhoto(
        transactionId, 
        formData.pendingTransferProofBytes!, 
        PhotoType.transferProof,
        'Transfer proof'
      ));
    }
    
    // Wait for all uploads to complete
    if (uploadTasks.isNotEmpty) {
      try {
        await Future.wait(uploadTasks);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photos uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error uploading photos: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload some photos: $e'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }
  
  /// Upload individual photo
  Future<void> _uploadPhoto(String transactionId, Uint8List imageBytes, PhotoType type, String typeName) async {
    try {
      if (type == PhotoType.photoProof) {
        await _photoService.uploadTransactionPhotoProof(transactionId, imageBytes);
      } else if (type == PhotoType.transferProof) {
        await _photoService.uploadTransactionTransferProof(transactionId, imageBytes);
      }
      debugPrint('$typeName uploaded successfully');
    } catch (e) {
      debugPrint('Failed to upload $typeName: $e');
      rethrow;
    }
  }

  void _cancelCreation() {
    // Prevent cancellation during transaction creation
    if (_isCreating) return;
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
        isLoading: _isCreating,
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