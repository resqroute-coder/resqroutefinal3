# ResQRoute Firestore Database Structure

## Overview
This document outlines the complete Firestore database structure for the ResQRoute emergency response app, designed to store all user data and activities in organized collections.

## Database Collections

### 1. Users Collection (`/users/{userId}`)
**Purpose**: Store all user profiles, authentication data, and personal information

**Document Structure**:
```json
{
  "userId": "string (auto-generated)",
  "role": "patient | driver | hospital_staff | traffic_police",
  "email": "string",
  "phone": "string",
  "fullName": "string",
  "profilePicture": "string (URL)",
  "isActive": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  
  // Role-specific fields
  // For Patients:
  "dateOfBirth": "timestamp",
  "bloodGroup": "string",
  "address": {
    "street": "string",
    "city": "string",
    "state": "string",
    "pincode": "string",
    "coordinates": {
      "latitude": "number",
      "longitude": "number"
    }
  },
  "insuranceInfo": {
    "provider": "string",
    "policyNumber": "string",
    "validUntil": "timestamp"
  },
  
  // For Drivers:
  "employeeId": "string",
  "licenseNumber": "string",
  "licenseType": "string",
  "experience": "number",
  "ambulanceId": "string",
  "isOnDuty": "boolean",
  "currentLocation": {
    "latitude": "number",
    "longitude": "number",
    "timestamp": "timestamp"
  },
  
  // For Hospital Staff:
  "hospitalId": "string",
  "department": "string",
  "designation": "string",
  "employeeId": "string",
  
  // For Traffic Police:
  "badgeNumber": "string",
  "rank": "string",
  "stationName": "string",
  "sector": "string",
  "shift": "string"
}
```

**Subcollections**:

#### `/users/{userId}/activities/{activityId}`
```json
{
  "activityId": "string",
  "type": "emergency_request | ambulance_tracking | route_clearance | hospital_admission",
  "description": "string",
  "timestamp": "timestamp",
  "status": "string",
  "relatedDocuments": {
    "emergencyId": "string",
    "ambulanceId": "string",
    "hospitalId": "string"
  },
  "metadata": "object"
}
```

#### `/users/{userId}/notifications/{notificationId}`
```json
{
  "notificationId": "string",
  "title": "string",
  "message": "string",
  "type": "emergency | ambulance | update | warning | info",
  "isRead": "boolean",
  "timestamp": "timestamp",
  "data": "object",
  "senderId": "string"
}
```

#### `/users/{userId}/emergencyContacts/{contactId}`
```json
{
  "contactId": "string",
  "name": "string",
  "relationship": "string",
  "phone": "string",
  "email": "string",
  "isPrimary": "boolean"
}
```

#### `/users/{userId}/medicalInfo/{infoId}`
```json
{
  "infoId": "string",
  "allergies": "array of strings",
  "medications": "array of objects",
  "medicalConditions": "array of strings",
  "emergencyMedicalInfo": "string",
  "lastUpdated": "timestamp"
}
```

### 2. Emergencies Collection (`/emergencies/{emergencyId}`)
**Purpose**: Store all emergency requests and their complete lifecycle

```json
{
  "emergencyId": "string (auto-generated)",
  "patientId": "string (reference to users)",
  "patientName": "string",
  "patientPhone": "string",
  "emergencyType": "cardiac | accident | respiratory | stroke | other",
  "severity": "critical | high | medium | low",
  "description": "string",
  "location": {
    "address": "string",
    "coordinates": {
      "latitude": "number",
      "longitude": "number"
    }
  },
  "status": "pending | dispatched | en_route | arrived | completed | cancelled",
  "assignedDriverId": "string",
  "assignedAmbulanceId": "string",
  "assignedHospitalId": "string",
  "estimatedArrivalTime": "timestamp",
  "actualArrivalTime": "timestamp",
  "completedAt": "timestamp",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "priority": "number",
  "routeClearanceStatus": "requested | in_progress | cleared | not_required"
}
```

**Subcollections**:

#### `/emergencies/{emergencyId}/timeline/{timelineId}`
```json
{
  "timelineId": "string",
  "event": "request_created | ambulance_dispatched | driver_en_route | arrived_at_location | patient_picked_up | en_route_to_hospital | arrived_at_hospital | completed",
  "description": "string",
  "timestamp": "timestamp",
  "updatedBy": "string (userId)",
  "location": {
    "latitude": "number",
    "longitude": "number"
  }
}
```

#### `/emergencies/{emergencyId}/locationUpdates/{updateId}`
```json
{
  "updateId": "string",
  "ambulanceId": "string",
  "location": {
    "latitude": "number",
    "longitude": "number"
  },
  "timestamp": "timestamp",
  "speed": "number",
  "heading": "number",
  "eta": "number (minutes)"
}
```

### 3. Ambulances Collection (`/ambulances/{ambulanceId}`)
**Purpose**: Store ambulance information and real-time tracking

```json
{
  "ambulanceId": "string",
  "vehicleNumber": "string",
  "hospitalId": "string",
  "driverId": "string",
  "type": "basic | advanced | critical_care",
  "status": "available | dispatched | en_route | at_hospital | maintenance",
  "currentLocation": {
    "latitude": "number",
    "longitude": "number",
    "timestamp": "timestamp"
  },
  "equipment": "array of strings",
  "capacity": "number",
  "isActive": "boolean",
  "lastMaintenance": "timestamp",
  "nextMaintenance": "timestamp"
}
```

#### `/ambulances/{ambulanceId}/locationHistory/{locationId}`
```json
{
  "locationId": "string",
  "location": {
    "latitude": "number",
    "longitude": "number"
  },
  "timestamp": "timestamp",
  "emergencyId": "string",
  "speed": "number",
  "heading": "number"
}
```

