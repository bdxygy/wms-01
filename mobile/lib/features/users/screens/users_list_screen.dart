import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../generated/app_localizations.dart';
import '../../../core/models/user.dart';
import '../../../core/services/users_service.dart';
import '../../../core/auth/auth_provider.dart';
import '../widgets/user_card.dart';

/// Users list screen with search, filtering, and CRUD operations
class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final UsersService _usersService = UsersService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<User> _users = [];
  bool _isLoading = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  String? _errorMessage;

  // Filter parameters
  UserRole? _selectedRole;
  bool? _isActiveFilter;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    if (currentScroll >= (maxScroll * 0.9) && !_isLoading && _hasMoreData) {
      _loadMoreUsers();
    }
  }

  Future<void> _loadUsers({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      if (refresh) {
        _users.clear();
        _currentPage = 1;
        _hasMoreData = true;
      }
    });

    try {
      final response = await _usersService.getUsers(
        page: _currentPage,
        limit: 20,
        role: _selectedRole?.roleString,
        isActive: _isActiveFilter,
        search: _searchQuery,
      );

      if (mounted) {
        setState(() {
          if (refresh || _currentPage == 1) {
            _users = response.data;
          } else {
            _users.addAll(response.data);
          }
          _hasMoreData = response.pagination.hasNext;
          _isLoading = false;
        });
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

  Future<void> _loadMoreUsers() async {
    if (!_hasMoreData || _isLoading) return;

    setState(() {
      _currentPage++;
    });

    await _loadUsers();
  }

  void _onSearchChanged(String query) {
    _searchQuery = query.isEmpty ? null : query;
    _currentPage = 1;
    _loadUsers(refresh: true);
  }

  void _showFilterSheet() {
    // TODO: Implement filter sheet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filter feature coming soon!')),
    );
  }

  void _navigateToCreateUser() {
    context.push('/users/create').then((_) {
      _loadUsers(refresh: true);
    });
  }

  void _navigateToUserDetail(User user) {
    context.push('/users/${user.id}').then((_) {
      _loadUsers(refresh: true);
    });
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
          'Users',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showFilterSheet,
            icon: Badge(
              isLabelVisible: _selectedRole != null || _isActiveFilter != null,
              child: const Icon(Icons.filter_list),
            ),
            tooltip: l10n.filter,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildSearchSection(l10n),
          Expanded(
            child: _buildUsersList(l10n),
          ),
        ],
      ),
      floatingActionButton: currentUser?.canManageUsers == true
          ? FloatingActionButton(
              onPressed: _navigateToCreateUser,
              tooltip: 'Create User',
              child: const Icon(Icons.person_add),
            )
          : null,
    );
  }

  Widget _buildSearchSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search users by name or username...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }

  Widget _buildUsersList(AppLocalizations l10n) {
    if (_errorMessage != null && _users.isEmpty) {
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
              onPressed: () => _loadUsers(refresh: true),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No Users Found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first user to get started',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (context.watch<AuthProvider>().user?.canManageUsers == true)
              ElevatedButton(
                onPressed: _navigateToCreateUser,
                child: const Text('Create User'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadUsers(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _users.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _users.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final user = _users[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: UserCard(
              user: user,
              onTap: () => _navigateToUserDetail(user),
            ),
          );
        },
      ),
    );
  }
}