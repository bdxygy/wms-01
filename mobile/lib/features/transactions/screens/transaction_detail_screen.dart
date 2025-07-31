import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../generated/app_localizations.dart';
import '../../../core/widgets/loading.dart';
import '../../../core/widgets/barcode_quantity_dialog.dart';
import '../../../core/widgets/wms_app_bar.dart';
import '../../../core/services/transaction_service.dart';
import '../../../core/services/print_launcher.dart';
import '../../../core/services/photo_service.dart';
import '../../../core/models/transaction.dart';
import '../../../core/models/user.dart';
import '../../../core/models/photo.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/number_utils.dart';

/// Modern Transaction Detail Screen with comprehensive transaction information
///
/// Features:
/// - Modern Material Design 3 with hero cards and gradient backgrounds
/// - Transparent app bar with floating action button integration
/// - Comprehensive transaction information display with visual hierarchy
/// - Modern item list with responsive design and proper overflow handling
/// - Photo proof display with viewer integration
/// - Role-based action buttons with permission-aware UI
/// - Full internationalization support with proper i18n keys
/// - Guard clause patterns for clean error handling and state management
/// - Mobile-first responsive design with proper touch targets
///
/// Permissions:
/// - OWNER/ADMIN: Full view and edit access with all action buttons
/// - CASHIER: View and limited edit for SALE transactions
/// - STAFF: Read-only access with view-only interface
class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;

  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final TransactionService _transactionService = TransactionService();
  final PrintLauncher _printLauncher = PrintLauncher();
  final PhotoService _photoService = PhotoService();

  Transaction? _transaction;
  bool _isLoading = true;
  String? _error;
  bool _isUpdating = false;
  
  // Photo state management
  Photo? _photoProof;
  Photo? _transferProof;
  bool _isLoadingPhotos = false;
  bool _isUploadingPhoto = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    // Guard clause: ensure widget is mounted
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final transaction =
          await _transactionService.getTransactionById(widget.transactionId);

      // Guard clause: check mounted state after async operation
      if (!mounted) return;

      setState(() {
        _transaction = transaction;
        _isLoading = false;
      });
      
      // Load transaction photos after transaction is loaded
      _loadTransactionPhotos();
    } catch (e) {
      // Guard clause: ensure still mounted before updating state
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markFinished() async {
    // Guard clause: validate transaction and prevent concurrent updates
    if (_transaction == null || _isUpdating) return;

    // Guard clause: check if already finished
    if (_transaction!.isFinished) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final updatedTransaction =
          await _transactionService.finishTransaction(_transaction!.id);

      if (!mounted) return;

      setState(() {
        _transaction = updatedTransaction;
        _isUpdating = false;
      });

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.transactions_message_markedFinished),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isUpdating = false;
      });

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.transactions_error_markFinishedFailed(e.toString())),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _editTransaction() {
    if (_transaction == null) return;
    AppRouter.goToEditTransaction(context, _transaction!.id);
  }

  bool _canEditTransaction() {
    final authProvider = context.read<AuthProvider>();
    final userRole = authProvider.user?.role;

    // Guard clause: check if user role exists
    if (userRole == null) return false;

    return TransactionService.canUpdateTransaction(userRole);
  }

  void _printReceipt() async {
    // Guard clause: ensure transaction exists
    if (_transaction == null) return;

    final l10n = AppLocalizations.of(context)!;

    try {
      // Show receipt quantity dialog
      final quantity = await showDialog<int>(
        context: context,
        builder: (context) => BarcodeQuantityDialog(
          title: l10n.transactions_action_printReceipt,
          subtitle: '${l10n.transactions_label_id} #${_transaction!.id.substring(0, 8)}',
          defaultQuantity: 1,
        ),
      );

      // Guard clause: User cancelled dialog
      if (quantity == null) return;

      // Guard clause: Check if still mounted
      if (!mounted) return;

      // Get current user for printing context
      final user = context.read<AuthProvider>().user;

      // Print receipt using transaction data
      final result = quantity == 1
        ? await _printLauncher.printTransactionReceipt(
            transaction: _transaction!.toJson(),
            store: null, // Will be fetched if needed
            user: user,
          )
        : await _printLauncher.printTransactionReceipts(
            transaction: _transaction!.toJson(),
            quantity: quantity,
            store: null, // Will be fetched if needed
            user: user,
          );

      if (result && mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(quantity == 1 
              ? l10n.transactions_message_receiptPrintedSuccess
              : l10n.transactions_message_receiptsPrintedSuccess(quantity.toString())),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString();

        final l10n = AppLocalizations.of(context)!;
        
        // Check if it's a connection issue
        if (errorMessage.contains('not connected')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.common_error_printerNotConnected),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              action: SnackBarAction(
                label: l10n.common_action_setup,
                onPressed: () => _printLauncher.connectAndPrint(context),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.transactions_error_printReceiptFailed(e.toString())),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }

  void _managePrinter() async {
    try {
      final isConnected = await _printLauncher.isConnected;

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Printer Management'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: ${isConnected ? 'Connected' : 'Disconnected'}'),
              const SizedBox(height: 16),
              const Text('Available Actions:'),
              const SizedBox(height: 8),
              if (!isConnected)
                ListTile(
                  leading: const Icon(Icons.bluetooth_connected),
                  title: const Text('Connect to Printer'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _printLauncher.connectWithDialog(context);
                  },
                ),
              if (isConnected) ...[
                ListTile(
                  leading: const Icon(Icons.print),
                  title: const Text('Print Test Page'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _testPrinter();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bluetooth_disabled),
                  title: const Text('Disconnect'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _printLauncher.disconnect();

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Printer disconnected'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accessing printer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _testPrinter() async {
    try {
      // Use the comprehensive connect and print method (no product = test page)
      final result = await _printLauncher.connectAndPrint(context);

      if (result && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test page printed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test print failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareTransaction() {
    // Guard clause: ensure transaction exists
    if (_transaction == null) return;

    final l10n = AppLocalizations.of(context)!;
    final transactionInfo = '''${l10n.transactions_title_details}:
${l10n.transactions_label_id}: ${_transaction!.id}
${l10n.transactions_label_type}: ${_transaction!.type.name.toUpperCase()}
${l10n.transactions_label_amount}: ${NumberUtils.formatDoubleAsInt(_transaction!.calculatedAmount)}
${l10n.transactions_label_items}: ${_transaction!.items?.length ?? 0}
${l10n.transactions_label_status}: ${_transaction!.isFinished ? l10n.common_status_completed : l10n.common_status_pending}
${l10n.transactions_label_date}: ${_formatDateTime(_transaction!.createdAt)}''';

    // Copy to clipboard (simplified sharing)
    Clipboard.setData(ClipboardData(text: transactionInfo));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.common_message_copiedToClipboard),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Load transaction photos (photoProof and transferProof)
  Future<void> _loadTransactionPhotos() async {
    if (_transaction == null || !mounted) return;

    setState(() {
      _isLoadingPhotos = true;
    });

    try {
      final photoMap = await _photoService.getAllTransactionPhotos(_transaction!.id);
      
      if (!mounted) return;
      
      setState(() {
        _photoProof = photoMap[PhotoType.photoProof];
        _transferProof = photoMap[PhotoType.transferProof];
        _isLoadingPhotos = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoadingPhotos = false;
      });
      
      debugPrint('Error loading transaction photos: $e');
    }
  }

  /// View photo in fullscreen
  void _viewPhoto(Photo photo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _NetworkPhotoViewer(
          photo: photo,
          title: '${photo.type.displayName} - ${_transaction?.id.substring(0, 8) ?? 'Transaction'}',
        ),
      ),
    );
  }

  /// Add photo proof
  Future<void> _addPhotoProof() async {
    if (_transaction == null || _isUploadingPhoto) return;
    
    final l10n = AppLocalizations.of(context)!;
    
    try {
      setState(() {
        _isUploadingPhoto = true;
        _uploadProgress = 0.0;
      });
      
      final photo = await _photoService.uploadTransactionPhotoProofWithPicker(
        _transaction!.id,
        context: context,
        onProgress: (sent, total) {
          if (mounted) {
            setState(() {
              _uploadProgress = PhotoService.calculateUploadProgress(sent, total);
            });
          }
        },
      );
      
      if (!mounted) return;
      
      setState(() {
        _isUploadingPhoto = false;
        _uploadProgress = 0.0;
      });
      
      if (photo != null) {
        setState(() {
          _photoProof = photo;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.transactions_message_photoProofAdded),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isUploadingPhoto = false;
        _uploadProgress = 0.0;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.transactions_error_photoProofAddFailed(e.toString())),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  /// Add transfer proof
  Future<void> _addTransferProof() async {
    if (_transaction == null || _isUploadingPhoto) return;
    
    final l10n = AppLocalizations.of(context)!;
    
    try {
      setState(() {
        _isUploadingPhoto = true;
        _uploadProgress = 0.0;
      });
      
      final photo = await _photoService.uploadTransactionTransferProofWithPicker(
        _transaction!.id,
        context: context,
        onProgress: (sent, total) {
          if (mounted) {
            setState(() {
              _uploadProgress = PhotoService.calculateUploadProgress(sent, total);
            });
          }
        },
      );
      
      if (!mounted) return;
      
      setState(() {
        _isUploadingPhoto = false;
        _uploadProgress = 0.0;
      });
      
      if (photo != null) {
        setState(() {
          _transferProof = photo;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.transactions_message_transferProofAdded),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isUploadingPhoto = false;
        _uploadProgress = 0.0;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.transactions_error_transferProofAddFailed(e.toString())),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  /// Update photo proof
  Future<void> _updatePhotoProof() async {
    if (_transaction == null || _isUploadingPhoto) return;
    
    final l10n = AppLocalizations.of(context)!;
    
    try {
      setState(() {
        _isUploadingPhoto = true;
        _uploadProgress = 0.0;
      });
      
      final photo = await _photoService.updateTransactionPhotoProofWithPicker(
        _transaction!.id,
        context: context,
        onProgress: (sent, total) {
          if (mounted) {
            setState(() {
              _uploadProgress = PhotoService.calculateUploadProgress(sent, total);
            });
          }
        },
      );
      
      if (!mounted) return;
      
      setState(() {
        _isUploadingPhoto = false;
        _uploadProgress = 0.0;
      });
      
      if (photo != null) {
        setState(() {
          _photoProof = photo;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.transactions_message_photoProofUpdated),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isUploadingPhoto = false;
        _uploadProgress = 0.0;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.transactions_error_photoProofUpdateFailed(e.toString())),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  /// Update transfer proof
  Future<void> _updateTransferProof() async {
    if (_transaction == null || _isUploadingPhoto) return;
    
    final l10n = AppLocalizations.of(context)!;
    
    try {
      setState(() {
        _isUploadingPhoto = true;
        _uploadProgress = 0.0;
      });
      
      final photo = await _photoService.updateTransactionTransferProofWithPicker(
        _transaction!.id,
        context: context,
        onProgress: (sent, total) {
          if (mounted) {
            setState(() {
              _uploadProgress = PhotoService.calculateUploadProgress(sent, total);
            });
          }
        },
      );
      
      if (!mounted) return;
      
      setState(() {
        _isUploadingPhoto = false;
        _uploadProgress = 0.0;
      });
      
      if (photo != null) {
        setState(() {
          _transferProof = photo;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.transactions_message_transferProofUpdated),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isUploadingPhoto = false;
        _uploadProgress = 0.0;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.transactions_error_transferProofUpdateFailed(e.toString())),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  /// Remove photo proof
  Future<void> _removePhotoProof() async {
    if (_photoProof == null) return;
    
    final l10n = AppLocalizations.of(context)!;
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.transactions_title_removePhotoProof),
        content: Text(l10n.transactions_message_removePhotoProofConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.common_button_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.common_button_remove),
          ),
        ],
      ),
    );
    
    if (confirmed != true || !mounted) return;
    
    try {
      await _photoService.deletePhoto(_photoProof!.id);
      
      if (!mounted) return;
      
      setState(() {
        _photoProof = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.transactions_message_photoProofRemoved),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.transactions_error_photoProofRemoveFailed(e.toString())),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  /// Remove transfer proof
  Future<void> _removeTransferProof() async {
    if (_transferProof == null) return;
    
    final l10n = AppLocalizations.of(context)!;
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.transactions_title_removeTransferProof),
        content: Text(l10n.transactions_message_removeTransferProofConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.common_button_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.common_button_remove),
          ),
        ],
      ),
    );
    
    if (confirmed != true || !mounted) return;
    
    try {
      await _photoService.deletePhoto(_transferProof!.id);
      
      if (!mounted) return;
      
      setState(() {
        _transferProof = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.transactions_message_transferProofRemoved),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.transactions_error_transferProofRemoveFailed(e.toString())),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final canEdit = _canEditTransaction();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildWMSAppBar(context, canEdit, user),
      body: _buildBody(),
      floatingActionButton:
          _transaction != null && canEdit ? _buildFloatingActionButton() : null,
    );
  }

  PreferredSizeWidget _buildWMSAppBar(
      BuildContext context, bool canEdit, User? user) {
    // Guard clause: Owner, Admin, and Cashier can print receipts, Staff cannot
    final canPrintReceipt = (user?.role == UserRole.owner || 
                            user?.role == UserRole.admin || 
                            user?.role == UserRole.cashier) && _transaction != null;
    
    final l10n = AppLocalizations.of(context)!;
    
    return WMSAppBar(
      icon: Icons.receipt_long,
      title: l10n.transactions_title_detail,
      badge: _transaction?.isFinished == false 
        ? WMSAppBarBadge.pending(Theme.of(context))
        : _transaction?.isFinished == true
          ? WMSAppBarBadge.completed(Theme.of(context))
          : null,
      shareConfig: _transaction != null 
        ? WMSAppBarShare(onShare: _shareTransaction)
        : null,
      printConfig: canPrintReceipt 
        ? WMSAppBarPrint.receipt(
            onPrint: _printReceipt,
            onManagePrinter: _managePrinter,
          )
        : null,
      menuItems: canEdit && _transaction?.isFinished == false 
        ? [
            WMSAppBarMenuItem(
              value: 'finish',
              title: l10n.transactions_action_markFinished,
              icon: Icons.check_circle,
              onTap: _markFinished,
            ),
          ]
        : null,
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _editTransaction,
      backgroundColor: Theme.of(context).primaryColor,
      tooltip: 'Edit Transaction',
      child: const Icon(Icons.edit, color: Colors.white),
    );
  }

  Widget _buildBody() {
    // Guard clause: show loading state
    if (_isLoading) {
      return const Center(child: WMSLoadingIndicator());
    }

    // Guard clause: show error state
    if (_error != null) {
      return _buildErrorState();
    }

    // Guard clause: show not found state
    if (_transaction == null) {
      return _buildNotFoundState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTransactionHeroCard(),
          const SizedBox(height: 16),
          _buildTransactionInfoCard(),
          const SizedBox(height: 16),
          if (_transaction!.isTrade && _transaction!.hasTradeInProduct) ...[
            _buildTradeInProductCard(),
            const SizedBox(height: 16),
          ],
          _buildItemsListCard(),
          const SizedBox(height: 16),
          _buildPhotoSection(),
          const SizedBox(height: 16),
          _buildAuditInfoCard(),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .errorContainer
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load transaction',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Transaction not found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'This transaction may have been deleted or moved',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHeroCard() {
    // Guard clause: ensure transaction exists
    if (_transaction == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
            Theme.of(context).primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with type badge and status
            Row(
              children: [
                _buildModernTypeBadge(),
                const Spacer(),
                _buildModernStatusIndicator(),
              ],
            ),
            const SizedBox(height: 20),

            // Total amount section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.monetization_on,
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
                        'Total Amount',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        NumberUtils.formatDoubleAsInt(_transaction!.calculatedAmount),
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Transaction ID and date
            Row(
              children: [
                Icon(
                  Icons.receipt,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ID: ${_transaction!.id}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Text(
                  _formatTransactionDate(_transaction!.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // QR Code Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction QR Code',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: QrImageView(
                          data: _transaction!.id,
                          size: 80,
                          padding: const EdgeInsets.all(8),
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Colors.black,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scan for quick access',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'This QR code contains the transaction ID for easy verification and tracking.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTypeBadge() {
    // Guard clause: ensure transaction exists
    if (_transaction == null) return const SizedBox.shrink();

    final isTrade = _transaction!.type == TransactionType.trade;
    final isTransfer = _transaction!.type == TransactionType.transfer;
    final color = isTrade
        ? Colors.purple
        : isTransfer
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              isTrade
                  ? Icons.swap_calls
                  : isTransfer
                      ? Icons.swap_horiz
                      : Icons.point_of_sale,
              size: 14,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _transaction!.type.name.toUpperCase(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatusIndicator() {
    // Guard clause: ensure transaction exists
    if (_transaction == null) return const SizedBox.shrink();

    final isCompleted = _transaction!.isFinished;
    final color = isCompleted ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isCompleted ? 'Completed' : 'Pending',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }

  String _formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    // Guard clause: handle different time ranges
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    }

    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildTransactionInfoCard() {
    // Guard clause: ensure transaction exists
    if (_transaction == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Transaction Information',
              'Key details about this transaction',
              Icons.info_outline,
            ),
            const SizedBox(height: 16),
            _buildModernInfoRow('Date', _formatDate(_transaction!.createdAt),
                Icons.calendar_today),
            if (_transaction!.to != null)
              _buildModernInfoRow(
                _transaction!.type == TransactionType.sale
                    ? 'Customer'
                    : 'Destination',
                _transaction!.to!,
                _transaction!.type == TransactionType.sale
                    ? Icons.person
                    : Icons.store,
              ),
            if (_transaction!.customerPhone != null)
              _buildModernInfoRow(
                  'Phone', _transaction!.customerPhone!, Icons.phone),
            if (_transaction!.fromStoreName != null)
              _buildModernInfoRow('From Store', _transaction!.fromStoreName!,
                  Icons.store_mall_directory),
            if (_transaction!.toStoreName != null)
              _buildModernInfoRow(
                  'To Store', _transaction!.toStoreName!, Icons.store),
            if (_transaction!.isTrade && _transaction!.tradeInProductName != null)
              _buildModernInfoRow('Trade-In Product', 
                  _transaction!.tradeInProductName!, Icons.swap_calls),
            if (_transaction!.isTrade && _transaction!.tradeInProductId != null)
              _buildModernInfoRow('Trade-In Product ID', 
                  _transaction!.tradeInProductId!, Icons.qr_code),
            _buildModernInfoRow('Items Count',
                '${_transaction!.items?.length ?? 0}', Icons.inventory_2),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeInProductCard() {
    // Guard clause: ensure transaction exists and has trade-in product
    if (_transaction == null || !_transaction!.hasTradeInProduct) {
      return const SizedBox.shrink();
    }

    return Container(
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
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Trade-In Product',
              'Product accepted for trade-in',
              Icons.swap_calls,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => AppRouter.pushToProductDetail(context, _transaction!.tradeInProductId!),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.purple.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.devices,
                        color: Colors.purple,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _transaction!.tradeInProductName ?? 'Trade-In Product',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple[800],
                                ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${_transaction!.tradeInProductId}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.purple[600],
                                  fontFamily: 'monospace',
                                ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'TRADE-IN',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple[800],
                                  fontSize: 10,
                                ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.purple[600],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildItemsListCard() {
    // Guard clause: ensure transaction exists
    if (_transaction == null) return const SizedBox.shrink();

    final items = _transaction!.items ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Transaction Items',
              '${items.length} items in this transaction',
              Icons.inventory_2,
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              _buildEmptyItemsState()
            else
              ...items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    _buildModernItemRow(item),
                    if (index < items.length - 1)
                      Divider(
                        height: 24,
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.2),
                      ),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }


  /// Build photo management section
  Widget _buildPhotoSection() {
    if (_transaction == null) return const SizedBox.shrink();
    
    final l10n = AppLocalizations.of(context)!;
    final isTransfer = _transaction!.type == TransactionType.transfer;
    final canEdit = _canEditTransaction();
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              l10n.transactions_title_photoManagement,
              l10n.transactions_subtitle_photoManagement,
              Icons.photo_library,
            ),
            const SizedBox(height: 16),
            
            // Photo Proof Section (for all transaction types)
            _buildPhotoProofSection(canEdit),
            
            // Transfer Proof Section (only for TRANSFER transactions)
            if (isTransfer) ...[
              const SizedBox(height: 16),
              _buildTransferProofSection(canEdit),
            ],
            
            // Upload progress indicator
            if (_isUploadingPhoto) ...[
              const SizedBox(height: 16),
              _buildUploadProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  /// Build photo proof section
  Widget _buildPhotoProofSection(bool canEdit) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.photo_camera,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.transactions_label_photoProof,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (canEdit && !_isUploadingPhoto) ...
              _buildPhotoActions(
                photo: _photoProof,
                onAdd: _addPhotoProof,
                onUpdate: _updatePhotoProof,
                onRemove: _removePhotoProof,
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingPhotos)
          _buildPhotoLoadingState()
        else if (_photoProof != null)
          _buildPhotoDisplay(_photoProof!)
        else
          _buildNoPhotoState(l10n.transactions_message_noPhotoProof),
      ],
    );
  }

  /// Build transfer proof section
  Widget _buildTransferProofSection(bool canEdit) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.receipt_long,
              size: 20,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.transactions_label_transferProof,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (canEdit && !_isUploadingPhoto) ...
              _buildPhotoActions(
                photo: _transferProof,
                onAdd: _addTransferProof,
                onUpdate: _updateTransferProof,
                onRemove: _removeTransferProof,
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingPhotos)
          _buildPhotoLoadingState()
        else if (_transferProof != null)
          _buildPhotoDisplay(_transferProof!)
        else
          _buildNoPhotoState(l10n.transactions_message_noTransferProof),
      ],
    );
  }

  /// Build photo action buttons
  List<Widget> _buildPhotoActions({
    required Photo? photo,
    required VoidCallback onAdd,
    required VoidCallback onUpdate,
    required VoidCallback onRemove,
  }) {
    final l10n = AppLocalizations.of(context)!;
    
    if (photo == null) {
      return [
        FilledButton.tonal(
          onPressed: onAdd,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_photo_alternate, size: 16),
              const SizedBox(width: 4),
              Text(l10n.common_button_add),
            ],
          ),
        ),
      ];
    }
    
    return [
      PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'change':
              onUpdate();
              break;
            case 'remove':
              onRemove();
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'change',
            child: Row(
              children: [
                const Icon(Icons.edit, size: 16),
                const SizedBox(width: 8),
                Text(l10n.common_button_change),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'remove',
            child: Row(
              children: [
                const Icon(Icons.delete, size: 16, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  l10n.common_button_remove,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.more_vert, size: 16),
        ),
      ),
    ];
  }

  /// Build photo display widget
  Widget _buildPhotoDisplay(Photo photo) {
    return GestureDetector(
      onTap: () => _viewPhoto(photo),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  photo.mediumUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              color: Theme.of(context).colorScheme.error,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context)!.common_error_loadImageFailed,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    photo.type.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.zoom_in,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build no photo state
  Widget _buildNoPhotoState(String message) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build photo loading state
  Widget _buildPhotoLoadingState() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Build upload progress indicator
  Widget _buildUploadProgressIndicator() {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_upload,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.transactions_message_uploadingPhoto,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Text(
                '${_uploadProgress.toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _uploadProgress / 100,
            backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
        ],
      ),
    );
  }


  Widget _buildAuditInfoCard() {
    // Guard clause: ensure transaction exists
    if (_transaction == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Audit Information',
              'Transaction creation and approval history',
              Icons.history,
            ),
            const SizedBox(height: 16),
            _buildModernInfoRow('Created',
                _formatDateTime(_transaction!.createdAt), Icons.schedule),
            if (_transaction!.createdByName != null)
              _buildModernInfoRow(
                  'Created By', _transaction!.createdByName!, Icons.person),
            if (_transaction!.approvedByName != null)
              _buildModernInfoRow('Approved By', _transaction!.approvedByName!,
                  Icons.verified_user),
          ],
        ),
      ),
    );
  }

  // Modern helper methods for redesigned components
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
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            child: Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyItemsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 32,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'No items found',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernItemRow(TransactionItem item) {
    return InkWell(
      onTap: () => AppRouter.pushToProductDetail(context, item.productId),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${item.productId}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontFamily: 'monospace',
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${item.quantity}x',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  NumberUtils.formatDoubleAsInt(item.price),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Network Photo Viewer for displaying photos from URLs
class _NetworkPhotoViewer extends StatefulWidget {
  final Photo photo;
  final String? title;

  const _NetworkPhotoViewer({
    required this.photo,
    this.title,
  });

  @override
  State<_NetworkPhotoViewer> createState() => _NetworkPhotoViewerState();
}

class _NetworkPhotoViewerState extends State<_NetworkPhotoViewer> {
  bool _showOverlay = true;
  TransformationController? _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController?.dispose();
    super.dispose();
  }

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  void _resetZoom() {
    _transformationController?.value = Matrix4.identity();
  }

  void _showPhotoInfo() {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.transactions_title_photoInfo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(l10n.transactions_label_photoType, widget.photo.type.displayName),
            const SizedBox(height: 8),
            _buildInfoRow(l10n.transactions_label_photoId, widget.photo.id.substring(0, 8)),
            const SizedBox(height: 8),
            _buildInfoRow(l10n.transactions_label_uploadedAt, _formatDateTime(widget.photo.createdAt)),
            const SizedBox(height: 8),
            _buildInfoRow(l10n.transactions_label_uploadedBy, widget.photo.createdBy),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.common_button_close),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _showOverlay
          ? AppBar(
              title: Text(widget.title ?? l10n.transactions_title_photoViewer),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  onPressed: _showPhotoInfo,
                  icon: const Icon(Icons.info_outline),
                  tooltip: l10n.transactions_title_photoInfo,
                ),
                IconButton(
                  onPressed: _resetZoom,
                  icon: const Icon(Icons.fullscreen_exit),
                  tooltip: l10n.transactions_action_resetZoom,
                ),
              ],
            )
          : null,
      body: GestureDetector(
        onTap: _toggleOverlay,
        child: Center(
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.5,
            maxScale: 3.0,
            child: Image.network(
              widget.photo.secureUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.common_message_loading,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.common_error_loadImageFailed,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
