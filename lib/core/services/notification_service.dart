import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class NotificationService extends GetxService {
  static NotificationService get instance => Get.find<NotificationService>();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final RxList<NotificationModel> _notifications = <NotificationModel>[].obs;
  final RxInt _unreadCount = 0.obs;
  StreamSubscription<QuerySnapshot>? _notificationSubscription;
  StreamSubscription<User?>? _authSubscription;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount.value;

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
    _setupAuthListener();
  }

  @override
  void onClose() {
    _notificationSubscription?.cancel();
    _authSubscription?.cancel();
    super.onClose();
  }

  void _initializeNotifications() {
    // Initialize with empty list - will be populated from Firebase
    _notifications.clear();
    _updateUnreadCount();
  }

  void _setupAuthListener() {
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _setupNotificationListener(user.uid);
        _sendWelcomeNotification(user.uid);
      } else {
        _notificationSubscription?.cancel();
        _notifications.clear();
        _updateUnreadCount();
      }
    });
  }

  void _setupNotificationListener(String userId) {
    _notificationSubscription?.cancel();
    
    _notificationSubscription = _firestore
        .collection('notifications')
        .doc(userId)
        .collection('user_notifications')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      _notifications.clear();
      
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          final notification = NotificationModel.fromFirestore(doc.id, data);
          _notifications.add(notification);
        } catch (e) {
          print('Error parsing notification: $e');
        }
      }
      
      _updateUnreadCount();
    }, onError: (error) {
      print('Error listening to notifications: $error');
    });
  }

  Future<void> addNotification(NotificationModel notification, {String? targetUserId}) async {
    try {
      final userId = targetUserId ?? _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore
          .collection('notifications')
          .doc(userId)
          .collection('user_notifications')
          .doc(notification.id)
          .set(notification.toFirestore());
      
      // Show in-app notification only for current user
      if (targetUserId == null || targetUserId == _auth.currentUser?.uid) {
        _showInAppNotification(notification);
      }
    } catch (e) {
      print('Error adding notification: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore
          .collection('notifications')
          .doc(userId)
          .collection('user_notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final batch = _firestore.batch();
      
      for (var notification in _notifications.where((n) => !n.isRead)) {
        final docRef = _firestore
            .collection('notifications')
            .doc(userId)
            .collection('user_notifications')
            .doc(notification.id);
        batch.update(docRef, {'isRead': true});
      }
      
      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  Future<void> removeNotification(String notificationId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore
          .collection('notifications')
          .doc(userId)
          .collection('user_notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      print('Error removing notification: $e');
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final batch = _firestore.batch();
      
      for (var notification in _notifications) {
        final docRef = _firestore
            .collection('notifications')
            .doc(userId)
            .collection('user_notifications')
            .doc(notification.id);
        batch.delete(docRef);
      }
      
      await batch.commit();
    } catch (e) {
      print('Error clearing all notifications: $e');
    }
  }

  void _updateUnreadCount() {
    _unreadCount.value = _notifications.where((n) => !n.isRead).length;
  }

  void _showInAppNotification(NotificationModel notification) {
    // Show popup banners for login and welcome notifications to create good user experience
    if (notification.id.contains('login_') || 
        notification.id.contains('welcome_') ||
        notification.title.toLowerCase().contains('login successful') ||
        notification.title.toLowerCase().contains('welcome')) {
      Get.snackbar(
        notification.title,
        notification.message,
        backgroundColor: _getNotificationColor(notification.type),
        colorText: Colors.white,
        icon: Icon(
          _getNotificationIcon(notification.type),
          color: Colors.white,
        ),
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    
    // Also show snackbar for important notifications (emergency, ambulance, warning)
    if (notification.type == NotificationType.emergency ||
        notification.type == NotificationType.ambulance ||
        notification.type == NotificationType.warning) {
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

  Future<void> _sendWelcomeNotification(String userId) async {
    try {
      // Check if user already has login notification today to prevent duplicates
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      final existingNotifications = await _firestore
          .collection('notifications')
          .doc(userId)
          .collection('user_notifications')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where('title', whereIn: ['Login Successful!', 'Welcome to ResQRoute!', 'Welcome, Ambulance Driver!', 'Welcome, Hospital Staff!', 'Welcome, Traffic Officer!'])
          .limit(1)
          .get();
      
      if (existingNotifications.docs.isNotEmpty) {
        print('Login/Welcome notification already sent today for user: $userId');
        return; // Don't send duplicate notifications
      }
      
      // Get user role to send appropriate welcome notification
      final userRole = await _getUserRole(userId);
      
      if (userRole == null) {
        print('Could not determine user role for welcome notification');
        return;
      }
      
      // Send both login success and welcome notifications
      await _sendRoleSpecificWelcomeNotification(userId, userRole);
      
      // Add role-specific sample notifications only if no notifications exist
      final allNotifications = await _firestore
          .collection('notifications')
          .doc(userId)
          .collection('user_notifications')
          .limit(1)
          .get();
      
      if (allNotifications.docs.isEmpty) {
        await _initializeRoleSpecificNotifications(userId, userRole);
      }
    } catch (e) {
      print('Error sending welcome notification: $e');
    }
  }

  // Helper method to determine user role
  Future<String?> _getUserRole(String userId) async {
    try {
      // First check if user is in professional collection
      final professionalDoc = await _firestore
          .collection('professional')
          .doc(userId)
          .get();
      
      if (professionalDoc.exists) {
        return professionalDoc.data()?['role'] as String?;
      }
      
      // Then check if user is in users collection (patient)
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        return 'patient';
      }
      
      return null;
    } catch (e) {
      print('Error determining user role: $e');
      return null;
    }
  }
  
  // Send role-specific welcome notifications
  Future<void> _sendRoleSpecificWelcomeNotification(String userId, String role) async {
    // Send login success notification first
    final loginNotification = NotificationModel(
      id: 'login_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Login Successful!',
      message: 'You have successfully logged in to ResQRoute.',
      type: NotificationType.info,
      timestamp: DateTime.now(),
      isRead: false,
    );
    
    await addNotification(loginNotification, targetUserId: userId);
    
    // Small delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Send role-specific welcome notification
    String welcomeTitle;
    String welcomeMessage;
    
    switch (role) {
      case 'patient':
        welcomeTitle = 'Welcome to ResQRoute!';
        welcomeMessage = 'Emergency services are ready to assist you. Stay safe and explore your dashboard.';
        break;
      case 'driver':
        welcomeTitle = 'Welcome, Ambulance Driver!';
        welcomeMessage = 'You\'re online and ready for emergency calls. New requests will appear in your dashboard.';
        break;
      case 'hospital_staff':
        welcomeTitle = 'Welcome, Hospital Staff!';
        welcomeMessage = 'Hospital dashboard is ready. Monitor incoming patients and manage bed availability.';
        break;
      case 'traffic_police':
        welcomeTitle = 'Welcome, Traffic Officer!';
        welcomeMessage = 'Traffic control system is online. Route clearance requests will appear here.';
        break;
      default:
        welcomeTitle = 'Welcome to ResQRoute!';
        welcomeMessage = 'Emergency services system is ready for you.';
    }
    
    final welcomeNotification = NotificationModel(
      id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
      title: welcomeTitle,
      message: welcomeMessage,
      type: NotificationType.info,
      timestamp: DateTime.now(),
      isRead: false,
    );
    
    await addNotification(welcomeNotification, targetUserId: userId);
  }
  
  // Initialize role-specific sample notifications
  Future<void> _initializeRoleSpecificNotifications(String userId, String role) async {
    List<NotificationModel> sampleNotifications = [];
    
    switch (role) {
      case 'patient':
        sampleNotifications = _getPatientSampleNotifications();
        break;
      case 'driver':
        sampleNotifications = _getDriverSampleNotifications();
        break;
      case 'hospital_staff':
        sampleNotifications = _getHospitalSampleNotifications();
        break;
      case 'traffic_police':
        sampleNotifications = _getTrafficPoliceSampleNotifications();
        break;
      default:
        return; // No sample notifications for unknown roles
    }
    
    for (var notification in sampleNotifications) {
      await addNotification(notification, targetUserId: userId);
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
  
  // Patient-specific sample notifications
  List<NotificationModel> _getPatientSampleNotifications() {
    return [
      NotificationModel(
        id: 'patient_sample_1_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Emergency Request Confirmed',
        message: 'Your Heart Attack emergency request has been received and ambulance is being dispatched to Andheri West, Mumbai.',
        type: NotificationType.emergency,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        isRead: false,
        data: {'requestId': 'REQ001', 'emergencyType': 'Heart Attack', 'location': 'Andheri West, Mumbai'},
      ),
      NotificationModel(
        id: 'patient_sample_2_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Ambulance Assigned',
        message: 'Ambulance MH-12-AB-1234 has been assigned to your emergency request. Driver Rajesh Kumar is preparing to depart.',
        type: NotificationType.ambulance,
        timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
        isRead: false,
        data: {'ambulanceId': 'MH-12-AB-1234', 'driverName': 'Rajesh Kumar', 'driverPhone': '+91 98765 43210'},
      ),
      NotificationModel(
        id: 'patient_sample_3_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Driver En Route',
        message: 'Driver Rajesh Kumar is on the way to your location. ETA: 8 minutes. Please stay calm and prepare for pickup.',
        type: NotificationType.update,
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        isRead: true,
        data: {'eta': '8 minutes', 'driverPhone': '+91 98765 43210', 'instruction': 'stay_calm'},
      ),
    ];
  }
  
  // Driver-specific sample notifications
  List<NotificationModel> _getDriverSampleNotifications() {
    return [
      NotificationModel(
        id: 'driver_sample_1_${DateTime.now().millisecondsSinceEpoch}',
        title: 'New Emergency Assignment',
        message: 'URGENT: Heart Attack patient at Andheri West, Mumbai. Patient: Rahul Sharma. Please proceed immediately.',
        type: NotificationType.emergency,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        isRead: false,
        data: {'requestId': 'REQ002', 'patientName': 'Rahul Sharma', 'emergencyType': 'Heart Attack', 'location': 'Andheri West, Mumbai'},
      ),
      NotificationModel(
        id: 'driver_sample_2_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Route Cleared',
        message: 'Traffic police have cleared your route to City Hospital. You may proceed at emergency speed.',
        type: NotificationType.update,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: true,
        data: {'route': 'Andheri to City Hospital', 'instruction': 'emergency_speed'},
      ),
      NotificationModel(
        id: 'driver_sample_3_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Performance Update',
        message: 'Great work! 3 emergency trips completed today. ₹1,200 earned + ₹200 bonus. Rating: 4.8★',
        type: NotificationType.info,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isRead: true,
        data: {'trips': 3, 'earnings': 1200, 'bonus': 200, 'rating': 4.8},
      ),
    ];
  }
  
  // Hospital staff sample notifications
  List<NotificationModel> _getHospitalSampleNotifications() {
    return [
      NotificationModel(
        id: 'hospital_sample_1_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Incoming Patient - HIGH Priority',
        message: 'PREPARE: Heart Attack patient Rahul Sharma arriving in 10 minutes. Please prepare emergency bay and cardiac team.',
        type: NotificationType.warning,
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        isRead: false,
        data: {'patientName': 'Rahul Sharma', 'emergencyType': 'Heart Attack', 'eta': '10 minutes', 'priority': 'high'},
      ),
      NotificationModel(
        id: 'hospital_sample_2_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Bed Availability Updated',
        message: 'ICU beds: 2 available out of 10 total. Emergency ward: 5 available out of 15 total.',
        type: NotificationType.info,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        isRead: true,
        data: {'icuBeds': 2, 'icuTotal': 10, 'emergencyBeds': 5, 'emergencyTotal': 15},
      ),
    ];
  }
  
  // Traffic police sample notifications
  List<NotificationModel> _getTrafficPoliceSampleNotifications() {
    return [
      NotificationModel(
        id: 'police_sample_1_${DateTime.now().millisecondsSinceEpoch}',
        title: 'URGENT: Route Clearance Needed',
        message: 'Emergency ambulance MH-12-AB-1234 requires immediate clearance on Highway 1 to City Hospital for Heart Attack patient.',
        type: NotificationType.emergency,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
        data: {'ambulanceId': 'MH-12-AB-1234', 'route': 'Highway 1 to City Hospital', 'emergencyType': 'Heart Attack'},
      ),
      NotificationModel(
        id: 'police_sample_2_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Emergency Alert',
        message: 'Multiple emergency requests in Sector 7. Prepare for potential route clearance requests.',
        type: NotificationType.warning,
        timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
        isRead: true,
        data: {'sector': 'Sector 7', 'alertType': 'multiple_emergencies'},
      ),
    ];
  }

  // Send emergency-related notifications
  Future<void> sendEmergencyNotification({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    final notification = NotificationModel(
      id: 'emergency_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
      data: data,
    );
    
    await addNotification(notification, targetUserId: userId);
  }

  // Send system-wide notifications
  Future<void> sendSystemNotification({
    required String title,
    required String message,
    required NotificationType type,
    List<String>? targetUserIds,
  }) async {
    try {
      if (targetUserIds != null) {
        // Send to specific users
        for (String userId in targetUserIds) {
          await sendEmergencyNotification(
            userId: userId,
            title: title,
            message: message,
            type: type,
          );
        }
      } else {
        // Send to system notifications collection for all users
        await _firestore
            .collection('system_notifications')
            .add({
          'title': title,
          'message': message,
          'type': type.name,
          'timestamp': FieldValue.serverTimestamp(),
          'isActive': true,
        });
      }
    } catch (e) {
      print('Error sending system notification: $e');
    }
  }

  // Simulate real-time notifications for emergency scenarios
  Future<void> simulateEmergencyNotifications(String requestId, {String? patientName}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final patientDisplayName = patientName ?? 'Patient';
    
    // Ambulance dispatched
    Future.delayed(const Duration(seconds: 30), () {
      addNotification(NotificationModel(
        id: 'dispatch_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Ambulance Dispatched',
        message: 'Ambulance has been dispatched to your location. Request ID: $requestId',
        type: NotificationType.ambulance,
        timestamp: DateTime.now(),
        isRead: false,
        data: {'requestId': requestId, 'status': 'dispatched'},
      ));
    });

    // Driver en route
    Future.delayed(const Duration(minutes: 2), () {
      addNotification(NotificationModel(
        id: 'enroute_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Driver En Route',
        message: 'Driver Amit Kumar is on the way to your location. ETA: 6 minutes.',
        type: NotificationType.update,
        timestamp: DateTime.now(),
        isRead: false,
        data: {'driverName': 'Amit Kumar', 'eta': '6 minutes', 'phone': '+91 98765 43210'},
      ));
    });

    // Traffic clearance
    Future.delayed(const Duration(minutes: 3), () {
      addNotification(NotificationModel(
        id: 'clearance_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Route Clearance Approved',
        message: 'Traffic police have cleared the route for faster ambulance movement.',
        type: NotificationType.info,
        timestamp: DateTime.now(),
        isRead: false,
        data: {'route': 'Main Road to Hospital', 'officer': 'Traffic Control'},
      ));
    });

    // Driver arriving
    Future.delayed(const Duration(minutes: 5), () {
      addNotification(NotificationModel(
        id: 'arriving_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Ambulance Arriving',
        message: 'Ambulance is arriving at your location in 2 minutes. Please be ready.',
        type: NotificationType.warning,
        timestamp: DateTime.now(),
        isRead: false,
        data: {'finalEta': '2 minutes', 'instruction': 'Please be ready'},
      ));
    });

    // Driver arrived
    Future.delayed(const Duration(minutes: 7), () {
      addNotification(NotificationModel(
        id: 'arrived_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Ambulance Arrived',
        message: 'Ambulance has arrived at your location. Please proceed to the vehicle.',
        type: NotificationType.emergency,
        timestamp: DateTime.now(),
        isRead: false,
        data: {'status': 'arrived', 'instruction': 'Proceed to vehicle'},
      ));
    });

    // En route to hospital
    Future.delayed(const Duration(minutes: 10), () {
      addNotification(NotificationModel(
        id: 'hospital_${DateTime.now().millisecondsSinceEpoch}',
        title: 'En Route to Hospital',
        message: '$patientDisplayName is now being transported to City General Hospital. ETA: 15 minutes.',
        type: NotificationType.info,
        timestamp: DateTime.now(),
        isRead: false,
        data: {'hospital': 'City General Hospital', 'eta': '15 minutes'},
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

  factory NotificationModel.fromFirestore(String id, Map<String, dynamic> data) {
    return NotificationModel(
      id: id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => NotificationType.info,
      ),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      data: data['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'type': type.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      if (data != null) 'data': data,
    };
  }

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
