/// Tracks a student's individual answer for one question within an attempt.
/// Matches the [response_log] schema. Embedded inside [QuizAttemptModel].
class ResponseLogModel {
  final String id;
  final String attemptId; // FK -> quiz_attempts
  final String questionId; // FK -> questions
  final bool isCorrect;
  final String? selectedOptionId;

  const ResponseLogModel({
    required this.id,
    required this.attemptId,
    required this.questionId,
    required this.isCorrect,
    this.selectedOptionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'attempt_id': attemptId,
      'question_id': questionId,
      'is_correct': isCorrect,
      'selected_option_id': selectedOptionId,
    };
  }

  factory ResponseLogModel.fromMap(Map<String, dynamic> map) {
    return ResponseLogModel(
      id: map['id'] ?? '',
      attemptId: map['attempt_id'] ?? map['attemptId'] ?? '',
      questionId: map['question_id'] ?? map['questionId'] ?? '',
      isCorrect: map['is_correct'] ?? map['isCorrect'] ?? false,
      selectedOptionId:
          map['selected_option_id'] ?? map['selectedOptionId'],
    );
  }
}
