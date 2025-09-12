import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/emergency_request_service.dart';
import '../../core/services/professional_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/models/emergency_request_model.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({Key? key}) : super(key: key);

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  bool _isOnline = true;
  int _currentIndex = 0;
  final EmergencyRequestService _emergencyService = Get.find<EmergencyRequestService>();
  final ProfessionalService _professionalService = Get.put(ProfessionalService());
  final NotificationService _notificationService = Get.find<NotificationService>();
  
  Map<String, dynamic> _performanceMetrics = {};

  @override
  void initState() {
    super.initState();
    _loadPerformanceMetrics();
  }

  Future<void> _loadPerformanceMetrics() async {
    final metrics = await _professionalService.getDriverPerformance();
    if (mounted) {
      setState(() {
        _performanceMetrics = metrics;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5252),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Center(
                        child: Text(
                          'D',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Driver Portal',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            _professionalService.professionalName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      )),
                    ),
                    IconButton(
                      onPressed: () {
                        _showNotificationsPopup(context);
                      },
                      icon: Stack(
                        children: [
                          const Icon(
                            Icons.notifications_outlined,
                            color: Colors.black54,
                            size: 28,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.bug_report, color: Colors.orange),
                      onPressed: () {
                        Get.toNamed('/debug-emergency');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () {
                        // Handle settings
                      },
                    ),
                  ],
                ),
              ),
              
              // Online Status
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _isOnline ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isOnline ? 'You are Online' : 'You are Offline',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            _isOnline ? 'Ready to receive requests' : 'Not receiving requests',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isOnline,
                      onChanged: (value) {
                        setState(() {
                          _isOnline = value;
                        });
                      },
                      activeColor: const Color(0xFFFF5252),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Active Trip Section - Show current assignment or no active trip
              StreamBuilder<List<EmergencyRequest>>(
                stream: _emergencyService.getDriverActiveTripsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final activeTrip = snapshot.data!.first;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE8E8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Active Trip',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF5252),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF5252),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'ETA: 8 min',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          Text(
                            activeTrip.patientName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.grey, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                activeTrip.pickupLocation,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 4),
                          
                          Row(
                            children: [
                              const Icon(Icons.local_hospital, color: Colors.grey, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  activeTrip.hospitalLocation,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 4),
                          
                          Text(
                            activeTrip.id.substring(0, 8).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.toNamed('/driver-navigation', arguments: activeTrip.id);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF5252),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text(
                                    'Navigate',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton(
                                onPressed: () {
                                  // Handle call patient
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.grey),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                ),
                                child: const Icon(
                                  Icons.phone,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton(
                                onPressed: () {
                                  Get.toNamed('/emergency-request-details', arguments: activeTrip.id);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.grey),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                child: const Text(
                                  'Details',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  } else {
                    // No active trip
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            size: 48,
                            color: Colors.grey.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No Active Trip',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'You\'ll see your current assignment here',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              
              const SizedBox(height: 24),
              
              // Today's Performance
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
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
                    const Text(
                      "Today's Performance",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildPerformanceCard(
                            _performanceMetrics['tripsCompleted']?.toString() ?? '0',
                            'Trips Completed',
                            const Color(0xFFFF5252),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildPerformanceCard(
                            _performanceMetrics['kmDriven']?.toString() ?? '0',
                            'KM Driven',
                            const Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildPerformanceCard(
                            '₹${_performanceMetrics['earnings']?.toString() ?? '0'}',
                            'Earnings',
                            const Color(0xFF2196F3),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildPerformanceCard(
                            _performanceMetrics['rating']?.toStringAsFixed(1) ?? '4.5',
                            'Rating',
                            const Color(0xFFFF9800),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // New Requests
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'New Requests',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        StreamBuilder<List<EmergencyRequest>>(
                          stream: _emergencyService.getPendingRequestsStream(),
                          builder: (context, snapshot) {
                            final pendingCount = snapshot.data?.length ?? 0;
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE8E8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$pendingCount pending',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFFF5252),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    StreamBuilder<List<EmergencyRequest>>(
                      stream: _emergencyService.getPendingRequestsStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFF5252),
                            ),
                          );
                        }
                        
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 48,
                                  color: Colors.grey.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No pending requests',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'You\'ll see new emergency requests here',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        
                        return Column(
                          children: snapshot.data!.map((request) => _buildRequestCard(request)).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _handleBottomNavigation(index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFF5252),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard(String value, String label, Color color) {
    return Column(
      children: [
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
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRequestCard(EmergencyRequest request) {
    // Calculate time ago
    final now = DateTime.now();
    final difference = now.difference(request.createdAt);
    String timeAgo;
    if (difference.inMinutes < 1) {
      timeAgo = 'Just now';
    } else if (difference.inMinutes < 60) {
      timeAgo = '${difference.inMinutes} min ago';
    } else {
      timeAgo = '${difference.inHours} hr ago';
    }
    
    // Calculate distance (simulated)
    final distance = '${(2.0 + (request.id.hashCode % 10) * 0.5).toStringAsFixed(1)} km away';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  request.priority.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    timeAgo,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    request.id.substring(0, 8).toUpperCase(),
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
          
          const SizedBox(height: 12),
          
          Text(
            request.patientName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            request.emergencyTypeText,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFFF5252),
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.grey, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${request.pickupLocation} • $distance',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          Row(
            children: [
              const Icon(Icons.local_hospital, color: Colors.grey, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  request.hospitalLocation,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _acceptRequest(request);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Accept',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _declineRequest(request);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF5252)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Decline',
                    style: TextStyle(
                      color: Color(0xFFFF5252),
                      fontWeight: FontWeight.w600,
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

  void _showNotificationsPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: Obx(() {
                    final notifications = _notificationService.notifications;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return _buildNotificationItem(notification);
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Mark all as read
                      _notificationService.markAllAsRead();
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5252),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Mark All as Read',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSettingsPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSettingsItem(
                  Icons.notifications,
                  'Push Notifications',
                  'Receive emergency alerts',
                  true,
                  (value) {},
                ),
                _buildSettingsItem(
                  Icons.location_on,
                  'Location Services',
                  'Share location for tracking',
                  true,
                  (value) {},
                ),
                _buildSettingsItem(
                  Icons.volume_up,
                  'Sound Alerts',
                  'Audio notifications for requests',
                  false,
                  (value) {},
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _buildSettingsButton(
                  Icons.person,
                  'Edit Profile',
                  () {
                    Get.back();
                    Get.toNamed('/driver-profile');
                  },
                ),
                _buildSettingsButton(
                  Icons.history,
                  'Trip History',
                  () {
                    Get.back();
                    Get.toNamed('/driver-trips');
                  },
                ),
                _buildSettingsButton(
                  Icons.help,
                  'Help & Support',
                  () {
                    Get.back();
                    // Navigate to help screen
                  },
                ),
                _buildSettingsButton(
                  Icons.logout,
                  'Logout',
                  () {
                    Get.back();
                    _showLogoutConfirmation(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    IconData iconData;
    Color iconColor;
    
    switch (notification.type) {
      case NotificationType.emergency:
        iconData = Icons.emergency;
        iconColor = const Color(0xFFFF5252);
        break;
      case NotificationType.update:
        iconData = Icons.check_circle;
        iconColor = const Color(0xFF4CAF50);
        break;
      case NotificationType.info:
        iconData = Icons.info;
        iconColor = const Color(0xFF2196F3);
        break;
      case NotificationType.ambulance:
        iconData = Icons.local_shipping;
        iconColor = const Color(0xFF2196F3);
        break;
      case NotificationType.warning:
        iconData = Icons.warning;
        iconColor = const Color(0xFFFF9800);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.grey.withValues(alpha: 0.05) : const Color(0xFFFFF8F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead ? Colors.grey.withValues(alpha: 0.2) : const Color(0xFFFFE8E8),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(notification.timestamp),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (!notification.isRead)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFFF5252),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5252).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFF5252),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFFF5252),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsButton(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.black54,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout from your driver account?',
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
                Get.offAllNamed('/auth-selection');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5252),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _acceptRequest(EmergencyRequest request) async {
    try {
      // Show loading dialog
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF5252)),
        ),
        barrierDismissible: false,
      );
      
      final success = await _emergencyService.acceptRequest(
        requestId: request.id,
        driverId: _professionalService.currentProfessional?.uid ?? '',
        driverName: _professionalService.professionalName,
        ambulanceId: _professionalService.employeeId,
      );
      
      Get.back(); // Close loading dialog
      
      if (success) {
        Get.snackbar(
          'Request Accepted',
          'You have accepted the emergency request for ${request.patientName}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Navigate to emergency request details
        Get.toNamed('/emergency-request-details', arguments: request.id);
      } else {
        Get.snackbar(
          'Error',
          'Failed to accept request. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'An error occurred while accepting the request.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  void _declineRequest(EmergencyRequest request) async {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Decline Request',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to decline the emergency request for ${request.patientName}?',
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
            onPressed: () async {
              Get.back();
              
              // Show loading dialog
              Get.dialog(
                const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF5252)),
                ),
                barrierDismissible: false,
              );
              
              try {
                // Add declined by driver info to the request
                final success = await _emergencyService.declineRequest(
                  requestId: request.id,
                  driverId: _professionalService.currentProfessional?.uid ?? '',
                  driverName: _professionalService.professionalName,
                );
                
                Get.back(); // Close loading dialog
                
                if (success) {
                  Get.snackbar(
                    'Request Declined',
                    'You have declined the emergency request. It will be reassigned to another driver.',
                    backgroundColor: Colors.orange,
                    colorText: Colors.white,
                  );
                } else {
                  Get.snackbar(
                    'Error',
                    'Failed to decline request. Please try again.',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              } catch (e) {
                Get.back(); // Close loading dialog
                Get.snackbar(
                  'Error',
                  'An error occurred while declining the request.',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Decline',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _handleBottomNavigation(int index) {
    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        Get.toNamed('/driver-trips');
        break;
      case 2:
        Get.toNamed('/driver-navigation');
        break;
      case 3:
        Get.toNamed('/driver-profile');
        break;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

// Remove local EmergencyRequest class - using the one from models
