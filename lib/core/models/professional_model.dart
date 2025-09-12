import 'package:cloud_firestore/cloud_firestore.dart';

class ProfessionalModel {
  final String id;
  final String role;
  final String employeeId;
  final String email;
  final String fullName;
  final String phone;
  final DateTime createdAt;
  final bool isActive;
  final Map<String, dynamic>? additionalData;
  
  // Getter for uid to maintain compatibility
  String get uid => id;

  ProfessionalModel({
    required this.id,
    required this.role,
    required this.employeeId,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.createdAt,
    this.isActive = true,
    this.additionalData,
  });

  factory ProfessionalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProfessionalModel(
      id: doc.id,
      role: data['role']?.toString() ?? '',
      employeeId: data['employeeId']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      fullName: data['fullName']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: (data['isActive'] is bool) ? data['isActive'] as bool : true,
      additionalData: data['additionalData'] as Map<String, dynamic>?,
    );
  }

  factory ProfessionalModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalModel(
      id: json['id'] ?? '',
      role: json['role'] ?? '',
      employeeId: json['employeeId'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
      additionalData: json['additionalData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'employeeId': employeeId,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'additionalData': additionalData,
    };
  }

  ProfessionalModel copyWith({
    String? id,
    String? role,
    String? employeeId,
    String? email,
    String? fullName,
    String? phone,
    DateTime? createdAt,
    bool? isActive,
    Map<String, dynamic>? additionalData,
  }) {
    return ProfessionalModel(
      id: id ?? this.id,
      role: role ?? this.role,
      employeeId: employeeId ?? this.employeeId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}
