import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final List<EmergencyHotline> _emergencyHotlines = [
    EmergencyHotline(
      title: 'National Emergency',
      subtitle: 'Police, Fire, Medical Emergency',
      number: '112',
    ),
    EmergencyHotline(
      title: 'Ambulance Service',
      subtitle: 'Free ambulance service',
      number: '108',
    ),
    EmergencyHotline(
      title: 'Police',
      subtitle: 'Police emergency',
      number: '100',
    ),
    EmergencyHotline(
      title: 'Fire Department',
      subtitle: 'Fire emergency',
      number: '101',
    ),
    EmergencyHotline(
      title: 'Women Helpline',
      subtitle: 'Women in distress',
      number: '1091',
    ),
  ];

  final List<PersonalContact> _personalContacts = [
    PersonalContact(
      id: '1',
      name: 'Dr. Rajesh Sharma',
      type: 'Family Doctor',
      number: '+91 98765 43210',
    ),
    PersonalContact(
      id: '2',
      name: 'Priya Patel',
      type: 'Emergency Contact',
      number: '+91 87654 32109',
    ),
    PersonalContact(
      id: '3',
      name: 'Mumbai Hospital',
      type: 'Primary Hospital',
      number: '+91 76543 21098',
    ),
  ];

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
          'Emergency Contacts',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency Hotlines Section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE8E8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.emergency,
                      color: Color(0xFFFF5252),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Emergency Hotlines',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF5252),
                    ),
                  ),
                ],
              ),
            ),
            
            // Emergency Hotlines List
            Container(
              color: Colors.white,
              child: Column(
                children: _emergencyHotlines.map((hotline) => _buildHotlineCard(hotline)).toList(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Personal Contacts Section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Personal Contacts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Handle add contact
                      _showAddContactDialog();
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.add,
                          color: Color(0xFFFF5252),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Add Contact',
                          style: TextStyle(
                            color: Color(0xFFFF5252),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Personal Contacts List
            Container(
              color: Colors.white,
              child: Column(
                children: _personalContacts.map((contact) => _buildPersonalContactCard(contact)).toList(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Emergency Guidelines
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE8E8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Emergency Guidelines',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF5252),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHotlineCard(EmergencyHotline hotline) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotline.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hotline.subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            hotline.number,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF5252),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _makePhoneCall(hotline.number),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5252),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.phone,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalContactCard(PersonalContact contact) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contact.type,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            contact.number,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              _showEditContactDialog(contact);
            },
            child: const Icon(
              Icons.edit,
              color: Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              _showDeleteContactDialog(contact);
            },
            child: const Icon(
              Icons.delete,
              color: Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _makePhoneCall(contact.number),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5252),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.phone,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch phone dialer',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    final numberController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Emergency Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(
                labelText: 'Type (e.g., Family Doctor)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: numberController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  typeController.text.isNotEmpty &&
                  numberController.text.isNotEmpty) {
                setState(() {
                  _personalContacts.add(
                    PersonalContact(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      type: typeController.text,
                      number: numberController.text,
                    ),
                  );
                });
                Get.back();
                Get.snackbar(
                  'Success',
                  'Contact added successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
            ),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditContactDialog(PersonalContact contact) {
    final nameController = TextEditingController(text: contact.name);
    final typeController = TextEditingController(text: contact.type);
    final numberController = TextEditingController(text: contact.number);

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Emergency Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(
                labelText: 'Type (e.g., Family Doctor)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: numberController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  typeController.text.isNotEmpty &&
                  numberController.text.isNotEmpty) {
                setState(() {
                  final index = _personalContacts.indexWhere((c) => c.id == contact.id);
                  if (index != -1) {
                    _personalContacts[index] = PersonalContact(
                      id: contact.id,
                      name: nameController.text,
                      type: typeController.text,
                      number: numberController.text,
                    );
                  }
                });
                Get.back();
                Get.snackbar(
                  'Success',
                  'Contact updated successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
            ),
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteContactDialog(PersonalContact contact) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${contact.name}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _personalContacts.removeWhere((c) => c.id == contact.id);
              });
              Get.back();
              Get.snackbar(
                'Success',
                'Contact deleted successfully',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class EmergencyHotline {
  final String title;
  final String subtitle;
  final String number;

  EmergencyHotline({
    required this.title,
    required this.subtitle,
    required this.number,
  });
}

class PersonalContact {
  final String id;
  final String name;
  final String type;
  final String number;

  PersonalContact({
    required this.id,
    required this.name,
    required this.type,
    required this.number,
  });
}
