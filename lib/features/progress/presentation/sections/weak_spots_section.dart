import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../quizzes/presentation/providers/quiz_provider.dart';
import '../widgets/insight_card.dart';

/// AI Weak Spot Insights section — list of insight cards.
class WeakSpotsSection extends StatelessWidget {
  const WeakSpotsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, _) {
        final stats = quizProvider.globalTopicPerformance;
        final weakSpots = stats.entries
            .where((e) => (e.value['correct']! / e.value['total']!) < 0.7)
            .toList();

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.lOutlineVariant),
            boxShadow: const [BoxShadow(color: Color(0x08002045), blurRadius: 12)],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 4, color: AppColors.lPrimary),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.psychology_rounded, color: AppColors.lPrimary, size: 20),
                      const SizedBox(width: 8),
                      Text('AI Weak Spot Insights',
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.lPrimary)),
                    ]),
                    const SizedBox(height: 16),
                    if (weakSpots.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text('No major weak spots detected! Keep it up.', style: GoogleFonts.inter(color: AppColors.lOnSurfaceVariant)),
                        ),
                      ),
                    ...weakSpots.map((e) {
                      final accuracy = (e.value['correct']! / e.value['total']! * 100).round();
                      return InsightCard(
                        icon: Icons.warning_rounded, iconColor: AppColors.lError,
                        title: e.key,
                        body: 'Your accuracy in ${e.key} is currently $accuracy%. You\'ve missed ${e.value['total']! - e.value['correct']!} questions here.',
                        actionLabel: 'START FOCUS SESSION',
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
