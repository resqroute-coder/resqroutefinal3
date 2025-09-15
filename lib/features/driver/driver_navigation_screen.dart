import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/emergency_request_service.dart';
import '../../core/services/ambulance_tracking_service.dart';
import '../../core/services/professional_service.dart';
import '../../core/models/emergency_request_model.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverNavigationScreen extends StatefulWidget {
  const DriverNavigationScreen({Key? key}) : super(key: key);

  @override
  State<DriverNavigationScreen> createState() => _DriverNavigationScreenState();
}

class _DriverNavigationScreenState extends State<DriverNavigationScreen> {
  final EmergencyRequestService _emergencyService = Get.find<EmergencyRequestService>();
  final AmbulanceTrackingService _trackingService = Get.put(AmbulanceTrackingService());
  final ProfessionalService _professionalService = Get.find<ProfessionalService>();
  EmergencyRequest? _currentRequest;
  String? _requestId;
  bool _isLoading = true;
  String _currentInstruction = 'Loading navigation...';
  String _buttonText = 'Confirm Patient Pickup';
  bool _isPickedUp = false;

  @override
  void initState() {
    super.initState();
    _requestId = Get.arguments as String?;
    _loadRequestDetails();
  }

  void _loadRequestDetails() async {
    if (_requestId != null) {
      final request = await _emergencyService.getRequestById(_requestId!);
      if (mounted) {
        setState(() {
          _currentRequest = request;
          _isLoading = false;
          if (request != null) {
            _updateNavigationState();
            _startTracking();
          }
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateNavigationState() {
    if (_currentRequest == null) return;
    
    switch (_currentRequest!.status) {
      case RequestStatus.enRoute:
        _currentInstruction = 'Navigate to ${_currentRequest!.pickupLocation}. Patient ${_currentRequest!.patientName} is waiting.';
        _buttonText = 'Confirm Patient Pickup';
        _isPickedUp = false;
        break;
      case RequestStatus.pickedUp:
        _currentInstruction = 'Patient picked up. Navigate to ${_currentRequest!.hospitalLocation}';
        _buttonText = 'Complete Trip';
        _isPickedUp = true;
        break;
      default:
        _currentInstruction = 'Navigate to patient location';
        _buttonText = 'Confirm Patient Pickup';
        _isPickedUp = false;
    }
  }

  void _startTracking() {
    if (_currentRequest != null) {
      final driverId = _professionalService.currentProfessional?.uid ?? '';
      _trackingService.startTracking(_currentRequest!.id, driverId);
      
      // Request route clearance for high priority emergencies
      if (_currentRequest!.priority == 'critical' || _currentRequest!.priority == 'high') {
        _trackingService.requestRouteClearance(
          requestId: _currentRequest!.id,
          ambulanceId: 'AMB_${_professionalService.currentProfessional?.uid ?? 'unknown'}',
          fromLat: 19.0760, // Default Mumbai coordinates - should be replaced with actual pickup location
          fromLng: 72.8777,
          toLat: 19.0825, // Default hospital coordinates - should be replaced with actual hospital location  
          toLng: 72.8811,
        );
      }
    }
  }

  @override
  void dispose() {
    _trackingService.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF5252),
          ),
        ),
      );
    }

    if (_currentRequest == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'Navigation',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'Request not found',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Navigation',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5252),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Active Trip',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Trip Info Header
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentRequest!.estimatedTime,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '2.3 km • Via SV Road',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _currentRequest!.patientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      _isPickedUp ? 'To Hospital' : 'Pickup Location',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Map Area
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFFF5F5F5),
              child: Stack(
                children: [
                  // Interactive Map Container
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.blue.shade50,
                          Colors.grey.shade100,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Map grid pattern
                        CustomPaint(
                          painter: MapGridPainter(),
                          size: Size.infinite,
                        ),
                        
                        // Route path
                        CustomPaint(
                          painter: RoutePathPainter(),
                          size: Size.infinite,
                        ),
                        
                        // Current location marker
                        Positioned(
                          left: MediaQuery.of(context).size.width * 0.3,
                          top: MediaQuery.of(context).size.height * 0.4,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.navigation,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                        
                        // Destination marker
                        Positioned(
                          right: MediaQuery.of(context).size.width * 0.2,
                          top: MediaQuery.of(context).size.height * 0.15,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF5252),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.local_hospital,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        
                        // Map controls
                        Positioned(
                          top: 20,
                          right: 20,
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.add, size: 20),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.remove, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Speed and status overlay
                        Positioned(
                          top: 20,
                          left: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.speed, color: Colors.white, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  '45 km/h',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
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
                  
                  // Current location indicator
                  Positioned(
                    bottom: 120,
                    right: 20,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Navigation Instruction
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE8E8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF5252), width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.navigation,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _currentInstruction,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    color: Color(0xFFFF5252),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Action Buttons
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Call Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _makePhoneCall(_currentRequest!.patientPhone);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Icon(
                      Icons.phone,
                      color: Colors.black87,
                      size: 24,
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Recenter Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Handle recenter map
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.black87,
                      size: 24,
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Details Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.toNamed('/emergency-request-details', arguments: _currentRequest!.id);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Details',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Confirm Pickup Button
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  _handleMainAction();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5252),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _buttonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMainAction() {
    if (_isPickedUp) {
      _showCompleteDialog();
    } else {
      _showConfirmPickupDialog();
    }
  }

  void _showConfirmPickupDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Confirm Patient Pickup',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Confirm that you have picked up ${_currentRequest!.patientName} and are heading to the hospital.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _confirmPickup();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Confirm Pickup',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Complete Trip',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Confirm that ${_currentRequest!.patientName} has been safely delivered to ${_currentRequest!.hospitalLocation}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _completeTrip();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Complete Trip',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmPickup() async {
    try {
      final success = await _emergencyService.updateRequestStatus(
        requestId: _currentRequest!.id,
        status: RequestStatus.pickedUp,
      );

      if (success) {
        setState(() {
          _currentRequest = _currentRequest!.copyWith(status: RequestStatus.pickedUp);
          _updateNavigationState();
        });

        Get.snackbar(
          'Patient Picked Up',
          'Patient has been picked up. Proceeding to hospital.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update pickup status. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _completeTrip() async {
    try {
      final success = await _emergencyService.updateRequestStatus(
        requestId: _currentRequest!.id,
        status: RequestStatus.completed,
      );

      if (success) {
        Get.snackbar(
          'Trip Completed',
          'Emergency trip has been completed successfully.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Navigate back to dashboard after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          Get.offAllNamed('/driver-dashboard');
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to complete trip. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        Get.snackbar(
          'Error',
          'Could not launch phone dialer',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not launch phone dialer',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

class NavigationData {
  String eta;
  String distance;
  String route;
  String patientName;
  String pickupLocation;
  String currentInstruction;

  NavigationData({
    required this.eta,
    required this.distance,
    required this.route,
    required this.patientName,
    required this.pickupLocation,
    required this.currentInstruction,
  });
}

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    // Draw grid lines
    const gridSpacing = 40.0;
    
    // Vertical lines
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Horizontal lines
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class RoutePathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = const Color(0xFFFF5252)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Create route path
    final path = Path();
    path.moveTo(size.width * 0.3, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 0.4,
      size.width * 0.7, size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.8, size.height * 0.25,
      size.width * 0.8, size.height * 0.15,
    );

    // Draw shadow first
    canvas.drawPath(path, shadowPaint);
    // Draw route
    canvas.drawPath(path, routePaint);
    
    // Draw route direction arrows
    final arrowPaint = Paint()
      ..color = const Color(0xFFFF5252)
      ..style = PaintingStyle.fill;
    
    // Add directional arrows along the path
    _drawArrow(canvas, Offset(size.width * 0.4, size.height * 0.6), arrowPaint);
    _drawArrow(canvas, Offset(size.width * 0.6, size.height * 0.35), arrowPaint);
  }

  void _drawArrow(Canvas canvas, Offset position, Paint paint) {
    final path = Path();
    path.moveTo(position.dx, position.dy - 4);
    path.lineTo(position.dx - 3, position.dy + 2);
    path.lineTo(position.dx + 3, position.dy + 2);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF5252)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw a curved route line
    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 0.3,
      size.width * 0.8, size.height * 0.2,
    );

    // Draw the path directly (simplified approach)
    canvas.drawPath(path, paint);
    
    // Add route markers
    final markerPaint = Paint()
      ..color = const Color(0xFFFF5252)
      ..style = PaintingStyle.fill;
    
    // Start point
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.8),
      4,
      markerPaint,
    );
    
    // End point
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      4,
      markerPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
