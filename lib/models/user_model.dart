import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { artisan, buyer, admin }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String language; // 'en', 'hi', 'te'
  final DateTime createdAt;
  final String? fcmToken;
  final String? profilePicture;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.language = 'en',
    required this.createdAt,
    this.fcmToken,
    this.profilePicture,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'language': language,
      'createdAt': Timestamp.fromDate(createdAt),
      'fcmToken': fcmToken,
      'profilePicture': profilePicture,
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.buyer,
      ),
      language: map['language'] ?? 'en',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      fcmToken: map['fcmToken'],
      profilePicture: map['profilePicture'],
    );
  }

  // Create from Firestore DocumentSnapshot
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data);
  }

  // Copy with method
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? language,
    DateTime? createdAt,
    String? fcmToken,
    String? profilePicture,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }
}
