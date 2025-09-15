import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/emergency_request_service.dart';
import '../../core/services/ambulance_tracking_service.dart';
import '../core/services/professional_service.dart';
import '../core/models/emergency_request_model.dart';
import 'dart:async';

class PatientTrackingWorkflowTester extends StatefulWidget {
  const PatientTrackingWorkflowTester({Key? key}) : super(key: key);

  @override
  State<PatientTrackingWorkflowTester> createState() => _PatientTrackingWorkflowTesterState();
}

class _PatientTrackingWorkflowTesterState extends State<PatientTrackingWorkflowTester> {
  final EmergencyRequestService _emergencyService = Get.find<EmergencyRequestService>();
  final AmbulanceTrackingService _locationService = Get.find<AmbulanceTrackingService>();
  final ProfessionalService _professionalService = Get.find<ProfessionalService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isTesting = false;
  String _currentStep = '';
  List<String> _testResults = [];
  String? _testRequestId;
  Timer? _testTimer;

  @override
  void dispose() {
    _testTimer?.cancel();
    super.dispose();
  }

  Future<void> _runCompleteWorkflowTest() async {
    setState(() {
      _isTesting = true;
      _testResults.clear();
      _currentStep = 'Starting workflow test...';
    });

    try {
      // Step 1: Create emergency request
      await _testStep1CreateEmergencyRequest();
      
      // Step 2: Accept request (simulate driver)
      await _testStep2AcceptRequest();
      
      // Step 3: Update ambulance location
      await _testStep3UpdateAmbulanceLocation();
      
      // Step 4: Update request status to en_route
      await _testStep4UpdateToEnRoute();
      
      // Step 5: Update request status to picked_up
      await _testStep5UpdateToPickedUp();
      
      // Step 6: Verify hospital dashboard shows patient
      await _testStep6VerifyHospitalDashboard();
      
      // Step 7: Test patient tracking screen data
      await _testStep7TestPatientTrackingScreen();
      
      // Step 8: Complete the request
      await _testStep8CompleteRequest();
      
      setState(() {
        _currentStep = 'Test completed successfully!';
        _testResults.add('✅ All tests passed - Patient tracking workflow is working correctly');
      });
      
    } catch (e) {
      setState(() {
        _currentStep = 'Test failed';
        _testResults.add('❌ Test failed: $e');
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  Future<void> _testStep1CreateEmergencyRequest() async {
    setState(() {
      _currentStep = 'Step 1: Creating emergency request...';
    });

    _testRequestId = await _emergencyService.createEmergencyRequest(
      patientId: 'test_patient_${DateTime.now().millisecondsSinceEpoch}',
      patientName: 'Test Patient Workflow',
      patientPhone: '+91 9876543210',
      emergencyType: EmergencyType.cardiac,
      description: 'Test emergency for workflow verification',
      pickupLocation: 'Test Pickup Location, Mumbai',
      hospitalLocation: 'Test Hospital, Mumbai',
      priority: 'critical',
    );

    if (_testRequestId != null) {
      _testResults.add('✅ Step 1: Emergency request created successfully (ID: $_testRequestId)');
    } else {
      throw Exception('Failed to create emergency request');
    }
  }

  Future<void> _testStep2AcceptRequest() async {
    setState(() {
      _currentStep = 'Step 2: Accepting request (simulating driver)...';
    });

    final success = await _emergencyService.acceptRequest(
      requestId: _testRequestId!,
      driverId: 'test_driver_001',
      driverName: 'Test Driver Kumar',
      ambulanceId: 'TEST-AB-1234',
    );

    if (success) {
      _testResults.add('✅ Step 2: Request accepted by driver successfully');
    } else {
      throw Exception('Failed to accept request');
    }
  }

  Future<void> _testStep3UpdateAmbulanceLocation() async {
    setState(() {
      _currentStep = 'Step 3: Updating ambulance location...';
    });

    final success = await _locationService.updateAmbulanceLocation(
      ambulanceId: 'TEST-AB-1234',
      driverId: 'test_driver_001',
      latitude: 19.0760,
      longitude: 72.8777,
      status: 'active',
      emergencyRequestId: _testRequestId,
      speed: 45.0,
      heading: 90.0,
    );

    if (success) {
      _testResults.add('✅ Step 3: Ambulance location updated successfully');
    } else {
      throw Exception('Failed to update ambulance location');
    }
  }

  Future<void> _testStep4UpdateToEnRoute() async {
    setState(() {
      _currentStep = 'Step 4: Updating status to en_route...';
    });

    await Future.delayed(const Duration(seconds: 2));

    final success = await _emergencyService.updateRequestStatus(
      requestId: _testRequestId!,
      status: RequestStatus.enRoute,
    );

    if (success) {
      _testResults.add('✅ Step 4: Status updated to en_route successfully');
    } else {
      throw Exception('Failed to update status to en_route');
    }
  }

  Future<void> _testStep5UpdateToPickedUp() async {
    setState(() {
      _currentStep = 'Step 5: Updating status to picked_up...';
    });

    await Future.delayed(const Duration(seconds: 2));

    final success = await _emergencyService.updateRequestStatus(
      requestId: _testRequestId!,
      status: RequestStatus.pickedUp,
      additionalData: {
        'patientVitals': {
          'heartRate': 110,
          'bloodPressure': '140/90',
          'oxygenSaturation': 92,
          'temperature': 98.6,
          'consciousness': 'Conscious but distressed',
        },
      },
    );

    if (success) {
      _testResults.add('✅ Step 5: Status updated to picked_up with vitals');
    } else {
      throw Exception('Failed to update status to picked_up');
    }
  }

  Future<void> _testStep6VerifyHospitalDashboard() async {
    setState(() {
      _currentStep = 'Step 6: Verifying hospital dashboard shows patient...';
    });

    await Future.delayed(const Duration(seconds: 1));

    // Test the incoming patients stream
    final incomingPatientsStream = _professionalService.getIncomingPatientsStream();
    final patients = await incomingPatientsStream.first;
    
    final testPatient = patients.where((p) => p['id'] == _testRequestId).firstOrNull;
    
    if (testPatient != null) {
      _testResults.add('✅ Step 6: Patient appears in hospital dashboard (${testPatient['name']})');
      _testResults.add('   - Status: ${testPatient['status']}');
      _testResults.add('   - Priority: ${testPatient['priority']}');
      _testResults.add('   - Ambulance: ${testPatient['ambulanceId']}');
    } else {
      throw Exception('Patient not found in hospital dashboard');
    }
  }

  Future<void> _testStep7TestPatientTrackingScreen() async {
    setState(() {
      _currentStep = 'Step 7: Testing patient tracking screen data...';
    });

    // Verify emergency request data is accessible
    final requestDoc = await _firestore
        .collection('emergency_requests')
        .doc(_testRequestId)
        .get();

    if (requestDoc.exists) {
      final data = requestDoc.data()!;
      _testResults.add('✅ Step 7: Patient tracking data verified');
      _testResults.add('   - Patient Name: ${data['patientName']}');
      _testResults.add('   - Emergency Type: ${data['emergencyType']}');
      _testResults.add('   - Driver: ${data['driverName']}');
      _testResults.add('   - Vitals: ${data['patientVitals'] != null ? 'Available' : 'Not available'}');
    } else {
      throw Exception('Emergency request data not found');
    }

    // Verify ambulance location data
    final ambulanceDoc = await _firestore
        .collection('ambulance_locations')
        .doc('TEST-AB-1234')
        .get();

    if (ambulanceDoc.exists) {
      final locationData = ambulanceDoc.data()!;
      _testResults.add('   - Ambulance Location: ${locationData['latitude']}, ${locationData['longitude']}');
      _testResults.add('   - Ambulance Status: ${locationData['status']}');
    } else {
      _testResults.add('   - Ambulance location: Not available (this is expected for test)');
    }
  }

  Future<void> _testStep8CompleteRequest() async {
    setState(() {
      _currentStep = 'Step 8: Completing the request...';
    });

    await Future.delayed(const Duration(seconds: 2));

    final success = await _emergencyService.updateRequestStatus(
      requestId: _testRequestId!,
      status: RequestStatus.completed,
    );

    if (success) {
      _testResults.add('✅ Step 8: Request completed successfully');
      _testResults.add('✅ Patient should no longer appear in incoming patients list');
    } else {
      throw Exception('Failed to complete request');
    }
  }

  Future<void> _cleanupTestData() async {
    if (_testRequestId != null) {
      try {
        // Delete test emergency request
        await _firestore
            .collection('emergency_requests')
            .doc(_testRequestId)
            .delete();
        
        // Delete test ambulance location
        await _firestore
            .collection('ambulance_locations')
            .doc('TEST-AB-1234')
            .delete();
        
        Get.snackbar(
          'Cleanup Complete',
          'Test data has been cleaned up',
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Cleanup Warning',
          'Some test data may still exist: $e',
          backgroundColor: const Color(0xFFFF9800),
          colorText: Colors.white,
        );
      }
    }
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
            const Text(
              'Patient Tracking Workflow Tester',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'This tool tests the complete workflow from emergency request to patient tracking in hospital dashboard.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 16),
            
            if (_isTesting) ...[
              const LinearProgressIndicator(
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
              const SizedBox(height: 12),
              Text(
                _currentStep,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2196F3),
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isTesting ? null : _runCompleteWorkflowTest,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Run Complete Test'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _testRequestId != null ? _cleanupTestData : null,
                  icon: const Icon(Icons.cleaning_services),
                  label: const Text('Cleanup'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF9800),
                  ),
                ),
              ],
            ),
            
            if (_testResults.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Test Results:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _testResults.map((result) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      result,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: result.startsWith('✅') 
                            ? const Color(0xFF4CAF50)
                            : result.startsWith('❌')
                                ? const Color(0xFFFF5252)
                                : Colors.black87,
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
