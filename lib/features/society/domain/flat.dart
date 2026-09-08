enum FlatType {
  oneBhk('1_BHK', '1 BHK'),
  twoBhk('2_BHK', '2 BHK'),
  threeBhk('3_BHK', '3 BHK'),
  fourBhk('4_BHK', '4 BHK'),
  other('OTHER', 'Other');

  final String code;
  final String displayName;
  const FlatType(this.code, this.displayName);

  static FlatType fromString(String? code) {
    if (code == null) return FlatType.twoBhk;
    final normalized = code.trim().toUpperCase().replaceAll(' ', '_');
    return FlatType.values.firstWhere(
      (t) => t.code == normalized,
      orElse: () => FlatType.other,
    );
  }
}

enum OccupancyStatus {
  vacant('VACANT', 'Vacant'),
  occupied('OCCUPIED', 'Occupied'),
  underMaintenance('UNDER_MAINTENANCE', 'Under Maintenance');

  final String code;
  final String displayName;
  const OccupancyStatus(this.code, this.displayName);

  static OccupancyStatus fromString(String? code) {
    if (code == null) return OccupancyStatus.vacant;
    final normalized = code.trim().toUpperCase();
    return OccupancyStatus.values.firstWhere(
      (s) => s.code == normalized,
      orElse: () => OccupancyStatus.vacant,
    );
  }
}

class Flat {
  final String id;
  final String societyId;
  final String towerId;
  final String floorId;
  final String flatNumber;
  final FlatType flatType;
  final double areaSqFt;
  final OccupancyStatus occupancyStatus;
  final DateTime createdAt;

  const Flat({
    required this.id,
    required this.societyId,
    required this.towerId,
    required this.floorId,
    required this.flatNumber,
    required this.flatType,
    required this.areaSqFt,
    required this.occupancyStatus,
    required this.createdAt,
  });

  Flat copyWith({
    String? id,
    String? societyId,
    String? towerId,
    String? floorId,
    String? flatNumber,
    FlatType? flatType,
    double? areaSqFt,
    OccupancyStatus? occupancyStatus,
    DateTime? createdAt,
  }) {
    return Flat(
      id: id ?? this.id,
      societyId: societyId ?? this.societyId,
      towerId: towerId ?? this.towerId,
      floorId: floorId ?? this.floorId,
      flatNumber: flatNumber ?? this.flatNumber,
      flatType: flatType ?? this.flatType,
      areaSqFt: areaSqFt ?? this.areaSqFt,
      occupancyStatus: occupancyStatus ?? this.occupancyStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'societyId': societyId,
      'towerId': towerId,
      'floorId': floorId,
      'flatNumber': flatNumber,
      'flatType': flatType.code,
      'areaSqFt': areaSqFt,
      'occupancyStatus': occupancyStatus.code,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Flat.fromMap(Map<String, dynamic> map) {
    return Flat(
      id: map['id'] as String,
      societyId: map['societyId'] as String,
      towerId: map['towerId'] as String,
      floorId: map['floorId'] as String,
      flatNumber: map['flatNumber'] as String,
      flatType: FlatType.fromString(map['flatType'] as String?),
      areaSqFt: (map['areaSqFt'] as num).toDouble(),
      occupancyStatus: OccupancyStatus.fromString(map['occupancyStatus'] as String?),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
