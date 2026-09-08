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
  final TowerStatus status;
  final DateTime createdAt;

  const Tower({
    required this.id,
    required this.societyId,
    required this.name,
    required this.description,
    required this.floorCount,
    required this.status,
    required this.createdAt,
  });

  Tower copyWith({
    String? id,
    String? societyId,
    String? name,
    String? description,
    int? floorCount,
    TowerStatus? status,
    DateTime? createdAt,
  }) {
    return Tower(
      id: id ?? this.id,
      societyId: societyId ?? this.societyId,
      name: name ?? this.name,
      description: description ?? this.description,
      floorCount: floorCount ?? this.floorCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'societyId': societyId,
      'name': name,
      'description': description,
      'floorCount': floorCount,
      'status': status.code,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Tower.fromMap(Map<String, dynamic> map) {
    return Tower(
      id: map['id'] as String,
      societyId: map['societyId'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      floorCount: (map['floorCount'] as num).toInt(),
      status: TowerStatus.fromString(map['status'] as String?),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
