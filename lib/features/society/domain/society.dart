class Society {
  final String id;
  final String name;
  final String? logoUrl;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pinCode;
  final String contactNumber;
  final String email;
  final String registrationNumber;
  final String? website;
  final DateTime updatedAt;

  const Society({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pinCode,
    required this.contactNumber,
    required this.email,
    required this.registrationNumber,
    this.website,
    required this.updatedAt,
  });

  Society copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? address,
    String? city,
    String? state,
    String? country,
    String? pinCode,
    String? contactNumber,
    String? email,
    String? registrationNumber,
    String? website,
    DateTime? updatedAt,
  }) {
    return Society(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      pinCode: pinCode ?? this.pinCode,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      website: website ?? this.website,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pinCode': pinCode,
      'contactNumber': contactNumber,
      'email': email,
      'registrationNumber': registrationNumber,
      'website': website,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Society.fromMap(Map<String, dynamic> map) {
    return Society(
      id: map['id'] as String,
      name: map['name'] as String,
      logoUrl: map['logoUrl'] as String?,
      address: map['address'] as String,
      city: map['city'] as String,
      state: map['state'] as String,
      country: map['country'] as String,
      pinCode: map['pinCode'] as String,
      contactNumber: map['contactNumber'] as String,
      email: map['email'] as String,
      registrationNumber: map['registrationNumber'] as String,
      website: map['website'] as String?,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}
