import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/providers/store_context_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final storeProvider = context.watch<StoreContextProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('WMS Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(user?.name ?? 'User', user?.role.toString() ?? 'UNKNOWN'),
            
            const SizedBox(height: 24),
            
            // Store Context Section (for non-owner users)
            if (!authProvider.isOwner && storeProvider.selectedStore != null)
              _buildStoreContextSection(storeProvider.selectedStore?.name ?? 'Unknown Store'),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            _buildQuickActions(authProvider),
            
            const SizedBox(height: 24),
            
            // Role-specific Dashboard Content
            _buildRoleSpecificContent(authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(String userName, String role) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                size: 30,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, $userName!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRoleColor(role).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      role,
                      style: TextStyle(
                        color: _getRoleColor(role),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
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

  Widget _buildStoreContextSection(String storeName) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.store,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Store',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    storeName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _handleChangeStore(),
              child: Text('Change'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            if (authProvider.canCreateProducts)
              _buildActionCard(
                icon: Icons.add_box,
                title: 'Add Product',
                subtitle: 'Create new product',
                onTap: () => _navigateToCreateProduct(),
              ),
            if (authProvider.canCreateTransactions)
              _buildActionCard(
                icon: Icons.point_of_sale,
                title: 'New Sale',
                subtitle: 'Create transaction',
                onTap: () => _navigateToCreateTransaction(),
              ),
            _buildActionCard(
              icon: Icons.qr_code_scanner,
              title: 'Scan Barcode',
              subtitle: 'Scan product',
              onTap: () => _navigateToScanner(),
            ),
            _buildActionCard(
              icon: Icons.search,
              title: 'Search Products',
              subtitle: 'Find products',
              onTap: () => _navigateToProducts(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSpecificContent(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'No recent activity',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Your recent activities will appear here',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toUpperCase()) {
      case 'OWNER':
        return Colors.purple;
      case 'ADMIN':
        return Colors.blue;
      case 'STAFF':
        return Colors.green;
      case 'CASHIER':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _navigateToCreateProduct() {
    // TODO: Navigate to create product screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create Product feature coming soon!')),
    );
  }

  void _navigateToCreateTransaction() {
    // TODO: Navigate to create transaction screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create Transaction feature coming soon!')),
    );
  }

  void _navigateToScanner() {
    // TODO: Navigate to scanner screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scanner feature coming soon!')),
    );
  }

  void _navigateToProducts() {
    // TODO: Navigate to products screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Products feature coming soon!')),
    );
  }

  void _handleChangeStore() {
    context.goNamed('store-selection');
  }

  Future<void> _handleLogout() async {
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();

      if (mounted) {
        context.goNamed('login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to logout: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}