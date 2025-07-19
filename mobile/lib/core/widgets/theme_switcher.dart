import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../theme/theme_colors.dart';
import '../theme/typography.dart';
import '../theme/icons.dart';

/// Theme switcher widget for changing between light, dark, and system themes
class WMSThemeSwitcher extends StatelessWidget {
  final bool showLabel;
  final Axis direction;

  const WMSThemeSwitcher({
    super.key,
    this.showLabel = true,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return direction == Axis.horizontal
            ? _buildHorizontalSwitcher(context, appProvider)
            : _buildVerticalSwitcher(context, appProvider);
      },
    );
  }

  Widget _buildHorizontalSwitcher(BuildContext context, AppProvider appProvider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          Text(
            'Theme',
            style: WMSTypography.bodyMedium,
          ),
          const SizedBox(width: 16),
        ],
        _buildThemeToggleButtons(context, appProvider, Axis.horizontal),
      ],
    );
  }

  Widget _buildVerticalSwitcher(BuildContext context, AppProvider appProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Text(
            'Theme',
            style: WMSTypography.bodyMedium,
          ),
          const SizedBox(height: 12),
        ],
        _buildThemeToggleButtons(context, appProvider, Axis.vertical),
      ],
    );
  }

  Widget _buildThemeToggleButtons(BuildContext context, AppProvider appProvider, Axis axis) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? WMSColors.surfaceVariantDark : WMSColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: WMSColors.outline.withOpacity(0.3),
        ),
      ),
      child: axis == Axis.horizontal
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: _buildThemeButtons(appProvider),
            )
          : Column(
              children: _buildThemeButtons(appProvider),
            ),
    );
  }

  List<Widget> _buildThemeButtons(AppProvider appProvider) {
    return [
      _ThemeButton(
        icon: WMSIcons.themeFilled,
        label: 'Light',
        isSelected: appProvider.themeMode == ThemeMode.light,
        onPressed: () => appProvider.setThemeMode(ThemeMode.light),
      ),
      _ThemeButton(
        icon: Icons.dark_mode,
        label: 'Dark',
        isSelected: appProvider.themeMode == ThemeMode.dark,
        onPressed: () => appProvider.setThemeMode(ThemeMode.dark),
      ),
      _ThemeButton(
        icon: Icons.auto_mode,
        label: 'System',
        isSelected: appProvider.themeMode == ThemeMode.system,
        onPressed: () => appProvider.setThemeMode(ThemeMode.system),
      ),
    ];
  }
}

/// Individual theme button
class _ThemeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _ThemeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(4),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? WMSColors.primaryBlue.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: WMSColors.primaryBlue, width: 1)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected 
                    ? WMSColors.primaryBlue
                    : (isDark ? WMSColors.textSecondaryDark : WMSColors.textSecondary),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: WMSTypography.bodySmall.copyWith(
                  color: isSelected 
                      ? WMSColors.primaryBlue
                      : (isDark ? WMSColors.textSecondaryDark : WMSColors.textSecondary),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple theme toggle button (icon only)
class WMSThemeToggleButton extends StatelessWidget {
  final bool showTooltip;

  const WMSThemeToggleButton({
    super.key,
    this.showTooltip = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        IconData icon;
        String tooltip;

        switch (appProvider.themeMode) {
          case ThemeMode.light:
            icon = Icons.light_mode;
            tooltip = 'Switch to Dark Theme';
            break;
          case ThemeMode.dark:
            icon = Icons.dark_mode;
            tooltip = 'Switch to System Theme';
            break;
          case ThemeMode.system:
            icon = Icons.auto_mode;
            tooltip = 'Switch to Light Theme';
            break;
        }

        final button = IconButton(
          onPressed: appProvider.toggleTheme,
          icon: Icon(
            icon,
            color: isDark ? WMSColors.textColorDark : Colors.white,
          ),
        );

        return showTooltip
            ? Tooltip(
                message: tooltip,
                child: button,
              )
            : button;
      },
    );
  }
}

/// Theme mode indicator
class WMSThemeModeIndicator extends StatelessWidget {
  final bool showLabel;

  const WMSThemeModeIndicator({
    super.key,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        String modeText;
        IconData modeIcon;
        Color indicatorColor;

        switch (appProvider.themeMode) {
          case ThemeMode.light:
            modeText = 'Light Theme';
            modeIcon = Icons.light_mode;
            indicatorColor = WMSColors.warningAmber;
            break;
          case ThemeMode.dark:
            modeText = 'Dark Theme';
            modeIcon = Icons.dark_mode;
            indicatorColor = WMSColors.primaryBlue;
            break;
          case ThemeMode.system:
            modeText = 'System Theme';
            modeIcon = Icons.auto_mode;
            indicatorColor = WMSColors.successGreen;
            break;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: indicatorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: indicatorColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                modeIcon,
                size: 16,
                color: indicatorColor,
              ),
              if (showLabel) ...[
                const SizedBox(width: 6),
                Text(
                  modeText,
                  style: WMSTypography.labelSmall.copyWith(
                    color: indicatorColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Advanced theme settings tile
class WMSThemeSettingsTile extends StatelessWidget {
  const WMSThemeSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: WMSColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              WMSIcons.theme,
              color: WMSColors.primaryBlue,
            ),
          ),
          title: Text(
            'App Theme',
            style: WMSTypography.bodyMedium,
          ),
          subtitle: Text(
            _getThemeModeDescription(appProvider.themeMode),
            style: WMSTypography.bodySmall.copyWith(
              color: WMSColors.textSecondary,
            ),
          ),
          trailing: const WMSThemeModeIndicator(showLabel: false),
          onTap: () {
            _showThemeSelector(context, appProvider);
          },
        );
      },
    );
  }

  String _getThemeModeDescription(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Always use light theme';
      case ThemeMode.dark:
        return 'Always use dark theme';
      case ThemeMode.system:
        return 'Follow system settings';
    }
  }

  void _showThemeSelector(BuildContext context, AppProvider appProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Theme',
              style: WMSTypography.titleLarge,
            ),
            const SizedBox(height: 16),
            const WMSThemeSwitcher(
              showLabel: false,
              direction: Axis.vertical,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}