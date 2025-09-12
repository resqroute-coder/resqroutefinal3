import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/api_config.dart';
import 'ambulance_location_service.dart';
import 'dart:async';

class MapsService extends GetxController {
  static MapsService get instance => Get.find();
  
  GoogleMapController? _mapController;
  GoogleMapController? get mapController => _mapController;
  final RxSet<Marker> _markers = <Marker>{}.obs;
  final RxSet<Polyline> _polylines = <Polyline>{}.obs;
  final Rx<LatLng> _currentLocation = const LatLng(19.0760, 72.8777).obs; // Mumbai default
  final RxBool _isLocationPermissionGranted = false.obs;
  final RxBool _isLoadingLocation = false.obs;
  
  // Ambulance tracking
  final AmbulanceLocationService _ambulanceService = Get.find<AmbulanceLocationService>();
  StreamSubscription<List<Map<String, dynamic>>>? _ambulanceSubscription;

  // Hospital locations in Mumbai
  final List<Map<String, dynamic>> _hospitalLocations = [
    {
      'name': 'Apollo Hospital',
      'location': const LatLng(19.0728, 72.8826),
      'distance': '2.1 km',
      'phone': '+91 22 2692 7777',
      'type': 'Multi-specialty',
    },
    {
      'name': 'Fortis Hospital',
      'location': const LatLng(19.0896, 72.8656),
      'distance': '3.5 km',
      'phone': '+91 22 6754 4444',
      'type': 'Multi-specialty',
    },
    {
      'name': 'Lilavati Hospital',
      'location': const LatLng(19.0520, 72.8302),
      'distance': '1.8 km',
      'phone': '+91 22 2675 1000',
      'type': 'Multi-specialty',
    },
    {
      'name': 'Kokilaben Hospital',
      'location': const LatLng(19.1136, 72.8697),
      'distance': '4.2 km',
      'phone': '+91 22 4269 8888',
      'type': 'Multi-specialty',
    },
    {
      'name': 'Breach Candy Hospital',
      'location': const LatLng(18.9667, 72.8081),
      'distance': '2.7 km',
      'phone': '+91 22 2367 1888',
      'type': 'Multi-specialty',
    },
  ];

  // Getters
  Set<Marker> get markers => _markers.value;
  Set<Polyline> get polylines => _polylines.value;
  LatLng get currentLocation => _currentLocation.value;
  bool get isLocationPermissionGranted => _isLocationPermissionGranted.value;
  bool get isLoadingLocation => _isLoadingLocation.value;
  List<Map<String, dynamic>> get hospitalLocations => _hospitalLocations;

  @override
  void onInit() {
    super.onInit();
    _checkApiConfiguration();
    _initializeLocation();
    _startAmbulanceTracking();
  }

  @override
  void onClose() {
    _ambulanceSubscription?.cancel();
    super.onClose();
  }

  void _checkApiConfiguration() {
    if (!ApiConfig.isGoogleMapsConfigured) {
      // Delay snackbar until after GetX is fully initialized
      Future.delayed(Duration(seconds: 1), () {
        if (Get.context != null) {
          Get.snackbar(
            'Configuration Required',
            'Google Maps API key not configured. Please check GOOGLE_MAPS_SETUP.md',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      });
    }
  }

  Future<void> _initializeLocation() async {
    await _checkLocationPermission();
    if (_isLocationPermissionGranted.value) {
      await getCurrentLocation();
    }
    _addHospitalMarkers();
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.status;
    if (status.isGranted) {
      _isLocationPermissionGranted.value = true;
    } else {
      final result = await Permission.location.request();
      _isLocationPermissionGranted.value = result.isGranted;
    }
  }

  Future<void> getCurrentLocation() async {
    if (!_isLocationPermissionGranted.value) {
      await _checkLocationPermission();
      if (!_isLocationPermissionGranted.value) {
        Get.snackbar(
          'Permission Required',
          'Location permission is required to show your current location',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
    }

    try {
      _isLoadingLocation.value = true;
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'Location Services Disabled',
          'Please enable location services to use this feature',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
      
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      _currentLocation.value = LatLng(position.latitude, position.longitude);
      
      // Add current location marker
      _markers.removeWhere((marker) => marker.markerId.value == 'current_location');
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation.value,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'Current position',
          ),
        ),
      );
      
      // Update hospital distances
      updateHospitalDistances();
      
      // Move camera to current location
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_currentLocation.value, 14.0),
        );
      }
      
      Get.snackbar(
        'Location Updated',
        'Current location found successfully',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      String errorMessage = 'Failed to get current location';
      if (e.toString().contains('timeout')) {
        errorMessage = 'Location request timed out. Please try again.';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Location permission denied';
      }
      
      Get.snackbar(
        'Location Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoadingLocation.value = false;
    }
  }

