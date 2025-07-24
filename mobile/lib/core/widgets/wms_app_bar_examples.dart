import 'package:flutter/material.dart';
import 'wms_app_bar.dart';

/// WMSAppBar Usage Examples
/// 
/// This file demonstrates various ways to use the WMSAppBar component
/// across different types of screens in the WMS app.
class WMSAppBarExamples {
  
  /// Example 1: Basic Detail Screen (Product, User, Transaction, etc.)
  /// Shows title with icon, share button, and simple menu
  static PreferredSizeWidget basicDetailScreen({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onShare,
    List<WMSAppBarMenuItem>? menuItems,
  }) {
    return WMSAppBar(
      icon: icon,
      title: title,
      subtitle: subtitle,
      shareConfig: WMSAppBarShare(onShare: onShare),
      menuItems: menuItems,
    );
  }

  /// Example 2: Product Detail Screen
  /// Shows IMEI badge, barcode printing, and delete option
  static PreferredSizeWidget productDetailScreen({
    required String productName,
    required bool isImeiProduct,
    required VoidCallback onShare,
    required VoidCallback onPrintBarcode,
    required VoidCallback onManagePrinter,
    VoidCallback? onDelete,
    bool canDelete = false,
  }) {
    return WMSAppBar(
      icon: Icons.inventory_2,
      title: productName,
      badge: isImeiProduct 
        ? WMSAppBarBadge.imei(ThemeData())
        : null,
      shareConfig: WMSAppBarShare(onShare: onShare),
      printConfig: WMSAppBarPrint.barcode(
        onPrint: onPrintBarcode,
        onManagePrinter: onManagePrinter,
      ),
      menuItems: canDelete && onDelete != null
        ? [
            WMSAppBarMenuItem.delete(
              onTap: onDelete,
              title: 'Delete Product',
            ),
          ]
        : null,
    );
  }

  /// Example 3: Transaction Detail Screen
  /// Shows transaction status badge, receipt printing, and management options
  static PreferredSizeWidget transactionDetailScreen({
    required String transactionId,
    required bool isCompleted,
    required VoidCallback onPrintReceipt,
    VoidCallback? onEdit,
    VoidCallback? onComplete,
    VoidCallback? onCancel,
  }) {
    return WMSAppBar(
      icon: Icons.receipt_long,
      title: 'Transaction #$transactionId',
      badge: isCompleted
        ? WMSAppBarBadge.completed(ThemeData())
        : WMSAppBarBadge.pending(ThemeData()),
      printConfig: WMSAppBarPrint.receipt(
        onPrint: onPrintReceipt,
      ),
      menuItems: [
        if (onEdit != null)
          WMSAppBarMenuItem.edit(
            onTap: onEdit,
            title: 'Edit Transaction',
          ),
        if (onComplete != null && !isCompleted)
          WMSAppBarMenuItem(
            value: 'complete',
            title: 'Mark Complete',
            icon: Icons.check_circle_outline,
            onTap: onComplete,
          ),
        if (onCancel != null && !isCompleted)
          WMSAppBarMenuItem(
            value: 'cancel',
            title: 'Cancel Transaction',
            icon: Icons.cancel_outlined,
            onTap: onCancel,
            isDestructive: true,
          ),
      ],
    );
  }

  /// Example 4: User Detail Screen  
  /// Shows user status badge and management options
  static PreferredSizeWidget userDetailScreen({
    required String userName,
    required bool isActiveUser,
    VoidCallback? onEdit,
    VoidCallback? onDeactivate,
    VoidCallback? onResetPassword,
  }) {
    return WMSAppBar(
      icon: Icons.person,
      title: userName,
      subtitle: 'User Details',
      badge: isActiveUser
        ? WMSAppBarBadge.active(ThemeData())
        : WMSAppBarBadge.inactive(ThemeData()),
      menuItems: [
        if (onEdit != null)
          WMSAppBarMenuItem.edit(
            onTap: onEdit,
            title: 'Edit User',
          ),
        if (onResetPassword != null)
          WMSAppBarMenuItem(
            value: 'reset_password',
            title: 'Reset Password',
            icon: Icons.lock_reset,
            onTap: onResetPassword,
          ),
        if (onDeactivate != null)
          WMSAppBarMenuItem(
            value: 'deactivate',
            title: isActiveUser ? 'Deactivate User' : 'Activate User',
            icon: isActiveUser ? Icons.person_off : Icons.person,
            onTap: onDeactivate,
            isDestructive: isActiveUser,
          ),
      ],
    );
  }

