import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/patient_model.dart';
import 'patient_firestore_service.dart';

class UserService extends GetxController {
  static UserService get instance => Get.find();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PatientFirestoreService _firestoreService = PatientFirestoreService();
  
  // Patient data observables
  final Rx<PatientModel?> _currentPatient = Rx<PatientModel?>(null);
  final RxBool _isLoggedIn = false.obs;
  
  // Stream subscription for real-time updates
  StreamSubscription<PatientModel?>? _patientDataSubscription;
  
  // App preferences
  final RxBool _notificationsEnabled = true.obs;
  final RxString _selectedLanguage = 'English'.obs;
  final RxString _selectedTheme = 'Light mode'.obs;

  // Getters
  PatientModel? get currentPatient => _currentPatient.value;
  bool get isLoggedIn => _isLoggedIn.value;
  User? get firebaseUser => _auth.currentUser;
  
  // Patient info getters
  String get userId => _currentPatient.value?.id ?? '';
  String get userName => _currentPatient.value?.name ?? '';
  String get userEmail => _currentPatient.value?.email ?? '';
  String get userPhone => _currentPatient.value?.phone ?? '';
  String get userAddress => _currentPatient.value?.address ?? '';
  String get bloodGroup => _currentPatient.value?.bloodGroup ?? '';
  String get medicalConditions => _currentPatient.value?.medicalConditions ?? '';
  String get allergies => _currentPatient.value?.allergies ?? '';
  String get medications => _currentPatient.value?.medications ?? '';
  String get emergencyContactName => _currentPatient.value?.emergencyContactName ?? '';
  String get emergencyContactPhone => _currentPatient.value?.emergencyContactPhone ?? '';
  String get emergencyContactRelation => _currentPatient.value?.emergencyContactRelation ?? '';
  DateTime? get dateOfBirth => _currentPatient.value?.dateOfBirth;
  String get gender => _currentPatient.value?.gender ?? '';
  int get age => _currentPatient.value?.age ?? 0;
  String get userLocation => _currentPatient.value?.address ?? 'Location not available';
  
  bool get notificationsEnabled => _notificationsEnabled.value;
  String get selectedLanguage => _selectedLanguage.value;
  String get selectedTheme => _selectedTheme.value;

  @override
  void onInit() {
    super.onInit();
    _initializeAuthListener();
    loadUserData();
  }
  
  @override
  void onClose() {
    _patientDataSubscription?.cancel();
    super.onClose();
  }

