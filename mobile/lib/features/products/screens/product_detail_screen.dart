import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/models/product.dart';
import '../../../core/models/user.dart';
import '../../../core/models/store.dart';
import '../../../core/models/category.dart';
import '../../../core/services/product_service.dart';
import '../../../core/services/store_service.dart';
import '../../../core/services/category_service.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/widgets/loading.dart';
import '../../../core/widgets/app_bars.dart';
import '../../../core/widgets/cards.dart';
import '../../../core/routing/app_router.dart';
import '../../../generated/app_localizations.dart';
import '../widgets/imei_management_section.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductService _productService = ProductService();
  final StoreService _storeService = StoreService();
  final CategoryService _categoryService = CategoryService();
  
  Product? _product;
  Store? _store;
  Category? _category;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final product = await _productService.getProductById(widget.productId);
      
      // Load store details
      Store? store;
      try {
        store = await _storeService.getStoreById(product.storeId);
      } catch (e) {
        debugPrint('Failed to load store: $e');
      }
      
      // Load category details if category exists
      Category? category;
      if (product.categoryId != null) {
        try {
          category = await _categoryService.getCategoryById(product.categoryId!);
        } catch (e) {
          debugPrint('Failed to load category: $e');
        }
      }
      
      setState(() {
        _product = product;
        _store = store;
        _category = category;
      });
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

  void _editProduct() {
    AppRouter.goToEditProduct(context, widget.productId);
  }

  void _printBarcode() {
    // TODO: Implement barcode printing in Phase 17
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Print Barcode ready - Thermal printing in Phase 17'),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void _shareProduct() {
    final productInfo = '''Product Details:
Name: ${_product!.name}
SKU: ${_product!.sku}
Barcode: ${_product!.barcode}
Price: \$${(_product!.salePrice ?? _product!.purchasePrice).toStringAsFixed(2)}
Quantity: ${_product!.quantity}''';
    
    Clipboard.setData(ClipboardData(text: productInfo));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product information copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteProduct() async {
    final user = context.read<AuthProvider>().user;
    if (user?.role != UserRole.owner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only owners can delete products'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${_product!.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        // TODO: Implement delete product API call when available
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product deletion will be implemented when API is available'),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthProvider>().user;
    final canEdit = user?.canCreateProducts == true;

    return Scaffold(
      appBar: WMSAppBar(
        title: _product?.name ?? l10n.details,
        actions: [
          if (canEdit && _product != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editProduct,
            ),
          if (_product != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'print':
                    _printBarcode();
                    break;
                  case 'share':
                    _shareProduct();
                    break;
                  case 'delete':
                    _deleteProduct();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'print',
                  child: Row(
                    children: [
                      Icon(Icons.print),
                      SizedBox(width: 8),
                      Text('Print Barcode'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 8),
                      Text('Share Product'),
                    ],
                  ),
                ),
                if (user?.role == UserRole.owner)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Product', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: WMSLoadingIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                'Failed to load product',
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
                onPressed: _loadProduct,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_product == null) {
      return const Center(
        child: Text('Product not found'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicInfo(),
          const SizedBox(height: 16),
          _buildPricingInfo(),
          const SizedBox(height: 16),
          _buildInventoryInfo(),
          
          // IMEI Management for IMEI products
          if (_product!.isImei) ...[
            const SizedBox(height: 16),
            ImeiManagementSection(
              productId: _product!.id,
              productName: _product!.name,
              expectedQuantity: _product!.quantity,
            ),
          ],
          
          const SizedBox(height: 16),
          _buildStoreInfo(),
          const SizedBox(height: 16),
          _buildAdditionalInfo(),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return WMSCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', _product!.name),
            if (_product!.sku.isNotEmpty) _buildInfoRow('SKU', _product!.sku),
            if (_product!.barcode.isNotEmpty) _buildInfoRow('Barcode', _product!.barcode),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingInfo() {
    return WMSCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pricing Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Purchase Price', '\$${_product!.purchasePrice.toStringAsFixed(2)}'),
            if (_product!.salePrice != null)
              _buildInfoRow('Sale Price', '\$${_product!.salePrice!.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryInfo() {
    return WMSCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inventory Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Quantity', '${_product!.quantity}'),
            _buildInfoRow('IMEI Tracked', _product!.isImei ? 'Yes' : 'No'),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreInfo() {
    return WMSCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Store & Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Store', _store?.name ?? 'Loading...'),
            if (_product!.categoryId != null)
              _buildInfoRow('Category', _category?.name ?? 'Loading...'),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return WMSCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Created', _formatDateTime(_product!.createdAt)),
            _buildInfoRow('Updated', _formatDateTime(_product!.updatedAt)),
            _buildInfoRow('Status', _product!.deletedAt != null ? 'Deleted' : 'Active'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final user = context.watch<AuthProvider>().user;
    final canEdit = user?.canCreateProducts == true;
    final isOwner = user?.role == UserRole.owner;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        children: [
        if (canEdit) ...[ 
          Expanded(
            child: OutlinedButton(
              onPressed: _editProduct,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Edit',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: OutlinedButton(
            onPressed: _printBarcode,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.print, size: 18),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Print',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: _shareProduct,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.share, size: 18),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Share',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isOwner) ...[ 
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: _deleteProduct,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.1),
            ),
            child: const Icon(Icons.delete, color: Colors.red, size: 18),
          ),
        ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}