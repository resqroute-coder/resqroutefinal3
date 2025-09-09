import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool _isLoading = false;
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
                          'Employee ID or Email',
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
                            hintText: 'Enter your employee ID or email',
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
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF5252),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
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

  Future<void> _handleLogin() async {
    final inputIdOrEmail = _employeeIdController.text.trim();
    final password = _passwordController.text.trim();

    if (_selectedDepartment == null) {
      Get.snackbar(
        'Error',
        'Please select your department',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Map department to role
      String expectedRole;
      String dashboardRoute;
      
      switch (_selectedDepartment) {
        case 'Ambulance Driver':
          expectedRole = 'driver';
          dashboardRoute = '/driver-dashboard';
          break;
        case 'Traffic Police':
          expectedRole = 'traffic_police';
          dashboardRoute = '/traffic-police-dashboard';
          break;
        case 'Hospital Admin':
          expectedRole = 'hospital_staff';
          dashboardRoute = '/hospital-dashboard';
          break;
        default:
          throw Exception('Invalid department selected');
      }

      // Determine the email to use for FirebaseAuth sign-in.
      // If the user typed an email, use it. If they typed a code (e.g., EMP001),
      // construct an internal email like emp001@pro.resqroute (adjust domain if needed).
      final bool inputLooksLikeEmail = inputIdOrEmail.contains('@');
      final String loginEmail = inputLooksLikeEmail
          ? inputIdOrEmail
          : '${inputIdOrEmail.toLowerCase()}@pro.resqroute';

      // Authenticate with Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: loginEmail,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Authentication failed');
      }

      // Read professional profile from 'professional/{uid}'
      final profileDoc = await _firestore.collection('professional').doc(user.uid).get();

      if (!profileDoc.exists) {
        await _auth.signOut();
        throw Exception('Professional profile not found. Please contact administrator.');
      }

      final data = profileDoc.data()!;
      final userRole = (data['role'] as String?)?.trim();
      final profileEmployeeId = (data['employeeId'] as String?)?.trim();
      final profileEmail = (data['email'] as String?)?.trim();

      // Verify expected role matches
      if (userRole != expectedRole) {
        await _auth.signOut();
        throw Exception('Account role mismatch for $_selectedDepartment.');
      }

      // Verify identity depending on the input the user typed
      final bool identityMatches = inputLooksLikeEmail
          ? (profileEmail != null &&
              profileEmail.toLowerCase() == inputIdOrEmail.toLowerCase())
          : (profileEmployeeId != null && profileEmployeeId.toUpperCase() == inputIdOrEmail.toUpperCase());

      if (!identityMatches) {
        await _auth.signOut();
        throw Exception('Account verification failed. Please check your credentials.');
      }

      // Success - navigate to dashboard
      Get.snackbar(
        'Success',
        'Login successful! Welcome to $_selectedDepartment dashboard',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      Get.offAllNamed(dashboardRoute);

    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          errorMessage = 'Invalid Employee ID or Password for $_selectedDepartment';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled. Please contact administrator.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;
        default:
          errorMessage = 'Login failed: ${e.message}';
      }
      
      Get.snackbar(
        'Login Failed',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Login Failed',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
