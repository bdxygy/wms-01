import 'package:flutter/material.dart';

import '../../../core/models/user.dart';
import '../../../core/widgets/cards.dart';

/// Card widget for displaying user information in lists
class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const UserCard({
    super.key,
    required this.user,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return WMSUserCard(
      name: user.name,
      email: '@${user.username}',
      role: user.roleString,
      isActive: user.isActive,
      onTap: onTap,
      actions: _buildActions(),
    );
  }

  List<Widget>? _buildActions() {
    final actions = <Widget>[];
    
    if (onEdit != null) {
      actions.add(
        IconButton(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      );
    }
    
    if (onDelete != null) {
      actions.add(
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      );
    }
    
    return actions.isEmpty ? null : actions;
  }
}