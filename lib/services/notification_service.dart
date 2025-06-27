import '../models/models.dart';

class NotificationService {
  // Mock data untuk simulasi
  static List<NotificationModel> _mockNotifications = [
    NotificationModel(
      id: '1',
      title: 'New Destination Added!',
      message: 'Discover the beauty of Sekumpul Waterfall in North Bali',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      type: NotificationType.info,
      metadata: {'iconData': 'place', 'color': 'green'},
    ),
    NotificationModel(
      id: '2',
      title: 'Booking Confirmed',
      message: 'Your trip to Mount Batur has been confirmed for tomorrow',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
      type: NotificationType.booking,
      metadata: {'iconData': 'confirmation_number', 'color': 'blue'},
    ),
    NotificationModel(
      id: '3',
      title: 'Weather Update',
      message: 'Perfect weather for your Ubud trip this weekend!',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      type: NotificationType.info,
      metadata: {'iconData': 'wb_sunny', 'color': 'orange'},
    ),
    NotificationModel(
      id: '4',
      title: 'Special Offer',
      message: 'Get 20% off for Lempuyang Temple tour this month',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      type: NotificationType.offer,
      metadata: {'iconData': 'local_offer', 'color': 'red'},
    ),
    NotificationModel(
      id: '5',
      title: 'Trip Reminder',
      message: 'Don\'t forget to bring your camera for sunset at Tanah Lot',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
      type: NotificationType.info,
      metadata: {'iconData': 'camera_alt', 'color': 'purple'},
    ),
  ];
  
  Future<List<NotificationModel>> getAllNotifications() async {
    // Simulasi delay network
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_mockNotifications);
  }
  
  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _mockNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _mockNotifications[index] = _mockNotifications[index].copyWith(isRead: true);
    }
  }
  
  Future<void> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (int i = 0; i < _mockNotifications.length; i++) {
      _mockNotifications[i] = _mockNotifications[i].copyWith(isRead: true);
    }
  }
  
  Future<void> deleteNotification(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockNotifications.removeWhere((n) => n.id == notificationId);
  }
  
  Future<void> clearAllNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockNotifications.clear();
  }
  
  Future<void> addNotification(NotificationModel notification) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockNotifications.insert(0, notification);
  }
}
