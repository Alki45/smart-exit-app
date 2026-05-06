import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'ai_service.dart';
import '../../features/quizzes/data/models/question_model.dart';

class QuestionGeneratorService {
  final AIService _aiService = AIService();

  /// Generates a list of questions from the provided [text] using AI, aligned with [outcomes].
  Future<List<QuestionModel>> generateQuestions(String text, {int limit = 10, List<String>? outcomes}) async {
    if (!_aiService.isEnabled) {
      debugPrint('AI Service is disabled. Cannot generate questions.');
      return [];
    }

    try {
      final jsonResponse = await _aiService.generateQuizJson(text, count: limit, outcomes: outcomes);
      
      if (jsonResponse != null) {
        String cleanJson = jsonResponse.replaceAll('```json', '').replaceAll('```', '').trim();
        final List<dynamic> decoded = json.decode(cleanJson);
        
        return decoded.asMap().entries.map((entry) {
          final int index = entry.key;
          final Map<String, dynamic> data = Map<String, dynamic>.from(entry.value);
          
          return QuestionModel(
            id: DateTime.now().millisecondsSinceEpoch.toString() + index.toString(),
            questionText: data['questionText'] ?? '',
            options: List<String>.from(data['options'] ?? []),
            correctAnswerIndex: data['correctAnswerIndex'] ?? 0,
            explanation: data['explanation'] ?? '',
            topic: data['topic'],
            domain: data['domain'],
            cognitiveLevel: data['cognitiveLevel'],
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Error generating questions with AI: $e');
    }
    
    return []; // Return empty list on failure
  }
}
