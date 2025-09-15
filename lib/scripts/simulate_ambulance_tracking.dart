import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/ambulance_tracking_service.dart';
import 'dart:async';
import 'dart:math';

class AmbulanceTrackingSimulator extends StatefulWidget {
  const AmbulanceTrackingSimulator({Key? key}) : super(key: key);

  @override
  State<AmbulanceTrackingSimulator> createState() => _AmbulanceTrackingSimulatorState();
}

class _AmbulanceTrackingSimulatorState extends State<AmbulanceTrackingSimulator> {
  final AmbulanceTrackingService _locationService = Get.find<AmbulanceTrackingService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isSimulating = false;
  Timer? _simulationTimer;
  List<Map<String, dynamic>> _simulatedAmbulances = [];
  
  // Mumbai coordinates for simulation (unused variables removed)

  @override
  void initState() {
    super.initState();
    _initializeSimulatedAmbulances();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  void _initializeSimulatedAmbulances() {
    _simulatedAmbulances = [
      {
        'id': 'MH-12-AB-1234',
        'driverId': 'driver_001',
        'driverName': 'Rajesh Kumar',
        'lat': 19.0760,
        'lng': 72.8777,
        'status': 'active',
        'speed': 45.0,
        'heading': 90.0,
        'emergencyRequestId': null,
      },
      {
        'id': 'MH-12-CD-5678',
        'driverId': 'driver_002',
        'driverName': 'Amit Sharma',
        'lat': 19.1136,
        'lng': 72.8697,
        'status': 'en_route',
        'speed': 60.0,
        'heading': 180.0,
        'emergencyRequestId': 'req_001',
      },
      {
        'id': 'MH-12-EF-9012',
        'driverId': 'driver_003',
        'driverName': 'Sunil Patil',
        'lat': 19.0330,
        'lng': 72.8570,
        'status': 'picked_up',
        'speed': 55.0,
        'heading': 270.0,
        'emergencyRequestId': 'req_002',
      },
      {
        'id': 'MH-12-GH-3456',
        'driverId': 'driver_004',
        'driverName': 'Priya Desai',
        'lat': 19.0896,
        'lng': 72.8656,
        'status': 'idle',
        'speed': 0.0,
        'heading': 0.0,
        'emergencyRequestId': null,
      },
    ];
  }

  void _startSimulation() {
    if (_isSimulating) return;
    
    setState(() {
      _isSimulating = true;
    });

    // Create sample emergency requests for simulation
    _createSampleEmergencyRequests();
    
    // Start location updates every 5 seconds
    _simulationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateAmbulanceLocations();
    });
  }

  void _stopSimulation() {
    _simulationTimer?.cancel();
    setState(() {
      _isSimulating = false;
    });
  }

  Future<void> _createSampleEmergencyRequests() async {
    try {
      // Create sample emergency request for ambulance tracking
      final sampleRequests = [
        {
          'id': 'req_001',
          'patientId': 'patient_001',
          'patientName': 'Ramesh Gupta',
          'patientPhone': '+91 98765 43210',
          'emergencyType': 'heart_attack',
          'description': 'Chest pain and difficulty breathing',
          'pickupLocation': 'Andheri West, Mumbai',
          'hospitalLocation': 'Max Super Speciality Hospital, Goregaon',
          'priority': 'critical',
          'status': 'accepted',
          'driverId': 'driver_002',
          'driverName': 'Amit Sharma',
          'ambulanceId': 'MH-12-CD-5678',
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 15))),
          'acceptedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 10))),
          'patientAge': 58,
          'patientVitals': {
            'heartRate': 110,
            'bloodPressure': '140/90',
            'oxygenSaturation': 92,
            'temperature': 98.6,
            'consciousness': 'Conscious but distressed',
          },
        },
        {
          'id': 'req_002',
          'patientId': 'patient_002',
          'patientName': 'Priya Sharma',
          'patientPhone': '+91 87654 32109',
          'emergencyType': 'accident',
          'description': 'Road accident with multiple injuries',
          'pickupLocation': 'Bandra Kurla Complex, Mumbai',
          'hospitalLocation': 'Lilavati Hospital, Bandra',
          'priority': 'high',
          'status': 'picked_up',
          'driverId': 'driver_003',
          'driverName': 'Sunil Patil',
          'ambulanceId': 'MH-12-EF-9012',
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 25))),
          'acceptedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 20))),
          'pickedUpAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 5))),
          'patientAge': 32,
          'patientVitals': {
            'heartRate': 95,
            'bloodPressure': '120/80',
            'oxygenSaturation': 96,
            'temperature': 98.2,
            'consciousness': 'Alert and oriented',
          },
        },
      ];

      for (var request in sampleRequests) {
        await _firestore
            .collection('emergency_requests')
            .doc(request['id'] as String)
            .set(request);
      }
    } catch (e) {
      print('Error creating sample requests: $e');
    }
  }

  void _updateAmbulanceLocations() {
    for (var ambulance in _simulatedAmbulances) {
      // Simulate movement based on status
      _simulateMovement(ambulance);
      
      // Update location in Firebase
      _locationService.updateAmbulanceLocation(
        ambulanceId: ambulance['id'] as String,
        driverId: ambulance['driverId'] as String,
        latitude: ambulance['lat'] as double,
        longitude: ambulance['lng'] as double,
        status: ambulance['status'] as String,
        emergencyRequestId: ambulance['emergencyRequestId'] as String?,
        speed: ambulance['speed'] as double,
        heading: ambulance['heading'] as double,
      );
    }
  }

  void _simulateMovement(Map<String, dynamic> ambulance) {
    final random = Random();
    
    switch (ambulance['status']) {
      case 'active':
      case 'en_route':
        // Simulate movement towards destination
        final speedKmh = ambulance['speed'] as double;
        final speedMs = speedKmh / 3.6; // Convert km/h to m/s
        final distanceM = speedMs * 5; // Distance in 5 seconds
        
        // Convert distance to lat/lng change (approximate)
        final latChange = (distanceM / 111320) * (random.nextBool() ? 1 : -1);
        final lngChange = (distanceM / (111320 * cos((ambulance['lat'] as double) * pi / 180))) * (random.nextBool() ? 1 : -1);
        
        ambulance['lat'] += latChange * 0.5; // Reduce movement for realistic simulation
        ambulance['lng'] += lngChange * 0.5;
        
        // Vary speed slightly
        ambulance['speed'] = (speedKmh + random.nextDouble() * 10 - 5).clamp(30.0, 80.0);
        
        // Update heading
        ambulance['heading'] = ((ambulance['heading'] as double) + random.nextDouble() * 30 - 15) % 360;
        break;
        
      case 'picked_up':
        // Simulate movement towards hospital
        final speedKmh = ambulance['speed'] as double;
        final speedMs = speedKmh / 3.6;
        final distanceM = speedMs * 5;
        
        final latChange = (distanceM / 111320) * 0.3; // Move towards hospital
        final lngChange = (distanceM / (111320 * cos((ambulance['lat'] as double) * pi / 180))) * 0.3;
        
        ambulance['lat'] += latChange;
        ambulance['lng'] += lngChange;
        
        ambulance['speed'] = (speedKmh + random.nextDouble() * 8 - 4).clamp(40.0, 70.0);
        break;
        
      case 'idle':
        // Stationary or slow movement
        ambulance['speed'] = 0.0;
        break;
    }
    
    // Keep ambulances within Mumbai bounds
    ambulance['lat'] = (ambulance['lat'] as double).clamp(18.9, 19.3);
    ambulance['lng'] = (ambulance['lng'] as double).clamp(72.7, 73.0);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ambulance Tracking Simulator',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: _isSimulating,
                  onChanged: (value) {
                    if (value) {
                      _startSimulation();
                    } else {
                      _stopSimulation();
                    }
                  },
                  activeColor: const Color(0xFF4CAF50),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              _isSimulating 
                ? 'Simulation running - Ambulances are moving and updating locations'
                : 'Simulation stopped - Click switch to start tracking simulation',
              style: TextStyle(
                color: _isSimulating ? const Color(0xFF4CAF50) : Colors.grey[600],
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Simulated Ambulances:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 8),
            
            ..._simulatedAmbulances.map((ambulance) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getStatusColor(ambulance['status'] as String),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${ambulance['id']} - ${ambulance['driverName']}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Status: ${ambulance['status']} | Speed: ${(ambulance['speed'] as double).toStringAsFixed(1)} km/h',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: () {
                // Create a test emergency request
                _createTestEmergencyRequest();
              },
              icon: const Icon(Icons.add_alert),
              label: const Text('Create Test Emergency'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5252),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
      case 'en_route':
        return const Color(0xFF2196F3);
      case 'picked_up':
        return const Color(0xFFFF9800);
      case 'idle':
        return const Color(0xFF4CAF50);
      default:
        return Colors.grey;
    }
  }

  Future<void> _createTestEmergencyRequest() async {
    try {
      final requestId = _firestore.collection('emergency_requests').doc().id;
      
      final testRequest = {
        'id': requestId,
        'patientId': 'test_patient_${DateTime.now().millisecondsSinceEpoch}',
        'patientName': 'Test Patient ${Random().nextInt(100)}',
        'patientPhone': '+91 ${Random().nextInt(9000000000) + 1000000000}',
        'emergencyType': ['heart_attack', 'stroke', 'accident', 'respiratory_distress'][Random().nextInt(4)],
        'description': 'Test emergency for simulation',
        'pickupLocation': 'Test Location, Mumbai',
        'hospitalLocation': 'Test Hospital, Mumbai',
        'priority': ['critical', 'high', 'medium'][Random().nextInt(3)],
        'status': 'pending',
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'patientAge': Random().nextInt(60) + 20,
      };

      await _firestore
          .collection('emergency_requests')
          .doc(requestId)
          .set(testRequest);

      Get.snackbar(
        'Test Emergency Created',
        'Emergency request $requestId has been created for testing',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create test emergency: $e',
        backgroundColor: const Color(0xFFFF5252),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
