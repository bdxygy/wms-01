import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../generated/app_localizations.dart';

class BarcodeQuantityDialog extends StatefulWidget {
  final String title;
  final String? subtitle;
  final int defaultQuantity;

  const BarcodeQuantityDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.defaultQuantity = 1,
  });

  @override
  State<BarcodeQuantityDialog> createState() => _BarcodeQuantityDialogState();
}

class _BarcodeQuantityDialogState extends State<BarcodeQuantityDialog>
    with TickerProviderStateMixin {
  late TextEditingController _quantityController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  int _currentQuantity = 1;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.defaultQuantity;
    _quantityController = TextEditingController(text: _currentQuantity.toString());
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    ));
    
    _scaleController.forward();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _updateQuantity(int quantity) {
    if (quantity < 1) {
      quantity = 1;
    }

    setState(() {
      _currentQuantity = quantity;
      _quantityController.text = quantity.toString();
      _errorMessage = null;
    });
  }

  void _incrementQuantity() {
    _updateQuantity(_currentQuantity + 1);
  }

  void _decrementQuantity() {
    _updateQuantity(_currentQuantity - 1);
  }

  void _onQuantityChanged(String value) {
    final l10n = AppLocalizations.of(context)!;
    
    if (value.isEmpty) {
      setState(() {
        _errorMessage = null;
      });
      return;
    }

    final quantity = int.tryParse(value);
    if (quantity == null) {
      setState(() {
        _errorMessage = l10n.barcode_quantity_invalid_number;
      });
      return;
    }

    if (quantity < 1) {
      setState(() {
        _errorMessage = l10n.barcode_quantity_minimum_error;
      });
      return;
    }

    // No maximum limit validation - removed

    setState(() {
      _currentQuantity = quantity;
      _errorMessage = null;
    });
  }

  void _confirmPrint() {
    // Guard clause: Check if quantity is valid
    if (_currentQuantity < 1) {
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _errorMessage = l10n.barcode_quantity_minimum_error;
      });
      return;
    }
    
    // No maximum limit validation - removed

    // Close dialog and return quantity
    Navigator.of(context).pop(_currentQuantity);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  _buildContent(),
                  _buildActions(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.print_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Instructions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[700],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.barcode_quantity_instructions,
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quantity input section
          Text(
            l10n.barcode_quantity_label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quantity controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decrement button
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _currentQuantity > 1 ? _decrementQuantity : null,
                  icon: Icon(
                    Icons.remove,
                    color: _currentQuantity > 1 
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Quantity input field
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _quantityController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    errorText: _errorMessage,
                  ),
                  onChanged: _onQuantityChanged,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Increment button
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _incrementQuantity,
                  icon: Icon(
                    Icons.add,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Quick quantity buttons
          Wrap(
            spacing: 8,
            children: [1, 5, 10, 20].map((quantity) {
              final isSelected = _currentQuantity == quantity;
              return FilterChip(
                label: Text(quantity.toString()),
                selected: isSelected,
                onSelected: (selected) => _updateQuantity(quantity),
                backgroundColor: isSelected 
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                  : null,
                selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: isSelected 
                    ? Theme.of(context).primaryColor
                    : null,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 8),
          
          // Range info
          Text(
            l10n.barcode_quantity_minimum_info,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 18),
            label: Text(l10n.common_button_cancel),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _errorMessage == null ? _confirmPrint : null,
            icon: const Icon(Icons.print, size: 18),
            label: Text(l10n.barcode_quantity_print_button(_currentQuantity)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}