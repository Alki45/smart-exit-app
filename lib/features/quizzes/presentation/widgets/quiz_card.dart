import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';

class QuizCard extends StatelessWidget {
  final String title;
  final int questionCount;
  final int durationMinutes;
  final VoidCallback onTap;

  const QuizCard({
    Key? key,
    required this.title,
    required this.questionCount,
    required this.durationMinutes,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColorLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.h4,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                 decoration: BoxDecoration(
                    color: AppColors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                 ),
                 child: Text(
                    '$durationMinutes min',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.purpleLight),
                 ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
             children: [
                Icon(Icons.format_list_bulleted, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text('$questionCount Questions', style: AppTextStyles.bodySmall),
             ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Start Quiz',
              onPressed: onTap,
              height: 40,
              type: ButtonType.outline,
            ),
          ),
        ],
      ),
    );
  }
}