  void _addHospitalMarkers() {
    for (int i = 0; i < _hospitalLocations.length; i++) {
      final hospital = _hospitalLocations[i];
      _markers.add(
        Marker(
          markerId: MarkerId('hospital_$i'),
          position: hospital['location'],
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: hospital['name'],
            snippet: '${hospital['type']} • ${hospital['distance']}',
            onTap: () => _showHospitalDetails(hospital),
          ),
        ),
      );
    }
  }

  void _showHospitalDetails(Map<String, dynamic> hospital) {
    Get.dialog(
      AlertDialog(
        title: Text(hospital['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_hospital, color: Color(0xFFFF5252), size: 20),
                const SizedBox(width: 8),
                Text(hospital['type']),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF2196F3), size: 20),
                const SizedBox(width: 8),
                Text('Distance: ${hospital['distance']}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, color: Color(0xFF4CAF50), size: 20),
                const SizedBox(width: 8),
                Text(hospital['phone']),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              getDirections(hospital['location']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
            ),
            child: const Text('Get Directions', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void getDirections(LatLng destination) {
    // Calculate route and show directions
    Get.snackbar(
      'Directions',
      'Opening navigation to selected hospital...',
      backgroundColor: const Color(0xFF2196F3),
      colorText: Colors.white,
    );
    
    // In a real app, you would integrate with Google Directions API
    // For now, we'll show a simple route line
    _showRouteToHospital(destination);
  }

  void _showRouteToHospital(LatLng destination) {
    // Add polyline for route visualization
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              _currentLocation.value.latitude < destination.latitude 
                  ? _currentLocation.value.latitude 
                  : destination.latitude,
              _currentLocation.value.longitude < destination.longitude 
                  ? _currentLocation.value.longitude 
                  : destination.longitude,
            ),
            northeast: LatLng(
              _currentLocation.value.latitude > destination.latitude 
                  ? _currentLocation.value.latitude 
                  : destination.latitude,
              _currentLocation.value.longitude > destination.longitude 
                  ? _currentLocation.value.longitude 
                  : destination.longitude,
            ),
          ),
          100.0,
        ),
      );
    }
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    // Set custom map style if needed
    _setMapStyle();
    
    if (_isLocationPermissionGranted.value) {
      getCurrentLocation();
    }
  }
  
  Future<void> _setMapStyle() async {
    try {
      // You can add custom map styling here if needed
      // const String mapStyle = '[{"featureType":"all","elementType":"geometry.fill","stylers":[{"weight":"2.00"}]}]';
      // await _mapController?.setMapStyle(mapStyle);
    } catch (e) {
      // Map style loading failed, continue with default style
    }
  }

  void searchNearbyHospitals() {
    // Filter hospitals by distance (simulate search)
    Get.snackbar(
      'Search Results',
      'Found ${_hospitalLocations.length} hospitals nearby',
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
    );
  }

  double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    ) / 1000; // Convert to kilometers
  }

  void updateHospitalDistances() {
    for (int i = 0; i < _hospitalLocations.length; i++) {
      final distance = calculateDistance(_currentLocation.value, _hospitalLocations[i]['location']);
      _hospitalLocations[i]['distance'] = '${distance.toStringAsFixed(1)} km';
    }
    
    // Sort by distance
    _hospitalLocations.sort((a, b) {
      final distanceA = double.parse(a['distance'].toString().replaceAll(' km', ''));
      final distanceB = double.parse(b['distance'].toString().replaceAll(' km', ''));
      return distanceA.compareTo(distanceB);
    });
    
    // Refresh markers
    _markers.removeWhere((marker) => marker.markerId.value.startsWith('hospital_'));
    _addHospitalMarkers();
  }

  // Start tracking active ambulances
  void _startAmbulanceTracking() {
    _ambulanceSubscription = _ambulanceService
        .getActiveAmbulancesStream()
        .listen((ambulances) {
      _updateAmbulanceMarkers(ambulances);
    });
  }

  // Update ambulance markers on map
  void _updateAmbulanceMarkers(List<Map<String, dynamic>> ambulances) {
    // Remove existing ambulance markers
    _markers.removeWhere((marker) => marker.markerId.value.startsWith('ambulance_'));
    
    // Add new ambulance markers
    for (var ambulance in ambulances) {
      final position = LatLng(
        ambulance['latitude'] ?? 19.0760,
        ambulance['longitude'] ?? 72.8777,
      );
      
      Color markerColor = _getAmbulanceMarkerColor(ambulance['status']);
      
      _markers.add(
        Marker(
          markerId: MarkerId('ambulance_${ambulance['ambulanceId']}'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(_getMarkerHue(markerColor)),
          infoWindow: InfoWindow(
            title: 'Ambulance ${ambulance['ambulanceId']}',
            snippet: '${ambulance['status']} • Speed: ${ambulance['speed']?.toStringAsFixed(1) ?? '0'} km/h',
            onTap: () => _showAmbulanceDetails(ambulance),
          ),
          rotation: ambulance['heading']?.toDouble() ?? 0.0,
        ),
      );
    }
  }

  Color _getAmbulanceMarkerColor(String status) {
    switch (status) {
      case 'active':
      case 'enRoute':
        return Colors.green;
      case 'atPickup':
        return Colors.orange;
      case 'toHospital':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  double _getMarkerHue(Color color) {
    if (color == Colors.green) return BitmapDescriptor.hueGreen;
    if (color == Colors.orange) return BitmapDescriptor.hueOrange;
    if (color == Colors.blue) return BitmapDescriptor.hueBlue;
    return BitmapDescriptor.hueRed;
  }

  void _showAmbulanceDetails(Map<String, dynamic> ambulance) {
    Get.dialog(
      AlertDialog(
        title: Text('Ambulance ${ambulance['ambulanceId']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.local_shipping, 'Status', ambulance['status']),
            _buildDetailRow(Icons.speed, 'Speed', '${ambulance['speed']?.toStringAsFixed(1) ?? '0'} km/h'),
            _buildDetailRow(Icons.person, 'Driver', ambulance['driverId'] ?? 'Not assigned'),
            if (ambulance['emergencyRequestId'] != null)
              _buildDetailRow(Icons.emergency, 'Emergency ID', ambulance['emergencyRequestId']),
            if (ambulance['destination'] != null)
              _buildDetailRow(Icons.location_on, 'Destination', ambulance['destination']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          if (ambulance['emergencyRequestId'] != null)
            ElevatedButton(
              onPressed: () {
                Get.back();
                _showAmbulanceRoute(ambulance);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5252)),
              child: const Text('Show Route', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFFFF5252)),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Show ambulance route
  void _showAmbulanceRoute(Map<String, dynamic> ambulance) async {
    try {
      final route = await _ambulanceService.getAmbulanceRoute(ambulance['ambulanceId']);
      if (route != null) {
        _displayRoute(route);
      } else {
        Get.snackbar(
          'Route Not Available',
          'Route information not found for this ambulance',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load route information',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Display route on map
  void _displayRoute(Map<String, dynamic> route) {
    // Clear existing polylines
    _polylines.clear();
    
    // Create route polyline
    final routePoints = route['routePoints'] as List<dynamic>? ?? [];
    if (routePoints.isNotEmpty) {
      final points = routePoints.map((point) => 
        LatLng(point['latitude'], point['longitude'])
      ).toList();
      
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('ambulance_route'),
          points: points,
          color: const Color(0xFFFF5252),
          width: 4,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );
      
      // Fit camera to show entire route
      if (_mapController != null && points.length >= 2) {
        _fitCameraToPoints(points);
      }
    }
  }

  // Fit camera to show all points
  void _fitCameraToPoints(List<LatLng> points) {
    if (points.isEmpty) return;
    
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    
    for (var point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }
    
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0,
      ),
    );
  }

  // Add emergency location markers
  void addEmergencyMarkers(List<Map<String, dynamic>> emergencies) {
    // Remove existing emergency markers
    _markers.removeWhere((marker) => marker.markerId.value.startsWith('emergency_'));
    
    for (var emergency in emergencies) {
      if (emergency['pickupLocation'] != null) {
        // Parse location string to coordinates (simplified)
        final pickupCoords = _parseLocationString(emergency['pickupLocation']);
        if (pickupCoords != null) {
          _markers.add(
            Marker(
              markerId: MarkerId('emergency_pickup_${emergency['id']}'),
              position: pickupCoords,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
              infoWindow: InfoWindow(
                title: 'Emergency Pickup',
                snippet: emergency['emergencyType'] ?? 'Medical Emergency',
              ),
            ),
          );
        }
      }
      
      if (emergency['hospitalLocation'] != null) {
        final hospitalCoords = _parseLocationString(emergency['hospitalLocation']);
        if (hospitalCoords != null) {
          _markers.add(
            Marker(
              markerId: MarkerId('emergency_hospital_${emergency['id']}'),
              position: hospitalCoords,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              infoWindow: InfoWindow(
                title: 'Destination Hospital',
                snippet: emergency['hospitalLocation'],
              ),
            ),
          );
        }
      }
    }
  }

  // Simple location string parser (you might want to use geocoding API)
  LatLng? _parseLocationString(String location) {
    // This is a simplified parser. In production, use geocoding API
    if (location.toLowerCase().contains('bandra')) {
      return const LatLng(19.0596, 72.8295);
    } else if (location.toLowerCase().contains('mumbai')) {
      return const LatLng(19.0760, 72.8777);
    }
    return null;
  }

  // Filter ambulances by status
  void filterAmbulancesByStatus(String status) {
    _ambulanceSubscription?.cancel();
    _ambulanceSubscription = _ambulanceService
        .getActiveAmbulancesStream()
        .map((ambulances) => ambulances.where((a) => a['status'] == status).toList())
        .listen((ambulances) {
      _updateAmbulanceMarkers(ambulances);
    });
  }

  // Reset ambulance filter
  void resetAmbulanceFilter() {
    _ambulanceSubscription?.cancel();
    _startAmbulanceTracking();
  }
}
