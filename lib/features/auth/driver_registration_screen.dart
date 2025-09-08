import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';

class DriverRegistrationScreen extends StatefulWidget {
  const DriverRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<DriverRegistrationScreen> createState() => _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState extends State<DriverRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _licenseNumberController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  String? _selectedLicenseType;
  String? _selectedBloodGroup;
  bool _hasFirstAidTraining = false;
  bool _acceptsTerms = false;
  bool _isLoading = false;

  final List<String> _licenseTypes = [
    'Light Motor Vehicle (LMV)',
    'Heavy Motor Vehicle (HMV)',
    'Transport Vehicle',
    'Commercial Vehicle',
  ];

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _licenseNumberController.dispose();
    _experienceController.dispose();
    _emergencyContactController.dispose();
    _employeeIdController.dispose();
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
          'Driver Registration',
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
                'Join as Ambulance Driver',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Help save lives by joining our emergency response team',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Personal Information Section
              _buildSectionHeader('Personal Information'),
              const SizedBox(height: 16),
              
              _buildTextFormField(
                controller: _fullNameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                validator: (value) => value?.isEmpty == true ? 'Full name is required' : null,
              ),
              
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
              
              const SizedBox(height: 16),
              
              _buildDropdownField(
                label: 'Blood Group',
                value: _selectedBloodGroup,
                items: _bloodGroups,
                onChanged: (value) => setState(() => _selectedBloodGroup = value),
                validator: (value) => value == null ? 'Please select blood group' : null,
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
              
              // Professional Information Section
              _buildSectionHeader('Professional Information'),
              const SizedBox(height: 16),
              
              _buildTextFormField(
                controller: _licenseNumberController,
                label: 'Driving License Number',
                hint: 'Enter license number',
                validator: (value) => value?.isEmpty == true ? 'License number is required' : null,
              ),
              
              const SizedBox(height: 16),
              
              _buildDropdownField(
                label: 'License Type',
                value: _selectedLicenseType,
                items: _licenseTypes,
                onChanged: (value) => setState(() => _selectedLicenseType = value),
                validator: (value) => value == null ? 'Please select license type' : null,
              ),
              
              const SizedBox(height: 16),
              
              _buildTextFormField(
                controller: _experienceController,
                label: 'Driving Experience (Years)',
                hint: 'Enter years of experience',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Experience is required';
                  final experience = int.tryParse(value!);
                  if (experience == null || experience < 2) return 'Minimum 2 years experience required';
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              _buildTextFormField(
                controller: _emergencyContactController,
                label: 'Emergency Contact',
                hint: 'Enter emergency contact number',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Emergency contact is required';
                  if (value!.length != 10) return 'Enter valid 10-digit phone number';
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              _buildCheckboxTile(
                title: 'I have First Aid Training Certificate',
                value: _hasFirstAidTraining,
                onChanged: (value) => setState(() => _hasFirstAidTraining = value ?? false),
              ),
              
              const SizedBox(height: 24),
              
              // Account Information Section
              _buildSectionHeader('Account Information'),
              const SizedBox(height: 16),
              
              _buildTextFormField(
                controller: _employeeIdController,
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
                          'Register as Driver',
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
    final employeeId = _employeeIdController.text.trim();
    final password = _passwordController.text.trim();
    final authEmail = _buildProfessionalEmail(employeeId);

    final additionalData = <String, dynamic>{
      'name': _fullNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'contactEmail': _emailController.text.trim(),
      'address': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'pincode': _pincodeController.text.trim(),
      'bloodGroup': _selectedBloodGroup,
      'licenseNumber': _licenseNumberController.text.trim(),
      'licenseType': _selectedLicenseType,
      'experienceYears': int.tryParse(_experienceController.text.trim()) ?? 0,
      'emergencyContact': _emergencyContactController.text.trim(),
      'employeeId': employeeId,
      'hasFirstAidTraining': _hasFirstAidTraining,
    };

    try {
      final auth = AuthService();
      await auth.registerUser(
        email: authEmail,
        password: password,
        name: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        role: AppConstants.roleDriver,
        authType: AppConstants.authTypeProfessional,
        additionalData: additionalData,
      );

      Get.snackbar('Registration Successful', 'Driver account created. You can now login with your Employee ID and password.', backgroundColor: Colors.green, colorText: Colors.white);
      Get.back();
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account with this Employee ID already exists.';
          break;
        case 'weak-password':
          message = 'Password is too weak. Use at least 6 characters.';
          break;
        case 'invalid-email':
          message = 'Invalid Employee ID format. Contact admin.';
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
