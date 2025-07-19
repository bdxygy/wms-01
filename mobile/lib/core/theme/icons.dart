import 'package:flutter/material.dart';

/// Icon system for the WMS application
/// Provides consistent icons and icon styles across the app

class WMSIcons {
  // Private constructor to prevent instantiation
  WMSIcons._();

  // === NAVIGATION ICONS ===
  static const IconData home = Icons.home_outlined;
  static const IconData homeFilled = Icons.home;
  static const IconData dashboard = Icons.dashboard_outlined;
  static const IconData dashboardFilled = Icons.dashboard;
  static const IconData back = Icons.arrow_back;
  static const IconData forward = Icons.arrow_forward;
  static const IconData close = Icons.close;
  static const IconData menu = Icons.menu;
  static const IconData moreVert = Icons.more_vert;
  static const IconData moreHoriz = Icons.more_horiz;

  // === USER & AUTH ICONS ===
  static const IconData user = Icons.person_outlined;
  static const IconData userFilled = Icons.person;
  static const IconData users = Icons.people_outlined;
  static const IconData usersFilled = Icons.people;
  static const IconData login = Icons.login;
  static const IconData logout = Icons.logout;
  static const IconData profile = Icons.account_circle_outlined;
  static const IconData profileFilled = Icons.account_circle;
  static const IconData admin = Icons.admin_panel_settings_outlined;
  static const IconData adminFilled = Icons.admin_panel_settings;

  // === ROLE-SPECIFIC ICONS ===
  static const IconData owner = Icons.business_center_outlined;
  static const IconData ownerFilled = Icons.business_center;
  static const IconData manager = Icons.supervisor_account_outlined;
  static const IconData managerFilled = Icons.supervisor_account;
  static const IconData staff = Icons.badge_outlined;
  static const IconData staffFilled = Icons.badge;
  static const IconData cashier = Icons.point_of_sale_outlined;
  static const IconData cashierFilled = Icons.point_of_sale;

  // === PRODUCT ICONS ===
  static const IconData product = Icons.inventory_2_outlined;
  static const IconData productFilled = Icons.inventory_2;
  static const IconData products = Icons.view_list_outlined;
  static const IconData productsFilled = Icons.view_list;
  static const IconData category = Icons.category_outlined;
  static const IconData categoryFilled = Icons.category;
  static const IconData barcode = Icons.qr_code_scanner;
  static const IconData imei = Icons.phone_android;
  static const IconData sku = Icons.tag;
  static const IconData price = Icons.attach_money;
  static const IconData stock = Icons.warehouse;

  // === TRANSACTION ICONS ===
  static const IconData transaction = Icons.receipt_outlined;
  static const IconData transactionFilled = Icons.receipt;
  static const IconData sale = Icons.shopping_cart_outlined;
  static const IconData saleFilled = Icons.shopping_cart;
  static const IconData transfer = Icons.swap_horiz;
  static const IconData payment = Icons.payment;
  static const IconData cash = Icons.money;
  static const IconData checkout = Icons.shopping_cart_checkout;

  // === STORE ICONS ===
  static const IconData store = Icons.store_outlined;
  static const IconData storeFilled = Icons.store;
  static const IconData stores = Icons.storefront_outlined;
  static const IconData storesFilled = Icons.storefront;
  static const IconData location = Icons.location_on_outlined;
  static const IconData locationFilled = Icons.location_on;
  static const IconData address = Icons.home_work_outlined;
  static const IconData addressFilled = Icons.home_work;

  // === CAMERA & SCANNER ICONS ===
  static const IconData camera = Icons.camera_alt_outlined;
  static const IconData cameraFilled = Icons.camera_alt;
  static const IconData scan = Icons.qr_code_scanner;
  static const IconData scanner = Icons.scanner;
  static const IconData photo = Icons.photo_outlined;
  static const IconData photoFilled = Icons.photo;
  static const IconData gallery = Icons.photo_library_outlined;
  static const IconData galleryFilled = Icons.photo_library;

  // === PRINTER ICONS ===
  static const IconData print = Icons.print_outlined;
  static const IconData printFilled = Icons.print;
  static const IconData printer = Icons.local_print_shop_outlined;
  static const IconData printerFilled = Icons.local_print_shop;
  static const IconData bluetooth = Icons.bluetooth;
  static const IconData bluetoothConnected = Icons.bluetooth_connected;
  static const IconData bluetoothDisabled = Icons.bluetooth_disabled;

