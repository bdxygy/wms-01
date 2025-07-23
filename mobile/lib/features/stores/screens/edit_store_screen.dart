import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../generated/app_localizations.dart';
import '../../../core/models/store.dart';
import '../../../core/services/store_service.dart';
import '../../../core/widgets/loading.dart';
import '../widgets/store_form.dart';

class EditStoreScreen extends StatefulWidget {
  final String storeId;

  const EditStoreScreen({
    super.key,
    required this.storeId,
  });

  @override
  State<EditStoreScreen> createState() => _EditStoreScreenState();
}

class _EditStoreScreenState extends State<EditStoreScreen> {
  final StoreService _storeService = StoreService();
  
  Store? _store;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadStore();
  }

  Future<void> _loadStore() async {
    try {
      final store = await _storeService.getStoreById(widget.storeId);
      if (mounted) {
        setState(() {
          _store = store;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editStore),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: WMSLoadingIndicator())
          : _hasError
              ? _buildErrorView(l10n, theme)
              : StoreForm(
                  store: _store,
                  onSuccess: () {
                    // Navigate back to store detail
                    context.goNamed('storeDetail', pathParameters: {'id': widget.storeId});
                  },
                ),
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
                  onPressed: _loadStore,
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
}