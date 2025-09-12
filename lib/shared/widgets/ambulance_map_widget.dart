import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/services/maps_service.dart';
import '../../core/services/ambulance_location_service.dart';
import '../../core/services/emergency_request_service.dart';

class AmbulanceMapWidget extends StatefulWidget {
  final String userType; // 'hospital' or 'police'
  final double height;
  final bool showControls;
  final Function(Map<String, dynamic>)? onAmbulanceSelected;

  const AmbulanceMapWidget({
    Key? key,
    required this.userType,
    this.height = 300,
    this.showControls = true,
    this.onAmbulanceSelected,
  }) : super(key: key);

  @override
  State<AmbulanceMapWidget> createState() => _AmbulanceMapWidgetState();
}

class _AmbulanceMapWidgetState extends State<AmbulanceMapWidget> {
  final MapsService _mapsService = Get.put(MapsService());
  final AmbulanceLocationService _ambulanceService = Get.put(AmbulanceLocationService());
  final EmergencyRequestService _emergencyService = Get.put(EmergencyRequestService());
  
  String _selectedFilter = 'all';
  bool _showEmergencies = true;

  @override
  void initState() {
    super.initState();
    _loadEmergencyData();
  }

  void _loadEmergencyData() {
    if (_showEmergencies) {
      _emergencyService.getPendingRequestsStream().listen((emergencies) {
        final emergencyData = emergencies.map((e) => {
          'id': e.id,
          'pickupLocation': e.pickupLocation,
          'hospitalLocation': e.hospitalLocation,
          'emergencyType': e.emergencyTypeText,
          'status': e.statusText,
        }).toList();
        
        _mapsService.addEmergencyMarkers(emergencyData);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Google Map
            Obx(() => GoogleMap(
              onMapCreated: _mapsService.onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _mapsService.currentLocation,
                zoom: 12.0,
              ),
              markers: _mapsService.markers,
              polylines: _mapsService.polylines,
              myLocationEnabled: _mapsService.isLocationPermissionGranted,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onTap: (position) => _onMapTapped(position),
            )),
            
            // Controls overlay
            if (widget.showControls) _buildControlsOverlay(),
            
            // Legend
            _buildLegend(),
            
            // Loading indicator
            Obx(() => _mapsService.isLoadingLocation
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF5252),
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        children: [
          // Filter dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButton<String>(
              value: _selectedFilter,
              underline: const SizedBox.shrink(),
              icon: const Icon(Icons.filter_list, size: 16),
              items: [
                const DropdownMenuItem(value: 'all', child: Text('All Ambulances')),
                const DropdownMenuItem(value: 'active', child: Text('Active')),
                const DropdownMenuItem(value: 'enRoute', child: Text('En Route')),
                const DropdownMenuItem(value: 'atPickup', child: Text('At Pickup')),
                const DropdownMenuItem(value: 'toHospital', child: Text('To Hospital')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                _applyFilter(value!);
              },
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Toggle emergencies
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                _showEmergencies ? Icons.emergency : Icons.emergency_outlined,
                color: _showEmergencies ? const Color(0xFFFF5252) : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _showEmergencies = !_showEmergencies;
                });
                _loadEmergencyData();
              },
              tooltip: 'Toggle Emergency Locations',
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Current location button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.my_location, color: Color(0xFF2196F3)),
              onPressed: _mapsService.getCurrentLocation,
              tooltip: 'My Location',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Positioned(
      bottom: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Legend',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            _buildLegendItem(Colors.green, 'Active/En Route'),
            _buildLegendItem(Colors.orange, 'At Pickup'),
            _buildLegendItem(Colors.blue, 'To Hospital'),
            _buildLegendItem(Colors.red, 'Hospitals'),
            if (_showEmergencies) _buildLegendItem(Colors.purple, 'Emergencies'),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  void _applyFilter(String filter) {
    if (filter == 'all') {
      _mapsService.resetAmbulanceFilter();
    } else {
      _mapsService.filterAmbulancesByStatus(filter);
    }
  }

  void _onMapTapped(LatLng position) {
    // Handle map tap if needed
    if (widget.userType == 'police') {
      _showRouteOptions(position);
    }
  }

  void _showRouteOptions(LatLng position) {
    Get.dialog(
      AlertDialog(
        title: const Text('Route Actions'),
        content: const Text('What would you like to do at this location?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _createRouteClearance(position);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
            ),
            child: const Text('Create Route Clearance', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _createRouteClearance(LatLng position) {
    // Create route clearance for traffic police
    Get.snackbar(
      'Route Clearance',
      'Route clearance created at ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
    );
  }
}
