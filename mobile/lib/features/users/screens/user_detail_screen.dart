import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../generated/app_localizations.dart';
import '../../../core/models/user.dart';
import '../../../core/services/users_service.dart';
import '../../../core/auth/auth_provider.dart';

/// User detail screen with role-based information display
class UserDetailScreen extends StatefulWidget {
  final String userId;

  const UserDetailScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final UsersService _usersService = UsersService();
  
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _usersService.getUserById(widget.userId);
      
      if (mounted && response.success && response.data != null) {
        setState(() {
          _user = response.data;
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to load user';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToEdit() {
    if (_user == null) return;
    
    context.push('/users/${_user!.id}/edit').then((_) {
      _loadUser(); // Refresh after edit
    });
  }

  void _confirmDelete() {
    if (_user == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to delete user \'${_user!.name}\'? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteUser();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser() async {
    if (_user == null) return;

    try {
      await _usersService.deleteUser(_user!.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );
        Navigator.of(context).pop(); // Return to users list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'User Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          if (_user != null && currentUser?.canManageUsers == true) ...[
            IconButton(
              onPressed: _navigateToEdit,
              icon: const Icon(Icons.edit),
              tooltip: l10n.edit,
            ),
            IconButton(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete),
              tooltip: l10n.delete,
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUser,
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (_user == null) {
      return const Center(
        child: Text('User not found'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserHeader(),
          const SizedBox(height: 24),
          _buildUserInfo(l10n),
          const SizedBox(height: 24),
          _buildRoleInfo(l10n),
          const SizedBox(height: 24),
          _buildTimestamps(l10n),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getRoleColor(),
            _getRoleColor().withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              _getRoleIcon(),
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _user!.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '@${_user!.username}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getRoleDisplayName(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                const Text(
                  'User Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Full Name', _user!.name),
            _buildInfoRow('Username', '@${_user!.username}'),
            _buildInfoRow('User ID', _user!.id),
            if (_user!.ownerId != null)
              _buildInfoRow('Owner ID', _user!.ownerId!),
            _buildInfoRow(
              'Status',
              _user!.isActive ? 'Active' : 'Inactive',
              valueColor: _user!.isActive ? Colors.green : Colors.red,
            ),
            if (_user!.deletedAt != null)
              _buildInfoRow(
                'Deleted At',
                _formatDateTime(_user!.deletedAt!),
                valueColor: Colors.red,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleInfo(AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Role & Permissions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Role', _getRoleDisplayName()),
            const SizedBox(height: 12),
            const Text(
              'Permissions:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            _buildPermissionChip('Create Products', _user!.canCreateProducts),
            _buildPermissionChip('Create Transactions', _user!.canCreateTransactions),
            _buildPermissionChip('Manage Users', _user!.canManageUsers),
            _buildPermissionChip('Manage Stores', _user!.canManageStores),
            _buildPermissionChip('Delete Data', _user!.canDeleteData),
          ],
        ),
      ),
    );
  }

  Widget _buildTimestamps(AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Timestamps',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Created At', _formatDateTime(_user!.createdAt)),
            _buildInfoRow('Updated At', _formatDateTime(_user!.updatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionChip(String permission, bool hasPermission) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: Chip(
        label: Text(
          permission,
          style: TextStyle(
            fontSize: 12,
            color: hasPermission ? Colors.green : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: hasPermission 
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        side: BorderSide(
          color: hasPermission ? Colors.green : Colors.grey,
          width: 1,
        ),
        avatar: Icon(
          hasPermission ? Icons.check_circle : Icons.cancel,
          size: 16,
          color: hasPermission ? Colors.green : Colors.grey,
        ),
      ),
    );
  }

  Color _getRoleColor() {
    switch (_user!.role) {
      case UserRole.owner:
        return Colors.purple;
      case UserRole.admin:
        return Colors.blue;
      case UserRole.staff:
        return Colors.green;
      case UserRole.cashier:
        return Colors.orange;
    }
  }

  IconData _getRoleIcon() {
    switch (_user!.role) {
      case UserRole.owner:
        return Icons.admin_panel_settings;
      case UserRole.admin:
        return Icons.manage_accounts;
      case UserRole.staff:
        return Icons.person;
      case UserRole.cashier:
        return Icons.point_of_sale;
    }
  }

  String _getRoleDisplayName() {
    switch (_user!.role) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.admin:
        return 'Admin';
      case UserRole.staff:
        return 'Staff';
      case UserRole.cashier:
        return 'Cashier';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}