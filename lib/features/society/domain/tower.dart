enum TowerStatus {
  active('ACTIVE', 'Active'),
  inactive('INACTIVE', 'Inactive');

  final String code;
  final String displayName;
  const TowerStatus(this.code, this.displayName);

  static TowerStatus fromString(String? code) {
    if (code == null) return TowerStatus.active;
    final normalized = code.trim().toUpperCase();
    return TowerStatus.values.firstWhere(
      (s) => s.code == normalized,
      orElse: () => TowerStatus.active,
    );
  }
}

class Tower {
  final String id;
  final String societyId;
  final String name;
  final String description;
  final int floorCount;
  final int flatsPerFloor;
  final TowerStatus status;
  final DateTime createdAt;

  const Tower({
    required this.id,
    required this.societyId,
    required this.name,
    required this.description,
    required this.floorCount,
    this.flatsPerFloor = 3,
    required this.status,
    required this.createdAt,
  });

  static int extractFlatsPerFloor(String? desc) {
    if (desc == null || desc.isEmpty) return 3;
    final match = RegExp(r'\[flats_per_floor:\s*(\d+)\]').firstMatch(desc);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '3') ?? 3;
    }
    return 3;
  }

  String get displayDescription =>
      description.replaceAll(RegExp(r'\s*\[flats_per_floor:\s*\d+\]'), '').trim();

  Tower copyWith({
    String? id,
    String? societyId,
    String? name,
    String? description,
    int? floorCount,
    int? flatsPerFloor,
    TowerStatus? status,
    DateTime? createdAt,
  }) {
    return Tower(
      id: id ?? this.id,
      societyId: societyId ?? this.societyId,
      name: name ?? this.name,
      description: description ?? this.description,
      floorCount: floorCount ?? this.floorCount,
      flatsPerFloor: flatsPerFloor ?? this.flatsPerFloor,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    final cleanDesc = displayDescription;
    final encodedDesc = cleanDesc.isEmpty
        ? '[flats_per_floor:$flatsPerFloor]'
        : '$cleanDesc [flats_per_floor:$flatsPerFloor]';

    return {
      'id': id,
      'societyId': societyId,
      'name': name,
      'description': encodedDesc,
      'floorCount': floorCount,
      'flatsPerFloor': flatsPerFloor,
      'status': status.code,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Tower.fromMap(Map<String, dynamic> map) {
    final desc = map['description'] as String? ?? '';
    final parsedFlats = map['flatsPerFloor'] is num
        ? (map['flatsPerFloor'] as num).toInt()
        : extractFlatsPerFloor(desc);

    return Tower(
      id: map['id'] as String,
      societyId: map['societyId'] as String,
      name: map['name'] as String,
      description: desc,
      floorCount: (map['floorCount'] as num).toInt(),
      flatsPerFloor: parsedFlats,
      status: TowerStatus.fromString(map['status'] as String?),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
