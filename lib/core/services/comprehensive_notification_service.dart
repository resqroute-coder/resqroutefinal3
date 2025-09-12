import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';

/// Comprehensive notification service that handles all app-wide notifications
/// for different user types and activities
class ComprehensiveNotificationService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final NotificationService _notificationService;

  @override
  void onInit() {
    super.onInit();
    _notificationService = Get.find<NotificationService>();
  }

  // ==================== EMERGENCY NOTIFICATIONS ====================
  
  /// Send emergency request notifications to all relevant parties
  Future<void> sendEmergencyRequestNotifications({
    required String requestId,
    required String patientId,
    required String patientName,
    required String emergencyType,
    required String location,
  }) async {
    try {
      // Notify patient with detailed context
      await _notificationService.sendEmergencyNotification(
        userId: patientId,
        title: 'Emergency Request Confirmed',
        message: 'Your $emergencyType emergency request has been received and ambulance is being dispatched to $location.',
        type: NotificationType.emergency,
        data: {
          'requestId': requestId,
          'emergencyType': emergencyType,
          'location': location,
          'status': 'confirmed',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // Notify nearby drivers (system notification)
      await _notificationService.sendSystemNotification(
        title: 'New Emergency Request',
        message: '$emergencyType emergency at $location. Patient: $patientName',
        type: NotificationType.emergency,
      );

      // Notify traffic police in the area
      await _notifyTrafficPoliceOfEmergency(requestId, location, emergencyType);

      // Notify hospitals in the area
      await _notifyHospitalsOfEmergency(requestId, patientName, emergencyType);

    } catch (e) {
      print('Error sending emergency request notifications: $e');
    }
  }

  /// Send ambulance assignment notifications
  Future<void> sendAmbulanceAssignmentNotifications({
    required String requestId,
    required String patientId,
    required String driverId,
    required String driverName,
    required String ambulanceId,
  }) async {
    try {
      // Notify patient with specific details
      await _notificationService.sendEmergencyNotification(
        userId: patientId,
        title: 'Ambulance Assigned',
        message: 'Ambulance $ambulanceId has been assigned to your emergency request. Driver $driverName is preparing to depart.',
        type: NotificationType.ambulance,
        data: {
          'requestId': requestId,
          'driverId': driverId,
          'driverName': driverName,
          'ambulanceId': ambulanceId,
          'status': 'assigned',
          'driverPhone': '+91 98765 43210',
        },
      );

      // Notify driver with actionable information
      await _notificationService.sendEmergencyNotification(
        userId: driverId,
        title: 'New Emergency Assignment',
        message: 'URGENT: You have been assigned to emergency request $requestId. Patient needs immediate assistance. Please proceed to location immediately.',
        type: NotificationType.emergency,
        data: {
          'requestId': requestId,
          'patientId': patientId,
          'priority': 'urgent',
          'action': 'proceed_immediately',
          'ambulanceId': ambulanceId,
        },
      );

    } catch (e) {
      print('Error sending ambulance assignment notifications: $e');
    }
  }

  // ==================== HOSPITAL NOTIFICATIONS ====================

  /// Send hospital-specific notifications
  Future<void> sendHospitalNotifications({
    required String hospitalId,
    required String title,
    required String message,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _notificationService.sendEmergencyNotification(
        userId: hospitalId,
        title: title,
        message: message,
        type: type,
        data: data,
      );
    } catch (e) {
      print('Error sending hospital notification: $e');
    }
  }

  /// Send bed availability update notifications
  Future<void> sendBedAvailabilityUpdate({
    required String hospitalId,
    required int totalBeds,
    required int availableBeds,
  }) async {
    try {
      await sendHospitalNotifications(
        hospitalId: hospitalId,
        title: 'Bed Availability Updated',
        message: 'Hospital beds: $availableBeds available out of $totalBeds total',
        type: NotificationType.info,
        data: {
          'event': 'bed_update',
          'totalBeds': totalBeds,
          'availableBeds': availableBeds,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Error sending bed availability notification: $e');
    }
  }

  /// Send patient admission notifications
  Future<void> sendPatientAdmissionNotification({
    required String hospitalId,
    required String patientName,
    required String emergencyType,
    required String severity,
  }) async {
    try {
      final eta = severity == 'critical' ? '5 minutes' : severity == 'high' ? '10 minutes' : '15 minutes';
        
      await sendHospitalNotifications(
        hospitalId: hospitalId,
        title: 'Incoming Patient - ${severity.toUpperCase()} Priority',
        message: 'PREPARE: Patient $patientName with $emergencyType arriving in $eta. Priority: $severity. Please prepare emergency bay and medical team.',
        type: severity == 'critical' ? NotificationType.emergency : NotificationType.warning,
        data: {
          'event': 'patient_incoming',
          'patientName': patientName,
          'emergencyType': emergencyType,
          'severity': severity,
          'eta': eta,
          'action': 'prepare_emergency_bay',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Error sending patient admission notification: $e');
    }
  }

  // ==================== TRAFFIC POLICE NOTIFICATIONS ====================

  /// Send traffic police notifications
  Future<void> sendTrafficPoliceNotifications({
    required String policeId,
    required String title,
    required String message,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _notificationService.sendEmergencyNotification(
        userId: policeId,
        title: title,
        message: message,
        type: type,
        data: data,
      );
    } catch (e) {
      print('Error sending traffic police notification: $e');
    }
  }

  /// Send route clearance request notifications
  Future<void> sendRouteClearanceRequest({
    required String policeId,
    required String ambulanceId,
    required String route,
    required String emergencyType,
  }) async {
    try {
      await sendTrafficPoliceNotifications(
        policeId: policeId,
        title: 'URGENT: Route Clearance Needed',
        message: 'Emergency ambulance $ambulanceId requires immediate clearance on $route for $emergencyType patient. Please clear traffic and provide escort if possible.',
        type: NotificationType.emergency,
        data: {
          'event': 'route_clearance_request',
          'ambulanceId': ambulanceId,
          'route': route,
          'emergencyType': emergencyType,
          'priority': 'urgent',
          'action': 'clear_route_immediately',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Error sending route clearance request: $e');
    }
  }

  /// Send route clearance approval notifications
  Future<void> sendRouteClearanceApproval({
    required String driverId,
    required String policeOfficer,
    required String route,
  }) async {
    try {
      await _notificationService.sendEmergencyNotification(
        userId: driverId,
        title: 'Route Cleared - Proceed with Caution',
        message: 'Officer $policeOfficer has cleared your route: $route. Traffic has been diverted. You may proceed at emergency speed while maintaining safety.',
        type: NotificationType.update,
        data: {
          'event': 'route_cleared',
          'policeOfficer': policeOfficer,
          'route': route,
          'instruction': 'proceed_emergency_speed',
          'safety_note': 'maintain_caution',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Error sending route clearance approval: $e');
    }
  }

  // ==================== DRIVER NOTIFICATIONS ====================

  /// Send driver performance notifications
  Future<void> sendDriverPerformanceUpdate({
    required String driverId,
    required int tripsCompleted,
    required double rating,
    required double earnings,
  }) async {
    try {
      final performance = rating >= 4.5 ? 'Excellent' : rating >= 4.0 ? 'Good' : rating >= 3.5 ? 'Average' : 'Needs Improvement';
      final bonus = tripsCompleted >= 10 ? ' + ₹500 bonus!' : tripsCompleted >= 5 ? ' + ₹200 bonus!' : '';
      
      await _notificationService.sendEmergencyNotification(
        userId: driverId,
        title: 'Daily Performance Report - $performance',
        message: 'Today\'s summary: $tripsCompleted emergency trips completed, ₹${earnings.toInt()} earned$bonus, ${rating.toStringAsFixed(1)}★ rating. ${performance == 'Excellent' ? 'Outstanding work!' : 'Keep up the good work!'}',
        type: NotificationType.info,
        data: {
          'event': 'performance_update',
          'tripsCompleted': tripsCompleted,
          'rating': rating,
          'earnings': earnings,
          'performance': performance,
          'bonus': bonus.isNotEmpty,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Error sending driver performance notification: $e');
    }
  }

  /// Send shift notifications
  Future<void> sendShiftNotification({
    required String driverId,
    required String shiftType, // 'start' or 'end'
    required String shiftTime,
  }) async {
    try {
      final title = shiftType == 'start' ? 'Shift Started' : 'Shift Ended';
      final message = shiftType == 'start' 
          ? 'Your shift has started at $shiftTime. Stay safe!'
          : 'Your shift ended at $shiftTime. Thank you for your service!';

      await _notificationService.sendEmergencyNotification(
        userId: driverId,
        title: title,
        message: message,
        type: NotificationType.info,
        data: {
          'event': 'shift_$shiftType',
          'shiftTime': shiftTime,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Error sending shift notification: $e');
    }
  }

  // ==================== SYSTEM NOTIFICATIONS ====================

  /// Send system maintenance notifications
  Future<void> sendSystemMaintenanceNotification({
    required String title,
    required String message,
    required DateTime scheduledTime,
  }) async {
    try {
      await _notificationService.sendSystemNotification(
        title: title,
        message: message,
        type: NotificationType.warning,
      );
    } catch (e) {
      print('Error sending system maintenance notification: $e');
    }
  }

  /// Send app update notifications
  Future<void> sendAppUpdateNotification({
    required String version,
    required String features,
  }) async {
    try {
      await _notificationService.sendSystemNotification(
        title: 'App Update Available',
        message: 'ResQRoute v$version is available with new features: $features',
        type: NotificationType.info,
      );
    } catch (e) {
      print('Error sending app update notification: $e');
    }
  }

  // ==================== HELPER METHODS ====================

  /// Notify traffic police about emergency in their area
  Future<void> _notifyTrafficPoliceOfEmergency(
    String requestId,
    String location,
    String emergencyType,
  ) async {
    try {
      // Get traffic police in the area (simplified - in real app, use geolocation)
      final policeQuery = await _firestore
          .collection('professional')
          .where('role', isEqualTo: 'traffic_police')
          .limit(5)
          .get();

      for (var doc in policeQuery.docs) {
        await sendTrafficPoliceNotifications(
          policeId: doc.id,
          title: 'Emergency Alert',
          message: '$emergencyType emergency at $location. Prepare for potential route clearance.',
          type: NotificationType.warning,
          data: {
            'requestId': requestId,
            'location': location,
            'emergencyType': emergencyType,
          },
        );
      }
    } catch (e) {
      print('Error notifying traffic police: $e');
    }
  }

  /// Notify hospitals about incoming emergency
  Future<void> _notifyHospitalsOfEmergency(
    String requestId,
    String patientName,
    String emergencyType,
  ) async {
    try {
      // Get hospitals in the area (simplified - in real app, use geolocation)
      final hospitalQuery = await _firestore
          .collection('professional')
          .where('role', isEqualTo: 'hospital_staff')
          .limit(3)
          .get();

      for (var doc in hospitalQuery.docs) {
        await sendHospitalNotifications(
          hospitalId: doc.id,
          title: 'Incoming Emergency',
          message: 'Prepare for $emergencyType patient: $patientName',
          type: NotificationType.warning,
          data: {
            'requestId': requestId,
            'patientName': patientName,
            'emergencyType': emergencyType,
          },
        );
      }
    } catch (e) {
      print('Error notifying hospitals: $e');
    }
  }

  /// Send location update notifications
  Future<void> sendLocationUpdateNotification({
    required String userId,
    required String userType,
    required String location,
  }) async {
    try {
      await _notificationService.sendEmergencyNotification(
        userId: userId,
        title: 'Location Updated',
        message: 'Your $userType location has been updated to: $location',
        type: NotificationType.info,
        data: {
          'event': 'location_update',
          'userType': userType,
          'location': location,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Error sending location update notification: $e');
    }
  }

  /// Send data sync notifications
  Future<void> sendDataSyncNotification({
    required String userId,
    required String dataType,
    required bool success,
  }) async {
    try {
      final title = success ? 'Data Synced' : 'Sync Failed';
      final message = success 
          ? 'Your $dataType data has been synced successfully'
          : 'Failed to sync $dataType data. Please try again.';

      await _notificationService.sendEmergencyNotification(
        userId: userId,
        title: title,
        message: message,
        type: success ? NotificationType.info : NotificationType.warning,
        data: {
          'event': 'data_sync',
          'dataType': dataType,
          'success': success,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Error sending data sync notification: $e');
    }
  }
}
