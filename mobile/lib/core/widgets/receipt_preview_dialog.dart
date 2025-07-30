import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../generated/app_localizations.dart';
import '../services/logo_service.dart';
import '../models/store.dart';
import '../models/user.dart';
import '../providers/app_provider.dart';

/// Dialog for previewing how receipts will look with logo
class ReceiptPreviewDialog extends StatefulWidget {
  final Map<String, dynamic>? transaction;
  final Store? store;
  final User? user;

  const ReceiptPreviewDialog({
    super.key,
    this.transaction,
    this.store,
    this.user,
  });

  @override
  State<ReceiptPreviewDialog> createState() => _ReceiptPreviewDialogState();
}

class _ReceiptPreviewDialogState extends State<ReceiptPreviewDialog> {
  final LogoService _logoService = LogoService();
  String? _logoPath;
  bool _hasLogo = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLogoInfo();
  }

  Future<void> _loadLogoInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final logoPath = await _logoService.getLogoPath();
      final hasLogo = await _logoService.hasLogo();

      if (mounted) {
        setState(() {
          _logoPath = logoPath;
          _hasLogo = hasLogo;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 700),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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
            if (_isLoading) _buildLoadingState(),
            if (!_isLoading) _buildPreview(),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
              Icons.receipt_long_outlined,
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
                  l10n.receipt_preview_title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.receipt_preview_subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildPreview() {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo header (if available)
              if (_hasLogo && _logoPath != null) ...[
                Container(
                  constraints: const BoxConstraints(maxHeight: 80),
                  child: Image.file(
                    File(_logoPath!),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return SizedBox(
                        height: 60,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Store name
              Text(
                widget.store?.name ?? 'Sample Store',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Receipt title based on transaction type
              Text(
                _getReceiptTitle(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Divider
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.grey[300],
              ),
              
              const SizedBox(height: 12),
              
              // Transaction details
              _buildReceiptRow('Type:', _getTransactionType()),
              _buildReceiptRow('Date:', _formatDate()),
              if (widget.user != null)
                _buildReceiptRow('Cashier:', widget.user!.name),
              ..._buildTypeSpecificDetails(),
              
              const SizedBox(height: 12),
              
              // Divider
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.grey[300],
              ),
              
              const SizedBox(height: 12),
              
              // Items
              ..._buildItemsList(),
              
              const SizedBox(height: 12),
              
              // Divider
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.grey[300],
              ),
              
              const SizedBox(height: 12),
              
              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    Provider.of<AppProvider>(context, listen: false).formatCurrency(_calculateTotal()),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // QR Code for transaction verification
              if (_getTransactionId() != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Transaction ID:',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      QrImageView(
                        data: _getTransactionId()!,
                        version: QrVersions.auto,
                        size: 80,
                        gapless: false,
                        dataModuleStyle: const QrDataModuleStyle(
                          color: Colors.black,
                          dataModuleShape: QrDataModuleShape.square,
                        ),
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getTransactionId()!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Footer
              Text(
                _getFooterMessage(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItemsList() {
    final items = widget.transaction?['items'] as List<dynamic>? ?? _getSampleItems();
    
    return items.map<Widget>((item) {
      final productName = item['productName'] ?? 'Sample Product';
      final quantity = item['quantity'] ?? 1;
      final price = (item['price'] as num?)?.toDouble() ?? 10.0;
      final subtotal = quantity * price;

      return Column(
        children: [
          // Product name
          SizedBox(
            width: double.infinity,
            child: Text(
              productName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 2),
          // Quantity and price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$quantity x ${Provider.of<AppProvider>(context, listen: false).formatCurrency(price)}',
                style: const TextStyle(fontSize: 11, color: Colors.black),
              ),
              Text(
                Provider.of<AppProvider>(context, listen: false).formatCurrency(subtotal),
                style: const TextStyle(fontSize: 11, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      );
    }).toList();
  }

  Widget _buildActions() {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 18),
            label: Text(l10n.common_button_cancel),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _getTransactionType() {
    return widget.transaction?['type'] ?? 'SALE';
  }

  String _getReceiptTitle() {
    final transactionType = _getTransactionType().toUpperCase();
    switch (transactionType) {
      case 'SALE':
        return 'SALES RECEIPT';
      case 'TRANSFER':
        return 'TRANSFER RECEIPT';
      case 'TRADE':
        return 'TRADE RECEIPT';
      default:
        return 'RECEIPT';
    }
  }

  String _formatDate() {
    final dateStr = widget.transaction?['createdAt'] ?? DateTime.now().toIso8601String();
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  List<Map<String, dynamic>> _getSampleItems() {
    final transactionType = _getTransactionType().toUpperCase();
    
    switch (transactionType) {
      case 'TRANSFER':
        return [
          {
            'productName': 'Product A (Transfer Item)',
            'quantity': 5,
            'price': 25.00,
          },
          {
            'productName': 'Product B (Transfer Item)',
            'quantity': 3,
            'price': 15.50,
          },
        ];
      case 'TRADE':
        return [
          {
            'productName': 'Trade Item X',
            'quantity': 1,
            'price': 100.00,
          },
          {
            'productName': 'Trade Item Y',
            'quantity': 2,
            'price': 50.00,
          },
        ];
      default: // SALE
        return [
          {
            'productName': 'Sample Product 1',
            'quantity': 2,
            'price': 15.99,
          },
          {
            'productName': 'Sample Product 2',
            'quantity': 1,
            'price': 29.99,
          },
          {
            'productName': 'Sample Product 3',
            'quantity': 3,
            'price': 8.50,
          },
        ];
    }
  }

  List<Widget> _buildTypeSpecificDetails() {
    final transactionType = _getTransactionType().toUpperCase();
    
    switch (transactionType) {
      case 'TRANSFER':
        return [
          _buildReceiptRow('From:', widget.transaction?['from'] ?? 'Store A'),
          _buildReceiptRow('To:', widget.transaction?['to'] ?? 'Store B'),
        ];
      case 'TRADE':
        return [
          _buildReceiptRow('Trade Partner:', widget.transaction?['tradeWith'] ?? widget.transaction?['to'] ?? 'Trade Customer'),
        ];
      default: // SALE
        return [
          _buildReceiptRow('Customer:', widget.transaction?['to'] ?? 'Walk-in Customer'),
        ];
    }
  }

  String _getFooterMessage() {
    final transactionType = _getTransactionType().toUpperCase();
    switch (transactionType) {
      case 'SALE':
        return 'Thank you for your purchase!';
      case 'TRANSFER':
        return 'Transfer completed successfully!';
      case 'TRADE':
        return 'Trade transaction completed!';
      default:
        return 'Transaction completed!';
    }
  }

  double _calculateTotal() {
    final items = widget.transaction?['items'] as List<dynamic>? ?? _getSampleItems();
    return items.fold<double>(0.0, (total, item) {
      final quantity = item['quantity'] ?? 1;
      final price = (item['price'] as num?)?.toDouble() ?? 0.0;
      return total + (quantity * price);
    });
  }

  String? _getTransactionId() {
    return widget.transaction?['id'] ?? 'TXN-${DateTime.now().millisecondsSinceEpoch}';
  }
}