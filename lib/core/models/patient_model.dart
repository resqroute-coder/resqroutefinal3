import 'package:cloud_firestore/cloud_firestore.dart';

class PatientModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String? address;
  final DateTime dateOfBirth;
  final String gender;
  final String bloodGroup;
  final String? medicalConditions;
  final String? allergies;
  final String? medications;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String? emergencyContactRelation;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  PatientModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    this.address,
    required this.dateOfBirth,
    required this.gender,
    required this.bloodGroup,
    this.medicalConditions,
    this.allergies,
    this.medications,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    this.emergencyContactRelation,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    try {
      return PatientModel(
        id: json['userId']?.toString() ?? json['id']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        name: json['fullName']?.toString() ?? json['name']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        address: json['address'] is Map 
            ? json['address']['street']?.toString() 
            : json['address']?.toString(),
        dateOfBirth: json['dateOfBirth'] is String 
            ? DateTime.parse(json['dateOfBirth'])
            : json['dateOfBirth'] is Timestamp
            ? (json['dateOfBirth'] as Timestamp).toDate()
            : DateTime.now(),
        gender: json['gender']?.toString() ?? '',
        bloodGroup: json['bloodGroup']?.toString() ?? '',
        medicalConditions: json['medicalConditions']?.toString(),
        allergies: json['allergies']?.toString(),
        medications: json['medications']?.toString(),
        emergencyContactName: json['emergencyContactName']?.toString() ?? '',
        emergencyContactPhone: json['emergencyContactPhone']?.toString() ?? '',
        emergencyContactRelation: json['emergencyContactRelation']?.toString(),
        profileImageUrl: json['profileImageUrl']?.toString(),
        createdAt: json['createdAt'] is String 
            ? DateTime.parse(json['createdAt']) 
            : json['createdAt'] is Timestamp
            ? (json['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
        updatedAt: json['updatedAt'] is String 
            ? DateTime.parse(json['updatedAt']) 
            : json['updatedAt'] is Timestamp
            ? (json['updatedAt'] as Timestamp).toDate()
            : DateTime.now(),
        isActive: json['isActive'] == true || json['isActive'] == 'true',
      );
    } catch (e) {
      print('Error parsing PatientModel from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': id,
      'role': 'patient',
      'email': email,
      'fullName': name,
      'phone': phone,
      'profilePicture': profileImageUrl,
      'gender': gender,
      'bloodGroup': bloodGroup,
      'medicalConditions': medicalConditions,
      'allergies': allergies,
      'medications': medications,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'emergencyContactRelation': emergencyContactRelation,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'role': 'patient', // Add role field for Firestore rules
    };
  }

  PatientModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodGroup,
    String? medicalConditions,
    String? allergies,
    String? medications,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return PatientModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      allergies: allergies ?? this.allergies,
      medications: medications ?? this.medications,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      emergencyContactRelation: emergencyContactRelation ?? this.emergencyContactRelation,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Calculate age from date of birth
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }
}
