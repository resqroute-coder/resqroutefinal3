class ApiConfig {
  // Google Maps API Key - Configured with your actual API key
  static const String googleMapsApiKey = 'AIzaSyDb3k1AXV_cwvf-Hkron_kddeUM0fUSJdg';
  
  // Firebase configuration (if needed for other APIs)
  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: '',
  );
  
  // Other API configurations can be added here
  static const String placesApiKey = 'AIzaSyDb3k1AXV_cwvf-Hkron_kddeUM0fUSJdg';
  
  static const String directionsApiKey = 'AIzaSyDb3k1AXV_cwvf-Hkron_kddeUM0fUSJdg';
  
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
