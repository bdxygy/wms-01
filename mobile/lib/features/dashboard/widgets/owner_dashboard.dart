import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../generated/app_localizations.dart';

import '../../../core/providers/store_context_provider.dart';
import '../../../core/models/store.dart';
import '../../../core/routing/app_router.dart';
import 'dashboard_metric_card.dart';
import 'dashboard_quick_actions.dart';
import 'recent_activity_card.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  Store? _selectedStore;
  bool _isLoading = true;
  List<Store> _stores = [];

  @override
  void initState() {
    super.initState();
    // Defer the store loading to after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadStores();
      }
    });
  }

  Future<void> _loadStores() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('🏪 OwnerDashboard: Starting store loading...');
      final storeProvider = context.read<StoreContextProvider>();

      debugPrint('🏪 OwnerDashboard: Calling loadAvailableStores...');
      await storeProvider.loadAvailableStores().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Store loading timeout');
        },
      );

      debugPrint(
          '🏪 OwnerDashboard: Store loading completed, found ${storeProvider.availableStores.length} stores');

      if (mounted) {
        setState(() {
          _stores = storeProvider.availableStores;
          _selectedStore = _stores.isNotEmpty ? _stores.first : null;
          _isLoading = false;
        });
        debugPrint('🏪 OwnerDashboard: State updated successfully');
      }
    } catch (e) {
      debugPrint('❌ OwnerDashboard: Store loading failed: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show error to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load stores: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Store Switcher Panel
        _buildStoreSwitcherPanel(),

        const SizedBox(height: 24),

        // Overview Metrics
        _buildOverviewMetrics(),

        const SizedBox(height: 24),

        // Comprehensive Quick Actions (List Page Navigation)
        DashboardQuickActions(
          role: 'OWNER',
          title: l10n.quickNavigationFullAccess,
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

            // Product Tools
            QuickAction(
              icon: Icons.search,
              title: l10n.searchProducts,
              subtitle: l10n.quickProductLookup,
              color: Colors.orange,
              onTap: () => _navigateToProductSearch(),
            ),
            QuickAction(
              icon: Icons.fact_check,
              title: l10n.productCheck,
              subtitle: l10n.qualityVerification,
              color: Colors.orange,
              onTap: () => _navigateToProductCheck(),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Multiple Activity Feeds (All Role Features)
        _buildComprehensiveActivitySections(),
      ],
    );
  }

  Widget _buildStoreSwitcherPanel() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.dashboard_rounded,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.multiStoreOverview,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                      ),
                      Text(
                        l10n.viewStores,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withValues(alpha: 0.7),
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => _navigateToStoreManagement(),
                  icon: const Icon(Icons.settings_rounded),
                  tooltip: l10n.storeManagement,
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_stores.isEmpty)
              _buildNoStoresWidget()
            else
              _buildStoreSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildNoStoresWidget() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.store_outlined,
            size: 48,
            color: Theme.of(context)
                .colorScheme
                .onPrimaryContainer
                .withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noStoresCreated,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.createFirstStore,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer
                      .withValues(alpha: 0.8),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddStore(),
            icon: const Icon(Icons.add),
            label: Text(l10n.createStore),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreSelector() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectStoreToView(_stores.length),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onPrimaryContainer
                    .withValues(alpha: 0.8),
              ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButton<Store>(
            value: _selectedStore,
            isExpanded: true,
            underline: const SizedBox(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            items: _stores.map((store) {
              return DropdownMenuItem<Store>(
                value: store,
                child: Row(
                  children: [
                    Icon(
                      Icons.store,
                      size: 20,
                      color: store.isActive ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            store.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          if (store.address.isNotEmpty)
                            Text(
                              store.address,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: store.isActive
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        store.isActive ? l10n.active : l10n.inactive,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: store.isActive
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (Store? newStore) {
              setState(() {
                _selectedStore = newStore;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewMetrics() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedStore != null
                ? l10n.comprehensiveAnalytics(_selectedStore!.name)
                : l10n.businessIntelligenceDashboard,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),

          // Store Management Metrics
          Text(
            l10n.storeManagement,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.purple,
                ),
          ),
          const SizedBox(height: 12),
          DashboardMetricCard(
            title: l10n.totalStores,
            value: '${_stores.length}',
            icon: Icons.store,
            color: Colors.purple,
            trend: '+0', // TODO: Calculate trend
            onTap: () => _navigateToStoreManagement(),
          ),
          const SizedBox(height: 12),
          DashboardMetricCard(
            title: l10n.activeUsers,
            value: '0', // TODO: Get actual data
            icon: Icons.people,
            color: Colors.purple,
            trend: '+0',
            onTap: () => _navigateToManageUsers(),
          ),

          const SizedBox(height: 20),

          // Sales & Transaction Metrics (Cashier Features)
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
            icon: Icons.attach_money,
            color: Colors.green,
            trend: '+0',
            subtitle: l10n.totalRevenue,
            onTap: () => _navigateToSalesReport(),
          ),
          const SizedBox(height: 12),
          DashboardMetricCard(
            title: l10n.transactions,
            value: '0', // TODO: Get actual data
            icon: Icons.receipt,
            color: Colors.green,
            trend: '+0',
            subtitle: l10n.viewTransactions,
            onTap: () => _navigateToTransactions(),
          ),
          const SizedBox(height: 12),
          DashboardMetricCard(
            title: l10n.averageSale,
            value: '0', // TODO: Get actual data
            icon: Icons.trending_up,
            color: Colors.green,
            trend: '+0',
            subtitle: l10n.averageTransaction,
          ),
          const SizedBox(height: 12),
          DashboardMetricCard(
            title: l10n.itemsSold,
            value: '0', // TODO: Get actual data
            icon: Icons.shopping_bag,
            color: Colors.green,
            trend: '+0',
            subtitle: l10n.totalItems,
          ),

          const SizedBox(height: 20),

          // Inventory & Product Metrics (Admin Features)
          Text(
            l10n.inventoryManagement,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
          ),
          const SizedBox(height: 12),
          DashboardMetricCard(
            title: l10n.totalProducts,
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
            color: Colors.blue,
            trend: '+0',
            onTap: () => _navigateToCategories(),
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
          const SizedBox(height: 12),
          DashboardMetricCard(
            title: l10n.inStock,
            value: '0', // TODO: Get actual data
            icon: Icons.check_circle,
            color: Colors.blue,
            trend: '+0',
          ),

          const SizedBox(height: 20),

          // Staff Operations Metrics (Staff Features)
          Text(
            l10n.operationsQualityControl,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
          ),
          const SizedBox(height: 12),
          DashboardMetricCard(
            title: l10n.productChecks,
            value: '0', // TODO: Get actual data
            icon: Icons.fact_check,
            color: Colors.orange,
            trend: '+0',
            subtitle: l10n.totalChecksToday,
            onTap: () => _navigateToAllChecks(),
          ),
          const SizedBox(height: 12),
          DashboardMetricCard(
            title: l10n.pendingChecks,
            value: '0', // TODO: Get actual data
            icon: Icons.pending,
            color: Colors.orange,
            trend: '0',
            subtitle: l10n.requiresAttention,
            onTap: () => _navigateToPendingChecks(),
          ),
        ],
      ),
    );
  }

  Widget _buildComprehensiveActivitySections() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recent Transactions (Cashier Feature)
        RecentActivityCard(
          title: l10n.recentTransactionsAllStores,
          activityType: 'transactions',
          onViewAll: () => _navigateToTransactions(),
          onRefresh: () => _refreshAllData(),
        ),

        const SizedBox(height: 24),

        // Recent Product Checks (Staff Feature)
        RecentActivityCard(
          title: l10n.recentProductChecks,
          activityType: 'product-checks',
          onViewAll: () => _navigateToAllChecks(),
          onRefresh: () => _refreshAllData(),
        ),

        const SizedBox(height: 24),

        // Store Activity Overview (Admin Feature)
        RecentActivityCard(
          title: l10n.storeOperationsActivity,
          activityType: 'store-specific',
          onViewAll: () => _navigateToStoreActivity(),
          onRefresh: () => _refreshAllData(),
        ),

        const SizedBox(height: 24),

        // Multi-Store Overview (Owner Feature)
        RecentActivityCard(
          title: l10n.multiStoreSummary,
          activityType: 'multi-store',
          onViewAll: () => _navigateToAllActivity(),
          onRefresh: () => _refreshAllData(),
        ),
      ],
    );
  }

  Future<void> _refreshAllData() async {
    // TODO: Implement comprehensive data refresh for all sections
    await _loadStores();
  }

  // List Page Navigation (OWNER has full access to all lists)

  void _navigateToCreateSale() {
    AppRouter.goToCreateTransaction(context);
  }

  void _navigateToReports() {
    // TODO: Navigate to reports screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reports feature coming soon!')),
    );
  }

  void _navigateToSettings() {
    AppRouter.goToSettings(context);
  }

  void _navigateToAllActivity() {
    // TODO: Navigate to all activity screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All Activity feature coming soon!')),
    );
  }

  // Store Management Navigation
  void _navigateToStoreManagement() {
    // TODO: Navigate to store management screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Store Management feature coming soon!')),
    );
  }

  void _navigateToAddStore() {
    // TODO: Navigate to add store screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Store feature coming soon!')),
    );
  }

  void _navigateToManageUsers() {
    // TODO: Navigate to user management screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User Management feature coming soon!')),
    );
  }

  // Additional navigation methods for comprehensive features

  // Admin Features

  void _navigateToInventory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inventory feature coming soon!')),
    );
  }

  void _navigateToCategories() {
    context.go('/categories');
  }

  void _navigateToLowStock() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Low Stock feature coming soon!')),
    );
  }

  // Cashier Features

  void _navigateToTransactions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All Transactions feature coming soon!')),
    );
  }

  void _navigateToSalesReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sales Report feature coming soon!')),
    );
  }

  // Product Search Features
  void _navigateToProductSearch() {
    AppRouter.goToProductSearch(context);
  }

  void _navigateToProductCheck() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product Check feature coming soon!')),
    );
  }

  void _navigateToAllChecks() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All Product Checks feature coming soon!')),
    );
  }

  void _navigateToPendingChecks() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pending Checks feature coming soon!')),
    );
  }

  // Additional Activity Navigation
  void _navigateToStoreActivity() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Store Activity feature coming soon!')),
    );
  }
}
