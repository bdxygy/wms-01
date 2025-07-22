import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
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

        // Limited Quick Actions - Staff Tools
        DashboardQuickActions(
          role: 'STAFF',
          title: l10n.quickNavigationReadOnlyAccess,
          actions: [
            // Staff Tools
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

        // Product Check Interface
        _buildProductCheckInterface(),

        const SizedBox(height: 24),

        // Recent Product Checks
        RecentActivityCard(
          title: l10n.recentProductChecks,
          activityType: 'product-checks',
          onViewAll: () => _navigateToAllChecks(),
          onRefresh: () => _refreshData(),
        ),
      ],
    );
  }

  Widget _buildStoreOverviewHeader(String storeName) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.tertiaryContainer,
            Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
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
                color: Theme.of(context).colorScheme.tertiary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.visibility_rounded,
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
                    l10n.storeOverviewReadOnly,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onTertiaryContainer
                              .withValues(alpha: 0.7),
                        ),
                  ),
                  Text(
                    storeName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onTertiaryContainer,
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
                    Icons.remove_red_eye_rounded,
                    size: 14,
                    color: Colors.green[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.viewMode,
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
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.storeInformation,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          DashboardMetricCard(
            title: l10n.totalProducts,
            value: '0', // TODO: Get actual data
            icon: Icons.inventory,
            color: Colors.blue,
            trend: '0',
          ),
          const SizedBox(height: 12),
          DashboardMetricCard(
            title: l10n.categories,
            value: '0', // TODO: Get actual data
            icon: Icons.category,
            color: Colors.purple,
            trend: '0',
          ),
          const SizedBox(height: 12),
          DashboardMetricCard(
            title: l10n.myChecksToday,
            value: '0', // TODO: Get actual data
            icon: Icons.fact_check,
            color: Colors.green,
            trend: '+0',
          ),
          const SizedBox(height: 12),
          DashboardMetricCard(
            title: l10n.pendingChecks,
            value: '0', // TODO: Get actual data
            icon: Icons.pending,
            color: Colors.orange,
            trend: '0',
          ),
        ],
      ),
    );
  }

  Widget _buildProductCheckInterface() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.productChecking,
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
                      l10n.quickProductCheck,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.useButtonsToCheck,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildCheckStatusButton(
                        l10n.checkStatusPending,
                        Icons.pending,
                        Colors.orange,
                        l10n.itemsCount(0),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCheckStatusButton(
                        l10n.checkStatusOk,
                        Icons.check_circle,
                        Colors.green,
                        l10n.itemsCount(0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildCheckStatusButton(
                        l10n.checkStatusMissing,
                        Icons.error,
                        Colors.red,
                        l10n.itemsCount(0),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCheckStatusButton(
                        l10n.checkStatusBroken,
                        Icons.broken_image,
                        Colors.grey,
                        l10n.itemsCount(0),
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

  Widget _buildCheckStatusButton(
      String status, IconData icon, Color color, String count) {
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
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
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