  /// Example 5: Store Detail Screen
  /// Shows store status and management options
  static PreferredSizeWidget storeDetailScreen({
    required String storeName,
    required bool isActive,
    VoidCallback? onEdit,
    VoidCallback? onViewAnalytics,
    VoidCallback? onToggleStatus,
  }) {
    return WMSAppBar(
      icon: Icons.store,
      title: storeName,
      subtitle: 'Store Details',
      badge: isActive
        ? WMSAppBarBadge.active(ThemeData())
        : WMSAppBarBadge.inactive(ThemeData()),
      menuItems: [
        if (onEdit != null)
          WMSAppBarMenuItem.edit(
            onTap: onEdit,
            title: 'Edit Store',
          ),
        if (onViewAnalytics != null)
          WMSAppBarMenuItem(
            value: 'analytics',
            title: 'View Analytics',
            icon: Icons.analytics_outlined,
            onTap: onViewAnalytics,
          ),
        if (onToggleStatus != null)
          WMSAppBarMenuItem(
            value: 'toggle_status',
            title: isActive ? 'Deactivate Store' : 'Activate Store',
            icon: isActive ? Icons.store_mall_directory_outlined : Icons.store,
            onTap: onToggleStatus,
            isDestructive: isActive,
          ),
      ],
    );
  }

  /// Example 6: Form Screen (Create/Edit)
  /// Simple app bar for forms without extra actions
  static PreferredSizeWidget formScreen({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return WMSAppBar(
      icon: icon,
      title: title,
      subtitle: subtitle,
      showMoreMenu: false, // No menu for forms
    );
  }

  /// Example 7: List Screen with Multiple Print Options
  /// Shows both barcode and receipt printing options
  static PreferredSizeWidget multiPrintScreen({
    required IconData icon,
    required String title,
    required VoidCallback onPrintBarcodes,
    required VoidCallback onPrintReport,
    required VoidCallback onManagePrinter,
    VoidCallback? onExport,
  }) {
    return WMSAppBar(
      icon: icon,
      title: title,
      printConfig: WMSAppBarPrint.both(
        onPrintBarcode: onPrintBarcodes,
        onPrintReceipt: onPrintReport,
        onManagePrinter: onManagePrinter,
      ),
      menuItems: onExport != null
        ? [
            WMSAppBarMenuItem(
              value: 'export',
              title: 'Export Data',
              icon: Icons.download_outlined,
              onTap: onExport,
            ),
          ]
        : null,
    );
  }

  /// Example 8: Custom Actions with Direct Print Button
  /// Shows custom action buttons alongside print functionality
  static PreferredSizeWidget customActionsScreen({
    required String title,
    required List<Widget> customActions,
    VoidCallback? onPrint,
  }) {
    return WMSAppBar(
      icon: Icons.dashboard,
      title: title,
      customActions: customActions,
      printConfig: onPrint != null
        ? WMSAppBarPrint.barcode(onPrint: onPrint)
        : null,
    );
  }

  /// Example 9: Minimal App Bar
  /// Just icon and title, no additional functionality
  static PreferredSizeWidget minimalScreen({
    required IconData icon,
    required String title,
    Color? iconColor,
  }) {
    return WMSAppBar(
      icon: icon,
      title: title,
      iconColor: iconColor,
      showMoreMenu: false,
    );
  }

  /// Example 10: Settings Screen
  /// Custom background and no menu
  static PreferredSizeWidget settingsScreen({
    required String title,
    Color? backgroundColor,
  }) {
    return WMSAppBar(
      icon: Icons.settings,
      title: title,
      backgroundColor: backgroundColor,
      showMoreMenu: false,
    );
  }
}

/// Usage Examples in Actual Screens:
/// 
/// ```dart
/// // In ProductDetailScreen:
/// @override
/// Widget build(BuildContext context) {
///   return Scaffold(
///     appBar: WMSAppBarExamples.productDetailScreen(
///       productName: product.name,
///       isImeiProduct: product.isImei,
///       onShare: _shareProduct,
///       onPrintBarcode: _printBarcode,
///       onManagePrinter: _managePrinter,
///       onDelete: canDelete ? _deleteProduct : null,
///       canDelete: user.canDeleteProducts,
///     ),
///     body: _buildBody(),
///   );
/// }
/// 
/// // In TransactionDetailScreen:
/// @override
/// Widget build(BuildContext context) {
///   return Scaffold(
///     appBar: WMSAppBarExamples.transactionDetailScreen(
///       transactionId: transaction.id,
///       isCompleted: transaction.isFinished,
///       onPrintReceipt: _printReceipt,
///       onEdit: canEdit ? _editTransaction : null,
///       onComplete: canComplete ? _completeTransaction : null,
///       onCancel: canCancel ? _cancelTransaction : null,
///     ),
///     body: _buildBody(),
///   );
/// }
/// 
/// // In CreateProductScreen:
/// @override
/// Widget build(BuildContext context) {
///   return Scaffold(
///     appBar: WMSAppBarExamples.formScreen(
///       icon: Icons.add_box,
///       title: 'Create Product',
///       subtitle: 'Add new product to inventory',
///     ),
///     body: _buildForm(),
///   );
/// }
/// ```