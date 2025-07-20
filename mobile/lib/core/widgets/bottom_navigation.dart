import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../generated/app_localizations.dart';

class WMSBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const WMSBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: _getNavigationItems(context),
    );
  }

  static List<BottomNavigationBarItem> _getNavigationItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return [
      BottomNavigationBarItem(
        icon: const Icon(Icons.dashboard),
        label: l10n.dashboard,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.inventory_2),
        label: l10n.products,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.receipt),
        label: l10n.transactions,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.store),
        label: l10n.stores,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.settings),
        label: l10n.settings,
      ),
    ];
  }

  static List<String> getRouteNamesForRole(String role) {
    switch (role) {
      case 'OWNER':
        return [
          'owner_dashboard',
          'owner_products',
          'owner_transactions',
          'owner_stores',
          'owner_settings',
        ];
      case 'ADMIN':
        return [
          'admin_dashboard',
          'admin_products',
          'admin_transactions',
          'admin_stores',
          'admin_settings',
        ];
      case 'STAFF':
        return [
          'staff_dashboard',
          'staff_products',
          'staff_checks',
          'staff_settings',
        ];
      case 'CASHIER':
        return [
          'cashier_dashboard',
          'cashier_products',
          'cashier_transactions',
          'cashier_settings',
        ];
      default:
        return [
          'dashboard',
          'products',
          'transactions',
          'stores',
          'settings',
        ];
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('currentIndex', currentIndex));
  }
}

