import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/notification.dart';
import '../../state/notification_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'new_inquiry':
        return Icons.mark_email_unread_outlined;
      case 'linkage_matched':
        return Icons.auto_awesome;
      case 'status_changed':
        return Icons.sync_alt;
      default:
        return Icons.notifications_none;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'new_inquiry':
        return AppTheme.primaryTerracotta;
      case 'linkage_matched':
        return AppTheme.primaryOchre;
      case 'status_changed':
        return AppTheme.sageAccent;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifProv = Provider.of<NotificationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifProv.unreadCount > 0)
            TextButton(
              onPressed: () => notifProv.markAllAsRead(),
              child: const Text('Mark all read', style: TextStyle(color: AppTheme.primaryTerracotta, fontSize: 13)),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifProv.fetchNotifications(),
            tooltip: 'Refresh Notifications',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifProv.fetchNotifications(),
        color: AppTheme.primaryTerracotta,
        child: notifProv.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTerracotta))
            : notifProv.notifications.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: notifProv.notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final notif = notifProv.notifications[index];
                      return _buildNotificationTile(notif, notifProv);
                    },
                  ),
      ),
    );
  }

  Widget _buildNotificationTile(AppNotification notif, NotificationProvider provider) {
    final timeStr = DateFormat('MMM d, h:mm a').format(notif.createdAt);
    final iconColor = _getColorForType(notif.notificationType);

    return InkWell(
      onTap: notif.isRead ? null : () => provider.markAsRead(notif.id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.white : const Color(0xFFFFF9F3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notif.isRead ? AppTheme.borderLight : AppTheme.primaryTerracotta.withOpacity(0.35),
            width: notif.isRead ? 0.8 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_getIconForType(notif.notificationType), color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryTerracotta,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.message,
                    style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, height: 1.3),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    timeStr,
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        child: const Column(
          children: [
            Icon(Icons.notifications_none, size: 60, color: AppTheme.textSecondary),
            SizedBox(height: 16),
            Text('No Notifications Yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text('Buyer inquiries and linkage matches will notify you instantly.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