  // Initialize Firebase Auth listener
  void _initializeAuthListener() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _setupPatientDataStream(user.uid);
        _isLoggedIn.value = true;
      } else {
        _patientDataSubscription?.cancel();
        _currentPatient.value = null;
        _isLoggedIn.value = false;
      }
    });
  }

  // Setup real-time patient data stream
  Future<void> _setupPatientDataStream(String userId) async {
    try {
      print('UserService: Setting up real-time data stream for user: $userId');
      
      // Cancel existing subscription
      _patientDataSubscription?.cancel();
      
      // Setup new stream subscription for real-time updates
      _patientDataSubscription = _firestoreService.streamPatientData(userId).listen(
        (PatientModel? patient) {
          if (patient != null) {
            print('UserService: Real-time patient data updated: ${patient.name}');
            _currentPatient.value = patient;
          } else {
            print('UserService: No patient data found for user: $userId');
            _currentPatient.value = null;
          }
        },
        onError: (error) {
          print('UserService: Error in patient data stream: $error');
          // Fallback to one-time load if stream fails
          _loadPatientDataFallback(userId);
        },
      );
    } catch (e) {
      print('UserService: Error setting up patient data stream: $e');
      // Fallback to one-time load
      await _loadPatientDataFallback(userId);
    }
  }
  
  // Fallback method for loading patient data (one-time)
  Future<void> _loadPatientDataFallback(String userId) async {
    try {
      print('UserService: Loading patient data (fallback) for user: $userId');
      final patient = await _firestoreService.getPatientData(userId);
      if (patient != null) {
        print('UserService: Patient data loaded successfully: ${patient.name}');
        _currentPatient.value = patient;
      } else {
        print('UserService: No patient data found for user: $userId');
        _currentPatient.value = null;
      }
    } catch (e) {
      print('UserService: Error loading patient data: $e');
      _currentPatient.value = null;
    }
  }

  // Load user data from local storage
  Future<void> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _notificationsEnabled.value = prefs.getBool('notifications_enabled') ?? true;
      _selectedLanguage.value = prefs.getString('selected_language') ?? 'English';
      _selectedTheme.value = prefs.getString('selected_theme') ?? 'Light mode';
      
      // Check if user is logged in with Firebase
      final user = _auth.currentUser;
      if (user != null) {
        await _setupPatientDataStream(user.uid);
        _isLoggedIn.value = true;
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Save user preferences to local storage
  Future<void> saveUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('notifications_enabled', _notificationsEnabled.value);
      await prefs.setString('selected_language', _selectedLanguage.value);
      await prefs.setString('selected_theme', _selectedTheme.value);
    } catch (e) {
      print('Error saving user preferences: $e');
    }
  }

  // Update patient profile information
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? profileImageUrl,
  }) async {
    if (_currentPatient.value == null) return;
    
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (address != null) updates['address'] = address;
    if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;
    
    if (updates.isNotEmpty) {
      await _firestoreService.updateCurrentPatientData(updates);
      // Real-time stream will automatically update the data
      print('UserService: Profile updated, real-time stream will reflect changes');
    }
  }

  // Update medical information
  Future<void> updateMedicalInfo({
    String? bloodGroup,
    String? medicalConditions,
    String? allergies,
    String? medications,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
  }) async {
    if (_currentPatient.value == null) return;
    
    final updates = <String, dynamic>{};
    if (bloodGroup != null) updates['bloodGroup'] = bloodGroup;
    if (medicalConditions != null) updates['medicalConditions'] = medicalConditions;
    if (allergies != null) updates['allergies'] = allergies;
    if (medications != null) updates['medications'] = medications;
    if (emergencyContactName != null) updates['emergencyContactName'] = emergencyContactName;
    if (emergencyContactPhone != null) updates['emergencyContactPhone'] = emergencyContactPhone;
    if (emergencyContactRelation != null) updates['emergencyContactRelation'] = emergencyContactRelation;
    
    if (updates.isNotEmpty) {
      await _firestoreService.updateCurrentPatientData(updates);
      // Real-time stream will automatically update the data
      print('UserService: Medical info updated, real-time stream will reflect changes');
    }
  }

  // Update app preferences
  Future<void> updatePreferences({
    bool? notificationsEnabled,
    String? selectedLanguage,
    String? selectedTheme,
  }) async {
    if (notificationsEnabled != null) _notificationsEnabled.value = notificationsEnabled;
    if (selectedLanguage != null) _selectedLanguage.value = selectedLanguage;
    if (selectedTheme != null) _selectedTheme.value = selectedTheme;
    
    await saveUserPreferences();
  }

  // Login user with Firebase
  Future<void> loginUser(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        await _setupPatientDataStream(userCredential.user!.uid);
        _isLoggedIn.value = true;
      }
    } on FirebaseAuthException catch (e) {
      // Re-throw FirebaseAuthException to be handled by the UI
      rethrow;
    } catch (e) {
      // Handle PigeonUserDetails serialization error by checking auth state
      if (e.toString().contains('PigeonUserDetails') || 
          e.toString().contains('List<Object?>')) {
        
        // Wait a moment and check if user is actually authenticated
        await Future.delayed(const Duration(milliseconds: 500));
        final currentUser = _auth.currentUser;
        
        if (currentUser != null) {
          // User is authenticated despite the error, load their data
          try {
            await _setupPatientDataStream(currentUser.uid);
            _isLoggedIn.value = true;
            return; // Success despite the error
          } catch (dataError) {
            throw Exception('Login successful but failed to load user data. Please try again.');
          }
        } else {
          throw Exception('Authentication service error. Please restart the app and try again.');
        }
      }
      
      // Handle any other exceptions
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Logout user
  Future<void> logoutUser() async {
    // Cancel real-time subscription
    _patientDataSubscription?.cancel();
    
    await _auth.signOut();
    _currentPatient.value = null;
    _isLoggedIn.value = false;
    
    // Clear preferences but keep app settings
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }

  // Get greeting based on time
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  // Refresh patient data
  Future<void> refreshPatientData() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Re-setup the stream to get fresh data
      await _setupPatientDataStream(user.uid);
    }
  }
  
  // Force reload patient data (one-time)
  Future<void> forceReloadPatientData() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _loadPatientDataFallback(user.uid);
    }
  }
}
