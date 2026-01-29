class CourseModel {
  final String id;
  final String courseCode;
  final String courseName;
  final int creditHours;
  final List<String> topics;
  final List<String> materialUrls; // URL strings for PDF/DOCX
  final String? userId; // Owner of this course
  final DateTime createdAt;

  CourseModel({
    required this.id,
    required this.courseCode,
    required this.courseName,
    required this.creditHours,
    this.topics = const [],
    this.materialUrls = const [],
    this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseCode': courseCode,
      'courseName': courseName,
      'creditHours': creditHours,
      'topics': topics,
      'materialUrls': materialUrls,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CourseModel.fromMap(Map<String, dynamic> map, String docId) {
    return CourseModel(
      id: docId,
      courseCode: map['courseCode'] ?? '',
      courseName: map['courseName'] ?? '',
      creditHours: map['creditHours'] ?? 0,
      topics: List<String>.from(map['topics'] ?? []),
      materialUrls: List<String>.from(map['materialUrls'] ?? []),
      userId: map['userId'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
