import 'package:flutter/material.dart';

import '../theme/theme_colors.dart';
import '../theme/typography.dart';

/// Loading components for the WMS application
/// Provides consistent loading states and skeleton screens

/// Standard loading indicator
class WMSLoadingIndicator extends StatelessWidget {
  final double? size;
  final Color? color;
  final double? strokeWidth;

  const WMSLoadingIndicator({
    super.key,
    this.size,
    this.color,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? 24,
      height: size ?? 24,
      child: CircularProgressIndicator(
        color: color ?? WMSColors.primaryBlue,
        strokeWidth: strokeWidth ?? 2.5,
      ),
    );
  }
}

/// Loading overlay for entire screens
class WMSLoadingOverlay extends StatelessWidget {
  final String? message;
  final bool isVisible;
  final Widget child;

  const WMSLoadingOverlay({
    super.key,
    this.message,
    this.isVisible = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isVisible)
          Container(
            color: Colors.black54,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: WMSColors.shadowMedium,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const WMSLoadingIndicator(size: 40),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message!,
                        style: WMSTypography.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Skeleton loader for list items
class WMSSkeletonLoader extends StatefulWidget {
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

  const WMSSkeletonLoader({
    super.key,
    this.height,
    this.width,
    this.borderRadius,
  });

  @override
  State<WMSSkeletonLoader> createState() => _WMSSkeletonLoaderState();
}

class _WMSSkeletonLoaderState extends State<WMSSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height ?? 16,
          width: widget.width,
          decoration: BoxDecoration(
            color: WMSColors.outline.withOpacity(_animation.value * 0.3),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}

/// Product card skeleton
class WMSProductCardSkeleton extends StatelessWidget {
  const WMSProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const WMSSkeletonLoader(
              height: 60,
              width: 60,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const WMSSkeletonLoader(height: 16, width: double.infinity),
                  const SizedBox(height: 8),
                  const WMSSkeletonLoader(height: 12, width: 120),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const WMSSkeletonLoader(height: 14, width: 80),
                      const Spacer(),
                      const WMSSkeletonLoader(height: 14, width: 60),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Transaction card skeleton
class WMSTransactionCardSkeleton extends StatelessWidget {
  const WMSTransactionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const WMSSkeletonLoader(height: 14, width: 100),
                const Spacer(),
                const WMSSkeletonLoader(height: 14, width: 80),
              ],
            ),
            const SizedBox(height: 12),
            const WMSSkeletonLoader(height: 20, width: 150),
            const SizedBox(height: 8),
            const WMSSkeletonLoader(height: 12, width: 200),
            const SizedBox(height: 8),
            Row(
              children: [
                const WMSSkeletonLoader(height: 12, width: 60),
                const Spacer(),
                const WMSSkeletonLoader(height: 12, width: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// List skeleton with multiple items
class WMSListSkeleton extends StatelessWidget {
  final int itemCount;
  final Widget itemSkeleton;

  const WMSListSkeleton({
    super.key,
    this.itemCount = 5,
    required this.itemSkeleton,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => itemSkeleton,
    );
  }
}

/// Loading state for specific operations
class WMSOperationLoading extends StatelessWidget {
  final String operation;
  final IconData? icon;

  const WMSOperationLoading({
    super.key,
    required this.operation,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 48,
              color: WMSColors.textSecondary,
            ),
            const SizedBox(height: 16),
          ],
          const WMSLoadingIndicator(size: 32),
          const SizedBox(height: 16),
          Text(
            operation,
            style: WMSTypography.bodyMedium.copyWith(
              color: WMSColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Inline loading for buttons and small components
class WMSInlineLoading extends StatelessWidget {
  final String? text;
  final double size;
  final Color? color;

  const WMSInlineLoading({
    super.key,
    this.text,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        WMSLoadingIndicator(
          size: size,
          color: color,
          strokeWidth: 2,
        ),
        if (text != null) ...[
          const SizedBox(width: 8),
          Text(
            text!,
            style: WMSTypography.bodySmall.copyWith(color: color),
          ),
        ],
      ],
    );
  }
}

/// Pull to refresh indicator
class WMSRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;

  const WMSRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? WMSColors.primaryBlue,
      backgroundColor: Theme.of(context).colorScheme.surface,
      strokeWidth: 2.5,
      child: child,
    );
  }
}