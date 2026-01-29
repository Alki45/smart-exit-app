class QuizAttemptModel {
  final String id;
  final String userId;
  final String quizId;
  final String quizTitle;
  final double score;
  final int correctAnswers;
  final int totalQuestions;
  final DateTime timestamp;
  final Map<String, int> userAnswers; // questionId -> selectedOptionIndex
  final List<String> incorrectQuestionIds;
  final List<String> recommendations;

  QuizAttemptModel({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timestamp,
    required this.userAnswers,
    this.incorrectQuestionIds = const [],
    this.recommendations = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'quizId': quizId,
      'quizTitle': quizTitle,
      'score': score,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'timestamp': timestamp.toIso8601String(),
      'userAnswers': userAnswers,
      'incorrectQuestionIds': incorrectQuestionIds,
      'recommendations': recommendations,
    };
  }

  factory QuizAttemptModel.fromMap(Map<String, dynamic> map) {
    return QuizAttemptModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      quizId: map['quizId'] ?? '',
      quizTitle: map['quizTitle'] ?? '',
      score: (map['score'] as num?)?.toDouble() ?? 0.0,
      correctAnswers: map['correctAnswers'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      timestamp: DateTime.parse(map['timestamp']),
      userAnswers: Map<String, int>.from(map['userAnswers'] ?? {}),
      incorrectQuestionIds: List<String>.from(map['incorrectQuestionIds'] ?? []),
      recommendations: List<String>.from(map['recommendations'] ?? []),
    );
  }
}
