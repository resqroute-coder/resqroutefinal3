import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class AmbulanceLocationService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Observable ambulance locations
  final RxMap<String, Map<String, dynamic>> _ambulanceLocations = <String, Map<String, dynamic>>{}.obs;
  final RxList<Map<String, dynamic>> _activeAmbulances = <Map<String, dynamic>>[].obs;
  
  // Location update timer
  Timer? _locationUpdateTimer;
  
  // Getters
  Map<String, Map<String, dynamic>> get ambulanceLocations => _ambulanceLocations;
  List<Map<String, dynamic>> get activeAmbulances => _activeAmbulances;
  
  @override
  void onInit() {
    super.onInit();
    _listenToAmbulanceLocations();
  }
  
  @override
  void onClose() {
    _locationUpdateTimer?.cancel();
    super.onClose();
  }
  
  // Listen to real-time ambulance locations
  void _listenToAmbulanceLocations() {
    _firestore
        .collection('ambulance_locations')
        .snapshots()
        .listen((snapshot) {
      final locations = <String, Map<String, dynamic>>{};
      final activeList = <Map<String, dynamic>>[];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        locations[doc.id] = data;
        
        // Add to active list if ambulance is currently on a trip
        if (data['status'] == 'active' || data['status'] == 'enRoute') {
          activeList.add(data);
        }
      }
      
      _ambulanceLocations.value = locations;
      _activeAmbulances.value = activeList;
    });
  }
  
  // Update ambulance location (called by driver app)
  Future<bool> updateAmbulanceLocation({
    required String ambulanceId,
    required String driverId,
    required double latitude,
    required double longitude,
    required String status, // 'idle', 'active', 'enRoute', 'atPickup', 'toHospital'
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
      print('Error updating ambulance location: $e');
      return false;
    }
  }
  
  // Get ambulance location by ID
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
  
  // Get all active ambulances for a specific emergency type or area
  Stream<List<Map<String, dynamic>>> getActiveAmbulancesStream({
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
  
  // Get ambulances assigned to specific hospital
  Stream<List<Map<String, dynamic>>> getHospitalAmbulancesStream(String hospitalId) {
    return _firestore
        .collection('ambulance_locations')
        .where('assignedHospital', isEqualTo: hospitalId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
  
  // Get route information for ambulance
  Future<Map<String, dynamic>?> getAmbulanceRoute(String ambulanceId) async {
    try {
      final doc = await _firestore
          .collection('ambulance_routes')
          .doc(ambulanceId)
          .get();
      
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting ambulance route: $e');
      return null;
    }
  }
  
  // Update ambulance route (for navigation)
  Future<bool> updateAmbulanceRoute({
    required String ambulanceId,
    required String emergencyRequestId,
    required Map<String, dynamic> pickupLocation,
    required Map<String, dynamic> hospitalLocation,
    List<Map<String, dynamic>>? routePoints,
    double? estimatedDuration,
    double? estimatedDistance,
  }) async {
    try {
      final routeData = {
        'ambulanceId': ambulanceId,
        'emergencyRequestId': emergencyRequestId,
        'pickupLocation': pickupLocation,
        'hospitalLocation': hospitalLocation,
        'routePoints': routePoints ?? [],
        'estimatedDuration': estimatedDuration,
        'estimatedDistance': estimatedDistance,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };
      
      await _firestore
          .collection('ambulance_routes')
          .doc(ambulanceId)
          .set(routeData, SetOptions(merge: true));
      
      return true;
    } catch (e) {
      print('Error updating ambulance route: $e');
      return false;
    }
  }
  
  // Start location tracking for driver
  void startLocationTracking(String ambulanceId, String driverId) {
    _locationUpdateTimer?.cancel();
    
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        
        await updateAmbulanceLocation(
          ambulanceId: ambulanceId,
          driverId: driverId,
          latitude: position.latitude,
          longitude: position.longitude,
          status: 'active',
          speed: position.speed,
          heading: position.heading,
        );
      } catch (e) {
        print('Error updating location: $e');
      }
    });
  }
  
  // Stop location tracking
  void stopLocationTracking() {
    _locationUpdateTimer?.cancel();
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
      print('Error calculating estimated arrival: $e');
      return null;
    }
  }
  
  // Get ambulance statistics for dashboard
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
      print('Error getting ambulance stats: $e');
      return {
        'total': 0,
        'active': 0,
        'idle': 0,
        'maintenance': 0,
        'utilization': 0,
      };
    }
  }
}
