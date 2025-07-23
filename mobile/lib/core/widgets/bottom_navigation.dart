import 'package:flutter/material.dart';
import '../../generated/app_localizations.dart';

class WMSBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String userRole;

  const WMSBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.userRole,
  });

  @override
  State<WMSBottomNavigation> createState() => _WMSBottomNavigationState();
}

class _WMSBottomNavigationState extends State<WMSBottomNavigation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeAnimations();
      _isInitialized = true;
    }
  }

  void _initializeAnimations() {
    final items = getNavigationItemsForRole(context, widget.userRole);
    _controllers = List.generate(
      items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );
    _animations = _controllers
        .map((controller) => Tween<double>(begin: 0.8, end: 1.0)
            .animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut)))
        .toList();

    // Animate the selected item
    if (widget.currentIndex < _controllers.length) {
      _controllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(WMSBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isInitialized && oldWidget.currentIndex != widget.currentIndex) {
      // Reset all animations
      for (var controller in _controllers) {
        controller.reset();
      }
      // Animate the new selected item
      if (widget.currentIndex < _controllers.length) {
        _controllers[widget.currentIndex].forward();
      }
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      for (var controller in _controllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = getNavigationItemsForRole(context, widget.userRole);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface.withValues(alpha: 0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = index == widget.currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.onTap(index),
                  child: AnimatedBuilder(
                    animation: _animations[index],
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _animations[index].value,
                        child: Container(
                          height: 64,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: isSelected
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.primary.withValues(alpha: 0.8),
                                    ],
                                  )
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                items[index].icon is Icon 
                                    ? (items[index].icon as Icon).icon
                                    : Icons.dashboard,
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                size: isSelected ? 24 : 22,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                items[index].label ?? '',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  static List<BottomNavigationBarItem> getNavigationItemsForRole(BuildContext context, String role) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (role.toUpperCase()) {
      case 'OWNER':
        return [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2),
            label: l10n.products,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt),
            label: l10n.transactions,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.store),
            label: l10n.stores,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: l10n.users,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ];
      case 'ADMIN':
        return [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2),
            label: l10n.products,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt),
            label: l10n.transactions,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.store),
            label: l10n.stores,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ];
      case 'STAFF':
        return [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2),
            label: l10n.products,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.checklist),
            label: l10n.checks,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ];
      case 'CASHIER':
        return [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2),
            label: l10n.products,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt),
            label: l10n.transactions,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ];
      default:
        return [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2),
            label: l10n.products,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt),
            label: l10n.transactions,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.store),
            label: l10n.stores,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ];
    }
  }

}