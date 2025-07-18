import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/store_context_provider.dart';
import '../../../core/models/store.dart';
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
    _loadStores();
  }

  Future<void> _loadStores() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final storeProvider = context.read<StoreContextProvider>();
      await storeProvider.loadAvailableStores();

      if (mounted) {
        setState(() {
          _stores = storeProvider.availableStores;
          _selectedStore = _stores.isNotEmpty ? _stores.first : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          title: 'Quick Navigation (Full Access)',
          actions: [
            // List Page Navigation (OWNER has full access)
            QuickAction(
              icon: Icons.store,
              title: 'Stores',
              subtitle: 'View & manage stores',
              color: Colors.purple,
              onTap: () => _navigateToStoresList(),
            ),
            QuickAction(
              icon: Icons.people,
              title: 'Users',
              subtitle: 'View & manage users',
              color: Colors.purple,
              onTap: () => _navigateToUsersList(),
            ),
            QuickAction(
              icon: Icons.inventory_2,
              title: 'Products',
              subtitle: 'View & manage products',
              color: Colors.blue,
              onTap: () => _navigateToProductsList(),
            ),
            QuickAction(
              icon: Icons.category,
              title: 'Categories',
              subtitle: 'View & manage categories',
              color: Colors.blue,
              onTap: () => _navigateToCategoriesList(),
            ),
            QuickAction(
              icon: Icons.receipt_long,
              title: 'Transactions',
              subtitle: 'View & manage transactions',
              color: Colors.green,
              onTap: () => _navigateToTransactionsList(),
            ),
            
            // Quick Actions (Creation & Tools)
            QuickAction(
              icon: Icons.add_shopping_cart,
              title: 'New Sale',
              subtitle: 'Create quick sale',
              color: Colors.green,
              onTap: () => _navigateToCreateSale(),
            ),
            QuickAction(
              icon: Icons.qr_code_scanner,
              title: 'Scan Barcode',
              subtitle: 'Quick product lookup',
              color: Colors.orange,
              onTap: () => _navigateToScanner(),
            ),
            QuickAction(
              icon: Icons.fact_check,
              title: 'Product Check',
              subtitle: 'Quality verification',
              color: Colors.orange,
              onTap: () => _navigateToProductCheck(),
            ),
            
            // Analytics & Management
            QuickAction(
              icon: Icons.analytics,
              title: 'Reports',
              subtitle: 'Business analytics',
              color: Colors.purple,
              onTap: () => _navigateToReports(),
            ),
            QuickAction(
              icon: Icons.settings,
              title: 'Settings',
              subtitle: 'App configuration',
              color: Colors.grey,
              onTap: () => _navigateToSettings(),
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
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Multi-Store Overview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _navigateToStoreManagement(),
                  icon: const Icon(Icons.manage_accounts),
                  label: const Text('Manage'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
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
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.store_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No stores created yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first store to start managing inventory',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddStore(),
            icon: const Icon(Icons.add),
            label: const Text('Create Store'),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select store to view details (${_stores.length} total)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
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
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (store.address.isNotEmpty)
                            Text(
                              store.address,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: store.isActive 
                            ? Colors.green.withValues(alpha: 0.2) 
                            : Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        store.isActive ? 'Active' : 'Inactive',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: store.isActive ? Colors.green[700] : Colors.orange[700],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedStore != null 
              ? 'Comprehensive Analytics for ${_selectedStore!.name}'
              : 'Business Intelligence Dashboard',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Store Management Metrics
        Text(
          'Store Management',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.purple,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DashboardMetricCard(
                title: 'Total Stores',
                value: '${_stores.length}',
                icon: Icons.store,
                color: Colors.purple,
                trend: '+0', // TODO: Calculate trend
                onTap: () => _navigateToStoreManagement(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardMetricCard(
                title: 'Active Users',
                value: '0', // TODO: Get actual data
                icon: Icons.people,
                color: Colors.purple,
                trend: '+0',
                onTap: () => _navigateToManageUsers(),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Sales & Transaction Metrics (Cashier Features)
        Text(
          'Sales Performance',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DashboardMetricCard(
                title: 'Today Sales',
                value: '\$0', // TODO: Get actual data
                icon: Icons.attach_money,
                color: Colors.green,
                trend: '+0',
                subtitle: 'Total revenue',
                onTap: () => _navigateToSalesReport(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardMetricCard(
                title: 'Transactions',
                value: '0', // TODO: Get actual data
                icon: Icons.receipt,
                color: Colors.green,
                trend: '+0',
                subtitle: 'All transactions',
                onTap: () => _navigateToTransactions(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DashboardMetricCard(
                title: 'Avg. Sale',
                value: '\$0', // TODO: Get actual data
                icon: Icons.trending_up,
                color: Colors.green,
                trend: '+0',
                subtitle: 'Average transaction',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardMetricCard(
                title: 'Items Sold',
                value: '0', // TODO: Get actual data
                icon: Icons.shopping_bag,
                color: Colors.green,
                trend: '+0',
                subtitle: 'Total items',
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Inventory & Product Metrics (Admin Features)
        Text(
          'Inventory Management',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DashboardMetricCard(
                title: 'Total Products',
                value: '0', // TODO: Get actual data
                icon: Icons.inventory,
                color: Colors.blue,
                trend: '+0',
                onTap: () => _navigateToInventory(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardMetricCard(
                title: 'Categories',
                value: '0', // TODO: Get actual data
                icon: Icons.category,
                color: Colors.blue,
                trend: '+0',
                onTap: () => _navigateToCategories(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DashboardMetricCard(
                title: 'Low Stock',
                value: '0', // TODO: Get actual data
                icon: Icons.warning,
                color: Colors.red,
                trend: '0',
                onTap: () => _navigateToLowStock(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardMetricCard(
                title: 'In Stock',
                value: '0', // TODO: Get actual data
                icon: Icons.check_circle,
                color: Colors.blue,
                trend: '+0',
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Staff Operations Metrics (Staff Features)
        Text(
          'Operations & Quality Control',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DashboardMetricCard(
                title: 'Product Checks',
                value: '0', // TODO: Get actual data
                icon: Icons.fact_check,
                color: Colors.orange,
                trend: '+0',
                subtitle: 'Total checks today',
                onTap: () => _navigateToAllChecks(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardMetricCard(
                title: 'Pending Checks',
                value: '0', // TODO: Get actual data
                icon: Icons.pending,
                color: Colors.orange,
                trend: '0',
                subtitle: 'Requires attention',
                onTap: () => _navigateToPendingChecks(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComprehensiveActivitySections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recent Transactions (Cashier Feature)
        RecentActivityCard(
          title: 'Recent Transactions (All Stores)',
          activityType: 'transactions',
          onViewAll: () => _navigateToTransactions(),
          onRefresh: () => _refreshAllData(),
        ),
        
        const SizedBox(height: 24),
        
        // Recent Product Checks (Staff Feature)
        RecentActivityCard(
          title: 'Recent Product Checks',
          activityType: 'product-checks',
          onViewAll: () => _navigateToAllChecks(),
          onRefresh: () => _refreshAllData(),
        ),
        
        const SizedBox(height: 24),
        
        // Store Activity Overview (Admin Feature)
        RecentActivityCard(
          title: 'Store Operations Activity',
          activityType: 'store-specific',
          onViewAll: () => _navigateToStoreActivity(),
          onRefresh: () => _refreshAllData(),
        ),
        
        const SizedBox(height: 24),
        
        // Multi-Store Overview (Owner Feature)
        RecentActivityCard(
          title: 'Multi-Store Summary',
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
  void _navigateToStoresList() {
    // TODO: Navigate to stores list with search & create button
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Stores List page coming soon!')),
    );
  }

  void _navigateToUsersList() {
    // TODO: Navigate to users list with search & create button
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Users List page coming soon!')),
    );
  }

  void _navigateToProductsList() {
    // TODO: Navigate to products list with search & create button
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Products List page coming soon!')),
    );
  }

  void _navigateToCategoriesList() {
    // TODO: Navigate to categories list with search & create button
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Categories List page coming soon!')),
    );
  }

  void _navigateToTransactionsList() {
    // TODO: Navigate to transactions list with search functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transactions List page coming soon!')),
    );
  }

  void _navigateToCreateSale() {
    // TODO: Navigate to create sale screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create Sale feature coming soon!')),
    );
  }

  void _navigateToReports() {
    // TODO: Navigate to reports screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reports feature coming soon!')),
    );
  }

  void _navigateToSettings() {
    // TODO: Navigate to settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings feature coming soon!')),
    );
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
  void _navigateToAddProduct() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Product feature coming soon!')),
    );
  }

  void _navigateToCreateTransaction() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create Transaction feature coming soon!')),
    );
  }

  void _navigateToInventory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inventory feature coming soon!')),
    );
  }

  void _navigateToCategories() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Categories feature coming soon!')),
    );
  }

  void _navigateToLowStock() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Low Stock feature coming soon!')),
    );
  }

  // Cashier Features
  void _navigateToQuickSale() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quick Sale feature coming soon!')),
    );
  }

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

  // Staff Features
  void _navigateToScanner() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scanner feature coming soon!')),
    );
  }

  void _navigateToProductCheck() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product Check feature coming soon!')),
    );
  }

  void _navigateToProductSearch() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product Search feature coming soon!')),
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