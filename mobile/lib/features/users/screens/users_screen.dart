import 'package:flutter/material.dart';
import '../../../core/widgets/main_navigation_scaffold.dart';
import 'users_list_screen.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const NavigationAwareScaffold(
      title: 'Users',
      currentRoute: 'users',
      body: UsersListScreen(),
    );
  }
}