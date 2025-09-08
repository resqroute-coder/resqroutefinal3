import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActivityLogger {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Log user activity to Firestore
  static Future<void> logActivity({
    required String type,
    required String description,
    Map<String, dynamic>? metadata,
    String? relatedEmergencyId,
    String? relatedAmbulanceId,
    String? relatedHospitalId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final activityData = {
        'type': type,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'completed',
        'relatedDocuments': {
          if (relatedEmergencyId != null) 'emergencyId': relatedEmergencyId,
          if (relatedAmbulanceId != null) 'ambulanceId': relatedAmbulanceId,
          if (relatedHospitalId != null) 'hospitalId': relatedHospitalId,
        },
        'metadata': metadata ?? {},
      };

      // Log to user's activities subcollection
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('activities')
          .add(activityData);

      // Also log to system logs for monitoring
      await _firestore.collection('systemLogs').add({
        'userId': user.uid,
        'action': type,
        'details': {
          'description': description,
          'metadata': metadata,
        },
        'timestamp': FieldValue.serverTimestamp(),
        'level': 'info',
        'source': 'mobile_app',
      });
    } catch (e) {
      print('Error logging activity: $e');
    }
  }

  // Predefined activity types for consistency
  static Future<void> logLogin(String userRole) async {
    await logActivity(
      type: 'user_login',
      description: 'User logged in as $userRole',
      metadata: {'role': userRole, 'loginTime': DateTime.now().toIso8601String()},
    );
  }

  static Future<void> logLogout() async {
    await logActivity(
      type: 'user_logout',
      description: 'User logged out',
      metadata: {'logoutTime': DateTime.now().toIso8601String()},
    );
  }

  static Future<void> logEmergencyRequest(String emergencyId, String emergencyType) async {
    await logActivity(
      type: 'emergency_request',
      description: 'Created emergency request for $emergencyType',
      relatedEmergencyId: emergencyId,
      metadata: {'emergencyType': emergencyType},
    );
  }

  static Future<void> logProfileUpdate(String field) async {
    await logActivity(
      type: 'profile_update',
      description: 'Updated profile field: $field',
      metadata: {'updatedField': field},
    );
  }

  static Future<void> logMapInteraction(String action) async {
    await logActivity(
      type: 'map_interaction',
      description: 'Map interaction: $action',
      metadata: {'action': action},
    );
  }

  static Future<void> logEmergencyContactAction(String action, String contactName) async {
    await logActivity(
      type: 'emergency_contact_action',
      description: '$action emergency contact: $contactName',
      metadata: {'action': action, 'contactName': contactName},
    );
  }

  static Future<void> logNotificationInteraction(String action) async {
    await logActivity(
      type: 'notification_interaction',
      description: 'Notification $action',
      metadata: {'action': action},
    );
  }

  static Future<void> logAmbulanceTracking(String ambulanceId) async {
    await logActivity(
      type: 'ambulance_tracking',
      description: 'Viewed ambulance tracking',
      relatedAmbulanceId: ambulanceId,
      metadata: {'ambulanceId': ambulanceId},
    );
  }

  static Future<void> logHospitalInteraction(String hospitalId, String action) async {
    await logActivity(
      type: 'hospital_interaction',
      description: 'Hospital interaction: $action',
      relatedHospitalId: hospitalId,
      metadata: {'action': action, 'hospitalId': hospitalId},
    );
  }

  // Get user activities (for displaying in profile or dashboard)
  static Stream<QuerySnapshot> getUserActivities({int limit = 20}) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }
}
