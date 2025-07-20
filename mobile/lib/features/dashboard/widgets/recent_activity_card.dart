import 'package:flutter/material.dart';

class ActivityItem {
  final String title;
  final String subtitle;
  final String timestamp;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const ActivityItem({
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.icon,
    this.iconColor,
    this.onTap,
  });
}

class RecentActivityCard extends StatelessWidget {
  final String title;
  final String activityType;
  final List<ActivityItem>? activities;
  final VoidCallback? onViewAll;
  final VoidCallback? onRefresh;

  const RecentActivityCard({
    super.key,
    required this.title,
    required this.activityType,
    this.activities,
    this.onViewAll,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final hasActivities = activities != null && activities!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded( // Make title flexible to prevent overflow
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2, // Allow title to wrap to 2 lines if needed
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8), // Small spacing instead of Spacer
            Row( // Group buttons to manage their space
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onRefresh != null)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: onRefresh,
                    tooltip: 'Refresh',
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ), // Smaller button constraints
                  ),
                if (onViewAll != null && hasActivities)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text(
                      'View All',
                      style: TextStyle(fontSize: 13), // Slightly smaller text
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        Card(
          child: hasActivities
              ? _buildActivityList(context)
              : _buildEmptyState(context),
        ),
      ],
    );
  }

  Widget _buildActivityList(BuildContext context) {
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities!.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final activity = activities![index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: (activity.iconColor ?? Theme.of(context).colorScheme.primary)
                    .withValues(alpha: 0.1),
                child: Icon(
                  activity.icon,
                  color: activity.iconColor ?? Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              title: Text(
                activity.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.timestamp,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              trailing: activity.onTap != null
                  ? const Icon(Icons.chevron_right)
                  : null,
              onTap: activity.onTap,
            );
          },
        ),
        
        if (onViewAll != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onViewAll,
                child: const Text('View All Activity'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    String emptyMessage;
    String emptySubtitle;
    IconData emptyIcon;

    switch (activityType) {
      case 'multi-store':
        emptyMessage = 'No recent activity across stores';
        emptySubtitle = 'Activity from all your stores will appear here';
        emptyIcon = Icons.store_outlined;
        break;
      case 'store-specific':
        emptyMessage = 'No recent store activity';
        emptySubtitle = 'Store transactions and updates will appear here';
        emptyIcon = Icons.business_outlined;
        break;
      case 'transactions':
        emptyMessage = 'No recent transactions';
        emptySubtitle = 'Your recent transactions will appear here';
        emptyIcon = Icons.receipt_outlined;
        break;
      case 'product-checks':
        emptyMessage = 'No recent product checks';
        emptySubtitle = 'Your product verification activities will appear here';
        emptyIcon = Icons.fact_check_outlined;
        break;
      default:
        emptyMessage = 'No recent activity';
        emptySubtitle = 'Your recent activities will appear here';
        emptyIcon = Icons.inbox_outlined;
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Icon(
            emptyIcon,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            emptyMessage,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            emptySubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          
          if (onRefresh != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ],
      ),
    );
  }
}