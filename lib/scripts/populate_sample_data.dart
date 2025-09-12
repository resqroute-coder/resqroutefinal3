import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Sample data population script for testing ambulance tracking
/// Run this script to populate Firestore with sample ambulance locations and emergency data
class SampleDataPopulator {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> populateAmbulanceLocations() async {
    print('Populating sample ambulance locations...');
    
    final ambulances = [
      {
        'ambulanceId': 'AMB_001',
        'driverId': 'driver_001',
        'latitude': 19.0760,
        'longitude': 72.8777,
        'status': 'active',
        'emergencyRequestId': 'EMR_001',
        'destination': 'Apollo Hospital, Bandra',
        'speed': 45.5,
        'heading': 90.0,
        'lastUpdated': Timestamp.now(),
        'timestamp': Timestamp.now(),
        'assignedHospital': 'apollo_bandra',
      },
      {
        'ambulanceId': 'AMB_002',
        'driverId': 'driver_002',
        'latitude': 19.0596,
        'longitude': 72.8295,
        'status': 'enRoute',
        'emergencyRequestId': 'EMR_002',
        'destination': 'Lilavati Hospital',
        'speed': 38.2,
        'heading': 45.0,
        'lastUpdated': Timestamp.now(),
        'timestamp': Timestamp.now(),
        'assignedHospital': 'lilavati_bandra',
      },
      {
        'ambulanceId': 'AMB_003',
        'driverId': 'driver_003',
        'latitude': 19.0728,
        'longitude': 72.8826,
        'status': 'atPickup',
        'emergencyRequestId': 'EMR_003',
        'destination': 'Fortis Hospital',
        'speed': 0.0,
        'heading': 0.0,
        'lastUpdated': Timestamp.now(),
        'timestamp': Timestamp.now(),
        'assignedHospital': 'fortis_mulund',
      },
      {
        'ambulanceId': 'AMB_004',
        'driverId': 'driver_004',
        'latitude': 19.1136,
        'longitude': 72.8697,
        'status': 'toHospital',
        'emergencyRequestId': 'EMR_004',
        'destination': 'Kokilaben Hospital',
        'speed': 52.1,
        'heading': 180.0,
        'lastUpdated': Timestamp.now(),
        'timestamp': Timestamp.now(),
        'assignedHospital': 'kokilaben_andheri',
      },
      {
        'ambulanceId': 'AMB_005',
        'driverId': 'driver_005',
        'latitude': 18.9667,
        'longitude': 72.8081,
        'status': 'idle',
        'speed': 0.0,
        'heading': 0.0,
        'lastUpdated': Timestamp.now(),
        'timestamp': Timestamp.now(),
        'assignedHospital': 'breach_candy',
      },
    ];

    for (var ambulance in ambulances) {
      await _firestore
          .collection('ambulance_locations')
          .doc(ambulance['ambulanceId'] as String)
          .set(ambulance);
      
      print('Added ambulance: ${ambulance['ambulanceId']}');
    }
    
    print('✅ Ambulance locations populated successfully!');
  }

  static Future<void> populateAmbulanceRoutes() async {
    print('Populating sample ambulance routes...');
    
    final routes = [
      {
        'ambulanceId': 'AMB_001',
        'emergencyRequestId': 'EMR_001',
        'pickupLocation': {
          'latitude': 19.0760,
          'longitude': 72.8777,
          'address': 'Bandra West, Mumbai'
        },
        'hospitalLocation': {
          'latitude': 19.0728,
          'longitude': 72.8826,
          'address': 'Apollo Hospital, Bandra'
        },
        'routePoints': [
          {'latitude': 19.0760, 'longitude': 72.8777},
          {'latitude': 19.0750, 'longitude': 72.8800},
          {'latitude': 19.0740, 'longitude': 72.8815},
          {'latitude': 19.0728, 'longitude': 72.8826},
        ],
        'estimatedDuration': 12.5, // minutes
        'estimatedDistance': 2.3, // km
        'updatedAt': Timestamp.now(),
      },
      {
        'ambulanceId': 'AMB_002',
        'emergencyRequestId': 'EMR_002',
        'pickupLocation': {
          'latitude': 19.0596,
          'longitude': 72.8295,
          'address': 'Khar West, Mumbai'
        },
        'hospitalLocation': {
          'latitude': 19.0520,
          'longitude': 72.8302,
          'address': 'Lilavati Hospital'
        },
        'routePoints': [
          {'latitude': 19.0596, 'longitude': 72.8295},
          {'latitude': 19.0580, 'longitude': 72.8298},
          {'latitude': 19.0550, 'longitude': 72.8300},
          {'latitude': 19.0520, 'longitude': 72.8302},
        ],
        'estimatedDuration': 8.0,
        'estimatedDistance': 1.2,
        'updatedAt': Timestamp.now(),
      },
    ];

    for (var route in routes) {
      await _firestore
          .collection('ambulance_routes')
          .doc(route['ambulanceId'] as String)
          .set(route);
      
      print('Added route for: ${route['ambulanceId']}');
    }
    
    print('✅ Ambulance routes populated successfully!');
  }

