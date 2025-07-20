import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/imei_scanner_service.dart';
import '../../../core/utils/imei_utils.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/models/product.dart';
import '../../../generated/app_localizations.dart';

/// Screen for managing IMEIs associated with a product
class ProductImeiManagementScreen extends StatefulWidget {
  final Product product;

  const ProductImeiManagementScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductImeiManagementScreen> createState() => _ProductImeiManagementScreenState();
}

class _ProductImeiManagementScreenState extends State<ProductImeiManagementScreen> {
  final ImeiManagementService _imeiManagementService = ImeiManagementService();
  List<String> _productImeis = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProductImeis();
  }

  Future<void> _loadProductImeis() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final imeis = await _imeiManagementService.getProductImeis(widget.product.id);
      setState(() {
        _productImeis = imeis;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load IMEIs: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addImeiToProduct(String imei) async {
    setState(() {
      _errorMessage = null;
    });

    try {
      // Validate IMEI first
      final imeiInfo = ImeiUtils.getImeiInfo(imei);
      if (!imeiInfo.isValid) {
        throw Exception('Invalid IMEI format');
      }

      // Check if IMEI is already associated with another product
      final isUnique = await _imeiManagementService.isImeiUnique(imeiInfo.cleanedImei);
      if (!isUnique) {
        throw Exception('IMEI is already associated with another product');
      }

      // Add IMEI to product
      final success = await _imeiManagementService.addImeiToProduct(
        widget.product.id,
        imeiInfo.cleanedImei,
      );

      if (success) {
        setState(() {
          _productImeis.add(imeiInfo.cleanedImei);
        });
        
        _showSuccessMessage('IMEI added successfully');
      } else {
        throw Exception('Failed to add IMEI to product');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _removeImeiFromProduct(String imei, String imeiId) async {
    final confirmed = await _showConfirmationDialog(
      'Remove IMEI',
      'Are you sure you want to remove IMEI $imei from this product?',
    );

    if (!confirmed) return;

    try {
      final success = await _imeiManagementService.removeImeiFromProduct(imeiId);
      
      if (success) {
        setState(() {
          _productImeis.remove(imei);
        });
        
        _showSuccessMessage('IMEI removed successfully');
      } else {
        throw Exception('Failed to remove IMEI');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to remove IMEI: $e';
      });
    }
  }

  void _showAddImeiOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildAddImeiBottomSheet(),
    );
  }

  Widget _buildAddImeiBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Add IMEI to Product',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // Scan IMEI option
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('Scan IMEI'),
            subtitle: const Text('Use camera to scan IMEI barcode or text'),
            onTap: () {
              Navigator.of(context).pop();
              _scanImei();
            },
          ),
          
          // Manual entry option
          ListTile(
            leading: const Icon(Icons.keyboard),
            title: const Text('Enter IMEI Manually'),
            subtitle: const Text('Type IMEI number manually'),
            onTap: () {
              Navigator.of(context).pop();
              _showManualImeiEntry();
            },
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _scanImei() {
    AppRouter.goToImeiScanner(
      context,
      title: 'Scan IMEI for ${widget.product.name}',
      subtitle: 'Position IMEI within the frame',
      onImeiScanned: (result) {
        final imeiResult = result as ImeiScanResult;
        if (imeiResult.isValid) {
          _addImeiToProduct(imeiResult.imeiInfo.cleanedImei);
        }
      },
      autoSearchProduct: false,
      autoClose: true,
    );
  }

  void _showManualImeiEntry() {
    final controller = TextEditingController();
    ImeiValidationResult? validationResult;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Add IMEI to ${widget.product.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'IMEI Number',
                    hintText: 'Enter 15-16 digit IMEI...',
                    border: const OutlineInputBorder(),
                    suffixIcon: validationResult?.isValid == true 
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : validationResult?.canProceed == false
                            ? const Icon(Icons.error, color: Colors.red)
                            : null,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      validationResult = ImeiUtils.validateInput(value);
                    });
                  },
                ),
                const SizedBox(height: 8),
                if (validationResult != null) ...[
                  Text(
                    validationResult!.message,
                    style: TextStyle(
                      color: validationResult!.isValid 
                          ? Colors.green 
                          : validationResult!.canProceed 
                              ? Colors.orange 
                              : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: validationResult?.canProceed == true
                    ? () {
                        final imei = controller.text.trim();
                        Navigator.of(context).pop();
                        _addImeiToProduct(imei);
                      }
                    : null,
                child: const Text('Add IMEI'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showImeiDetails(String imei) {
    final imeiInfo = ImeiUtils.getImeiInfo(imei);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('IMEI Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('IMEI', imeiInfo.formattedImei),
            _buildDetailRow('Type', imeiInfo.type),
            if (imeiInfo.tac != null)
              _buildDetailRow('TAC', imeiInfo.tac!),
            if (imeiInfo.serialNumber != null)
              _buildDetailRow('Serial Number', imeiInfo.serialNumber!),
            if (imeiInfo.checkDigit != null)
              _buildDetailRow('Check Digit', imeiInfo.checkDigit!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _copyImeiToClipboard(imei);
            },
            child: const Text('Copy IMEI'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _copyImeiToClipboard(String imei) {
    Clipboard.setData(ClipboardData(text: imei));
    _showSuccessMessage('IMEI copied to clipboard');
  }

  Future<bool> _showConfirmationDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('IMEI Management'),
            Text(
              widget.product.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadProductImeis,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddImeiOptions,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[700]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadProductImeis,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_productImeis.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_2,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No IMEIs Added',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Add IMEIs to track individual units of this product',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddImeiOptions,
              icon: const Icon(Icons.add),
              label: const Text('Add First IMEI'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header with statistics
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.qr_code_scanner,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_productImeis.length} IMEIs',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      'Associated with this product',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // IMEI List
        Expanded(
          child: ListView.builder(
            itemCount: _productImeis.length,
            itemBuilder: (context, index) {
              final imei = _productImeis[index];
              final imeiInfo = ImeiUtils.getImeiInfo(imei);
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.qr_code_2,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  title: Text(
                    imeiInfo.formattedImei,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  subtitle: Text('Type: ${imeiInfo.type}'),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'details',
                        child: ListTile(
                          leading: Icon(Icons.info),
                          title: Text('View Details'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'copy',
                        child: ListTile(
                          leading: Icon(Icons.copy),
                          title: Text('Copy IMEI'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'remove',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Remove', style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'details':
                          _showImeiDetails(imei);
                          break;
                        case 'copy':
                          _copyImeiToClipboard(imei);
                          break;
                        case 'remove':
                          _removeImeiFromProduct(imei, 'imei_id_$index'); // TODO: Use actual IMEI ID
                          break;
                      }
                    },
                  ),
                  onTap: () => _showImeiDetails(imei),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}