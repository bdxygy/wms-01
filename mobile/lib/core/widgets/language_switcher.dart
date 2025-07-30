import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../../generated/app_localizations.dart';

/// Supported languages in the application
class SupportedLanguages {
  static const List<LanguageOption> all = [
    LanguageOption(
      locale: Locale('en', 'US'),
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸',
    ),
    LanguageOption(
      locale: Locale('id', 'ID'),
      name: 'Indonesian',
      nativeName: 'Bahasa Indonesia',
      flag: '🇮🇩',
    ),
  ];

  static LanguageOption fromLocale(Locale locale) {
    return all.firstWhere(
      (lang) => lang.locale.languageCode == locale.languageCode,
      orElse: () => all.first, // Default to English
    );
  }
}

class LanguageOption {
  final Locale locale;
  final String name;
  final String nativeName;
  final String flag;

  const LanguageOption({
    required this.locale,
    required this.name,
    required this.nativeName,
    required this.flag,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LanguageOption &&
           other.locale.languageCode == locale.languageCode &&
           other.locale.countryCode == locale.countryCode;
  }

  @override
  int get hashCode => Object.hash(locale.languageCode, locale.countryCode);
}

/// Modern Language Settings Tile Widget for Settings Screen
/// 
/// Features:
/// - Shows current language with flag and native name
/// - Opens modern language selection dialog
/// - Smooth animations and Material Design 3 styling
/// - Instant language switching with persistence
class LanguageSettingsTile extends StatelessWidget {
  const LanguageSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final currentLanguage = SupportedLanguages.fromLocale(appProvider.locale);
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.language_rounded,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          size: 20,
        ),
      ),
      title: Text(
        l10n.language,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Row(
        children: [
          Text(
            currentLanguage.flag,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              currentLanguage.nativeName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onTap: () => _showLanguageSelector(context, appProvider, currentLanguage),
    );
  }

  void _showLanguageSelector(
    BuildContext context, 
    AppProvider appProvider, 
    LanguageOption currentLanguage
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => LanguageSelectorDialog(
        currentLanguage: currentLanguage,
        onLanguageSelected: (language) {
          appProvider.setLocale(language.locale);
          Navigator.of(dialogContext).pop();
          
          // Show success message
          final newL10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Text(language.flag),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${newL10n.languageChangedTo} ${language.name}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Modern Language Selector Dialog with Beautiful UI
/// 
/// Features:
/// - Material Design 3 styling with proper theming
/// - Flag emojis and native language names
/// - Smooth selection animations
/// - Visual feedback for current selection
/// - Responsive design for different screen sizes
class LanguageSelectorDialog extends StatelessWidget {
  final LanguageOption currentLanguage;
  final Function(LanguageOption) onLanguageSelected;

  const LanguageSelectorDialog({
    super.key,
    required this.currentLanguage,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.language_rounded,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.selectLanguage,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.selectLanguageSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ...SupportedLanguages.all.map((language) {
              final isSelected = language == currentLanguage;
              return _buildLanguageOption(
                context,
                language,
                isSelected,
                onLanguageSelected,
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    LanguageOption language,
    bool isSelected,
    Function(LanguageOption) onSelected,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected 
          ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha:0.5)
          : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => onSelected(language),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withValues(alpha:0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Flag emoji
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha:0.2),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      language.flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Language info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected 
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        language.nativeName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Selection indicator
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 16,
                    ),
                  )
                else
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha:0.3),
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Quick Language Toggle Widget for Floating Actions
/// 
/// Features:
/// - Shows current language flag
/// - Quick toggle between English and Indonesian
/// - Compact design for toolbars or floating buttons
class QuickLanguageToggle extends StatelessWidget {
  const QuickLanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final currentLanguage = SupportedLanguages.fromLocale(appProvider.locale);

    return IconButton(
      onPressed: () {
        // Toggle between English and Indonesian
        appProvider.toggleLanguage();
        
        final newLanguage = SupportedLanguages.fromLocale(appProvider.locale);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text(newLanguage.flag),
                const SizedBox(width: 8),
                Text('${AppLocalizations.of(context)!.switchedTo} ${newLanguage.name}'),
              ],
            ),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      icon: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          currentLanguage.flag,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      tooltip: 'Switch Language',
    );
  }
}