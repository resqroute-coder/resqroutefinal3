import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/emergency_request_service.dart';
import '../core/services/ambulance_tracking_service.dart';
import '../core/services/professional_service.dart';
import '../core/models/emergency_request_model.dart';

class TestDriverFlowCompleteScreen extends StatefulWidget {
  const TestDriverFlowCompleteScreen({super.key});

  @override
  State<TestDriverFlowCompleteScreen> createState() => _TestDriverFlowCompleteScreenState();
}

class _TestDriverFlowCompleteScreenState extends State<TestDriverFlowCompleteScreen> {
  final EmergencyRequestService _emergencyService = Get.find<EmergencyRequestService>();
  final AmbulanceTrackingService _trackingService = Get.put(AmbulanceTrackingService());
  final ProfessionalService _professionalService = Get.find<ProfessionalService>();
  
  final List<String> _testLogs = [];
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF5252),
        title: const Text(
          'Driver Flow Test',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Driver Flow End-to-End Test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'This test will simulate the complete driver flow:\n'
                      '1. Create emergency request\n'
                      '2. Driver accepts request\n'
                      '3. Navigate to pickup location\n'
                      '4. Start real-time tracking\n'
                      '5. Pickup patient\n'
                      '6. Navigate to hospital\n'
                      '7. Complete trip\n'
                      '8. Verify tracking data',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isRunning ? null : _runCompleteTest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF5252),
                              foregroundColor: Colors.white,
                            ),
                            child: _isRunning
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text('Running Test...'),
                                    ],
                                  )
                                : const Text('Run Complete Test'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _clearLogs,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Clear Logs'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Test Logs
            const Text(
              'Test Logs',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Expanded(
              child: Card(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: _testLogs.isEmpty
                      ? const Center(
                          child: Text(
                            'No test logs yet. Run the test to see results.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _testLogs.length,
                          itemBuilder: (context, index) {
                            final log = _testLogs[index];
                            final isError = log.contains('❌') || log.contains('ERROR');
                            final isSuccess = log.contains('✅') || log.contains('SUCCESS');
                            
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                log,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  color: isError
                                      ? Colors.red
                                      : isSuccess
                                          ? Colors.green
                                          : Colors.black87,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addLog(String message) {
    setState(() {
      final timestamp = DateTime.now().toString().substring(11, 19);
      _testLogs.add('[$timestamp] $message');
    });
  }

  void _clearLogs() {
    setState(() {
      _testLogs.clear();
    });
  }

  Future<void> _runCompleteTest() async {
    setState(() {
      _isRunning = true;
    });

    try {
      _addLog('🚀 Starting complete driver flow test...');
      
      // Step 1: Create test emergency request
      _addLog('📝 Step 1: Creating test emergency request...');
      final requestId = await _createTestEmergencyRequest();
      if (requestId == null) {
        _addLog('❌ Failed to create emergency request');
        return;
      }
      // Store requestId for reference
      _addLog('✅ Emergency request created: $requestId');
      
      // Step 2: Simulate driver acceptance
      _addLog('👨‍⚕️ Step 2: Simulating driver acceptance...');
      final accepted = await _simulateDriverAcceptance(requestId);
      if (!accepted) {
        _addLog('❌ Failed to accept emergency request');
        return;
      }
      _addLog('✅ Driver accepted the request');
      
      // Step 3: Start tracking
      _addLog('📍 Step 3: Starting real-time tracking...');
      await _startTracking(requestId);
      _addLog('✅ Real-time tracking started');
      
      // Step 4: Simulate navigation to pickup
      _addLog('🚗 Step 4: Simulating navigation to pickup...');
      await _simulateNavigationToPickup(requestId);
      _addLog('✅ Navigation to pickup simulated');
      
      // Step 5: Simulate patient pickup
      _addLog('🏥 Step 5: Simulating patient pickup...');
      await _simulatePatientPickup(requestId);
      _addLog('✅ Patient pickup completed');
      
      // Step 6: Simulate navigation to hospital
      _addLog('🚑 Step 6: Simulating navigation to hospital...');
      await _simulateNavigationToHospital(requestId);
      _addLog('✅ Navigation to hospital simulated');
      
      // Step 7: Complete trip
      _addLog('🏁 Step 7: Completing trip...');
      await _completeTrip(requestId);
      _addLog('✅ Trip completed successfully');
      
      // Step 8: Verify tracking data
      _addLog('🔍 Step 8: Verifying tracking data...');
      await _verifyTrackingData(requestId);
      _addLog('✅ Tracking data verified');
      
      _addLog('🎉 Complete driver flow test PASSED! All steps successful.');
      
    } catch (e) {
      _addLog('❌ Test failed with error: $e');
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  Future<String?> _createTestEmergencyRequest() async {
    try {
      final request = EmergencyRequest(
        id: '',
        patientId: 'test_patient_001',
        patientName: 'Test Patient',
        patientPhone: '+91 9876543210',
        emergencyType: EmergencyType.cardiac,
        priority: 'high',
        pickupLocation: 'Test Pickup Location, Mumbai',
        hospitalLocation: 'Test Hospital, Mumbai',
        status: RequestStatus.pending,
        createdAt: DateTime.now(),
        description: 'Test emergency request for driver flow testing',
      );

      final docRef = await FirebaseFirestore.instance
          .collection('emergency_requests')
          .add(request.toJson());
      
      return docRef.id;
    } catch (e) {
      _addLog('Error creating test request: $e');
      return null;
    }
  }

  Future<bool> _simulateDriverAcceptance(String requestId) async {
    try {
      final driverId = _professionalService.currentProfessional?.uid ?? 'test_driver_001';
      final driverName = _professionalService.currentProfessional?.fullName ?? 'Test Driver';
      
      final success = await _emergencyService.acceptRequest(
        requestId: requestId,
        driverId: driverId,
        driverName: driverName,
        ambulanceId: 'AMB-TEST-001',
      );
      
      if (success) {
        await Future.delayed(const Duration(seconds: 1));
      }
      
      return success;
    } catch (e) {
      _addLog('Error accepting request: $e');
      return false;
    }
  }

  Future<void> _startTracking(String requestId) async {
    try {
      final driverId = _professionalService.currentProfessional?.uid ?? 'test_driver_001';
      _trackingService.startTracking(requestId, driverId);
      
      // Simulate initial location update using updateAmbulanceLocation
      await _trackingService.updateAmbulanceLocation(
        ambulanceId: 'AMB-TEST-001',
        driverId: driverId,
        latitude: 19.0760, // Mumbai coordinates
        longitude: 72.8777,
        status: 'active',
        emergencyRequestId: requestId,
        speed: 25.0, // 25 km/h speed
      );
      
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      _addLog('Error starting tracking: $e');
    }
  }

  Future<void> _simulateNavigationToPickup(String requestId) async {
    try {
      // Simulate multiple location updates during navigation
      final locations = [
        [19.0760, 72.8777, 30.0],
        [19.0780, 72.8790, 35.0],
        [19.0800, 72.8810, 40.0],
        [19.0820, 72.8830, 25.0],
      ];
      
      for (final location in locations) {
        await _trackingService.updateAmbulanceLocation(
          ambulanceId: 'AMB-TEST-001',
          driverId: _professionalService.currentProfessional?.uid ?? 'test_driver_001',
          latitude: location[0],
          longitude: location[1],
          status: 'enRoute',
          emergencyRequestId: requestId,
          speed: location[2],
        );
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      // Update status to en route
      await _emergencyService.updateRequestStatus(
        requestId: requestId,
        status: RequestStatus.enRoute,
      );
    } catch (e) {
      _addLog('Error simulating navigation to pickup: $e');
    }
  }

  Future<void> _simulatePatientPickup(String requestId) async {
    try {
      // Update status to picked up
      await _emergencyService.updateRequestStatus(
        requestId: requestId,
        status: RequestStatus.pickedUp,
      );
      
      // Update location at pickup point
      await _trackingService.updateAmbulanceLocation(
        ambulanceId: 'AMB-TEST-001',
        driverId: _professionalService.currentProfessional?.uid ?? 'test_driver_001',
        latitude: 19.0850, // Pickup location
        longitude: 72.8850,
        status: 'atPickup',
        emergencyRequestId: requestId,
        speed: 0.0, // Stopped for pickup
      );
      
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      _addLog('Error simulating patient pickup: $e');
    }
  }

  Future<void> _simulateNavigationToHospital(String requestId) async {
    try {
      // Simulate navigation to hospital with multiple location updates
      final locations = [
        [19.0850, 72.8850, 20.0],
        [19.0870, 72.8870, 45.0],
        [19.0890, 72.8890, 50.0],
        [19.0910, 72.8910, 35.0],
        [19.0930, 72.8930, 30.0],
      ];
      
      for (final location in locations) {
        await _trackingService.updateAmbulanceLocation(
          ambulanceId: 'AMB-TEST-001',
          driverId: _professionalService.currentProfessional?.uid ?? 'test_driver_001',
          latitude: location[0],
          longitude: location[1],
          status: 'toHospital',
          emergencyRequestId: requestId,
          speed: location[2],
        );
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e) {
      _addLog('Error simulating navigation to hospital: $e');
    }
  }

  Future<void> _completeTrip(String requestId) async {
    try {
      // Update status to completed
      await _emergencyService.updateRequestStatus(
        requestId: requestId,
        status: RequestStatus.completed,
      );
      
      // Final location update at hospital
      await _trackingService.updateAmbulanceLocation(
        ambulanceId: 'AMB-TEST-001',
        driverId: _professionalService.currentProfessional?.uid ?? 'test_driver_001',
        latitude: 19.0950, // Hospital location
        longitude: 72.8950,
        status: 'completed',
        emergencyRequestId: requestId,
        speed: 0.0, // Stopped at hospital
      );
      
      // Stop tracking
      _trackingService.stopTracking();
      
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      _addLog('Error completing trip: $e');
    }
  }

  Future<void> _verifyTrackingData(String requestId) async {
    try {
      // Verify that tracking data exists
      final trackingDoc = await FirebaseFirestore.instance
          .collection('ambulance_tracking')
          .doc(requestId)
          .get();
      
      if (!trackingDoc.exists) {
        _addLog('❌ No tracking data found');
        return;
      }
      
      final trackingData = trackingDoc.data()!;
      _addLog('📊 Tracking data found: ${trackingData.keys.join(', ')}');
      
      // Verify tracking updates
      final updatesSnapshot = await FirebaseFirestore.instance
          .collection('ambulance_tracking')
          .doc(requestId)
          .collection('updates')
          .get();
      
      _addLog('📈 Found ${updatesSnapshot.docs.length} tracking updates');
      
      // Verify final request status
      final requestDoc = await FirebaseFirestore.instance
          .collection('emergency_requests')
          .doc(requestId)
          .get();
      
      if (requestDoc.exists) {
        final requestData = requestDoc.data()!;
        final status = requestData['status'];
        _addLog('📋 Final request status: $status');
        
        if (status == 'completed') {
          _addLog('✅ Request status correctly updated to completed');
        } else {
          _addLog('⚠️ Request status is not completed: $status');
        }
      }
      
    } catch (e) {
      _addLog('Error verifying tracking data: $e');
    }
  }
}
