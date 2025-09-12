import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/emergency_request_service.dart';
import '../core/models/emergency_request_model.dart';

class DebugEmergencyRequests extends StatefulWidget {
  @override
  _DebugEmergencyRequestsState createState() => _DebugEmergencyRequestsState();
}

class _DebugEmergencyRequestsState extends State<DebugEmergencyRequests> {
  final EmergencyRequestService _emergencyService = EmergencyRequestService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _allRequests = [];
  List<EmergencyRequest> _pendingRequests = [];
  String _debugInfo = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _debugEmergencyRequests();
  }

  Future<void> _debugEmergencyRequests() async {
    setState(() {
      _isLoading = true;
      _debugInfo = 'Starting debug...\n';
    });

    try {
      // 1. Check Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      _addDebugInfo('Current User: ${user?.email ?? 'Not logged in'}');
      _addDebugInfo('User ID: ${user?.uid ?? 'None'}');

      // 2. Check all emergency requests in Firestore (raw data)
      _addDebugInfo('\n=== RAW FIRESTORE DATA ===');
      final allRequestsSnapshot = await _firestore
          .collection('emergency_requests')
          .orderBy('createdAt', descending: true)
          .get();

      _addDebugInfo('Total requests in Firestore: ${allRequestsSnapshot.docs.length}');
      
      _allRequests = allRequestsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      for (int i = 0; i < _allRequests.length; i++) {
        final request = _allRequests[i];
        _addDebugInfo('\nRequest ${i + 1}:');
        _addDebugInfo('  ID: ${request['id']}');
        _addDebugInfo('  Status: "${request['status']}" (${request['status'].runtimeType})');
        _addDebugInfo('  Patient: ${request['patientName']}');
        _addDebugInfo('  Emergency Type: ${request['emergencyType']}');
        _addDebugInfo('  Created: ${request['createdAt']}');
      }

      // 3. Check pending requests query
      _addDebugInfo('\n=== PENDING REQUESTS QUERY ===');
      final pendingSnapshot = await _firestore
          .collection('emergency_requests')
          .where('status', isEqualTo: 'pending')
          .get();

      _addDebugInfo('Pending requests found: ${pendingSnapshot.docs.length}');

      // 4. Test the service stream
      _addDebugInfo('\n=== SERVICE STREAM TEST ===');
      final streamData = await _emergencyService.getPendingRequestsStream().first;
      _addDebugInfo('Service stream returned: ${streamData.length} requests');

      _pendingRequests = streamData;
      for (int i = 0; i < _pendingRequests.length; i++) {
        final request = _pendingRequests[i];
        _addDebugInfo('  Request ${i + 1}: ${request.patientName} - ${request.status}');
      }

      // 5. Check Firebase rules by trying to read as current user
      _addDebugInfo('\n=== FIREBASE RULES TEST ===');
      try {
        await _firestore.collection('emergency_requests').limit(1).get();
        _addDebugInfo('✅ Can read emergency_requests collection');
      } catch (e) {
        _addDebugInfo('❌ Cannot read emergency_requests: $e');
      }

      // 6. Create a test request to verify creation
      _addDebugInfo('\n=== TEST REQUEST CREATION ===');
      if (user != null) {
        try {
          final testRequestId = await _emergencyService.createEmergencyRequest(
            patientId: user.uid,
            patientName: 'Debug Test Patient',
            patientPhone: '+91 9999999999',
            emergencyType: EmergencyType.medical,
            description: 'Debug test emergency request',
            pickupLocation: 'Test Location',
            hospitalLocation: 'Test Hospital',
            priority: 'high',
          );
          
          if (testRequestId != null) {
            _addDebugInfo('✅ Test request created: $testRequestId');
            
            // Check if it appears in pending requests
            await Future.delayed(Duration(seconds: 2));
            final updatedStream = await _emergencyService.getPendingRequestsStream().first;
            _addDebugInfo('Pending requests after creation: ${updatedStream.length}');
          } else {
            _addDebugInfo('❌ Failed to create test request');
          }
        } catch (e) {
          _addDebugInfo('❌ Error creating test request: $e');
        }
      }

    } catch (e) {
      _addDebugInfo('❌ Debug error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _addDebugInfo(String info) {
    setState(() {
      _debugInfo += '$info\n';
    });
    print(info); // Also print to console
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Requests Debug'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _debugEmergencyRequests,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              LinearProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Debug Information:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    _debugInfo,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
