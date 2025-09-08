import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/config/api_config.dart';
import '../../core/services/maps_service.dart';

class EnhancedGoogleMap extends StatefulWidget {
  final CameraPosition initialCameraPosition;
  final Set<Marker>? markers;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool zoomControlsEnabled;
  final bool mapToolbarEnabled;
  final bool compassEnabled;
  final bool trafficEnabled;
  final bool buildingsEnabled;
  final MapType mapType;
  final Function(GoogleMapController)? onMapCreated;
  final Function(LatLng)? onTap;
  final Function(LatLng)? onLongPress;

  const EnhancedGoogleMap({
    super.key,
    required this.initialCameraPosition,
    this.markers,
    this.myLocationEnabled = true,
    this.myLocationButtonEnabled = false,
    this.zoomControlsEnabled = false,
    this.mapToolbarEnabled = false,
    this.compassEnabled = true,
    this.trafficEnabled = false,
    this.buildingsEnabled = true,
    this.mapType = MapType.normal,
    this.onMapCreated,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<EnhancedGoogleMap> createState() => _EnhancedGoogleMapState();
}

class _EnhancedGoogleMapState extends State<EnhancedGoogleMap> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkConfiguration();
  }

  void _checkConfiguration() {
    if (!ApiConfig.isGoogleMapsConfigured) {
      setState(() {
        _errorMessage = 'Google Maps API key not configured';
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFFFF5252),
            ),
            SizedBox(height: 16),
            Text(
              'Loading Map...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        widget.onMapCreated?.call(controller);
      },
      initialCameraPosition: widget.initialCameraPosition,
      markers: widget.markers ?? {},
      myLocationEnabled: widget.myLocationEnabled,
      myLocationButtonEnabled: widget.myLocationButtonEnabled,
      zoomControlsEnabled: widget.zoomControlsEnabled,
      mapToolbarEnabled: widget.mapToolbarEnabled,
      compassEnabled: widget.compassEnabled,
      trafficEnabled: widget.trafficEnabled,
      buildingsEnabled: widget.buildingsEnabled,
      mapType: widget.mapType,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Map Configuration Required',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error occurred',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          _buildConfigurationInstructions(),
        ],
      ),
    );
  }

  Widget _buildConfigurationInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Setup Instructions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInstructionStep(
            '1.',
            'Get your Google Maps API key from Google Cloud Console',
          ),
          _buildInstructionStep(
            '2.',
            'Copy .env.example to .env and add your API key',
          ),
          _buildInstructionStep(
            '3.',
            'Update android/gradle.properties with your API key',
          ),
          _buildInstructionStep(
            '4.',
            'Rebuild the app to apply changes',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Get.snackbar(
                  'Configuration Status',
                  'Maps: ${ApiConfig.isGoogleMapsConfigured ? "✓" : "✗"} | '
                  'Places: ${ApiConfig.isPlacesConfigured ? "✓" : "✗"} | '
                  'Directions: ${ApiConfig.isDirectionsConfigured ? "✓" : "✗"}',
                  backgroundColor: ApiConfig.isGoogleMapsConfigured 
                      ? const Color(0xFF4CAF50) 
                      : Colors.orange,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 5),
                );
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Check Configuration',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String instruction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.orange[700],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
