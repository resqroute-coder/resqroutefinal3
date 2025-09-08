class AppConstants {
  // App Info
  static const String appName = 'ResQRoute';
  static const String appVersion = '1.0.0';
  
  // Animation Duration
  static const int splashDuration = 5000; // 5 seconds
  
  // User Roles
  static const String rolePatient = 'patient';
  static const String roleHospital = 'hospital';
  static const String roleDriver = 'driver';
  static const String rolePolice = 'police';
  
  // Authentication Types
  static const String authTypeUser = 'user';
  static const String authTypeProfessional = 'professional';
  
  // Emergency Status
  static const String emergencyPending = 'pending';
  static const String emergencyAssigned = 'assigned';
  static const String emergencyEnRoute = 'en_route';
  static const String emergencyPickedUp = 'picked_up';
  static const String emergencyCompleted = 'completed';
  static const String emergencyCancelled = 'cancelled';
  
  // Shared Preferences Keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserRole = 'user_role';
  static const String keyAuthType = 'auth_type';
  static const String keyUserId = 'user_id';
  static const String keyUserData = 'user_data';
  
  // Firebase Collections
  static const String collectionUsers = 'users';
  static const String collectionHospitals = 'hospitals';
  static const String collectionDrivers = 'drivers';
  static const String collectionPolice = 'police';
  static const String collectionEmergencies = 'emergencies';
  static const String collectionAmbulances = 'ambulances';
}
