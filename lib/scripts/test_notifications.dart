import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/services/notification_service.dart';
import '../core/services/comprehensive_notification_service.dart';
import '../core/services/user_service.dart';

/// Test script to verify notification system functionality
/// Run this to test if notifications are working after login
class NotificationTestScreen extends StatelessWidget {
  const NotificationTestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NotificationService notificationService = Get.find<NotificationService>();
    final ComprehensiveNotificationService comprehensiveService = Get.put(ComprehensiveNotificationService());
    final UserService userService = Get.find<UserService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test'),
        backgroundColor: const Color(0xFFFF5252),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test Notification System',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Display current notification count
            Obx(() => Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Current Notifications: ${notificationService.notifications.length}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Unread: ${notificationService.unreadCount}',
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ],
                ),
              ),
            )),
            
            const SizedBox(height: 20),
            
            // Test buttons
            ElevatedButton(
              onPressed: () async {
                await comprehensiveService.sendEmergencyRequestNotifications(
                  requestId: 'EMR_${DateTime.now().millisecondsSinceEpoch}',
                  patientId: 'current_user',
                  patientName: 'Rajesh Sharma',
                  emergencyType: 'Heart Attack',
                  location: 'Andheri West, Mumbai - 400058',
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Test Emergency Request Flow'),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: () async {
                await comprehensiveService.sendAmbulanceAssignmentNotifications(
                  requestId: 'EMR_${DateTime.now().millisecondsSinceEpoch}',
                  patientId: 'current_user',
                  driverId: 'driver_001',
                  driverName: 'Amit Kumar',
                  ambulanceId: 'MH-12-AB-1234',
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Test Ambulance Assignment'),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: () async {
                await comprehensiveService.sendHospitalNotifications(
                  hospitalId: 'current_user',
                  title: 'New Patient Incoming',
                  message: 'Heart attack patient arriving in 10 minutes',
                  type: NotificationType.warning,
                  data: {'eta': '10 minutes', 'condition': 'critical'},
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Test Hospital Notification'),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: () async {
                await comprehensiveService.sendTrafficPoliceNotifications(
                  policeId: 'current_user',
                  title: 'Route Clearance Needed',
                  message: 'Ambulance needs clearance on Highway 1',
                  type: NotificationType.warning,
                  data: {'route': 'Highway 1', 'urgency': 'high'},
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text('Test Traffic Police Notification'),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: () async {
                await comprehensiveService.sendDriverPerformanceUpdate(
                  driverId: 'current_user',
                  tripsCompleted: 5,
                  rating: 4.8,
                  earnings: 2500.0,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text('Test Driver Performance'),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: () async {
                // Test profile update notification
                await userService.updateProfile(
                  name: 'Updated Test Name',
                  phone: '+91 9876543210',
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              child: const Text('Test Profile Update'),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: () async {
                await notificationService.sendSystemNotification(
                  title: 'System Maintenance',
                  message: 'ResQRoute will undergo maintenance tonight at 2 AM',
                  type: NotificationType.warning,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Test System Notification'),
            ),
            
            const SizedBox(height: 20),
            
            // List notifications
            Expanded(
              child: Obx(() {
                final notifications = notificationService.notifications;
                if (notifications.isEmpty) {
                  return const Center(
                    child: Text('No notifications yet. Try sending a test notification.'),
                  );
                }
                
                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          _getIconForType(notification.type),
                          color: _getColorForType(notification.type),
                        ),
                        title: Text(notification.title),
                        subtitle: Text(notification.message),
                        trailing: notification.isRead 
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.circle, color: Colors.red, size: 12),
                        onTap: () {
                          if (!notification.isRead) {
                            notificationService.markAsRead(notification.id);
                          }
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getIconForType(NotificationType type) {
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
  
  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.emergency:
        return Colors.red;
      case NotificationType.ambulance:
        return Colors.blue;
      case NotificationType.update:
        return Colors.green;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.info:
        return Colors.grey;
    }
  }
}
