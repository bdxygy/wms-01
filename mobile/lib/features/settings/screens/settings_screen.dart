import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../generated/app_localizations.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/providers/store_context_provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/models/currency.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/widgets/main_navigation_scaffold.dart';
import '../../../core/widgets/theme_switcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();
    final storeProvider = context.watch<StoreContextProvider>();
    final user = authProvider.currentUser;

    return NavigationAwareScaffold(
      title: l10n.settings,
      currentRoute: 'settings',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            _buildUserProfileSection(l10n, user?.name ?? l10n.name, user?.role.toString() ?? l10n.roleUnknown),
            
            const SizedBox(height: 24),
            
            // Store Selection Section (for non-owner users)
            if (!authProvider.isOwner) ...[
              _buildStoreSelectionSection(l10n, storeProvider),
              const SizedBox(height: 24),
            ],
            
            // Account Settings Section
            _buildAccountSettingsSection(l10n),
            
            const SizedBox(height: 24),
            
            // App Settings Section
            _buildAppSettingsSection(l10n),
            
            const SizedBox(height: 24),
            
            // About Section
            _buildAboutSection(l10n),
            
            const SizedBox(height: 32),
            
            // Logout Button
            _buildLogoutSection(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileSection(AppLocalizations l10n, String userName, String role) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.userProfile,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getRoleColor(role).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(
                            color: _getRoleColor(role),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _editProfile(l10n),
                  icon: const Icon(Icons.edit),
                  tooltip: l10n.editProfile,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreSelectionSection(AppLocalizations l10n, StoreContextProvider storeProvider) {
    final currentStore = storeProvider.selectedStore;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.storeSelection,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.store,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.currentStore,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSecondaryContainer.withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          currentStore?.name ?? l10n.noStoreSelected,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _changeStore(),
                    child: Text(l10n.change),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSettingsSection(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.accountSettings,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              icon: Icons.lock,
              title: l10n.changePassword,
              subtitle: l10n.updatePassword,
              onTap: () => _changePassword(l10n),
            ),
            const Divider(),
            _buildSettingsItem(
              icon: Icons.email,
              title: l10n.emailSettings,
              subtitle: l10n.manageEmailPreferences,
              onTap: () => _emailSettings(l10n),
            ),
            const Divider(),
            _buildSettingsItem(
              icon: Icons.notifications,
              title: l10n.notifications,
              subtitle: l10n.manageNotificationPreferences,
              onTap: () => _notificationSettings(l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSettingsSection(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appSettingsSection,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildThemeSettingsItem(l10n),
            const Divider(),
            _buildCurrencySettingsItem(l10n),
            const Divider(),
            _buildSettingsItem(
              icon: Icons.language,
              title: l10n.language,
              subtitle: l10n.changeAppLanguage,
              onTap: () => _languageSettings(l10n),
            ),
            const Divider(),
            _buildSettingsItem(
              icon: Icons.storage,
              title: l10n.storage,
              subtitle: l10n.manageLocalData,
              onTap: () => _storageSettings(l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.about,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              icon: Icons.info,
              title: l10n.appVersion,
              subtitle: l10n.appVersionNumber,
              onTap: () => _showAppInfo(l10n),
            ),
            const Divider(),
            _buildSettingsItem(
              icon: Icons.help,
              title: l10n.helpAndSupport,
              subtitle: l10n.getHelpOrSupport,
              onTap: () => _helpAndSupport(l10n),
            ),
            const Divider(),
            _buildSettingsItem(
              icon: Icons.privacy_tip,
              title: l10n.privacyPolicy,
              subtitle: l10n.viewPrivacyPolicy,
              onTap: () => _privacyPolicy(l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutSection(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _handleLogout(l10n),
        icon: const Icon(Icons.logout),
        label: Text(l10n.logout),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildThemeSettingsItem(AppLocalizations l10n) {
    return const WMSThemeSettingsTile();
  }

  Widget _buildCurrencySettingsItem(AppLocalizations l10n) {
    final appProvider = context.watch<AppProvider>();
    return ListTile(
      leading: const Icon(Icons.attach_money),
      title: const Text('Currency'),
      subtitle: Text('Current: ${appProvider.currency.displayName}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showCurrencySelector(context, appProvider),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toUpperCase()) {
      case 'OWNER':
        return Colors.purple;
      case 'ADMIN':
        return Colors.blue;
      case 'STAFF':
        return Colors.green;
      case 'CASHIER':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _editProfile(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.editProfileComingSoon)),
    );
  }

  void _changeStore() {
    AppRouter.goToStoreSelection(context);
  }

  void _changePassword(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.changePasswordComingSoon)),
    );
  }

  void _emailSettings(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.emailSettingsComingSoon)),
    );
  }

  void _notificationSettings(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.notificationSettingsComingSoon)),
    );
  }

  void _languageSettings(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.languageSettingsComingSoon)),
    );
  }

  void _storageSettings(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.storageSettingsComingSoon)),
    );
  }

  void _showAppInfo(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.appInformation),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.warehouseManagementSystem),
            const SizedBox(height: 8),
            Text(l10n.appVersionNumber),
            const SizedBox(height: 8),
            Text(l10n.appDescription),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _helpAndSupport(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.helpAndSupportComingSoon)),
    );
  }

  void _privacyPolicy(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.privacyPolicyComingSoon)),
    );
  }

  void _showCurrencySelector(BuildContext context, AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: SupportedCurrencies.all.length,
            itemBuilder: (context, index) {
              final currency = SupportedCurrencies.all[index];
              final isSelected = currency == appProvider.currency;
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isSelected 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Text(
                    currency.symbol,
                    style: TextStyle(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(currency.name),
                subtitle: Text(currency.code),
                trailing: isSelected 
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  appProvider.setCurrency(currency);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Currency changed to ${currency.name}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(AppLocalizations l10n) async {
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();

      if (mounted) {
        AppRouter.goToLogin(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToLogout(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}