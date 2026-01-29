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

  Future<void> saveQuizAttempt(String userId) async {
    if (_activeQuiz == null) return;

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
    );

    try {
      await _repository.saveQuizAttempt(attempt);
      _history.insert(0, attempt);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving quiz attempt: $e');
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
