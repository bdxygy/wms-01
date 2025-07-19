import 'package:flutter/material.dart';
import '../../../generated/app_localizations.dart';
import '../../../core/widgets/main_navigation_scaffold.dart';

class ChecksScreen extends StatelessWidget {
  const ChecksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return NavigationAwareScaffold(
      title: l10n.checks,
      currentRoute: 'checks',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.productCheckComingSoon,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}