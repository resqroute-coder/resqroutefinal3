import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/emergency_request_service.dart';
import '../../core/services/user_service.dart';
import '../../core/models/emergency_request_model.dart';

class EmergencyRequestScreen extends StatefulWidget {
  const EmergencyRequestScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyRequestScreen> createState() => _EmergencyRequestScreenState();
}

class _EmergencyRequestScreenState extends State<EmergencyRequestScreen> {
  String? _selectedEmergencyType;
  String? _selectedSeverity;
  String? _selectedGender;
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _patientAgeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _additionalDetailsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  bool _isRequestingAmbulance = false;
  final NotificationService _notificationService = Get.find<NotificationService>();
  final EmergencyRequestService _emergencyService = Get.find<EmergencyRequestService>();
  final UserService _userService = Get.find<UserService>();

  final List<Map<String, dynamic>> _emergencyTypes = [
    {
      'name': 'Cardiac Emergency',
      'icon': Icons.favorite,
      'color': const Color(0xFFFF1744),
      'description': 'Heart attack, chest pain, cardiac arrest',
    },
    {
      'name': 'Accident/Trauma',
      'icon': Icons.local_hospital,
      'color': const Color(0xFFFF5722),
      'description': 'Road accident, fall, injury',
    },
    {
      'name': 'Breathing Issues',
      'icon': Icons.air,
      'color': const Color(0xFF2196F3),
      'description': 'Asthma, difficulty breathing',
    },
    {
      'name': 'Stroke/Neurological',
      'icon': Icons.psychology,
      'color': const Color(0xFF9C27B0),
      'description': 'Stroke, seizure, unconsciousness',
    },
    {
      'name': 'Poisoning',
      'icon': Icons.warning,
      'color': const Color(0xFFFF9800),
      'description': 'Drug overdose, food poisoning',
    },
    {
      'name': 'Other Emergency',
      'icon': Icons.emergency,
      'color': const Color(0xFF607D8B),
      'description': 'Other medical emergency',
    },
  ];

