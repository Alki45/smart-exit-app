import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../progress/presentation/providers/progress_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/exam_countdown_card.dart';
import '../widgets/streak_milestone_card.dart';
import '../widgets/next_exam_card.dart';

/// 3-part exam milestones section: countdown + streak + next exam.
class ExamMilestonesSection extends StatelessWidget {
  const ExamMilestonesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProgressProvider, AuthProvider>(
      builder: (_, progress, auth, __) {
        final examDate = auth.currentUser?.examDate;
        final reminderTime = auth.currentUser?.reminderTime ?? 'Not set';

        // Calculate days remaining from user's saved exam date
        int daysRemaining = 0;
        String nextExamLabel = 'Not scheduled';
        if (examDate != null) {
          final diff = examDate.difference(DateTime.now());
          daysRemaining = diff.inDays.clamp(0, 9999);
          nextExamLabel = '${examDate.day}/${examDate.month}/${examDate.year} • Reminder: $reminderTime';
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: ExamCountdownCard(daysRemaining: daysRemaining)),
                const SizedBox(width: 12),
                Expanded(child: StreakMilestoneCard(streak: progress.streak)),
              ],
            ),
            const SizedBox(height: 12),
            NextExamCard(
              dateLabel: nextExamLabel,
              subtitle: examDate != null ? 'National Exit Exam Countdown' : 'Set exam date in your profile',
            ),
          ],
        );
      },
    );
  }
}
