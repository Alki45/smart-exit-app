import 'question_model.dart';
    
class QuizModel {
  final String id;
  final String courseId;
  final String title;
  final List<QuestionModel> questions;
  final int duration; // in minutes
  final DateTime createdAt;
  final bool isMockExam;
  final bool isCourseSpecific;
  final String? blueprintId;
  final String? blueprintVersionUsed;
  final String? scope; // "mock_exam", "focus_session", "quick_practice"

  QuizModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.questions,
    required this.duration,
    required this.createdAt,
    this.isMockExam = false,
    this.isCourseSpecific = true,
    this.blueprintId,
    this.blueprintVersionUsed,
    this.scope,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'questions': questions.map((q) => q.toMap()).toList(),
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
      'isMockExam': isMockExam,
      'isCourseSpecific': isCourseSpecific,
      'blueprintId': blueprintId,
      'blueprintVersionUsed': blueprintVersionUsed,
      'scope': scope,
    };
  }

  factory QuizModel.fromMap(Map<String, dynamic> map) {
    return QuizModel(
      id: map['id'] ?? '',
      courseId: map['courseId'] ?? '',
      title: map['title'] ?? '',
      questions: (map['questions'] as List<dynamic>?)
              ?.map((q) => QuestionModel.fromMap(q))
              .toList() ??
          [],
      duration: map['duration'] ?? 0,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      isMockExam: map['isMockExam'] ?? false,
      isCourseSpecific: map['isCourseSpecific'] ?? true,
      blueprintId: map['blueprintId'],
      blueprintVersionUsed: map['blueprintVersionUsed'],
      scope: map['scope'],
    );
  }
}
