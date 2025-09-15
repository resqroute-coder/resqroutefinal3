import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/professional_model.dart';
import 'notification_service.dart';

class ProfessionalService extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final NotificationService _notificationService;
  
  // Observable professional data
  final Rx<ProfessionalModel?> _currentProfessional = Rx<ProfessionalModel?>(null);
  final RxBool _isLoading = false.obs;
  
  // Getters
  ProfessionalModel? get currentProfessional => _currentProfessional.value;
  bool get isLoading => _isLoading.value;
  String get professionalName => _currentProfessional.value?.fullName ?? 'Professional';
  String get professionalRole => _currentProfessional.value?.role ?? '';
  String get employeeId => _currentProfessional.value?.employeeId ?? '';
  String get professionalEmail => _currentProfessional.value?.email ?? '';
  String get professionalPhone => _currentProfessional.value?.phone ?? '';
  
  @override
  void onInit() {
    super.onInit();
    _notificationService = Get.find<NotificationService>();
    // Listen to auth state changes to reload professional data
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadProfessionalData();
      } else {
        _currentProfessional.value = null;
      }
    });
  }
  
  // Load professional data from Firebase
  Future<void> _loadProfessionalData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        _isLoading.value = true;
        
        print('ProfessionalService: Loading data for user: ${user.uid}');
        
        final doc = await _firestore
            .collection('professional')
            .doc(user.uid)
            .get();
            
        if (doc.exists) {
          final professional = ProfessionalModel.fromFirestore(doc);
          _currentProfessional.value = professional;
          print('ProfessionalService: Loaded professional: ${professional.fullName} (${professional.role})');
          
          // Note: Login notifications are now handled by NotificationService._sendWelcomeNotification()
          // which provides role-specific welcome messages and sample notifications
        } else {
          print('ProfessionalService: No professional document found for user: ${user.uid}');
          _currentProfessional.value = null;
        }
      } else {
        print('ProfessionalService: No authenticated user found');
        _currentProfessional.value = null;
      }
    } catch (e) {
      print('Error loading professional data: $e');
      _currentProfessional.value = null;
      // Don't throw error to prevent app crashes, just log it
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Send professional login notification
  Future<void> _sendProfessionalLoginNotification(ProfessionalModel professional) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      String roleDisplayName = _getRoleDisplayName(professional.role);
      String welcomeMessage = _getWelcomeMessage(professional.role, professional.fullName);
      
      await _notificationService.sendEmergencyNotification(
        userId: user.uid,
        title: 'Welcome Back, ${professional.fullName}!',
        message: welcomeMessage,
        type: NotificationType.info,
        data: {
          'event': 'professional_login',
          'role': professional.role,
          'employeeId': professional.employeeId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Error sending professional login notification: $e');
    }
  }
  
  // Get role display name
  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'driver':
        return 'Ambulance Driver';
      case 'hospital_staff':
        return 'Hospital Staff';
      case 'traffic_police':
        return 'Traffic Police Officer';
      default:
        return 'Professional';
    }
  }
  
  // Get welcome message based on role
  String _getWelcomeMessage(String role, String name) {
    switch (role) {
      case 'driver':
        return 'You have successfully logged in as an Ambulance Driver. Ready to respond to emergency calls and save lives.';
      case 'hospital_staff':
        return 'You have successfully logged in as Hospital Staff. Ready to receive patients and coordinate emergency care.';
      case 'traffic_police':
        return 'You have successfully logged in as Traffic Police Officer. Ready to clear routes and assist emergency vehicles.';
      default:
        return 'You have successfully logged in to ResQRoute professional services.';
    }
  }
  
  // Refresh professional data
  Future<void> refreshProfessionalData() async {
    await _loadProfessionalData();
  }
  
  // Update additional professional data
  Future<void> updateAdditionalData(Map<String, dynamic> additionalData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('professional')
          .doc(user.uid)
          .update({'additionalData': additionalData});
      
      // Send profile update notification
      await _sendProfessionalUpdateNotification(additionalData);
      
      // Reload professional data to reflect changes
      await _loadProfessionalData();
      
      print('ProfessionalService: Additional data updated successfully');
    } catch (e) {
      print('ProfessionalService: Error updating additional data: $e');
    }
  }

  // Send professional profile update notification
  Future<void> _sendProfessionalUpdateNotification(Map<String, dynamic> updates) async {
    try {
      final user = _auth.currentUser;
      if (user == null || _currentProfessional.value == null) return;

      final role = _currentProfessional.value!.role;
      final updatedFields = updates.keys.join(', ');
      
      await _notificationService.sendEmergencyNotification(
        userId: user.uid,
        title: 'Professional Profile Updated',
        message: 'Your $role profile has been updated: $updatedFields',
        type: NotificationType.info,
        data: {
          'event': 'professional_profile_update',
          'role': role,
          'updated_fields': updates.keys.toList(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Error sending professional update notification: $e');
    }
  }
  
  // Get driver performance metrics
  Future<Map<String, dynamic>> getDriverPerformance() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return _getDefaultDriverMetrics();
      
      // Get today's date range
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      // Query completed trips for today
      final tripsQuery = await _firestore
          .collection('emergency_requests')
          .where('driverId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'completed')
          .where('completedAt', isGreaterThanOrEqualTo: startOfDay)
          .where('completedAt', isLessThan: endOfDay)
          .get();
      
      // Calculate metrics from actual data
      int tripsCompleted = tripsQuery.docs.length;
      double totalDistance = 0;
      double totalEarnings = 0;
      double totalRating = 0;
      int ratingCount = 0;
      
      for (var doc in tripsQuery.docs) {
        final data = doc.data();
        totalDistance += (data['distance'] as num?)?.toDouble() ?? 0;
        totalEarnings += (data['fare'] as num?)?.toDouble() ?? 0;
        
        if (data['rating'] != null) {
          totalRating += (data['rating'] as num).toDouble();
          ratingCount++;
        }
      }
      
      double averageRating = ratingCount > 0 ? totalRating / ratingCount : 4.5;
      
      return {
        'tripsCompleted': tripsCompleted,
        'kmDriven': totalDistance.round(),
        'earnings': totalEarnings.round(),
        'rating': averageRating,
      };
    } catch (e) {
      print('Error getting driver performance: $e');
      return _getDefaultDriverMetrics();
    }
  }
  
  // Get hospital metrics
  Future<Map<String, dynamic>> getHospitalMetrics() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return _getDefaultHospitalMetrics();
      
      // Try to get hospital data, create if doesn't exist
      DocumentSnapshot hospitalDoc;
      try {
        hospitalDoc = await _firestore
            .collection('hospitals')
            .doc(user.uid)
            .get();
      } catch (e) {
        print('Error accessing hospitals collection: $e');
        return _getDefaultHospitalMetrics();
      }
      
      Map<String, dynamic> hospitalData;
      if (!hospitalDoc.exists) {
        // Create default hospital document
        hospitalData = {
          'totalBeds': 50,
          'availableBeds': 20,
          'activeAmbulances': 5,
        };
        try {
          await _firestore
              .collection('hospitals')
              .doc(user.uid)
              .set(hospitalData);
        } catch (e) {
          print('Error creating hospital document: $e');
          return _getDefaultHospitalMetrics();
        }
      } else {
        hospitalData = hospitalDoc.data() as Map<String, dynamic>;
      }
      
      // Get incoming patients count
      final incomingQuery = await _firestore
          .collection('emergency_requests')
          .where('assignedHospitalId', isEqualTo: user.uid)
          .where('status', whereIn: ['accepted', 'en_route', 'picked_up'])
          .get();
      
      // Get critical cases count
      final criticalQuery = await _firestore
          .collection('emergency_requests')
          .where('assignedHospitalId', isEqualTo: user.uid)
          .where('priority', isEqualTo: 'critical')
          .where('status', whereIn: ['accepted', 'en_route', 'picked_up'])
          .get();
      
      return {
        'availableBeds': hospitalData['availableBeds'] ?? 20,
        'totalBeds': hospitalData['totalBeds'] ?? 50,
        'activeAmbulances': hospitalData['activeAmbulances'] ?? 5,
        'incomingPatients': incomingQuery.docs.length,
        'criticalCases': criticalQuery.docs.length,
      };
    } catch (e) {
      print('Error getting hospital metrics: $e');
      return _getDefaultHospitalMetrics();
    }
  }
  
  // Get traffic police metrics
  Future<Map<String, dynamic>> getTrafficPoliceMetrics() async {
    try {
      // Get active emergencies in the area
      QuerySnapshot activeQuery;
      try {
        activeQuery = await _firestore
            .collection('emergency_requests')
            .where('status', whereIn: ['accepted', 'en_route', 'picked_up'])
            .get();
      } catch (e) {
        print('Error accessing emergency_requests for active emergencies: $e');
        return _getDefaultTrafficMetrics();
      }
      
      // Get clearance requests
      QuerySnapshot clearanceQuery;
      try {
        clearanceQuery = await _firestore
            .collection('route_clearances')
            .where('status', isEqualTo: 'pending')
            .get();
      } catch (e) {
        print('Error accessing route_clearances: $e');
        return _getDefaultTrafficMetrics();
      }
      
      // Get critical cases
      QuerySnapshot criticalQuery;
      try {
        criticalQuery = await _firestore
            .collection('emergency_requests')
            .where('priority', isEqualTo: 'critical')
            .where('status', whereIn: ['accepted', 'en_route', 'picked_up'])
            .get();
      } catch (e) {
        print('Error accessing emergency_requests for critical cases: $e');
        return _getDefaultTrafficMetrics();
      }
      
      // Get today's cleared routes count
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      QuerySnapshot clearedQuery;
      try {
        clearedQuery = await _firestore
            .collection('route_clearances')
            .where('status', isEqualTo: 'cleared')
            .where('clearedAt', isGreaterThanOrEqualTo: startOfDay)
            .get();
      } catch (e) {
        print('Error accessing route_clearances for cleared routes: $e');
        return _getDefaultTrafficMetrics();
      }
      
      return {
        'activeEmergencies': activeQuery.docs.length,
        'clearanceRequests': clearanceQuery.docs.length,
        'criticalCases': criticalQuery.docs.length,
        'routesCleared': clearedQuery.docs.length,
      };
    } catch (e) {
      print('Error getting traffic police metrics: $e');
      return _getDefaultTrafficMetrics();
    }
  }
  
  // Get incoming patients for hospital
  Stream<List<Map<String, dynamic>>> getIncomingPatientsStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    
    // Get all emergency requests that have been accepted by drivers
    // These represent incoming patients to hospitals
    return _firestore
        .collection('emergency_requests')
        .where('status', whereIn: ['accepted', 'en_route', 'picked_up'])
        .orderBy('acceptedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['patientName'] ?? 'Unknown Patient',
          'condition': _formatEmergencyType(data['emergencyType']),
          'ambulanceId': data['ambulanceId'] ?? 'N/A',
          'driverName': data['driverName'] ?? 'Unknown Driver',
          'driverId': data['driverId'] ?? '',
          'eta': _calculateETA(data),
          'priority': data['priority'] ?? 'medium',
          'status': data['status'] ?? 'accepted',
          'patientPhone': data['patientPhone'] ?? '',
          'pickupLocation': data['pickupLocation'] ?? 'Unknown Location',
          'hospitalLocation': data['hospitalLocation'] ?? 'Hospital',
          'acceptedAt': data['acceptedAt'],
          'createdAt': data['createdAt'],
          'patientAge': _calculateAge(data['patientAge']),
          'patientVitals': data['patientVitals'] ?? {},
        };
      }).toList();
    });
  }
  
  // Get active emergencies for traffic police
  Stream<List<Map<String, dynamic>>> getActiveEmergenciesStream() {
    return _firestore
        .collection('emergency_requests')
        .where('status', whereIn: ['accepted', 'en_route', 'picked_up'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'ambulanceId': data['ambulanceId'] ?? 'N/A',
          'patientName': data['patientName'] ?? 'Unknown Patient',
          'priority': data['priority'] ?? 'medium',
          'status': data['status'] ?? 'accepted',
          'emergencyType': data['emergencyType'] ?? 'Emergency',
          'patientAge': _formatPatientAge(data),
          'location': data['pickupLocation'] ?? 'Unknown Location',
          'sector': _formatSector(data),
          'eta': _calculateETA(data),
          'timeUpdated': _formatTimeAgo(data['updatedAt']),
          'clearanceStatus': data['clearanceStatus'] ?? 'Clearance Requested',
        };
      }).toList();
    });
  }
  
  // Helper methods
  Map<String, dynamic> _getDefaultDriverMetrics() {
    return {
      'tripsCompleted': 0,
      'kmDriven': 0,
      'earnings': 0,
      'rating': 4.5,
    };
  }
  
  Map<String, dynamic> _getDefaultHospitalMetrics() {
    return {
      'availableBeds': 20,
      'totalBeds': 50,
      'activeAmbulances': 5,
      'incomingPatients': 0,
      'criticalCases': 0,
    };
  }
  
  Map<String, dynamic> _getDefaultTrafficMetrics() {
    return {
      'activeEmergencies': 0,
      'clearanceRequests': 0,
      'criticalCases': 0,
      'routesCleared': 0,
    };
  }
  
  String _calculateETA(Map<String, dynamic> data) {
    // Simple ETA calculation based on status
    final status = data['status'] ?? 'accepted';
    switch (status) {
      case 'accepted':
        return '15 mins';
      case 'en_route':
        return '8 mins';
      case 'picked_up':
        return '12 mins';
      default:
        return '10 mins';
    }
  }
  
  String _formatEmergencyType(dynamic emergencyType) {
    if (emergencyType == null) return 'Emergency';
    String type = emergencyType.toString();
    // Convert from enum format to readable format
    switch (type) {
      case 'heart_attack':
        return 'Acute Myocardial Infarction';
      case 'stroke':
        return 'Stroke Emergency';
      case 'accident':
        return 'Accident Victim';
      case 'respiratory_distress':
        return 'Respiratory Distress';
      case 'cardiac_arrest':
        return 'Cardiac Arrest';
      case 'trauma':
        return 'Trauma Emergency';
      case 'poisoning':
        return 'Poisoning Emergency';
      case 'burns':
        return 'Burn Injury';
      case 'seizure':
        return 'Seizure Emergency';
      case 'allergic_reaction':
        return 'Allergic Reaction';
      default:
        return type.replaceAll('_', ' ').split(' ').map((word) => 
          word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word
        ).join(' ');
    }
  }
  
  String _calculateAge(dynamic ageData) {
    if (ageData == null) return '58 years'; // Default for demo
    if (ageData is int) return '$ageData years';
    if (ageData is String) return ageData;
    return '58 years';
  }
  
  String _formatPatientAge(Map<String, dynamic> data) {
    final age = data['patientAge'];
    final gender = data['patientGender'] ?? 'Unknown';
    if (age != null) {
      return '$gender, $age years';
    }
    return '$gender, Age unknown';
  }
  
  String _formatSector(Map<String, dynamic> data) {
    final pickup = data['pickupLocation'] ?? 'Unknown';
    final hospital = data['hospitalName'] ?? 'Hospital';
    return '$pickup → $hospital';
  }
  
  String _formatTimeAgo(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    
    try {
      DateTime dateTime;
      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } else if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else {
        return 'Unknown';
      }
      
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hr ago';
      } else {
        return '${difference.inDays} days ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
