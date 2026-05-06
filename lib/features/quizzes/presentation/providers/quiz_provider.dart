import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../courses/data/models/course_model.dart';
import '../../data/models/quiz_model.dart';
import '../../data/models/question_model.dart';
import '../../data/models/quiz_attempt_model.dart';
import '../../data/models/response_log_model.dart';
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

  Map<String, Map<String, int>> get globalTopicPerformance {
    final Map<String, Map<String, int>> stats = {};
    for (var attempt in _history) {
      // In a real app, attempts would have topic breakdown. 
      // For now, we'll use the quiz title as a proxy topic or mock some data if history exists.
      final topic = attempt.quizTitle.split(':').last.trim();
      stats.putIfAbsent(topic, () => {'correct': 0, 'total': 0});
      stats[topic]!['correct'] = stats[topic]!['correct']! + attempt.correctAnswers;
      stats[topic]!['total'] = stats[topic]!['total']! + attempt.totalQuestions;
    }
    return stats;
  }
  
  // Load quizzes for a specific course
  Future<void> loadQuizzesForCourse(String userId, String courseId, {bool isDemo = false}) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (isDemo) {
        _courseQuizzes = _repository.getSampleQuizzes();
      } else {
        _courseQuizzes = await _repository.getQuizzes(userId, courseId: courseId);
      }
    } catch (e) {
      debugPrint('Error loading quizzes: $e');
      if (isDemo) _courseQuizzes = _repository.getSampleQuizzes();
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
      if (userId != 'demo_user') {
        await _repository.saveQuiz(userId, quiz);
      }
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
        endQuiz();
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
    return (correctAnswersCount / _activeQuiz!.questions.length) * 100;
  }
  
  int get correctAnswersCount {
    if (_activeQuiz == null) return 0;
    int count = 0;
    for (var q in _activeQuiz!.questions) {
      if (_userAnswers[q.id] == q.correctAnswerIndex) count++;
    }
    return count;
  }

  Map<String, Map<String, int>> getTopicPerformance() {
    if (_activeQuiz == null) return {};
    final Map<String, Map<String, int>> stats = {};
    for (var q in _activeQuiz!.questions) {
      final t = q.topic ?? 'General';
      stats.putIfAbsent(t, () => {'correct': 0, 'total': 0});
      stats[t]!['total'] = stats[t]!['total']! + 1;
      if (_userAnswers[q.id] == q.correctAnswerIndex) stats[t]!['correct'] = stats[t]!['correct']! + 1;
    }
    return stats;
  }

  Future<void> saveQuizAttempt(String userId) async {
    if (_activeQuiz == null) return;
    const uuid = Uuid();
    final now = DateTime.now();
    final attemptId = uuid.v4();

    // Determine quiz type from quiz metadata
    final quizType = _activeQuiz!.isMockExam
        ? 'Mock Exam'
        : (_activeQuiz!.scope == 'focus_session'
            ? 'Focus Session'
            : 'Practice Quiz');

    // Build per-question response log
    final responses = _activeQuiz!.questions.map((q) {
      final selectedIdx = _userAnswers[q.id];
      return ResponseLogModel(
        id: uuid.v4(),
        attemptId: attemptId,
        questionId: q.id,
        isCorrect: selectedIdx == q.correctAnswerIndex,
        selectedOptionId:
            selectedIdx != null ? '${q.id}_opt_$selectedIdx' : null,
      );
    }).toList();

    final attempt = QuizAttemptModel(
      id: attemptId,
      userId: userId,
      quizId: _activeQuiz!.id,
      quizTitle: _activeQuiz!.title,
      quizType: quizType,
      score: calculateScore(),
      correctAnswers: correctAnswersCount,
      totalQuestions: totalQuestions,
      timestamp: now,
      completedAt: now,
      userAnswers: Map<String, int>.from(_userAnswers),
      incorrectQuestionIds: _activeQuiz!.questions
          .where((q) => _userAnswers[q.id] != q.correctAnswerIndex)
          .map((q) => q.id)
          .toList(),
      recommendations: [],
      responses: responses,
    );
    try {
      if (userId != 'demo_user') {
        await _repository.saveQuizAttempt(attempt);
      }
      _history.insert(0, attempt);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving attempt: $e');
    }
  }

  // Generate a Full Mock Exam based on Blueprint weights
  Future<QuizModel?> generateMockExam(String userId, List<CourseModel> userCourses) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final List<QuestionModel> allQuestions = [];
      
      for (var course in userCourses) {
        // Fetch existing quizzes for this course
        final courseQuizzes = await _repository.getQuizzes(userId, courseId: course.id);
        if (courseQuizzes.isNotEmpty) {
          int shareCount = course.itemShareCount ?? 1; // Default to 7 if not specified
          final sourceQuestions = courseQuizzes.expand((q) => q.questions).toList();
          sourceQuestions.shuffle();
          allQuestions.addAll(sourceQuestions.take(shareCount));
        }
      }
      
      if (allQuestions.isEmpty) throw Exception("No quiz data available to build mock exam.");

      final mockQuiz = QuizModel(
        id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
        courseId: 'all_courses',
        title: 'Full National Exit Exam Mock',
        questions: allQuestions,
        duration: 120, // National standard 120-150 mins
        createdAt: DateTime.now(),
        isMockExam: true,
        isCourseSpecific: false,
      );
      
      _activeQuiz = mockQuiz;
      _isLoading = false;
      notifyListeners();
      return mockQuiz;
    } catch (e) {
      debugPrint('Error generating mock exam: $e');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<QuizModel?> getQuizById(String userId, String quizId) async {
    try {
      return await _repository.getQuizById(userId, quizId);
    } catch (_) {
      return null;
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
