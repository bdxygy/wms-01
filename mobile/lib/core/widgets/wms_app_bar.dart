import 'package:flutter/material.dart';
import '../../generated/app_localizations.dart';

/// WMS Global AppBar Component
///
/// Provides consistent theming and layout while remaining flexible for extensions.
/// Supports:
/// - Icon with background
/// - Dynamic title with overflow handling
/// - Status badges
/// - Custom action buttons
/// - Print functionality
/// - Share functionality
/// - Popup menu items
class WMSAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The main icon to display (e.g., Icons.inventory_2, Icons.receipt_long)
  final IconData icon;

  /// The title text to display
  final String title;

  /// Optional subtitle for additional context
  final String? subtitle;

  /// Optional status badge configuration
  final WMSAppBarBadge? badge;

  /// Custom action buttons (will be placed before the default actions)
  final List<Widget>? customActions;

  /// Share functionality configuration
  final WMSAppBarShare? shareConfig;

  /// Print functionality configuration
  final WMSAppBarPrint? printConfig;

  /// Additional popup menu items
  final List<WMSAppBarMenuItem>? menuItems;

  /// Whether to show the default more menu (three dots)
  final bool showMoreMenu;

  /// Custom leading widget (overrides default back button)
  final Widget? leading;

  /// Background color override (defaults to transparent)
  final Color? backgroundColor;

  /// Icon theme color override
  final Color? iconColor;

  /// Custom elevation (defaults to 0)
  final double elevation;

  /// Whether this app bar should be placed in a [SafeArea] widget
  final bool automaticallyImplyLeading;

  const WMSAppBar({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.badge,
    this.customActions,
    this.shareConfig,
    this.printConfig,
    this.menuItems,
    this.showMoreMenu = true,
    this.leading,
    this.backgroundColor,
    this.iconColor,
    this.elevation = 0,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Build popup menu items
    final popupMenuItems = <PopupMenuEntry<String>>[];

    // Add print menu items
    if (printConfig != null) {
      if (printConfig!.canPrintBarcode) {
        popupMenuItems.add(
          PopupMenuItem(
            value: 'print_barcode',
            child: Row(
              children: [
                Icon(Icons.qr_code, size: 20, color: theme.iconTheme.color),
                const SizedBox(width: 12),
                const Text('Print Barcode'),
              ],
            ),
          ),
        );
      }

      if (printConfig!.canPrintReceipt) {
        popupMenuItems.add(
          PopupMenuItem(
            value: 'print_receipt',
            child: Row(
              children: [
                Icon(Icons.receipt, size: 20, color: theme.iconTheme.color),
                const SizedBox(width: 12),
                const Text('Print Receipt'),
              ],
            ),
          ),
        );
      }

      if (printConfig!.canManagePrinter) {
        popupMenuItems.add(
          PopupMenuItem(
            value: 'manage_printer',
            child: Row(
              children: [
                Icon(Icons.print, size: 20, color: theme.iconTheme.color),
                const SizedBox(width: 12),
                const Text('Manage Printer'),
              ],
            ),
          ),
        );
      }
    }

    // Add custom menu items
    if (menuItems != null) {
      if (popupMenuItems.isNotEmpty) {
        popupMenuItems.add(const PopupMenuDivider());
      }

      for (final item in menuItems!) {
        popupMenuItems.add(
          PopupMenuItem(
            value: item.value,
            child: Row(
              children: [
                Icon(item.icon,
                    size: 20,
                    color: item.isDestructive
                        ? theme.colorScheme.error
                        : theme.iconTheme.color),
                const SizedBox(width: 12),
                Text(item.title,
                    style: TextStyle(
                      color: item.isDestructive
                          ? theme.colorScheme.error
                          : theme.iconTheme.color,
                    )),
              ],
            ),
          ),
        );
      }
    }

    return AppBar(
      elevation: elevation,
      iconTheme: IconTheme.of(context).copyWith(
        color: iconColor ?? theme.iconTheme.color,
      ),
      backgroundColor: backgroundColor ?? Colors.transparent,
      foregroundColor: iconColor ?? theme.iconTheme.color,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      title: _buildTitle(context, theme),
      actions: _buildActions(context, theme, l10n, popupMenuItems),
    );
  }

  Widget _buildTitle(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon with background
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? theme.primaryColor).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor ?? theme.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),

        // Title and subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ],
          ),
        ),

        // Status badge
        if (badge != null) ...[
          const SizedBox(width: 4),
          Flexible(
            child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: badge!.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: badge!.borderColor != null
                  ? Border.all(color: badge!.borderColor!)
                  : null,
            ),
            child: Text(
              badge!.text,
              style: theme.textTheme.labelSmall?.copyWith(
                color: badge!.textColor,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildActions(
    BuildContext context,
    ThemeData th,
    AppLocalizations l10n,
    List<PopupMenuEntry<String>> popupMenuItems,
  ) {
    final actions = <Widget>[];

    // Add custom actions first
    if (customActions != null) {
      actions.addAll(customActions!);
    }

    // Add share button
    if (shareConfig != null) {
      actions.add(
        IconButton(
          icon: Icon(
            Icons.share_outlined,
            color: th.iconTheme.color,
          ),
          onPressed: shareConfig!.onShare,
          tooltip: 'Share',
        ),
      );
    }

    // Add direct print button (if only one print option)
    if (printConfig != null && _shouldShowDirectPrintButton()) {
      actions.add(
        IconButton(
          icon: Icon(
            Icons.print_outlined,
            color: th.iconTheme.color,
          ),
          onPressed: _getDirectPrintAction(),
          tooltip: 'Print',
        ),
      );
    }

    // Add popup menu if there are items or showMoreMenu is true
    if (popupMenuItems.isNotEmpty && showMoreMenu) {
      actions.add(
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: th.iconTheme.color),
          onSelected: (value) => _handleMenuSelection(value),
          itemBuilder: (context) => popupMenuItems,
        ),
      );
    }

    return actions;
  }

  bool _shouldShowDirectPrintButton() {
    if (printConfig == null) return false;

    final printOptions = [
      printConfig!.canPrintBarcode,
      printConfig!.canPrintReceipt,
    ].where((option) => option).length;

    return printOptions == 1;
  }

  VoidCallback? _getDirectPrintAction() {
    if (printConfig?.canPrintBarcode == true) {
      return printConfig!.onPrintBarcode;
    }
    if (printConfig?.canPrintReceipt == true) {
      return printConfig!.onPrintReceipt;
    }
    return null;
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'print_barcode':
        printConfig?.onPrintBarcode?.call();
        break;
      case 'print_receipt':
        printConfig?.onPrintReceipt?.call();
        break;
      case 'manage_printer':
        printConfig?.onManagePrinter?.call();
        break;
      default:
        // Handle custom menu items
        final menuItem = menuItems?.firstWhere(
          (item) => item.value == value,
          orElse: () => WMSAppBarMenuItem(
            value: value,
            title: '',
            icon: Icons.error,
            onTap: () {},
          ),
        );
        menuItem?.onTap();
        break;
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Configuration for status badges in the app bar
class WMSAppBarBadge {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const WMSAppBarBadge({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });

  /// Factory for IMEI product badge
  factory WMSAppBarBadge.imei(ThemeData theme) => WMSAppBarBadge(
        text: 'IMEI',
        backgroundColor: Colors.orange.withValues(alpha: 0.2),
        textColor: Colors.orange.shade700,
        borderColor: Colors.orange.withValues(alpha: 0.3),
      );

  /// Factory for pending/unfinished status badge
  factory WMSAppBarBadge.pending(ThemeData theme) => WMSAppBarBadge(
        text: 'PENDING',
        backgroundColor: Colors.orange.withValues(alpha: 0.1),
        textColor: Colors.orange.shade700,
        borderColor: Colors.orange.withValues(alpha: 0.3),
      );

  /// Factory for completed status badge
  factory WMSAppBarBadge.completed(ThemeData theme) => WMSAppBarBadge(
        text: 'COMPLETED',
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        textColor: Colors.green.shade700,
        borderColor: Colors.green.withValues(alpha: 0.3),
      );

  /// Factory for active status badge
  factory WMSAppBarBadge.active(ThemeData theme) => WMSAppBarBadge(
        text: 'ACTIVE',
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        textColor: Colors.green.shade700,
      );

  /// Factory for inactive status badge
  factory WMSAppBarBadge.inactive(ThemeData theme) => WMSAppBarBadge(
        text: 'INACTIVE',
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        textColor: Colors.red.shade700,
      );
}

/// Configuration for share functionality
class WMSAppBarShare {
  final VoidCallback onShare;

  const WMSAppBarShare({
    required this.onShare,
  });
}

/// Configuration for print functionality
class WMSAppBarPrint {
  final bool canPrintBarcode;
  final bool canPrintReceipt;
  final bool canManagePrinter;
  final VoidCallback? onPrintBarcode;
  final VoidCallback? onPrintReceipt;
  final VoidCallback? onManagePrinter;

  const WMSAppBarPrint({
    this.canPrintBarcode = false,
    this.canPrintReceipt = false,
    this.canManagePrinter = false,
    this.onPrintBarcode,
    this.onPrintReceipt,
    this.onManagePrinter,
  });

  /// Factory for barcode printing only
  factory WMSAppBarPrint.barcode({
    required VoidCallback onPrint,
    VoidCallback? onManagePrinter,
  }) =>
      WMSAppBarPrint(
        canPrintBarcode: true,
        canManagePrinter: onManagePrinter != null,
        onPrintBarcode: onPrint,
        onManagePrinter: onManagePrinter,
      );

  /// Factory for receipt printing only
  factory WMSAppBarPrint.receipt({
    required VoidCallback onPrint,
    VoidCallback? onManagePrinter,
  }) =>
      WMSAppBarPrint(
        canPrintReceipt: true,
        canManagePrinter: onManagePrinter != null,
        onPrintReceipt: onPrint,
        onManagePrinter: onManagePrinter,
      );

  /// Factory for both barcode and receipt printing
  factory WMSAppBarPrint.both({
    required VoidCallback onPrintBarcode,
    required VoidCallback onPrintReceipt,
    VoidCallback? onManagePrinter,
  }) =>
      WMSAppBarPrint(
        canPrintBarcode: true,
        canPrintReceipt: true,
        canManagePrinter: onManagePrinter != null,
        onPrintBarcode: onPrintBarcode,
        onPrintReceipt: onPrintReceipt,
        onManagePrinter: onManagePrinter,
      );
}

/// Custom menu item for the app bar popup menu
class WMSAppBarMenuItem {
  final String value;
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const WMSAppBarMenuItem({
    required this.value,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  /// Factory for edit menu item
  factory WMSAppBarMenuItem.edit({
    required VoidCallback onTap,
    required String title,
  }) =>
      WMSAppBarMenuItem(
        value: 'edit',
        title: title,
        icon: Icons.edit_outlined,
        onTap: onTap,
      );

  /// Factory for delete menu item
  factory WMSAppBarMenuItem.delete({
    required VoidCallback onTap,
    required String title,
  }) =>
      WMSAppBarMenuItem(
        value: 'delete',
        title: title,
        icon: Icons.delete_outline,
        onTap: onTap,
        isDestructive: true,
      );

  /// Factory for duplicate menu item
  factory WMSAppBarMenuItem.duplicate({
    required VoidCallback onTap,
    required String title,
  }) =>
      WMSAppBarMenuItem(
        value: 'duplicate',
        title: title,
        icon: Icons.copy_outlined,
        onTap: onTap,
      );
}
