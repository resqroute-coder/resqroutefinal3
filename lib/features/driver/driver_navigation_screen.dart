import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverNavigationScreen extends StatefulWidget {
  const DriverNavigationScreen({Key? key}) : super(key: key);

  @override
  State<DriverNavigationScreen> createState() => _DriverNavigationScreenState();
}

class _DriverNavigationScreenState extends State<DriverNavigationScreen> {
  final NavigationData navigationData = NavigationData(
    eta: '6 min',
    distance: '2.3 km',
    route: 'Via SV Road',
    patientName: 'Raj Patel',
    pickupLocation: 'Pickup Location',
    currentInstruction: 'In 200m, turn right onto Linking Road',
  );

  @override
  Widget build(BuildContext context) {
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
                        navigationData.eta,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '${navigationData.distance} • ${navigationData.route}',
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
                      navigationData.patientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      navigationData.pickupLocation,
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
                                  color: Colors.black.withOpacity(0.2),
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
                                  color: Colors.black.withOpacity(0.2),
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
                                      color: Colors.black.withOpacity(0.1),
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
                                      color: Colors.black.withOpacity(0.1),
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
                              color: Colors.black.withOpacity(0.7),
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
                      navigationData.currentInstruction,
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
                      // Handle call patient
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
                      // Handle trip details
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
                  _showConfirmPickupDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5252),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Confirm Patient Pickup',
                  style: TextStyle(
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

  void _showConfirmPickupDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Pickup'),
        content: const Text('Have you picked up the patient and are ready to proceed to the hospital?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showPatientPickedUpSuccess();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Confirm Pickup', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPatientPickedUpSuccess() {
    Get.snackbar(
      'Patient Picked Up',
      'Navigating to hospital. Drive safely!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
    
    // Update navigation to hospital
    setState(() {
      navigationData.currentInstruction = 'Proceed to Apollo Hospital - 1.8 km remaining';
      navigationData.pickupLocation = 'To Hospital';
    });
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
      ..color = Colors.grey.withOpacity(0.2)
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
      ..color = Colors.black.withOpacity(0.2)
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