  final List<Map<String, dynamic>> _severityLevels = [
    {
      'name': 'Critical',
      'color': const Color(0xFFFF1744),
      'description': 'Life-threatening, immediate attention needed',
      'icon': Icons.priority_high,
    },
    {
      'name': 'High',
      'color': const Color(0xFFFF5722),
      'description': 'Urgent medical attention required',
      'icon': Icons.warning,
    },
    {
      'name': 'Medium',
      'color': const Color(0xFFFF9800),
      'description': 'Medical attention needed soon',
      'icon': Icons.info,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  void _initializeUserData() {
    // Pre-fill patient information if available
    if (_userService.userName.isNotEmpty) {
      _patientNameController.text = _userService.userName;
    }
    if (_userService.userLocation.isNotEmpty && _userService.userLocation != 'Location not available') {
      _locationController.text = _userService.userLocation;
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _additionalDetailsController.dispose();
    _descriptionController.dispose();
    _patientNameController.dispose();
    _ageController.dispose();
    _patientAgeController.dispose();
    _phoneController.dispose();
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
        title: const Text(
          'Emergency Request',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'Urgent',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency Alert Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF5252).withValues(alpha: 0.1),
                    const Color(0xFFFF1744).withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFF5252).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.emergency,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Request Emergency Ambulance',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Fill in the details below to request immediate medical assistance',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Emergency Type Selection
            _buildSectionCard(
              'Type of Emergency',
              Icons.medical_services,
              [
                const Text(
                  'Select the type of medical emergency:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _emergencyTypes.length,
                  itemBuilder: (context, index) {
                    final type = _emergencyTypes[index];
                    final isSelected = _selectedEmergencyType == type['name'];
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedEmergencyType = type['name'];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? type['color'].withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? type['color']
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              type['icon'],
                              color: type['color'],
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              type['name'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? type['color'] : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Severity Level
            _buildSectionCard(
              'Severity Level',
              Icons.priority_high,
              [
                const Text(
                  'How urgent is this emergency?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ..._severityLevels.map((severity) {
                  final isSelected = _selectedSeverity == severity['name'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSeverity = severity['name'];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? severity['color'].withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                              ? severity['color']
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            severity['icon'],
                            color: severity['color'],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  severity['name'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? severity['color'] : Colors.black87,
                                  ),
                                ),
                                Text(
                                  severity['description'],
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
                  );
                }).toList(),
              ],
            ),

            const SizedBox(height: 24),

            // Patient Information
            _buildSectionCard(
              'Patient Information',
              Icons.person,
              [
                _buildTextFormField(
                  controller: _patientNameController,
                  label: 'Patient Name',
                  hint: 'Enter patient\'s full name',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _patientAgeController,
                        label: 'Age',
                        hint: 'Age',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownField(
                        value: _selectedGender,
                        label: 'Gender',
                        items: ['Male', 'Female', 'Other'],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Location Information
            _buildSectionCard(
              'Location Information',
              Icons.location_on,
              [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _locationController,
                        label: 'Current Location',
                        hint: 'Enter your current location',
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _getCurrentLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5252),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(12),
                      ),
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Additional Details
            _buildSectionCard(
              'Additional Details',
              Icons.description,
              [
                _buildTextFormField(
                  controller: _descriptionController,
                  label: 'Description (Optional)',
                  hint: 'Describe the situation in detail...',
                  maxLines: 4,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Request Ambulance Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isRequestingAmbulance ? null : _requestAmbulance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5252),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isRequestingAmbulance
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Requesting Ambulance...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.emergency,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Request Emergency Ambulance',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Emergency Hotline
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFF5252).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.phone,
                    color: Color(0xFFFF5252),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Emergency Hotline: 108',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Handle call to emergency hotline
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5252),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'Call',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8E8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFFF5252),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _getCurrentLocation() {
    // Simulate getting current location
    setState(() {
      _locationController.text = 'Bandra West, Mumbai, Maharashtra';
    });
    
    Get.snackbar(
      'Location Found',
      'Current location has been detected',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _requestAmbulance() async {
    // Validate required fields
    if (_selectedEmergencyType == null) {
      Get.snackbar(
        'Error',
        'Please select the type of emergency',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_selectedSeverity == null) {
      Get.snackbar(
        'Error',
        'Please select the severity level',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_patientNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter the patient name',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_locationController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter the location',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isRequestingAmbulance = true;
    });

    try {
      // Map emergency type to enum
      EmergencyType emergencyType;
      switch (_selectedEmergencyType) {
        case 'Cardiac Emergency':
          emergencyType = EmergencyType.cardiac;
          break;
        case 'Accident/Trauma':
          emergencyType = EmergencyType.trauma;
          break;
        case 'Breathing Issues':
          emergencyType = EmergencyType.respiratory;
          break;
        case 'Stroke/Neurological':
        case 'Poisoning':
        case 'Other Emergency':
        default:
          emergencyType = EmergencyType.medical;
          break;
      }

      // Create emergency request
      final requestId = await _emergencyService.createEmergencyRequest(
        patientId: _userService.userId,
        patientName: _patientNameController.text.trim(),
        patientPhone: _userService.userPhone.isNotEmpty ? _userService.userPhone : '9876543210',
        emergencyType: emergencyType,
        description: _descriptionController.text.trim(),
        pickupLocation: _locationController.text.trim(),
        hospitalLocation: 'Max Super Specialty Hospital, Bandra West, Mumbai',
        priority: _selectedSeverity!.toLowerCase(),
      );

      if (requestId != null) {
        // Add confirmation notification
        _notificationService.addNotification(NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Emergency Request Created',
          message: 'Request ID: $requestId - Searching for available ambulance',
          type: NotificationType.emergency,
          timestamp: DateTime.now(),
          isRead: false,
        ));

        Get.snackbar(
          'Emergency Request Sent',
          'Request ID: $requestId\nSearching for available ambulance...',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );

        // Navigate to tracking screen
        Get.offNamed('/ambulance-tracking', arguments: {
          'requestId': requestId,
          'emergencyType': _selectedEmergencyType,
          'severity': _selectedSeverity,
          'patientName': _patientNameController.text.trim(),
          'location': _locationController.text.trim(),
        });
      } else {
        throw Exception('Failed to create emergency request');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create emergency request. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isRequestingAmbulance = false;
      });
    }
  }
}
