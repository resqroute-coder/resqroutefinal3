import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  String _selectedFilter = 'All Requests';
  
  final List<String> _filterOptions = [
    'All Requests',
    'Completed',
    'Cancelled',
    'In Progress',
  ];

  final List<ServiceRequest> _serviceRequests = [
    ServiceRequest(
      requestId: 'REQ001',
      patientName: 'Raj Patel',
      emergencyType: 'Heart Attack',
      fromLocation: 'Bandra West, Mumbai',
      toLocation: 'Apollo Hospital',
      duration: '45 min',
      driverName: 'Amit Kumar',
      ambulanceId: 'MH-12-AB-1234',
      totalCost: 850,
      rating: 5,
      status: 'Completed',
      timestamp: 'Today, 2:30 PM',
    ),
    ServiceRequest(
      requestId: 'REQ002',
      patientName: 'Priya Sharma',
      emergencyType: 'Road Accident',
      fromLocation: 'Andheri East, Mumbai',
      toLocation: 'Fortis Hospital',
      duration: '32 min',
      driverName: 'Rajesh Kumar',
      ambulanceId: 'MH-12-CD-5678',
      totalCost: 650,
      rating: 4,
      status: 'Completed',
      timestamp: 'Yesterday, 8:15 AM',
    ),
    ServiceRequest(
      requestId: 'REQ003',
      patientName: 'Amit Singh',
      emergencyType: 'Breathing Issues',
      fromLocation: 'Powai, Mumbai',
      toLocation: 'Kokilaben Hospital',
      duration: '28 min',
      driverName: 'Suresh Patel',
      ambulanceId: 'MH-12-EF-9012',
      totalCost: 720,
      rating: 5,
      status: 'Completed',
      timestamp: '3 days ago, 11:45 PM',
    ),
  ];

  List<ServiceRequest> get _filteredRequests {
    if (_selectedFilter == 'All Requests') {
      return _serviceRequests;
    }
    return _serviceRequests.where((request) => request.status == _selectedFilter).toList();
  }

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
          'Service History',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Dropdown
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: _selectedFilter,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFilter = newValue!;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey, width: 0.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: _filterOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          
          // Service Requests List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredRequests.length,
              itemBuilder: (context, index) {
                return _buildServiceRequestCard(_filteredRequests[index]);
              },
            ),
          ),
          
          // Bottom Statistics
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('3', 'Total Requests'),
                _buildStatItem('3', 'Completed'),
                _buildStatItem('4.7', 'Avg Rating'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRequestCard(ServiceRequest request) {
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
          // Header with status and timestamp
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(request.status),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  request.status,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    request.timestamp,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    request.requestId,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Patient name and rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                request.patientName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    size: 16,
                    color: index < request.rating ? Colors.amber : Colors.grey[300],
                  );
                }),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Emergency type
          Text(
            request.emergencyType,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Location details
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFFFF5252), size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'From: ${request.fromLocation}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          Row(
            children: [
              const Icon(Icons.local_hospital, color: Color(0xFFFF5252), size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'To: ${request.toLocation}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          Row(
            children: [
              const Icon(Icons.access_time, color: Color(0xFFFF5252), size: 16),
              const SizedBox(width: 4),
              Text(
                'Duration: ${request.duration}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Driver and ambulance info
          Text(
            '${request.driverName}  ${request.ambulanceId}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Total cost
          Text(
            '₹${request.totalCost} Total Cost',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Handle rate & review
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Rate & Review',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Handle view receipt
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'View Receipt',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
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

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF5252),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFFE8F5E8);
      case 'in progress':
        return const Color(0xFFE3F2FD);
      case 'cancelled':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFF5F5F5);
    }
  }
}

class ServiceRequest {
  final String requestId;
  final String patientName;
  final String emergencyType;
  final String fromLocation;
  final String toLocation;
  final String duration;
  final String driverName;
  final String ambulanceId;
  final int totalCost;
  final int rating;
  final String status;
  final String timestamp;

  ServiceRequest({
    required this.requestId,
    required this.patientName,
    required this.emergencyType,
    required this.fromLocation,
    required this.toLocation,
    required this.duration,
    required this.driverName,
    required this.ambulanceId,
    required this.totalCost,
    required this.rating,
    required this.status,
    required this.timestamp,
  });
}
