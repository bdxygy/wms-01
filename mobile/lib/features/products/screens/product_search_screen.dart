import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/product_search_service.dart';
import '../../../core/services/imei_scanner_service.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/models/product.dart';
import '../../../core/utils/imei_utils.dart';

/// Comprehensive product search screen supporting barcode, IMEI, and text search
class ProductSearchScreen extends StatefulWidget {
  final String? initialQuery;
  final String? searchType; // 'barcode', 'imei', 'text'

  const ProductSearchScreen({
    super.key,
    this.initialQuery,
    this.searchType,
  });

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ProductSearchService _productSearchService = ProductSearchService();
  final ImeiScannerService _imeiScannerService = ImeiScannerService();
  
  late TabController _tabController;
  
  List<Product> _searchResults = [];
  Product? _singleResult;
  bool _isSearching = false;
  String? _errorMessage;
  String _currentSearchType = 'text';
  
  // Search history
  final List<String> _searchHistory = [];
  final List<Product> _recentResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }
    
    if (widget.searchType != null) {
      _currentSearchType = widget.searchType!;
      switch (widget.searchType) {
        case 'barcode':
          _tabController.index = 0;
          break;
        case 'imei':
          _tabController.index = 1;
          break;
        case 'text':
        default:
          _tabController.index = 2;
          break;
      }
    }
    
    _tabController.addListener(() {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _currentSearchType = 'barcode';
            break;
          case 1:
            _currentSearchType = 'imei';
            break;
          case 2:
          default:
            _currentSearchType = 'text';
            break;
        }
      });
      _clearResults();
    });

    // Perform initial search if query provided
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _clearResults() {
    setState(() {
      _searchResults.clear();
      _singleResult = null;
      _errorMessage = null;
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _searchResults.clear();
      _singleResult = null;
    });

    // Add to search history
    if (!_searchHistory.contains(query)) {
      _searchHistory.insert(0, query);
      if (_searchHistory.length > 10) {
        _searchHistory.removeLast();
      }
    }

    try {
      switch (_currentSearchType) {
        case 'barcode':
          await _searchByBarcode(query);
          break;
        case 'imei':
          await _searchByImei(query);
          break;
        case 'text':
        default:
          await _searchByText(query);
          break;
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isSearching = false;
      });
    }
  }

  Future<void> _searchByBarcode(String barcode) async {
    try {
      final product = await _productSearchService.searchByBarcode(barcode);
      setState(() {
        if (product != null) {
          _singleResult = product;
          _addToRecentResults(product);
        } else {
          _errorMessage = 'No product found with barcode: $barcode';
        }
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Barcode search failed: $e';
        _isSearching = false;
      });
    }
  }

  Future<void> _searchByImei(String imei) async {
    try {
      final result = await _imeiScannerService.searchProductByImei(imei);
      setState(() {
        if (result.hasProduct) {
          _singleResult = result.product;
          _addToRecentResults(result.product!);
        } else if (result.hasError) {
          _errorMessage = result.errorMessage;
        } else {
          _errorMessage = 'No product found with IMEI: $imei';
        }
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'IMEI search failed: $e';
        _isSearching = false;
      });
    }
  }

  Future<void> _searchByText(String query) async {
    try {
      final products = await _productSearchService.searchProducts(
        query: query,
        limit: 50,
      );
      setState(() {
        _searchResults = products;
        if (products.isEmpty) {
          _errorMessage = 'No products found matching: $query';
        }
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Text search failed: $e';
        _isSearching = false;
      });
    }
  }

  void _addToRecentResults(Product product) {
    _recentResults.removeWhere((p) => p.id == product.id);
    _recentResults.insert(0, product);
    if (_recentResults.length > 5) {
      _recentResults.removeLast();
    }
  }

  void _openBarcodeScanner() {
    AppRouter.goToScanner(
      context,
      title: 'Scan Barcode',
      subtitle: 'Position barcode within the frame',
      onBarcodeScanned: (result) {
        if (result.isValid) {
          setState(() {
            _searchController.text = result.formattedCode;
            _tabController.index = 0;
            _currentSearchType = 'barcode';
          });
          _performSearch(result.formattedCode);
        }
      },
      autoClose: true,
    );
  }

  void _openImeiScanner() {
    AppRouter.goToImeiScanner(
      context,
      title: 'Scan IMEI',
      subtitle: 'Position IMEI within the frame',
      onImeiScanned: (result) {
        final imeiResult = result as ImeiScanResult;
        if (imeiResult.isValid) {
          setState(() {
            _searchController.text = imeiResult.imeiInfo.cleanedImei;
            _tabController.index = 1;
            _currentSearchType = 'imei';
          });
          _performSearch(imeiResult.imeiInfo.cleanedImei);
        }
      },
      autoClose: true,
    );
  }

  void _navigateToProduct(Product product) {
    AppRouter.goToProductDetail(context, product.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Search'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.qr_code),
              text: 'Barcode',
            ),
            Tab(
              icon: Icon(Icons.qr_code_2),
              text: 'IMEI',
            ),
            Tab(
              icon: Icon(Icons.search),
              text: 'Text',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Input
          Container(
            padding: const EdgeInsets.all(16),
            child: _buildSearchInput(),
          ),
          
          // Search Results
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBarcodeSearchTab(),
                _buildImeiSearchTab(),
                _buildTextSearchTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: _getSearchHint(),
              prefixIcon: Icon(_getSearchIcon()),
              border: const OutlineInputBorder(),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _clearResults();
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
            ),
            onSubmitted: _performSearch,
            inputFormatters: _getInputFormatters(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _currentSearchType == 'barcode'
              ? _openBarcodeScanner
              : _currentSearchType == 'imei'
                  ? _openImeiScanner
                  : null,
          icon: const Icon(Icons.qr_code_scanner),
          tooltip: 'Scan ${_currentSearchType.toUpperCase()}',
        ),
        IconButton(
          onPressed: () => _performSearch(_searchController.text),
          icon: const Icon(Icons.search),
          tooltip: 'Search',
        ),
      ],
    );
  }

  String _getSearchHint() {
    switch (_currentSearchType) {
      case 'barcode':
        return 'Enter or scan barcode...';
      case 'imei':
        return 'Enter or scan IMEI (15-16 digits)...';
      case 'text':
      default:
        return 'Search products by name, SKU...';
    }
  }

  IconData _getSearchIcon() {
    switch (_currentSearchType) {
      case 'barcode':
        return Icons.qr_code;
      case 'imei':
        return Icons.qr_code_2;
      case 'text':
      default:
        return Icons.search;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    switch (_currentSearchType) {
      case 'barcode':
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
          LengthLimitingTextInputFormatter(50),
        ];
      case 'imei':
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(16),
        ];
      case 'text':
      default:
        return [LengthLimitingTextInputFormatter(100)];
    }
  }

  Widget _buildBarcodeSearchTab() {
    return _buildSearchResultsView(
      emptyMessage: 'Enter or scan a barcode to find products',
      searchType: 'Barcode',
    );
  }

  Widget _buildImeiSearchTab() {
    return _buildSearchResultsView(
      emptyMessage: 'Enter or scan an IMEI to find products',
      searchType: 'IMEI',
    );
  }

  Widget _buildTextSearchTab() {
    return _buildSearchResultsView(
      emptyMessage: 'Enter product name, SKU, or description to search',
      searchType: 'Text',
    );
  }

  Widget _buildSearchResultsView({
    required String emptyMessage,
    required String searchType,
  }) {
    if (_isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching products...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Search Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[700]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _clearResults,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_singleResult != null) {
      return _buildSingleProductResult(_singleResult!);
    }

    if (_searchResults.isNotEmpty) {
      return _buildProductList(_searchResults);
    }

    return _buildEmptyState(emptyMessage);
  }

  Widget _buildSingleProductResult(Product product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green[600],
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Product Found',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              _buildProductDetails(product),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToProduct(product),
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Product Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductList(List<Product> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: Icon(
                Icons.inventory_2,
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SKU: ${product.sku}'),
                if (product.salePrice != null)
                  Text('Price: ${product.salePrice!.toInt()}'),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _navigateToProduct(product),
          ),
        );
      },
    );
  }

  Widget _buildProductDetails(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildDetailRow('SKU', product.sku),
        _buildDetailRow('Barcode', product.barcode),
        if (product.salePrice != null)
          _buildDetailRow('Sale Price', '${product.salePrice!.toInt()}'),
        _buildDetailRow('Purchase Price', '${product.purchasePrice?.toInt() ?? 0}'),
        _buildDetailRow('Quantity', '${product.quantity}'),
        if (product.categoryName != null)
          _buildDetailRow('Category', product.categoryName!),
        if (product.storeName != null)
          _buildDetailRow('Store', product.storeName!),
        _buildDetailRow('IMEI Support', product.isImei ? 'Yes' : 'No'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getSearchIcon(),
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Start Searching',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (_searchHistory.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSearchHistory(),
          ],
          if (_recentResults.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildRecentResults(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchHistory() {
    return Column(
      children: [
        Text(
          'Recent Searches',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _searchHistory.take(5).map((query) {
            return ActionChip(
              label: Text(query),
              onPressed: () {
                _searchController.text = query;
                _performSearch(query);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentResults() {
    return Column(
      children: [
        Text(
          'Recently Found',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...(_recentResults.take(3).map((product) {
          return ListTile(
            leading: const Icon(Icons.inventory_2),
            title: Text(product.name),
            subtitle: Text('SKU: ${product.sku}'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _navigateToProduct(product),
          );
        })),
      ],
    );
  }
}