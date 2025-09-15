import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:math';
import '../../core/services/ambulance_tracking_service.dart';

/// Widget for simulating ambulance movement for testing purposes
/// This helps demonstrate real-time tracking without actual GPS data
class AmbulanceSimulatorWidget extends StatefulWidget {
  const AmbulanceSimulatorWidget({super.key});

  @override
  State<AmbulanceSimulatorWidget> createState() => _AmbulanceSimulatorWidgetState();
}

class _AmbulanceSimulatorWidgetState extends State<AmbulanceSimulatorWidget> {
  final AmbulanceTrackingService _ambulanceService = Get.find<AmbulanceTrackingService>();
  Timer? _simulationTimer;
  bool _isSimulating = false;
  
  // Mumbai area bounds for realistic simulation
  final double _minLat = 18.9000;
  final double _maxLat = 19.2500;
  final double _minLng = 72.7500;
  final double _maxLng = 72.9500;
  
  final List<Map<String, dynamic>> _simulatedAmbulances = [
    {
      'ambulanceId': 'SIM_001',
      'driverId': 'sim_driver_001',
      'status': 'active',
      'emergencyRequestId': 'SIM_EMR_001',
      'destination': 'Apollo Hospital',
      'currentLat': 19.0760,
      'currentLng': 72.8777,
      'targetLat': 19.0728,
      'targetLng': 72.8826,
      'speed': 45.0,
    },
    {
      'ambulanceId': 'SIM_002', 
      'driverId': 'sim_driver_002',
      'status': 'enRoute',
      'emergencyRequestId': 'SIM_EMR_002',
      'destination': 'Lilavati Hospital',
      'currentLat': 19.0596,
      'currentLng': 72.8295,
      'targetLat': 19.0520,
      'targetLng': 72.8302,
      'speed': 38.0,
    },
  ];

  @override
  void dispose() {
    _stopSimulation();
    super.dispose();
  }

  void _startSimulation() {
    if (_isSimulating) return;
    
    setState(() {
      _isSimulating = true;
    });
    
    _simulationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateAmbulancePositions();
    });
    
    Get.snackbar(
      'Simulation Started',
      'Ambulance movement simulation is now active',
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
  
  void _stopSimulation() {
    _simulationTimer?.cancel();
    setState(() {
      _isSimulating = false;
    });
    
    if (mounted) {
      Get.snackbar(
        'Simulation Stopped',
        'Ambulance movement simulation has been stopped',
        backgroundColor: const Color(0xFFFF9800),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }
  
  void _updateAmbulancePositions() {
    final random = Random();
    
    for (var ambulance in _simulatedAmbulances) {
      // Simulate movement towards target with some randomness
      double currentLat = ambulance['currentLat'];
      double currentLng = ambulance['currentLng'];
      double targetLat = ambulance['targetLat'];
      double targetLng = ambulance['targetLng'];
      
      // Calculate movement step (roughly 50-100 meters per update)
      double latStep = (targetLat - currentLat) * 0.1 + (random.nextDouble() - 0.5) * 0.001;
      double lngStep = (targetLng - currentLng) * 0.1 + (random.nextDouble() - 0.5) * 0.001;
      
      // Update position
      ambulance['currentLat'] = currentLat + latStep;
      ambulance['currentLng'] = currentLng + lngStep;
      
      // Vary speed slightly
      ambulance['speed'] = ambulance['speed'] + (random.nextDouble() - 0.5) * 10;
      ambulance['speed'] = ambulance['speed'].clamp(20.0, 60.0);
      
      // Calculate heading
      double heading = _calculateHeading(currentLat, currentLng, targetLat, targetLng);
      
      // Update in Firestore
      _ambulanceService.updateAmbulanceLocation(
        ambulanceId: ambulance['ambulanceId'],
        driverId: ambulance['driverId'],
        latitude: ambulance['currentLat'],
        longitude: ambulance['currentLng'],
        status: ambulance['status'],
        emergencyRequestId: ambulance['emergencyRequestId'],
        destination: ambulance['destination'],
        speed: ambulance['speed'],
        heading: heading,
      );
      
      // Check if reached target, set new random target
      double distance = _calculateDistance(
        ambulance['currentLat'], 
        ambulance['currentLng'],
        targetLat, 
        targetLng
      );
      
      if (distance < 0.5) { // Within 500 meters
        ambulance['targetLat'] = _minLat + random.nextDouble() * (_maxLat - _minLat);
        ambulance['targetLng'] = _minLng + random.nextDouble() * (_maxLng - _minLng);
        
        // Randomly change status
        List<String> statuses = ['active', 'enRoute', 'atPickup', 'toHospital'];
        ambulance['status'] = statuses[random.nextInt(statuses.length)];
      }
    }
  }
  
  double _calculateHeading(double lat1, double lng1, double lat2, double lng2) {
    double dLng = lng2 - lng1;
    double y = sin(dLng) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
    double heading = atan2(y, x);
    return (heading * 180 / 3.14159 + 360) % 360;
  }
  
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // km
    double dLat = (lat2 - lat1) * 3.14159 / 180;
    double dLng = (lng2 - lng1) * 3.14159 / 180;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * 3.14159 / 180) * cos(lat2 * 3.14159 / 180) * sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.settings,
                  color: Color(0xFF2196F3),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Ambulance Simulator',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isSimulating ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isSimulating ? 'Running' : 'Stopped',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Simulate real-time ambulance movement for testing the tracking system. This will update ${_simulatedAmbulances.length} ambulances every 5 seconds.',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Ambulance status list
          ..._simulatedAmbulances.map((ambulance) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getStatusColor(ambulance['status']),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${ambulance['ambulanceId']} - ${ambulance['status']}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${ambulance['speed'].toStringAsFixed(1)} km/h',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          )),
          
          const SizedBox(height: 16),
          
          // Control buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSimulating ? null : _startSimulation,
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Start Simulation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSimulating ? _stopSimulation : null,
                  icon: const Icon(Icons.stop, size: 18),
                  label: const Text('Stop Simulation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5252),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
      case 'enRoute':
        return const Color(0xFF4CAF50);
      case 'atPickup':
        return const Color(0xFFFF9800);
      case 'toHospital':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}
