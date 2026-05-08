// lib/models/user_model.dart

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String? profileImageUrl;
  final List<Map<String, dynamic>> addresses;
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImageUrl,
    this.addresses = const [],
    required this.createdAt,
    this.isActive = true,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: (map['uid'] ?? '').toString().trim(),
      fullName: (map['fullName'] ?? '').toString().trim(),
      email: (map['email'] ?? '').toString().trim(),
      phone: (map['phone'] ?? '').toString().trim(),
      role: (map['role'] ?? 'customer').toString().trim(),
      profileImageUrl: map['profileImageUrl']?.toString(),
      addresses: List<Map<String, dynamic>>.from(
          map['addresses'] ?? []),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
      isActive: map['isActive'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'profileImageUrl': profileImageUrl,
      'addresses': addresses,
      'createdAt': createdAt,
      'isActive': isActive,
    };
  }
}