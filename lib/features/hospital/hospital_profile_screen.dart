import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/professional_service.dart';

class HospitalProfileScreen extends StatefulWidget {
  const HospitalProfileScreen({Key? key}) : super(key: key);

  @override
  State<HospitalProfileScreen> createState() => _HospitalProfileScreenState();
}

class _HospitalProfileScreenState extends State<HospitalProfileScreen> {
  final ProfessionalService _professionalService = Get.put(ProfessionalService());
  bool _isEditing = false;
  
  // Additional hospital-specific fields
  String _hospitalName = '';
  String _hospitalType = '';
  String _licenseNumber = '';
  String _totalBeds = '';
  String _availableBeds = '';
  String _departments = '';
  String _emergencyContact = '';
  
  @override
  void initState() {
    super.initState();
    _loadAdditionalHospitalData();
  }
  
  void _loadAdditionalHospitalData() {
    // Load additional hospital data from additionalData field
    final professional = _professionalService.currentProfessional;
    if (professional?.additionalData != null) {
      final additionalData = professional!.additionalData!;
      setState(() {
        _hospitalName = additionalData['hospitalName'] ?? 'Max Super Specialty Hospital';
        _hospitalType = additionalData['hospitalType'] ?? 'Multi-Specialty Hospital';
        _licenseNumber = additionalData['licenseNumber'] ?? 'HSP-2024-001';
        _totalBeds = additionalData['totalBeds'] ?? '150';
        _availableBeds = additionalData['availableBeds'] ?? '23';
        _departments = additionalData['departments'] ?? '12';
        _emergencyContact = additionalData['emergencyContact'] ?? '+91 120 456 7891';
      });
    } else {
      // Set default values if no additional data
      setState(() {
        _hospitalName = 'Max Super Specialty Hospital';
        _hospitalType = 'Multi-Specialty Hospital';
        _licenseNumber = 'HSP-2024-001';
        _totalBeds = '150';
        _availableBeds = '23';
        _departments = '12';
        _emergencyContact = '+91 120 456 7891';
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
        title: const Text(
          'Hospital Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.white),
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
              icon: const Icon(Icons.close, color: Colors.white),
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
            // Hospital Header
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // Hospital Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.local_hospital,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Hospital Name
                  Text(
                    _hospitalName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Hospital Type
                  Text(
                    _hospitalType,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // License Number
                  Text(
                    'License: $_licenseNumber',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Hospital Statistics
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
                    'Hospital Statistics',
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
                        child: _buildStatCard('150', 'Total Beds', const Color(0xFF4CAF50)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('12', 'Departments', const Color(0xFF2196F3)),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('247', 'Monthly Cases', const Color(0xFFFF9800)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('96.8%', 'Success Rate', const Color(0xFF9C27B0)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Hospital Information
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
                  Obx(() => _buildInfoField(
                    'Staff Name',
                    _professionalService.professionalName,
                    Icons.person,
                  )),
                  Obx(() => _buildInfoField(
                    'Employee ID',
                    _professionalService.employeeId,
                    Icons.badge,
                  )),
                  Obx(() => _buildInfoField(
                    'Email',
                    _professionalService.professionalEmail,
                    Icons.email,
                  )),
                  Obx(() => _buildInfoField(
                    'Phone',
                    _professionalService.professionalPhone,
                    Icons.phone,
                  )),
                  _buildInfoField(
                    'Hospital Name',
                    _hospitalName,
                    Icons.local_hospital,
                    onTap: _isEditing ? () => _editField('Hospital Name', _hospitalName, (value) => setState(() => _hospitalName = value)) : null,
                  ),
                  _buildInfoField(
                    'Hospital Type',
                    _hospitalType,
                    Icons.business,
                    onTap: _isEditing ? () => _editField('Hospital Type', _hospitalType, (value) => setState(() => _hospitalType = value)) : null,
                  ),
                  _buildInfoField(
                    'License Number',
                    _licenseNumber,
                    Icons.verified,
                    onTap: _isEditing ? () => _editField('License Number', _licenseNumber, (value) => setState(() => _licenseNumber = value)) : null,
                  ),
                  _buildInfoField(
                    'Total Beds',
                    _totalBeds,
                    Icons.bed,
                    onTap: _isEditing ? () => _editField('Total Beds', _totalBeds, (value) => setState(() => _totalBeds = value)) : null,
                  ),
                  _buildInfoField(
                    'Available Beds',
                    _availableBeds,
                    Icons.hotel,
                    onTap: _isEditing ? () => _editField('Available Beds', _availableBeds, (value) => setState(() => _availableBeds = value)) : null,
                  ),
                  _buildInfoField(
                    'Departments',
                    _departments,
                    Icons.domain,
                    onTap: _isEditing ? () => _editField('Departments', _departments, (value) => setState(() => _departments = value)) : null,
                  ),
                  _buildInfoField(
                    'Emergency Contact',
                    _emergencyContact,
                    Icons.emergency,
                    onTap: _isEditing ? () => _editField('Emergency Contact', _emergencyContact, (value) => setState(() => _emergencyContact = value)) : null,
                    isLast: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Departments
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
                    'Departments',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Emergency',
                      'Cardiology',
                      'Neurology',
                      'Orthopedics',
                      'Pediatrics',
                      'ICU',
                      'Surgery',
                      'Radiology',
                      'Pathology',
                      'Pharmacy',
                      'Trauma',
                      'Oncology',
                    ].map((department) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          department,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
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
                    'Staff Management',
                    Icons.people,
                    onTap: () {
                      _showStaffManagement();
                    },
                  ),
                  _buildSettingsOption(
                    'Bed Management',
                    Icons.bed,
                    onTap: () {
                      _showBedManagement();
                    },
                  ),
                  _buildSettingsOption(
                    'Equipment Management',
                    Icons.medical_services,
                    onTap: () {
                      _showEquipmentManagement();
                    },
                  ),
                  _buildSettingsOption(
                    'Emergency Settings',
                    Icons.settings,
                    onTap: () {
                      _showEmergencySettings();
                    },
                  ),
                  _buildSettingsOption(
                    'Notification Settings',
                    Icons.notifications,
                    onTap: () {
                      _showNotificationSettings();
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

  Widget _buildInfoField(
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
              color: const Color(0xFFFF5252),
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
                color: _isEditing ? const Color(0xFFFF5252) : Colors.grey,
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

  void _showStaffManagement() {
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
              'Staff Management',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Add Staff Member'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('View All Staff'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Staff Schedules'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showBedManagement() {
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
              'Bed Management',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.bed),
              title: const Text('Available Beds'),
              subtitle: const Text('23 beds available'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.local_hospital),
              title: const Text('ICU Beds'),
              subtitle: const Text('5 beds available'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Bed Assignments'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showEquipmentManagement() {
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
              'Equipment Management',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.medical_services),
              title: const Text('Medical Equipment'),
              subtitle: const Text('View all equipment status'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text('Maintenance Schedule'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Equipment Inventory'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showEmergencySettings() {
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
              'Emergency Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildSwitchTile('Auto-Accept Critical Cases', true),
            _buildSwitchTile('Emergency Alerts', true),
            _buildSwitchTile('Ambulance Auto-Assignment', false),
            const SizedBox(height: 20),
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
            _buildSwitchTile('Patient Updates', true),
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
              subtitle: const Text('24/7 Hospital Support'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Live Chat'),
              subtitle: const Text('Chat with support team'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('User Manual'),
              subtitle: const Text('Hospital system guide'),
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
          maxLines: fieldName.contains('Address') ? 3 : 1,
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
              backgroundColor: const Color(0xFFFF5252),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _saveProfile() async {
    try {
      // Save additional hospital data to Firestore
      await _professionalService.updateAdditionalData({
        'hospitalName': _hospitalName,
        'hospitalType': _hospitalType,
        'licenseNumber': _licenseNumber,
        'totalBeds': _totalBeds,
        'availableBeds': _availableBeds,
        'departments': _departments,
        'emergencyContact': _emergencyContact,
      });
      
      setState(() {
        _isEditing = false;
      });
      
      Get.snackbar(
        'Profile Saved',
        'Hospital profile has been updated successfully',
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
