import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/models/api_requests.dart';
import '../../../core/models/product.dart';
import '../../../core/services/product_service.dart';
import '../../../core/widgets/cards.dart';
import '../../../core/widgets/loading.dart';
import '../../../core/validators/transaction_validators.dart';

class TransactionItemManager extends StatefulWidget {
  final List<TransactionItemRequest> items;
  final String storeId;
  final Function(List<TransactionItemRequest>) onItemsChanged;

  const TransactionItemManager({
    super.key,
    required this.items,
    required this.storeId,
    required this.onItemsChanged,
  });

  @override
  State<TransactionItemManager> createState() => _TransactionItemManagerState();
}

class _TransactionItemManagerState extends State<TransactionItemManager> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Product> _searchResults = [];
  bool _isSearching = false;
  bool _showSearchResults = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchProducts(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showSearchResults = true;
    });

    try {
      final response = await _productService.getProducts(
        search: query.trim(),
        storeId: widget.storeId,
        limit: 20,
      );
      
      setState(() {
        _searchResults = response.data;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to search products: $e')),
        );
      }
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _addProductToTransaction(Product product) {
    // Check if product already exists in transaction
    final existingItemIndex = widget.items.indexWhere(
      (item) => item.productId == product.id,
    );

    if (existingItemIndex >= 0) {
      // Increment quantity of existing item
      final existingItem = widget.items[existingItemIndex];
      final updatedItem = TransactionItemRequest(
        productId: existingItem.productId,
        quantity: existingItem.quantity + 1,
        price: existingItem.price,
      );
      
      final updatedItems = [...widget.items];
      updatedItems[existingItemIndex] = updatedItem;
      widget.onItemsChanged(updatedItems);
    } else {
      // Add new item
      final newItem = TransactionItemRequest(
        productId: product.id,
        quantity: 1,
        price: product.salePrice ?? product.purchasePrice,
      );
      
      widget.onItemsChanged([...widget.items, newItem]);
    }

    // Clear search
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _showSearchResults = false;
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to transaction'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _removeItem(int index) {
    final updatedItems = [...widget.items];
    updatedItems.removeAt(index);
    widget.onItemsChanged(updatedItems);
  }

  void _updateItemQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeItem(index);
      return;
    }

    final item = widget.items[index];
    final updatedItem = TransactionItemRequest(
      productId: item.productId,
      quantity: newQuantity,
      price: item.price,
    );
    
    final updatedItems = [...widget.items];
    updatedItems[index] = updatedItem;
    widget.onItemsChanged(updatedItems);
  }

  void _updateItemPrice(int index, double newPrice) {
    final item = widget.items[index];
    final updatedItem = TransactionItemRequest(
      productId: item.productId,
      quantity: item.quantity,
      price: newPrice,
    );
    
    final updatedItems = [...widget.items];
    updatedItems[index] = updatedItem;
    widget.onItemsChanged(updatedItems);
  }

  void _openBarcodeScanner() {
    // TODO: Implement barcode scanning navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Barcode scanning will be implemented in the next phase'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _openImeiScanner() {
    // TODO: Implement IMEI scanning navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('IMEI scanning will be implemented in the next phase'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and scan controls
        _buildSearchControls(),
        
        // Search results or item list
        Expanded(
          child: _showSearchResults ? _buildSearchResults() : _buildItemList(),
        ),
        
        // Total summary
        if (widget.items.isNotEmpty) _buildTotalSummary(),
      ],
    );
  }

  Widget _buildSearchControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search products by name, SKU, or barcode...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults = [];
                          _showSearchResults = false;
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              _searchProducts(value);
            },
          ),
          const SizedBox(height: 12),
          
          // Scan buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openBarcodeScanner,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan Barcode'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openImeiScanner,
                  icon: const Icon(Icons.device_hub),
                  label: const Text('Scan IMEI'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: WMSLoadingIndicator());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        return _SearchResultCard(
          product: product,
          onTap: () => _addProductToTransaction(product),
        );
      },
    );
  }

  Widget _buildItemList() {
    if (widget.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No items added',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Search and add products to the transaction',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        return _TransactionItemCard(
          item: item,
          index: index,
          onQuantityChanged: (newQuantity) => _updateItemQuantity(index, newQuantity),
          onPriceChanged: (newPrice) => _updateItemPrice(index, newPrice),
          onRemove: () => _removeItem(index),
        );
      },
    );
  }

  Widget _buildTotalSummary() {
    final total = widget.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final itemCount = widget.items.fold(0, (sum, item) => sum + item.quantity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$itemCount items',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '\$${total.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return WMSCard(
      margin: const EdgeInsets.only(bottom: 8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                  const SizedBox(height: 4),
                  Text(
                    '\$${(product.salePrice ?? product.purchasePrice).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: product.quantity > 0 ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Stock: ${product.quantity}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: product.quantity > 0 ? Colors.green[700] : Colors.red[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.add_circle_outline, color: Colors.green),
          ],
        ),
      ),
    );
  }
}

class _TransactionItemCard extends StatefulWidget {
  final TransactionItemRequest item;
  final int index;
  final Function(int) onQuantityChanged;
  final Function(double) onPriceChanged;
  final VoidCallback onRemove;

  const _TransactionItemCard({
    required this.item,
    required this.index,
    required this.onQuantityChanged,
    required this.onPriceChanged,
    required this.onRemove,
  });

  @override
  State<_TransactionItemCard> createState() => _TransactionItemCardState();
}

class _TransactionItemCardState extends State<_TransactionItemCard> {
  late TextEditingController _quantityController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: widget.item.quantity.toString());
    _priceController = TextEditingController(text: widget.item.price.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WMSCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product ID: ${widget.item.productId}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Subtotal: \$${(widget.item.price * widget.item.quantity).toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Remove item',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Quantity input
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: TransactionValidators.validateItemQuantity,
                    onChanged: (value) {
                      final quantity = int.tryParse(value);
                      if (quantity != null && quantity > 0) {
                        widget.onQuantityChanged(quantity);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Price input
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                      isDense: true,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: TransactionValidators.validateItemPrice,
                    onChanged: (value) {
                      final price = double.tryParse(value);
                      if (price != null && price >= 0) {
                        widget.onPriceChanged(price);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}