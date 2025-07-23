import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../generated/app_localizations.dart';
import '../../../core/models/store.dart';
import '../../../core/services/store_service.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/models/user.dart';
import '../../../core/widgets/loading.dart';

class StoreDetailScreen extends StatefulWidget {
  final String storeId;

  const StoreDetailScreen({
    super.key,
    required this.storeId,
  });

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  final StoreService _storeService = StoreService();
  
  Store? _store;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadStoreDetail();
  }

  Future<void> _loadStoreDetail() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final store = await _storeService.getStoreById(widget.storeId);
      
      if (!mounted) return;

      setState(() {
        _store = store;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteStore() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (_store == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeleteStore),
        content: Text(l10n.deleteStoreConfirmation(_store!.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storeService.deleteStore(widget.storeId);
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.storeDeletedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to stores list
        context.goNamed('stores');
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToDeleteStore),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final isOwner = authProvider.currentUser?.role == UserRole.owner;

    return Scaffold(
      body: _isLoading
          ? const Center(child: WMSLoadingIndicator())
          : _hasError
              ? _buildErrorView(l10n, theme)
              : _buildContent(l10n, theme, isOwner),
    );
  }

  Widget _buildErrorView(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.failedToLoadStore,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(l10n.back),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _loadStoreDetail,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n, ThemeData theme, bool isOwner) {
    if (_store == null) {
      return const Center(child: WMSLoadingIndicator());
    }

    return CustomScrollView(
      slivers: [
        // Hero App Bar
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.8),
                    theme.colorScheme.secondary.withValues(alpha: 0.6),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.store,
                          color: theme.colorScheme.onPrimary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _store!.name,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _store!.isActive
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _store!.isActive ? l10n.active : l10n.inactive,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: _store!.isActive ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _store!.type,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          actions: [
            if (isOwner) ...[
              IconButton(
                onPressed: () => context.pushNamed('editStore', pathParameters: {'id': widget.storeId}),
                icon: const Icon(Icons.edit),
                tooltip: l10n.editStore,
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteStore();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store Information Card
                _buildInfoCard(
                  l10n.storeInformation,
                  Icons.info_outline,
                  [
                    _buildInfoRow(l10n.storeName, _store!.name),
                    _buildInfoRow(l10n.storeType, _store!.type),
                    _buildInfoRow(l10n.status, _store!.isActive ? l10n.active : l10n.inactive),
                    _buildInfoRow(l10n.timezone, _store!.timezone),
                    if (_store!.hasOperatingHours) ...[
                      _buildInfoRow(l10n.openTime, _store!.openTime?.toString().split(' ')[1] ?? ''),
                      _buildInfoRow(l10n.closeTime, _store!.closeTime?.toString().split(' ')[1] ?? ''),
                    ],
                  ],
                  theme,
                ),

                const SizedBox(height: 16),

                // Address Information Card
                _buildInfoCard(
                  l10n.addressInformation,
                  Icons.location_on_outlined,
                  [
                    _buildInfoRow(l10n.addressLine1, _store!.addressLine1),
                    if (_store!.addressLine2?.isNotEmpty == true)
                      _buildInfoRow(l10n.addressLine2, _store!.addressLine2!),
                    _buildInfoRow(l10n.city, _store!.city),
                    _buildInfoRow(l10n.province, _store!.province),
                    _buildInfoRow(l10n.postalCode, _store!.postalCode),
                    _buildInfoRow(l10n.country, _store!.country),
                    if (_store!.mapLocation?.isNotEmpty == true)
                      _buildInfoRow(l10n.mapLocation, _store!.mapLocation!),
                  ],
                  theme,
                ),

                const SizedBox(height: 16),

                // Contact Information Card
                _buildInfoCard(
                  l10n.contactInformation,
                  Icons.contact_phone_outlined,
                  [
                    _buildInfoRow(l10n.phoneNumber, _store!.phoneNumber),
                    if (_store!.email?.isNotEmpty == true)
                      _buildInfoRow(l10n.email, _store!.email!),
                  ],
                  theme,
                ),

                const SizedBox(height: 16),

                // Audit Information Card
                _buildInfoCard(
                  l10n.auditInformation,
                  Icons.history,
                  [
                    _buildInfoRow(l10n.createdBy, _store!.createdBy),
                    _buildInfoRow(l10n.createdAt, _formatDateTime(_store!.createdAt)),
                    _buildInfoRow(l10n.updatedAt, _formatDateTime(_store!.updatedAt)),
                    if (_store!.deletedAt != null)
                      _buildInfoRow(l10n.deletedAt, _formatDateTime(_store!.deletedAt!)),
                  ],
                  theme,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    String title,
    IconData icon,
    List<Widget> children,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? '-' : value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}