import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/services/imei_scanner_service.dart';
import '../../../core/utils/imei_utils.dart';
import '../../../core/widgets/scanner_overlay.dart';
import '../../../core/models/product.dart';
import '../../../generated/app_localizations.dart';

/// Professional IMEI scanner screen with enhanced validation and product search
class ImeiScannerScreen extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final Function(ImeiScanResult)? onImeiScanned;
  final Function(Product)? onProductFound;
  final bool allowManualEntry;
  final bool showHistory;
  final bool autoSearchProduct;
  final bool autoClose;

  const ImeiScannerScreen({
    super.key,
    this.title,
    this.subtitle,
    this.onImeiScanned,
    this.onProductFound,
    this.allowManualEntry = true,
    this.showHistory = true,
    this.autoSearchProduct = true,
    this.autoClose = false,
  });

  @override
  State<ImeiScannerScreen> createState() => _ImeiScannerScreenState();
}

class _ImeiScannerScreenState extends State<ImeiScannerScreen>
    with WidgetsBindingObserver {
  final ImeiScannerService _imeiScannerService = ImeiScannerService();
  StreamSubscription<ImeiScanResult>? _imeiScanSubscription;
  
  bool _isFlashOn = false;
  final bool _canSwitchCamera = true;
  bool _isTorchAvailable = false;
  bool _isProcessing = false;
  bool _isSearchingProduct = false;
  
  Product? _foundProduct;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeImeiScanner();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _imeiScanSubscription?.cancel();
    _imeiScannerService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _imeiScannerService.stopScanning();
    } else if (state == AppLifecycleState.resumed) {
      _imeiScannerService.startScanning();
    }
  }

  Future<void> _initializeImeiScanner() async {
    try {
      final success = await _imeiScannerService.initialize();
      if (!success) {
        _showErrorDialog('Failed to initialize IMEI scanner. Please check camera permissions.');
        return;
      }

      // Check torch availability
      _isTorchAvailable = await _imeiScannerService.isTorchAvailable();
      
      // Start scanning
      await _imeiScannerService.startScanning();
      
      // Listen to IMEI scan results
      _imeiScanSubscription = _imeiScannerService.imeiScanStream?.listen(_handleImeiScanResult);
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      _showErrorDialog('IMEI scanner initialization failed: $e');
    }
  }

  void _handleImeiScanResult(ImeiScanResult result) async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
      _foundProduct = null;
      _searchError = null;
    });

    // Provide haptic feedback
    if (result.isValid) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }

    // Auto-search for product if enabled and IMEI is valid
    if (widget.autoSearchProduct && result.isValid) {
      await _searchProductByImei(result.imeiInfo.cleanedImei);
    }

    // Show result dialog
    _showImeiResult(result);
    
    setState(() {
      _isProcessing = false;
    });
  }

  Future<void> _searchProductByImei(String imei) async {
    setState(() {
      _isSearchingProduct = true;
      _searchError = null;
    });

    try {
      final searchResult = await _imeiScannerService.searchProductByImei(imei);
      
      setState(() {
        if (searchResult.hasProduct) {
          _foundProduct = searchResult.product;
        } else if (searchResult.hasError) {
          _searchError = searchResult.errorMessage;
        } else {
          _searchError = 'No product found with this IMEI';
        }
        _isSearchingProduct = false;
      });
    } catch (e) {
      setState(() {
        _searchError = 'Product search failed: $e';
        _isSearchingProduct = false;
      });
    }
  }

  void _showImeiResult(ImeiScanResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildImeiResultDialog(result),
    );
  }

  Widget _buildImeiResultDialog(ImeiScanResult result) {
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            result.isValid ? Icons.check_circle : Icons.error,
            color: result.isValid ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(result.isValid ? 'IMEI Scanned' : 'Invalid IMEI'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMEI Information
            if (result.isValid) ...[ 
              _buildImeiInfoSection(result.imeiInfo),
              const SizedBox(height: 16),
              
              // Product Search Results
              if (widget.autoSearchProduct) ...[
                const Divider(),
                const SizedBox(height: 8),
                _buildProductSearchSection(),
              ],
            ] else ...[
              Text('IMEI: ${result.scannedValue}'),
              const SizedBox(height: 8),
              Text(
                'Error: ${result.imeiInfo.errorMessage ?? "Invalid format"}',
                style: TextStyle(color: Colors.red[700]),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (!result.isValid)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _continueScanning();
            },
            child: const Text('Try Again'),
          ),
        if (result.isValid) ...[ 
          if (_foundProduct != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleProductSelected(_foundProduct!);
              },
              child: const Text('View Product'),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _continueScanning();
            },
            child: const Text('Scan Another'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleConfirmedScan(result);
            },
            child: const Text('Use This IMEI'),
          ),
        ] else ...[ 
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ],
    );
  }

  Widget _buildImeiInfoSection(ImeiInfo imeiInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'IMEI: ${imeiInfo.formattedImei}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text('Type: ${imeiInfo.type}'),
        if (imeiInfo.tac != null) ...[
          const SizedBox(height: 4),
          Text('TAC: ${imeiInfo.tac}'),
        ],
        if (imeiInfo.serialNumber != null) ...[
          const SizedBox(height: 4),
          Text('Serial: ${imeiInfo.serialNumber}'),
        ],
        if (imeiInfo.checkDigit != null) ...[
          const SizedBox(height: 4),
          Text('Check Digit: ${imeiInfo.checkDigit}'),
        ],
      ],
    );
  }

  Widget _buildProductSearchSection() {
    if (_isSearchingProduct) {
      return const Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('Searching for product...'),
        ],
      );
    }

    if (_foundProduct != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Found:',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 4),
          Text(_foundProduct!.name),
          const SizedBox(height: 2),
          Text(
            'SKU: ${_foundProduct!.sku}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (_foundProduct!.salePrice != null) ...[
            const SizedBox(height: 2),
            Text(
              'Price: \$${_foundProduct!.salePrice!.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ],
      );
    }

    if (_searchError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Search:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _searchError!,
            style: TextStyle(color: Colors.orange[700]),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  void _handleConfirmedScan(ImeiScanResult result) {
    widget.onImeiScanned?.call(result);
    
    if (widget.autoClose) {
      Navigator.of(context).pop(result);
    }
  }

  void _handleProductSelected(Product product) {
    widget.onProductFound?.call(product);
    
    if (widget.autoClose) {
      Navigator.of(context).pop(product);
    }
  }

  void _continueScanning() {
    _isProcessing = false;
    _imeiScannerService.startScanning();
  }

  Future<void> _toggleFlash() async {
    if (!_isTorchAvailable) return;
    
    try {
      await _imeiScannerService.toggleTorch();
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      _showErrorDialog('Failed to toggle flash: $e');
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _imeiScannerService.switchCamera();
    } catch (e) {
      _showErrorDialog('Failed to switch camera: $e');
    }
  }

  void _showManualEntry() {
    showDialog(
      context: context,
      builder: (context) => _buildManualImeiEntryDialog(),
    );
  }

  Widget _buildManualImeiEntryDialog() {
    final controller = TextEditingController();
    ImeiValidationResult? validationResult;
    
    return StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text('Enter IMEI Manually'),
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
                const SizedBox(height: 8),
              ],
              const Text(
                'IMEI should be 15 digits (standard) or 16 digits (IMEISV)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
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
                      final result = _imeiScannerService.enterImeiManually(imei);
                      _handleImeiScanResult(result);
                    }
                  : null,
              child: const Text('Validate'),
            ),
          ],
        );
      },
    );
  }

  void _showScanHistory() {
    final history = _imeiScannerService.scanHistory;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('IMEI Scan History'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: history.isEmpty
              ? const Center(child: Text('No IMEI scans yet'))
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final scan = history[index];
                    return ListTile(
                      leading: Icon(
                        scan.isValid ? Icons.check_circle : Icons.error,
                        color: scan.isValid ? Colors.green : Colors.red,
                      ),
                      title: Text(scan.imeiInfo.formattedImei),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Type: ${scan.imeiInfo.type}'),
                          Text('Method: ${scan.scanMethod}'),
                        ],
                      ),
                      trailing: Text(
                        '${scan.timestamp.hour}:${scan.timestamp.minute.toString().padLeft(2, '0')}',
                      ),
                      onTap: () {
                        if (scan.isValid) {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          _handleConfirmedScan(scan);
                        }
                      },
                    );
                  },
                ),
        ),
        actions: [
          if (history.isNotEmpty)
            TextButton(
              onPressed: () {
                _imeiScannerService.clearScanHistory();
                Navigator.of(context).pop();
              },
              child: const Text('Clear History'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('IMEI Scanner Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_imeiScannerService.isReady) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                'Initializing IMEI scanner...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview (reusing the underlying scanner)
          Positioned.fill(
            child: MobileScanner(
              controller: _imeiScannerService.scannerService.controller!,
              onDetect: _imeiScannerService.scannerService.onBarcodeDetected,
            ),
          ),

          // IMEI Scanner overlay
          Positioned.fill(
            child: ScannerOverlay(
              title: widget.title ?? 'Scan IMEI',
              subtitle: widget.subtitle ?? 'Position IMEI barcode or text within the frame',
              onFlashToggle: _isTorchAvailable ? _toggleFlash : null,
              onCameraSwitch: _canSwitchCamera ? _switchCamera : null,
              onManualEntry: widget.allowManualEntry ? _showManualEntry : null,
              onClose: () => Navigator.of(context).pop(),
              isFlashOn: _isFlashOn,
              canSwitchCamera: _canSwitchCamera,
            ),
          ),

          // History button (if enabled)
          if (widget.showHistory && _imeiScannerService.scanHistory.isNotEmpty)
            Positioned(
              top: 100,
              right: 16,
              child: SafeArea(
                child: FloatingActionButton.small(
                  onPressed: _showScanHistory,
                  backgroundColor: Colors.black.withValues(alpha: 0.7),
                  foregroundColor: Colors.white,
                  child: Stack(
                    children: [
                      const Icon(Icons.history),
                      if (_imeiScannerService.scanHistory.isNotEmpty)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(1),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${_imeiScannerService.scanHistory.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

          // Processing indicator
          if (_isProcessing || _isSearchingProduct)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}