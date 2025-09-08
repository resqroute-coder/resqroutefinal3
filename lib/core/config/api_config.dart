class ApiConfig {
  // Google Maps API Key - Replace with your actual API key
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'YOUR_GOOGLE_MAPS_API_KEY_HERE',
  );
  
  // Firebase configuration (if needed for other APIs)
  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: '',
  );
  
  // Other API configurations can be added here
  static const String placesApiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
    defaultValue: 'YOUR_GOOGLE_PLACES_API_KEY_HERE',
  );
  
  static const String directionsApiKey = String.fromEnvironment(
    'GOOGLE_DIRECTIONS_API_KEY', 
    defaultValue: 'YOUR_GOOGLE_DIRECTIONS_API_KEY_HERE',
  );
  
  // Validation methods
  static bool get isGoogleMapsConfigured => 
      googleMapsApiKey != 'YOUR_GOOGLE_MAPS_API_KEY_HERE' && 
      googleMapsApiKey.isNotEmpty;
  
  static bool get isPlacesConfigured => 
      placesApiKey != 'YOUR_GOOGLE_PLACES_API_KEY_HERE' && 
      placesApiKey.isNotEmpty;
  
  static bool get isDirectionsConfigured => 
      directionsApiKey != 'YOUR_GOOGLE_DIRECTIONS_API_KEY_HERE' && 
      directionsApiKey.isNotEmpty;
  
  // Debug method to check configuration status
  static Map<String, bool> getConfigurationStatus() {
    return {
      'Google Maps': isGoogleMapsConfigured,
      'Google Places': isPlacesConfigured,
      'Google Directions': isDirectionsConfigured,
    };
  }
}
