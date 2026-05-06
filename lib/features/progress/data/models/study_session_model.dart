class StudySessionModel {
  final String id;
  final String userId;
  final String lastMaterialId;
  final int lastPageNumber;
  final DateTime lastAccessedAt;

  StudySessionModel({
    required this.id,
    required this.userId,
    required this.lastMaterialId,
    this.lastPageNumber = 1,
    required this.lastAccessedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'last_material_id': lastMaterialId,
      'last_page_number': lastPageNumber,
      'last_accessed_at': lastAccessedAt.toIso8601String(),
    };
  }

  factory StudySessionModel.fromMap(Map<String, dynamic> map, String docId) {
    return StudySessionModel(
      id: docId,
      userId: map['user_id'] ?? '',
      lastMaterialId: map['last_material_id'] ?? '',
      lastPageNumber: map['last_page_number'] ?? 1,
      lastAccessedAt: map['last_accessed_at'] != null
          ? DateTime.tryParse(map['last_accessed_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  StudySessionModel copyWith({
    String? id,
    String? userId,
    String? lastMaterialId,
    int? lastPageNumber,
    DateTime? lastAccessedAt,
  }) {
    return StudySessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lastMaterialId: lastMaterialId ?? this.lastMaterialId,
      lastPageNumber: lastPageNumber ?? this.lastPageNumber,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }
}
