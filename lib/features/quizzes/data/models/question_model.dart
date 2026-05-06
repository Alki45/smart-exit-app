import 'package:uuid/uuid.dart';
import 'question_option_model.dart';

/// Matches the [questions] Firestore collection.
/// Keeps [options] as List<String> for UI compatibility while serializing
/// to/from the typed [question_options] embedded sub-documents.
class QuestionModel {
  final String id;
  final String? courseId;          // FK -> courses
  final String? outcomeId;         // FK -> learning_outcomes
  final String questionText;
  final List<String> options;      // UI-friendly flat list
  final int correctAnswerIndex;    // Used by quiz engine
  final String? explanation;
  final String? topic;
  final String? domain;            // Cognitive / Affective / Psychomotor
  final String? cognitiveLevel;    // e.g. Synthesis, Analysis, Evaluation
  final String? courseCode;
  final bool isAiGenerated;        // true = produced by AI pipeline

  const QuestionModel({
    required this.id,
    this.courseId,
    this.outcomeId,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation,
    this.topic,
    this.domain,
    this.cognitiveLevel,
    this.courseCode,
    this.isAiGenerated = false,
  });

  /// The correct answer text — used as [correct_answer] in Firestore.
  String get correctAnswer =>
      (options.isNotEmpty && correctAnswerIndex < options.length)
          ? options[correctAnswerIndex]
          : '';

  /// Build typed option objects for Firestore serialization.
  List<QuestionOptionModel> get questionOptions {
    const uuid = Uuid();
    return options.asMap().entries.map((entry) {
      return QuestionOptionModel(
        id: uuid.v4(),
        questionId: id,
        optionText: entry.value,
        isCorrect: entry.key == correctAnswerIndex,
      );
    }).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'outcome_id': outcomeId,
      'question_text': questionText,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'is_ai_generated': isAiGenerated,
      'domain': domain,
      'cognitive_level': cognitiveLevel,
      // Legacy keys kept for backward-compatibility reads
      'questionText': questionText,
      'correctAnswerIndex': correctAnswerIndex,
      'topic': topic,
      'cognitiveLevel': cognitiveLevel,
      'courseCode': courseCode,
      // Embedded options (NoSQL denormalization — no separate round-trip needed)
      'question_options':
          questionOptions.map((o) => o.toMap()).toList(),
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    // Support both old List<String> options and new List<Map> question_options
    List<String> parsedOptions = [];
    int parsedCorrectIndex = map['correctAnswerIndex'] ?? 0;

    final rawOptions = map['question_options'] ?? map['options'];
    if (rawOptions is List && rawOptions.isNotEmpty) {
      if (rawOptions.first is Map) {
        // New typed format
        final typed = rawOptions
            .map((o) => QuestionOptionModel.fromMap(
                o as Map<String, dynamic>))
            .toList();
        parsedOptions = typed.map((o) => o.optionText).toList();
        final ci = typed.indexWhere((o) => o.isCorrect);
        parsedCorrectIndex = ci >= 0 ? ci : 0;
      } else {
        // Legacy string list
        parsedOptions = List<String>.from(rawOptions);
      }
    }

    return QuestionModel(
      id: map['id'] ?? '',
      courseId: map['course_id'] ?? map['courseId'],
      outcomeId: map['outcome_id'] ?? map['outcomeId'],
      questionText:
          map['question_text'] ?? map['questionText'] ?? '',
      options: parsedOptions,
      correctAnswerIndex: parsedCorrectIndex,
      explanation: map['explanation'],
      topic: map['topic'],
      domain: map['domain'],
      cognitiveLevel:
          map['cognitive_level'] ?? map['cognitiveLevel'],
      courseCode: map['courseCode'],
      isAiGenerated:
          map['is_ai_generated'] ?? map['isAiGenerated'] ?? false,
    );
  }
}
