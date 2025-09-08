import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HospitalLiveTrackingScreen extends StatefulWidget {
  const HospitalLiveTrackingScreen({Key? key}) : super(key: key);

  @override
  State<HospitalLiveTrackingScreen> createState() => _HospitalLiveTrackingScreenState();
}

class _HospitalLiveTrackingScreenState extends State<HospitalLiveTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Map<String, dynamic> arguments;
  late dynamic patient;
  late String tripId;
  late String ambulanceId;
  late PatientVitals vitals;
  late TripDetails tripDetails;
  late List<TimelineEvent> timelineEvents;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Get arguments passed from hospital dashboard
    arguments = Get.arguments ?? {};
    patient = arguments['patient'];
    tripId = arguments['tripId'] ?? 'T001';
    ambulanceId = arguments['ambulanceId'] ?? 'UP-16-AB-1234';
    
    // Generate patient-specific data
    _generatePatientData();
  }

  void _generatePatientData() {
    // Generate unique vitals based on patient condition and priority
    vitals = _generateVitalsForPatient(patient);
    
    // Generate trip details
    tripDetails = _generateTripDetails(patient);
    
    // Generate timeline events
    timelineEvents = _generateTimelineEvents(patient);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              'Live Tracking',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$tripId • $ambulanceId',
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
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: Colors.green, size: 8),
                SizedBox(width: 6),
                Text(
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
      body: Column(
        children: [
          // GPS Tracking Map
          Container(
            height: 200,
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
                          painter: HospitalMapGridPainter(),
                          size: Size.infinite,
                        ),
                        
                        // Route path
                        CustomPaint(
                          painter: HospitalRoutePathPainter(),
                          size: Size.infinite,
                        ),
                        
                        // Ambulance location marker
                        Positioned(
                          left: MediaQuery.of(context).size.width * 0.4,
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
                              Icons.local_shipping,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        
                        // Hospital marker
                        Positioned(
                          right: MediaQuery.of(context).size.width * 0.15,
                          bottom: MediaQuery.of(context).size.height * 0.08,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
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
                        
                        // ETA overlay
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'ETA: 8 mins',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Live Location Indicator
                  const Positioned(
                    top: 16,
                    left: 16,
                    child: Row(
                      children: [
                        Icon(Icons.circle, color: Colors.green, size: 8),
                        SizedBox(width: 6),
                        Text(
                          'Live Location',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Tab Navigation
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFFF5252),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFFFF5252),
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Patient'),
                Tab(text: 'Trip Info'),
                Tab(text: 'Timeline'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPatientTab(),
                _buildTripInfoTab(),
                _buildTimelineTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient Information
          Container(
            width: double.infinity,
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
                    const Text(
                      'Patient Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: patient?.priority == 'critical'
                            ? const Color(0xFFFF5252)
                            : patient?.priority == 'high'
                                ? const Color(0xFFFF9800)
                                : const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        patient?.priority ?? 'medium',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: (patient?.priority == 'critical'
                            ? const Color(0xFFFF5252)
                            : patient?.priority == 'high'
                                ? const Color(0xFFFF9800)
                                : const Color(0xFF4CAF50)).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        Icons.person,
                        color: patient?.priority == 'critical'
                            ? const Color(0xFFFF5252)
                            : patient?.priority == 'high'
                                ? const Color(0xFFFF9800)
                                : const Color(0xFF4CAF50),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient?.name ?? 'Unknown Patient',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Age: ${vitals.age} years',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  patient?.condition ?? 'Unknown Condition',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Current Vitals
          Container(
            width: double.infinity,
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
                    const Row(
                      children: [
                        Icon(Icons.favorite, color: Color(0xFFFF5252), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Current Vitals',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '2 mins ago',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Vitals Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildVitalCard(
                        vitals.heartRate.toString(),
                        'Heart Rate (bpm)',
                        vitals.heartRateColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildVitalCard(
                        vitals.bloodPressure,
                        'Blood Pressure',
                        vitals.bloodPressureColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildVitalCard(
                        '${vitals.oxygenSaturation}%',
                        'Oxygen Saturation',
                        vitals.oxygenColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildVitalCard(
                        '${vitals.temperature}°F',
                        'Temperature',
                        vitals.temperatureColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Consciousness Level
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Consciousness Level',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vitals.consciousnessLevel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTripInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Driver Contact
          Container(
            width: double.infinity,
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
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(
                        Icons.local_shipping,
                        color: Color(0xFF2196F3),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tripDetails.driverName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            ambulanceId,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Make call
                        },
                        icon: const Icon(Icons.call, size: 16),
                        label: const Text('Call'),
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
                          // Send message
                        },
                        icon: const Icon(Icons.message, size: 16),
                        label: const Text('Message'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2196F3),
                          side: const BorderSide(color: Color(0xFF2196F3)),
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
          ),
          
          const SizedBox(height: 16),
          
          // Pickup Location
          Container(
            width: double.infinity,
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
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Pickup Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tripDetails.pickupLocation,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Time: ${tripDetails.pickupTime}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Destination
          Container(
            width: double.infinity,
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
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF5252),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Max Super Specialty Hospital',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tripDetails.hospitalLocation,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ETA: ${patient?.eta ?? "Unknown"}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF5252),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTimelineTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: timelineEvents.map((event) => _buildTimelineItem(event)).toList(),
      ),
    );
  }

  Widget _buildVitalCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
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

  Widget _buildTimelineItem(TimelineEvent event) {
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
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: event.isCompleted ? const Color(0xFF4CAF50) : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              event.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: event.isCompleted ? Colors.black : Colors.grey,
              ),
            ),
          ),
          Text(
            event.time,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: event.isCompleted ? const Color(0xFF4CAF50) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // Data generation methods
  PatientVitals _generateVitalsForPatient(dynamic patient) {
    if (patient == null) return PatientVitals.defaultVitals();
    
    // Generate vitals based on patient condition and priority
    switch (patient.condition) {
      case 'Cardiac Emergency':
      case 'Acute Myocardial Infarction':
        return PatientVitals.cardiacEmergency(patient.name);
      case 'Accident Victim':
        return PatientVitals.accidentVictim(patient.name);
      case 'Respiratory Distress':
        return PatientVitals.respiratoryDistress(patient.name);
      default:
        return PatientVitals.general(patient.name);
    }
  }

  TripDetails _generateTripDetails(dynamic patient) {
    if (patient == null) return TripDetails.defaultTrip();
    
    // Generate trip details based on patient data
    return TripDetails.forPatient(patient);
  }

  List<TimelineEvent> _generateTimelineEvents(dynamic patient) {
    if (patient == null) return TimelineEvent.defaultEvents();
    
    // Generate timeline based on patient priority and condition
    return TimelineEvent.forPatient(patient);
  }
}

class HospitalMapGridPainter extends CustomPainter {
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

class HospitalRoutePathPainter extends CustomPainter {
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

    // Create route path from ambulance to hospital
    final path = Path();
    path.moveTo(size.width * 0.4, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.6, size.height * 0.5,
      size.width * 0.85, size.height * 0.7,
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
    _drawArrow(canvas, Offset(size.width * 0.5, size.height * 0.4), arrowPaint);
    _drawArrow(canvas, Offset(size.width * 0.7, size.height * 0.6), arrowPaint);
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


class PatientVitals {
  final String patientName;
  final int age;
  final int heartRate;
  final String bloodPressure;
  final int oxygenSaturation;
  final double temperature;
  final String consciousnessLevel;
  final Color heartRateColor;
  final Color bloodPressureColor;
  final Color oxygenColor;
  final Color temperatureColor;

  PatientVitals({
    required this.patientName,
    required this.age,
    required this.heartRate,
    required this.bloodPressure,
    required this.oxygenSaturation,
    required this.temperature,
    required this.consciousnessLevel,
    required this.heartRateColor,
    required this.bloodPressureColor,
    required this.oxygenColor,
    required this.temperatureColor,
  });

  static PatientVitals cardiacEmergency(String name) {
    return PatientVitals(
      patientName: name,
      age: 58,
      heartRate: 110,
      bloodPressure: '140/90',
      oxygenSaturation: 92,
      temperature: 98.6,
      consciousnessLevel: 'Conscious but distressed',
      heartRateColor: const Color(0xFFFF5252),
      bloodPressureColor: const Color(0xFFFF9800),
      oxygenColor: const Color(0xFF2196F3),
      temperatureColor: const Color(0xFF4CAF50),
    );
  }

  static PatientVitals accidentVictim(String name) {
    return PatientVitals(
      patientName: name,
      age: 32,
      heartRate: 95,
      bloodPressure: '120/80',
      oxygenSaturation: 96,
      temperature: 99.2,
      consciousnessLevel: 'Alert and responsive',
      heartRateColor: const Color(0xFFFF9800),
      bloodPressureColor: const Color(0xFF4CAF50),
      oxygenColor: const Color(0xFF4CAF50),
      temperatureColor: const Color(0xFFFF9800),
    );
  }

  static PatientVitals respiratoryDistress(String name) {
    return PatientVitals(
      patientName: name,
      age: 45,
      heartRate: 88,
      bloodPressure: '110/70',
      oxygenSaturation: 89,
      temperature: 100.1,
      consciousnessLevel: 'Conscious, difficulty breathing',
      heartRateColor: const Color(0xFF4CAF50),
      bloodPressureColor: const Color(0xFF4CAF50),
      oxygenColor: const Color(0xFFFF5252),
      temperatureColor: const Color(0xFFFF5252),
    );
  }

  static PatientVitals general(String name) {
    return PatientVitals(
      patientName: name,
      age: 40,
      heartRate: 75,
      bloodPressure: '120/80',
      oxygenSaturation: 98,
      temperature: 98.6,
      consciousnessLevel: 'Alert and oriented',
      heartRateColor: const Color(0xFF4CAF50),
      bloodPressureColor: const Color(0xFF4CAF50),
      oxygenColor: const Color(0xFF4CAF50),
      temperatureColor: const Color(0xFF4CAF50),
    );
  }

  static PatientVitals defaultVitals() {
    return PatientVitals(
      patientName: 'Unknown Patient',
      age: 0,
      heartRate: 0,
      bloodPressure: 'N/A',
      oxygenSaturation: 0,
      temperature: 0.0,
      consciousnessLevel: 'Unknown',
      heartRateColor: Colors.grey,
      bloodPressureColor: Colors.grey,
      oxygenColor: Colors.grey,
      temperatureColor: Colors.grey,
    );
  }
}

class TripDetails {
  final String driverName;
  final String pickupLocation;
  final String pickupTime;
  final String hospitalLocation;

  TripDetails({
    required this.driverName,
    required this.pickupLocation,
    required this.pickupTime,
    required this.hospitalLocation,
  });

  static TripDetails forPatient(dynamic patient) {
    // Generate unique trip details based on patient
    Map<String, Map<String, String>> driverMap = {
      'Ramesh Gupta': {
        'driver': 'Rajesh Kumar',
        'pickup': 'Sector 18, Noida, UP',
        'time': '14:23',
        'hospital': 'Max Super Specialty Hospital, Sector 19, Noida, UP',
      },
      'Priya Sharma': {
        'driver': 'Mohammed Ali',
        'pickup': 'Connaught Place, New Delhi',
        'time': '15:10',
        'hospital': 'Max Super Specialty Hospital, Sector 19, Noida, UP',
      },
      'Sunil Yadav': {
        'driver': 'Sunita Devi',
        'pickup': 'Gurgaon Cyber City, Haryana',
        'time': '16:05',
        'hospital': 'Max Super Specialty Hospital, Sector 19, Noida, UP',
      },
    };

    final details = driverMap[patient?.name] ?? driverMap['Ramesh Gupta']!;
    
    return TripDetails(
      driverName: details['driver']!,
      pickupLocation: details['pickup']!,
      pickupTime: details['time']!,
      hospitalLocation: details['hospital']!,
    );
  }

  static TripDetails defaultTrip() {
    return TripDetails(
      driverName: 'Unknown Driver',
      pickupLocation: 'Unknown Location',
      pickupTime: 'Unknown',
      hospitalLocation: 'Max Super Specialty Hospital',
    );
  }
}

class TimelineEvent {
  final String title;
  final String time;
  final bool isCompleted;

  TimelineEvent(this.title, this.time, this.isCompleted);

  static List<TimelineEvent> forPatient(dynamic patient) {
    // Generate timeline based on patient condition and priority
    if (patient?.priority == 'critical') {
      return [
        TimelineEvent('Emergency call received', '14:20', true),
        TimelineEvent('Ambulance dispatched', '14:21', true),
        TimelineEvent('Patient pickup completed', '14:23', true),
        TimelineEvent('En route to hospital', '14:25', true),
        TimelineEvent('Critical vitals recorded', '14:28', true),
        TimelineEvent('Hospital notified - preparing ICU', '14:30', false),
      ];
    } else if (patient?.priority == 'high') {
      return [
        TimelineEvent('Emergency call received', '15:08', true),
        TimelineEvent('Ambulance dispatched', '15:10', true),
        TimelineEvent('Patient pickup completed', '15:12', true),
        TimelineEvent('En route to hospital', '15:15', true),
        TimelineEvent('Vitals stable, monitoring', '15:18', false),
      ];
    } else {
      return [
        TimelineEvent('Emergency call received', '16:03', true),
        TimelineEvent('Ambulance dispatched', '16:05', true),
        TimelineEvent('Patient pickup completed', '16:08', true),
        TimelineEvent('En route to hospital', '16:12', true),
        TimelineEvent('Patient stable', '16:15', false),
      ];
    }
  }

  static List<TimelineEvent> defaultEvents() {
    return [
      TimelineEvent('Emergency call received', '00:00', true),
      TimelineEvent('Ambulance dispatched', '00:00', true),
      TimelineEvent('Patient pickup completed', '00:00', true),
      TimelineEvent('En route to hospital', '00:00', false),
    ];
  }
}