### 4. Hospitals Collection (`/hospitals/{hospitalId}`)
**Purpose**: Store hospital information and capacity

```json
{
  "hospitalId": "string",
  "name": "string",
  "address": {
    "street": "string",
    "city": "string",
    "state": "string",
    "pincode": "string",
    "coordinates": {
      "latitude": "number",
      "longitude": "number"
    }
  },
  "phone": "string",
  "email": "string",
  "type": "government | private | specialty",
  "specialties": "array of strings",
  "totalBeds": "number",
  "availableBeds": "number",
  "icuBeds": "number",
  "emergencyBeds": "number",
  "hasAmbulanceService": "boolean",
  "has24x7Emergency": "boolean",
  "rating": "number",
  "isActive": "boolean"
}
```

#### `/hospitals/{hospitalId}/bedAvailability/{bedId}`
```json
{
  "bedId": "string",
  "type": "general | icu | emergency | pediatric",
  "isOccupied": "boolean",
  "patientId": "string",
  "admissionDate": "timestamp",
  "estimatedDischarge": "timestamp"
}
```

#### `/hospitals/{hospitalId}/staff/{staffId}`
```json
{
  "staffId": "string",
  "userId": "string (reference to users)",
  "department": "string",
  "designation": "string",
  "isOnDuty": "boolean",
  "shift": "string",
  "specialization": "string"
}
```

### 5. Traffic Control Collection (`/trafficControl/{controlId}`)
**Purpose**: Store traffic management and route clearance data

```json
{
  "controlId": "string",
  "officerId": "string",
  "emergencyId": "string",
  "route": {
    "startLocation": {
      "latitude": "number",
      "longitude": "number",
      "address": "string"
    },
    "endLocation": {
      "latitude": "number",
      "longitude": "number",
      "address": "string"
    },
    "waypoints": "array of coordinates"
  },
  "status": "requested | in_progress | cleared | completed",
  "estimatedClearanceTime": "number (minutes)",
  "actualClearanceTime": "number (minutes)",
  "trafficDensity": "low | medium | high | critical",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### `/trafficControl/{controlId}/routeClearance/{clearanceId}`
```json
{
  "clearanceId": "string",
  "location": {
    "latitude": "number",
    "longitude": "number",
    "address": "string"
  },
  "action": "signal_override | traffic_diversion | manual_control",
  "status": "pending | active | completed",
  "timestamp": "timestamp",
  "officerId": "string",
  "notes": "string"
}
```

### 6. Analytics Collection (`/analytics/{analyticsId}`)
**Purpose**: Store performance metrics and reports

```json
{
  "analyticsId": "string",
  "type": "daily | weekly | monthly | custom",
  "dateRange": {
    "startDate": "timestamp",
    "endDate": "timestamp"
  },
  "metrics": {
    "totalEmergencies": "number",
    "averageResponseTime": "number",
    "routesClearedCount": "number",
    "successRate": "number",
    "emergencyTypeDistribution": "object",
    "sectorPerformance": "object"
  },
  "generatedBy": "string (userId)",
  "generatedAt": "timestamp",
  "reportUrl": "string"
}
```

### 7. Chats Collection (`/chats/{chatId}`)
**Purpose**: Store communication between users and emergency responders

```json
{
  "chatId": "string",
  "participants": "array of userIds",
  "emergencyId": "string",
  "type": "emergency | support | feedback",
  "isActive": "boolean",
  "createdAt": "timestamp",
  "lastMessageAt": "timestamp"
}
```

#### `/chats/{chatId}/messages/{messageId}`
```json
{
  "messageId": "string",
  "senderId": "string",
  "message": "string",
  "type": "text | image | location | audio",
  "timestamp": "timestamp",
  "isRead": "boolean",
  "metadata": "object"
}
```

### 8. Feedback Collection (`/feedback/{feedbackId}`)
**Purpose**: Store user feedback and ratings

```json
{
  "feedbackId": "string",
  "userId": "string",
  "emergencyId": "string",
  "driverId": "string",
  "hospitalId": "string",
  "rating": "number (1-5)",
  "feedback": "string",
  "category": "driver | hospital | app | overall",
  "isAnonymous": "boolean",
  "createdAt": "timestamp"
}
```

### 9. System Logs Collection (`/systemLogs/{logId}`)
**Purpose**: Store system events and debugging information

```json
{
  "logId": "string",
  "userId": "string",
  "action": "string",
  "details": "object",
  "timestamp": "timestamp",
  "level": "info | warning | error | critical",
  "source": "mobile_app | web_dashboard | system"
}
```

## Data Flow Examples

### Emergency Request Flow:
1. Patient creates document in `/emergencies/`
2. System creates timeline entry in `/emergencies/{id}/timeline/`
3. Driver assignment updates emergency document
4. Location updates stored in `/emergencies/{id}/locationUpdates/`
5. User activities logged in `/users/{patientId}/activities/`
6. Notifications sent to `/users/{userId}/notifications/`

### User Activity Tracking:
- All user actions are logged in their respective `/users/{userId}/activities/` subcollection
- Emergency-related activities reference the emergency document
- System maintains audit trail for all critical operations

## Security Features:
- Role-based access control through Firestore rules
- Data encryption in transit and at rest
- User can only access their own data unless they're emergency responders
- Professional users have limited access to patient data during emergencies only
- All write operations include timestamp validation
- Audit logging for all critical operations

## Indexing Strategy:
- Composite indexes on emergency status and timestamp
- User role and active status indexes
- Location-based queries for ambulance tracking
- Time-based queries for analytics and reporting

This structure ensures comprehensive data storage while maintaining security, scalability, and real-time capabilities for the ResQRoute emergency response system.
