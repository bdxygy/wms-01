import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/theme_colors.dart';
import '../theme/typography.dart';

/// Custom app bar components for the WMS application
/// Provides consistent app bar styles and behavior

/// Standard WMS app bar
class WMSAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool centerTitle;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;

  const WMSAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = true,
    this.flexibleSpace,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppBar(
      title: Text(
        title,
        style: WMSTypography.appBarTitle.copyWith(
          color: foregroundColor ?? (isDark ? WMSColors.textColorDark : Colors.white),
        ),
      ),
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor ?? (isDark ? WMSColors.surfaceDark : WMSColors.primaryBlue),
      foregroundColor: foregroundColor ?? (isDark ? WMSColors.textColorDark : Colors.white),
      elevation: elevation ?? 0,
      scrolledUnderElevation: 4,
      centerTitle: centerTitle,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );
}

/// Search app bar with search functionality
class WMSSearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String hintText;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchSubmitted;
  final VoidCallback? onSearchCleared;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  const WMSSearchAppBar({
    super.key,
    required this.title,
    this.hintText = 'Search...',
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onSearchCleared,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  @override
  State<WMSSearchAppBar> createState() => _WMSSearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _WMSSearchAppBarState extends State<WMSSearchAppBar> {
  bool _isSearching = false;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
    _searchFocusNode.requestFocus();
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
    });
    _searchController.clear();
    _searchFocusNode.unfocus();
    widget.onSearchCleared?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: WMSTypography.bodyMedium.copyWith(
                color: isDark ? WMSColors.textColorDark : Colors.white,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: WMSTypography.bodyMedium.copyWith(
                  color: isDark 
                      ? WMSColors.textSecondaryDark.withOpacity(0.7)
                      : Colors.white.withOpacity(0.7),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: widget.onSearchChanged,
              onSubmitted: (_) => widget.onSearchSubmitted?.call(),
            )
          : Text(
              widget.title,
              style: WMSTypography.appBarTitle.copyWith(
                color: isDark ? WMSColors.textColorDark : Colors.white,
              ),
            ),
      automaticallyImplyLeading: widget.automaticallyImplyLeading,
      backgroundColor: isDark ? WMSColors.surfaceDark : WMSColors.primaryBlue,
      foregroundColor: isDark ? WMSColors.textColorDark : Colors.white,
      elevation: 0,
      scrolledUnderElevation: 4,
      centerTitle: true,
      actions: [
        if (_isSearching) ...[
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _stopSearch,
          ),
        ] else ...[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _startSearch,
          ),
          if (widget.actions != null) ...widget.actions!,
        ],
      ],
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );
  }
}

/// App bar with role indicator
class WMSRoleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String userRole;
  final String? storeName;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  const WMSRoleAppBar({
    super.key,
    required this.title,
    required this.userRole,
    this.storeName,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppBar(
      title: Column(
        children: [
          Text(
            title,
            style: WMSTypography.appBarTitle.copyWith(
              color: isDark ? WMSColors.textColorDark : Colors.white,
            ),
          ),
          if (storeName != null)
            Text(
              storeName!,
              style: WMSTypography.bodySmall.copyWith(
                color: isDark 
                    ? WMSColors.textSecondaryDark
                    : Colors.white.withOpacity(0.8),
              ),
            ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: WMSColors.getRoleColor(userRole).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            userRole.toUpperCase(),
            style: WMSTypography.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (actions != null) ...actions!,
      ],
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: isDark ? WMSColors.surfaceDark : WMSColors.primaryBlue,
      foregroundColor: isDark ? WMSColors.textColorDark : Colors.white,
      elevation: 0,
      scrolledUnderElevation: 4,
      centerTitle: true,
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Sliver app bar for scrollable content
class WMSSliverAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool pinned;
  final bool floating;
  final bool snap;
  final double? expandedHeight;
  final Widget? flexibleSpace;
  final Widget? bottom;

  const WMSSliverAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.expandedHeight,
    this.flexibleSpace,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SliverAppBar(
      title: Text(
        title,
        style: WMSTypography.appBarTitle.copyWith(
          color: isDark ? WMSColors.textColorDark : Colors.white,
        ),
      ),
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: isDark ? WMSColors.surfaceDark : WMSColors.primaryBlue,
      foregroundColor: isDark ? WMSColors.textColorDark : Colors.white,
      elevation: 0,
      pinned: pinned,
      floating: floating,
      snap: snap,
      expandedHeight: expandedHeight,
      flexibleSpace: flexibleSpace,
      bottom: bottom as PreferredSizeWidget?,
      centerTitle: true,
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );
  }
}

/// Tab bar for navigation
class WMSTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Tab> tabs;
  final TabController? controller;
  final ValueChanged<int>? onTap;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;

  const WMSTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.onTap,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TabBar(
      tabs: tabs,
      controller: controller,
      onTap: onTap,
      indicatorColor: indicatorColor ?? (isDark ? WMSColors.primaryBlue : Colors.white),
      labelColor: labelColor ?? (isDark ? WMSColors.textColorDark : Colors.white),
      unselectedLabelColor: unselectedLabelColor ?? (isDark 
          ? WMSColors.textSecondaryDark 
          : Colors.white.withOpacity(0.7)),
      labelStyle: WMSTypography.tabText.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: WMSTypography.tabText,
      indicatorWeight: 3,
      indicatorSize: TabBarIndicatorSize.tab,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);
}

/// Bottom app bar for actions
class WMSBottomAppBar extends StatelessWidget {
  final List<Widget> children;
  final Color? backgroundColor;
  final double height;
  final EdgeInsetsGeometry? padding;

  const WMSBottomAppBar({
    super.key,
    required this.children,
    this.backgroundColor,
    this.height = 60,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: WMSColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: children,
      ),
    );
  }
}