  // === ACTION ICONS ===
  static const IconData add = Icons.add;
  static const IconData edit = Icons.edit_outlined;
  static const IconData editFilled = Icons.edit;
  static const IconData delete = Icons.delete_outlined;
  static const IconData deleteFilled = Icons.delete;
  static const IconData save = Icons.save_outlined;
  static const IconData saveFilled = Icons.save;
  static const IconData cancel = Icons.cancel_outlined;
  static const IconData cancelFilled = Icons.cancel;
  static const IconData confirm = Icons.check_circle_outlined;
  static const IconData confirmFilled = Icons.check_circle;

  // === SEARCH & FILTER ICONS ===
  static const IconData search = Icons.search;
  static const IconData filter = Icons.filter_alt_outlined;
  static const IconData filterFilled = Icons.filter_alt;
  static const IconData sort = Icons.sort;
  static const IconData sortAsc = Icons.keyboard_arrow_up;
  static const IconData sortDesc = Icons.keyboard_arrow_down;
  static const IconData clear = Icons.clear;

  // === STATUS ICONS ===
  static const IconData success = Icons.check_circle_outlined;
  static const IconData successFilled = Icons.check_circle;
  static const IconData warning = Icons.warning_outlined;
  static const IconData warningFilled = Icons.warning;
  static const IconData error = Icons.error_outlined;
  static const IconData errorFilled = Icons.error;
  static const IconData info = Icons.info_outlined;
  static const IconData infoFilled = Icons.info;
  static const IconData pending = Icons.schedule;
  static const IconData complete = Icons.done;
  static const IconData incomplete = Icons.close;

  // === CONNECTIVITY ICONS ===
  static const IconData wifi = Icons.wifi;
  static const IconData wifiOff = Icons.wifi_off;
  static const IconData signal = Icons.signal_cellular_alt;
  static const IconData signalOff = Icons.signal_cellular_off;
  static const IconData sync = Icons.sync;
  static const IconData syncProblem = Icons.sync_problem;
  static const IconData offline = Icons.cloud_off;
  static const IconData online = Icons.cloud_done;

  // === SETTINGS ICONS ===
  static const IconData settings = Icons.settings_outlined;
  static const IconData settingsFilled = Icons.settings;
  static const IconData preferences = Icons.tune;
  static const IconData theme = Icons.palette_outlined;
  static const IconData themeFilled = Icons.palette;
  static const IconData language = Icons.language;
  static const IconData security = Icons.security_outlined;
  static const IconData securityFilled = Icons.security;

  // === VISIBILITY ICONS ===
  static const IconData visible = Icons.visibility_outlined;
  static const IconData visibleFilled = Icons.visibility;
  static const IconData hidden = Icons.visibility_off_outlined;
  static const IconData hiddenFilled = Icons.visibility_off;
  static const IconData expand = Icons.expand_more;
  static const IconData collapse = Icons.expand_less;

  // === TIME & DATE ICONS ===
  static const IconData time = Icons.access_time;
  static const IconData date = Icons.calendar_today;
  static const IconData dateRange = Icons.date_range;
  static const IconData history = Icons.history;
  static const IconData schedule = Icons.schedule;

  // === HELP & SUPPORT ICONS ===
  static const IconData help = Icons.help_outline;
  static const IconData helpFilled = Icons.help;
  static const IconData support = Icons.support_agent;
  static const IconData feedback = Icons.feedback_outlined;
  static const IconData feedbackFilled = Icons.feedback;
  static const IconData bug = Icons.bug_report_outlined;
  static const IconData bugFilled = Icons.bug_report;

  // === NOTIFICATION ICONS ===
  static const IconData notification = Icons.notifications_outlined;
  static const IconData notificationFilled = Icons.notifications;
  static const IconData notificationOff = Icons.notifications_off_outlined;
  static const IconData notificationOffFilled = Icons.notifications_off;
  static const IconData badge = Icons.circle_notifications;

  // === FILE & DOCUMENT ICONS ===
  static const IconData file = Icons.description_outlined;
  static const IconData fileFilled = Icons.description;
  static const IconData folder = Icons.folder_outlined;
  static const IconData folderFilled = Icons.folder;
  static const IconData download = Icons.download;
  static const IconData upload = Icons.upload;
  static const IconData share = Icons.share;
  static const IconData export = Icons.file_download;
  static const IconData import = Icons.file_upload;

