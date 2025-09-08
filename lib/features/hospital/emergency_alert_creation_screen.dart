import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmergencyAlertCreationScreen extends StatefulWidget {
  const EmergencyAlertCreationScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyAlertCreationScreen> createState() => _EmergencyAlertCreationScreenState();
}

class _EmergencyAlertCreationScreenState extends State<EmergencyAlertCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _patientAgeController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _pickupAddressController = TextEditingController();
  final _medicalConditionController = TextEditingController();
  final _additionalNotesController = TextEditingController();

  String _selectedPriority = 'High';
  String _selectedGender = 'Male';
  String _selectedAmbulanceType = 'Basic Life Support';
  bool _requiresSpecialEquipment = false;

  final List<String> _priorities = ['Critical', 'High', 'Medium', 'Low'];
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _ambulanceTypes = [
    'Basic Life Support',
    'Advanced Life Support',
    'Critical Care Transport',
    'Neonatal Transport'
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
          'Create Emergency Alert',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              // Show help dialog
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Priority Selection
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
                    const Text(
                      'Emergency Priority',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      children: _priorities.map((priority) {
                        Color priorityColor = priority == 'Critical'
                            ? const Color(0xFFFF5252)
                            : priority == 'High'
                                ? const Color(0xFFFF9800)
                                : priority == 'Medium'
                                    ? const Color(0xFF2196F3)
                                    : const Color(0xFF4CAF50);

                        return ChoiceChip(
                          label: Text(priority),
                          selected: _selectedPriority == priority,
                          onSelected: (selected) {
                            setState(() {
                              _selectedPriority = priority;
                            });
                          },
                          selectedColor: priorityColor.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: _selectedPriority == priority ? priorityColor : Colors.black87,
                            fontWeight: _selectedPriority == priority ? FontWeight.w600 : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

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
                    const Text(
                      'Patient Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Patient Name
                    TextFormField(
                      controller: _patientNameController,
                      decoration: const InputDecoration(
                        labelText: 'Patient Name *',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter patient name';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Age and Gender Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _patientAgeController,
                            decoration: const InputDecoration(
                              labelText: 'Age *',
                              prefixIcon: Icon(Icons.cake),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter age';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedGender,
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            items: _genders.map((gender) {
                              return DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Contact Number
                    TextFormField(
                      controller: _contactNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number *',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter contact number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Location Information
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
                    const Text(
                      'Pickup Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _pickupAddressController,
                      decoration: const InputDecoration(
                        labelText: 'Pickup Address *',
                        prefixIcon: Icon(Icons.location_on),
                        suffixIcon: Icon(Icons.my_location),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter pickup address';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Medical Information
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
                    const Text(
                      'Medical Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Medical Condition
                    TextFormField(
                      controller: _medicalConditionController,
                      decoration: const InputDecoration(
                        labelText: 'Medical Condition *',
                        prefixIcon: Icon(Icons.medical_services),
                        hintText: 'e.g., Cardiac Emergency, Accident, etc.',
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter medical condition';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Ambulance Type
                    DropdownButtonFormField<String>(
                      value: _selectedAmbulanceType,
                      decoration: const InputDecoration(
                        labelText: 'Required Ambulance Type',
                        prefixIcon: Icon(Icons.local_shipping),
                      ),
                      items: _ambulanceTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAmbulanceType = value!;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Special Equipment Checkbox
                    CheckboxListTile(
                      title: const Text('Requires Special Equipment'),
                      subtitle: const Text('Ventilator, Defibrillator, etc.'),
                      value: _requiresSpecialEquipment,
                      onChanged: (value) {
                        setState(() {
                          _requiresSpecialEquipment = value!;
                        });
                      },
                      activeColor: const Color(0xFFFF5252),
                      contentPadding: EdgeInsets.zero,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Additional Notes
                    TextFormField(
                      controller: _additionalNotesController,
                      decoration: const InputDecoration(
                        labelText: 'Additional Notes',
                        prefixIcon: Icon(Icons.note),
                        hintText: 'Any additional information for the medical team',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _createEmergencyAlert();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5252),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Create Emergency Alert',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _createEmergencyAlert() {
    // Show confirmation dialog
    Get.dialog(
      AlertDialog(
        title: const Text('Emergency Alert Created'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Emergency alert has been successfully created and dispatched.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alert ID: EMG-2024-001',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  Text('Priority: $_selectedPriority'),
                  Text('Patient: ${_patientNameController.text}'),
                  const Text('Status: Dispatching Ambulance'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/hospital-live-tracking');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
            ),
            child: const Text('Track Ambulance', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _patientAgeController.dispose();
    _contactNumberController.dispose();
    _pickupAddressController.dispose();
    _medicalConditionController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }
}
