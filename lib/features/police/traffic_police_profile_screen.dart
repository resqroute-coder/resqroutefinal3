import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/professional_service.dart';

class TrafficPoliceProfileScreen extends StatefulWidget {
  const TrafficPoliceProfileScreen({Key? key}) : super(key: key);

  @override
  State<TrafficPoliceProfileScreen> createState() => _TrafficPoliceProfileScreenState();
}

class _TrafficPoliceProfileScreenState extends State<TrafficPoliceProfileScreen> {
  final ProfessionalService _professionalService = Get.put(ProfessionalService());
  bool _isEditing = false;
  
  // Additional traffic police-specific fields
  String _badgeNumber = '';
  String _rank = '';
  String _stationName = '';
  String _sector = '';
  String _shift = '';
  String _vehicleNumber = '';
  String _jurisdiction = '';
  
  @override
  void initState() {
    super.initState();
    _loadAdditionalPoliceData();
  }
  
  void _loadAdditionalPoliceData() {
    // Load additional traffic police data from additionalData field
    final professional = _professionalService.currentProfessional;
    if (professional?.additionalData != null) {
      final additionalData = professional!.additionalData!;
      setState(() {
        _badgeNumber = additionalData['badgeNumber'] ?? 'OFF001';
        _rank = additionalData['rank'] ?? 'Senior Officer';
        _stationName = additionalData['stationName'] ?? 'Sector 18 Traffic Police Station';
        _sector = additionalData['sector'] ?? 'Sector 18-22';
        _shift = additionalData['shift'] ?? 'Day Shift (8AM-8PM)';
        _vehicleNumber = additionalData['vehicleNumber'] ?? 'TPC-001';
        _jurisdiction = additionalData['jurisdiction'] ?? 'Highway & City Roads';
      });
    } else {
      // Set default values if no additional data
      setState(() {
        _badgeNumber = 'OFF001';
        _rank = 'Senior Officer';
        _stationName = 'Sector 18 Traffic Police Station';
        _sector = 'Sector 18-22';
        _shift = 'Day Shift (8AM-8PM)';
        _vehicleNumber = 'TPC-001';
        _jurisdiction = 'Highway & City Roads';
      });
    }
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
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.black),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // Profile Picture
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(
                          Icons.local_police,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5252),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.verified,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Officer Name
                  Obx(() => Text(
                    _professionalService.professionalName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  )),
                  
                  const SizedBox(height: 8),
                  
