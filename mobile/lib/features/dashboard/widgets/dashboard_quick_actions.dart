import 'package:flutter/material.dart';

class QuickAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  const QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });
}

class DashboardQuickActions extends StatelessWidget {
  final String role;
  final List<QuickAction> actions;
  final String? title;

  const DashboardQuickActions({
    super.key,
    required this.role,
    required this.actions,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title ?? 'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Use different layouts based on number of actions
        if (actions.length <= 4)
          _buildGridLayout()
        else
          _buildListLayout(),
      ],
    );
  }

  Widget _buildGridLayout() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: actions.map((action) => _buildActionCard(action)).toList(),
    );
  }

  Widget _buildListLayout() {
    return Column(
      children: [
        // First 4 actions in grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: actions.take(4).map((action) => _buildActionCard(action)).toList(),
        ),
        
        if (actions.length > 4) ...[
          const SizedBox(height: 12),
          // Remaining actions in horizontal list
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: actions.length - 4,
              itemBuilder: (context, index) {
                final action = actions[index + 4];
                return Container(
                  width: 160,
                  margin: EdgeInsets.only(
                    right: index < actions.length - 5 ? 12 : 0,
                  ),
                  child: _buildActionCard(action),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionCard(QuickAction action) {
    return Builder(
      builder: (context) => Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: action.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  action.icon,
                  size: 32,
                  color: action.color ?? Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  action.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  action.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}