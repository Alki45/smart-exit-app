import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/quiz_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../progress/presentation/providers/progress_provider.dart';

class QuizResultsScreen extends StatefulWidget {
  const QuizResultsScreen({Key? key}) : super(key: key);

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _saveProgress();
  }

  void _saveProgress() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      final score = quizProvider.calculateScore();
      
      // Save to history (Firestore)
      await quizProvider.saveQuizAttempt(authProvider.currentUser!.id);
      
      // Record progress (Local Hive)
      progressProvider.recordQuizCompletion(score);
      
      if (mounted) {
        setState(() {
          _isSaved = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: const Text('Result'),
         automaticallyImplyLeading: false,
      ),
      body: Consumer<QuizProvider>(
         builder: (context, provider, _) {
            final score = provider.calculateScore();
            final correct = provider.correctAnswersCount;
            final total = provider.totalQuestions;
            
            return SingleChildScrollView(
               padding: const EdgeInsets.all(24),
               child: Column(
                  children: [
                      // Score Card
                      Container(
                         padding: const EdgeInsets.all(32),
                         decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                            boxShadow: [
                               BoxShadow(
                                  color: AppColors.purple.withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                            ],
                         ),
                         child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                               Text(
                                  '${score.toInt()}%',
                                  style: AppTextStyles.h1.copyWith(fontSize: 48, color: Colors.white),
                               ),
                               Text(
                                  'Score',
                                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                               ),
                            ],
                         ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                         score >= 80 ? 'Excellent Job!' : 'Keep Practicing!',
                         style: AppTextStyles.h2.copyWith(color: AppColors.cyan),
                      ),
                      const SizedBox(height: 8),
                      Text(
                         'You answered $correct out of $total questions correctly.',
                         style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                         textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 12),
                      if (!_isSaved)
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                            SizedBox(width: 8),
                            Text('Saving results...', style: TextStyle(color: Colors.white70)),
                          ],
                        )
                      else
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 16),
                            SizedBox(width: 8),
                            Text('Results saved to history', style: TextStyle(color: Colors.green)),
                          ],
                        ),

                      const SizedBox(height: 32),
                      
                      CustomButton(
                         text: 'Review Answers',
                         onPressed: () {
                             // Navigate to review
                         },
                         type: ButtonType.outline,
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                         text: 'Back to Home',
                         onPressed: () {
                             Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                         },
                      ),
                  ],
               ),
            );
         },
      ),
    );
  }
}
