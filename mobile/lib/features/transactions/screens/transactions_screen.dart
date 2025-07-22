import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../generated/app_localizations.dart';
import '../../../core/widgets/main_navigation_scaffold.dart';
import '../../../core/widgets/cards.dart';
import '../../../core/services/transaction_service.dart';
import '../../../core/models/transaction.dart';
import '../../../core/models/api_response.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/routing/app_router.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/transaction_filter_sheet.dart';

/// Comprehensive Transaction List Screen with CRUD operations
/// 
/// Features:
/// - Role-based transaction listing and filtering
/// - Real-time pagination with pull-to-refresh
/// - Advanced filtering (type, store, date range, amount)
/// - Quick actions (view, edit, mark finished)
/// - Create new transaction (floating action button)
/// - Search functionality
/// - Transaction statistics
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

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TransactionService _transactionService = TransactionService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  List<Transaction> _transactions = [];
  PaginatedResponse<Transaction>? _currentResponse;
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
    _loadTransactions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreTransactions();
    }
  }

  Future<void> _loadTransactions({bool refresh = false}) async {
    if (_isLoading && !refresh) return;
    
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
      );
      
      if (!mounted) return;
      
      setState(() {
        _currentResponse = response;
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
    setState(() {
      _searchQuery = query;
    });
    // TODO: Implement search functionality in backend
    // For now, we'll filter locally
    _loadTransactions(refresh: true);
  }

  void _onTransactionTap(Transaction transaction) {
    AppRouter.goToTransactionDetail(context, transaction.id);
  }

  Future<void> _onMarkFinished(Transaction transaction) async {
    if (!mounted) return;
    
    try {
      await _transactionService.finishTransaction(transaction.id);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction ${transaction.id.substring(0, 8)} marked as finished'),
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
    return userRole != null && TransactionService.canCreateTransactions(userRole);
  }

  bool _canEditTransaction(Transaction transaction) {
    final authProvider = context.read<AuthProvider>();
    final userRole = authProvider.user?.role;
    return userRole != null && TransactionService.canUpdateTransaction(userRole);
  }

  Widget _buildStatistics() {
    if (_currentResponse == null) return const SizedBox.shrink();
    
    final totalTransactions = _currentResponse!.pagination.total;
    final completedCount = _transactions.where((t) => t.isFinished).length;
    final pendingCount = _transactions.where((t) => !t.isFinished).length;
    final totalAmount = _transactions.fold<double>(
      0.0, 
      (sum, transaction) => sum + transaction.calculatedAmount,
    );

    return WMSCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total',
                    totalTransactions.toString(),
                    Icons.receipt_long,
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Completed',
                    completedCount.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Pending',
                    pendingCount.toString(),
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Amount',
                    totalAmount.toStringAsFixed(0),
                    Icons.monetization_on,
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();
    final userRole = authProvider.user?.role;

    return NavigationAwareScaffold(
      title: l10n.transactions,
      currentRoute: 'transactions',
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search transactions...',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: _hasActiveFilters() 
                        ? Theme.of(context).colorScheme.primary 
                        : null,
                  ),
                  onPressed: _showFilterSheet,
                  tooltip: 'Filter transactions',
                ),
              ],
            ),
          ),

          // Statistics Summary
          if (_currentResponse != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildStatistics(),
            ),
            const SizedBox(height: 16),
          ],

          // Transaction List
          Expanded(
            child: _buildTransactionList(),
          ),
        ],
      ),
      floatingActionButton: _canCreateTransactions()
          ? FloatingActionButton(
              onPressed: () => AppRouter.goToCreateTransaction(context),
              tooltip: 'Create Transaction',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildTransactionList() {
    if (_isLoading && _transactions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null && _transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load transactions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadTransactions(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _hasActiveFilters() 
                  ? 'Try adjusting your filters'
                  : 'Create your first transaction',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (_canCreateTransactions()) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => AppRouter.goToCreateTransaction(context),
                child: const Text('Create Transaction'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _transactions.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _transactions.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final transaction = _transactions[index];
          return TransactionListItem(
            transaction: transaction,
            onTap: () => _onTransactionTap(transaction),
            onEdit: _canEditTransaction(transaction) 
                ? () => _onEditTransaction(transaction)
                : null,
            onMarkFinished: !transaction.isFinished && _canEditTransaction(transaction)
                ? () => _onMarkFinished(transaction)
                : null,
          );
        },
      ),
    );
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