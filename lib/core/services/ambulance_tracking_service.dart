import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/emergency_request_model.dart';
import '../models/tracking_model.dart';
import 'dart:async';

class AmbulanceTrackingService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Observable tracking updates
  final RxList<TrackingUpdate> _activeTracking = <TrackingUpdate>[].obs;
  final RxBool _isTracking = false.obs;
  final RxMap<String, Map<String, dynamic>> _ambulanceLocations = <String, Map<String, dynamic>>{}.obs;
  final RxList<Map<String, dynamic>> _activeAmbulances = <Map<String, dynamic>>[].obs;
  
  // Location update timer
  Timer? _locationUpdateTimer;
  
  // Getters
  List<TrackingUpdate> get activeTracking => _activeTracking;
  bool get isTracking => _isTracking.value;
  Map<String, Map<String, dynamic>> get ambulanceLocations => _ambulanceLocations;
  List<Map<String, dynamic>> get activeAmbulances => _activeAmbulances;
  
  // Start tracking for a specific emergency request
  Future<void> startTracking(String requestId, String driverId) async {
    try {
      _isTracking.value = true;
      
      // Start location updates
      _startLocationUpdates(requestId, driverId);
      
      // Listen to tracking updates for this request
      _listenToTrackingUpdates(requestId);
      
    } catch (e) {
      debugPrint('Error starting tracking: $e');
    }
  }
  
  // Stop tracking
  void stopTracking() {
    _isTracking.value = false;
    _locationUpdateTimer?.cancel();
    debugPrint('Stopped ambulance tracking');
  }

  @override
  void onClose() {
    _locationUpdateTimer?.cancel();
    super.onClose();
  }

  // Enhanced ambulance location management (merged from AmbulanceLocationService)
  
  // Update ambulance location (unified method)
  Future<bool> updateAmbulanceLocation({
    required String ambulanceId,
    required String driverId,
    required double latitude,
    required double longitude,
    required String status,
    String? emergencyRequestId,
    String? destination,
    double? speed,
    double? heading,
  }) async {
    try {
      final locationData = {
        'ambulanceId': ambulanceId,
        'driverId': driverId,
        'latitude': latitude,
        'longitude': longitude,
        'status': status,
        'emergencyRequestId': emergencyRequestId,
        'destination': destination,
        'speed': speed ?? 0.0,
        'heading': heading ?? 0.0,
        'lastUpdated': Timestamp.fromDate(DateTime.now()),
        'timestamp': Timestamp.fromDate(DateTime.now()),
      };
      
      await _firestore
          .collection('ambulance_locations')
          .doc(ambulanceId)
          .set(locationData, SetOptions(merge: true));
      
      return true;
    } catch (e) {
      debugPrint('Error updating ambulance location: $e');
      return false;
    }
  }

  // Get ambulance location stream
  Stream<Map<String, dynamic>?> getAmbulanceLocationStream(String ambulanceId) {
    return _firestore
        .collection('ambulance_locations')
        .doc(ambulanceId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return data;
      }
      return null;
    });
  }

  // Get active ambulances with filtering
  Stream<List<Map<String, dynamic>>> getActiveAmbulancesStreamWithFilter({
    String? emergencyType,
    double? centerLat,
    double? centerLng,
    double? radiusKm,
  }) {
    Query query = _firestore
        .collection('ambulance_locations')
        .where('status', whereIn: ['active', 'enRoute', 'atPickup', 'toHospital']);
    
    return query.snapshots().map((snapshot) {
      List<Map<String, dynamic>> ambulances = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        
        // Filter by radius if specified
        if (centerLat != null && centerLng != null && radiusKm != null) {
          final distance = Geolocator.distanceBetween(
            centerLat,
            centerLng,
            data['latitude'] ?? 0.0,
            data['longitude'] ?? 0.0,
          ) / 1000; // Convert to km
          
          if (distance <= radiusKm) {
            ambulances.add(data);
          }
        } else {
          ambulances.add(data);
        }
      }
      
      return ambulances;
    });
  }

  // Get ambulance statistics
  Future<Map<String, dynamic>> getAmbulanceStats() async {
    try {
      final snapshot = await _firestore
          .collection('ambulance_locations')
          .get();
      
      int total = snapshot.docs.length;
      int active = 0;
      int idle = 0;
      int maintenance = 0;
      
      for (var doc in snapshot.docs) {
        final status = doc.data()['status'] as String? ?? 'idle';
        switch (status) {
          case 'active':
          case 'enRoute':
          case 'atPickup':
          case 'toHospital':
            active++;
            break;
          case 'maintenance':
            maintenance++;
            break;
          default:
            idle++;
            break;
        }
      }
      
      return {
        'total': total,
        'active': active,
        'idle': idle,
        'maintenance': maintenance,
        'utilization': total > 0 ? (active / total * 100).round() : 0,
      };
    } catch (e) {
      debugPrint('Error getting ambulance stats: $e');
      return {
        'total': 0,
        'active': 0,
        'idle': 0,
        'maintenance': 0,
        'utilization': 0,
      };
    }
  }

  // Get estimated arrival time
  Future<Duration?> getEstimatedArrivalTime({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    try {
      final distance = Geolocator.distanceBetween(fromLat, fromLng, toLat, toLng);
      
      // Estimate based on average speed (assuming 40 km/h in city traffic)
      final averageSpeedKmh = 40.0;
      final distanceKm = distance / 1000;
      final estimatedHours = distanceKm / averageSpeedKmh;
      
      return Duration(minutes: (estimatedHours * 60).round());
    } catch (e) {
      debugPrint('Error calculating estimated arrival: $e');
      return null;
    }
  }
  
  // Start location updates
  void _startLocationUpdates(String requestId, String driverId) async {
    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    
    // Start location stream
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );
    
    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        if (_isTracking.value) {
          _updateLocation(requestId, driverId, position);
        }
      },
    );
  }
  
  // Update location in Firestore
  Future<void> _updateLocation(String requestId, String driverId, Position position) async {
    try {
      final trackingUpdate = TrackingUpdate(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        requestId: requestId,
        driverId: driverId,
        timestamp: DateTime.now(),
        latitude: position.latitude,
        longitude: position.longitude,
        speed: position.speed,
        status: 'en_route',
        estimatedArrival: DateTime.now().add(const Duration(minutes: 8)),
      );
      
      // Save to Firestore
      await _firestore
          .collection('ambulance_tracking')
          .doc(requestId)
          .collection('updates')
          .doc(trackingUpdate.id)
          .set(trackingUpdate.toJson());
      
      // Update latest position
      await _firestore
          .collection('ambulance_tracking')
          .doc(requestId)
          .set({
        'requestId': requestId,
        'driverId': driverId,
        'currentLocation': {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
        'speed': position.speed,
        'timestamp': Timestamp.fromDate(DateTime.now()),
        'status': 'en_route',
        'estimatedArrival': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 8))),
      }, SetOptions(merge: true));
      
    } catch (e) {
      debugPrint('Error updating location: $e');
    }
  }
  
  // Listen to tracking updates
  void _listenToTrackingUpdates(String requestId) {
    _firestore
        .collection('ambulance_tracking')
        .doc(requestId)
        .collection('updates')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots()
        .listen((snapshot) {
      final updates = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TrackingUpdate.fromJson(data);
      }).toList();
      
      _activeTracking.value = updates;
    });
  }
  
  // Get real-time tracking stream for hospital admin
  Stream<DocumentSnapshot> getTrackingStream(String requestId) {
    return _firestore
        .collection('ambulance_tracking')
        .doc(requestId)
        .snapshots();
  }

  
  // Get emergency requests that need tracking
  Stream<List<EmergencyRequest>> getTrackableRequestsStream() {
    return _firestore
        .collection('emergency_requests')
        .where('status', whereIn: ['accepted', 'enRoute', 'pickedUp'])
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return EmergencyRequest.fromJson(data);
      }).toList();
    });
  }
  
  // Send location update to hospital
  Future<void> notifyHospital(String requestId, Map<String, dynamic> locationData) async {
    try {
      await _firestore
          .collection('hospital_notifications')
          .add({
        'requestId': requestId,
        'type': 'location_update',
        'data': locationData,
        'timestamp': Timestamp.fromDate(DateTime.now()),
        'read': false,
      });
    } catch (e) {
      debugPrint('Error notifying hospital: $e');
    }
  }
  
  // Send alert to traffic police
  Future<void> alertTrafficPolice(String requestId, Map<String, dynamic> alertData) async {
    try {
      await _firestore
          .collection('traffic_alerts')
          .add({
        'requestId': requestId,
        'type': 'ambulance_approaching',
        'data': alertData,
        'timestamp': Timestamp.fromDate(DateTime.now()),
        'status': 'active',
      });
    } catch (e) {
      debugPrint('Error alerting traffic police: $e');
    }
  }

  // Request route clearance
  Future<bool> requestRouteClearance({
    required String requestId,
    required String ambulanceId,
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    try {
      await _firestore.collection('route_clearances').add({
        'requestId': requestId,
        'ambulanceId': ambulanceId,
        'fromLocation': GeoPoint(fromLat, fromLng),
        'toLocation': GeoPoint(toLat, toLng),
        'status': 'pending',
        'requestedAt': Timestamp.fromDate(DateTime.now()),
        'priority': 'high',
      });
      return true;
    } catch (e) {
      debugPrint('Error requesting route clearance: $e');
      return false;
    }
  }

  // Get active ambulances stream for maps service
  Stream<List<Map<String, dynamic>>> getActiveAmbulancesStream() {
    return _firestore
        .collection('ambulance_tracking')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Get ambulance route for maps service
  Future<List<Map<String, dynamic>>?> getAmbulanceRoute(String ambulanceId) async {
    try {
      final routeDoc = await _firestore
          .collection('ambulance_routes')
          .doc(ambulanceId)
          .get();
      
      if (routeDoc.exists) {
        final data = routeDoc.data();
        return List<Map<String, dynamic>>.from(data?['waypoints'] ?? []);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting ambulance route: $e');
      return null;
    }
  }
}
