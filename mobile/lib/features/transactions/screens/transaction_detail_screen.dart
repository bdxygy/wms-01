import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_bars.dart';
import '../../../core/widgets/cards.dart';
import '../../../core/services/transaction_service.dart';
import '../../../core/models/transaction.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/routing/app_router.dart';

/// Transaction Detail Screen
/// 
/// Displays comprehensive transaction information with:
/// - Transaction header (type, status, amount)
/// - Customer/destination information
/// - Item list with product details
/// - Photo/transfer proof display
/// - Action buttons (edit, mark finished, print receipt)
/// - Audit trail (created by, approved by)
/// 
/// Permissions:
/// - OWNER/ADMIN: Full view and edit access
/// - CASHIER: View and limited edit for SALE transactions
/// - STAFF: Read-only access
class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;

  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final TransactionService _transactionService = TransactionService();
  
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

  Future<void> _markFinished() async {
    if (_transaction == null || _isUpdating) return;
    
    setState(() {
      _isUpdating = true;
    });

    try {
      final updatedTransaction = await _transactionService.finishTransaction(_transaction!.id);
      
      if (!mounted) return;
      
      setState(() {
        _transaction = updatedTransaction;
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction marked as finished'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark transaction as finished: $e'),
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
    return userRole != null && TransactionService.canUpdateTransaction(userRole);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WMSAppBar(
        title: 'Transaction Detail',
        actions: [
          if (_transaction != null && _canEditTransaction()) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editTransaction,
              tooltip: 'Edit Transaction',
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'finish':
                    _markFinished();
                    break;
                  case 'print':
                    // TODO: Implement print functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Print functionality coming soon')),
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                if (!_transaction!.isFinished)
                  const PopupMenuItem(
                    value: 'finish',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 20),
                        SizedBox(width: 8),
                        Text('Mark as Finished'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'print',
                  child: Row(
                    children: [
                      Icon(Icons.print, size: 20),
                      SizedBox(width: 8),
                      Text('Print Receipt'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTransactionHeader(),
          const SizedBox(height: 16),
          _buildTransactionInfo(),
          const SizedBox(height: 16),
          _buildItemsList(),
          const SizedBox(height: 16),
          if (_transaction!.photoProofUrl != null || _transaction!.transferProofUrl != null)
            _buildProofSection(),
          if (_transaction!.photoProofUrl != null || _transaction!.transferProofUrl != null)
            const SizedBox(height: 16),
          _buildAuditInfo(),
        ],
      ),
    );
  }

  Widget _buildTransactionHeader() {
    return WMSCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTypeBadge(),
                _buildStatusIndicator(),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Total Amount',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Flexible(
                  child: Text(
                    _transaction!.calculatedAmount.toInt().toString(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.receipt,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'ID: ${_transaction!.id}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge() {
    final isTransfer = _transaction!.type == TransactionType.transfer;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isTransfer 
            ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTransfer 
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isTransfer ? Icons.swap_horiz : Icons.point_of_sale,
            size: 16,
            color: isTransfer 
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            _transaction!.type.name.toUpperCase(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isTransfer 
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _transaction!.isFinished 
            ? Colors.green.withValues(alpha: 0.1) 
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _transaction!.isFinished ? Icons.check_circle : Icons.pending,
            size: 16,
            color: _transaction!.isFinished ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 6),
          Text(
            _transaction!.isFinished ? 'Completed' : 'Pending',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: _transaction!.isFinished ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionInfo() {
    return WMSCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildInfoRow('Date', _formatDate(_transaction!.createdAt)),
            
            if (_transaction!.to != null)
              _buildInfoRow(
                _transaction!.type == TransactionType.sale ? 'Customer' : 'Destination',
                _transaction!.to!,
              ),
            
            if (_transaction!.customerPhone != null)
              _buildInfoRow('Phone', _transaction!.customerPhone!),
            
            if (_transaction!.fromStoreName != null)
              _buildInfoRow('From Store', _transaction!.fromStoreName!),
            
            if (_transaction!.toStoreName != null)
              _buildInfoRow('To Store', _transaction!.toStoreName!),
            
            _buildInfoRow('Items Count', '${_transaction!.items?.length ?? 0}'),
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

  Widget _buildItemsList() {
    final items = _transaction!.items ?? [];
    
    return WMSCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Items',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (items.isEmpty)
              const Text('No items found')
            else
              ...items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    _buildItemRow(item),
                    if (index < items.length - 1) const Divider(),
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
              item.price.toInt().toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              (item.amount ?? 0.0).toInt().toString(),
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
    return WMSCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proof Documentation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_transaction!.photoProofUrl != null) ...[
              _buildProofItem(
                'Photo Proof',
                _transaction!.photoProofUrl!,
                Icons.photo_camera,
              ),
              const SizedBox(height: 12),
            ],
            
            if (_transaction!.transferProofUrl != null) ...[
              _buildProofItem(
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

  Widget _buildAuditInfo() {
    return WMSCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Audit Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildInfoRow('Created', _formatDateTime(_transaction!.createdAt)),
            
            if (_transaction!.createdByName != null)
              _buildInfoRow('Created By', _transaction!.createdByName!),
            
            if (_transaction!.approvedByName != null)
              _buildInfoRow('Approved By', _transaction!.approvedByName!),
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