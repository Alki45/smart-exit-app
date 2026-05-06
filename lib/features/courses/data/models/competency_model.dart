class CompetencyModel {
  final String id;
  final String courseId;
  final String description;
  final String domainType; // e.g., 'Cognitive', 'Affective', 'Psychomotor', 'Laboratory', 'Theoretical'

  CompetencyModel({
    required this.id,
    required this.courseId,
    required this.description,
    required this.domainType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'description': description,
      'domain_type': domainType,
    };
  }

  factory CompetencyModel.fromMap(Map<String, dynamic> map, String docId) {
    return CompetencyModel(
      id: docId,
      courseId: map['course_id'] ?? '',
      description: map['description'] ?? '',
      domainType: map['domain_type'] ?? '',
    );
  }

  CompetencyModel copyWith({
    String? id,
    String? courseId,
    String? description,
    String? domainType,
  }) {
    return CompetencyModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      description: description ?? this.description,
      domainType: domainType ?? this.domainType,
    );
  }
}
