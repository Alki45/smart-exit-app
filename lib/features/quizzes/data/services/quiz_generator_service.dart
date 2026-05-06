import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/ai_service.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';

class QuizGeneratorService {
  final AIService _aiService;
  final Uuid _uuid = const Uuid();

  QuizGeneratorService(this._aiService);

  /// Generates a Fixed-Size Practice Quiz based on Blueprint weights
  Future<QuizModel?> generatePracticeQuiz({
    required Map<String, dynamic> blueprint,
    required String courseId,
    required int targetQuizCount,
    String scope = 'quick_practice',
    List<String> weakTopics = const [],
  }) async {
    try {
      final List<Map<String, dynamic>> courses = _extractCoursesFromBlueprint(blueprint);
      if (courses.isEmpty) return null;

      // Calculate counts using course_share_percent
      int remainingCount = targetQuizCount;
      Map<String, int> countsMap = {};
      List<Map<String, dynamic>> coursesWithRemainders = [];

      for (var course in courses) {
        double weight = (course['course_share_percent'] ?? 0) / 100.0;
        
        // Focus Session Logic: artificially inflate the weight for weak topics
        if (weakTopics.contains(course['course_code'])) {
          weight *= 1.5; // Boost weak areas
        }
      }

      // Re-normalize weights if they exceed 100% after boosting
      double totalWeight = courses.fold(0.0, (sum, c) {
        double w = (c['course_share_percent'] ?? 0) / 100.0;
        if (weakTopics.contains(c['course_code'])) w *= 1.5;
        return sum + w;
      });

      for (var course in courses) {
        double rawWeight = (course['course_share_percent'] ?? 0) / 100.0;
        if (weakTopics.contains(course['course_code'])) rawWeight *= 1.5;
        
        double normalizedWeight = totalWeight > 0 ? (rawWeight / totalWeight) : 0;
        double exactCount = normalizedWeight * targetQuizCount;
        int floorCount = exactCount.floor();
        
        countsMap[course['course_code']] = floorCount;
        remainingCount -= floorCount;
        
        coursesWithRemainders.add({
          'course_code': course['course_code'],
          'remainder': exactCount - floorCount,
        });
      }

      // Distribute remaining counts to those with the highest remainders
      coursesWithRemainders.sort((a, b) => (b['remainder'] as double).compareTo(a['remainder'] as double));
      for (int i = 0; i < remainingCount; i++) {
        if (i < coursesWithRemainders.length) {
          countsMap[coursesWithRemainders[i]['course_code']] = (countsMap[coursesWithRemainders[i]['course_code']] ?? 0) + 1;
        }
      }

      // Generate Questions
      List<QuestionModel> generatedQuestions = [];
      for (var course in courses) {
        int count = countsMap[course['course_code']] ?? 0;
        if (count > 0) {
          final questions = await _generateQuestionsForCourse(course, count);
          generatedQuestions.addAll(questions);
        }
      }

      // Build QuizModel
      return QuizModel(
        id: _uuid.v4(),
        courseId: courseId,
        title: scope == 'focus_session' ? 'Targeted Focus Session' : 'Practice Quiz',
        questions: generatedQuestions,
        duration: generatedQuestions.length * 1, // 1 min per question
        createdAt: DateTime.now(),
        isMockExam: false,
        blueprintId: blueprint['id'] ?? 'unknown',
        scope: scope,
      );

    } catch (e) {
      debugPrint('Error generating practice quiz: $e');
      return null;
    }
  }

  /// Generates a Full Mock Exam matching 100% of the Blueprint item counts
  Future<QuizModel?> generateMockExam({
    required Map<String, dynamic> blueprint,
    required String courseId,
  }) async {
    try {
      final List<Map<String, dynamic>> courses = _extractCoursesFromBlueprint(blueprint);
      if (courses.isEmpty) return null;

      List<QuestionModel> generatedQuestions = [];
      for (var course in courses) {
        int count = course['item_count'] ?? 0;
        if (count > 0) {
          final questions = await _generateQuestionsForCourse(course, count);
          generatedQuestions.addAll(questions);
        }
      }

      return QuizModel(
        id: _uuid.v4(),
        courseId: courseId,
        title: 'Full Mock Exam',
        questions: generatedQuestions,
        duration: generatedQuestions.length * 1,
        createdAt: DateTime.now(),
        isMockExam: true,
        blueprintId: blueprint['id'] ?? 'unknown',
        scope: 'mock_exam',
      );
    } catch (e) {
      debugPrint('Error generating mock exam: $e');
      return null;
    }
  }

  List<Map<String, dynamic>> _extractCoursesFromBlueprint(Map<String, dynamic> blueprint) {
    final List<Map<String, dynamic>> allCourses = [];
    if (blueprint.containsKey('themes')) {
      for (var theme in blueprint['themes']) {
        if (theme.containsKey('courses')) {
          allCourses.addAll(List<Map<String, dynamic>>.from(theme['courses']));
        }
      }
    }
    return allCourses;
  }

  Future<List<QuestionModel>> _generateQuestionsForCourse(Map<String, dynamic> course, int count) async {
    List<String> outcomes = List<String>.from(course['learning_outcomes'] ?? []);
    String promptContext = "Course: ${course['course_name']} (${course['course_code']})";
    
    // Call existing AI Service (Requires tweaking the materialText if actual docs are present)
    // For blueprint generation without a bank, we just use the blueprint topic as context.
    final jsonResult = await _aiService.generateQuizJson(promptContext, count: count, outcomes: outcomes);
    
    if (jsonResult != null) {
      try {
        String cleanJson = jsonResult.replaceAll('```json', '').replaceAll('```', '').trim();
        List<dynamic> parsed = json.decode(cleanJson);
        
        return parsed.map((q) => QuestionModel(
          id: _uuid.v4(),
          // Attach the parent course FK and mark as AI-generated
          courseId: course['id'] ?? course['course_code'],
          questionText: q['questionText'] ?? '',
          options: List<String>.from(q['options'] ?? []),
          correctAnswerIndex: q['correctAnswerIndex'] ?? 0,
          explanation: q['explanation'],
          topic: course['course_name'],
          courseCode: course['course_code'],
          domain: q['domain'],
          cognitiveLevel: q['cognitiveLevel'],
          isAiGenerated: true,
        )).toList();
      } catch (e) {
        debugPrint('Failed to parse questions for ${course['course_code']}: $e');
      }
    }
    return [];
  }
}
