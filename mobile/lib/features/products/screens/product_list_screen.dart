import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/product.dart';
import '../../../core/models/category.dart';
import '../../../core/models/store.dart';
import '../../../core/models/user.dart';
import '../../../core/services/product_service.dart';
import '../../../core/services/category_service.dart';
import '../../../core/services/store_service.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/providers/store_context_provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/widgets/loading.dart';
import '../../../core/widgets/app_bars.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/mixins/refresh_list_mixin.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> 
    with WidgetsBindingObserver, RefreshListMixin<ProductListScreen> {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final StoreService _storeService = StoreService();

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _products = [];
  List<Category> _categories = [];
  List<Store> _stores = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreProducts = true;
  String? _error;

  int _currentPage = 1;
  static const int _pageSize = 15; // Reduced for mobile

  // Filter states
  String _searchQuery = '';
  String? _selectedCategoryId;
  String? _selectedStoreId;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    setupRefreshListener();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });

    Future.microtask(() {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    disposeRefreshListener();
    super.dispose();
  }

  @override
  Future<void> refreshData() async {
    await _refreshProducts();
  }

  void _onScroll() {
    // Guard clause: Check scroll position for pagination
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 200) return;
    if (_isLoadingMore || !_hasMoreProducts) return;

    _loadMoreProducts();
  }

  void _onSearchChanged() {
    // Guard clause: Prevent unnecessary searches
    if (!mounted) return;
    if (_searchController.text == _searchQuery) return;

    // Debounce search to avoid too many API calls
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (_searchController.text != _searchQuery) {
        setState(() {
          _searchQuery = _searchController.text;
        });
        _refreshProducts();
      }
    });
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Future.wait([
        _loadCategories(),
        _loadStores(),
        _loadProducts(reset: true),
      ]);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      if (!mounted) return;
      final response = await _categoryService.getCategories(limit: 50);
      if (!mounted) return;

      setState(() {
        _categories = response.data;
      });
    } catch (e) {
      debugPrint('Failed to load categories: $e');
    }
  }

  Future<void> _loadStores() async {
    final user = context.read<AuthProvider>().user;

    // Guard clause: Only load stores for owners
    if (user?.role != UserRole.owner) return;

    try {
      if (!mounted) return;
      final response = await _storeService.getStores(limit: 50);
      if (!mounted) return;

      setState(() {
        _stores = response.data;
      });
    } catch (e) {
      debugPrint('Failed to load stores: $e');
    }
  }

  Future<void> _loadProducts({bool reset = false}) async {
    if (!mounted) return;

    if (reset) {
      setState(() {
        _currentPage = 1;
        _hasMoreProducts = true;
      });
    }

    try {
      if (!mounted) return;
      final storeContext = context.read<StoreContextProvider>().selectedStore;
      final user = context.read<AuthProvider>().user;

      // Determine store filter based on user role
      String? storeFilter = _selectedStoreId;
      if (user?.role != UserRole.owner && storeContext != null) {
        storeFilter = storeContext.id;
      }

      final response = await _productService.getProducts(
        page: _currentPage,
        limit: _pageSize,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        storeId: storeFilter,
        categoryId: _selectedCategoryId,
      );

      if (!mounted) return;

      setState(() {
        if (reset) {
          _products = response.data;
        } else {
          _products.addAll(response.data);
        }
        _hasMoreProducts = response.pagination.hasNext;
      });
    } catch (e) {
      if (!mounted) return;
      if (reset) {
        setState(() {
          _error = e.toString();
        });
      }
      rethrow;
    }
  }

  Future<void> _loadMoreProducts() async {
    // Guard clause: Prevent multiple loads
    if (_isLoadingMore || !_hasMoreProducts) return;

    setState(() => _isLoadingMore = true);

    try {
      _currentPage++;
      await _loadProducts();
    } catch (e) {
      _currentPage--; // Revert on error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load more: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  Future<void> _refreshProducts() async {
    try {
      await _loadProducts(reset: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to refresh: $e')),
        );
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedCategoryId = null;
      _selectedStoreId = null;
      _searchController.clear();
      _searchQuery = '';
      _showFilters = false;
    });
    _refreshProducts();
  }

  void _scanBarcode() {
    AppRouter.goToScanner(
      context,
      title: 'Scan Product Barcode',
      subtitle: 'Find products by barcode',
      onBarcodeScanned: (result) {
        if (result.isValid) {
          _searchProductByBarcode(result.code);
        }
      },
    );
  }

  Future<void> _searchProductByBarcode(String barcode) async {
    try {
      final product = await _productService.getProductByBarcode(barcode);

      if (mounted) {
        AppRouter.goToProductDetail(context, product.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No product found: $barcode'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool get _hasActiveFilters {
    return _selectedCategoryId != null ||
        _selectedStoreId != null ||
        _searchQuery.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final canEdit = user?.canCreateProducts == true;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: WMSAppBar(
        title: 'Products (${_products.length})',
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, size: 22),
            onPressed: _scanBarcode,
            tooltip: 'Scan Barcode',
          ),
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list : Icons.filter_list_outlined,
              size: 22,
              color: _hasActiveFilters || _showFilters
                  ? Theme.of(context).primaryColor
                  : null,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            tooltip: 'Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          // Compact search and filters
          _buildSearchAndFilters(),

          // Product list
          Expanded(
            child: _buildProductList(),
          ),
        ],
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton(
              onPressed: () => navigateAndRefresh(
                AppRouter.pushToCreateProduct(context)
              ),
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.5),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                isDense: true,
              ),
            ),
          ),

          // Expandable filters
          if (_showFilters) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_categories.isNotEmpty || _stores.isNotEmpty) ...[
                    Row(
                      children: [
                        // Category filter
                        if (_categories.isNotEmpty) ...[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Category',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<String>(
                                  value: _selectedCategoryId,
                                  decoration: InputDecoration(
                                    hintText: 'All',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    isDense: true,
                                  ),
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('All Categories'),
                                    ),
                                    ..._categories.map(
                                        (category) => DropdownMenuItem<String>(
                                              value: category.id,
                                              child: Text(
                                                category.name,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            )),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCategoryId = value;
                                    });
                                    _refreshProducts();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Store filter (for owners)
                        if (_stores.isNotEmpty) ...[
                          if (_categories.isNotEmpty) const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Store',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<String>(
                                  value: _selectedStoreId,
                                  decoration: InputDecoration(
                                    hintText: 'All',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    isDense: true,
                                  ),
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('All Stores'),
                                    ),
                                    ..._stores.map(
                                        (store) => DropdownMenuItem<String>(
                                              value: store.id,
                                              child: Text(
                                                store.name,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            )),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedStoreId = value;
                                    });
                                    _refreshProducts();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Clear filters button
                    if (_hasActiveFilters) ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _clearFilters,
                          icon: const Icon(Icons.clear, size: 18),
                          label: const Text('Clear Filters'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: Theme.of(context).primaryColor),
                            foregroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],

          // Active filters indicator
          if (_hasActiveFilters && !_showFilters) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Filters active',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _clearFilters,
                    child: Text(
                      'Clear',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    // Guard clause: Loading state
    if (_isLoading) {
      return const Center(child: WMSLoadingIndicator());
    }

    // Guard clause: Error state
    if (_error != null) {
      return _buildErrorState();
    }

    // Guard clause: Empty state
    if (_products.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _products.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          // Loading more indicator
          if (index == _products.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: WMSLoadingIndicator(),
              ),
            );
          }

          final product = _products[index];
          return _CompactProductCard(
            product: product,
            onTap: () => AppRouter.goToProductDetail(context, product.id),
            onEdit: context.read<AuthProvider>().user?.canCreateProducts == true
                ? () => AppRouter.goToEditProduct(context, product.id)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load products',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInitialData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _hasActiveFilters
                  ? 'No products match filters'
                  : 'No products found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _hasActiveFilters
                  ? 'Try adjusting your search or filters'
                  : 'Add your first product to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_hasActiveFilters) ...[
              OutlinedButton(
                onPressed: _clearFilters,
                child: const Text('Clear Filters'),
              ),
            ] else if (context.read<AuthProvider>().user?.canCreateProducts ==
                true) ...[
              ElevatedButton.icon(
                onPressed: () => AppRouter.goToCreateProduct(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CompactProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const _CompactProductCard({
    required this.product,
    required this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // IMEI badge
                            if (product.isImei) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: Colors.orange, width: 0.5),
                                ),
                                child: Text(
                                  'IMEI',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.orange[700],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 9,
                                      ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (product.sku.isNotEmpty) ...[
                          Text(
                            'SKU: ${product.sku}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                        ],
                      ],
                    ),
                  ),

                  // Action button
                  if (onEdit != null) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 8),

              // Info chips row
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      context,
                      Icons.attach_money,
                      Provider.of<AppProvider>(context, listen: false).formatCurrency(
                          product.salePrice ?? product.purchasePrice),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      context,
                      Icons.inventory,
                      'Stock: ${product.quantity}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStockStatusChip(context),
                  ),
                ],
              ),

              // Barcode row
              if (product.barcode.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.qr_code,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        product.barcode,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontFamily: 'monospace',
                            ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockStatusChip(BuildContext context) {
    Color statusColor;
    String statusText;

    if (product.quantity == 0) {
      statusColor = Colors.red;
      statusText = 'Out';
    } else if (product.quantity < 10) {
      statusColor = Colors.orange;
      statusText = 'Low';
    } else {
      statusColor = Colors.green;
      statusText = 'Good';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: statusColor, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              statusText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