  static Future<void> populateSampleEmergencies() async {
    print('Populating sample emergency requests...');
    
    final emergencies = [
      {
        'id': 'EMR_001',
        'patientId': 'patient_001',
        'patientName': 'Rajesh Kumar',
        'patientPhone': '+91 9876543210',
        'driverId': 'driver_001',
        'driverName': 'Amit Singh',
        'ambulanceId': 'AMB_001',
        'status': 'accepted',
        'emergencyType': 'cardiac',
        'description': 'Chest pain and difficulty breathing',
        'pickupLocation': 'Bandra West, Mumbai, Maharashtra',
        'hospitalLocation': 'Apollo Hospital, Bandra West, Mumbai',
        'priority': 'critical',
        'createdAt': Timestamp.now(),
        'acceptedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'severity': 'critical',
        'location': {
          'pickup': 'Bandra West, Mumbai, Maharashtra',
          'hospital': 'Apollo Hospital, Bandra West, Mumbai',
        },
      },
      {
        'id': 'EMR_002',
        'patientId': 'patient_002',
        'patientName': 'Priya Sharma',
        'patientPhone': '+91 9876543211',
        'driverId': 'driver_002',
        'driverName': 'Vikram Patel',
        'ambulanceId': 'AMB_002',
        'status': 'enRoute',
        'emergencyType': 'accident',
        'description': 'Road accident with minor injuries',
        'pickupLocation': 'Khar West, Mumbai, Maharashtra',
        'hospitalLocation': 'Lilavati Hospital, Bandra West, Mumbai',
        'priority': 'high',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 15))),
        'acceptedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 12))),
        'enRouteAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 8))),
        'updatedAt': Timestamp.now(),
        'severity': 'high',
        'location': {
          'pickup': 'Khar West, Mumbai, Maharashtra',
          'hospital': 'Lilavati Hospital, Bandra West, Mumbai',
        },
      },
      {
        'id': 'EMR_003',
        'patientId': 'patient_003',
        'patientName': 'Mohammed Ali',
        'patientPhone': '+91 9876543212',
        'driverId': 'driver_003',
        'driverName': 'Suresh Reddy',
        'ambulanceId': 'AMB_003',
        'status': 'pickedUp',
        'emergencyType': 'respiratory',
        'description': 'Severe asthma attack',
        'pickupLocation': 'Andheri East, Mumbai, Maharashtra',
        'hospitalLocation': 'Fortis Hospital, Mulund, Mumbai',
        'priority': 'high',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 25))),
        'acceptedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 22))),
        'enRouteAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 18))),
        'pickedUpAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 5))),
        'updatedAt': Timestamp.now(),
        'severity': 'high',
        'location': {
          'pickup': 'Andheri East, Mumbai, Maharashtra',
          'hospital': 'Fortis Hospital, Mulund, Mumbai',
        },
      },
    ];

    for (var emergency in emergencies) {
      await _firestore
          .collection('emergency_requests')
          .doc(emergency['id'] as String)
          .set(emergency);
      
      print('Added emergency: ${emergency['id']} - ${emergency['patientName']}');
    }
    
    print('✅ Emergency requests populated successfully!');
  }

  static Future<void> populateHospitalData() async {
    print('Populating hospital data...');
    
    final hospitals = [
      {
        'id': 'apollo_bandra',
        'name': 'Apollo Hospital',
        'location': {
          'latitude': 19.0728,
          'longitude': 72.8826,
        },
        'address': 'Bandra West, Mumbai, Maharashtra',
        'phone': '+91 22 2692 7777',
        'totalBeds': 150,
        'availableBeds': 23,
        'emergencyBeds': 12,
        'availableEmergencyBeds': 3,
        'departments': ['Cardiology', 'Emergency', 'ICU', 'Surgery'],
        'ambulanceCapacity': 8,
        'activeAmbulances': 3,
        'lastUpdated': Timestamp.now(),
      },
      {
        'id': 'lilavati_bandra',
        'name': 'Lilavati Hospital',
        'location': {
          'latitude': 19.0520,
          'longitude': 72.8302,
        },
        'address': 'Bandra West, Mumbai, Maharashtra',
        'phone': '+91 22 2675 1000',
        'totalBeds': 200,
        'availableBeds': 45,
        'emergencyBeds': 15,
        'availableEmergencyBeds': 7,
        'departments': ['Cardiology', 'Neurology', 'Emergency', 'ICU'],
        'ambulanceCapacity': 10,
        'activeAmbulances': 4,
        'lastUpdated': Timestamp.now(),
      },
    ];

    for (var hospital in hospitals) {
      await _firestore
          .collection('hospitals')
          .doc(hospital['id'] as String)
          .set(hospital);
      
      print('Added hospital: ${hospital['name']}');
    }
    
    print('✅ Hospital data populated successfully!');
  }

  static Future<void> populateAllSampleData() async {
    try {
      print('🚀 Starting sample data population...\n');
      
      await populateAmbulanceLocations();
      print('');
      
      await populateAmbulanceRoutes();
      print('');
      
      await populateSampleEmergencies();
      print('');
      
      await populateHospitalData();
      print('');
      
      print('🎉 All sample data populated successfully!');
      print('You can now test the ambulance tracking features in the app.');
      
    } catch (e) {
      print('❌ Error populating sample data: $e');
    }
  }
}

// Uncomment and run this function to populate sample data
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   await SampleDataPopulator.populateAllSampleData();
// }
