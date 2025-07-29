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

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final ProductService _productService = ProductService();

  Future<void> _createProduct(ProductFormData formData) async {
    final authProvider = context.read<AuthProvider>();
    
    // Validate permissions
    if (!authProvider.canCreateProducts) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have permission to create products'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Choose appropriate endpoint based on whether IMEIs are provided
      final Product product;
      
      if (formData.isImei && formData.imeis.isNotEmpty) {
        // Create product with IMEIs using dedicated endpoint
        final request = CreateProductWithImeisRequest(
          name: formData.productName,
          description: formData.description,
          storeId: formData.storeId,
          categoryId: formData.categoryId,
          sku: formData.sku,
          barcode: '', // Backend generates this
          quantity: formData.quantity,
          purchasePrice: formData.purchasePrice,
          salePrice: formData.salePrice,
          imeis: formData.imeis,
        );
        
        product = await _productService.createProductWithImeis(request);
      } else {
        // Create regular product
        final request = CreateProductRequest(
          name: formData.productName,
          description: formData.description,
          storeId: formData.storeId,
          categoryId: formData.categoryId,
          sku: formData.sku,
          isImei: formData.isImei,
          isMustCheck: formData.isMustCheck,
          quantity: formData.quantity,
          purchasePrice: formData.purchasePrice,
          salePrice: formData.salePrice,
        );
        
        product = await _productService.createProduct(request);
      }
      
      // Success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product "${product.name}" created successfully!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                AppRouter.goToProductDetail(context, product.id);
              },
            ),
          ),
        );
        
        // Navigate to product detail screen as per business workflow
        AppRouter.goToProductDetail(context, product.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create product: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _cancelCreation() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: WMSAppBar(
        title: l10n.addProduct,
      ),
      body: ProductForm(
        isEditing: false,
        onSave: _createProduct,
        onCancel: _cancelCreation,
      ),
    );
  }
}