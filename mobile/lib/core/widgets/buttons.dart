import 'package:flutter/material.dart';

import '../theme/theme_colors.dart';
import '../theme/typography.dart';

/// Custom button components for the WMS application
/// Provides consistent button styles and behavior across the app

/// Primary button - used for main actions
class WMSPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const WMSPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: WMSColors.primaryBlue,
        foregroundColor: Colors.white,
        disabledBackgroundColor: WMSColors.textDisabled,
        disabledForegroundColor: Colors.white,
        elevation: 2,
        shadowColor: WMSColors.shadowMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: Size(0, height ?? 48),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: WMSTypography.buttonMedium.copyWith(color: Colors.white),
                ),
              ],
            ),
    );

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}

/// Secondary button - used for secondary actions
class WMSSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const WMSSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: WMSColors.primaryBlue,
        disabledForegroundColor: WMSColors.textDisabled,
        side: const BorderSide(color: WMSColors.primaryBlue, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: Size(0, height ?? 48),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(WMSColors.primaryBlue),
              ),
            )
          : Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: WMSTypography.buttonMedium.copyWith(color: WMSColors.primaryBlue),
                ),
              ],
            ),
    );

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}

/// Text button - used for subtle actions
class WMSTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;

  const WMSTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.textColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? WMSColors.primaryBlue;

    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        disabledForegroundColor: WMSColors.textDisabled,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: isLoading
          ? SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 4),
                ],
                Text(
                  text,
                  style: WMSTypography.buttonSmall.copyWith(color: color),
                ),
              ],
            ),
    );
  }
}

/// Icon button - used for icon-only actions
class WMSIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final String? tooltip;
  final EdgeInsetsGeometry? padding;

  const WMSIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.tooltip,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final Widget button = IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: iconColor ?? WMSColors.iconColor,
        size: size ?? 24,
      ),
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: iconColor ?? WMSColors.iconColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: padding ?? const EdgeInsets.all(8),
      ),
    );

    return tooltip != null
        ? Tooltip(
            message: tooltip!,
            child: button,
          )
        : button;
  }
}

/// Floating action button with WMS styling
class WMSFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final bool isExtended;
  final String? label;
  final bool isLoading;

  const WMSFloatingActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.isExtended = false,
    this.label,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isExtended && label != null) {
      return FloatingActionButton.extended(
        onPressed: isLoading ? null : onPressed,
        backgroundColor: WMSColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(icon),
        label: Text(
          label!,
          style: WMSTypography.buttonMedium.copyWith(color: Colors.white),
        ),
      );
    }

    final fab = FloatingActionButton(
      onPressed: isLoading ? null : onPressed,
      backgroundColor: WMSColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(icon),
    );

    return tooltip != null
        ? Tooltip(
            message: tooltip!,
            child: fab,
          )
        : fab;
  }
}

/// Destructive button - used for delete/remove actions
class WMSDestructiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const WMSDestructiveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: WMSColors.errorRed,
        foregroundColor: Colors.white,
        disabledBackgroundColor: WMSColors.textDisabled,
        disabledForegroundColor: Colors.white,
        elevation: 2,
        shadowColor: WMSColors.shadowMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: Size(0, height ?? 48),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: WMSTypography.buttonMedium.copyWith(color: Colors.white),
                ),
              ],
            ),
    );

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}

/// Success button - used for confirmation actions
class WMSSuccessButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const WMSSuccessButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: WMSColors.successGreen,
        foregroundColor: Colors.white,
        disabledBackgroundColor: WMSColors.textDisabled,
        disabledForegroundColor: Colors.white,
        elevation: 2,
        shadowColor: WMSColors.shadowMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: Size(0, height ?? 48),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: WMSTypography.buttonMedium.copyWith(color: Colors.white),
                ),
              ],
            ),
    );

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}