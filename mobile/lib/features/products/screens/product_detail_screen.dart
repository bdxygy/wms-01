import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/product.dart';
import '../../../core/services/product_service.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/widgets/loading.dart';
import '../../../core/widgets/app_bars.dart';
import '../../../core/widgets/cards.dart';
import '../../../generated/app_localizations.dart';

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
  
  Product? _product;
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
      setState(() {
        _product = product;
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
    context.pushNamed('edit-product', pathParameters: {'id': widget.productId});
  }

  void _printBarcode() {
    // TODO: Implement barcode printing in Phase 17
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Barcode printing will be implemented in Phase 17'),
      ),
    );
  }

  void _shareProduct() {
    // TODO: Implement product sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product sharing coming soon'),
      ),
    );
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
          if (_product!.isImei) ...[
            const SizedBox(height: 16),
            _buildImeiInfo(),
          ],
          const SizedBox(height: 16),
          _buildAdditionalInfo(),
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

  Widget _buildImeiInfo() {
    return WMSCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'IMEI Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'IMEI management will be implemented in Phase 14',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}