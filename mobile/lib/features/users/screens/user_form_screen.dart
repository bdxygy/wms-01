import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../generated/app_localizations.dart';
import '../../../core/models/user.dart';
import '../../../core/services/users_service.dart';
import '../../../core/auth/auth_provider.dart';

/// User form screen for create and edit operations
class UserFormScreen extends StatefulWidget {
  final String? userId; // null for create, user ID for edit

  const UserFormScreen({
    super.key,
    this.userId,
  });

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final UsersService _usersService = UsersService();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Form state
  UserRole? _selectedRole;
  bool _isActive = true;
  bool _isLoadingUser = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  // Data
  User? _existingUser;

  bool get _isEditMode => widget.userId != null;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (_isEditMode) {
      await _loadUser();
    }
  }

  Future<void> _loadUser() async {
    if (!_isEditMode) return;

    setState(() {
      _isLoadingUser = true;
    });

    try {
      final response = await _usersService.getUserById(widget.userId!);
      
      if (mounted && response.success && response.data != null) {
        _existingUser = response.data;
        _populateForm();
        setState(() {
          _isLoadingUser = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to load user';
            _isLoadingUser = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoadingUser = false;
        });
      }
    }
  }

  void _populateForm() {
    if (_existingUser == null) return;

    _nameController.text = _existingUser!.name;
    _usernameController.text = _existingUser!.username;
    _selectedRole = _existingUser!.role;
    _isActive = _existingUser!.isActive;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      if (_isEditMode) {
        await _updateUser();
      } else {
        await _createUser();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'User updated successfully' : 'User created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return success
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _createUser() async {
    await _usersService.createUser(
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole!,
    );
  }

  Future<void> _updateUser() async {
    await _usersService.updateUser(
      id: widget.userId!,
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
      role: _selectedRole!,
      isActive: _isActive,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          _isEditMode ? 'Edit User' : 'Create User',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_isLoadingUser) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && !_isSubmitting) {
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
              onPressed: _loadInitialData,
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null && _isSubmitting) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            _buildBasicInfoSection(l10n),
            const SizedBox(height: 24),
            _buildRoleSection(l10n),
            const SizedBox(height: 24),
            if (_isEditMode) ...[
              _buildStatusSection(l10n),
              const SizedBox(height: 24),
            ],
            _buildSubmitButton(l10n),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(AppLocalizations l10n) {
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
                  'Basic Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name *',
                hintText: 'Enter full name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'Full name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username *',
                hintText: 'Enter username',
                prefixIcon: const Icon(Icons.alternate_email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'Username is required';
                }
                if (value!.trim().length < 3) {
                  return 'Username must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: _isEditMode ? 'Password (leave empty to keep current)' : 'Password *',
                hintText: _isEditMode ? 'Enter new password' : 'Enter password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (!_isEditMode && (value?.isEmpty ?? true)) {
                  return 'Password is required';
                }
                if (value != null && value.isNotEmpty && value.length < 4) {
                  return 'Password must be at least 4 characters';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSection(AppLocalizations l10n) {
    final currentUser = context.watch<AuthProvider>().user;

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
            const SizedBox(height: 20),
            DropdownButtonFormField<UserRole>(
              value: _selectedRole,
              decoration: InputDecoration(
                labelText: 'Role *',
                hintText: 'Select role',
                prefixIcon: const Icon(Icons.admin_panel_settings),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: _getAvailableRoles(currentUser).map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Row(
                    children: [
                      Icon(_getRoleIcon(role), size: 20),
                      const SizedBox(width: 8),
                      Text(_getRoleDisplayName(role)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (role) {
                setState(() {
                  _selectedRole = role;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Role is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(AppLocalizations l10n) {
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
                  Icons.toggle_on,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Active'),
              subtitle: Text(_isActive 
                  ? 'User can login and access the system'
                  : 'User cannot login to the system'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              secondary: Icon(
                _isActive ? Icons.check_circle : Icons.cancel,
                color: _isActive ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                _isEditMode ? 'Update User' : 'Create User',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  List<UserRole> _getAvailableRoles(User? currentUser) {
    if (currentUser == null) return [];

    // Only owners can create other owners and admins
    if (currentUser.isOwner) {
      return [UserRole.owner, UserRole.admin, UserRole.staff, UserRole.cashier];
    }

    // Admins can only create staff and cashiers
    if (currentUser.isAdmin) {
      return [UserRole.staff, UserRole.cashier];
    }

    return [];
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
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

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
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
}