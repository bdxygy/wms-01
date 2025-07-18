import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/providers/store_context_provider.dart';
import '../widgets/owner_dashboard.dart';
import '../widgets/admin_dashboard.dart';
import '../widgets/staff_dashboard.dart';
import '../widgets/cashier_dashboard.dart';

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
        title: Text(_getDashboardTitle(user?.role.toString() ?? 'UNKNOWN')),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          // Settings action for OWNER
          if (authProvider.isOwner)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _navigateToSettings(),
              tooltip: 'Settings',
            ),
          // Logout action
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
              
              if (!authProvider.isOwner && storeProvider.selectedStore != null)
                const SizedBox(height: 24),
              
              // Role-specific Dashboard Content
              _buildRoleSpecificDashboard(user?.role.toString() ?? 'UNKNOWN'),
            ],
          ),
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

  Widget _buildRoleSpecificDashboard(String role) {
    switch (role.toUpperCase()) {
      case 'OWNER':
        return const OwnerDashboard();
      case 'ADMIN':
        return const AdminDashboard();
      case 'STAFF':
        return const StaffDashboard();
      case 'CASHIER':
        return const CashierDashboard();
      default:
        return _buildUnknownRoleDashboard();
    }
  }

  Widget _buildUnknownRoleDashboard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unknown Role',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your user role is not recognized. Please contact your administrator.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => _handleLogout(),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
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

  String _getDashboardTitle(String role) {
    switch (role.toUpperCase()) {
      case 'OWNER':
        return 'Owner Dashboard';
      case 'ADMIN':
        return 'Admin Dashboard';
      case 'STAFF':
        return 'Staff Dashboard';
      case 'CASHIER':
        return 'Cashier Dashboard';
      default:
        return 'WMS Dashboard';
    }
  }

  Future<void> _handleRefresh() async {
    // TODO: Implement refresh logic
    await Future.delayed(const Duration(seconds: 1));
  }

  void _navigateToSettings() {
    // TODO: Navigate to settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings feature coming soon!')),
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