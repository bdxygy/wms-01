import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../generated/app_localizations.dart';
import '../../../core/widgets/main_navigation_scaffold.dart';
import '../../../core/widgets/loading.dart';
import '../../../core/services/transaction_service.dart';
import '../../../core/models/transaction.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/mixins/refresh_list_mixin.dart';
import '../../../core/utils/scanner_launcher.dart';
import '../widgets/transaction_filter_sheet.dart';

/// Modern Transaction List Screen with comprehensive transaction management
///
/// Features:
/// - Modern Material Design 3 with hero cards and gradient backgrounds
/// - Role-based transaction listing with proper permissions
/// - Real-time pagination with pull-to-refresh functionality
/// - Advanced filtering with modal bottom sheet
/// - Search functionality with debounced input
/// - Transaction statistics with visual indicators
/// - Responsive mobile-first design with proper overflow handling
/// - Full internationalization support
/// - Guard clause patterns for clean code structure
///
/// Permissions:
/// - OWNER/ADMIN: Full CRUD access, can see all transactions
/// - CASHIER: Can view and create SALE transactions, limited edit access
/// - STAFF: Read-only access to transactions
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with WidgetsBindingObserver, RefreshListMixin<TransactionsScreen> {
  final TransactionService _transactionService = TransactionService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  // Filter state
  String? _selectedType;
  String? _selectedStoreId;
  bool? _selectedIsFinished;
  DateTime? _startDate;
  DateTime? _endDate;
  double? _minAmount;
  double? _maxAmount;
  String _searchQuery = '';

  // Pagination
  int _currentPage = 1;
  static const int _pageSize = 20;
  bool _hasNextPage = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    setupRefreshListener();
    _loadTransactions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    disposeRefreshListener();
    super.dispose();
  }

  @override
  Future<void> refreshData() async {
    await _loadTransactions(refresh: true);
  }

  void _onScroll() {
    // Guard clause: check if widget is still mounted
    if (!mounted) return;

    // Guard clause: check scroll position for pagination trigger
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 200) {
      return;
    }

    _loadMoreTransactions();
  }

  Future<void> _loadTransactions({bool refresh = false}) async {
    // Guard clause: prevent multiple loads unless refreshing
    if (_isLoading && !refresh) return;

    // Guard clause: ensure widget is mounted
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
      if (refresh) {
        _transactions.clear();
        _currentPage = 1;
        _hasNextPage = true;
      }
    });

    try {
      final response = await _transactionService.getTransactions(
        page: _currentPage,
        limit: _pageSize,
        type: _selectedType,
        storeId: _selectedStoreId,
        isFinished: _selectedIsFinished,
        startDate: _startDate,
        endDate: _endDate,
        minAmount: _minAmount,
        maxAmount: _maxAmount,
        customerName: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (!mounted) return;

      setState(() {
        // Store response for potential future use
        if (refresh || _currentPage == 1) {
          _transactions = response.data;
        } else {
          _transactions.addAll(response.data);
        }
        _hasNextPage = response.pagination.hasNext;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreTransactions() async {
    // Guard clause: prevent multiple pagination loads
    if (_isLoadingMore || !_hasNextPage || _isLoading) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    try {
      final response = await _transactionService.getTransactions(
        page: _currentPage,
        limit: _pageSize,
        type: _selectedType,
        storeId: _selectedStoreId,
        isFinished: _selectedIsFinished,
        startDate: _startDate,
        endDate: _endDate,
        minAmount: _minAmount,
        maxAmount: _maxAmount,
        customerName: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (!mounted) return;

      setState(() {
        _transactions.addAll(response.data);
        _hasNextPage = response.pagination.hasNext;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _currentPage--; // Revert page increment on error
        _isLoadingMore = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load more transactions: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _onRefresh() async {
    await _loadTransactions(refresh: true);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TransactionFilterSheet(
        selectedType: _selectedType,
        selectedStoreId: _selectedStoreId,
        selectedIsFinished: _selectedIsFinished,
        startDate: _startDate,
        endDate: _endDate,
        minAmount: _minAmount,
        maxAmount: _maxAmount,
        onFiltersChanged: (filters) {
          setState(() {
            _selectedType = filters['type'];
            _selectedStoreId = filters['storeId'];
            _selectedIsFinished = filters['isFinished'];
            _startDate = filters['startDate'];
            _endDate = filters['endDate'];
            _minAmount = filters['minAmount'];
            _maxAmount = filters['maxAmount'];
          });
          _loadTransactions(refresh: true);
        },
        onClearFilters: () {
          setState(() {
            _selectedType = null;
            _selectedStoreId = null;
            _selectedIsFinished = null;
            _startDate = null;
            _endDate = null;
            _minAmount = null;
            _maxAmount = null;
          });
          _loadTransactions(refresh: true);
        },
      ),
    );
  }

  void _onSearchChanged(String query) {
    // Guard clause: prevent unnecessary state updates
    if (!mounted) return;
    if (_searchQuery == query) return;

    setState(() {
      _searchQuery = query;
    });

    // Debounce search to avoid too many API calls
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (_searchQuery == query) {
        _loadTransactions(refresh: true);
      }
    });
  }

  /// Launch QR scanner to search for transactions by QR code (transaction ID)
  void _scanTransactionQR() async {
    try {
      await ScannerLauncher.forCustomAction(
        context,
        title: 'Scan Transaction QR Code',
        subtitle: 'Scan QR code to find transaction',
        allowedTypes: ['QR_CODE'],
        onScanResult: (result) async {
          if (!result.isValid) {
            throw Exception('Invalid QR code format');
          }

          final scannedCode = result.formattedCode;

          // Guard clause: ensure widget is mounted after scan
          if (!mounted) return;

          try {
            // Try to navigate to transaction detail (assuming scannedCode is transaction ID)
            AppRouter.goToTransactionDetail(context, scannedCode);
          } catch (e) {
            // Guard clause: ensure widget is mounted after error
            if (!mounted) return;

            // Try searching by the scanned code as customer name or transaction data
            _searchController.text = scannedCode;
            _onSearchChanged(scannedCode);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'No transaction found for QR code. Searching by "$scannedCode"...'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scanner error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _onTransactionTap(Transaction transaction) {
    AppRouter.goToTransactionDetail(context, transaction.id);
  }

  Future<void> _onMarkFinished(Transaction transaction) async {
    // Guard clause: ensure widget is mounted
    if (!mounted) return;

    try {
      await _transactionService.finishTransaction(transaction.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Transaction ${transaction.id.substring(0, 8)} marked as finished'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh the list
      _loadTransactions(refresh: true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark transaction as finished: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _onEditTransaction(Transaction transaction) {
    AppRouter.goToEditTransaction(context, transaction.id);
  }

  bool _canCreateTransactions() {
    final authProvider = context.read<AuthProvider>();
    final userRole = authProvider.user?.role;

    // Guard clause: check if user role exists
    if (userRole == null) return false;

    return TransactionService.canCreateTransactions(userRole);
  }

  bool _canEditTransaction(Transaction transaction) {
    final authProvider = context.read<AuthProvider>();
    final userRole = authProvider.user?.role;

    // Guard clause: check if user role exists
    if (userRole == null) return false;

    return TransactionService.canUpdateTransaction(userRole);
  }

  Widget _buildModernSearchBar() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '${l10n.search} customers...',
                        prefixIcon: Icon(
                          Icons.search,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        isDense: true,
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // QR Scanner Button
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.qr_code_scanner,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onPressed: _scanTransactionQR,
                    tooltip: 'Scan Transaction QR Code',
                  ),
                ),
                const SizedBox(width: 12),
                // Filter Button
                Container(
                  decoration: BoxDecoration(
                    color: _hasActiveFilters()
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                        : Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _hasActiveFilters()
                          ? Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.3)
                          : Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.2),
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      _hasActiveFilters()
                          ? Icons.filter_list
                          : Icons.filter_list_outlined,
                      size: 20,
                      color: _hasActiveFilters()
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onPressed: _showFilterSheet,
                    tooltip: l10n.filter,
                  ),
                ),
              ],
            ),
          ),

          // Active filters indicator
          if (_hasActiveFilters()) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Filters active',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = null;
                        _selectedStoreId = null;
                        _selectedIsFinished = null;
                        _startDate = null;
                        _endDate = null;
                        _minAmount = null;
                        _maxAmount = null;
                        _searchController.clear();
                        _searchQuery = '';
                      });
                      _loadTransactions(refresh: true);
                    },
                    child: Text(
                      'Clear',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Divider(height: 1),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return NavigationAwareScaffold(
      title: l10n.transactions,
      currentRoute: 'transactions',
      body: Column(
        children: [
          // Modern Search and Filter Bar
          _buildModernSearchBar(),

          // Transaction List
          Expanded(
            child: _buildTransactionList(),
          ),
        ],
      ),
      floatingActionButton: _canCreateTransactions()
          ? FloatingActionButton(
              onPressed: () => navigateAndRefresh(
                  AppRouter.pushToCreateTransaction(context)),
              backgroundColor: Theme.of(context).primaryColor,
              tooltip: l10n.add,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildTransactionList() {
    // Guard clause: show loading state
    if (_isLoading && _transactions.isEmpty) {
      return const Center(child: WMSLoadingIndicator());
    }

    // Guard clause: show error state
    if (_error != null && _transactions.isEmpty) {
      return _buildErrorState();
    }

    // Guard clause: show empty state
    if (_transactions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _transactions.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          // Loading more indicator
          if (index == _transactions.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: WMSLoadingIndicator(),
              ),
            );
          }

          final transaction = _transactions[index];
          return _buildModernTransactionCard(transaction);
        },
      ),
    );
  }

  Widget _buildErrorState() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .errorContainer
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load transactions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadTransactions(refresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _hasActiveFilters()
                  ? 'Try adjusting your filters'
                  : 'Create your first transaction',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (_canCreateTransactions()) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => AppRouter.goToCreateTransaction(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add),
                label: Text(
                    'Create ${l10n.transactions.substring(0, l10n.transactions.length - 1)}'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModernTransactionCard(Transaction transaction) {
    final isTransfer = transaction.type == TransactionType.transfer;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _onTransactionTap(transaction),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with type badge and amount
              Row(
                children: [
                  _buildTransactionTypeBadge(transaction),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Provider.of<AppProvider>(context, listen: false)
                            .formatCurrency(transaction.calculatedAmount),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      _buildTransactionStatusChip(transaction),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Transaction ID and date row
              Row(
                children: [
                  Icon(
                    Icons.receipt,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'ID: ${transaction.id.substring(0, 8)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Text(
                    _formatTransactionDate(transaction.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),

              // Customer/destination info
              if (transaction.to != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      isTransfer ? Icons.store : Icons.person,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        transaction.to!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],

              // Items count and actions row
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${transaction.items?.length ?? 0} items',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const Spacer(),
                  if (_canEditTransaction(transaction)) ...[
                    InkWell(
                      onTap: () => _onEditTransaction(transaction),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (!transaction.isFinished &&
                      _canEditTransaction(transaction)) ...[
                    InkWell(
                      onTap: () => _onMarkFinished(transaction),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTypeBadge(Transaction transaction) {
    final isTransfer = transaction.type == TransactionType.transfer;
    final isTrade = transaction.type == TransactionType.trade;
    var color = Theme.of(context).colorScheme.primary;

    if (isTransfer) {
      color = Theme.of(context).colorScheme.secondary;
    }

    if (isTrade) {
      color = Colors.purple;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isTransfer ? Icons.swap_horiz : Icons.point_of_sale,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            transaction.type.name.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionStatusChip(Transaction transaction) {
    final isCompleted = transaction.isFinished;
    final color = isCompleted ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isCompleted ? 'Done' : 'Pending',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  String _formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    // Guard clause: handle different time ranges
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    }

    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  bool _hasActiveFilters() {
    return _selectedType != null ||
        _selectedStoreId != null ||
        _selectedIsFinished != null ||
        _startDate != null ||
        _endDate != null ||
        _minAmount != null ||
        _maxAmount != null ||
        _searchQuery.isNotEmpty;
  }
}
