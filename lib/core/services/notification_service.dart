import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService {
  static NotificationService get instance => Get.find<NotificationService>();
  
  final RxList<NotificationModel> _notifications = <NotificationModel>[].obs;
  final RxInt _unreadCount = 0.obs;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount.value;

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    // Add some sample notifications
    _notifications.addAll([
      NotificationModel(
        id: '1',
        title: 'Emergency Request Confirmed',
        message: 'Your emergency request has been received and ambulance is being dispatched.',
        type: NotificationType.emergency,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
      NotificationModel(
        id: '2',
        title: 'Ambulance Assigned',
        message: 'Ambulance MH-12-AB-1234 has been assigned to your emergency request.',
        type: NotificationType.ambulance,
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        isRead: false,
      ),
      NotificationModel(
        id: '3',
        title: 'Driver En Route',
        message: 'Driver Rajesh Kumar is on the way to your location. ETA: 8 minutes.',
        type: NotificationType.update,
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        isRead: false,
      ),
    ]);
    _updateUnreadCount();
  }

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    _updateUnreadCount();
    
    // Show in-app notification
    _showInAppNotification(notification);
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _updateUnreadCount();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _updateUnreadCount();
  }

  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _updateUnreadCount();
  }

  void clearAllNotifications() {
    _notifications.clear();
    _updateUnreadCount();
  }

  void _updateUnreadCount() {
    _unreadCount.value = _notifications.where((n) => !n.isRead).length;
  }

  void _showInAppNotification(NotificationModel notification) {
    Get.snackbar(
      notification.title,
      notification.message,
      backgroundColor: _getNotificationColor(notification.type),
      colorText: Colors.white,
      icon: Icon(
        _getNotificationIcon(notification.type),
        color: Colors.white,
      ),
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.emergency:
        return const Color(0xFFFF5252);
      case NotificationType.ambulance:
        return const Color(0xFF2196F3);
      case NotificationType.update:
        return const Color(0xFF4CAF50);
      case NotificationType.warning:
        return const Color(0xFFFF9800);
      case NotificationType.info:
        return const Color(0xFF607D8B);
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.emergency:
        return Icons.emergency;
      case NotificationType.ambulance:
        return Icons.local_shipping;
      case NotificationType.update:
        return Icons.update;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info;
    }
  }

  // Simulate real-time notifications for emergency scenarios
  void simulateEmergencyNotifications(String requestId) {
    // Ambulance dispatched
    Future.delayed(const Duration(seconds: 30), () {
      addNotification(NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Ambulance Dispatched',
        message: 'Ambulance has been dispatched to your location. Request ID: $requestId',
        type: NotificationType.ambulance,
        timestamp: DateTime.now(),
        isRead: false,
      ));
    });

    // Driver en route
    Future.delayed(const Duration(minutes: 2), () {
      addNotification(NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Driver En Route',
        message: 'Driver is on the way to your location. ETA: 6 minutes.',
        type: NotificationType.update,
        timestamp: DateTime.now(),
        isRead: false,
      ));
    });

    // Driver arriving
    Future.delayed(const Duration(minutes: 5), () {
      addNotification(NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Ambulance Arriving',
        message: 'Ambulance is arriving at your location in 2 minutes.',
        type: NotificationType.update,
        timestamp: DateTime.now(),
        isRead: false,
      ));
    });

    // Driver arrived
    Future.delayed(const Duration(minutes: 7), () {
      addNotification(NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Ambulance Arrived',
        message: 'Ambulance has arrived at your location. Please proceed to the vehicle.',
        type: NotificationType.emergency,
        timestamp: DateTime.now(),
        isRead: false,
      ));
    });
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
    this.data,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}

enum NotificationType {
  emergency,
  ambulance,
  update,
  warning,
  info,
}
