class MaterialModel {
  final String id;
  final String courseId;
  final String filePath;
  final String? contentSummary;
  final DateTime uploadedAt;

  MaterialModel({
    required this.id,
    required this.courseId,
    required this.filePath,
    this.contentSummary,
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'file_path': filePath,
      'content_summary': contentSummary,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory MaterialModel.fromMap(Map<String, dynamic> map, String docId) {
    return MaterialModel(
      id: docId,
      courseId: map['course_id'] ?? '',
      filePath: map['file_path'] ?? '',
      contentSummary: map['content_summary'],
      uploadedAt: map['uploadedAt'] != null
          ? DateTime.tryParse(map['uploadedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  MaterialModel copyWith({
    String? id,
    String? courseId,
    String? filePath,
    String? contentSummary,
    DateTime? uploadedAt,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      filePath: filePath ?? this.filePath,
      contentSummary: contentSummary ?? this.contentSummary,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
}