  // === QUANTITY & COUNT ICONS ===
  static const IconData increase = Icons.add_circle_outlined;
  static const IconData increaseFilled = Icons.add_circle;
  static const IconData decrease = Icons.remove_circle_outlined;
  static const IconData decreaseFilled = Icons.remove_circle;
  static const IconData count = Icons.format_list_numbered;
  static const IconData quantity = Icons.inventory;

  // === ANALYTICS & REPORTS ICONS ===
  static const IconData analytics = Icons.analytics_outlined;
  static const IconData analyticsFilled = Icons.analytics;
  static const IconData chart = Icons.bar_chart;
  static const IconData trends = Icons.trending_up;
  static const IconData report = Icons.assessment_outlined;
  static const IconData reportFilled = Icons.assessment;

  // === Get icon by role ===
  static IconData getRoleIcon(String role) {
    switch (role.toUpperCase()) {
      case 'OWNER':
        return owner;
      case 'ADMIN':
        return admin;
      case 'STAFF':
        return staff;
      case 'CASHIER':
        return cashier;
      default:
        return user;
    }
  }

  /// Get filled role icon
  static IconData getRoleIconFilled(String role) {
    switch (role.toUpperCase()) {
      case 'OWNER':
        return ownerFilled;
      case 'ADMIN':
        return adminFilled;
      case 'STAFF':
        return staffFilled;
      case 'CASHIER':
        return cashierFilled;
      default:
        return userFilled;
    }
  }

  /// Get transaction type icon
  static IconData getTransactionTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'SALE':
        return sale;
      case 'TRANSFER':
        return transfer;
      case 'RETURN':
        return error; // Using error icon for returns
      default:
        return transaction;
    }
  }

  /// Get transaction type filled icon
  static IconData getTransactionTypeIconFilled(String type) {
    switch (type.toUpperCase()) {
      case 'SALE':
        return saleFilled;
      case 'TRANSFER':
        return transfer; // Transfer doesn't have filled variant
      case 'RETURN':
        return errorFilled;
      default:
        return transactionFilled;
    }
  }

  /// Get status icon
  static IconData getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
      case 'SUCCESS':
      case 'OK':
        return success;
      case 'PENDING':
      case 'PROCESSING':
        return pending;
      case 'FAILED':
      case 'ERROR':
      case 'BROKEN':
        return error;
      case 'WARNING':
      case 'MISSING':
        return warning;
      case 'INFO':
        return info;
      default:
        return info;
    }
  }

  /// Get status filled icon
  static IconData getStatusIconFilled(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
      case 'SUCCESS':
      case 'OK':
        return successFilled;
      case 'PENDING':
      case 'PROCESSING':
        return pending; // Pending doesn't have filled variant
      case 'FAILED':
      case 'ERROR':
      case 'BROKEN':
        return errorFilled;
      case 'WARNING':
      case 'MISSING':
        return warningFilled;
      case 'INFO':
        return infoFilled;
      default:
        return infoFilled;
    }
  }

  /// Get connectivity icon
  static IconData getConnectivityIcon(bool isConnected) {
    return isConnected ? online : offline;
  }

  /// Get printer status icon
  static IconData getPrinterStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'connected':
        return bluetoothConnected;
      case 'connecting':
        return bluetooth;
      case 'disconnected':
      default:
        return bluetoothDisabled;
    }
  }
}

/// Icon button styles for different contexts
class WMSIconStyles {
  static const double small = 16;
  static const double medium = 24;
  static const double large = 32;
  static const double extraLarge = 48;

  /// Get icon size based on context
  static double getSize(String context) {
    switch (context.toLowerCase()) {
      case 'small':
      case 'list':
        return small;
      case 'medium':
      case 'button':
      case 'app_bar':
        return medium;
      case 'large':
      case 'card':
        return large;
      case 'hero':
      case 'feature':
        return extraLarge;
      default:
        return medium;
    }
  }
}

/// Extension for easy icon access
extension IconExtension on IconData {
  /// Create an Icon widget with consistent styling
  Widget icon({
    double? size,
    Color? color,
    String? semanticLabel,
  }) {
    return Icon(
      this,
      size: size ?? WMSIconStyles.medium,
      color: color,
      semanticLabel: semanticLabel,
    );
  }

  /// Create an IconButton with consistent styling
  Widget button({
    required VoidCallback? onPressed,
    double? size,
    Color? color,
    String? tooltip,
    EdgeInsets? padding,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        this,
        size: size ?? WMSIconStyles.medium,
        color: color,
      ),
      tooltip: tooltip,
      padding: padding ?? const EdgeInsets.all(8),
    );
  }
}