import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/emergency_request_model.dart';
import 'notification_service.dart';

class EmergencyRequestService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final NotificationService _notificationService;
  
  // Observable lists for real-time updates
  final RxList<EmergencyRequest> _pendingRequests = <EmergencyRequest>[].obs;
  final RxList<EmergencyRequest> _activeRequests = <EmergencyRequest>[].obs;
  final RxList<EmergencyRequest> _completedRequests = <EmergencyRequest>[].obs;
  
  // Getters
  List<EmergencyRequest> get pendingRequests => _pendingRequests;
  List<EmergencyRequest> get activeRequests => _activeRequests;
  List<EmergencyRequest> get completedRequests => _completedRequests;
  
  @override
  void onInit() {
    super.onInit();
    _notificationService = Get.find<NotificationService>();
    _listenToRequests();
  }

  // Create a new emergency request
  Future<String?> createEmergencyRequest({
    required String patientId,
    required String patientName,
    required String patientPhone,
    required EmergencyType emergencyType,
    required String description,
    required String pickupLocation,
    required String hospitalLocation,
    required String priority,
  }) async {
    try {
      final requestId = _firestore.collection('emergency_requests').doc().id;
      
      final request = EmergencyRequest(
        id: requestId,
        patientId: patientId,
        patientName: patientName,
        patientPhone: patientPhone,
        status: RequestStatus.pending,
        emergencyType: emergencyType,
        description: description,
        pickupLocation: pickupLocation,
        hospitalLocation: hospitalLocation,
        createdAt: DateTime.now(),
        priority: priority,
      );

      await _firestore
          .collection('emergency_requests')
          .doc(requestId)
          .set(request.toJson());

      // Send meaningful notification to patient with simulation
      await _notificationService.sendEmergencyNotification(
        userId: patientId,
        title: 'Emergency Request Confirmed',
        message: 'Your ${emergencyType.name.replaceAll('_', ' ')} emergency request has been received and ambulance is being dispatched to $pickupLocation.',
        type: NotificationType.emergency,
        data: {
          'requestId': requestId, 
          'emergencyType': emergencyType.name,
          'location': pickupLocation,
          'status': 'confirmed',
        },
      );

      // Start the realistic emergency flow simulation
      await _notificationService.simulateEmergencyNotifications(requestId, patientName: patientName);

      return requestId;
    } catch (e) {
      print('Error creating emergency request: $e');
      return null;
    }
  }

  // Accept a request (driver)
  Future<bool> acceptRequest({
    required String requestId,
    required String driverId,
    required String driverName,
    required String ambulanceId,
  }) async {
    try {
      final updatedRequest = {
        'driverId': driverId,
        'driverName': driverName,
        'ambulanceId': ambulanceId,
        'status': 'accepted',
        'acceptedAt': Timestamp.fromDate(DateTime.now()),
      };

      await _firestore
          .collection('emergency_requests')
          .doc(requestId)
          .update(updatedRequest);

      // Add to professional's active requests (using professional collection instead of drivers)
      await _firestore
          .collection('professional')
          .doc(driverId)
          .collection('active_requests')
          .doc(requestId)
          .set(updatedRequest);

      // Get patient ID from the request
      final requestDoc = await _firestore
          .collection('emergency_requests')
          .doc(requestId)
          .get();
      
      if (requestDoc.exists) {
        final patientId = requestDoc.data()?['patientId'];
        if (patientId != null) {
          // Notify patient about ambulance assignment with detailed context
          await _notificationService.sendEmergencyNotification(
            userId: patientId,
            title: 'Ambulance Assigned',
            message: 'Ambulance $ambulanceId has been assigned to your emergency request. Driver $driverName is preparing to depart and will contact you shortly.',
            type: NotificationType.ambulance,
            data: {
              'requestId': requestId,
              'driverId': driverId,
              'driverName': driverName,
              'ambulanceId': ambulanceId,
              'status': 'accepted',
              'driverPhone': '+91 98765 43210',
            },
          );
        }
        
        // Notify driver about new assignment with actionable information
        final emergencyType = requestDoc.data()?['emergencyType'] ?? 'Emergency';
        final patientName = requestDoc.data()?['patientName'] ?? 'Patient';
        final location = requestDoc.data()?['pickupLocation'] ?? 'Location';
        
        await _notificationService.sendEmergencyNotification(
          userId: driverId,
          title: 'URGENT: New Emergency Assignment',
          message: 'You have been assigned to $emergencyType emergency for $patientName at $location. Please proceed immediately to ambulance $ambulanceId.',
          type: NotificationType.emergency,
          data: {
            'requestId': requestId,
            'patientId': patientId,
            'emergencyType': emergencyType,
            'patientName': patientName,
            'location': location,
            'ambulanceId': ambulanceId,
            'priority': 'urgent',
            'action': 'proceed_immediately',
          },
        );
      }

      return true;
    } catch (e) {
      print('Error accepting request: $e');
      return false;
    }
  }

  // Decline a request (driver)
  Future<bool> declineRequest({
    required String requestId,
    required String driverId,
    required String driverName,
  }) async {
    try {
      // Add decline information to the request
      final declineData = {
        'declinedBy': FieldValue.arrayUnion([{
          'driverId': driverId,
          'driverName': driverName,
          'declinedAt': Timestamp.fromDate(DateTime.now()),
        }]),
        'lastDeclinedAt': Timestamp.fromDate(DateTime.now()),
      };

      await _firestore
          .collection('emergency_requests')
          .doc(requestId)
          .update(declineData);

      // Get request details for notification
      final requestDoc = await _firestore
          .collection('emergency_requests')
          .doc(requestId)
          .get();
      
      if (requestDoc.exists) {
        final patientId = requestDoc.data()?['patientId'];
        if (patientId != null) {
          // Notify patient that request is being reassigned
          await _notificationService.sendEmergencyNotification(
            userId: patientId,
            title: 'Reassigning Ambulance',
            message: 'Your emergency request is being reassigned to another available ambulance. Please wait while we find the nearest driver.',
            type: NotificationType.update,
            data: {
              'requestId': requestId,
              'status': 'reassigning',
              'action': 'finding_driver',
            },
          );
        }
      }

      return true;
    } catch (e) {
      print('Error declining request: $e');
      return false;
    }
  }

  // Update request status
  Future<bool> updateRequestStatus({
    required String requestId,
    required RequestStatus status,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.name,
      };

      // Add timestamp based on status
      switch (status) {
        case RequestStatus.enRoute:
          updateData['enRouteAt'] = Timestamp.fromDate(DateTime.now());
          break;
        case RequestStatus.pickedUp:
          updateData['pickedUpAt'] = Timestamp.fromDate(DateTime.now());
          break;
        case RequestStatus.completed:
          updateData['completedAt'] = Timestamp.fromDate(DateTime.now());
          break;
        default:
          break;
      }

      if (additionalData != null) {
        updateData.addAll(additionalData);
      }

      await _firestore
          .collection('emergency_requests')
          .doc(requestId)
          .update(updateData);

      // Send status update notifications
      await _sendStatusUpdateNotification(requestId, status);

      return true;
    } catch (e) {
      print('Error updating request status: $e');
      return false;
    }
  }

  Future<void> _sendStatusUpdateNotification(String requestId, RequestStatus status) async {
    try {
      // Get request details
      final requestDoc = await _firestore
          .collection('emergency_requests')
          .doc(requestId)
          .get();
      
      if (!requestDoc.exists) return;
      
      final data = requestDoc.data()!;
      final patientId = data['patientId'];
      final driverId = data['driverId'];
      final driverName = data['driverName'] ?? 'Driver';
      
      String title = '';
      String message = '';
      NotificationType notificationType = NotificationType.update;
      
      switch (status) {
        case RequestStatus.enRoute:
          title = 'Driver En Route';
          message = 'Driver $driverName is on the way to your location. ETA: 8 minutes. Please stay calm and prepare for pickup.';
          notificationType = NotificationType.update;
          break;
        case RequestStatus.pickedUp:
          title = 'Patient Picked Up - En Route to Hospital';
          message = 'You have been safely picked up by $driverName and are now heading to the hospital. Medical assistance is being provided during transport.';
          notificationType = NotificationType.ambulance;
          break;
        case RequestStatus.completed:
          title = 'Safely Arrived at Hospital';
          message = 'You have safely arrived at the hospital. Emergency request completed successfully. Medical team is ready to assist you.';
          notificationType = NotificationType.info;
          break;
        default:
          return;
      }
      
      // Notify patient
      if (patientId != null) {
        await _notificationService.sendEmergencyNotification(
          userId: patientId,
          title: title,
          message: message,
          type: notificationType,
          data: {
            'requestId': requestId,
            'status': status.name,
          },
        );
      }
      
      // Notify driver about status change with contextual information
      if (driverId != null) {
        String driverTitle = '';
        String driverMessage = '';
        
        switch (status) {
          case RequestStatus.enRoute:
            driverTitle = 'En Route to Patient';
            driverMessage = 'You are now en route to pick up the patient. Drive safely and follow emergency protocols.';
            break;
          case RequestStatus.pickedUp:
            driverTitle = 'Patient Picked Up Successfully';
            driverMessage = 'Patient has been picked up. Proceed to hospital immediately. Monitor patient condition during transport.';
            break;
          case RequestStatus.completed:
            driverTitle = 'Emergency Trip Completed';
            driverMessage = 'Patient delivered safely to hospital. Trip completed successfully. Well done!';
            break;
          default:
            driverTitle = 'Request Status Updated';
            driverMessage = 'Emergency request $requestId status: ${status.name}';
        }
        
        await _notificationService.sendEmergencyNotification(
          userId: driverId,
          title: driverTitle,
          message: driverMessage,
          type: NotificationType.update,
          data: {
            'requestId': requestId,
            'status': status.name,
            'instruction': status == RequestStatus.enRoute ? 'drive_safely' : 
                         status == RequestStatus.pickedUp ? 'monitor_patient' : 
                         status == RequestStatus.completed ? 'trip_completed' : 'status_updated',
          },
        );
      }
    } catch (e) {
      print('Error sending status update notification: $e');
    }
  }

  // Get pending requests stream
  Stream<List<EmergencyRequest>> getPendingRequestsStream() {
    return _firestore
        .collection('emergency_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      final requests = snapshot.docs.map<EmergencyRequest>((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return EmergencyRequest.fromJson(data);
      }).toList();
      
      // Sort in memory instead of using Firestore orderBy
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests;
    });
  }

  // Get driver active trips stream
  Stream<List<EmergencyRequest>> getDriverActiveTripsStream() {
    return _firestore
        .collection('emergency_requests')
        .where('status', whereIn: ['accepted', 'en_route', 'picked_up'])
        .snapshots()
        .map((snapshot) {
      final requests = snapshot.docs.map<EmergencyRequest>((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return EmergencyRequest.fromJson(data);
      }).toList();
      
      // Sort in memory instead of using Firestore orderBy
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests;
    });
  }

  // Get active requests for a specific driver
  Stream<List<EmergencyRequest>> getDriverActiveRequestsStream(String driverId) {
    return _firestore
        .collection('emergency_requests')
        .where('driverId', isEqualTo: driverId)
        .where('status', whereIn: ['accepted', 'en_route', 'picked_up'])
        .snapshots()
        .map((snapshot) {
      final requests = snapshot.docs.map<EmergencyRequest>((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return EmergencyRequest.fromJson(data);
      }).toList();
      
      // Sort in memory by acceptedAt date
      requests.sort((a, b) => (b.acceptedAt ?? DateTime.now()).compareTo(a.acceptedAt ?? DateTime.now()));
      return requests;
    });
  }

  // Get patient's requests
  Stream<List<EmergencyRequest>> getPatientRequestsStream(String patientId) {
    return _firestore
        .collection('emergency_requests')
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map((snapshot) {
      final requests = snapshot.docs.map<EmergencyRequest>((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return EmergencyRequest.fromJson(data);
      }).toList();
      
      // Sort in memory by createdAt date
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests;
    });
  }

  // Get current active request for patient
  Stream<EmergencyRequest?> getPatientActiveRequestStream(String patientId) {
    return _firestore
        .collection('emergency_requests')
        .where('patientId', isEqualTo: patientId)
        .where('status', whereIn: [
          'pending',
          'accepted',
          'en_route',
          'picked_up',
        ])
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return EmergencyRequest.fromJson({
            'id': snapshot.docs.first.id,
            ...snapshot.docs.first.data(),
          });
        });
  }

  // Get patient history (completed and cancelled requests)
  Stream<List<EmergencyRequest>> getPatientHistoryStream(String patientId) {
    return _firestore
        .collection('emergency_requests')
        .where('patientId', isEqualTo: patientId)
        .where('status', whereIn: [
          'completed',
          'cancelled',
        ])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return EmergencyRequest.fromJson({
              'id': doc.id,
              ...doc.data(),
            });
          }).toList();
        });
  }

  // Get driver history (completed and cancelled requests)
  Stream<List<EmergencyRequest>> getDriverHistoryStream(String driverId) {
    return _firestore
        .collection('emergency_requests')
        .where('driverId', isEqualTo: driverId)
        .where('status', whereIn: [
          'completed',
          'cancelled',
        ])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return EmergencyRequest.fromJson({
              'id': doc.id,
              ...doc.data(),
            });
          }).toList();
        });
  }

  // Get patient statistics
  Future<Map<String, int>> getPatientStats(String patientId) async {
    try {
      final snapshot = await _firestore
          .collection('emergency_requests')
          .where('patientId', isEqualTo: patientId)
          .get();

      int total = snapshot.docs.length;
      int completed = 0;
      int cancelled = 0;

      for (var doc in snapshot.docs) {
        final status = doc.data()['status'] as String;
        if (status == 'completed') {
          completed++;
        } else if (status == 'cancelled') {
          cancelled++;
        }
      }

      return {
        'total': total,
        'completed': completed,
        'cancelled': cancelled,
      };
    } catch (e) {
      print('Error getting patient stats: $e');
      return {'total': 0, 'completed': 0, 'cancelled': 0};
    }
  }

  // Get driver statistics
  Future<Map<String, int>> getDriverStats(String driverId) async {
    try {
      final snapshot = await _firestore
          .collection('emergency_requests')
          .where('driverId', isEqualTo: driverId)
          .get();

      int total = snapshot.docs.length;
      int completed = 0;
      int cancelled = 0;

      for (var doc in snapshot.docs) {
        final status = doc.data()['status'] as String;
        if (status == 'completed') {
          completed++;
        } else if (status == 'cancelled') {
          cancelled++;
        }
      }

      return {
        'total': total,
        'completed': completed,
        'cancelled': cancelled,
      };
    } catch (e) {
      print('Error getting driver stats: $e');
      return {'total': 0, 'completed': 0, 'cancelled': 0};
    }
  }

  // Listen to all requests for real-time updates
  void _listenToRequests() {
    // Listen to pending requests
    _firestore
        .collection('emergency_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      _pendingRequests.value = snapshot.docs
          .map((doc) => EmergencyRequest.fromJson(doc.data()))
          .toList();
    });

    // Listen to active requests
    _firestore
        .collection('emergency_requests')
        .where('status', whereIn: ['accepted', 'enRoute', 'pickedUp'])
        .snapshots()
        .listen((snapshot) {
      _activeRequests.value = snapshot.docs
          .map((doc) => EmergencyRequest.fromJson(doc.data()))
          .toList();
    });

    // Listen to completed requests
    _firestore
        .collection('emergency_requests')
        .where('status', whereIn: ['completed', 'cancelled'])
        .snapshots()
        .listen((snapshot) {
      _completedRequests.value = snapshot.docs
          .map((doc) => EmergencyRequest.fromJson(doc.data()))
          .toList();
    });
  }

  // Cancel a request
  Future<bool> cancelRequest(String requestId) async {
    try {
      await _firestore
          .collection('emergency_requests')
          .doc(requestId)
          .update({
        'status': 'cancelled',
        'cancelledAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      print('Error cancelling request: $e');
      return false;
    }
  }

  // Add patient vitals during transport
  Future<bool> updatePatientVitals({
    required String requestId,
    required Map<String, dynamic> vitals,
  }) async {
    try {
      await _firestore
          .collection('emergency_requests')
          .doc(requestId)
          .update({
        'patientVitals': vitals,
        'vitalsUpdatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      print('Error updating patient vitals: $e');
      return false;
    }
  }

  // Get request by ID
  Future<EmergencyRequest?> getRequestById(String requestId) async {
    try {
      final doc = await _firestore
          .collection('emergency_requests')
          .doc(requestId)
          .get();
      
      if (doc.exists) {
        return EmergencyRequest.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting request: $e');
      return null;
    }
  }

  // Get completed requests for history
  Future<List<EmergencyRequest>> getCompletedRequests({
    String? patientId,
    String? driverId,
    int limit = 50,
  }) async {
    try {
      Query query = _firestore
          .collection('emergency_requests')
          .where('status', whereIn: ['completed', 'cancelled']);

      if (patientId != null) {
        query = query.where('patientId', isEqualTo: patientId);
      }
      if (driverId != null) {
        query = query.where('driverId', isEqualTo: driverId);
      }

      final snapshot = await query
          .orderBy('completedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => EmergencyRequest.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting completed requests: $e');
      return [];
    }
  }
}
