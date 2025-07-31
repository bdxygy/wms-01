import 'package:flutter/material.dart';

import '../../../core/models/transaction.dart';
import '../../../core/widgets/cards.dart';

/// Transaction List Item Widget
/// 
/// Displays a transaction in a card format with:
/// - Transaction type badge
/// - Amount and completion status
/// - Customer/destination info
/// - Quick action buttons (edit, mark finished)
/// - Tap to view details
class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onMarkFinished;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onEdit,
    this.onMarkFinished,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: WMSCard(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with type badge and amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTypeBadge(context),
                    Text(
                      transaction.calculatedAmount.toInt().toString(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Transaction ID and date
                Row(
                  children: [
                    Icon(
                      Icons.receipt,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      transaction.id.substring(0, 8),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(transaction.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Customer/destination info
                if (transaction.to != null) ...[
                  Row(
                    children: [
                      Icon(
                        _getInfoIcon(),
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          transaction.to!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],

                // Items count
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${transaction.items?.length ?? 0} items',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    _buildStatusIndicator(context),
                  ],
                ),

                // Action buttons
                if (onEdit != null || onMarkFinished != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onEdit != null) ...[
                        TextButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (onMarkFinished != null) ...[
                        TextButton.icon(
                          onPressed: onMarkFinished,
                          icon: const Icon(Icons.check_circle, size: 16),
                          label: const Text('Finish'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(BuildContext context) {
    Color badgeColor;
    IconData badgeIcon;
    
    switch (transaction.type) {
      case TransactionType.transfer:
        badgeColor = Theme.of(context).colorScheme.secondary;
        badgeIcon = Icons.swap_horiz;
        break;
      case TransactionType.trade:
        badgeColor = Colors.purple;
        badgeIcon = Icons.swap_calls;
        break;
      case TransactionType.sale:
        badgeColor = Theme.of(context).colorScheme.primary;
        badgeIcon = Icons.point_of_sale;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeIcon,
            size: 14,
            color: badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            transaction.type.name.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getInfoIcon() {
    switch (transaction.type) {
      case TransactionType.sale:
      case TransactionType.trade:
        return Icons.person; // Customer for SALE and TRADE
      case TransactionType.transfer:
        return Icons.store; // Destination store for TRANSFER
    }
  }

  Widget _buildStatusIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: transaction.isFinished ? Colors.green.withValues(alpha:0.1) : Colors.orange.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            transaction.isFinished ? Icons.check_circle : Icons.pending,
            size: 12,
            color: transaction.isFinished ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            transaction.isFinished ? 'Completed' : 'Pending',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: transaction.isFinished ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}