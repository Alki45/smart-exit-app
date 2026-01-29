import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../data/models/quiz_attempt_model.dart';
import '../../data/models/quiz_model.dart';

class QuizReviewScreen extends StatelessWidget {
  final QuizAttemptModel attempt;
  final QuizModel quiz;

  const QuizReviewScreen({
    Key? key,
    required this.attempt,
    required this.quiz,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Answers'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Score', '${attempt.score.toInt()}%', AppColors.purple),
                _buildStatItem('Correct', '${attempt.correctAnswers}/${attempt.totalQuestions}', Colors.green),
                _buildStatItem('Incorrect', '${attempt.totalQuestions - attempt.correctAnswers}', Colors.red),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: quiz.questions.length,
              itemBuilder: (context, index) {
                final question = quiz.questions[index];
                final userAnswerIndex = attempt.userAnswers[question.id];
                final isCorrect = userAnswerIndex == question.correctAnswerIndex;

                return Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isCorrect ? Icons.check : Icons.close,
                                color: isCorrect ? Colors.green : Colors.red,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Question ${index + 1}',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isCorrect ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          question.questionText,
                          style: AppTextStyles.h4,
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(question.options.length, (optIndex) {
                          final isUserChoice = userAnswerIndex == optIndex;
                          final isCorrectChoice = question.correctAnswerIndex == optIndex;

                          Color borderColor = Colors.transparent;
                          Color bgColor = AppColors.cardBackgroundLight;
                          IconData? icon;

                          if (isCorrectChoice) {
                            borderColor = Colors.green;
                            bgColor = Colors.green.withOpacity(0.1);
                            icon = Icons.check_circle;
                          } else if (isUserChoice && !isCorrect) {
                            borderColor = Colors.red;
                            bgColor = Colors.red.withOpacity(0.1);
                            icon = Icons.cancel;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    question.options[optIndex],
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: isCorrectChoice ? Colors.green : (isUserChoice ? Colors.red : null),
                                      fontWeight: (isCorrectChoice || isUserChoice) ? FontWeight.bold : null,
                                    ),
                                  ),
                                ),
                                if (icon != null)
                                  Icon(icon, color: borderColor, size: 20),
                              ],
                            ),
                          );
                        }),
                        if (question.explanation != null && question.explanation!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.purple.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.purple.withOpacity(0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.info_outline, color: AppColors.purple, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Explanation',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.purple,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  question.explanation!,
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h3.copyWith(color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
