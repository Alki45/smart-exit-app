import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_model.dart';
import '../models/quiz_attempt_model.dart';
import '../models/question_model.dart';
import '../models/performance_summary_model.dart';

class QuizRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─────────────────────────────────────────────────────────
  // Quiz Attempts — users/{userId}/quiz_attempts/{attemptId}
  // ─────────────────────────────────────────────────────────

  Future<void> saveQuizAttempt(QuizAttemptModel attempt) async {
    await _firestore
        .collection('users')
        .doc(attempt.userId)
        .collection('quiz_attempts')
        .doc(attempt.id)
        .set(attempt.toMap());
  }

  Future<List<QuizAttemptModel>> getQuizHistory(String userId) async {
    final snap = await _firestore
        .collection('users')
        .doc(userId)
        .collection('quiz_attempts')
        .orderBy('timestamp', descending: true)
        .get();

    return snap.docs
        .map((doc) => QuizAttemptModel.fromMap(doc.data()))
        .toList();
  }

  // ─────────────────────────────────────────────────────────
  // Quizzes — users/{userId}/quizzes/{quizId}
  // ─────────────────────────────────────────────────────────

  Future<void> saveQuiz(String userId, QuizModel quiz) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('quizzes')
        .doc(quiz.id)
        .set(quiz.toMap());
  }

  Future<List<QuizModel>> getQuizzes(String userId,
      {String? courseId}) async {
    final col = _firestore
        .collection('users')
        .doc(userId)
        .collection('quizzes');

    final snap = courseId != null
        ? await col.where('courseId', isEqualTo: courseId).get()
        : await col.get();

    return snap.docs
        .map((doc) =>
            QuizModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<QuizModel?> getQuizById(String userId, String quizId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('quizzes')
        .doc(quizId)
        .get();

    return doc.exists
        ? QuizModel.fromMap(doc.data() as Map<String, dynamic>)
        : null;
  }

  // ─────────────────────────────────────────────────────────
  // Performance Summaries — performance_summaries/{id}
  // Top-level collection for fast cross-user dashboard queries.
  // ─────────────────────────────────────────────────────────

  Future<void> savePerformanceSummary(
      PerformanceSummaryModel summary) async {
    await _firestore
        .collection('performance_summaries')
        .doc(summary.id)
        .set(summary.toMap());
  }

  Future<List<PerformanceSummaryModel>> getPerformanceSummaries(
      String userId) async {
    final snap = await _firestore
        .collection('performance_summaries')
        .where('user_id', isEqualTo: userId)
        .get();

    return snap.docs
        .map((doc) =>
            PerformanceSummaryModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ─────────────────────────────────────────────────────────
  // Sample / Demo Data
  // ─────────────────────────────────────────────────────────

  List<QuizModel> getSampleQuizzes() {
    return [
      QuizModel(
        id: 'sample_1',
        courseId: 'cs_basics',
        title: 'Computer Science Fundamentals',
        duration: 10,
        createdAt: DateTime.now(),
        questions: [
          QuestionModel(
            id: 'q1',
            questionText: 'What does CPU stand for?',
            options: [
              'Central Processing Unit',
              'Computer Personal Unit',
              'Central Process Utility',
              'Common Parent Unit',
            ],
            correctAnswerIndex: 0,
            explanation:
                'CPU stands for Central Processing Unit, the main brain of the computer.',
            courseCode: 'cs_basics',
          ),
          QuestionModel(
            id: 'q2',
            questionText: 'Which data structure follows LIFO?',
            options: ['Queue', 'Stack', 'Linked List', 'Array'],
            correctAnswerIndex: 1,
            explanation:
                'Stack follows Last-In-First-Out (LIFO) principle.',
            courseCode: 'cs_basics',
          ),
          QuestionModel(
            id: 'q3',
            questionText:
                'What is the primary purpose of an Operating System?',
            options: [
              'Word processing',
              'Managing hardware and software resources',
              'Browsing the internet',
              'Creating graphics',
            ],
            correctAnswerIndex: 1,
            explanation:
                'An OS manages hardware and software resources for programs.',
            courseCode: 'cs_basics',
          ),
        ],
      ),
      QuizModel(
        id: 'sample_2',
        courseId: 'se_basics',
        title: 'Software Engineering Concepts',
        duration: 15,
        createdAt: DateTime.now(),
        questions: [
          QuestionModel(
            id: 's1',
            questionText:
                'Which model is a sequential software development process?',
            options: ['Agile', 'Scrum', 'Waterfall', 'Spiral'],
            correctAnswerIndex: 2,
            explanation:
                'The Waterfall model is a linear sequential flow.',
            courseCode: 'se_basics',
          ),
          QuestionModel(
            id: 's2',
            questionText: 'What does OOP stand for?',
            options: [
              'Object Oriented Programming',
              'Oracle Output Process',
              'Over One Process',
              'Object Oriented Protocol',
            ],
            correctAnswerIndex: 0,
            explanation:
                'OOP stands for Object-Oriented Programming.',
            courseCode: 'se_basics',
          ),
        ],
      ),
    ];
  }
}
