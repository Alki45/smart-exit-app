import 'response_log_model.dart';

/// Matches the [quiz_attempts] Firestore collection.
/// All existing fields are preserved; new schema fields are added alongside.
class QuizAttemptModel {
  final String id;
  final String userId;
  final String quizId;
  final String quizTitle;

  // Schema: quiz_type — "Mock Exam", "Focus Session", "Lab Quiz"
  final String quizType;

  final double score;

  // Schema: overall_accuracy — aliased from score
  final double overallAccuracy;

  final int correctAnswers;
  final int totalQuestions;

  // Legacy timestamp key (kept for Firestore orderBy compatibility)
  final DateTime timestamp;

  // Schema: completed_at
  final DateTime completedAt;

  final Map<String, int> userAnswers; // questionId -> selectedOptionIndex
  final List<String> incorrectQuestionIds;
  final List<String> recommendations;
  final Map<String, int> topicMisses;
  final Map<String, int> topicTotal;

  // Schema: response_log — embedded for NoSQL read performance
  final List<ResponseLogModel> responses;

  QuizAttemptModel({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.quizTitle,
    this.quizType = 'Practice Quiz',
    required this.score,
    double? overallAccuracy,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timestamp,
    DateTime? completedAt,
    required this.userAnswers,
    this.incorrectQuestionIds = const [],
    this.recommendations = const [],
    this.topicMisses = const {},
    this.topicTotal = const {},
    this.responses = const [],
  })  : overallAccuracy = overallAccuracy ?? score,
        completedAt = completedAt ?? timestamp;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      // Both key styles written so old readers still work
      'userId': userId,
      'user_id': userId,
      'quizId': quizId,
      'quizTitle': quizTitle,
      'quiz_type': quizType,
      'score': score,
      'overall_accuracy': overallAccuracy,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'timestamp': timestamp.toIso8601String(),
      'completed_at': completedAt.toIso8601String(),
      'userAnswers': userAnswers,
      'incorrectQuestionIds': incorrectQuestionIds,
      'recommendations': recommendations,
      'topicMisses': topicMisses,
      'topicTotal': topicTotal,
      'responses': responses.map((r) => r.toMap()).toList(),
    };
  }

  factory QuizAttemptModel.fromMap(Map<String, dynamic> map) {
    final ts = map['timestamp'] != null
        ? DateTime.parse(map['timestamp'])
        : DateTime.now();

    return QuizAttemptModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? map['user_id'] ?? '',
      quizId: map['quizId'] ?? '',
      quizTitle: map['quizTitle'] ?? '',
      quizType: map['quiz_type'] ?? map['scope'] ?? 'Practice Quiz',
      score: (map['score'] as num?)?.toDouble() ?? 0.0,
      overallAccuracy: (map['overall_accuracy'] as num?)?.toDouble() ??
          (map['score'] as num?)?.toDouble() ?? 0.0,
      correctAnswers: map['correctAnswers'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      timestamp: ts,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'])
          : ts,
      userAnswers: Map<String, int>.from(map['userAnswers'] ?? {}),
      incorrectQuestionIds:
          List<String>.from(map['incorrectQuestionIds'] ?? []),
      recommendations: List<String>.from(map['recommendations'] ?? []),
      topicMisses: Map<String, int>.from(map['topicMisses'] ?? {}),
      topicTotal: Map<String, int>.from(map['topicTotal'] ?? {}),
      responses: (map['responses'] as List<dynamic>?)
              ?.map((r) => ResponseLogModel.fromMap(
                  r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
