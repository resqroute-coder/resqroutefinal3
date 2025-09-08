import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/patient_model.dart';
import '../constants/app_constants.dart';

class PatientFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference for users (patients are stored in users collection)
  CollectionReference get _usersCollection => 
      _firestore.collection('users');

  // Save patient data to Firestore
  Future<void> savePatientData(PatientModel patient) async {
    try {
      print('PatientFirestoreService: Saving to /users/${patient.id}');
      print('Data to save: ${patient.toJson()}');
      await _usersCollection.doc(patient.id).set(patient.toJson());
      print('PatientFirestoreService: Data saved successfully');
    } catch (e) {
      print('PatientFirestoreService: Error saving data: $e');
      throw Exception('Failed to save patient data: ${e.toString()}');
    }
  }

  // Get patient data from Firestore
  Future<PatientModel?> getPatientData(String patientId) async {
    try {
      final doc = await _usersCollection.doc(patientId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data();
        if (data is Map<String, dynamic>) {
          return PatientModel.fromJson(data);
        } else {
          print('Invalid data format for patient $patientId: ${data.runtimeType}');
          return null;
        }
      }
      return null;
    } catch (e) {
      print('Error getting patient data: $e');
      throw Exception('Failed to get patient data: ${e.toString()}');
    }
  }

  // Get current patient data
  Future<PatientModel?> getCurrentPatientData() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await getPatientData(user.uid);
    }
    return null;
  }

  // Update patient data
  Future<void> updatePatientData(String patientId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = DateTime.now().toIso8601String();
      await _usersCollection.doc(patientId).update(updates);
    } catch (e) {
      throw Exception('Failed to update patient data: ${e.toString()}');
    }
  }

  // Update current patient data
  Future<void> updateCurrentPatientData(Map<String, dynamic> updates) async {
    final user = _auth.currentUser;
    if (user != null) {
      await updatePatientData(user.uid, updates);
    } else {
      throw Exception('No authenticated user found');
    }
  }

  // Delete patient data
  Future<void> deletePatientData(String patientId) async {
    try {
      await _usersCollection.doc(patientId).delete();
    } catch (e) {
      throw Exception('Failed to delete patient data: ${e.toString()}');
    }
  }

  // Check if patient exists
  Future<bool> patientExists(String patientId) async {
    try {
      final doc = await _usersCollection.doc(patientId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Get patient by email
  Future<PatientModel?> getPatientByEmail(String email) async {
    try {
      final querySnapshot = await _usersCollection
          .where('email', isEqualTo: email)
          .where('role', isEqualTo: 'patient')
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        return PatientModel.fromJson(
          querySnapshot.docs.first.data() as Map<String, dynamic>
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get patient by email: ${e.toString()}');
    }
  }

  // Stream patient data for real-time updates
  Stream<PatientModel?> streamPatientData(String patientId) {
    return _usersCollection.doc(patientId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return PatientModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Stream current patient data
  Stream<PatientModel?> streamCurrentPatientData() {
    final user = _auth.currentUser;
    if (user != null) {
      return streamPatientData(user.uid);
    }
    return Stream.value(null);
  }
}
