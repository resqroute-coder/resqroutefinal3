import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({Key? key}) : super(key: key);

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final List<AmbulanceTracker> _activeAmbulances = [
    AmbulanceTracker(
      ambulanceId: 'UP-16-AB-1234',
      driverName: 'Amit Kumar',
      patientName: 'Rajesh Sharma',
      currentLocation: 'Sector 18 Metro Station',
      destination: 'Max Hospital, Vaishali',
      eta: '8 mins',
      speed: '45 km/h',
      status: 'En Route',
      priority: 'Critical',
      distance: '3.2 km',
    ),
    AmbulanceTracker(
      ambulanceId: 'UP-16-AB-5678',
      driverName: 'Suresh Singh',
      patientName: 'Priya Gupta',
      currentLocation: 'DND Flyway',
      destination: 'Apollo Hospital',
      eta: '12 mins',
      speed: '38 km/h',
      status: 'En Route',
      priority: 'High',
      distance: '5.8 km',
    ),
    AmbulanceTracker(
      ambulanceId: 'UP-16-AB-9012',
      driverName: 'Vikash Yadav',
      patientName: 'Mohan Lal',
      currentLocation: 'Pickup Location',
      destination: 'Fortis Hospital',
      eta: '2 mins',
      speed: '0 km/h',
      status: 'Picking Up',
      priority: 'Medium',
      distance: '0.5 km',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Live Tracking',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              // Handle refresh
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Map Area
          Container(
            height: 250,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
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
                  // Interactive Map
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
                        
                        // Ambulance markers
                        Positioned(
                          left: 60,
                          top: 80,
                          child: _buildAmbulanceMarker('UP-16-AB-1234', const Color(0xFFFF5252)),
                        ),
                        Positioned(
                          right: 80,
                          top: 120,
                          child: _buildAmbulanceMarker('UP-16-AB-5678', const Color(0xFFFF9800)),
                        ),
                        Positioned(
                          left: 120,
                          bottom: 100,
                          child: _buildAmbulanceMarker('UP-16-AB-9012', const Color(0xFF4CAF50)),
                        ),
                        
                        // Hospital markers
                        Positioned(
                          right: 40,
                          top: 60,
                          child: _buildHospitalMarker('Max Hospital'),
                        ),
                        Positioned(
                          left: 40,
                          bottom: 80,
                          child: _buildHospitalMarker('Apollo Hospital'),
                        ),
                        
                        // Route lines
                        CustomPaint(
                          painter: RouteLinesPainter(),
                          size: Size.infinite,
                        ),
                      ],
                    ),
                  ),
                  
                  // Map Controls
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Column(
                      children: [
                        _buildMapControl(Icons.my_location, () {
                          // Center on user location
                        }),
                        const SizedBox(height: 8),
                        _buildMapControl(Icons.zoom_in, () {
                          // Zoom in
                        }),
                        const SizedBox(height: 8),
                        _buildMapControl(Icons.zoom_out, () {
                          // Zoom out
                        }),
                      ],
                    ),
                  ),
                  
                  // Legend
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLegendItem(const Color(0xFFFF5252), 'Critical'),
                          const SizedBox(width: 12),
                          _buildLegendItem(const Color(0xFFFF9800), 'High'),
                          const SizedBox(width: 12),
                          _buildLegendItem(const Color(0xFF4CAF50), 'Medium'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Active Ambulances Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active Ambulances',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '${_activeAmbulances.length} Active',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Ambulances List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _activeAmbulances.length,
              itemBuilder: (context, index) {
                return _buildAmbulanceCard(_activeAmbulances[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControl(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.black87,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
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
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildAmbulanceCard(AmbulanceTracker ambulance) {
    Color priorityColor = ambulance.priority == 'Critical'
        ? const Color(0xFFFF5252)
        : ambulance.priority == 'High'
            ? const Color(0xFFFF9800)
            : const Color(0xFF4CAF50);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ambulance.ambulanceId,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: priorityColor.withOpacity(0.3)),
                ),
                child: Text(
                  ambulance.priority,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: priorityColor,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Patient: ${ambulance.patientName}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              const Icon(Icons.drive_eta, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Driver: ${ambulance.driverName}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Color(0xFFFF5252)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ambulance.currentLocation,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              const Icon(Icons.local_hospital, size: 16, color: Color(0xFF4CAF50)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ambulance.destination,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoChip(Icons.access_time, 'ETA: ${ambulance.eta}'),
              _buildInfoChip(Icons.speed, ambulance.speed),
              _buildInfoChip(Icons.straighten, ambulance.distance),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Clear route for this ambulance
                  },
                  icon: const Icon(Icons.traffic, size: 16),
                  label: const Text('Clear Route'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Contact driver
                  },
                  icon: const Icon(Icons.phone, size: 16),
                  label: const Text('Contact'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF5252),
                    side: const BorderSide(color: Color(0xFFFF5252)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbulanceMarker(String ambulanceId, Color color) {
    return GestureDetector(
      onTap: () {
        // Show ambulance details
        _showAmbulanceDetails(ambulanceId);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
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
          Icons.local_shipping,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildHospitalMarker(String hospitalName) {
    return GestureDetector(
      onTap: () {
        // Show hospital details
        Get.snackbar('Hospital', hospitalName);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3),
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
    );
  }

  void _showAmbulanceDetails(String ambulanceId) {
    final ambulance = _activeAmbulances.firstWhere(
      (amb) => amb.ambulanceId == ambulanceId,
      orElse: () => _activeAmbulances.first,
    );
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ambulance.ambulanceId,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text('Patient: ${ambulance.patientName}'),
            Text('Driver: ${ambulance.driverName}'),
            Text('Status: ${ambulance.status}'),
            Text('ETA: ${ambulance.eta}'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      // Clear route action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                    ),
                    child: const Text('Clear Route', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.back();
                      // Contact driver
                    },
                    child: const Text('Contact'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

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

class RouteLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = const Color(0xFFFF5252).withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw route lines connecting ambulances to hospitals
    final path1 = Path();
    path1.moveTo(60, 80);
    path1.quadraticBezierTo(
      size.width * 0.5, size.height * 0.3,
      size.width - 40, 60,
    );
    canvas.drawPath(path1, routePaint);

    final path2 = Path();
    path2.moveTo(120, size.height - 100);
    path2.quadraticBezierTo(
      size.width * 0.3, size.height * 0.6,
      40, size.height - 80,
    );
    canvas.drawPath(path2, routePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class AmbulanceTracker {
  final String ambulanceId;
  final String driverName;
  final String patientName;
  final String currentLocation;
  final String destination;
  final String eta;
  final String speed;
  final String status;
  final String priority;
  final String distance;

  AmbulanceTracker({
    required this.ambulanceId,
    required this.driverName,
    required this.patientName,
    required this.currentLocation,
    required this.destination,
    required this.eta,
    required this.speed,
    required this.status,
    required this.priority,
    required this.distance,
  });
}
