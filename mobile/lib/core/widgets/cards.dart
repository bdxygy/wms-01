import 'package:flutter/material.dart';

import '../theme/theme_colors.dart';
import '../theme/typography.dart';

/// Card components for the WMS application
/// Provides consistent card layouts and styles

/// Base WMS card with consistent styling
class WMSCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;

  const WMSCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: elevation ?? 2,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    return onTap != null
        ? InkWell(
            onTap: onTap,
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            child: card,
          )
        : card;
  }
}

/// Product card for displaying product information
class WMSProductCard extends StatelessWidget {
  final String productName;
  final String? sku;
  final String? barcode;
  final double? price;
  final int? quantity;
  final String? imageUrl;
  final bool hasImei;
  final VoidCallback? onTap;
  final List<Widget>? actions;

  const WMSProductCard({
    super.key,
    required this.productName,
    this.sku,
    this.barcode,
    this.price,
    this.quantity,
    this.imageUrl,
    this.hasImei = false,
    this.onTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return WMSCard(
      onTap: onTap,
      child: Row(
        children: [
          // Product image placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: WMSColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: WMSColors.outline, width: 1),
            ),
            child: imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported,
                        color: WMSColors.textSecondary,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.inventory_2_outlined,
                    color: WMSColors.textSecondary,
                    size: 32,
                  ),
          ),
          const SizedBox(width: 16),
          
          // Product information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        productName,
                        style: WMSTypography.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasImei)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: WMSColors.infoBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'IMEI',
                          style: WMSTypography.labelSmall.copyWith(
                            color: WMSColors.infoBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                
                if (sku != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'SKU: $sku',
                    style: WMSTypography.productSku,
                  ),
                ],
                
                if (barcode != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Barcode: $barcode',
                    style: WMSTypography.bodySmall.copyWith(
                      color: WMSColors.textSecondary,
                    ),
                  ),
                ],
                
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (price != null)
                      Text(
                        '${price!.toInt()}',
                        style: WMSTypography.productPrice,
                      ),
                    const Spacer(),
                    if (quantity != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: quantity! > 0 
                              ? WMSColors.successGreen.withOpacity(0.1)
                              : WMSColors.errorRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Qty: $quantity',
                          style: WMSTypography.labelSmall.copyWith(
                            color: quantity! > 0 
                                ? WMSColors.successGreen
                                : WMSColors.errorRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // Actions
          if (actions != null) ...[
            const SizedBox(width: 8),
            Column(
              children: actions!,
            ),
          ],
        ],
      ),
    );
  }
}

/// Transaction card for displaying transaction information
class WMSTransactionCard extends StatelessWidget {
  final String transactionId;
  final String type;
  final double amount;
  final DateTime date;
  final String? customerName;
  final String? storeName;
  final String status;
  final int itemCount;
  final VoidCallback? onTap;
  final List<Widget>? actions;

  const WMSTransactionCard({
    super.key,
    required this.transactionId,
    required this.type,
    required this.amount,
    required this.date,
    this.customerName,
    this.storeName,
    required this.status,
    required this.itemCount,
    this.onTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return WMSCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: WMSColors.getTransactionTypeColor(type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  type.toUpperCase(),
                  style: WMSTypography.getTransactionTypeStyle(type),
                ),
              ),
              const Spacer(),
              Text(
                '#${transactionId.substring(0, 8)}',
                style: WMSTypography.transactionId,
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Amount
          Text(
            '${amount.toInt()}',
            style: WMSTypography.transactionAmount,
          ),
          
          const SizedBox(height: 8),
          
          // Customer or store info
          if (customerName != null)
            Text(
              'Customer: $customerName',
              style: WMSTypography.bodyMedium,
            )
          else if (storeName != null)
            Text(
              'Store: $storeName',
              style: WMSTypography.bodyMedium,
            ),
          
          const SizedBox(height: 8),
          
          // Footer row
          Row(
            children: [
              Text(
                '${date.day}/${date.month}/${date.year}',
                style: WMSTypography.bodySmall.copyWith(
                  color: WMSColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$itemCount items',
                style: WMSTypography.bodySmall.copyWith(
                  color: WMSColors.textSecondary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: WMSTypography.labelSmall.copyWith(
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          // Actions
          if (actions != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions!,
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return WMSColors.successGreen;
      case 'pending':
        return WMSColors.warningAmber;
      case 'failed':
        return WMSColors.errorRed;
      default:
        return WMSColors.textSecondary;
    }
  }
}

/// Stats card for displaying metrics
class WMSStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;
  final VoidCallback? onTap;

  const WMSStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? WMSColors.primaryBlue;
    
    return WMSCard(
      onTap: onTap,
      backgroundColor: cardColor.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: cardColor,
                  size: 24,
                ),
              ),
              const Spacer(),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: WMSColors.textSecondary,
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            value,
            style: WMSTypography.numericLarge.copyWith(color: cardColor),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            title,
            style: WMSTypography.bodyMedium.copyWith(
              color: WMSColors.textSecondary,
            ),
          ),
          
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: WMSTypography.bodySmall.copyWith(
                color: WMSColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// User card for displaying user information
class WMSUserCard extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;
  final bool isActive;
  final VoidCallback? onTap;
  final List<Widget>? actions;

  const WMSUserCard({
    super.key,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.isActive = true,
    this.onTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return WMSCard(
      onTap: onTap,
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: WMSColors.getRoleColor(role).withOpacity(0.1),
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: WMSTypography.titleMedium.copyWith(
                      color: WMSColors.getRoleColor(role),
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          
          const SizedBox(width: 16),
          
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: WMSTypography.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? WMSColors.successGreen : WMSColors.errorRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  email,
                  style: WMSTypography.bodySmall.copyWith(
                    color: WMSColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: WMSColors.getRoleColor(role).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: WMSTypography.getRoleStyle(role),
                  ),
                ),
              ],
            ),
          ),
          
          // Actions
          if (actions != null) ...[
            const SizedBox(width: 8),
            Column(
              children: actions!,
            ),
          ],
        ],
      ),
    );
  }
}