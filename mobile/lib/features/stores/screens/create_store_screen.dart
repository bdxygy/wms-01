import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../generated/app_localizations.dart';
import '../widgets/store_form.dart';

class CreateStoreScreen extends StatelessWidget {
  const CreateStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createStore),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: StoreForm(
        onSuccess: () {
          // Navigate back to stores list
          context.goNamed('stores');
        },
      ),
    );
  }
}