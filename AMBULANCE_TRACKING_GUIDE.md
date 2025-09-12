# ResQRoute Ambulance Tracking System

## Overview
The ResQRoute app now includes comprehensive real-time ambulance tracking with Google Maps integration. This system allows hospital staff and traffic police to monitor active ambulances, view their routes, and coordinate emergency responses effectively.

## Key Features Implemented

### 🚑 Real-Time Ambulance Tracking
- Live location updates every 10 seconds
- Status-based color coding for easy identification
- Speed and heading information
- Interactive ambulance details

### 🗺️ Google Maps Integration
- Interactive maps with custom markers
- Route visualization with polylines
- Emergency location markers
- Hospital location markers
- Full-screen map views

### 👥 Multi-User Dashboard Integration
- **Hospital Dashboard**: Track incoming ambulances
- **Police Dashboard**: Monitor for route clearance
- **Driver Dashboard**: Location sharing and navigation

## Emergency Creation Flow

### Patient Creates Emergency
1. Patient opens `Emergency Request Screen`
2. Selects emergency type (Cardiac, Accident, Breathing, etc.)
3. Sets severity level (Critical, High, Medium)
4. Provides patient information and location
5. Emergency stored in `emergency_requests` collection

### Visibility Matrix
| User Type | Can See | Can Do |
|-----------|---------|--------|
| **Patients** | Own requests | Create, cancel requests |
| **Drivers** | Pending + assigned requests | Accept, update status |
| **Hospital Staff** | All requests | View incoming patients |
| **Traffic Police** | All requests | Create route clearances |

## Ambulance Status Types

### Status Color Coding
- 🟢 **Green**: `active`, `enRoute` - Ambulance is responding
- 🟠 **Orange**: `atPickup` - Ambulance at pickup location
- 🔵 **Blue**: `toHospital` - Transporting patient to hospital
- ⚪ **Grey**: `idle` - Ambulance available
- 🔴 **Red**: `maintenance` - Ambulance out of service

## Database Collections

### `ambulance_locations`
```javascript
{
  ambulanceId: "AMB_001",
  driverId: "driver_001",
  latitude: 19.0760,
  longitude: 72.8777,
  status: "active",
  emergencyRequestId: "EMR_001",
  destination: "Apollo Hospital",
  speed: 45.5,
  heading: 90.0,
  lastUpdated: Timestamp,
  assignedHospital: "apollo_bandra"
}
```

### `ambulance_routes`
```javascript
{
  ambulanceId: "AMB_001",
  emergencyRequestId: "EMR_001",
  pickupLocation: {
    latitude: 19.0760,
    longitude: 72.8777,
    address: "Bandra West, Mumbai"
  },
  hospitalLocation: {
    latitude: 19.0728,
    longitude: 72.8826,
    address: "Apollo Hospital"
  },
  routePoints: [
    {latitude: 19.0760, longitude: 72.8777},
    {latitude: 19.0728, longitude: 72.8826}
  ],
  estimatedDuration: 12.5,
  estimatedDistance: 2.3
}
```

### `emergency_requests`
```javascript
{
  id: "EMR_001",
  patientId: "patient_001",
  patientName: "John Doe",
  driverId: "driver_001",
  ambulanceId: "AMB_001",
  status: "accepted",
  emergencyType: "cardiac",
  pickupLocation: "Bandra West, Mumbai",
  hospitalLocation: "Apollo Hospital",
  priority: "critical",
  createdAt: Timestamp,
  acceptedAt: Timestamp
}
```

## How to Test the System

### 1. Populate Sample Data
Run the sample data script to add test ambulances and emergencies:

```dart
// In lib/scripts/populate_sample_data.dart
// Uncomment the main function and run:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SampleDataPopulator.populateAllSampleData();
}
```

### 2. Test Hospital Dashboard
1. Login as hospital staff
2. Navigate to Hospital Dashboard
3. View the "Live Ambulance Tracking" section
4. Click ambulance markers to see details
5. Use filter controls to show specific statuses
6. Click fullscreen icon for detailed map view

### 3. Test Police Dashboard  
1. Login as traffic police
2. Navigate to Traffic Police Dashboard
3. Click "Live Tracking" tab
4. View real-time ambulance positions
5. Click map locations to create route clearances
6. Monitor emergency situations for coordination

### 4. Test Real-Time Updates
1. Open multiple dashboard instances
2. Simulate ambulance movement by updating Firestore data
3. Observe real-time marker updates across all dashboards
4. Test status changes and color coding

## API Configuration

### Google Maps Setup
The app uses your provided API key: `nacBdt87Xj6ZDTHU3Yaw5XFASEcGaSCL`

Ensure this key has the following APIs enabled:
- Maps SDK for Android
- Maps SDK for iOS  
- Maps JavaScript API
- Places API
- Directions API
- Geocoding API

## Security Rules

### Firestore Permissions
```javascript
// ambulance_locations - All users can read, only drivers can update
match /ambulance_locations/{ambulanceId} {
  allow read: if isAuthenticated();
  allow create, update: if isAuthenticated() && 
    (isDriver() || request.resource.data.driverId == request.auth.uid);
}

// ambulance_routes - All users can read, professionals can update  
match /ambulance_routes/{ambulanceId} {
  allow read: if isAuthenticated();
  allow create, update: if isAuthenticated() && 
    (isDriver() || isProfessional());
}
```

## Map Widget Usage

### Hospital Dashboard Integration
```dart
const AmbulanceMapWidget(
  userType: 'hospital',
  height: 250,
  showControls: true,
)
```

### Police Dashboard Integration
```dart
const AmbulanceMapWidget(
  userType: 'police', 
  height: double.infinity,
  showControls: true,
)
```

## Services Architecture

### AmbulanceLocationService
- Manages real-time ambulance locations
- Provides streams for live updates
- Handles location updates from drivers
- Calculates estimated arrival times

### MapsService  
- Google Maps integration
- Marker management and updates
- Route visualization
- Interactive map controls

### EmergencyRequestService
- Emergency request management
- Status tracking and updates
- Patient and driver coordination

## Troubleshooting

### Common Issues

1. **Map not loading**
   - Check Google Maps API key configuration
   - Verify API permissions in Google Cloud Console
   - Check network connectivity

2. **Ambulances not showing**
   - Ensure sample data is populated
   - Check Firestore security rules
   - Verify service initialization in main.dart

3. **Real-time updates not working**
   - Check Firestore connection
   - Verify stream subscriptions
   - Check authentication status

### Debug Steps
1. Check browser console for API errors
2. Verify Firestore data in Firebase Console
3. Test with sample data first
4. Check service initialization order

## Performance Considerations

### Optimization Features
- Efficient marker updates (only changed ambulances)
- Stream-based real-time updates
- Lazy loading of route data
- Cached hospital locations
- Debounced location updates

### Best Practices
- Limit map zoom levels for performance
- Use appropriate marker clustering for many ambulances
- Implement proper error handling for network issues
- Cache frequently accessed data

## Future Enhancements

### Potential Improvements
- Turn-by-turn navigation for drivers
- Traffic-aware route optimization
- Push notifications for critical updates
- Historical tracking and analytics
- Integration with hospital bed management
- Automated route clearance requests

This comprehensive ambulance tracking system provides the core functionality needed for coordinating emergency responses across hospital and police dashboards with real-time visibility and interactive map controls.
