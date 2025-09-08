import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfessionalLoginScreen extends StatefulWidget {
  const ProfessionalLoginScreen({Key? key}) : super(key: key);

  @override
  State<ProfessionalLoginScreen> createState() => _ProfessionalLoginScreenState();
}

class _ProfessionalLoginScreenState extends State<ProfessionalLoginScreen> {
  final _employeeIdController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedDepartment;
  bool _obscurePassword = true;

  final List<Map<String, dynamic>> _departments = [
    {
      'name': 'Ambulance Driver',
      'icon': Icons.local_hospital,
      'color': Colors.blue,
    },
    {
      'name': 'Traffic Police',
      'icon': Icons.local_police,
      'color': Colors.green,
    },
    {
      'name': 'Hospital Admin',
      'icon': Icons.business,
      'color': Colors.purple,
    },
  ];

  @override
  void dispose() {
    _employeeIdController.dispose();
    _passwordController.dispose();
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.navigation,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'ResQRoute Pro',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Shield icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.security,
                      color: Color(0xFFFF5252),
                      size: 32,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Professional Access title
                  const Text(
                    'Professional Access',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  const Text(
                    'Sign in with your official credentials',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Department selection
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
                          'Department',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Department dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedDepartment,
                          hint: const Text(
                            'Select your department',
                            style: TextStyle(color: Colors.grey),
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          items: _departments.map((dept) {
                            return DropdownMenuItem<String>(
                              value: dept['name'],
                              child: Row(
                                children: [
                                  Icon(
                                    dept['icon'],
                                    color: dept['color'],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    dept['name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              _selectedDepartment = value;
                            });
                          },
                        ),

                        const SizedBox(height: 20),

                        // Employee ID field
                        const Text(
                          'Employee ID',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _employeeIdController,
                          decoration: InputDecoration(
                            hintText: 'Enter your employee ID',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Password field
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Sign In button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF5252),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Demo Credentials section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Demo Credentials:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Driver: EMP001 / password123',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Police: OFF001 / password123',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Hospital: ADM001 / password123',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Login Link
                  Center(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Back to User Login',
                        style: TextStyle(
                          color: Color(0xFFFF5252),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Footer text
                  const Text(
                    'Authorized personnel only • ResQRoute Professional System',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin() {
    final employeeId = _employeeIdController.text.trim();
    final password = _passwordController.text.trim();

    // Validate inputs
    if (_selectedDepartment == null) {
      Get.snackbar(
        'Error',
        'Please select your department',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (employeeId.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter both Employee ID and Password',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validate credentials based on department
    bool isValidCredentials = false;
    String dashboardRoute = '';

    if (_selectedDepartment == 'Ambulance Driver') {
      if (employeeId == 'EMP001' && password == 'password123') {
        isValidCredentials = true;
        dashboardRoute = '/driver-dashboard';
      }
    } else if (_selectedDepartment == 'Traffic Police') {
      if (employeeId == 'OFF001' && password == 'password123') {
        isValidCredentials = true;
        dashboardRoute = '/traffic-police-dashboard';
      }
    } else if (_selectedDepartment == 'Hospital Admin') {
      if (employeeId == 'ADM001' && password == 'password123') {
        isValidCredentials = true;
        dashboardRoute = '/hospital-dashboard';
      }
    }

    if (isValidCredentials) {
      Get.snackbar(
        'Success',
        'Login successful! Welcome to $_selectedDepartment dashboard',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAllNamed(dashboardRoute);
    } else {
      Get.snackbar(
        'Login Failed',
        'Invalid Employee ID or Password for $_selectedDepartment',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
