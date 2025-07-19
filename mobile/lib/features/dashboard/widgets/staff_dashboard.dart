import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/store_context_provider.dart';
import '../../../core/routing/app_router.dart';
import 'dashboard_metric_card.dart';
import 'dashboard_quick_actions.dart';
import 'recent_activity_card.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreContextProvider>();
    final currentStore = storeProvider.selectedStore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Store Overview Header
        _buildStoreOverviewHeader(currentStore?.name ?? 'Unknown Store'),
        
        const SizedBox(height: 24),
        
        // Read-only Metrics
        _buildReadOnlyMetrics(),
        
        const SizedBox(height: 24),
        
        // Limited Quick Actions - Read-Only List Navigation
        DashboardQuickActions(
          role: 'STAFF',
          title: 'Quick Navigation (Read-Only Access)',
          actions: [
            // Read-Only List Page Navigation (STAFF can view products only)
            QuickAction(
              icon: Icons.inventory_2,
              title: 'Products',
              subtitle: 'View products (read-only)',
              color: Colors.blue,
              onTap: () => _navigateToProductsList(),
            ),
            
            // Staff Tools
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
            QuickAction(
              icon: Icons.search,
              title: 'Find Product',
              subtitle: 'Search products',
              color: Colors.green,
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
        
        // Product Check Interface
        _buildProductCheckInterface(),
        
        const SizedBox(height: 24),
        
        // Recent Product Checks
        RecentActivityCard(
          title: 'Recent Product Checks',
          activityType: 'product-checks',
          onViewAll: () => _navigateToAllChecks(),
          onRefresh: () => _refreshData(),
        ),
      ],
    );
  }

  Widget _buildStoreOverviewHeader(String storeName) {
    return Card(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.visibility,
                color: Theme.of(context).colorScheme.onTertiary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Store Overview (Read-Only)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onTertiaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    storeName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
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
                    Icons.remove_red_eye,
                    size: 14,
                    color: Colors.green[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'View Mode',
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

  Widget _buildReadOnlyMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Store Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DashboardMetricCard(
                title: 'Total Products',
                value: '0', // TODO: Get actual data
                icon: Icons.inventory,
                color: Colors.blue,
                trend: '0',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardMetricCard(
                title: 'Categories',
                value: '0', // TODO: Get actual data
                icon: Icons.category,
                color: Colors.purple,
                trend: '0',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DashboardMetricCard(
                title: 'My Checks Today',
                value: '0', // TODO: Get actual data
                icon: Icons.fact_check,
                color: Colors.green,
                trend: '+0',
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
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductCheckInterface() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Checking',
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
                      Icons.fact_check,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Quick Product Check',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Use the buttons below to quickly check product status:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildCheckStatusButton(
                        'PENDING',
                        Icons.pending,
                        Colors.orange,
                        '0 items',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCheckStatusButton(
                        'OK',
                        Icons.check_circle,
                        Colors.green,
                        '0 items',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildCheckStatusButton(
                        'MISSING',
                        Icons.error,
                        Colors.red,
                        '0 items',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCheckStatusButton(
                        'BROKEN',
                        Icons.broken_image,
                        Colors.grey,
                        '0 items',
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

  Widget _buildCheckStatusButton(String status, IconData icon, Color color, String count) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToCheckStatus(status),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                status,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                count,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _refreshData() {
    // TODO: Implement data refresh
    setState(() {
      // Trigger rebuild for refresh indicator
    });
  }

  // Read-Only List Page Navigation (STAFF can view products only)
  void _navigateToProductsList() {
    // TODO: Navigate to products list (read-only with search)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Products List (read-only) page coming soon!')),
    );
  }

  void _navigateToProductSearch() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product Search feature coming soon!')),
    );
  }

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

  void _navigateToInventory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inventory feature coming soon!')),
    );
  }

  void _navigateToAllChecks() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All Checks feature coming soon!')),
    );
  }

  void _navigateToCheckStatus(String status) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$status products feature coming soon!')),
    );
  }

  void _navigateToSettings() {
    AppRouter.goToSettings(context);
  }
}