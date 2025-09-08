import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/user_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserService _userService = Get.find<UserService>();

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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {
              // Handle notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // Handle more options
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
              child: Obx(() => Column(
                children: [
                  // Profile Picture
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB3D9FF),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF2196F3),
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
                            color: const Color(0xFF2196F3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // User Name
                  Text(
                    _userService.userName.isNotEmpty ? _userService.userName : 'User Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // User Email and Phone
                  Text(
                    '${_userService.userEmail.isNotEmpty ? _userService.userEmail : 'email@domain.com'} | ${_userService.userPhone.isNotEmpty ? _userService.userPhone : '+00 00000 00000'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              )),
            ),
            
            const SizedBox(height: 24),
            
            // Profile Options
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildProfileOption(
                    icon: Icons.edit,
                    title: 'Edit profile information',
                    onTap: () {
                      _showEditProfileDialog();
                    },
                  ),
                  Obx(() => _buildProfileOption(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    trailing: Text(
                      _userService.notificationsEnabled ? 'ON' : 'OFF',
                      style: const TextStyle(
                        color: Color(0xFFFF5252),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      _userService.updatePreferences(
                        notificationsEnabled: !_userService.notificationsEnabled,
                      );
                    },
                  )),
                  Obx(() => _buildProfileOption(
                    icon: Icons.language,
                    title: 'Language',
                    trailing: Text(
                      _userService.selectedLanguage,
                      style: const TextStyle(
                        color: Color(0xFFFF5252),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      _showLanguageDialog();
                    },
                  )),
                  _buildProfileOption(
                    icon: Icons.medical_information,
                    title: 'Medical Information',
                    onTap: () {
                      _showMedicalInfoDialog();
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.contacts,
                    title: 'Emergency Contacts',
                    onTap: () {
                      Get.toNamed('/emergency-contacts');
                    },
                  ),
                  Obx(() => _buildProfileOption(
                    icon: Icons.dark_mode,
                    title: 'Theme',
                    trailing: Text(
                      _userService.selectedTheme,
                      style: const TextStyle(
                        color: Color(0xFFFF5252),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      _showThemeDialog();
                    },
                  )),
                  _buildProfileOption(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      _showHelpSupportDialog();
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.email,
                    title: 'Contact us',
                    onTap: () {
                      _showContactUsDialog();
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.privacy_tip,
                    title: 'Privacy policy',
                    onTap: () {
                      _showPrivacyPolicyDialog();
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.logout,
                    title: 'Log out',
                    titleColor: const Color(0xFFFF5252),
                    onTap: () {
                      _showLogoutDialog();
                    },
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

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    Widget? trailing,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: titleColor ?? Colors.black87,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? Colors.black87,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userService.userName);
    final phoneController = TextEditingController(text: _userService.userPhone);
    final emailController = TextEditingController(text: _userService.userEmail);

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Profile Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: false, // Email cannot be changed
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _userService.updateProfile(
                  name: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                );
                Get.back();
                Get.snackbar(
                  'Success',
                  'Profile updated successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to update profile: $e',
                  backgroundColor: Colors.red,
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

  void _showMedicalInfoDialog() {
    String selectedBloodGroup = _userService.bloodGroup.isNotEmpty ? _userService.bloodGroup : 'O+';
    final conditionsController = TextEditingController(text: _userService.medicalConditions);
    final allergiesController = TextEditingController(text: _userService.allergies);
    final medicationsController = TextEditingController(text: _userService.medications);
    final emergencyNameController = TextEditingController(text: _userService.emergencyContactName);
    final emergencyPhoneController = TextEditingController(text: _userService.emergencyContactPhone);
    final emergencyRelationController = TextEditingController(text: _userService.emergencyContactRelation);

    Get.dialog(
      AlertDialog(
        title: const Text('Medical Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Blood Group Dropdown
              StatefulBuilder(
                builder: (context, setState) {
                  return DropdownButtonFormField<String>(
                    value: selectedBloodGroup,
                    decoration: const InputDecoration(
                      labelText: 'Blood Group',
                      border: OutlineInputBorder(),
                    ),
                    items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedBloodGroup = newValue!;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: conditionsController,
                decoration: const InputDecoration(
                  labelText: 'Medical Conditions',
                  border: OutlineInputBorder(),
                  hintText: 'Any existing medical conditions',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: allergiesController,
                decoration: const InputDecoration(
                  labelText: 'Allergies',
                  border: OutlineInputBorder(),
                  hintText: 'Any known allergies',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: medicationsController,
                decoration: const InputDecoration(
                  labelText: 'Current Medications',
                  border: OutlineInputBorder(),
                  hintText: 'Any current medications',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emergencyNameController,
                decoration: const InputDecoration(
                  labelText: 'Emergency Contact Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emergencyPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Emergency Contact Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emergencyRelationController,
                decoration: const InputDecoration(
                  labelText: 'Emergency Contact Relation',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Father, Mother, Spouse',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _userService.updateMedicalInfo(
                  bloodGroup: selectedBloodGroup,
                  medicalConditions: conditionsController.text.trim(),
                  allergies: allergiesController.text.trim(),
                  medications: medicationsController.text.trim(),
                  emergencyContactName: emergencyNameController.text.trim(),
                  emergencyContactPhone: emergencyPhoneController.text.trim(),
                  emergencyContactRelation: emergencyRelationController.text.trim(),
                );
                Get.back();
                Get.snackbar(
                  'Success',
                  'Medical information updated successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to update medical information: $e',
                  backgroundColor: Colors.red,
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

  void _showLanguageDialog() {
    final languages = ['English', 'Hindi', 'Marathi', 'Gujarati'];
    
    Get.dialog(
      AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) {
            return Obx(() => RadioListTile<String>(
              title: Text(language),
              value: language,
              groupValue: _userService.selectedLanguage,
              onChanged: (String? value) {
                _userService.updatePreferences(selectedLanguage: value);
                Get.back();
              },
              activeColor: const Color(0xFFFF5252),
            ));
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    final themes = ['Light mode', 'Dark mode', 'System default'];
    
    Get.dialog(
      AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: themes.map((theme) {
            return Obx(() => RadioListTile<String>(
              title: Text(theme),
              value: theme,
              groupValue: _userService.selectedTheme,
              onChanged: (String? value) {
                _userService.updatePreferences(selectedTheme: value);
                Get.back();
              },
              activeColor: const Color(0xFFFF5252),
            ));
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showHelpSupportDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Help & Support'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.help_outline, color: Color(0xFFFF5252)),
                title: const Text('FAQ'),
                subtitle: const Text('Frequently asked questions'),
                onTap: () {
                  Get.back();
                  Get.snackbar('FAQ', 'Opening FAQ section...');
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat, color: Color(0xFFFF5252)),
                title: const Text('Live Chat'),
                subtitle: const Text('Chat with our support team'),
                onTap: () {
                  Get.back();
                  Get.snackbar('Live Chat', 'Connecting to support...');
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone, color: Color(0xFFFF5252)),
                title: const Text('Call Support'),
                subtitle: const Text('1800-123-4567'),
                onTap: () {
                  Get.back();
                  Get.snackbar('Calling', 'Dialing support number...');
                },
              ),
              ListTile(
                leading: const Icon(Icons.bug_report, color: Color(0xFFFF5252)),
                title: const Text('Report Issue'),
                subtitle: const Text('Report a bug or technical issue'),
                onTap: () {
                  Get.back();
                  Get.snackbar('Report Issue', 'Opening issue reporting form...');
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showContactUsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Contact Us'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.email, color: Color(0xFFFF5252)),
              title: const Text('Email'),
              subtitle: const Text('support@resqroute.com'),
              onTap: () {
                Get.back();
                Get.snackbar('Email', 'Opening email client...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: Color(0xFFFF5252)),
              title: const Text('Phone'),
              subtitle: const Text('1800-123-4567'),
              onTap: () {
                Get.back();
                Get.snackbar('Phone', 'Dialing support number...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Color(0xFFFF5252)),
              title: const Text('Address'),
              subtitle: const Text('ResQRoute HQ, Mumbai, India'),
              onTap: () {
                Get.back();
                Get.snackbar('Address', 'Opening maps...');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'ResQRoute Privacy Policy\n\n'
            '1. Information Collection\n'
            'We collect information you provide directly to us, such as when you create an account, request emergency services, or contact us for support.\n\n'
            '2. Use of Information\n'
            'We use the information we collect to provide, maintain, and improve our emergency response services.\n\n'
            '3. Information Sharing\n'
            'We may share your information with emergency services, hospitals, and ambulance providers to facilitate emergency response.\n\n'
            '4. Data Security\n'
            'We implement appropriate security measures to protect your personal information.\n\n'
            '5. Contact Us\n'
            'If you have questions about this Privacy Policy, please contact us at privacy@resqroute.com',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _userService.logoutUser();
                Get.back();
                Get.offAllNamed('/user-login');
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to logout: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
            ),
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
