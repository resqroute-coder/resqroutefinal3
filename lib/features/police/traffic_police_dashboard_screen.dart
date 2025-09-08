import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrafficPoliceDashboardScreen extends StatefulWidget {
  const TrafficPoliceDashboardScreen({Key? key}) : super(key: key);

  @override
  State<TrafficPoliceDashboardScreen> createState() => _TrafficPoliceDashboardScreenState();
}

class _TrafficPoliceDashboardScreenState extends State<TrafficPoliceDashboardScreen> {
  int _selectedTabIndex = 0;

  final List<ActiveEmergency> _activeEmergencies = [
    ActiveEmergency(
      ambulanceId: 'UP-16-AB-1234',
      patientName: 'Rajesh Kumar',
      priority: 'critical',
      status: 'enroute',
      emergencyType: 'Cardiac Arrest',
      patientAge: 'Male, 58 years',
      location: 'Near DND Flyway',
      sector: 'Sector 15, Noida → Max Super Speciality Hospital',
      eta: '8 mins',
      timeUpdated: '30 secs ago',
      clearanceStatus: 'Clearance Requested',
    ),
    ActiveEmergency(
      ambulanceId: 'UP-16-AB-5678',
      patientName: 'Priya Sharma',
      priority: 'high',
      status: 'pickup',
      emergencyType: 'Road Accident',
      patientAge: 'Female, 32 years',
      location: 'Atta Market Area',
      sector: 'Sector 18, Noida → Fortis Hospital',
      eta: '15 mins',
      timeUpdated: '45 secs ago',
      clearanceStatus: 'Clearance Requested',
    ),
    ActiveEmergency(
      ambulanceId: 'UP-16-AB-9012',
      patientName: 'Amit Singh',
      priority: 'medium',
      status: 'dispatched',
      emergencyType: 'Breathing Issues',
      patientAge: 'Male, 45 years',
      location: 'Sector 62, Noida',
      sector: 'Sector 62 → Apollo Hospital',
      eta: '12 mins',
      timeUpdated: '2 mins ago',
      clearanceStatus: 'Route Cleared',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: const Color(0xFFFF5252),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.local_police,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Traffic Control',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Emergency Coordination Unit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Handle refresh
                    },
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Handle notifications
                    },
                    icon: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Get.toNamed('/traffic-police-profile');
                    },
                    icon: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            
            // Metrics Cards
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      '3',
                      'Active Emergencies',
                      const Color(0xFFFF5252),
                      Icons.emergency,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      '2',
                      'Clearance Requests',
                      const Color(0xFFFF9800),
                      Icons.traffic,
                    ),
                  ),
                ],
              ),
            ),
            
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      '1',
                      'Critical Cases',
                      const Color(0xFFFF1744),
                      Icons.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      '12',
                      'Routes Cleared',
                      const Color(0xFF4CAF50),
                      Icons.check_circle,
                    ),
                  ),
                ],
              ),
            ),
            
            // Tab Navigation
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  _buildTabButton('Live Tracking', 0),
                  _buildTabButton('Route Clearance', 1),
                  _buildTabButton('Activity Log', 2),
                ],
              ),
            ),
            
            // Content Area
            Expanded(
              child: _selectedTabIndex == 0 
                  ? _buildActiveEmergenciesTab()
                  : _selectedTabIndex == 1
                      ? _buildRouteClearanceTab()
                      : _buildActivityLogTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFFFF5252) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFFFF5252) : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveEmergenciesTab() {
    return Column(
      children: [
        // Section Header
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Emergencies',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252),
                  borderRadius: BorderRadius.circular(12),
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
                    const SizedBox(width: 4),
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
        ),
        
        // Emergency List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _activeEmergencies.length,
            itemBuilder: (context, index) {
              return _buildEmergencyCard(_activeEmergencies[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRouteClearanceTab() {
    return Column(
      children: [
        // Section Header
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: const Text(
            'Route Clearance Requests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        
        // Clearance Requests List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _activeEmergencies.where((e) => e.clearanceStatus == 'Clearance Requested').length,
            itemBuilder: (context, index) {
              final clearanceRequests = _activeEmergencies.where((e) => e.clearanceStatus == 'Clearance Requested').toList();
              return _buildClearanceRequestCard(clearanceRequests[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityLogTab() {
    final activityLogs = [
      ActivityLog(
        time: '14:32',
        action: 'Route Cleared',
        ambulanceId: 'UP-16-AB-9012',
        details: 'Cleared traffic on Sector 62 route to Apollo Hospital',
        status: 'completed',
      ),
      ActivityLog(
        time: '14:28',
        action: 'Emergency Alert',
        ambulanceId: 'UP-16-AB-1234',
        details: 'Critical patient - Cardiac Arrest near DND Flyway',
        status: 'active',
      ),
      ActivityLog(
        time: '14:15',
        action: 'Route Cleared',
        ambulanceId: 'UP-16-AB-5678',
        details: 'Traffic diverted from Atta Market to Fortis Hospital',
        status: 'completed',
      ),
      ActivityLog(
        time: '14:05',
        action: 'Clearance Request',
        ambulanceId: 'UP-16-AB-1234',
        details: 'Requested clearance for DND Flyway route',
        status: 'pending',
      ),
    ];

    return Column(
      children: [
        // Section Header
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: const Text(
            'Activity Log',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        
        // Activity Log List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activityLogs.length,
            itemBuilder: (context, index) {
              return _buildActivityLogCard(activityLogs[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyCard(ActiveEmergency emergency) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_hospital,
                      color: Color(0xFFFF5252),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        emergency.ambulanceId,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        emergency.patientName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(emergency.priority),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      emergency.priority,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(emergency.status),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      emergency.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Emergency Details
          Text(
            'Emergency: ${emergency.emergencyType}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF5252),
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            emergency.patientAge,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Location Info
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.grey, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  emergency.location,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              Text(
                'ETA ${emergency.eta}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF5252),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          Text(
            emergency.sector,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Status and Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                emergency.clearanceStatus,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: emergency.clearanceStatus == 'Route Cleared' 
                      ? const Color(0xFF4CAF50) 
                      : const Color(0xFFFF9800),
                ),
              ),
              Row(
                children: [
                  Text(
                    'Updated ${emergency.timeUpdated}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      // Handle call
                    },
                    child: const Icon(
                      Icons.phone,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      // Handle view details
                    },
                    child: const Icon(
                      Icons.visibility,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical':
        return const Color(0xFFFF1744);
      case 'high':
        return const Color(0xFFFF5722);
      case 'medium':
        return const Color(0xFFFF9800);
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'enroute':
        return const Color(0xFF2196F3);
      case 'pickup':
        return const Color(0xFFFF9800);
      case 'dispatched':
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey;
    }
  }

  Widget _buildClearanceRequestCard(ActiveEmergency emergency) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF9800), width: 2),
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
                emergency.ambulanceId,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'CLEARANCE NEEDED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Route: ${emergency.sector}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            'ETA: ${emergency.eta}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF5252),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _clearRoute(emergency);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Clear Route',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Get.toNamed('/live-tracking');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF5252)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Track',
                    style: TextStyle(color: Color(0xFFFF5252)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLogCard(ActivityLog log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getActivityStatusColor(log.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getActivityIcon(log.action),
              color: _getActivityStatusColor(log.status),
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      log.action,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      log.time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  log.ambulanceId,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFF5252),
                  ),
                ),
                
                const SizedBox(height: 2),
                
                Text(
                  log.details,
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
    );
  }

  Color _getActivityStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'active':
        return const Color(0xFFFF5252);
      case 'pending':
        return const Color(0xFFFF9800);
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String action) {
    switch (action.toLowerCase()) {
      case 'route cleared':
        return Icons.check_circle;
      case 'emergency alert':
        return Icons.warning;
      case 'clearance request':
        return Icons.traffic;
      default:
        return Icons.info;
    }
  }

  void _clearRoute(ActiveEmergency emergency) {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Route'),
        content: Text('Clear traffic route for ${emergency.ambulanceId}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Route Cleared',
                'Traffic route cleared for ${emergency.ambulanceId}',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Clear Route', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class ActivityLog {
  final String time;
  final String action;
  final String ambulanceId;
  final String details;
  final String status;

  ActivityLog({
    required this.time,
    required this.action,
    required this.ambulanceId,
    required this.details,
    required this.status,
  });
}

class ActiveEmergency {
  final String ambulanceId;
  final String patientName;
  final String priority;
  final String status;
  final String emergencyType;
  final String patientAge;
  final String location;
  final String sector;
  final String eta;
  final String timeUpdated;
  final String clearanceStatus;

  ActiveEmergency({
    required this.ambulanceId,
    required this.patientName,
    required this.priority,
    required this.status,
    required this.emergencyType,
    required this.patientAge,
    required this.location,
    required this.sector,
    required this.eta,
    required this.timeUpdated,
    required this.clearanceStatus,
  });
}
