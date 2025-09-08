import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';

class HospitalRegistrationScreen extends StatefulWidget {
  const HospitalRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<HospitalRegistrationScreen> createState() => _HospitalRegistrationScreenState();
}

class _HospitalRegistrationScreenState extends State<HospitalRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _hospitalNameController = TextEditingController();
  final TextEditingController _registrationNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _adminNameController = TextEditingController();
  final TextEditingController _adminEmployeeIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  String? _selectedHospitalType;
  int _totalBeds = 0;
  int _icuBeds = 0;
  int _emergencyBeds = 0;
  bool _hasAmbulanceService = false;
  bool _has24x7Emergency = false;
  bool _acceptsTerms = false;
  bool _isLoading = false;

  final List<String> _hospitalTypes = [
    'Government Hospital',
    'Private Hospital',
    'Multi-Specialty Hospital',
    'Super Specialty Hospital',
    'Nursing Home',
    'Clinic',
  ];

  @override
  void dispose() {
    _hospitalNameController.dispose();
    _registrationNumberController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _adminNameController.dispose();
    _adminEmployeeIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          'Hospital Registration',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Register Your Hospital',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join ResQRoute emergency network to serve patients better',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Hospital Information Section
              _buildSectionHeader('Hospital Information'),
              const SizedBox(height: 16),
              
              _buildTextFormField(
                controller: _hospitalNameController,
                label: 'Hospital Name',
                hint: 'Enter hospital name',
                validator: (value) => value?.isEmpty == true ? 'Hospital name is required' : null,
              ),
              
              const SizedBox(height: 16),
              
              _buildDropdownField(
                label: 'Hospital Type',
                value: _selectedHospitalType,
                items: _hospitalTypes,
                onChanged: (value) => setState(() => _selectedHospitalType = value),
                validator: (value) => value == null ? 'Please select hospital type' : null,
              ),
              
              const SizedBox(height: 16),
              
              _buildTextFormField(
                controller: _registrationNumberController,
                label: 'Registration Number',
                hint: 'Enter hospital registration number',
                validator: (value) => value?.isEmpty == true ? 'Registration number is required' : null,
              ),
              
              const SizedBox(height: 24),
              
              // Address Section
              _buildSectionHeader('Address Information'),
              const SizedBox(height: 16),
              
              _buildTextFormField(
                controller: _addressController,
                label: 'Address',
                hint: 'Enter complete address',
                maxLines: 3,
                validator: (value) => value?.isEmpty == true ? 'Address is required' : null,
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _cityController,
                      label: 'City',
                      hint: 'Enter city',
                      validator: (value) => value?.isEmpty == true ? 'City is required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextFormField(
                      controller: _stateController,
                      label: 'State',
                      hint: 'Enter state',
                      validator: (value) => value?.isEmpty == true ? 'State is required' : null,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              _buildTextFormField(
                controller: _pincodeController,
                label: 'Pincode',
                hint: 'Enter pincode',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Pincode is required';
                  if (value!.length != 6) return 'Enter valid 6-digit pincode';
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Contact Information Section
              _buildSectionHeader('Contact Information'),
              const SizedBox(height: 16),
              
              _buildTextFormField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: 'Enter phone number',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Phone number is required';
                  if (value!.length != 10) return 'Enter valid 10-digit phone number';
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              _buildTextFormField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'Enter email address',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Email is required';
                  if (!GetUtils.isEmail(value!)) return 'Enter valid email address';
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Facility Information Section
              _buildSectionHeader('Facility Information'),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      label: 'Total Beds',
                      value: _totalBeds,
                      onChanged: (value) => setState(() => _totalBeds = value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumberField(
                      label: 'ICU Beds',
                      value: _icuBeds,
                      onChanged: (value) => setState(() => _icuBeds = value),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              _buildNumberField(
                label: 'Emergency Beds',
                value: _emergencyBeds,
                onChanged: (value) => setState(() => _emergencyBeds = value),
              ),
              
              const SizedBox(height: 16),
              
              _buildCheckboxTile(
                title: 'Ambulance Service Available',
                value: _hasAmbulanceService,
                onChanged: (value) => setState(() => _hasAmbulanceService = value ?? false),
              ),
              
              _buildCheckboxTile(
                title: '24x7 Emergency Services',
                value: _has24x7Emergency,
                onChanged: (value) => setState(() => _has24x7Emergency = value ?? false),
              ),
              
              const SizedBox(height: 24),
              
              // Admin Account Section
              _buildSectionHeader('Admin Account'),
              const SizedBox(height: 16),
              
              _buildTextFormField(
                controller: _adminNameController,
                label: 'Admin Name',
                hint: 'Enter admin full name',
                validator: (value) => value?.isEmpty == true ? 'Admin name is required' : null,
              ),
              
              const SizedBox(height: 16),
              
              _buildTextFormField(
                controller: _adminEmployeeIdController,
                label: 'Employee ID',
                hint: 'Enter employee ID',
                validator: (value) => value?.isEmpty == true ? 'Employee ID is required' : null,
              ),
              
              const SizedBox(height: 16),
              
              _buildTextFormField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter password',
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Password is required';
                  if (value!.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              _buildTextFormField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                hint: 'Confirm password',
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Please confirm password';
                  if (value != _passwordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Terms and Conditions
              _buildCheckboxTile(
                title: 'I agree to the Terms and Conditions and Privacy Policy',
                value: _acceptsTerms,
                onChanged: (value) => setState(() => _acceptsTerms = value ?? false),
              ),
              
              const SizedBox(height: 32),
              
              // Register Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5252),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Register Hospital',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Login Link
              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    'Already registered? Login here',
                    style: TextStyle(
                      color: Color(0xFFFF5252),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF5252)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF5252)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item),
      )).toList(),
    );
  }

  Widget _buildNumberField({
    required String label,
    required int value,
    required void Function(int) onChanged,
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
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                child: Text(
                  value.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => onChanged(value + 1),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required bool value,
    required void Function(bool?) onChanged,
  }) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFFFF5252),
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptsTerms) {
      Get.snackbar('Error', 'Please accept the terms and conditions', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);

    final adminId = _adminEmployeeIdController.text.trim();
    final password = _passwordController.text.trim();
    final authEmail = _buildProfessionalEmail(adminId);

    final additionalData = <String, dynamic>{
      // Hospital details
      'hospitalName': _hospitalNameController.text.trim(),
      'registrationNumber': _registrationNumberController.text.trim(),
      'hospitalType': _selectedHospitalType,
      'address': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'pincode': _pincodeController.text.trim(),
      'phone': _phoneController.text.trim(),
      'contactEmail': _emailController.text.trim(),
      'totalBeds': _totalBeds,
      'icuBeds': _icuBeds,
      'emergencyBeds': _emergencyBeds,
      'hasAmbulanceService': _hasAmbulanceService,
      'has24x7Emergency': _has24x7Emergency,
      // Admin details
      'adminName': _adminNameController.text.trim(),
      'adminEmployeeId': adminId,
    };

    try {
      final auth = AuthService();
      await auth.registerUser(
        email: authEmail,
        password: password,
        name: _adminNameController.text.trim(),
        phone: _phoneController.text.trim(),
        role: AppConstants.roleHospital,
        authType: AppConstants.authTypeProfessional,
        additionalData: additionalData,
      );

      Get.snackbar('Registration Successful', 'Hospital admin account created. Login with Admin ID and password.', backgroundColor: Colors.green, colorText: Colors.white);
      Get.back();
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account with this Admin ID already exists.';
          break;
        case 'weak-password':
          message = 'Password is too weak. Use at least 6 characters.';
          break;
        case 'invalid-email':
          message = 'Invalid Admin ID format. Contact admin.';
          break;
        default:
          message = e.message ?? 'Registration failed.';
      }
      Get.snackbar('Registration Failed', message, backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _buildProfessionalEmail(String id) {
    return '${id.trim().toLowerCase()}@resqroute.pro';
  }
}
