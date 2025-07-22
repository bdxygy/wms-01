import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../generated/app_localizations.dart';

import '../../../core/providers/store_context_provider.dart';
import '../../../core/routing/app_router.dart';
import 'dashboard_metric_card.dart';
import 'dashboard_quick_actions.dart';
import 'recent_activity_card.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final storeProvider = context.watch<StoreContextProvider>();
    final currentStore = storeProvider.selectedStore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Store Header
        _buildStoreHeader(currentStore?.name ?? 'Unknown Store'),
        
        const SizedBox(height: 24),
        
        // Store Metrics
        _buildStoreMetrics(),
        
        const SizedBox(height: 24),
        
        // Quick Actions - List Page Navigation
        DashboardQuickActions(
          role: 'ADMIN',
          title: l10n.quickNavigationAdminAccess,
          actions: [
            // Primary Business Actions
            QuickAction(
              icon: Icons.add_shopping_cart,
              title: l10n.newSale,
              subtitle: l10n.createSale,
              color: Colors.green,
              onTap: () => _navigateToCreateSale(),
            ),
            QuickAction(
              icon: Icons.category,
              title: l10n.categories,
              subtitle: l10n.viewCategories,
              color: Colors.blue,
              onTap: () => _navigateToCategories(),
            ),
            
            // Store Management
            QuickAction(
              icon: Icons.search,
              title: l10n.searchProducts,
              subtitle: l10n.quickProductLookup,
              color: Colors.orange,
              onTap: () => _navigateToProductSearch(),
            ),
            QuickAction(
              icon: Icons.people_outline,
              title: l10n.manageStaff,
              subtitle: l10n.staffManagement,
              color: Colors.orange,
              onTap: () => _navigateToManageStaff(),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Store Inventory Overview
        _buildInventoryOverview(),
        
        const SizedBox(height: 24),
        
        // Recent Transactions
        RecentActivityCard(
          title: l10n.recentTransactions,
          activityType: 'transactions',
          onViewAll: () => _navigateToTransactions(),
          onRefresh: () => _refreshData(),
        ),
      ],
    );
  }

  Widget _buildStoreHeader(String storeName) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.secondaryContainer,
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.business_rounded,
                color: Theme.of(context).colorScheme.onSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.storeManagement,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    storeName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              onPressed: () => _navigateToStoreDetails(),
              icon: const Icon(Icons.info_outline_rounded),
              tooltip: l10n.details,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreMetrics() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.storePerformance,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Store Management Metrics
          Text(
            l10n.inventoryManagement,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          DashboardMetricCard(
            title: l10n.products,
            value: '0', // TODO: Get actual data
            icon: Icons.inventory,
            color: Colors.blue,
            trend: '+0',
            onTap: () => _navigateToInventory(),
          ),
          const SizedBox(height: 12),
          DashboardMetricCard(
            title: l10n.categories,
            value: '0', // TODO: Get actual data
            icon: Icons.category,
            color: Colors.purple,
            trend: '+0',
            onTap: () => _navigateToCategories(),
          ),

          const SizedBox(height: 20),

          // Sales & Transaction Metrics
          Text(
            l10n.salesPerformance,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 12),
          DashboardMetricCard(
            title: l10n.todaySales,
            value: '0', // TODO: Get actual data
            icon: Icons.trending_up,
            color: Colors.green,
            trend: '+0',
            onTap: () => _navigateToSalesReport(),
          ),
          const SizedBox(height: 12),
          DashboardMetricCard(
            title: l10n.transactions,
            value: '0', // TODO: Get actual data
            icon: Icons.receipt,
            color: Colors.orange,
            trend: '+0',
            onTap: () => _navigateToTransactions(),
          ),
          const SizedBox(height: 12),
          DashboardMetricCard(
            title: l10n.lowStock,
            value: '0', // TODO: Get actual data
            icon: Icons.warning,
            color: Colors.red,
            trend: '0',
            onTap: () => _navigateToLowStock(),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryOverview() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.inventoryOverview,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _navigateToInventory(),
              child: Text(l10n.viewAll),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInventoryItem(
                        l10n.totalProducts,
                        '0',
                        Icons.inventory,
                        Colors.blue,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    Expanded(
                      child: _buildInventoryItem(
                        l10n.categories,
                        '0',
                        Icons.category,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInventoryItem(
                        l10n.inStock,
                        '0',
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    Expanded(
                      child: _buildInventoryItem(
                        l10n.lowStock,
                        '0',
                        Icons.warning,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _refreshData() {
    // TODO: Implement data refresh
    setState(() {
      // Trigger rebuild for refresh indicator
    });
  }

  // List Page Navigation (ADMIN access to products, categories, transactions)
  void _navigateToCategories() {
    context.go('/categories');
  }

  void _navigateToCreateSale() {
    AppRouter.goToCreateTransaction(context);
  }

  void _navigateToManageStaff() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Manage Staff feature coming soon!')),
    );
  }

  void _navigateToProductSearch() {
    AppRouter.goToProductSearch(context);
  }

  void _navigateToInventory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inventory feature coming soon!')),
    );
  }

  void _navigateToTransactions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transactions feature coming soon!')),
    );
  }

  void _navigateToStoreDetails() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Store Details feature coming soon!')),
    );
  }

  void _navigateToSalesReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sales Report feature coming soon!')),
    );
  }

  void _navigateToLowStock() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Low Stock feature coming soon!')),
    );
  }

  void _navigateToSettings() {
    AppRouter.goToSettings(context);
  }
}