                  // Officer Role
                  const Text(
                    'Traffic Police Officer',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Badge Number
                  Text(
                    'Badge: $_badgeNumber',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Performance Stats
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
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
                  const Text(
                    'Performance Stats',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('47', 'Routes Cleared', const Color(0xFF4CAF50)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('12', 'Emergencies Handled', const Color(0xFFFF5252)),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('2.3 min', 'Avg Response Time', const Color(0xFF2196F3)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('98%', 'Success Rate', const Color(0xFFFF9800)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Profile Information
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
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
                children: [
                  Obx(() => _buildProfileField(
                    'Full Name',
                    _professionalService.professionalName,
                    Icons.person,
                  )),
                  Obx(() => _buildProfileField(
                    'Employee ID',
                    _professionalService.employeeId,
                    Icons.badge,
                  )),
                  Obx(() => _buildProfileField(
                    'Email',
                    _professionalService.professionalEmail,
                    Icons.email,
                  )),
                  Obx(() => _buildProfileField(
                    'Phone',
                    _professionalService.professionalPhone,
                    Icons.phone,
                  )),
                  _buildProfileField(
                    'Badge Number',
                    _badgeNumber,
                    Icons.security,
                    onTap: _isEditing ? () => _editField('Badge Number', _badgeNumber, (value) => setState(() => _badgeNumber = value)) : null,
                  ),
                  _buildProfileField(
                    'Rank',
                    _rank,
                    Icons.military_tech,
                    onTap: _isEditing ? () => _editField('Rank', _rank, (value) => setState(() => _rank = value)) : null,
                  ),
                  _buildProfileField(
                    'Station',
                    _stationName,
                    Icons.location_city,
                    onTap: _isEditing ? () => _editField('Station', _stationName, (value) => setState(() => _stationName = value)) : null,
                  ),
                  _buildProfileField(
                    'Sector',
                    _sector,
                    Icons.map,
                    onTap: _isEditing ? () => _editField('Sector', _sector, (value) => setState(() => _sector = value)) : null,
                  ),
                  _buildProfileField(
                    'Shift',
                    _shift,
                    Icons.schedule,
                    onTap: _isEditing ? () => _editField('Shift', _shift, (value) => setState(() => _shift = value)) : null,
                  ),
                  _buildProfileField(
                    'Vehicle Number',
                    _vehicleNumber,
                    Icons.local_shipping,
                    onTap: _isEditing ? () => _editField('Vehicle Number', _vehicleNumber, (value) => setState(() => _vehicleNumber = value)) : null,
                  ),
                  _buildProfileField(
                    'Jurisdiction',
                    _jurisdiction,
                    Icons.gavel,
                    onTap: _isEditing ? () => _editField('Jurisdiction', _jurisdiction, (value) => setState(() => _jurisdiction = value)) : null,
                    isLast: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Settings Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
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
                children: [
                  _buildSettingsOption(
                    'Notification Settings',
                    Icons.notifications,
                    onTap: () {
                      _showNotificationSettings();
                    },
                  ),
                  _buildSettingsOption(
                    'Analytics Dashboard',
                    Icons.analytics,
                    onTap: () {
                      Get.toNamed('/traffic-police-analytics');
                    },
                  ),
                  _buildSettingsOption(
                    'Help & Support',
                    Icons.help_outline,
                    onTap: () {
                      _showHelpSupport();
                    },
                    isLast: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Sign Out Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  _showSignOutDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5252),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(
    String label,
    String value,
    IconData icon, {
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: isLast ? null : const Border(
            bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                _isEditing ? Icons.edit : Icons.chevron_right,
                color: _isEditing ? const Color(0xFF4CAF50) : Colors.grey,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOption(
    String title,
    IconData icon, {
    bool isLast = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: isLast ? null : const Border(
            bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.black87,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings() {
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
            const Text(
              'Notification Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildSwitchTile('Emergency Alerts', true),
            _buildSwitchTile('Route Clearance Requests', true),
            _buildSwitchTile('System Notifications', false),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showHelpSupport() {
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
            const Text(
              'Help & Support',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Emergency Helpline'),
              subtitle: const Text('24/7 Traffic Control Center'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Control Room Chat'),
              subtitle: const Text('Chat with control room'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Officer Manual'),
              subtitle: const Text('Traffic police procedures'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: (bool newValue) {
        // Handle switch change
      },
      activeColor: const Color(0xFFFF5252),
    );
  }

  void _editField(String fieldName, String currentValue, Function(String) onSave) {
    final TextEditingController controller = TextEditingController(text: currentValue);
    
    Get.dialog(
      AlertDialog(
        title: Text('Edit $fieldName'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: fieldName,
            border: const OutlineInputBorder(),
          ),
          maxLines: fieldName.contains('Address') || fieldName.contains('Jurisdiction') ? 3 : 1,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onSave(controller.text.trim());
                Get.back();
                Get.snackbar(
                  'Success',
                  '$fieldName updated successfully',
                  backgroundColor: const Color(0xFF4CAF50),
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _saveProfile() async {
    try {
      // Save additional traffic police data to Firestore
      await _professionalService.updateAdditionalData({
        'badgeNumber': _badgeNumber,
        'rank': _rank,
        'stationName': _stationName,
        'sector': _sector,
        'shift': _shift,
        'vehicleNumber': _vehicleNumber,
        'jurisdiction': _jurisdiction,
      });
      
      setState(() {
        _isEditing = false;
      });
      
      Get.snackbar(
        'Profile Saved',
        'Traffic police profile has been updated successfully',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save profile: $e',
        backgroundColor: const Color(0xFFFF5252),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _showSignOutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Navigate to professional login screen
              Get.offAllNamed('/professional-login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
            ),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
