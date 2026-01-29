import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../data/models/quiz_model.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/quiz_provider.dart';
import '../widgets/quiz_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class QuizListScreen extends StatefulWidget {
  final String courseId; // Passed via arguments usually
  
  const QuizListScreen({Key? key, required this.courseId}) : super(key: key);

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null) {
        Provider.of<QuizProvider>(context, listen: false)
            .loadQuizzesForCourse(auth.currentUser!.id, widget.courseId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<QuizProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.courseQuizzes.isEmpty) {
             return Center(
                child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                       Icon(Icons.assignment_outlined, size: 64, color: AppColors.textTertiary),
                       const SizedBox(height: 16),
                       Text('No quizzes available', style: AppTextStyles.bodyLarge),
                   ],
                ),
             );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.courseQuizzes.length,
            itemBuilder: (context, index) {
              final quiz = provider.courseQuizzes[index];
              return QuizCard(
                title: quiz.title,
                questionCount: quiz.questions.length,
                durationMinutes: quiz.duration,
                onTap: () {
                   // Start quiz logic
                   provider.startQuiz(quiz);
                   Navigator.pushNamed(context, '/take-quiz'); // Need to register route
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
            // Generate/Create Quiz Screen
        },
        child: const Icon(Icons.add),
        tooltip: 'Create Quiz',
      ),
    );
  }
}
