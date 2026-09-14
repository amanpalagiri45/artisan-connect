import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/notification.dart';
import '../services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  Timer? _pollingTimer;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  void startPolling({Duration interval = const Duration(seconds: 20)}) {
    _pollingTimer?.cancel();
    fetchNotifications();
    fetchUnreadCount();
    _pollingTimer = Timer.periodic(interval, (_) {
      fetchUnreadCount();
      fetchNotifications(silent: true);
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> fetchNotifications({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final res = await ApiService.get(ApiConfig.notifications);
      if (res is List) {
        _notifications = res.map((item) => AppNotification.fromJson(item)).toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final res = await ApiService.get(ApiConfig.unreadCount);
      _unreadCount = res['unread_count'] ?? 0;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await ApiService.put('${ApiConfig.notifications}/$notificationId/read');
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final updated = AppNotification(
          id: _notifications[index].id,
          userId: _notifications[index].userId,
          title: _notifications[index].title,
          message: _notifications[index].message,
          notificationType: _notifications[index].notificationType,
          referenceId: _notifications[index].referenceId,
          isRead: true,
          createdAt: _notifications[index].createdAt,
        );
        _notifications[index] = updated;
        if (_unreadCount > 0) _unreadCount--;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await ApiService.put(ApiConfig.markAllRead);
      _unreadCount = 0;
      _notifications = _notifications.map((n) => AppNotification(
        id: n.id,
        userId: n.userId,
        title: n.title,
        message: n.message,
        notificationType: n.notificationType,
        referenceId: n.referenceId,
        isRead: true,
        createdAt: n.createdAt,
      )).toList();
      notifyListeners();
    } catch (_) {}
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
