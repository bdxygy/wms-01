import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
          title: l10n.quickNavigationTransactionFocus,
          actions: [
            // Point-of-Sale Actions
            QuickAction(
              icon: Icons.add_shopping_cart,
              title: l10n.newSale,
              subtitle: l10n.createSale,
              color: Colors.green,
              onTap: () => _navigateToNewSale(),
            ),
            QuickAction(
              icon: Icons.search,
              title: l10n.searchProducts,
              subtitle: l10n.quickProductLookup,
              color: Colors.orange,
              onTap: () => _navigateToProductSearch(),
            ),
            QuickAction(
              icon: Icons.settings,
              title: l10n.settings,
              subtitle: l10n.appSettings,
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
          title: l10n.myRecentTransactions,
          activityType: 'transactions',
          onViewAll: () => _navigateToMySales(),
          onRefresh: () => _refreshData(),
        ),
      ],
    );
  }

  Widget _buildTransactionFocusHeader(String storeName) {
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.point_of_sale_rounded,
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
                    l10n.pointOfSale,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
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
                    Icons.sell_rounded,
                    size: 14,
                    color: Colors.green[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.salesMode,
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
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.todaysSalesSummary,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          DashboardMetricCard(
            title: l10n.todaySales,
            value: '0', // TODO: Get actual data
            icon: Icons.attach_money,
            color: Colors.green,
            trend: '+0',
            subtitle: l10n.totalRevenue,
          ),
          const SizedBox(height: 12),
          DashboardMetricCard(
            title: l10n.transactions,
            value: '0', // TODO: Get actual data
            icon: Icons.receipt,
            color: Colors.blue,
            trend: '+0',
            subtitle: l10n.numberOfSales,
          ),
          const SizedBox(height: 12),
          DashboardMetricCard(
            title: l10n.averageSale,
            value: '0', // TODO: Get actual data
            icon: Icons.trending_up,
            color: Colors.orange,
            trend: '+0',
            subtitle: l10n.averageTransaction,
          ),
          const SizedBox(height: 12),
          DashboardMetricCard(
            title: l10n.itemsSold,
            value: '0', // TODO: Get actual data
            icon: Icons.shopping_bag,
            color: Colors.purple,
            trend: '+0',
            subtitle: l10n.totalItems,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSaleInterface() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.newSale,
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
                      l10n.fastSaleOptions,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.selectPreferredMethod,
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
                    label: Text(l10n.createNewSale),
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
                        label: Text(l10n.scanAndSell),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToProductSearch(),
                        icon: const Icon(Icons.search),
                        label: Text(l10n.search),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                const Divider(),
                
                const SizedBox(height: 16),
                
                // Sale Shortcuts
                Text(
                  l10n.quickActions,
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
                      l10n.lastSale,
                      Icons.history,
                      () => _viewLastSale(),
                    ),
                    _buildQuickActionChip(
                      l10n.reprintReceipt,
                      Icons.print,
                      () => _reprintLastReceipt(),
                    ),
                    _buildQuickActionChip(
                      l10n.dailyReport,
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

  void _navigateToNewSale() {
    AppRouter.goToCreateTransaction(context);
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