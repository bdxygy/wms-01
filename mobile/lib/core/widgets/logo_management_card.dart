import 'dart:io';
import 'package:flutter/material.dart';

import '../../generated/app_localizations.dart';
import '../services/logo_service.dart';
import '../services/image_picker_service.dart';
import '../models/product.dart';
import '../models/store.dart';
import 'barcode_preview_dialog.dart';
import 'receipt_preview_dialog.dart';

/// Widget for managing receipt header logo in settings
class LogoManagementCard extends StatefulWidget {
  const LogoManagementCard({super.key});

  @override
  State<LogoManagementCard> createState() => _LogoManagementCardState();
}

class _LogoManagementCardState extends State<LogoManagementCard>
    with TickerProviderStateMixin {
  final LogoService _logoService = LogoService();
  final ImagePickerService _imagePickerService = ImagePickerService();
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  String? _logoPath;
  bool _isLoading = false;
  bool _hasLogo = false;
  Map<String, int>? _logoDimensions;
  int? _logoFileSize;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadLogoInfo();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
  }

  Future<void> _loadLogoInfo() async {
    debugPrint('Loading logo info...');
    setState(() {
      _isLoading = true;
    });

    try {
      final logoPath = await _logoService.getLogoPath();
      final hasLogo = await _logoService.hasLogo();
      
      debugPrint('Logo path: $logoPath');
      debugPrint('Has logo: $hasLogo');
      
      Map<String, int>? dimensions;
      int? fileSize;
      
      if (hasLogo) {
        dimensions = await _logoService.getLogoDimensions();
        fileSize = await _logoService.getLogoFileSize();
        debugPrint('Logo dimensions: $dimensions');
        debugPrint('Logo file size: $fileSize');
      }

      if (mounted) {
        setState(() {
          _logoPath = logoPath;
          _hasLogo = hasLogo;
          _logoDimensions = dimensions;
          _logoFileSize = fileSize;
          _isLoading = false;
        });

        debugPrint('UI state updated - hasLogo: $_hasLogo, logoPath: $_logoPath');

        if (hasLogo) {
          debugPrint('Starting fade animation...');
          _fadeController.forward();
        }
      }
    } catch (e) {
      debugPrint('Error loading logo info: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorMessage('Failed to load logo info: $e');
      }
    }
  }

  Future<void> _uploadLogo() async {
    final l10n = AppLocalizations.of(context)!;
    
    try {
      debugPrint('Starting logo upload process...');
      final imageBytes = await _imagePickerService.pickImage(context);
      
      if (imageBytes == null) {
        debugPrint('No image selected or permission denied');
        if (mounted) {
          _showErrorMessage(l10n.logo_upload_error_no_image);
        }
        return;
      }

      debugPrint('Image selected, size: ${imageBytes.length} bytes');

      // Guard clause: Check if still mounted
      if (!mounted) return;

      setState(() {
        _isLoading = true;
      });

      // Validate image
      debugPrint('Validating image...');
      final isValid = await _logoService.isValidImage(imageBytes);
      if (!isValid) {
        debugPrint('Image validation failed');
        setState(() {
          _isLoading = false;
        });
        _showErrorMessage(l10n.logo_upload_error_validation);
        return;
      }

      debugPrint('Image validation passed, saving logo...');
      // Save logo
      final logoPath = await _logoService.saveLogo(imageBytes);
      
      setState(() {
        _isLoading = false;
      });
      
      if (logoPath != null) {
        debugPrint('Logo saved successfully at: $logoPath');
        await _loadLogoInfo();
        _showSuccessMessage(l10n.logo_upload_success);
      } else {
        debugPrint('Failed to save logo - logoPath is null');
        _showErrorMessage(l10n.logo_upload_error_save);
      }
    } catch (e) {
      debugPrint('Error in logo upload: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorMessage('Failed to upload logo: $e');
      }
    }
  }

  Future<void> _deleteLogo() async {
    final l10n = AppLocalizations.of(context)!;
    
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logo_delete_title),
        content: Text(l10n.logo_delete_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.common_button_cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              l10n.common_button_delete,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await _logoService.deleteLogo();
        if (success) {
          _fadeController.reverse();
          await _loadLogoInfo();
          _showSuccessMessage('Logo deleted successfully!');
        } else {
          _showErrorMessage('Failed to delete logo. Please try again.');
        }
      } catch (e) {
        _showErrorMessage('Failed to delete logo: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _showBarcodePreview() async {
    if (!mounted) return;
    
    try {
      final sampleProduct = Product(
        id: 'sample-id',
        createdBy: 'sample-user',
        storeId: 'sample-store',
        name: 'Sample Product',
        sku: 'SAMPLE123',
        barcode: '1234567890123',
        categoryId: 'sample-cat',
        isImei: false,
        isMustCheck: false,
        quantity: 100,
        purchasePrice: 15.00,
        salePrice: 19.99,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final sampleStore = Store(
        id: 'sample-store',
        ownerId: 'sample-owner',
        name: 'Sample Store',
        type: 'Retail',
        addressLine1: '123 Main St',
        city: 'Sample City',
        province: 'Sample Province',
        postalCode: '12345',
        country: 'Sample Country',
        phoneNumber: '+1234567890',
        isActive: true,
        timezone: 'UTC',
        createdBy: 'sample-user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await showDialog(
        context: context,
        builder: (context) => BarcodePreviewDialog(
          product: sampleProduct,
          store: sampleStore,
        ),
      );
      
    } catch (e) {
      debugPrint('Error showing barcode preview: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error showing preview: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showReceiptPreview() async {
    if (!mounted) return;
    
    try {
      final sampleStore = Store(
        id: 'sample-store',
        ownerId: 'sample-owner',
        name: 'Sample Store',
        type: 'Retail',
        addressLine1: '123 Main St',
        city: 'Sample City',
        province: 'Sample Province',
        postalCode: '12345',
        country: 'Sample Country',
        phoneNumber: '+1234567890',
        isActive: true,
        timezone: 'UTC',
        createdBy: 'sample-user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final sampleTransaction = {
        'id': 'TXN-${DateTime.now().millisecondsSinceEpoch}',
        'type': 'SALE',
        'createdAt': DateTime.now().toIso8601String(),
        'items': [
          {
            'productName': 'Premium Widget',
            'quantity': 2,
            'price': 15.99,
          },
          {
            'productName': 'Super Gadget',
            'quantity': 1,
            'price': 29.99,
          }
        ],
      };

      await showDialog(
        context: context,
        builder: (context) => ReceiptPreviewDialog(
          transaction: sampleTransaction,
          store: sampleStore,
        ),
      );
    } catch (e) {
      debugPrint('Error showing receipt preview: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error showing preview: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Column(
        children: [
          _buildHeader(),
          if (_isLoading) _buildLoadingState(),
          if (!_isLoading && _hasLogo) _buildLogoPreview(),
          if (!_isLoading && !_hasLogo) _buildEmptyState(),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.image_outlined,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.logo_management_title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.logo_management_subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
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

  Widget _buildLogoPreview() {
    final l10n = AppLocalizations.of(context)!;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // Logo preview
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[300]!,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _logoPath != null
                  ? Image.file(
                      File(_logoPath!),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.logo_preview_error,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Container(
                      padding: const EdgeInsets.all(20),
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                    ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Logo info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (_logoDimensions != null)
                    _buildInfoRow(
                      l10n.logo_dimensions,
                      '${_logoDimensions!['width']} × ${_logoDimensions!['height']} px',
                    ),
                  if (_logoFileSize != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      l10n.logo_file_size,
                      _logoService.formatFileSize(_logoFileSize!),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.add_photo_alternate_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.logo_empty_title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.logo_empty_subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
          ),
        ),
      ),
      child: Column(
        children: [
          // Preview section header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              l10n.logo_preview_section,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          
          // Preview buttons (available regardless of logo status)
          Column(
            children: [
              // Barcode preview button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _showBarcodePreview,
                  icon: Icon(
                    Icons.qr_code_outlined, 
                    size: 20,
                    color: _isLoading 
                      ? Colors.grey 
                      : Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    l10n.preview_barcode,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    side: BorderSide(
                      color: _isLoading 
                        ? Colors.grey[300]! 
                        : Theme.of(context).primaryColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: _isLoading 
                      ? Colors.grey 
                      : Theme.of(context).primaryColor,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Receipt preview button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _showReceiptPreview,
                  icon: Icon(
                    Icons.receipt_long_outlined, 
                    size: 20,
                    color: _isLoading 
                      ? Colors.grey 
                      : Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    l10n.preview_receipt,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    side: BorderSide(
                      color: _isLoading 
                        ? Colors.grey[300]! 
                        : Theme.of(context).primaryColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: _isLoading 
                      ? Colors.grey 
                      : Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Logo management buttons
          Row(
            children: [
              if (_hasLogo) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _deleteLogo,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: Text(l10n.common_button_delete),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _uploadLogo,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(l10n.logo_replace_button),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _uploadLogo,
                    icon: const Icon(Icons.add_photo_alternate, size: 18),
                    label: Text(l10n.logo_upload_button),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}