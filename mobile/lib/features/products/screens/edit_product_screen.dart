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
      Product updatedProduct;

      // Use different endpoints based on whether this is an IMEI product with IMEIs
      if (formData.isImei && formData.imeis.isNotEmpty) {
        // Use the new updateProductWithImeis endpoint for IMEI products with IMEIs
        final request = UpdateProductWithImeisRequest(
          name: formData.productName,
          categoryId: formData.categoryId,
          sku: formData.sku,
          purchasePrice: formData.purchasePrice,
          salePrice: formData.salePrice,
          imeis: formData.imeis,
        );

        updatedProduct = await _productService.updateProductWithImeis(
            widget.productId, request);
      } else {
        // Use regular update for non-IMEI products or IMEI products without IMEIs
        final request = UpdateProductRequest(
          name: formData.productName,
          categoryId: formData.categoryId,
          sku: formData.sku,
          isImei: formData.isImei,
          quantity: formData.quantity,
          purchasePrice: formData.purchasePrice,
          salePrice: formData.salePrice,
        );

        updatedProduct =
            await _productService.updateProduct(widget.productId, request);
      }

      // Success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Product "${updatedProduct.name}" updated successfully!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                AppRouter.goToProductDetail(context, updatedProduct.id);
              },
            ),
          ),
        );

        // Navigate to product detail screen to show updated product
        AppRouter.goToProductDetail(context, updatedProduct.id);
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
