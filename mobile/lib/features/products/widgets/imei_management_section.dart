import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/services/product_service.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/widgets/cards.dart';
import '../../../core/widgets/loading.dart';
import '../../../core/validators/product_validators.dart';

class ImeiManagementSection extends StatefulWidget {
  final String productId;
  final String productName;
  final int expectedQuantity;

  const ImeiManagementSection({
    super.key,
    required this.productId,
    required this.productName,
    required this.expectedQuantity,
  });

  @override
  State<ImeiManagementSection> createState() => _ImeiManagementSectionState();
}

class _ImeiManagementSectionState extends State<ImeiManagementSection> {
  final ProductService _productService = ProductService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _imeiController = TextEditingController();
  
  List<Map<String, dynamic>> _imeis = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreImeis = true;
  String? _error;
  
  int _currentPage = 1;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadImeis();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _imeiController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      if (!_isLoadingMore && _hasMoreImeis) {
        _loadMoreImeis();
      }
    }
  }

  Future<void> _loadImeis({bool reset = false}) async {
    if (reset) {
      // Guard clause: only update state if widget is still mounted
      if (!mounted) return;
      
      setState(() {
        _currentPage = 1;
        _hasMoreImeis = true;
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final response = await _productService.getProductImeis(
        widget.productId,
        page: _currentPage,
        limit: _pageSize,
      );

      // Guard clause: only update state if widget is still mounted
      if (!mounted) return;
      
      setState(() {
        if (reset) {
          _imeis = response.data;
        } else {
          _imeis.addAll(response.data);
        }
        _hasMoreImeis = response.pagination.hasNext;
        _isLoading = false;
      });
    } catch (e) {
      // Guard clause: only update state if widget is still mounted
      if (!mounted) return;
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreImeis() async {
    if (_isLoadingMore || !_hasMoreImeis) return;

    // Guard clause: only update state if widget is still mounted
    if (!mounted) return;
    
    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      await _loadImeis();
    } catch (e) {
      _currentPage--; // Revert page increment on error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load more IMEIs: $e')),
        );
      }
    } finally {
      // Guard clause: only update state if widget is still mounted
      if (!mounted) return;
      
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _addImei() async {
    final imei = _imeiController.text.trim();
    
    // Validate IMEI
    final validationError = ProductValidators.validateImei(imei);
    if (validationError != null) {
      // Guard clause: only show snackbar if widget is still mounted
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if IMEI already exists
    final existingImei = _imeis.where((i) => i['imei'] == imei).firstOrNull;
    if (existingImei != null) {
      // Guard clause: only show snackbar if widget is still mounted
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This IMEI is already added to this product'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await _productService.addImeiToProduct(widget.productId, imei);
      
      // Clear input
      _imeiController.clear();
      
      // Reload IMEIs
      await _loadImeis(reset: true);
      
      // Success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('IMEI $imei added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add IMEI: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeImei(Map<String, dynamic> imeiData) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove IMEI'),
        content: Text('Are you sure you want to remove IMEI ${imeiData['imei']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldRemove == true) {
      try {
        await _productService.removeImei(imeiData['id']);
        
        // Reload IMEIs
        await _loadImeis(reset: true);
        
        // Success feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('IMEI ${imeiData['imei']} removed successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove IMEI: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _copyImei(String imei) {
    Clipboard.setData(ClipboardData(text: imei));
    
    // Guard clause: only show snackbar if widget is still mounted
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('IMEI $imei copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final canManageImeis = user?.canCreateProducts == true;

    return WMSCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'IMEI Management',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getQuantityStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getQuantityStatusColor()),
                  ),
                  child: Text(
                    '${_imeis.length}/${widget.expectedQuantity}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getQuantityStatusColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Add IMEI Section
            if (canManageImeis) ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _imeiController,
                      decoration: const InputDecoration(
                        labelText: 'Add IMEI',
                        hintText: 'Enter 15-digit IMEI number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 15,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: ProductValidators.validateImei,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _addImei,
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // IMEI List
            _buildImeiList(),
          ],
        ),
      ),
    );
  }

  Widget _buildImeiList() {
    if (_isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: WMSLoadingIndicator()),
      );
    }

    if (_error != null) {
      return Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 32),
            const SizedBox(height: 8),
            Text(
              'Failed to load IMEIs',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _loadImeis(reset: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_imeis.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.device_hub_outlined, color: Colors.grey[400], size: 32),
            const SizedBox(height: 8),
            Text(
              'No IMEIs added yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add IMEIs to track individual units',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: Scrollbar(
        controller: _scrollController,
        child: ListView.builder(
          controller: _scrollController,
          shrinkWrap: true,
          itemCount: _imeis.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _imeis.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: WMSLoadingIndicator()),
              );
            }

            final imeiData = _imeis[index];
            return _ImeiListItem(
              imeiData: imeiData,
              onCopy: () => _copyImei(imeiData['imei']),
              onRemove: context.read<AuthProvider>().user?.canCreateProducts == true
                  ? () => _removeImei(imeiData)
                  : null,
            );
          },
        ),
      ),
    );
  }

  Color _getQuantityStatusColor() {
    final count = _imeis.length;
    final expected = widget.expectedQuantity;
    
    if (count == expected) return Colors.green;
    if (count > expected) return Colors.orange;
    return Colors.blue;
  }
}

class _ImeiListItem extends StatelessWidget {
  final Map<String, dynamic> imeiData;
  final VoidCallback onCopy;
  final VoidCallback? onRemove;

  const _ImeiListItem({
    required this.imeiData,
    required this.onCopy,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final imei = imeiData['imei'] as String;
    final createdAt = DateTime.tryParse(imeiData['createdAt'] ?? '');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          child: Icon(
            Icons.device_hub,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          imei,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
        subtitle: createdAt != null
            ? Text(
                'Added ${_formatDateTime(createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: onCopy,
              tooltip: 'Copy IMEI',
            ),
            if (onRemove != null)
              IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                onPressed: onRemove,
                tooltip: 'Remove IMEI',
              ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}