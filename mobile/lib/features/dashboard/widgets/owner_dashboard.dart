import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../generated/app_localizations.dart';
import '../../../core/providers/store_context_provider.dart';
import '../../../core/models/store.dart';
import '../../../core/widgets/loading.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _chartAnimationController;
  late List<Animation<double>> _cardAnimations;
  late Animation<double> _chartAnimation;

  Store? _selectedStore;
  bool _isLoading = true;
  List<Store> _stores = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadStores();
      }
    });
  }

  void _initializeAnimations() {
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Create staggered animations for cards
    _cardAnimations = List.generate(6, (index) {
      final start = index * 0.08;
      final end = (0.5 + (index * 0.08)).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardAnimationController,
          curve: Interval(
            start,
            end,
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _chartAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Start animations
    _cardAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _chartAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _chartAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadStores() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final storeProvider = context.read<StoreContextProvider>();
      await storeProvider.loadAvailableStores().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Store loading timeout');
        },
      );

      if (!mounted) return;

      setState(() {
        _stores = storeProvider.availableStores;
        // Find the selected store from the available stores list to ensure object equality
        final currentSelectedStoreId = storeProvider.selectedStore?.id;
        if (currentSelectedStoreId != null) {
          // Try to find the selected store in the available stores
          try {
            _selectedStore = _stores.firstWhere(
              (store) => store.id == currentSelectedStoreId,
            );
          } catch (e) {
            // If selected store is not in available stores, pick the first one
            _selectedStore = _stores.isNotEmpty ? _stores.first : null;
          }
        } else {
          _selectedStore = _stores.isNotEmpty ? _stores.first : null;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _switchToStore(Store store) async {
    try {
      final storeProvider = context.read<StoreContextProvider>();
      await storeProvider.switchStore(store);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.switchedTo} ${store.name}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to switch store: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(64),
        child: Center(child: WMSLoadingIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Store Selector Section
        _buildStoreSelector(l10n, theme),

        const SizedBox(height: 24),

        // Key Metrics Grid
        _buildKeyMetricsGrid(l10n, theme),

        const SizedBox(height: 24),

        // Analytics Section
        _buildAnalyticsSection(l10n, theme),

        const SizedBox(height: 24),

        // Quick Actions Grid
        _buildQuickActionsGrid(l10n, theme),

        const SizedBox(height: 24),

        // Recent Activity Section
        _buildRecentActivitySection(l10n, theme),
      ],
    );
  }

  Widget _buildStoreSelector(AppLocalizations l10n, ThemeData theme) {
    return AnimatedBuilder(
      animation: _cardAnimations[0],
      builder: (context, child) {
        return Transform.scale(
          scale: 0.95 + (_cardAnimations[0].value * 0.05),
          child: Opacity(
            opacity: _cardAnimations[0].value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.business,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.storeOverview,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.selectStoreToViewDetails(_stores.length),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_stores.isNotEmpty) _buildStoreCarousel(l10n, theme),
                    if (_stores.isEmpty) _buildEmptyStores(l10n, theme),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStoreCarousel(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Store Switcher Dropdown
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedStore?.id,
              isExpanded: true,
              icon: Icon(
                Icons.expand_more,
                color: theme.colorScheme.primary,
              ),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              dropdownColor: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              elevation: 8,
              onChanged: (String? storeId) {
                if (storeId != null) {
                  final selectedStore =
                      _stores.firstWhere((store) => store.id == storeId);
                  setState(() => _selectedStore = selectedStore);
                  _switchToStore(selectedStore);
                }
              },
              hint: Row(
                children: [
                  Icon(
                    Icons.store,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.selectStore,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
              selectedItemBuilder: (BuildContext context) {
                return _stores.map<Widget>((Store store) {
                  return Row(
                    children: [
                      Icon(
                        Icons.store,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              store.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${store.city}, ${store.province}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: store.isActive
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          store.isActive ? l10n.active : l10n.inactive,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: store.isActive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
              items: _stores.map<DropdownMenuItem<String>>((Store store) {
                return DropdownMenuItem<String>(
                  value: store.id,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.store,
                            color: theme.colorScheme.primary,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                store.name,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${store.city}, ${store.province}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: store.isActive
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            store.isActive ? l10n.active : l10n.inactive,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: store.isActive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStores(AppLocalizations l10n, ThemeData theme) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 32,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noStoresCreated,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => context.pushNamed('createStore'),
              icon: const Icon(Icons.add, size: 16),
              label: Text(l10n.createStore),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetricsGrid(AppLocalizations l10n, ThemeData theme) {
    final metrics = [
      _MetricData(
        title: l10n.totalStores,
        value: _stores.length.toString(),
        icon: Icons.store,
        color: const Color(0xFF6366F1),
        trend: '+2',
      ),
      _MetricData(
        title: l10n.totalRevenue,
        value: '₫125.4M',
        icon: Icons.trending_up,
        color: const Color(0xFF10B981),
        trend: '+15.3%',
      ),
      _MetricData(
        title: l10n.activeProducts,
        value: '2,847',
        icon: Icons.inventory,
        color: const Color(0xFF3B82F6),
        trend: '+8.7%',
      ),
      _MetricData(
        title: l10n.totalStaff,
        value: '24',
        icon: Icons.people,
        color: const Color(0xFFF59E0B),
        trend: '+3',
      ),
    ];

    return Column(
      children: metrics.asMap().entries.map((entry) {
        final index = entry.key;
        final metric = entry.value;

        return AnimatedBuilder(
          animation: _cardAnimations[index + 1],
          builder: (context, child) {
            return Transform.scale(
              scale: 0.95 + (_cardAnimations[index + 1].value * 0.05),
              child: Opacity(
                opacity: _cardAnimations[index + 1].value,
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: index < metrics.length - 1 ? 12 : 0,
                  ),
                  child: _buildMetricCard(metric, theme),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildMetricCard(_MetricData metric, ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            metric.color.withValues(alpha: 0.1),
            metric.color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: metric.color.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: metric.color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: metric.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                metric.icon,
                color: metric.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    metric.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    metric.value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: metric.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                metric.trend,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: metric.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection(AppLocalizations l10n, ThemeData theme) {
    return const SizedBox();
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.95 + (_chartAnimation.value * 0.05),
          child: Opacity(
            opacity: _chartAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface.withValues(alpha: 0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.analytics,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.businessAnalytics,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                l10n.last30Days,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to detailed analytics
                          },
                          child: Text(l10n.viewAll),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Placeholder for charts
                    _buildChartPlaceholder(theme),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChartPlaceholder(ThemeData theme) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              'Revenue Analytics Chart',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Coming Soon',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(AppLocalizations l10n, ThemeData theme) {
    final actions = [
      _ActionData(
        title: l10n.addProduct,
        subtitle: l10n.createNewProduct,
        icon: Icons.add_box,
        color: const Color(0xFF6366F1),
        onTap: () => context.pushNamed('create-product'),
      ),
      _ActionData(
        title: l10n.newSale,
        subtitle: l10n.createSale,
        icon: Icons.receipt_long,
        color: const Color(0xFF10B981),
        onTap: () => context.pushNamed('create-transaction'),
      ),
      _ActionData(
        title: l10n.addEmployee,
        subtitle: l10n.createNewEmployee,
        icon: Icons.person_add,
        color: const Color(0xFF3B82F6),
        onTap: () {
          // show snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.userManagementComingSoon),
            ),
          );
        },
      ),
      _ActionData(
        title: l10n.categories,
        subtitle: l10n.viewCategories,
        icon: Icons.category,
        color: const Color(0xFFF59E0B),
        onTap: () => context.pushNamed('categories'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _cardAnimations[index + 2],
          builder: (context, child) {
            return Transform.scale(
              scale: 0.9 + (_cardAnimations[index + 2].value * 0.1),
              child: Opacity(
                opacity: _cardAnimations[index + 2].value,
                child: _buildActionCard(actions[index], theme),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionCard(_ActionData action, ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                action.color.withValues(alpha: 0.1),
                action.color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: action.color.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: action.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    action.icon,
                    color: action.color,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: Text(
                    action.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    action.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(AppLocalizations l10n, ThemeData theme) {
    return const SizedBox();

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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.history,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    l10n.recentActivity,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to activity logs
                  },
                  child: Text(l10n.viewAll),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActivityPlaceholder(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityPlaceholder(ThemeData theme) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline,
              size: 40,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 8),
            Text(
              'Recent Activity Feed',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Coming Soon',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  _MetricData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
  });
}

class _ActionData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _ActionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
