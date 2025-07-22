import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../generated/app_localizations.dart';
import '../../../core/widgets/main_navigation_scaffold.dart';
import '../../../core/models/category.dart';
import '../../../core/services/category_service.dart';
import '../../../core/services/store_service.dart';
import '../../../core/models/store.dart';
import '../../../core/providers/store_context_provider.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/models/user.dart';
import '../../../core/routing/app_router.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryService _categoryService = CategoryService();
  final StoreService _storeService = StoreService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Category> _categories = [];
  List<Store> _stores = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadStoresAndCategories();
  }

  Future<void> _loadStoresAndCategories() async {
    await _loadStores();
    await _loadCategories();
  }

  Future<void> _loadStores() async {
    // Guard clause: ensure widget is mounted
    if (!mounted) return;
    
    try {
      final response = await _storeService.getStores();
      
      // Guard clause: check if widget is still mounted after async operation
      if (!mounted) return;
      
      setState(() {
        _stores = response.data;
      });
    } catch (e) {
      // Guard clause: ensure widget is mounted before error handling
      if (!mounted) return;
      
      // Store loading errors are not critical for category display
      debugPrint('Failed to load stores: $e');
    }
  }

  String? _getStoreName(String? storeId) {
    // Guard clause: return null if storeId is not provided
    if (storeId == null) return null;
    
    try {
      final store = _stores.firstWhere((store) => store.id == storeId);
      return store.name;
    } catch (e) {
      // Store not found, return null
      return null;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCategories({bool refresh = false}) async {
    // Guard clause: reset pagination state if refreshing
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _categories.clear();
    }

    // Guard clause: prevent loading if no more data or already loading
    if (!_hasMore || _isLoadingMore) return;
    // Guard clause: ensure widget is mounted before state changes
    if (!mounted) return;

    setState(() {
      if (refresh || _currentPage == 1) {
        _isLoading = true;
        _error = null;
      } else {
        _isLoadingMore = true;
      }
    });

    try {
      final storeContext = Provider.of<StoreContextProvider>(context, listen: false);
      final response = await _categoryService.getCategories(
        page: _currentPage,
        limit: 20,
        storeId: storeContext.selectedStore?.id,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      // Guard clause: ensure widget is mounted after async operation
      if (!mounted) return;

      setState(() {
        if (refresh || _currentPage == 1) {
          _categories = response.data;
        } else {
          _categories.addAll(response.data);
        }
        _currentPage++;
        _hasMore = response.pagination.hasNext;
        _isLoading = false;
        _isLoadingMore = false;
        _error = null;
      });
    } catch (e) {
      // Guard clause: ensure widget is mounted before error state update
      if (!mounted) return;
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    // Guard clause: ensure widget is mounted before state update
    if (!mounted) return;
    
    setState(() {
      _searchQuery = value;
    });
    _debounceSearch();
  }

  Timer? _debounceTimer;
  void _debounceSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      // Guard clause: ensure widget is still mounted before loading
      if (!mounted) return;
      _loadCategories(refresh: true);
    });
  }

  bool _canCreateOrEdit() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userRole = authProvider.currentUser?.role;
    return userRole == UserRole.owner || userRole == UserRole.admin;
  }

  Future<void> _navigateToCreateCategory() async {
    // Guard clause: check permissions before navigating
    if (!_canCreateOrEdit()) return;
    // Guard clause: ensure widget is mounted
    if (!mounted) return;

    AppRouter.goToCreateCategory(context);
    
    // Refresh categories when returning from form
    // Note: This will be triggered by screen lifecycle or manual refresh
    _loadCategories(refresh: true);
  }

  Future<void> _navigateToEditCategory(Category category) async {
    // Guard clause: check permissions before navigating
    if (!_canCreateOrEdit()) return;
    // Guard clause: ensure widget is mounted
    if (!mounted) return;

    AppRouter.goToEditCategory(context, category.id, category);
    
    // Refresh categories when returning from form
    // Note: This will be triggered by screen lifecycle or manual refresh
    _loadCategories(refresh: true);
  }

  Future<void> _showDeleteConfirmation(Category category) async {
    // Guard clause: check permissions before showing dialog
    if (!_canCreateOrEdit()) return;
    // Guard clause: ensure widget is mounted
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete + ' ' + l10n.categories.substring(0, l10n.categories.length - 1)),
        content: Text(
          'Are you sure you want to delete "${category.name}"?',
          overflow: TextOverflow.ellipsis,
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    // Guard clause: check if dialog was confirmed and widget is still mounted
    if (confirmed != true || !mounted) return;

    try {
      await _categoryService.deleteCategory(category.id);
      
      // Guard clause: ensure widget is mounted after async operation
      if (!mounted) return;
      
      _loadCategories(refresh: true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category "${category.name}" deleted successfully')),
      );
    } catch (e) {
      // Guard clause: ensure widget is mounted before showing error
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete category: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return NavigationAwareScaffold(
      title: l10n.categories,
      currentRoute: 'categories',
      floatingActionButton: _canCreateOrEdit()
          ? FloatingActionButton(
              onPressed: _navigateToCreateCategory,
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
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
                ),
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: _buildContent(l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    if (_isLoading && _categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading categories',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadCategories(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No categories found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search'
                  : 'Create your first category to get started',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (_canCreateOrEdit()) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _navigateToCreateCategory,
                child: const Text('Create Category'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadCategories(refresh: true),
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadCategories();
          }
          return false;
        },
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _categories.length + (_isLoadingMore ? 1 : 0),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == _categories.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final category = _categories[index];
            return _buildModernCategoryCard(category);
          },
        ),
      ),
    );
  }

  Widget _buildModernCategoryCard(Category category) {
    final l10n = AppLocalizations.of(context)!;
    final storeName = _getStoreName(category.storeId);
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Guard clause: check if editing is allowed before navigation
          if (!_canCreateOrEdit()) return;
          _navigateToEditCategory(category);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.category,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Category name and store
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.store,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            storeName ?? 'Unknown Store',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: storeName != null 
                                  ? Theme.of(context).colorScheme.onSurfaceVariant
                                  : Theme.of(context).colorScheme.error,
                              fontStyle: storeName != null ? FontStyle.normal : FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Actions menu
              if (_canCreateOrEdit())
                PopupMenuButton<String>(
                  onSelected: (value) {
                    // Guard clause: ensure widget is mounted before action
                    if (!mounted) return;
                    
                    switch (value) {
                      case 'edit':
                        _navigateToEditCategory(category);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(category);
                        break;
                    }
                  },
                  icon: Icon(
                    Icons.more_vert,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Text(l10n.edit),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete_outlined,
                            size: 18,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Text(l10n.delete),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}