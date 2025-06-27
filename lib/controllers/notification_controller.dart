import '../models/models.dart';
import '../services/services.dart';

class NotificationController {
  final NotificationService _notificationService = NotificationService();
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  
  // Singleton pattern
  static final NotificationController _instance = NotificationController._internal();
  factory NotificationController() => _instance;
  NotificationController._internal();
  
  Future<void> loadNotifications() async {
    _isLoading = true;
    try {
      _notifications = await _notificationService.getAllNotifications();
    } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      _isLoading = false;
    }
  }
  
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _notificationService.markAsRead(notificationId);
    }
  }
  
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _notificationService.markAllAsRead();
  }
  
  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _notificationService.deleteNotification(notificationId);
  }
  
  void clearAllNotifications() {
    _notifications.clear();
    _notificationService.clearAllNotifications();
  }
  
  List<NotificationModel> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }
  
  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }
}
