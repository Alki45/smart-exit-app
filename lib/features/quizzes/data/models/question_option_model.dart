/// Represents a single answer choice for a question.
/// Matches the [question_options] Firestore collection / embedded sub-document.
class QuestionOptionModel {
  final String id;
  final String questionId; // FK -> questions
  final String optionText;
  final bool isCorrect;

  const QuestionOptionModel({
    required this.id,
    required this.questionId,
    required this.optionText,
    required this.isCorrect,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question_id': questionId,
      'option_text': optionText,
      'is_correct': isCorrect,
    };
  }

  factory QuestionOptionModel.fromMap(Map<String, dynamic> map) {
    return QuestionOptionModel(
      id: map['id'] ?? '',
      questionId: map['question_id'] ?? map['questionId'] ?? '',
      optionText: map['option_text'] ?? map['optionText'] ?? '',
      isCorrect: map['is_correct'] ?? map['isCorrect'] ?? false,
    );
  }
}
