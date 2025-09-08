import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  // Get user role
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyUserRole);
  }

  // Get auth type
  Future<String?> getAuthType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyAuthType);
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailPassword(
    String email, 
    String password, 
    String role, 
    String authType
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Get user data from Firestore
        final userDoc = await _firestore
            .collection(_getCollectionName(role))
            .doc(credential.user!.uid)
            .get();

        if (userDoc.exists) {
          final userData = UserModel.fromJson({
            'id': credential.user!.uid,
            ...userDoc.data()!,
          });

          // Save login state
          await _saveLoginState(userData, authType);
          return userData;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Register new user
  Future<UserModel?> registerUser({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
    required String authType,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final now = DateTime.now();
        final userData = UserModel(
          id: credential.user!.uid,
          email: email,
          name: name,
          phone: phone,
          role: role,
          authType: authType,
          createdAt: now,
          updatedAt: now,
          additionalData: additionalData,
        );

        // Save user data to Firestore
        await _firestore
            .collection(_getCollectionName(role))
            .doc(credential.user!.uid)
            .set(userData.toJson());

        // Save login state
        await _saveLoginState(userData, authType);
        return userData;
      }
      return null;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Save login state to SharedPreferences
  Future<void> _saveLoginState(UserModel user, String authType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
    await prefs.setString(AppConstants.keyUserRole, user.role);
    await prefs.setString(AppConstants.keyAuthType, authType);
    await prefs.setString(AppConstants.keyUserId, user.id);
  }

  // Get collection name based on role
  String _getCollectionName(String role) {
    switch (role) {
      case AppConstants.rolePatient:
        return AppConstants.collectionUsers;
      case AppConstants.roleHospital:
        return AppConstants.collectionHospitals;
      case AppConstants.roleDriver:
        return AppConstants.collectionDrivers;
      case AppConstants.rolePolice:
        return AppConstants.collectionPolice;
      default:
        return AppConstants.collectionUsers;
    }
  }
}
