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
import '../../../core/widgets/loading.dart';
import '../../../core/widgets/cards.dart';
import '../../../core/widgets/app_bars.dart';
import '../../../core/routing/app_router.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
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
  static const int _pageSize = 20;
  
  // Filter states
  String _searchQuery = '';
  String? _selectedCategoryId;
  String? _selectedStoreId;
  double? _minPrice;
  double? _maxPrice;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreProducts) {
        _loadMoreProducts();
      }
    }
  }
  
  void _onSearchChanged() {
    // Debounce search to avoid too many API calls
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text != _searchQuery) {
        setState(() {
          _searchQuery = _searchController.text;
        });
        _refreshProducts();
      }
    });
  }
  
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // Load categories and stores for filtering
      await Future.wait([
        _loadCategories(),
        _loadStores(),
        _loadProducts(reset: true),
      ]);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadCategories() async {
    try {
      final response = await _categoryService.getCategories(limit: 100);
      setState(() {
        _categories = response.data;
      });
    } catch (e) {
      // Categories are optional for filtering, so don't throw error
      debugPrint('Failed to load categories: $e');
    }
  }
  
  Future<void> _loadStores() async {
    try {
      final user = context.read<AuthProvider>().user;
      if (user?.role == UserRole.owner) {
        final response = await _storeService.getStores(limit: 100);
        setState(() {
          _stores = response.data;
        });
      }
    } catch (e) {
      // Stores are optional for filtering, so don't throw error
      debugPrint('Failed to load stores: $e');
    }
  }
  
  Future<void> _loadProducts({bool reset = false}) async {
    if (reset) {
      setState(() {
        _currentPage = 1;
        _hasMoreProducts = true;
      });
    }
    
    try {
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
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        storeId: storeFilter,
        categoryId: _selectedCategoryId,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      );
      
      setState(() {
        if (reset) {
          _products = response.data;
        } else {
          _products.addAll(response.data);
        }
        _hasMoreProducts = response.pagination.hasNext;
      });
    } catch (e) {
      if (reset) {
        setState(() {
          _error = e.toString();
        });
      }
      rethrow;
    }
  }
  
  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMoreProducts) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      _currentPage++;
      await _loadProducts();
    } catch (e) {
      _currentPage--; // Revert page increment on error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load more products: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }
  
  Future<void> _refreshProducts() async {
    // No need for separate refresh state since we use RefreshIndicator
    
    try {
      await _loadProducts(reset: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to refresh products: $e')),
        );
      }
    } finally {
      // Refresh completed
    }
  }
  
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterDialog(
        categories: _categories,
        stores: _stores,
        selectedCategoryId: _selectedCategoryId,
        selectedStoreId: _selectedStoreId,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        onFiltersChanged: (categoryId, storeId, minPrice, maxPrice) {
          setState(() {
            _selectedCategoryId = categoryId;
            _selectedStoreId = storeId;
            _minPrice = minPrice;
            _maxPrice = maxPrice;
          });
          _refreshProducts();
        },
      ),
    );
  }
  
  void _clearFilters() {
    setState(() {
      _selectedCategoryId = null;
      _selectedStoreId = null;
      _minPrice = null;
      _maxPrice = null;
      _searchController.clear();
      _searchQuery = '';
    });
    _refreshProducts();
  }

  void _scanBarcode() {
    AppRouter.goToScanner(
      context,
      title: 'Scan Product Barcode',
      subtitle: 'Scan a barcode to search for products',
      onBarcodeScanned: (result) {
        if (result.isValid) {
          _searchProductByBarcode(result.code);
        }
      },
    );
  }

  Future<void> _searchProductByBarcode(String barcode) async {
    try {
      // Search for product by barcode using the dedicated method
      final product = await _productService.getProductByBarcode(barcode);
      
      // Navigate directly to product detail
      AppRouter.goToProductDetail(context, product.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No product found with barcode: $barcode'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
  
  bool get _hasActiveFilters {
    return _selectedCategoryId != null ||
        _selectedStoreId != null ||
        _minPrice != null ||
        _maxPrice != null ||
        _searchQuery.isNotEmpty;
  }
  
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final canEdit = user?.canCreateProducts == true;
    
    return Scaffold(
      appBar: WMSAppBar(
        title: 'Products',
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanBarcode,
            tooltip: 'Scan Barcode',
          ),
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _hasActiveFilters ? Theme.of(context).primaryColor : null,
            ),
            onPressed: _showFilterDialog,
          ),
          if (_hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearFilters,
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, SKU, or barcode...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          // Product list
          Expanded(
            child: _buildProductList(),
          ),
        ],
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton(
              onPressed: () {
                AppRouter.goToCreateProduct(context);
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
  
  Widget _buildProductList() {
    if (_isLoading) {
      return const Center(child: WMSLoadingIndicator());
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load products',
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
              onPressed: _loadInitialData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (_hasActiveFilters) ...[
              const SizedBox(height: 8),
              Text(
                'Try adjusting your filters',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _clearFilters,
                child: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _products.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _products.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: WMSLoadingIndicator()),
            );
          }
          
          final product = _products[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ProductCard(
              product: product,
              canEdit: context.read<AuthProvider>().user?.canCreateProducts == true,
              onTap: () {
                AppRouter.goToProductDetail(context, product.id);
              },
              onEdit: () {
                AppRouter.goToEditProduct(context, product.id);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final bool canEdit;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  
  const _ProductCard({
    required this.product,
    required this.canEdit,
    required this.onTap,
    required this.onEdit,
  });

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ProductQuickActions(
        product: product,
        canEdit: canEdit,
        onViewDetails: onTap,
        onEdit: onEdit,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return WMSCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // IMEI Badge
                          if (product.isImei) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.orange, width: 0.5),
                              ),
                              child: Text(
                                'IMEI',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (product.sku.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'SKU: ${product.sku}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (canEdit)
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: onEdit,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onPressed: () => _showQuickActions(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InfoChip(
                    label: 'Price',
                    value: '\$${(product.salePrice ?? product.purchasePrice).toStringAsFixed(2)}',
                    icon: Icons.attach_money,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoChip(
                    label: 'Quantity',
                    value: '${product.quantity}',
                    icon: Icons.inventory,
                  ),
                ),
              ],
            ),
            if (product.barcode.isNotEmpty) ...[
              const SizedBox(height: 8),
              _InfoChip(
                label: 'Barcode',
                value: product.barcode,
                icon: Icons.qr_code,
              ),
            ],
            if (product.sku.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Additional info: ${product.sku}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  
  const _InfoChip({
    required this.label,
    required this.value,
    required this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDialog extends StatefulWidget {
  final List<Category> categories;
  final List<Store> stores;
  final String? selectedCategoryId;
  final String? selectedStoreId;
  final double? minPrice;
  final double? maxPrice;
  final Function(String?, String?, double?, double?) onFiltersChanged;
  
  const _FilterDialog({
    required this.categories,
    required this.stores,
    required this.selectedCategoryId,
    required this.selectedStoreId,
    required this.minPrice,
    required this.maxPrice,
    required this.onFiltersChanged,
  });
  
  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late String? _selectedCategoryId;
  late String? _selectedStoreId;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  
  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.selectedCategoryId;
    _selectedStoreId = widget.selectedStoreId;
    _minPriceController = TextEditingController(
      text: widget.minPrice?.toString() ?? '',
    );
    _maxPriceController = TextEditingController(
      text: widget.maxPrice?.toString() ?? '',
    );
  }
  
  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final showStoreFilter = user?.role == UserRole.owner && widget.stores.isNotEmpty;
    
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Products',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          // Category filter
          if (widget.categories.isNotEmpty) ...[
            Text(
              'Category',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                hintText: 'Select category',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All categories'),
                ),
                ...widget.categories.map((category) => DropdownMenuItem<String>(
                  value: category.id,
                  child: Text(category.name),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
            ),
            const SizedBox(height: 16),
          ],
          
          // Store filter (only for owners)
          if (showStoreFilter) ...[
            Text(
              'Store',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedStoreId,
              decoration: const InputDecoration(
                hintText: 'Select store',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All stores'),
                ),
                ...widget.stores.map((store) => DropdownMenuItem<String>(
                  value: store.id,
                  child: Text(store.name),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStoreId = value;
                });
              },
            ),
            const SizedBox(height: 16),
          ],
          
          // Price range filter
          Text(
            'Price Range',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minPriceController,
                  decoration: const InputDecoration(
                    hintText: 'Min price',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _maxPriceController,
                  decoration: const InputDecoration(
                    hintText: 'Max price',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final minPrice = double.tryParse(_minPriceController.text);
                    final maxPrice = double.tryParse(_maxPriceController.text);
                    
                    widget.onFiltersChanged(
                      _selectedCategoryId,
                      _selectedStoreId,
                      minPrice,
                      maxPrice,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductQuickActions extends StatelessWidget {
  final Product product;
  final bool canEdit;
  final VoidCallback onViewDetails;
  final VoidCallback onEdit;

  const _ProductQuickActions({
    required this.product,
    required this.canEdit,
    required this.onViewDetails,
    required this.onEdit,
  });

  void _addToSale(BuildContext context) {
    // TODO: Implement add to sale functionality in Phase 15
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add to Sale feature will be implemented in Phase 15'),
      ),
    );
  }

  void _printBarcode(BuildContext context) {
    // TODO: Implement barcode printing in Phase 17
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Barcode printing will be implemented in Phase 17'),
      ),
    );
  }

  void _shareProduct(BuildContext context) {
    // TODO: Implement product sharing
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product sharing coming soon'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product.sku.isNotEmpty)
                      Text(
                        'SKU: ${product.sku}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Quick actions
          _QuickActionTile(
            icon: Icons.visibility,
            title: 'View Details',
            subtitle: 'See full product information',
            onTap: () {
              Navigator.of(context).pop();
              onViewDetails();
            },
          ),
          
          if (canEdit) ...[
            _QuickActionTile(
              icon: Icons.edit,
              title: 'Edit Product',
              subtitle: 'Modify product details',
              onTap: () {
                Navigator.of(context).pop();
                onEdit();
              },
            ),
          ],
          
          _QuickActionTile(
            icon: Icons.add_shopping_cart,
            title: 'Add to Sale',
            subtitle: 'Add this product to a transaction',
            onTap: () => _addToSale(context),
          ),
          
          _QuickActionTile(
            icon: Icons.print,
            title: 'Print Barcode',
            subtitle: 'Print product barcode label',
            onTap: () => _printBarcode(context),
          ),
          
          _QuickActionTile(
            icon: Icons.share,
            title: 'Share Product',
            subtitle: 'Share product information',
            onTap: () => _shareProduct(context),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}