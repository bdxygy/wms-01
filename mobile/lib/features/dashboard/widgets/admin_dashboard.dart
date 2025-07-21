import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          title: 'Quick Navigation (Admin Access)',
          actions: [
            // List Page Navigation (ADMIN can access products, categories, transactions)
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
              subtitle: 'Create sale transaction',
              color: Colors.green,
              onTap: () => _navigateToCreateSale(),
            ),
            QuickAction(
              icon: Icons.search,
              title: 'Search Products',
              subtitle: 'Barcode, IMEI & text search',
              color: Colors.orange,
              onTap: () => _navigateToProductSearch(),
            ),
            QuickAction(
              icon: Icons.people_outline,
              title: 'Manage Staff',
              subtitle: 'Staff management',
              color: Colors.orange,
              onTap: () => _navigateToManageStaff(),
            ),
            QuickAction(
              icon: Icons.settings,
              title: 'Settings',
              subtitle: 'App settings & store',
              color: Colors.grey,
              onTap: () => _navigateToSettings(),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Store Inventory Overview
        _buildInventoryOverview(),
        
        const SizedBox(height: 24),
        
        // Recent Transactions
        RecentActivityCard(
          title: 'Recent Transactions',
          activityType: 'transactions',
          onViewAll: () => _navigateToTransactions(),
          onRefresh: () => _refreshData(),
        ),
      ],
    );
  }

  Widget _buildStoreHeader(String storeName) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.business,
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
                    'Store Management',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
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
            TextButton.icon(
              onPressed: () => _navigateToStoreDetails(),
              icon: const Icon(Icons.info_outline),
              label: const Text('Details'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Store Performance',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DashboardMetricCard(
                title: 'Products',
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
                title: 'Today Sales',
                value: '0', // TODO: Get actual data
                icon: Icons.trending_up,
                color: Colors.green,
                trend: '+0',
                onTap: () => _navigateToSalesReport(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DashboardMetricCard(
                title: 'Transactions',
                value: '0', // TODO: Get actual data
                icon: Icons.receipt,
                color: Colors.orange,
                trend: '+0',
                onTap: () => _navigateToTransactions(),
              ),
            ),
            const SizedBox(width: 12),
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
          ],
        ),
      ],
    );
  }

  Widget _buildInventoryOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Inventory Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _navigateToInventory(),
              child: const Text('View All'),
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
                        'Total Products',
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
                        'Categories',
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
                        'In Stock',
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
                        'Low Stock',
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