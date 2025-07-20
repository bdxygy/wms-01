import 'package:flutter/material.dart';
import '../../generated/app_localizations.dart';

class WMSBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String userRole;

  const WMSBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 8,
      items: getNavigationItemsForRole(context, userRole),
    );
  }

  static List<BottomNavigationBarItem> getNavigationItemsForRole(BuildContext context, String role) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (role.toUpperCase()) {
      case 'OWNER':
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
            icon: const Icon(Icons.people),
            label: l10n.users,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ];
      case 'ADMIN':
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
      case 'STAFF':
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
            icon: const Icon(Icons.checklist),
            label: l10n.checks,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ];
      case 'CASHIER':
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
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ];
      default:
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
  }

  static List<String> getRouteNamesForRole(String role) {
    switch (role.toUpperCase()) {
      case 'OWNER':
        return [
          'dashboard',
          'products',
          'transactions',
          'stores',
          'users',
          'settings',
        ];
      case 'ADMIN':
        return [
          'dashboard',
          'products',
          'transactions',
          'stores',
          'settings',
        ];
      case 'STAFF':
        return [
          'dashboard',
          'products',
          'checks',
          'settings',
        ];
      case 'CASHIER':
        return [
          'dashboard',
          'products',
          'transactions',
          'settings',
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
}