import 'package:cloud_firestore/cloud_firestore.dart';

class TrackingUpdate {
  final String id;
  final String requestId;
  final String driverId;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double speed;
  final String status;
  final DateTime estimatedArrival;

  TrackingUpdate({
    required this.id,
    required this.requestId,
    required this.driverId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.status,
    required this.estimatedArrival,
  });

  factory TrackingUpdate.fromJson(Map<String, dynamic> json) {
    return TrackingUpdate(
      id: json['id'] ?? '',
      requestId: json['requestId'] ?? '',
      driverId: json['driverId'] ?? '',
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      speed: (json['speed'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'unknown',
      estimatedArrival: json['estimatedArrival'] is Timestamp
          ? (json['estimatedArrival'] as Timestamp).toDate()
          : DateTime.tryParse(json['estimatedArrival'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestId': requestId,
      'driverId': driverId,
      'timestamp': Timestamp.fromDate(timestamp),
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'status': status,
      'estimatedArrival': Timestamp.fromDate(estimatedArrival),
    };
  }

  TrackingUpdate copyWith({
    String? id,
    String? requestId,
    String? driverId,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    double? speed,
    String? status,
    DateTime? estimatedArrival,
  }) {
    return TrackingUpdate(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      driverId: driverId ?? this.driverId,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speed: speed ?? this.speed,
      status: status ?? this.status,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
    );
  }
}

class AmbulanceLocation {
  final String requestId;
  final String driverId;
  final double latitude;
  final double longitude;
  final double speed;
  final DateTime timestamp;
  final String status;
  final DateTime estimatedArrival;
  final String? patientName;
  final String? hospitalName;

  AmbulanceLocation({
    required this.requestId,
    required this.driverId,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.timestamp,
    required this.status,
    required this.estimatedArrival,
    this.patientName,
    this.hospitalName,
  });

  factory AmbulanceLocation.fromJson(Map<String, dynamic> json) {
    final currentLocation = json['currentLocation'] ?? {};
    return AmbulanceLocation(
      requestId: json['requestId'] ?? '',
      driverId: json['driverId'] ?? '',
      latitude: (currentLocation['latitude'] ?? 0.0).toDouble(),
      longitude: (currentLocation['longitude'] ?? 0.0).toDouble(),
      speed: (json['speed'] ?? 0.0).toDouble(),
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'unknown',
      estimatedArrival: json['estimatedArrival'] is Timestamp
          ? (json['estimatedArrival'] as Timestamp).toDate()
          : DateTime.tryParse(json['estimatedArrival'] ?? '') ?? DateTime.now(),
      patientName: json['patientName'],
      hospitalName: json['hospitalName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'driverId': driverId,
      'currentLocation': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'speed': speed,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
      'estimatedArrival': Timestamp.fromDate(estimatedArrival),
      'patientName': patientName,
      'hospitalName': hospitalName,
    };
  }
}

class RouteClearance {
  final String requestId;
  final String status; // requested, approved, denied
  final DateTime requestedAt;
  final DateTime? respondedAt;
  final String? officerId;
  final String? officerName;
  final Map<String, dynamic>? routeData;
  final String priority; // high, medium, low

  RouteClearance({
    required this.requestId,
    required this.status,
    required this.requestedAt,
    this.respondedAt,
    this.officerId,
    this.officerName,
    this.routeData,
    required this.priority,
  });

  factory RouteClearance.fromJson(Map<String, dynamic> json) {
    return RouteClearance(
      requestId: json['requestId'] ?? '',
      status: json['status'] ?? 'requested',
      requestedAt: json['requestedAt'] is Timestamp
          ? (json['requestedAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['requestedAt'] ?? '') ?? DateTime.now(),
      respondedAt: json['respondedAt'] != null
          ? (json['respondedAt'] is Timestamp
              ? (json['respondedAt'] as Timestamp).toDate()
              : DateTime.tryParse(json['respondedAt']))
          : null,
      officerId: json['officerId'],
      officerName: json['officerName'],
      routeData: json['route'],
      priority: json['priority'] ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'status': status,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'officerId': officerId,
      'officerName': officerName,
      'route': routeData,
      'priority': priority,
    };
  }
}
