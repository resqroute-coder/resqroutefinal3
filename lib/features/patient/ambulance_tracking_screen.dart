import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/emergency_request_service.dart';
import '../../core/models/emergency_request_model.dart';
import '../../core/services/user_service.dart';

class AmbulanceTrackingScreen extends StatefulWidget {
  const AmbulanceTrackingScreen({super.key});

  @override
  State<AmbulanceTrackingScreen> createState() => _AmbulanceTrackingScreenState();
}

class _AmbulanceTrackingScreenState extends State<AmbulanceTrackingScreen> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  final EmergencyRequestService _emergencyService = Get.find<EmergencyRequestService>();
  final UserService _userService = Get.find<UserService>();
  
  EmergencyRequest? _currentRequest;
  StreamSubscription<EmergencyRequest?>? _requestSubscription;

  final Map<String, dynamic> _requestData = Get.arguments ?? {
    'requestId': 'EMR123456',
    'emergencyType': 'Cardiac Emergency',
    'severity': 'Critical',
    'patientName': 'John Doe',
    'location': 'Bandra West, Mumbai',
  };

  final List<Map<String, dynamic>> _trackingSteps = [
    {
      'title': 'Emergency Request Received',
      'subtitle': 'Your request has been logged',
      'icon': Icons.assignment_turned_in,
      'completed': true,
      'time': '12:34 PM',
    },
    {
      'title': 'Ambulance Dispatched',
      'subtitle': 'Ambulance MH-12-AB-1234 assigned',
      'icon': Icons.local_shipping,
      'completed': true,
      'time': '12:36 PM',
    },
    {
      'title': 'En Route to Patient',
      'subtitle': 'Driver: Rajesh Kumar',
      'icon': Icons.navigation,
      'completed': false,
      'time': '',
    },
    {
      'title': 'Patient Pickup',
      'subtitle': 'Ambulance arrives at location',
      'icon': Icons.person_add,
      'completed': false,
      'time': '',
    },
    {
      'title': 'En Route to Hospital',
      'subtitle': 'Heading to nearest hospital',
      'icon': Icons.local_hospital,
      'completed': false,
      'time': '',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
    _listenToRequestUpdates();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _requestSubscription?.cancel();
    super.dispose();
  }

  void _listenToRequestUpdates() {
    if (_userService.userId.isNotEmpty) {
      _requestSubscription = _emergencyService
          .getPatientActiveRequestStream(_userService.userId)
          .listen((request) {
        if (mounted) {
          setState(() {
            _currentRequest = request;
          });
          _updateTrackingSteps();
        }
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  String _getStatusText() {
    if (_currentRequest == null) return 'Finding Driver';
    
    switch (_currentRequest!.status) {
      case RequestStatus.pending:
        return 'Finding Driver';
      case RequestStatus.accepted:
        return 'Driver Assigned';
      case RequestStatus.enRoute:
        return 'En Route to You';
      case RequestStatus.pickedUp:
        return 'Transporting';
      case RequestStatus.completed:
        return 'Trip Completed';
      case RequestStatus.cancelled:
        return 'Request Cancelled';
      default:
        return 'Finding Driver';
    }
  }

  Color _getStatusColor() {
    if (_currentRequest == null) return Colors.orange;
    
    switch (_currentRequest!.status) {
      case RequestStatus.pending:
        return Colors.orange;
      case RequestStatus.accepted:
        return Colors.blue;
      case RequestStatus.enRoute:
        return Colors.green;
      case RequestStatus.pickedUp:
        return Colors.purple;
      case RequestStatus.completed:
        return Colors.green;
      case RequestStatus.cancelled:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _getEstimatedTime() {
    if (_currentRequest == null) return 'Calculating...';
    
    switch (_currentRequest!.status) {
      case RequestStatus.pending:
        return 'Calculating...';
      case RequestStatus.accepted:
        return '8-12 mins';
      case RequestStatus.enRoute:
        return '5-8 mins';
      case RequestStatus.pickedUp:
        return '15-20 mins';
      case RequestStatus.completed:
        return 'Arrived';
      case RequestStatus.cancelled:
        return 'N/A';
      default:
        return 'Calculating...';
    }
  }

  void _updateTrackingSteps() {
    if (_currentRequest == null) return;

    setState(() {
      // Reset all steps
      for (int i = 0; i < _trackingSteps.length; i++) {
        _trackingSteps[i]['completed'] = false;
        _trackingSteps[i]['time'] = '';
      }

      // Update based on current status
      switch (_currentRequest!.status) {
        case RequestStatus.accepted:
          _trackingSteps[0] = {..._trackingSteps[0], 'completed': true, 'time': _formatTime(_currentRequest!.acceptedAt)};
          break;
        case RequestStatus.enRoute:
          _trackingSteps[0] = {..._trackingSteps[0], 'completed': true, 'time': _formatTime(_currentRequest!.acceptedAt)};
          _trackingSteps[1] = {..._trackingSteps[1], 'completed': true, 'time': _formatTime(_currentRequest!.enRouteAt)};
          break;
        case RequestStatus.pickedUp:
          _trackingSteps[0] = {..._trackingSteps[0], 'completed': true, 'time': _formatTime(_currentRequest!.acceptedAt)};
          _trackingSteps[1] = {..._trackingSteps[1], 'completed': true, 'time': _formatTime(_currentRequest!.enRouteAt)};
          _trackingSteps[2] = {..._trackingSteps[2], 'completed': true, 'time': _formatTime(_currentRequest!.pickedUpAt)};
          break;
        case RequestStatus.completed:
          _trackingSteps[0] = {..._trackingSteps[0], 'completed': true, 'time': _formatTime(_currentRequest!.acceptedAt)};
          _trackingSteps[1] = {..._trackingSteps[1], 'completed': true, 'time': _formatTime(_currentRequest!.enRouteAt)};
          _trackingSteps[2] = {..._trackingSteps[2], 'completed': true, 'time': _formatTime(_currentRequest!.pickedUpAt)};
          _trackingSteps[3] = {..._trackingSteps[3], 'completed': true, 'time': _formatTime(_currentRequest!.completedAt)};
          break;
        default:
          break;
      }
    });
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  double _getProgressValue() {
    if (_currentRequest == null) return 0.25;
    
    switch (_currentRequest!.status) {
      case RequestStatus.pending:
        return 0.25;
      case RequestStatus.accepted:
        return 0.5;
      case RequestStatus.enRoute:
        return 0.75;
      case RequestStatus.pickedUp:
        return 0.9;
      case RequestStatus.completed:
        return 1.0;
      case RequestStatus.cancelled:
        return 0.0;
      default:
        return 0.25;
    }
  }

  void _callDriver() async {
    if (_currentRequest?.driverPhone != null && _currentRequest!.driverPhone!.isNotEmpty) {
      final Uri phoneUri = Uri(scheme: 'tel', path: _currentRequest!.driverPhone);
      try {
        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        } else {
          Get.snackbar(
            'Error',
            'Unable to make phone call',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Unable to make phone call: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        'No Driver Assigned',
        'Driver contact information not available yet',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  void _shareLocation() {
    // Implement share location functionality
    Get.snackbar(
      'Location Shared',
      'Your location has been shared with the driver',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  String _formatElapsedTime() {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tracking Ambulance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'ID: ${_currentRequest?.id.substring(0, 8).toUpperCase() ?? _requestData['requestId']}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Live',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Header
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Current Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // ETA and Timer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'ETA',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getEstimatedTime(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF5252),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                      Column(
                        children: [
                          const Text(
                            'Elapsed Time',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatElapsedTime(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _getProgressValue(),
                        backgroundColor: Colors.grey.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
                        minHeight: 6,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_getProgressValue() * 100).toInt()}% Complete',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Live Tracking Map
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
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
                    // Map placeholder for now
                    Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Live Tracking Map',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Live tracking indicator overlay
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: Colors.white, size: 8),
                            SizedBox(width: 4),
                            Text(
                              'Live Tracking',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Emergency Details
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE8E8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Color(0xFFFF5252),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Emergency Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Emergency Type', _currentRequest?.emergencyType.toString().split('.').last ?? _requestData['emergencyType']),
                  _buildDetailRow('Severity', _currentRequest?.priority.toString().split('.').last.toUpperCase() ?? _requestData['severity']),
                  _buildDetailRow('Patient Name', _currentRequest?.patientName ?? _requestData['patientName']),
                  _buildDetailRow('Location', _currentRequest?.pickupLocation ?? _requestData['location']),
                  if (_currentRequest?.driverName != null) _buildDetailRow('Driver', _currentRequest!.driverName!),
                  if (_currentRequest?.driverPhone != null) _buildDetailRow('Driver Phone', _currentRequest!.driverPhone!),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tracking Timeline
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE8E8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.timeline,
                          color: Color(0xFFFF5252),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Tracking Timeline',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ..._trackingSteps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    final isLast = index == _trackingSteps.length - 1;
                    
                    return _buildTimelineStep(step, isLast);
                  }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _callDriver,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Call Driver',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _shareLocation,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF5252)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.share_location, color: Color(0xFFFF5252)),
                          SizedBox(width: 8),
                          Text(
                            'Share Location',
                            style: TextStyle(
                              color: Color(0xFFFF5252),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(Map<String, dynamic> step, bool isLast) {
    final isCompleted = step['completed'];
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted 
                    ? const Color(0xFF4CAF50) 
                    : Colors.grey.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : step['icon'],
                color: isCompleted ? Colors.white : Colors.grey,
                size: 16,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted 
                    ? const Color(0xFF4CAF50) 
                    : Colors.grey.withValues(alpha: 0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step['title'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isCompleted ? Colors.black87 : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                step['subtitle'],
                style: TextStyle(
                  fontSize: 14,
                  color: isCompleted ? Colors.black54 : Colors.grey,
                ),
              ),
              if (step['time'].isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    step['time'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

}

