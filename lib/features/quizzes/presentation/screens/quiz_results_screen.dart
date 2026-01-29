import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/quiz_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../progress/presentation/providers/progress_provider.dart';
import '../../../../core/constants/app_routes.dart';

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
                      
                      // Topic Analysis
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Performance by Topic', style: AppTextStyles.h4),
                      ),
                      const SizedBox(height: 12),
                      ...provider.getTopicPerformance().entries.map((entry) {
                        final topic = entry.key;
                        final correct = entry.value['correct']!;
                        final total = entry.value['total']!;
                        final percent = correct / total;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(topic, style: AppTextStyles.bodyMedium),
                                  Text('$correct/$total', style: AppTextStyles.bodySmall),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: percent,
                                backgroundColor: AppColors.cardBackgroundLight,
                                color: percent >= 0.8 ? Colors.green : (percent >= 0.5 ? AppColors.cyan : Colors.red),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 32),
                      
                      // Analysis & Recommendations
                      if (provider.history.isNotEmpty) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Personalized Recommendations', style: AppTextStyles.h4),
                        ),
                        const SizedBox(height: 12),
                        ...provider.history.first.recommendations.map((rec) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackgroundLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cyan.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.lightbulb_outline, color: AppColors.cyan, size: 24),
                                const SizedBox(width: 16),
                                Expanded(child: Text(rec, style: AppTextStyles.bodyMedium)),
                              ],
                            ),
                          ),
                        )).toList(),
                      ],

                      const SizedBox(height: 32),
                      
                      CustomButton(
                         text: 'Review Answers',
                         onPressed: () {
                             if (provider.history.isNotEmpty && provider.activeQuiz != null) {
                               Navigator.pushNamed(
                                 context, 
                                 AppRoutes.quizReview,
                                 arguments: {
                                   'attempt': provider.history.first,
                                   'quiz': provider.activeQuiz,
                                 },
                               );
                             } else {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text('No results to review')),
                               );
                             }
                         },
                         type: ButtonType.outline,
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                         text: 'Back to Home',
                         onPressed: () {
                             Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
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
