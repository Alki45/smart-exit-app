import 'package:flutter/foundation.dart';
import '../../../quizzes/data/models/quiz_attempt_model.dart';

class StatsAggregationService {
  
  /// Calculates overall global accuracy across a list of attempts
  double computeOverallAccuracy(List<QuizAttemptModel> attempts) {
    if (attempts.isEmpty) return 0.0;
    
    int totalCorrect = 0;
    int totalQuestions = 0;
    
    for (var attempt in attempts) {
      totalCorrect += attempt.correctAnswers;
      totalQuestions += attempt.totalQuestions;
    }
    
    if (totalQuestions == 0) return 0.0;
    return (totalCorrect / totalQuestions) * 100.0;
  }

  /// Identifies weakest topics based on lowest accuracy and highest miss count
  /// Returns a sorted list of Maps with 'topic' and 'accuracy'/'misses' data.
  List<Map<String, dynamic>> identifyWeaknesses(List<QuizAttemptModel> attempts) {
    final Map<String, int> aggregateMisses = {};
    final Map<String, int> aggregateTotals = {};

    // Aggregate topic data across all attempts
    for (var attempt in attempts) {
      attempt.topicMisses.forEach((topic, misses) {
        aggregateMisses[topic] = (aggregateMisses[topic] ?? 0) + misses;
      });
      attempt.topicTotal.forEach((topic, total) {
        aggregateTotals[topic] = (aggregateTotals[topic] ?? 0) + total;
      });
    }

    final List<Map<String, dynamic>> weaknessList = [];

    aggregateTotals.forEach((topic, total) {
      if (total > 0) {
        int misses = aggregateMisses[topic] ?? 0;
        int correct = total - misses;
        double accuracy = (correct / total) * 100.0;
        
        weaknessList.add({
          'topic': topic,
          'total': total,
          'misses': misses,
          'accuracy': accuracy,
        });
      }
    });

    // Sort heavily weighting lowest accuracy, then highest misses
    weaknessList.sort((a, b) {
      double accA = a['accuracy'];
      double accB = b['accuracy'];
      if (accA != accB) {
        return accA.compareTo(accB); // Ascending (lowest accuracy first)
      } else {
        int missA = a['misses'];
        int missB = b['misses'];
        return missB.compareTo(missA); // Descending (highest misses first)
      }
    });

    return weaknessList;
  }

  /// Helper to map `incorrectQuestionIds` to topics to fill the AttemptModel
  /// (Called before saving the attempt if topicMisses/topicTotals aren't populated directly by UI)
  Map<String, dynamic> extractTopicStats(
    Map<String, int> userAnswers,
    List<dynamic> allQuestions // List<QuestionModel>
  ) {
    final Map<String, int> topicMisses = {};
    final Map<String, int> topicTotal = {};

    for (var question in allQuestions) {
      String topic = question.courseCode ?? question.topic ?? 'General';
      
      topicTotal[topic] = (topicTotal[topic] ?? 0) + 1;
      
      int? selectedIndex = userAnswers[question.id];
      bool isCorrect = selectedIndex == question.correctAnswerIndex;
      
      if (!isCorrect) {
        topicMisses[topic] = (topicMisses[topic] ?? 0) + 1;
      }
    }

    return {
      'topicMisses': topicMisses,
      'topicTotal': topicTotal,
    };
  }
}
