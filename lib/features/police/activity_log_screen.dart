import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({Key? key}) : super(key: key);

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  final List<ActivityLogEntry> _activityLog = [
    ActivityLogEntry(
      ambulanceId: 'UP-16-AB-1234',
      action: 'Route Cleared',
      location: 'DND Flyway → Kalindi Kunj',
      timestamp: '2 mins ago',
      officer: 'Officer Singh',
      duration: '45 seconds',
      status: 'Completed',
    ),
    ActivityLogEntry(
      ambulanceId: 'UP-16-AB-5678',
      action: 'Traffic Alert Sent',
      location: 'Sector 18 Metro Area',
      timestamp: '5 mins ago',
      officer: 'Officer Sharma',
      duration: '30 seconds',
      status: 'Completed',
    ),
    ActivityLogEntry(
      ambulanceId: 'UP-16-AB-9012',
      action: 'Emergency Response',
      location: 'Sector 62 → Apollo Hospital',
      timestamp: '15 mins ago',
      officer: 'Officer Kumar',
      duration: '2 minutes',
      status: 'Completed',
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
          'Activity Log',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {
              // Handle filter
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activityLog.length,
        itemBuilder: (context, index) {
          return _buildActivityCard(_activityLog[index]);
        },
      ),
    );
  }

  Widget _buildActivityCard(ActivityLogEntry entry) {
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
                entry.ambulanceId,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  entry.status,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            entry.action,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF5252),
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            entry.location,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'By: ${entry.officer}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Duration: ${entry.duration}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Text(
                entry.timestamp,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActivityLogEntry {
  final String ambulanceId;
  final String action;
  final String location;
  final String timestamp;
  final String officer;
  final String duration;
  final String status;

  ActivityLogEntry({
    required this.ambulanceId,
    required this.action,
    required this.location,
    required this.timestamp,
    required this.officer,
    required this.duration,
    required this.status,
  });
}
