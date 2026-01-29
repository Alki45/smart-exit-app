import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_model.dart';
import '../models/quiz_attempt_model.dart';
import '../models/question_model.dart';

class QuizRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveQuizAttempt(QuizAttemptModel attempt) async {
    await _firestore
        .collection('users')
        .doc(attempt.userId)
        .collection('quiz_attempts')
        .doc(attempt.id)
        .set(attempt.toMap());
  }

  Future<void> saveQuiz(String userId, QuizModel quiz) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('quizzes')
        .doc(quiz.id)
        .set(quiz.toMap());
  }

  Future<List<QuizAttemptModel>> getQuizHistory(String userId) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('quiz_attempts')
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => QuizAttemptModel.fromMap(doc.data()))
        .toList();
  }

  Future<List<QuizModel>> getQuizzes(String userId, {String? courseId}) async {
    var query = _firestore
        .collection('users')
        .doc(userId)
        .collection('quizzes');
    
    QuerySnapshot snapshot;
    if (courseId != null) {
      snapshot = await query.where('courseId', isEqualTo: courseId).get();
    } else {
      snapshot = await query.get();
    }

    return snapshot.docs
        .map((doc) => QuizModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<QuizModel?> getQuizById(String userId, String quizId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('quizzes')
        .doc(quizId)
        .get();

    if (doc.exists) {
      return QuizModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

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
            options: ['Central Processing Unit', 'Computer Personal Unit', 'Central Process Utility', 'Common Parent Unit'],
            correctAnswerIndex: 0,
            explanation: 'CPU stands for Central Processing Unit, the main brain of the computer.',
          ),
          QuestionModel(
            id: 'q2',
            questionText: 'Which data structure follows LIFO?',
            options: ['Queue', 'Stack', 'Linked List', 'Array'],
            correctAnswerIndex: 1,
            explanation: 'Stack follows Last-In-First-Out (LIFO) principle.',
          ),
          QuestionModel(
            id: 'q3',
            questionText: 'What is the primary purpose of an Operating System?',
            options: ['Word processing', 'Managing hardware and software resources', 'Browsing the internet', 'Creating graphics'],
            correctAnswerIndex: 1,
            explanation: 'An Operating System manages computer hardware and software resources and provides common services for computer programs.',
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
            questionText: 'Which model is a sequential software development process?',
            options: ['Agile', 'Scrum', 'Waterfall', 'Spiral'],
            correctAnswerIndex: 2,
            explanation: 'The Waterfall model is a linear sequential flow.',
          ),
          QuestionModel(
            id: 's2',
            questionText: 'What does OOP stand for?',
            options: ['Object Oriented Programming', 'Oracle Output Process', 'Over One Process', 'Object Oriented Protocol'],
            correctAnswerIndex: 0,
            explanation: 'OOP stands for Object-Oriented Programming.',
          ),
        ],
      ),
    ];
  }
}
