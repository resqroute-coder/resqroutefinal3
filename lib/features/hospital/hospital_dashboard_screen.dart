import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/professional_service.dart';
import '../../shared/widgets/ambulance_map_widget.dart';
import '../../shared/widgets/ambulance_simulator_widget.dart';
import '../../scripts/simulate_ambulance_tracking.dart';
import '../../scripts/test_patient_tracking_workflow.dart';

class HospitalDashboardScreen extends StatefulWidget {
  const HospitalDashboardScreen({Key? key}) : super(key: key);

  @override
  State<HospitalDashboardScreen> createState() => _HospitalDashboardScreenState();
}

class _HospitalDashboardScreenState extends State<HospitalDashboardScreen> {
  final ProfessionalService _professionalService = Get.put(ProfessionalService());
  Map<String, dynamic> _hospitalMetrics = {};

  @override
  void initState() {
    super.initState();
    _loadHospitalMetrics();
  }

  Future<void> _loadHospitalMetrics() async {
    final metrics = await _professionalService.getHospitalMetrics();
    if (mounted) {
      setState(() {
        _hospitalMetrics = metrics;
      });
    }
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
        title: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hospital Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _professionalService.professionalName,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        )),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Handle notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Get.toNamed('/hospital-profile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Metrics Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      _hospitalMetrics['availableBeds']?.toString() ?? '0',
                      'Available Beds',
                      Icons.bed,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      _hospitalMetrics['activeAmbulances']?.toString() ?? '0',
                      'Active Ambulances',
                      Icons.local_shipping,
                      const Color(0xFF2196F3),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      _hospitalMetrics['incomingPatients']?.toString() ?? '0',
                      'Incoming Patients',
                      Icons.person_add,
                      const Color(0xFFFF9800),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      _hospitalMetrics['criticalCases']?.toString() ?? '0',
                      'Critical Cases',
                      Icons.warning,
                      const Color(0xFFFF5252),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Ambulance Tracking Map
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Live Ambulance Tracking',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.fullscreen, color: Color(0xFFFF5252)),
                        onPressed: () {
                          Get.toNamed('/hospital-live-tracking');
                        },
                        tooltip: 'Full Screen Map',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const AmbulanceMapWidget(
                    userType: 'hospital',
                    height: 250,
                    showControls: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Incoming Patients Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Incoming Patients',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // View all incoming patients
                    },
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFFFF5252),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Incoming Patients List
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _professionalService.getIncomingPatientsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF5252),
                      ),
                    ),
                  );
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No Incoming Patients',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Incoming emergency patients will appear here',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return _buildPatientCard(snapshot.data![index]);
                  },
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Testing Tools (Development Only)
            const AmbulanceSimulatorWidget(),
            
            const SizedBox(height: 16),
            
            // Ambulance Tracking Simulator
            const AmbulanceTrackingSimulator(),
            
            const SizedBox(height: 16),
            
            // Patient Tracking Workflow Tester
            const PatientTrackingWorkflowTester(),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildQuickAction(
                    'Bed\nManagement',
                    Icons.bed,
                    const Color(0xFF4CAF50),
                    () {
                      // Navigate to bed management
                    },
                  ),
                  _buildQuickAction(
                    'Driver\nManagement',
                    Icons.local_shipping,
                    const Color(0xFF2196F3),
                    () {
                      // Navigate to driver management
                    },
                  ),
                  _buildQuickAction(
                    'Patient\nIntake',
                    Icons.person_add,
                    const Color(0xFF9C27B0),
                    () {
                      // Navigate to patient intake
                    },
                  ),
                  _buildQuickAction(
                    'Reports',
                    Icons.assessment,
                    const Color(0xFFFF9800),
                    () {
                      Get.toNamed('/hospital-reports');
                    },
                  ),
                  _buildQuickAction(
                    'Emergency\nAlert',
                    Icons.add_alert,
                    const Color(0xFF009688),
                    () {
                      Get.toNamed('/emergency-alert-creation');
                    },
                  ),
                  _buildQuickAction(
                    'Medical\nRecords',
                    Icons.folder_special,
                    const Color(0xFFFF5252),
                    () {
                      // Navigate to medical records
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String value, String label, IconData icon, Color color) {
    return Container(
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
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
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

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    Color priorityColor = patient['priority'] == 'critical'
        ? const Color(0xFFFF5252)
        : patient['priority'] == 'high'
            ? const Color(0xFFFF9800)
            : const Color(0xFF4CAF50);

    return GestureDetector(
      onTap: () {
        // Navigate to patient live tracking screen with patient data
        Get.toNamed('/patient-live-tracking', arguments: {
          'patient': patient,
          'tripId': patient['id'],
          'ambulanceId': patient['ambulanceId'],
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              Icons.favorite,
              color: priorityColor,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      patient['name'] ?? 'Unknown Patient',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: priorityColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (patient['priority'] ?? 'medium').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  patient['condition'] ?? 'Emergency',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_shipping,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            patient['ambulanceId'] ?? 'N/A',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            patient['driverName'] ?? 'Unknown Driver',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Column(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 4),
              Text(
                'ETA ${patient['eta'] ?? '15 mins'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class IncomingPatient {
  final String name;
  final String condition;
  final String ambulanceId;
  final String driverName;
  final String eta;
  final String priority;

  IncomingPatient({
    required this.name,
    required this.condition,
    required this.ambulanceId,
    required this.driverName,
    required this.eta,
    required this.priority,
  });
}
