import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_bars.dart';
import '../../../core/services/product_service.dart';
import '../../../core/models/api_requests.dart';
import '../../../core/models/product.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../generated/app_localizations.dart';
import '../widgets/product_form.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;

  const EditProductScreen({
    super.key,
    required this.productId,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final ProductService _productService = ProductService();
  Product? _product;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final product = await _productService.getProductById(widget.productId);
      setState(() {
        _product = product;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load product: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _updateProduct(ProductFormData formData) async {
    final authProvider = context.read<AuthProvider>();
    
    // Validate permissions
    if (!authProvider.canCreateProducts) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have permission to update products'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Create update request with only changed fields (barcode handled by backend)
      final request = UpdateProductRequest(
        name: formData.productName != _product!.name ? formData.productName : null,
        categoryId: formData.categoryId != _product!.categoryId ? formData.categoryId : null,
        sku: formData.sku != _product!.sku ? formData.sku : null,
        isImei: formData.isImei != _product!.isImei ? formData.isImei : null,
        quantity: formData.quantity != _product!.quantity ? formData.quantity : null,
        purchasePrice: formData.purchasePrice != _product!.purchasePrice ? formData.purchasePrice : null,
        salePrice: formData.salePrice != _product!.salePrice ? formData.salePrice : null,
      );
      
      final updatedProduct = await _productService.updateProduct(widget.productId, request);
      
      // Success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product "${updatedProduct.name}" updated successfully!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                AppRouter.goToProductDetail(context, updatedProduct.id);
              },
            ),
          ),
        );
        
        // Navigate back to product detail
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update product: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _cancelEditing() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: WMSAppBar(
          title: '${l10n.edit} Product',
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: WMSAppBar(
          title: '${l10n.edit} Product',
        ),
        body: const Center(
          child: Text('Product not found'),
        ),
      );
    }

    return Scaffold(
      appBar: WMSAppBar(
        title: '${l10n.edit} ${_product!.name}',
      ),
      body: ProductForm(
        initialProduct: _product,
        isEditing: true,
        onSave: _updateProduct,
        onCancel: _cancelEditing,
      ),
    );
  }
}