import 'package:hive/hive.dart';

part 'course_material.g.dart';

@HiveType(typeId: 5)
class CourseMaterial {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String courseId;
  
  @HiveField(2)
  final String fileName;
  
  @HiveField(3)
  final String rawText;
  
  @HiveField(4)
  final Map<String, dynamic> analysis;
  
  @HiveField(5)
  final DateTime uploadedAt;

  CourseMaterial({
    required this.id,
    required this.courseId,
    required this.fileName,
    required this.rawText,
    required this.analysis,
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'fileName': fileName,
      'rawText': rawText,
      'analysis': analysis,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory CourseMaterial.fromMap(Map<String, dynamic> map) {
    return CourseMaterial(
      id: map['id'],
      courseId: map['courseId'],
      fileName: map['fileName'],
      rawText: map['rawText'],
      analysis: map['analysis'] ?? {},
      uploadedAt: DateTime.parse(map['uploadedAt']),
    );
  }
}
