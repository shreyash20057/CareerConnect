import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/notifications_provider.dart';
import '../models/notification_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/loading_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsProvider>().startListening();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: provider.markAllRead,
              child: const Text('Mark all read',
                  style: TextStyle(fontSize: 13)),
            ),
        ],
      ),
      body: provider.loading
          ? const LoadingWidget()
          : provider.notifications.isEmpty
              ? _EmptyNotifications()
              : RefreshIndicator(
                  onRefresh: () async =>
                      provider.startListening(),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12),
                    itemCount: provider.notifications.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 2),
                    itemBuilder: (context, i) {
                      final n = provider.notifications[i];
                      return _NotifTile(
                        notification: n,
                        onTap: () {
                          provider.markRead(n.id);
                          if (n.actionId != null) {
                            context.push('/job/${n.actionId}');
                          }
                        },
                      )
                          .animate()
                          .fadeIn(
                              duration: 300.ms,
                              delay: (i * 40).ms)
                          .slideX(begin: 0.04, end: 0);
                    },
                  ),
                ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotifTile(
      {required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final n = notification;
    final info = _typeInfo(n.type);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: n.isRead
            ? Colors.transparent
            : scheme.primary.withOpacity(0.04),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: info.$2.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(info.$1, color: info.$2, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: n.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      if (!n.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    n.body,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.createdAt.timeAgo,
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant
                          .withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (IconData, Color) _typeInfo(NotificationType type) {
    switch (type) {
      case NotificationType.newMatch:
        return (Icons.auto_awesome_rounded, AppTheme.primary);
      case NotificationType.applicationUpdate:
        return (Icons.assignment_turned_in_rounded,
            AppTheme.success);
      case NotificationType.deadline:
        return (Icons.schedule_rounded, AppTheme.warning);
      case NotificationType.interview:
        return (Icons.videocam_rounded,
            const Color(0xFF6366F1));
      case NotificationType.profileTip:
        return (Icons.person_rounded, AppTheme.secondary);
      case NotificationType.general:
        return (Icons.notifications_rounded, AppTheme.primary);
    }
  }
}

class _EmptyNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none_rounded,
              size: 72,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('No notifications yet',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant)),
          const SizedBox(height: 6),
          Text('We\'ll let you know when something happens',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall),
        ],
      ),
    );
  }
}