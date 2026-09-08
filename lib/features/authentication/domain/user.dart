import '../../role/domain/role.dart';

class User {
  final String id;
  final String email;
  final String name;
  final String mobile;
  final Role role;
  final String societyId;
  final String societyName;
  final String? profilePhotoUrl;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.mobile,
    required this.role,
    required this.societyId,
    required this.societyName,
    this.profilePhotoUrl,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? mobile,
    Role? role,
    String? societyId,
    String? societyName,
    String? profilePhotoUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      role: role ?? this.role,
      societyId: societyId ?? this.societyId,
      societyName: societyName ?? this.societyName,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'mobile': mobile,
      'role': role.code,
      'societyId': societyId,
      'societyName': societyName,
      'profilePhotoUrl': profilePhotoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      mobile: map['mobile'] as String,
      role: Role.fromString(map['role'] as String?),
      societyId: map['societyId'] as String,
      societyName: map['societyName'] as String? ?? 'Society',
      profilePhotoUrl: map['profilePhotoUrl'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
