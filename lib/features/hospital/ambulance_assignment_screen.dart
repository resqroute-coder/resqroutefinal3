import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AmbulanceAssignmentScreen extends StatefulWidget {
  const AmbulanceAssignmentScreen({Key? key}) : super(key: key);

  @override
  State<AmbulanceAssignmentScreen> createState() => _AmbulanceAssignmentScreenState();
}

class _AmbulanceAssignmentScreenState extends State<AmbulanceAssignmentScreen> {
  final List<AvailableAmbulance> _availableAmbulances = [
    AvailableAmbulance(
      id: 'UP-16-AB-1234',
      driverName: 'Rajesh Kumar',
      type: 'Advanced Life Support',
      location: 'Sector 18, Noida',
      distance: '2.3 km',
      eta: '8 mins',
      rating: 4.8,
      status: 'Available',
      equipment: ['Ventilator', 'Defibrillator', 'Oxygen'],
    ),
    AvailableAmbulance(
      id: 'UP-16-AB-5678',
      driverName: 'Mohammed Ali',
      type: 'Basic Life Support',
      location: 'Sector 15, Noida',
      distance: '3.7 km',
      eta: '12 mins',
      rating: 4.6,
      status: 'Available',
      equipment: ['Oxygen', 'First Aid Kit', 'Stretcher'],
    ),
    AvailableAmbulance(
      id: 'UP-16-AB-9012',
      driverName: 'Sunita Devi',
      type: 'Critical Care Transport',
      location: 'Sector 22, Noida',
      distance: '5.1 km',
      eta: '15 mins',
      rating: 4.9,
      status: 'Available',
      equipment: ['ICU Setup', 'Ventilator', 'Cardiac Monitor', 'Defibrillator'],
    ),
  ];

  final List<PendingAssignment> _pendingAssignments = [
    PendingAssignment(
      patientName: 'Ramesh Gupta',
      condition: 'Cardiac Emergency',
      priority: 'Critical',
      location: 'Sector 18, Noida',
      requestTime: '5 mins ago',
      requiredType: 'Advanced Life Support',
    ),
    PendingAssignment(
      patientName: 'Priya Sharma',
      condition: 'Accident Victim',
      priority: 'High',
      location: 'DND Flyway',
      requestTime: '12 mins ago',
      requiredType: 'Basic Life Support',
    ),
  ];

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
        title: const Text(
          'Ambulance Assignment',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // Refresh ambulance list
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Pending Assignments
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Pending Assignments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _pendingAssignments.length,
              itemBuilder: (context, index) {
                return _buildPendingAssignmentCard(_pendingAssignments[index]);
              },
            ),
            
            const SizedBox(height: 24),
            
            // Available Ambulances
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available Ambulances',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '${_availableAmbulances.length} Available',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _availableAmbulances.length,
              itemBuilder: (context, index) {
                return _buildAmbulanceCard(_availableAmbulances[index]);
              },
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingAssignmentCard(PendingAssignment assignment) {
    Color priorityColor = assignment.priority == 'Critical'
        ? const Color(0xFFFF5252)
        : assignment.priority == 'High'
            ? const Color(0xFFFF9800)
            : const Color(0xFF4CAF50);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: priorityColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
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
                assignment.patientName,
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
                  assignment.priority,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            assignment.condition,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  assignment.location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
              Text(
                assignment.requestTime,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: Text(
                  'Required: ${assignment.requiredType}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _showAssignmentDialog(assignment);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: priorityColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  'Assign',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmbulanceCard(AvailableAmbulance ambulance) {
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
                ambulance.id,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  ambulance.status,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            ambulance.type,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2196F3),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                ambulance.driverName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                ambulance.rating.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ambulance.location,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoChip(Icons.straighten, ambulance.distance),
              _buildInfoChip(Icons.access_time, 'ETA ${ambulance.eta}'),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Equipment List
          const Text(
            'Equipment:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: ambulance.equipment.map((equipment) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  equipment,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black87,
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // View details
                  },
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2196F3),
                    side: const BorderSide(color: Color(0xFF2196F3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showQuickAssignDialog(ambulance);
                  },
                  icon: const Icon(Icons.assignment, size: 16),
                  label: const Text('Assign'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5252),
                    foregroundColor: Colors.white,
                    elevation: 0,
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

  void _showAssignmentDialog(PendingAssignment assignment) {
    Get.dialog(
      AlertDialog(
        title: Text('Assign Ambulance to ${assignment.patientName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Condition: ${assignment.condition}'),
            Text('Priority: ${assignment.priority}'),
            Text('Location: ${assignment.location}'),
            Text('Required Type: ${assignment.requiredType}'),
            const SizedBox(height: 16),
            const Text('Select an ambulance from the available list below.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Show success message
              Get.snackbar(
                'Assignment Successful',
                'Ambulance has been assigned to ${assignment.patientName}',
                backgroundColor: const Color(0xFF4CAF50),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
            ),
            child: const Text('Confirm Assignment', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showQuickAssignDialog(AvailableAmbulance ambulance) {
    Get.dialog(
      AlertDialog(
        title: Text('Assign ${ambulance.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Driver: ${ambulance.driverName}'),
            Text('Type: ${ambulance.type}'),
            Text('Location: ${ambulance.location}'),
            Text('ETA: ${ambulance.eta}'),
            const SizedBox(height: 16),
            const Text('Select a pending assignment:'),
            const SizedBox(height: 8),
            ..._pendingAssignments.map((assignment) {
              return ListTile(
                title: Text(assignment.patientName),
                subtitle: Text(assignment.condition),
                trailing: Text(assignment.priority),
                onTap: () {
                  Get.back();
                  Get.snackbar(
                    'Assignment Successful',
                    '${ambulance.id} assigned to ${assignment.patientName}',
                    backgroundColor: const Color(0xFF4CAF50),
                    colorText: Colors.white,
                  );
                },
              );
            }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class AvailableAmbulance {
  final String id;
  final String driverName;
  final String type;
  final String location;
  final String distance;
  final String eta;
  final double rating;
  final String status;
  final List<String> equipment;

  AvailableAmbulance({
    required this.id,
    required this.driverName,
    required this.type,
    required this.location,
    required this.distance,
    required this.eta,
    required this.rating,
    required this.status,
    required this.equipment,
  });
}

class PendingAssignment {
  final String patientName;
  final String condition;
  final String priority;
  final String location;
  final String requestTime;
  final String requiredType;

  PendingAssignment({
    required this.patientName,
    required this.condition,
    required this.priority,
    required this.location,
    required this.requestTime,
    required this.requiredType,
  });
}
