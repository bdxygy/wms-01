import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wms_mobile/core/utils/number_utils.dart';

import '../../../core/models/product.dart';
import '../../../core/models/user.dart';
import '../../../core/models/store.dart';
import '../../../core/models/category.dart';
import '../../../core/services/product_service.dart';
import '../../../core/services/store_service.dart';
import '../../../core/services/category_service.dart';
import '../../../core/services/print_launcher.dart';
import '../../../core/widgets/wms_app_bar.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/widgets/loading.dart';
import '../../../core/widgets/barcode_quantity_dialog.dart';
import '../../../core/routing/app_router.dart';
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
  final PrintLauncher _printLauncher = PrintLauncher();

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
          category =
              await _categoryService.getCategoryById(product.categoryId!);
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

  void _printBarcode() async {
    if (_product == null) return;

    try {
      // Show barcode quantity dialog
      final quantity = await showDialog<int>(
        context: context,
        builder: (context) => BarcodeQuantityDialog(
          title: 'Print Barcode',
          subtitle: _product!.name,
          defaultQuantity: 1,
        ),
      );

      // Guard clause: User cancelled dialog
      if (quantity == null) return;

      // Guard clause: Check if still mounted
      if (!mounted) return;

      // Get current user for printing context
      final user = context.read<AuthProvider>().user;

      // Use the comprehensive connect and print method with quantity
      final result = await _printLauncher.connectAndPrint(
        context,
        product: _product!,
        quantity: quantity,
        store: _store,
        user: user,
      );

      if (result && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(quantity == 1
                ? 'Barcode printed successfully!'
                : '$quantity barcodes printed successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString();

        // Check if it's a permission issue
        if (errorMessage.contains('permission') ||
            errorMessage.contains('Nearby devices') ||
            errorMessage.contains('Bluetooth')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Permission required: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () =>
                    _printLauncher.showPermissionSettingsDialog(context),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to print barcode: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              action: SnackBarAction(
                label: 'Setup Printer',
                onPressed: () => _printLauncher.connectAndPrint(context),
              ),
            ),
          );
        }
      }
    }
  }

  void _testPrinter() async {
    try {
      // Use the comprehensive connect and print method (no product = test page)
      final result = await _printLauncher.connectAndPrint(context);

      if (result && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test page printed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test print failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _managePrinter() async {
    try {
      final isConnected = await _printLauncher.isConnected;

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Printer Management'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: ${isConnected ? 'Connected' : 'Disconnected'}'),
              const SizedBox(height: 16),
              const Text('Available Actions:'),
              const SizedBox(height: 8),
              if (!isConnected)
                ListTile(
                  leading: const Icon(Icons.bluetooth_connected),
                  title: const Text('Connect to Printer'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _printLauncher.connectWithDialog(context);
                  },
                ),
              if (isConnected) ...[
                ListTile(
                  leading: const Icon(Icons.print),
                  title: const Text('Print Test Page'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _testPrinter();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bluetooth_disabled),
                  title: const Text('Disconnect'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _printLauncher.disconnect();

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Printer disconnected'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accessing printer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareProduct() {
    final productInfo = '''Product Details:
Name: ${_product!.name}
SKU: ${_product!.sku}
Barcode: ${_product!.barcode}
Price: ${Provider.of<AppProvider>(context, listen: false).formatCurrency(_product!.salePrice ?? _product!.purchasePrice)}
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only owners can delete products'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
            'Are you sure you want to delete "${_product!.name}"? This action cannot be undone.'),
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
        await _productService.deleteProduct(widget.productId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Product "${_product!.name}" deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to products list
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete product: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final canEdit = user?.canCreateProducts == true;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildWMSAppBar(context, canEdit, user),
      body: _buildBody(user),
      floatingActionButton:
          _product != null ? _buildFloatingActionButton(canEdit) : null,
    );
  }

  PreferredSizeWidget _buildWMSAppBar(
      BuildContext context, bool canEdit, User? user) {
    // Guard clause: Check if user can access print functionality
    final canPrint = user?.role != UserRole.cashier && _product != null;
    
    return WMSAppBar(
      icon: Icons.inventory_2,
      title: _product?.name ?? 'Product Details',
      badge: _product?.isImei == true 
        ? WMSAppBarBadge.imei(Theme.of(context))
        : null,
      shareConfig: _product != null 
        ? WMSAppBarShare(onShare: _shareProduct)
        : null,
      printConfig: canPrint 
        ? WMSAppBarPrint.barcode(
            onPrint: _printBarcode,
            onManagePrinter: _managePrinter,
          )
        : null,
      menuItems: user?.role == UserRole.owner && _product != null 
        ? [
            WMSAppBarMenuItem.delete(
              onTap: _deleteProduct,
              title: 'Delete Product',
            ),
          ]
        : null,
    );
  }

  Widget? _buildFloatingActionButton(bool canEdit) {
    // Guard clause: Only show edit FAB if user can edit
    if (!canEdit) return null;

    return FloatingActionButton(
      onPressed: _editProduct,
      backgroundColor: Theme.of(context).primaryColor,
      child: const Icon(Icons.edit, color: Colors.white),
    );
  }

  Widget _buildBody(User? user) {
    // Guard clause: Show loading state
    if (_isLoading) {
      return const Center(child: WMSLoadingIndicator());
    }

    // Guard clause: Show error state
    if (_error != null) {
      return _buildErrorState();
    }

    // Guard clause: Product not found
    if (_product == null) {
      return _buildNotFoundState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero product card
          _buildHeroCard(user),
          const SizedBox(height: 16),

          // Pricing and inventory section
          _buildPricingInventorySection(),
          const SizedBox(height: 16),

          // Store and category section
          _buildStoreCategorySection(),

          // IMEI Management for IMEI products
          if (_product!.isImei) ...[
            const SizedBox(height: 16),
            _buildImeiManagementCard(),
          ],

          const SizedBox(height: 16),
          _buildAdditionalInfoSection(),

          // Add bottom padding for FAB
          const SizedBox(height: 80),
        ],
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to Load Product',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadProduct,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Product Not Found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'The product you\'re looking for doesn\'t exist or has been removed.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(User? user) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
            Theme.of(context).primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name and status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _product!.name,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStatusChip(),
                        if (_product!.isImei) ...[
                          const SizedBox(width: 8),
                          _buildImeiChip(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Only show print button for non-cashier roles
              if (user?.role != UserRole.cashier) _buildPrintButton(),
            ],
          ),

          // Product description (if available)
          if (_product!.description != null &&
              _product!.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surface
                    .withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _product!.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Key information grid
          Row(
            children: [
              Expanded(
                child: _buildHeroInfoItem(
                  'SKU',
                  _product!.sku.isNotEmpty ? _product!.sku : 'Not set',
                  Icons.qr_code,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildHeroInfoItem(
                  'Barcode',
                  _product!.barcode.isNotEmpty ? _product!.barcode : 'Not set',
                  Icons.barcode_reader,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    final isActive = _product!.deletedAt == null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isActive ? Colors.green[700] : Colors.red[700],
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildImeiChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.smartphone,
            size: 12,
            color: Colors.orange[700],
          ),
          const SizedBox(width: 4),
          Text(
            'IMEI',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrintButton() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: _printBarcode,
        icon: Icon(
          Icons.print,
          color: Theme.of(context).primaryColor,
        ),
        tooltip: 'Print Barcode',
      ),
    );
  }

  Widget _buildHeroInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingInventorySection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Pricing & Inventory',
            'Product pricing and stock information',
            Icons.attach_money,
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              _buildPriceCard(
                'Purchase Price',
                Provider.of<AppProvider>(context, listen: false)
                    .formatCurrency(_product!.purchasePrice),
                Icons.shopping_cart_outlined,
                Colors.blue,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              _buildPriceCard(
                'Sale Price',
                _product!.salePrice != null
                    ? Provider.of<AppProvider>(context, listen: false)
                        .formatCurrency(_product!.salePrice!)
                    : 'Not set',
                Icons.sell_outlined,
                Colors.green,
              )
            ],
          ),

          const SizedBox(height: 16),

          // Inventory information
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuantityInfo(),
                ),
                const SizedBox(width: 16),
                _buildStockStatusIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Stock',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '${NumberUtils.formatWithDots(_product!.quantity)} units',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildStockStatusIndicator() {
    final quantity = _product!.quantity;
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (quantity == 0) {
      statusColor = Colors.red;
      statusText = 'Out of Stock';
      statusIcon = Icons.error_outline;
    } else if (quantity < 10) {
      statusColor = Colors.orange;
      statusText = 'Low Stock';
      statusIcon = Icons.warning_outlined;
    } else {
      statusColor = Colors.green;
      statusText = 'In Stock';
      statusIcon = Icons.check_circle_outline;
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            statusIcon,
            color: statusColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          statusText,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStoreCategorySection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Location & Category',
            'Store location and product categorization',
            Icons.store,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildLocationInfoCard(
                  'Store',
                  _store?.name ?? 'Loading...',
                  Icons.store_outlined,
                  Theme.of(context).primaryColor,
                ),
              ),
              if (_product!.categoryId != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildLocationInfoCard(
                    'Category',
                    _category?.name ?? 'Loading...',
                    Icons.category_outlined,
                    Colors.purple,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfoCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildImeiManagementCard() {
    return ImeiManagementSection(
      productId: _product!.id,
      productName: _product!.name,
      expectedQuantity: _product!.quantity,
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Additional Information',
            'System information and timestamps',
            Icons.info_outlined,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoRow('Created', _formatDateTime(_product!.createdAt)),
                const SizedBox(height: 12),
                _buildInfoRow(
                    'Last Updated', _formatDateTime(_product!.updatedAt)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
