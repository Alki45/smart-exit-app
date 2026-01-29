import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/quiz_model.dart';
import '../../data/models/question_model.dart';
import '../../data/models/quiz_attempt_model.dart';
import '../../data/repositories/quiz_repository.dart';

class QuizProvider extends ChangeNotifier {
  final QuizRepository _repository = QuizRepository();
  
  List<QuizModel> _courseQuizzes = [];
  List<QuizAttemptModel> _history = [];
  bool _isLoading = false;
  
  // Active Quiz State
  QuizModel? _activeQuiz;
  int _currentQuestionIndex = 0;
  Map<String, int> _userAnswers = {}; // QuestionId -> OptionIndex
  int _timeRemaining = 0; // Seconds
  bool _isQuizActive = false;
  Timer? _timer;
  
  // Getters
  List<QuizModel> get courseQuizzes => _courseQuizzes;
  List<QuizAttemptModel> get history => _history;
  bool get isLoading => _isLoading;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get totalQuestions => _activeQuiz?.questions.length ?? 0;
  QuizModel? get activeQuiz => _activeQuiz;
  Map<String, int> get userAnswers => _userAnswers;
  bool get isQuizActive => _isQuizActive;
  int get timeRemaining => _timeRemaining;
  
  String get timerString {
    final minutes = (_timeRemaining / 60).floor();
    final seconds = _timeRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  // Load quizzes for a specific course
  Future<void> loadQuizzesForCourse(String userId, String courseId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _courseQuizzes = await _repository.getQuizzes(userId, courseId: courseId);
      
      // If no quizzes found for this course, show sample ones
      if (_courseQuizzes.isEmpty) {
        _courseQuizzes = _repository.getSampleQuizzes();
      }
    } catch (e) {
      debugPrint('Error loading quizzes: $e');
      _courseQuizzes = _repository.getSampleQuizzes();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Load user quiz history
  Future<void> loadHistory(String userId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _history = await _repository.getQuizHistory(userId);
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveQuiz(String userId, QuizModel quiz) async {
    try {
      await _repository.saveQuiz(userId, quiz);
      _courseQuizzes.add(quiz);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving quiz: $e');
    }
  }
  
  void startQuiz(QuizModel quiz) {
    _activeQuiz = quiz;
    _currentQuestionIndex = 0;
    _userAnswers = {};
    _timeRemaining = quiz.duration * 60;
    _isQuizActive = true;
    
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        _timeRemaining--;
        notifyListeners();
      } else {
        _timer?.cancel();
        _isQuizActive = false;
        notifyListeners();
        // Auto-submit should be handled by UI listening to isQuizActive or an event
      }
    });
  }
  
  void selectAnswer(String questionId, int optionIndex) {
    _userAnswers[questionId] = optionIndex;
    notifyListeners();
  }
  
  void nextQuestion() {
    if (_activeQuiz != null && _currentQuestionIndex < _activeQuiz!.questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }
  
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }
  
  double calculateScore() {
    if (_activeQuiz == null) return 0.0;
    
    int correctCount = correctAnswersCount;
    return (correctCount / _activeQuiz!.questions.length) * 100;
  }
  
  int get correctAnswersCount {
    if (_activeQuiz == null) return 0;
    int correctCount = 0;
    for (var question in _activeQuiz!.questions) {
      if (_userAnswers[question.id] == question.correctAnswerIndex) {
        correctCount++;
      }
    }
    return correctCount;
  }

  Map<String, Map<String, int>> getTopicPerformance() {
    if (_activeQuiz == null) return {};
    
    final Map<String, Map<String, int>> stats = {}; // Topic -> {correct: X, total: Y}
    
    for (var question in _activeQuiz!.questions) {
      final topic = question.topic ?? 'General';
      if (!stats.containsKey(topic)) {
        stats[topic] = {'correct': 0, 'total': 0};
      }
      
      stats[topic]!['total'] = stats[topic]!['total']! + 1;
      if (_userAnswers[question.id] == question.correctAnswerIndex) {
        stats[topic]!['correct'] = stats[topic]!['correct']! + 1;
      }
    }
    
    return stats;
  }

  List<String> _generateRecommendations() {
    if (_activeQuiz == null) return [];
    
    final Map<String, int> mistakesPerTopic = {};
    for (var question in _activeQuiz!.questions) {
      if (_userAnswers[question.id] != question.correctAnswerIndex) {
        String topic = question.topic ?? 'General';
        mistakesPerTopic[topic] = (mistakesPerTopic[topic] ?? 0) + 1;
      }
    }

    if (mistakesPerTopic.isEmpty) return ['Excellent understanding! Keep up the good work.'];

    return mistakesPerTopic.entries.map((e) {
      if (e.value > 1) {
        return 'Review "${e.key}" thoroughly - you missed multiple questions here.';
      } else {
        return 'Take another look at "${e.key}" to perfect your knowledge.';
      }
    }).toList();
  }

  Future<void> saveQuizAttempt(String userId) async {
    if (_activeQuiz == null) return;

    final incorrectIds = _activeQuiz!.questions
        .where((q) => _userAnswers[q.id] != q.correctAnswerIndex)
        .map((q) => q.id)
        .toList();

    final attempt = QuizAttemptModel(
      id: const Uuid().v4(),
      userId: userId,
      quizId: _activeQuiz!.id,
      quizTitle: _activeQuiz!.title,
      score: calculateScore(),
      correctAnswers: correctAnswersCount,
      totalQuestions: totalQuestions,
      timestamp: DateTime.now(),
      userAnswers: Map<String, int>.from(_userAnswers),
      incorrectQuestionIds: incorrectIds,
      recommendations: _generateRecommendations(),
    );

    try {
      await _repository.saveQuizAttempt(attempt);
      _history.insert(0, attempt);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving quiz attempt: $e');
    }
  }

  Future<QuizModel?> getQuizById(String userId, String quizId) async {
    // Check local list first
    try {
      final localQuiz = _courseQuizzes.firstWhere((q) => q.id == quizId);
      return localQuiz;
    } catch (_) {
      // Fetch from remote
      return await _repository.getQuizById(userId, quizId);
    }
  }

  void endQuiz() {
    _timer?.cancel();
    _isQuizActive = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
