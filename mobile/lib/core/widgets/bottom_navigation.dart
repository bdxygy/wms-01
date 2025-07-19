import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../generated/app_localizations.dart';
import '../auth/auth_provider.dart';
import '../models/user.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    final tabs = _getTabsForRole(user.role, l10n);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex.clamp(0, tabs.length - 1),
      onTap: onTap,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 8,
      items: tabs,
    );
  }

  List<BottomNavigationBarItem> _getTabsForRole(UserRole role, AppLocalizations l10n) {
    switch (role) {
      case UserRole.owner:
        return [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
            tooltip: l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.store),
            label: l10n.stores,
            tooltip: l10n.storeManagement,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: l10n.users,
            tooltip: l10n.userManagement,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory),
            label: l10n.products,
            tooltip: l10n.productManagement,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.check_circle),
            label: l10n.checks,
            tooltip: l10n.productChecks,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long),
            label: l10n.transactions,
            tooltip: l10n.transactionManagement,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.category),
            label: l10n.categories,
            tooltip: l10n.categoryManagement,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
            tooltip: l10n.settings,
          ),
        ];

      case UserRole.admin:
        return [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
            tooltip: l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory),
            label: l10n.products,
            tooltip: l10n.productManagement,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.check_circle),
            label: l10n.checks,
            tooltip: l10n.productChecks,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long),
            label: l10n.transactions,
            tooltip: l10n.transactionManagement,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: l10n.users,
            tooltip: l10n.userManagement,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.category),
            label: l10n.categories,
            tooltip: l10n.categoryManagement,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
            tooltip: l10n.settings,
          ),
        ];

      case UserRole.staff:
        return [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
            tooltip: l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory),
            label: l10n.products,
            tooltip: l10n.productSearch,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.check_circle),
            label: l10n.checks,
            tooltip: l10n.productChecks,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
            tooltip: l10n.settings,
          ),
        ];

      case UserRole.cashier:
        return [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
            tooltip: l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long),
            label: l10n.transactions,
            tooltip: l10n.saleTransactions,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            label: l10n.products,
            tooltip: l10n.productSearch,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
            tooltip: l10n.settings,
          ),
        ];
    }
  }

  static int getMaxTabsForRole(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return 8;
      case UserRole.admin:
        return 7;
      case UserRole.staff:
        return 4;
      case UserRole.cashier:
        return 4;
    }
  }

  static List<String> getRouteNamesForRole(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return ['dashboard', 'stores', 'users', 'products', 'checks', 'transactions', 'categories', 'settings'];
      case UserRole.admin:
        return ['dashboard', 'products', 'checks', 'transactions', 'users', 'categories', 'settings'];
      case UserRole.staff:
        return ['dashboard', 'products', 'checks', 'settings'];
      case UserRole.cashier:
        return ['dashboard', 'transactions', 'products', 'settings'];
    }
  }
}