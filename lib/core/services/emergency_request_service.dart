import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/emergency_request_model.dart';

class EmergencyRequestService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
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

      // Add to patient's request history
      await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('requests')
          .doc(requestId)
          .set(request.toJson());

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
        'status': RequestStatus.accepted.toString().split('.').last,
        'acceptedAt': Timestamp.fromDate(DateTime.now()),
      };

      await _firestore
          .collection('emergency_requests')
          .doc(requestId)
          .update(updatedRequest);

      // Add to driver's active requests
      await _firestore
          .collection('drivers')
          .doc(driverId)
          .collection('active_requests')
          .doc(requestId)
          .set(updatedRequest);

      return true;
    } catch (e) {
      print('Error accepting request: $e');
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
        'status': status.toString().split('.').last,
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

      return true;
    } catch (e) {
      print('Error updating request status: $e');
      return false;
    }
  }

  // Get pending requests for drivers
  Stream<List<EmergencyRequest>> getPendingRequestsStream() {
    return _firestore
        .collection('emergency_requests')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EmergencyRequest.fromJson(doc.data()))
          .toList();
    });
  }

  // Get active requests for a specific driver
  Stream<List<EmergencyRequest>> getDriverActiveRequestsStream(String driverId) {
    return _firestore
        .collection('emergency_requests')
        .where('driverId', isEqualTo: driverId)
        .where('status', whereIn: ['accepted', 'enRoute', 'pickedUp'])
        .orderBy('acceptedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EmergencyRequest.fromJson(doc.data()))
          .toList();
    });
  }

  // Get patient's requests
  Stream<List<EmergencyRequest>> getPatientRequestsStream(String patientId) {
    return _firestore
        .collection('emergency_requests')
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EmergencyRequest.fromJson(doc.data()))
          .toList();
    });
  }

  // Get current active request for patient
  Stream<EmergencyRequest?> getPatientActiveRequestStream(String patientId) {
    return _firestore
        .collection('emergency_requests')
        .where('patientId', isEqualTo: patientId)
        .where('status', whereIn: [
          RequestStatus.pending.toString().split('.').last,
          RequestStatus.accepted.toString().split('.').last,
          RequestStatus.enRoute.toString().split('.').last,
          RequestStatus.pickedUp.toString().split('.').last,
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
          RequestStatus.completed.toString().split('.').last,
          RequestStatus.cancelled.toString().split('.').last,
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
          RequestStatus.completed.toString().split('.').last,
          RequestStatus.cancelled.toString().split('.').last,
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
        if (status == RequestStatus.completed.toString().split('.').last) {
          completed++;
        } else if (status == RequestStatus.cancelled.toString().split('.').last) {
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
        if (status == RequestStatus.completed.toString().split('.').last) {
          completed++;
        } else if (status == RequestStatus.cancelled.toString().split('.').last) {
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
        'status': RequestStatus.cancelled.toString().split('.').last,
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
