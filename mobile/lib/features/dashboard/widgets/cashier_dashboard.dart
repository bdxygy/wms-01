import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/store_context_provider.dart';
import '../../../core/routing/app_router.dart';
import 'dashboard_metric_card.dart';
import 'dashboard_quick_actions.dart';
import 'recent_activity_card.dart';

class CashierDashboard extends StatefulWidget {
  const CashierDashboard({super.key});

  @override
  State<CashierDashboard> createState() => _CashierDashboardState();
}

class _CashierDashboardState extends State<CashierDashboard> {

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreContextProvider>();
    final currentStore = storeProvider.selectedStore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Transaction Focus Header
        _buildTransactionFocusHeader(currentStore?.name ?? 'Unknown Store'),
        
        const SizedBox(height: 24),
        
        // Daily Sales Summary
        _buildDailySalesSummary(),
        
        const SizedBox(height: 24),
        
        // Quick Sale Actions - Transaction-Focused Navigation
        DashboardQuickActions(
          role: 'CASHIER',
          title: 'Quick Navigation (Transaction Focus)',
          actions: [
            // Limited List Page Navigation (CASHIER can view products, transactions only)
            QuickAction(
              icon: Icons.inventory_2,
              title: 'Products',
              subtitle: 'View products for sale',
              color: Colors.blue,
              onTap: () => _navigateToProductsList(),
            ),
            QuickAction(
              icon: Icons.receipt_long,
              title: 'Transactions',
              subtitle: 'View my transactions',
              color: Colors.green,
              onTap: () => _navigateToTransactionsList(),
            ),
            
            // Point-of-Sale Actions
            QuickAction(
              icon: Icons.add_shopping_cart,
              title: 'New Sale',
              subtitle: 'Create sale transaction',
              color: Colors.green,
              onTap: () => _navigateToNewSale(),
            ),
            QuickAction(
              icon: Icons.search,
              title: 'Search Products',
              subtitle: 'Barcode, IMEI & text search',
              color: Colors.orange,
              onTap: () => _navigateToProductSearch(),
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
        
        // Quick Sale Interface
        _buildQuickSaleInterface(),
        
        const SizedBox(height: 24),
        
        // Recent Transactions
        RecentActivityCard(
          title: 'My Recent Transactions',
          activityType: 'transactions',
          onViewAll: () => _navigateToMySales(),
          onRefresh: () => _refreshData(),
        ),
      ],
    );
  }

  Widget _buildTransactionFocusHeader(String storeName) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.point_of_sale,
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
                    'Point of Sale',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    storeName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sell,
                    size: 14,
                    color: Colors.green[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Sales Mode',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySalesSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Sales Summary',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DashboardMetricCard(
                title: 'Sales Today',
                value: '\$0', // TODO: Get actual data
                icon: Icons.attach_money,
                color: Colors.green,
                trend: '+0',
                subtitle: 'Total revenue',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardMetricCard(
                title: 'Transactions',
                value: '0', // TODO: Get actual data
                icon: Icons.receipt,
                color: Colors.blue,
                trend: '+0',
                subtitle: 'Number of sales',
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
                color: Colors.orange,
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
                color: Colors.purple,
                trend: '+0',
                subtitle: 'Total items',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickSaleInterface() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Sale',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.flash_on,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Fast Sale Options',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Select your preferred method to create a sale:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Quick Sale Buttons
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToNewSale(),
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Create New Sale'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToScanAndSell(),
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Scan & Sell'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToProductSearch(),
                        icon: const Icon(Icons.search),
                        label: const Text('Search'),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                const Divider(),
                
                const SizedBox(height: 16),
                
                // Sale Shortcuts
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildQuickActionChip(
                      'Last Sale',
                      Icons.history,
                      () => _viewLastSale(),
                    ),
                    _buildQuickActionChip(
                      'Reprint Receipt',
                      Icons.print,
                      () => _reprintLastReceipt(),
                    ),
                    _buildQuickActionChip(
                      'Daily Report',
                      Icons.analytics,
                      () => _viewDailyReport(),
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

  Widget _buildQuickActionChip(String label, IconData icon, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(
        icon,
        size: 18,
        color: Theme.of(context).colorScheme.primary,
      ),
      label: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      onPressed: onTap,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
      side: BorderSide(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
      ),
    );
  }

  void _refreshData() {
    // TODO: Implement data refresh
    setState(() {
      // Trigger rebuild for refresh indicator
    });
  }

  // Limited List Page Navigation (CASHIER can view products and their own transactions)
  void _navigateToProductsList() {
    // TODO: Navigate to products list (view-only for sales)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Products List (for sales) page coming soon!')),
    );
  }

  void _navigateToTransactionsList() {
    // TODO: Navigate to transactions list (cashier's own transactions)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('My Transactions List page coming soon!')),
    );
  }

  void _navigateToNewSale() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New Sale feature coming soon!')),
    );
  }

  void _navigateToScanAndSell() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scan & Sell feature coming soon!')),
    );
  }

  void _navigateToProductSearch() {
    AppRouter.goToProductSearch(context);
  }

  void _navigateToMySales() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('My Sales feature coming soon!')),
    );
  }

  void _viewLastSale() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Last Sale feature coming soon!')),
    );
  }

  void _reprintLastReceipt() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reprint Receipt feature coming soon!')),
    );
  }

  void _viewDailyReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Daily Report feature coming soon!')),
    );
  }

  void _navigateToSettings() {
    AppRouter.goToSettings(context);
  }
}