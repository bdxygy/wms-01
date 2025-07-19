import 'package:flutter/material.dart';

import '../theme/theme_colors.dart';

/// Layout utilities and responsive design helpers for the WMS application
/// Provides consistent spacing, breakpoints, and layout components

/// Responsive breakpoints
class WMSBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < tablet;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet;

  static bool isSmallScreen(BuildContext context) =>
      MediaQuery.of(context).size.width < 360;

  static bool isLargeScreen(BuildContext context) =>
      MediaQuery.of(context).size.width > 600;
}

/// Responsive container that adapts to screen size
class WMSResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;
  final bool centerContent;

  const WMSResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveMaxWidth = maxWidth ?? 
        (WMSBreakpoints.isDesktop(context) ? 1200 : double.infinity);

    Widget container = Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
      padding: padding ?? EdgeInsets.symmetric(
        horizontal: WMSBreakpoints.isMobile(context) ? 16 : 24,
        vertical: 16,
      ),
      child: child,
    );

    return centerContent && screenWidth > effectiveMaxWidth
        ? Center(child: container)
        : container;
  }
}

/// Safe area wrapper with consistent padding
class WMSSafeArea extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final Color? backgroundColor;

  const WMSSafeArea({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: SafeArea(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: child,
      ),
    );
  }
}

/// Keyboard padding wrapper
class WMSKeyboardPadding extends StatelessWidget {
  final Widget child;
  final double? minPadding;

  const WMSKeyboardPadding({
    super.key,
    required this.child,
    this.minPadding,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final effectivePadding = bottomPadding > 0 
        ? bottomPadding + (minPadding ?? 16)
        : minPadding ?? 0;

    return Padding(
      padding: EdgeInsets.only(bottom: effectivePadding),
      child: child,
    );
  }
}

/// Grid layout for responsive card display
class WMSResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? fixedColumnCount;
  final double? maxItemWidth;
  final double? minItemWidth;

  const WMSResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.fixedColumnCount,
    this.maxItemWidth,
    this.minItemWidth,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    int columnCount;
    if (fixedColumnCount != null) {
      columnCount = fixedColumnCount!;
    } else {
      final effectiveMinWidth = minItemWidth ?? 280;
      final effectiveMaxWidth = maxItemWidth ?? 400;
      
      // Calculate optimal column count based on screen width
      columnCount = (screenWidth / effectiveMinWidth).floor();
      columnCount = columnCount.clamp(1, (screenWidth / effectiveMaxWidth).ceil());
    }

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children.map((child) {
        final itemWidth = (screenWidth - (spacing * (columnCount - 1))) / columnCount;
        return SizedBox(
          width: itemWidth,
          child: child,
        );
      }).toList(),
    );
  }
}

/// Staggered grid for cards with varying heights
class WMSStaggeredGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final int columnCount;

  const WMSStaggeredGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.columnCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    final List<List<Widget>> columns = List.generate(columnCount, (_) => []);
    
    for (int i = 0; i < children.length; i++) {
      columns[i % columnCount].add(children[i]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columns.map((column) {
        return Expanded(
          child: Column(
            children: column.map((child) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: spacing,
                  right: column != columns.last ? spacing / 2 : 0,
                  left: column != columns.first ? spacing / 2 : 0,
                ),
                child: child,
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

/// Empty state widget
class WMSEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? illustration;
  final Widget? action;

  const WMSEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.illustration,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (illustration != null)
              illustration!
            else if (icon != null)
              Icon(
                icon,
                size: 64,
                color: WMSColors.textSecondary,
              ),
            
            const SizedBox(height: 24),
            
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: WMSColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: WMSColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state widget
class WMSErrorState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;
  final VoidCallback? onRetry;

  const WMSErrorState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: WMSColors.errorRed,
            ),
            
            const SizedBox(height: 24),
            
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: WMSColors.errorRed,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: WMSColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            const SizedBox(height: 24),
            
            if (action != null)
              action!
            else if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: WMSColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Divider with label
class WMSLabeledDivider extends StatelessWidget {
  final String label;
  final Color? color;
  final double? thickness;

  const WMSLabeledDivider({
    super.key,
    required this.label,
    this.color,
    this.thickness,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: color ?? WMSColors.outline,
            thickness: thickness ?? 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: WMSColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: color ?? WMSColors.outline,
            thickness: thickness ?? 1,
          ),
        ),
      ],
    );
  }
}

/// Spacing constants
class WMSSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static Widget vertical(double height) => SizedBox(height: height);
  static Widget horizontal(double width) => SizedBox(width: width);

  static const Widget verticalXS = SizedBox(height: xs);
  static const Widget verticalSM = SizedBox(height: sm);
  static const Widget verticalMD = SizedBox(height: md);
  static const Widget verticalLG = SizedBox(height: lg);
  static const Widget verticalXL = SizedBox(height: xl);
  static const Widget verticalXXL = SizedBox(height: xxl);

  static const Widget horizontalXS = SizedBox(width: xs);
  static const Widget horizontalSM = SizedBox(width: sm);
  static const Widget horizontalMD = SizedBox(width: md);
  static const Widget horizontalLG = SizedBox(width: lg);
  static const Widget horizontalXL = SizedBox(width: xl);
  static const Widget horizontalXXL = SizedBox(width: xxl);
}

/// Extension for responsive design
extension ResponsiveExtension on BuildContext {
  bool get isMobile => WMSBreakpoints.isMobile(this);
  bool get isTablet => WMSBreakpoints.isTablet(this);
  bool get isDesktop => WMSBreakpoints.isDesktop(this);
  bool get isSmallScreen => WMSBreakpoints.isSmallScreen(this);
  bool get isLargeScreen => WMSBreakpoints.isLargeScreen(this);

  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
}