/// Cached per-course accuracy for a student. Used by the dashboard to show
/// "You missed 5 questions in AI" without re-aggregating all attempts.
/// Matches the [performance_summaries] schema. Stored as a top-level collection.
class PerformanceSummaryModel {
  final String id;
  final String userId;   // FK -> users
  final String courseId; // FK -> courses
  final double accuracyPercent;
  final int missedCount;

  const PerformanceSummaryModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.accuracyPercent,
    required this.missedCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'accuracy_percent': accuracyPercent,
      'missed_count': missedCount,
    };
  }

  factory PerformanceSummaryModel.fromMap(
      Map<String, dynamic> map, String docId) {
    return PerformanceSummaryModel(
      id: docId,
      userId: map['user_id'] ?? map['userId'] ?? '',
      courseId: map['course_id'] ?? map['courseId'] ?? '',
      accuracyPercent:
          (map['accuracy_percent'] as num?)?.toDouble() ?? 0.0,
      missedCount: map['missed_count'] ?? map['missedCount'] ?? 0,
    );
  }

  PerformanceSummaryModel copyWith({
    double? accuracyPercent,
    int? missedCount,
  }) {
    return PerformanceSummaryModel(
      id: id,
      userId: userId,
      courseId: courseId,
      accuracyPercent: accuracyPercent ?? this.accuracyPercent,
      missedCount: missedCount ?? this.missedCount,
    );
  }
}
