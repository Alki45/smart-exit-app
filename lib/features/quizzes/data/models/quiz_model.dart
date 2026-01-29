import 'package:flutter/foundation.dart';
import 'question_model.dart';
    
class QuizModel {
  final String id;
  final String courseId;
  final String title;
  final List<QuestionModel> questions;
  final int duration; // in minutes
  final DateTime createdAt;

  QuizModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.questions,
    required this.duration,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'questions': questions.map((q) => q.toMap()).toList(),
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
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
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
