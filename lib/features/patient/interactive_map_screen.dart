import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/services/maps_service.dart';
import '../../core/services/user_service.dart';
import '../../shared/widgets/enhanced_google_map.dart';
import '../../core/config/api_config.dart';

class InteractiveMapScreen extends StatefulWidget {
  const InteractiveMapScreen({super.key});

  @override
  State<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends State<InteractiveMapScreen> {
  final MapsService _mapsService = Get.put(MapsService());
  final UserService _userService = Get.find<UserService>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF5252),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Interactive Map',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              _mapsService.searchNearbyHospitals();
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white),
            onPressed: () {
              _mapsService.getCurrentLocation();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Location info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFFFF5252)),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Location',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        _userService.userLocation,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )),
                ),
                Obx(() => _mapsService.isLoadingLocation
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFFF5252),
                        ),
                      )
                    : const Icon(Icons.gps_fixed, color: Color(0xFF4CAF50))),
              ],
            ),
          ),
          
          // Map container
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Obx(() => EnhancedGoogleMap(
                  onMapCreated: _mapsService.onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _mapsService.currentLocation,
                    zoom: 14.0,
                  ),
                  markers: _mapsService.markers,
                  myLocationEnabled: _mapsService.isLocationPermissionGranted,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: true,
                  trafficEnabled: true,
                  buildingsEnabled: true,
                  mapType: MapType.normal,
                  onTap: (LatLng position) {
                    // Handle map tap
                    Get.snackbar(
                      'Location Selected',
                      'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}',
                      backgroundColor: const Color(0xFF2196F3),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                    );
                  },
                )),
              ),
            ),
          ),
          
          // Bottom action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Hospital list button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showHospitalListDialog();
                    },
                    icon: const Icon(Icons.local_hospital, color: Color(0xFFFF5252)),
                    label: const Text(
                      'View Hospital List',
                      style: TextStyle(color: Color(0xFFFF5252)),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFF5252)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Emergency button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.toNamed('/emergency-request');
                    },
                    icon: const Icon(Icons.emergency, color: Colors.white),
                    label: const Text(
                      'Request Emergency Ambulance',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5252),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHospitalListDialog() {
    Get.dialog(
      Dialog(
        child: Container(
          width: double.maxFinite,
          height: 500,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.local_hospital, color: Color(0xFFFF5252)),
                  const SizedBox(width: 8),
                  const Text(
                    'Nearby Hospitals',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _mapsService.hospitalLocations.length,
                  itemBuilder: (context, index) {
                    final hospital = _mapsService.hospitalLocations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE8E8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.local_hospital,
                            color: Color(0xFFFF5252),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          hospital['name'],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hospital['type']),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  hospital['distance'],
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                // Call hospital
                                Get.snackbar(
                                  'Calling',
                                  'Dialing ${hospital['phone']}...',
                                  backgroundColor: const Color(0xFF4CAF50),
                                  colorText: Colors.white,
                                );
                              },
                              icon: const Icon(Icons.phone, color: Color(0xFF4CAF50)),
                            ),
                            IconButton(
                              onPressed: () {
                                Get.back();
                                // Show directions
                                _mapsService.getDirections(hospital['location']);
                              },
                              icon: const Icon(Icons.directions, color: Color(0xFF2196F3)),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
                          Get.back();
                          // Focus on hospital marker
                          _mapsService.mapController?.animateCamera(
                            CameraUpdate.newLatLngZoom(hospital['location'], 16.0),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
