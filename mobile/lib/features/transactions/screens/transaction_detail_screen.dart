import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../generated/app_localizations.dart';
import '../../../core/widgets/loading.dart';
import '../../../core/widgets/barcode_quantity_dialog.dart';
import '../../../core/widgets/wms_app_bar.dart';
import '../../../core/services/transaction_service.dart';
import '../../../core/services/print_launcher.dart';
import '../../../core/models/transaction.dart';
import '../../../core/models/user.dart';
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

  Transaction? _transaction;
  bool _isLoading = true;
  String? _error;
  bool _isUpdating = false;

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

  void _viewPhoto(String photoUrl) {
    // Guard clause: validate photo URL
    if (photoUrl.isEmpty) return;

    // TODO: Implement photo viewing with PhotoViewer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Photo viewer coming soon')),
    );
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
          _buildItemsListCard(),
          const SizedBox(height: 16),
          if (_transaction!.photoProofUrl != null ||
              _transaction!.transferProofUrl != null) ...[
            _buildProofSection(),
            const SizedBox(height: 16),
          ],
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
          ],
        ),
      ),
    );
  }

  Widget _buildModernTypeBadge() {
    // Guard clause: ensure transaction exists
    if (_transaction == null) return const SizedBox.shrink();

    final isTransfer = _transaction!.type == TransactionType.transfer;
    final color = isTransfer
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
              isTransfer ? Icons.swap_horiz : Icons.point_of_sale,
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
            _buildModernInfoRow('Items Count',
                '${_transaction!.items?.length ?? 0}', Icons.inventory_2),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
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

  Widget _buildItemRow(TransactionItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  'ID: ${item.productId}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontFamily: 'monospace',
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${item.quantity}x',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              NumberUtils.formatDoubleAsInt(item.price),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              NumberUtils.formatDoubleAsInt(item.amount ?? 0.0),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProofSection() {
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
              'Proof Documentation',
              'Photo and transfer proof files',
              Icons.photo_library,
            ),
            const SizedBox(height: 16),
            if (_transaction!.photoProofUrl != null) ...[
              _buildModernProofItem(
                'Photo Proof',
                _transaction!.photoProofUrl!,
                Icons.photo_camera,
              ),
              const SizedBox(height: 12),
            ],
            if (_transaction!.transferProofUrl != null) ...[
              _buildModernProofItem(
                'Transfer Proof',
                _transaction!.transferProofUrl!,
                Icons.receipt_long,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProofItem(String label, String url, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                url,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            // TODO: Implement photo viewing
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Photo viewing coming soon')),
            );
          },
          child: const Text('View'),
        ),
      ],
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
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
          Text(
            NumberUtils.formatDoubleAsInt(item.price),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildModernProofItem(String label, String url, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  url,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            onPressed: () => _viewPhoto(url),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: const Text('View'),
          ),
        ],
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
