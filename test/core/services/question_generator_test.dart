import 'package:flutter_test/flutter_test.dart';
import 'package:smart_exit_app/core/services/question_generator_service.dart';

void main() {
  late QuestionGeneratorService service;

  setUp(() {
    service = QuestionGeneratorService();
  });

  test('generateQuestions should return questions from valid text', () async {
    const text = "Flutter is a UI toolkit. Dart is a programming language. We use Widgets to build UI.";
    
    final questions = await service.generateQuestions(text);

    expect(questions, isNotEmpty);
    expect(questions.length, lessThanOrEqualTo(10));
    
    for (var question in questions) {
      expect(question.options.length, 4);
      expect(question.correctAnswerIndex, greaterThanOrEqualTo(0));
      expect(question.correctAnswerIndex, lessThan(4));
      // Ensure the correct answer is one of the options
      expect(question.options[question.correctAnswerIndex], isNotEmpty);
    }
  });

  test('generateQuestions handles empty text gracefully', () async {
    final questions = await service.generateQuestions("");
    expect(questions, isEmpty);
  });
}
