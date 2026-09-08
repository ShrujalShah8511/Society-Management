import 'tower.dart';

class Floor {
  final String id;
  final String societyId;
  final String towerId;
  final int floorNumber;
  final String displayName;
  final TowerStatus status;
  final DateTime createdAt;

  const Floor({
    required this.id,
    required this.societyId,
    required this.towerId,
    required this.floorNumber,
    required this.displayName,
    required this.status,
    required this.createdAt,
  });

  Floor copyWith({
    String? id,
    String? societyId,
    String? towerId,
    int? floorNumber,
    String? displayName,
    TowerStatus? status,
    DateTime? createdAt,
  }) {
    return Floor(
      id: id ?? this.id,
      societyId: societyId ?? this.societyId,
      towerId: towerId ?? this.towerId,
      floorNumber: floorNumber ?? this.floorNumber,
      displayName: displayName ?? this.displayName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'societyId': societyId,
      'towerId': towerId,
      'floorNumber': floorNumber,
      'displayName': displayName,
      'status': status.code,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Floor.fromMap(Map<String, dynamic> map) {
    return Floor(
      id: map['id'] as String,
      societyId: map['societyId'] as String,
      towerId: map['towerId'] as String,
      floorNumber: (map['floorNumber'] as num).toInt(),
      displayName: map['displayName'] as String,
      status: TowerStatus.fromString(map['status'] as String?),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
