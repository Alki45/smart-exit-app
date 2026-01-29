import 'package:flutter/material.dart';
import '../../data/services/progress_service.dart';

class ProgressProvider extends ChangeNotifier {
  final ProgressService _service = ProgressService();
  
  int _streak = 0;
  int _quizzesTaken = 0;
  double _averageScore = 0.0;
  
  int get streak => _streak;
  int get quizzesTaken => _quizzesTaken;
  double get averageScore => _averageScore;
  
  ProgressProvider() {
    _loadStats();
    _checkStreak();
  }
  
  void _loadStats() {
    _streak = _service.getStreak();
    _quizzesTaken = _service.getQuizzesTaken();
    _averageScore = _service.getAverageScore();
    notifyListeners();
  }
  
  void _checkStreak() {
    _service.updateStreak();
    _streak = _service.getStreak();
    notifyListeners();
  }
  
  void recordQuizCompletion(double score) {
    _service.incrementQuizzesTaken(score);
    _service.updateStreak(); // Ensure streak is updated if this is first activity
    _loadStats(); // Reload all stats
  }
}
