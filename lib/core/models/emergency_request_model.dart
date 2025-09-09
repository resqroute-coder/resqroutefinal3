import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestStatus {
  pending,
  accepted,
  enRoute,
  pickedUp,
  completed,
  cancelled
}

enum EmergencyType {
  medical,
  accident,
  cardiac,
  respiratory,
  trauma,
  other
}

class EmergencyRequest {
  final String id;
  final String patientId;
  final String patientName;
  final String patientPhone;
  final String? driverId;
  final String? driverName;
  final String? ambulanceId;
  final RequestStatus status;
  final EmergencyType emergencyType;
  final String description;
  final String pickupLocation;
  final String hospitalLocation;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? completedAt;
  final String? notes;
  final DateTime? enRouteAt;
  final String? driverPhone;
  final Map<String, dynamic>? patientVitals;
  final String priority; // critical, high, medium, low

  EmergencyRequest({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
    this.driverId,
    this.driverName,
    this.ambulanceId,
    required this.status,
    required this.emergencyType,
    required this.description,
    required this.pickupLocation,
    required this.hospitalLocation,
    required this.createdAt,
    this.acceptedAt,
    this.pickedUpAt,
    this.completedAt,
    this.notes,
    this.enRouteAt,
    this.driverPhone,
    this.patientVitals,
    required this.priority,
  });

  factory EmergencyRequest.fromJson(Map<String, dynamic> json) {
    return EmergencyRequest(
      id: json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      patientName: json['patientName'] ?? '',
      patientPhone: json['patientPhone'] ?? '',
      driverId: json['driverId'],
      driverName: json['driverName'],
      ambulanceId: json['ambulanceId'],
      status: RequestStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => RequestStatus.pending,
      ),
      emergencyType: EmergencyType.values.firstWhere(
        (e) => e.toString().split('.').last == json['emergencyType'],
        orElse: () => EmergencyType.medical,
      ),
      description: json['description'] ?? '',
      pickupLocation: json['pickupLocation'] ?? '',
      hospitalLocation: json['hospitalLocation'] ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      acceptedAt: json['acceptedAt'] != null
          ? (json['acceptedAt'] is Timestamp
              ? (json['acceptedAt'] as Timestamp).toDate()
              : DateTime.tryParse(json['acceptedAt']))
          : null,
      pickedUpAt: json['pickedUpAt'] != null
          ? (json['pickedUpAt'] is Timestamp
              ? (json['pickedUpAt'] as Timestamp).toDate()
              : DateTime.tryParse(json['pickedUpAt']))
          : null,
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] is Timestamp
              ? (json['completedAt'] as Timestamp).toDate()
              : DateTime.tryParse(json['completedAt']))
          : null,
      patientVitals: json['patientVitals'],
      priority: json['priority'] ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'patientPhone': patientPhone,
      'driverId': driverId,
      'driverName': driverName,
      'ambulanceId': ambulanceId,
      'status': status.toString().split('.').last,
      'emergencyType': emergencyType.toString().split('.').last,
      'severity': priority, // Map priority to severity for Firestore rules
      'location': {
        'pickup': pickupLocation,
        'hospital': hospitalLocation,
      },
      'description': description,
      'pickupLocation': pickupLocation,
      'hospitalLocation': hospitalLocation,
      'createdAt': Timestamp.fromDate(createdAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'pickedUpAt': pickedUpAt != null ? Timestamp.fromDate(pickedUpAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
      'notes': notes,
      'enRouteAt': enRouteAt != null ? Timestamp.fromDate(enRouteAt!) : null,
      'driverPhone': driverPhone,
      'patientVitals': patientVitals,
      'priority': priority,
    };
  }

  EmergencyRequest copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? patientPhone,
    String? driverId,
    String? driverName,
    String? ambulanceId,
    RequestStatus? status,
    EmergencyType? emergencyType,
    String? description,
    String? pickupLocation,
    String? hospitalLocation,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? pickedUpAt,
    DateTime? completedAt,
    Map<String, dynamic>? patientVitals,
    String? priority,
  }) {
    return EmergencyRequest(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      ambulanceId: ambulanceId ?? this.ambulanceId,
      status: status ?? this.status,
      emergencyType: emergencyType ?? this.emergencyType,
      description: description ?? this.description,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      hospitalLocation: hospitalLocation ?? this.hospitalLocation,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      completedAt: completedAt ?? this.completedAt,
      patientVitals: patientVitals ?? this.patientVitals,
      priority: priority ?? this.priority,
    );
  }

  String get statusText {
    switch (status) {
      case RequestStatus.pending:
        return 'Searching for ambulance...';
      case RequestStatus.accepted:
        return 'Ambulance assigned';
      case RequestStatus.enRoute:
        return 'En route to pickup';
      case RequestStatus.pickedUp:
        return 'Patient picked up';
      case RequestStatus.completed:
        return 'Trip completed';
      case RequestStatus.cancelled:
        return 'Request cancelled';
    }
  }

  String get emergencyTypeText {
    switch (emergencyType) {
      case EmergencyType.medical:
        return 'Medical Emergency';
      case EmergencyType.accident:
        return 'Accident';
      case EmergencyType.cardiac:
        return 'Cardiac Emergency';
      case EmergencyType.respiratory:
        return 'Respiratory Emergency';
      case EmergencyType.trauma:
        return 'Trauma';
      case EmergencyType.other:
        return 'Other Emergency';
    }
  }

  String get estimatedTime {
    switch (status) {
      case RequestStatus.pending:
        return '2-5 min';
      case RequestStatus.accepted:
        return '8-12 min';
      case RequestStatus.enRoute:
        return '5-8 min';
      case RequestStatus.pickedUp:
        return '15-20 min';
      default:
        return 'N/A';
    }
  }
}
