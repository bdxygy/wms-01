import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/imei_scanner_service.dart';
import '../../../core/utils/imei_utils.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/models/product.dart';

/// Widget for quick IMEI-based product search in transaction workflows
class ImeiProductSearchWidget extends StatefulWidget {
  final Function(Product) onProductSelected;
  final Function(String)? onImeiEntered;
  final String? hintText;
  final bool showScanButton;
  final bool autoFocus;

  const ImeiProductSearchWidget({
    super.key,
    required this.onProductSelected,
    this.onImeiEntered,
    this.hintText,
    this.showScanButton = true,
    this.autoFocus = false,
  });

  @override
  State<ImeiProductSearchWidget> createState() => _ImeiProductSearchWidgetState();
}

class _ImeiProductSearchWidgetState extends State<ImeiProductSearchWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ImeiScannerService _imeiScannerService = ImeiScannerService();
  
  bool _isSearching = false;
  ImeiValidationResult? _validationResult;
  Product? _foundProduct;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onImeiChanged(String value) {
    setState(() {
      _validationResult = ImeiUtils.validateInput(value);
      _foundProduct = null;
      _searchError = null;
    });

    // Auto-search when IMEI is valid and complete
    if (_validationResult?.canProceed == true) {
      _searchProductByImei(value);
    }

    widget.onImeiEntered?.call(value);
  }

  Future<void> _searchProductByImei(String imei) async {
    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final result = await _imeiScannerService.searchProductByImei(imei);
      
      setState(() {
        if (result.hasProduct) {
          _foundProduct = result.product;
          _searchError = null;
        } else if (result.hasError) {
          _foundProduct = null;
          _searchError = result.errorMessage;
        } else {
          _foundProduct = null;
          _searchError = 'No product found with this IMEI';
        }
        _isSearching = false;
      });

      // Auto-select product if found
      if (_foundProduct != null) {
        widget.onProductSelected(_foundProduct!);
      }
    } catch (e) {
      setState(() {
        _foundProduct = null;
        _searchError = 'Search failed: $e';
        _isSearching = false;
      });
    }
  }

  void _openImeiScanner() {
    AppRouter.goToImeiScanner(
      context,
      title: 'Scan IMEI to Find Product',
      subtitle: 'Position IMEI within the frame',
      onProductFound: (product) {
        setState(() {
          _controller.text = (product as Product).name; // Or display IMEI if available
          _foundProduct = product;
          _searchError = null;
        });
        widget.onProductSelected(product);
      },
      onImeiScanned: (result) {
        final imeiResult = result as ImeiScanResult;
        if (imeiResult.isValid) {
          setState(() {
            _controller.text = imeiResult.imeiInfo.cleanedImei;
          });
          _onImeiChanged(imeiResult.imeiInfo.cleanedImei);
        }
      },
      autoSearchProduct: true,
      autoClose: true,
    );
  }

  void _clearSearch() {
    setState(() {
      _controller.clear();
      _validationResult = null;
      _foundProduct = null;
      _searchError = null;
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // IMEI Input Field
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: 'IMEI Number',
            hintText: widget.hintText ?? 'Enter or scan IMEI to find product',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.qr_code_2),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Validation indicator
                if (_validationResult?.isValid == true)
                  const Icon(Icons.check_circle, color: Colors.green)
                else if (_validationResult?.canProceed == false)
                  const Icon(Icons.error, color: Colors.red)
                else if (_isSearching)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                
                // Clear button
                if (_controller.text.isNotEmpty)
                  IconButton(
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.clear),
                  ),
                
                // Scan button
                if (widget.showScanButton)
                  IconButton(
                    onPressed: _openImeiScanner,
                    icon: const Icon(Icons.qr_code_scanner),
                    tooltip: 'Scan IMEI',
                  ),
              ],
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
          ],
          onChanged: _onImeiChanged,
          onSubmitted: (value) {
            if (_validationResult?.canProceed == true) {
              _searchProductByImei(value);
            }
          },
        ),
        
        const SizedBox(height: 8),
        
        // Validation message
        if (_validationResult != null) ...[
          Text(
            _validationResult!.message,
            style: TextStyle(
              color: _validationResult!.isValid 
                  ? Colors.green 
                  : _validationResult!.canProceed 
                      ? Colors.orange 
                      : Colors.red,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        // Search results
        if (_foundProduct != null) ...[
          _buildProductResult(_foundProduct!),
        ] else if (_searchError != null) ...[
          _buildErrorResult(_searchError!),
        ],
      ],
    );
  }

  Widget _buildProductResult(Product product) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green[700],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product Found',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  'SKU: ${product.sku}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (product.salePrice != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Price: ${product.salePrice!.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => widget.onProductSelected(product),
            icon: const Icon(Icons.arrow_forward_ios),
            tooltip: 'Select Product',
          ),
        ],
      ),
    );
  }

  Widget _buildErrorResult(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.orange[700],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search Result',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  error,
                  style: TextStyle(color: Colors.orange[800]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact version for use in forms and smaller spaces
class CompactImeiSearchField extends StatefulWidget {
  final Function(Product) onProductSelected;
  final String? initialValue;
  final String? labelText;
  final String? hintText;

  const CompactImeiSearchField({
    super.key,
    required this.onProductSelected,
    this.initialValue,
    this.labelText,
    this.hintText,
  });

  @override
  State<CompactImeiSearchField> createState() => _CompactImeiSearchFieldState();
}

class _CompactImeiSearchFieldState extends State<CompactImeiSearchField> {
  final TextEditingController _controller = TextEditingController();
  final ImeiScannerService _imeiScannerService = ImeiScannerService();
  
  bool _isSearching = false;
  Product? _selectedProduct;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _searchAndSelect(String imei) async {
    if (!ImeiUtils.isValidImei(imei)) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final result = await _imeiScannerService.searchProductByImei(imei);
      
      if (result.hasProduct) {
        setState(() {
          _selectedProduct = result.product;
          _isSearching = false;
        });
        widget.onProductSelected(result.product!);
      } else {
        setState(() {
          _selectedProduct = null;
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _selectedProduct = null;
        _isSearching = false;
      });
    }
  }

  void _openScanner() {
    AppRouter.goToImeiScanner(
      context,
      title: 'Scan IMEI',
      onImeiScanned: (result) {
        final imeiResult = result as ImeiScanResult;
        if (imeiResult.isValid) {
          setState(() {
            _controller.text = imeiResult.imeiInfo.cleanedImei;
          });
          _searchAndSelect(imeiResult.imeiInfo.cleanedImei);
        }
      },
      autoClose: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.labelText ?? 'IMEI',
        hintText: widget.hintText ?? 'Enter IMEI number',
        border: const OutlineInputBorder(),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isSearching)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (_selectedProduct != null)
              const Icon(Icons.check, color: Colors.green),
            
            IconButton(
              onPressed: _openScanner,
              icon: const Icon(Icons.qr_code_scanner),
              tooltip: 'Scan IMEI',
            ),
          ],
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(16),
      ],
      onChanged: (value) {
        if (ImeiUtils.isValidImei(value)) {
          _searchAndSelect(value);
        } else {
          setState(() {
            _selectedProduct = null;
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an IMEI';
        }
        if (!ImeiUtils.isValidImei(value)) {
          return 'Invalid IMEI format';
        }
        return null;
      },
    );
  }
}