class LearningOutcomeModel {
  final String id;
  final String courseId;
  final String description;
  final String domain;
  final String cognitiveLevel;

  LearningOutcomeModel({
    required this.id,
    required this.courseId,
    required this.description,
    required this.domain,
    required this.cognitiveLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'description': description,
      'domain': domain,
      'cognitive_level': cognitiveLevel,
    };
  }

  factory LearningOutcomeModel.fromMap(Map<String, dynamic> map, String docId) {
    return LearningOutcomeModel(
      id: docId,
      courseId: map['course_id'] ?? '',
      description: map['description'] ?? '',
      domain: map['domain'] ?? '',
      cognitiveLevel: map['cognitive_level'] ?? '',
    );
  }
}
