import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/quiz_provider.dart';
import '../../../progress/presentation/providers/progress_provider.dart';


class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late QuizProvider _quizProvider;

  @override
  void initState() {
    super.initState();
    _quizProvider = Provider.of<QuizProvider>(context, listen: false);
    _quizProvider.addListener(_onProviderUpdate);
  }

  void _onProviderUpdate() {
    if (!_quizProvider.isQuizActive && mounted) {
      _submitQuiz();
    }
  }

  @override
  void dispose() {
    _quizProvider.removeListener(_onProviderUpdate);
    super.dispose();
  }

  void _submitQuiz() {
    Navigator.pushReplacementNamed(context, '/quiz-results');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<QuizProvider>(
        builder: (context, provider, _) {
          final quiz = provider.activeQuiz;
          if (quiz == null) {
            return const Center(child: Text('Error loading quiz'));
          }
          
          final question = quiz.questions[provider.currentQuestionIndex];
          final total = quiz.questions.length;
          final current = provider.currentQuestionIndex + 1;
          
          return SafeArea(
            child: Column(
              children: [
                // Header: Progress & Timer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question $current/$total',
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.cyan),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackgroundLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                             const Icon(Icons.timer, size: 16, color: AppColors.textSecondary),
                             const SizedBox(width: 4),
                             Text(provider.timerString, style: AppTextStyles.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Progress Bar
                LinearProgressIndicator(
                   value: current / total,
                   backgroundColor: AppColors.cardBackground,
                   valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cyan),
                   minHeight: 4,
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                         Text(
                           question.questionText,
                           style: AppTextStyles.h4,
                         ),
                         const SizedBox(height: 32),
                         
                         ...List.generate(question.options.length, (index) {
                            final choice = question.options[index];
                            final isSelected = provider.userAnswers[question.id] == index;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: InkWell(
                                onTap: () => provider.selectAnswer(question.id, index),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.purple.withOpacity(0.2) : AppColors.cardBackground,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? AppColors.purple : AppColors.borderColor,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                       Container(
                                         width: 24,
                                         height: 24,
                                         decoration: BoxDecoration(
                                           color: isSelected ? AppColors.purple : Colors.transparent,
                                           shape: BoxShape.circle,
                                           border: Border.all(
                                             color: isSelected ? AppColors.purple : AppColors.textTertiary,
                                           ),
                                         ),
                                         child: isSelected 
                                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                                            : null,
                                       ),
                                       const SizedBox(width: 16),
                                       Expanded(
                                         child: Text(
                                           choice,
                                           style: AppTextStyles.bodyLarge.copyWith(
                                             color: isSelected ? Colors.white : AppColors.textSecondary,
                                           ),
                                         ),
                                       ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                         }),
                      ],
                    ),
                  ),
                ),
                
                // Footer Navigation
                Padding(
                   padding: const EdgeInsets.all(16),
                   child: Row(
                      children: [
                         if (current > 1)
                           Expanded(
                             child: CustomButton(
                               text: 'Previous',
                               onPressed: provider.previousQuestion,
                               type: ButtonType.outline,
                             ),
                           ),
                         if (current > 1) const SizedBox(width: 16),
                         Expanded(
                           child: CustomButton(
                             text: current == total ? 'Submit' : 'Next',
                             onPressed: () {
                                if (current == total) {
                                   // Calculate Score
                                   final score = provider.calculateScore();
                                   
                                   // Record Progress
                                   Provider.of<ProgressProvider>(context, listen: false).recordQuizCompletion(score);

                                   provider.endQuiz();
                                   Navigator.pushReplacementNamed(context, '/quiz-results');
                                } else {
                                   provider.nextQuestion();
                                }
                             },
                           ),
                         ),
                      ],
                   ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
