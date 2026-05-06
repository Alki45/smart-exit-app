import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/progress_bar_row.dart';
import '../../../quizzes/presentation/providers/quiz_provider.dart';

/// Dark navy performance insights card — the 3rd bento cell in Active Prep.
class PerformanceInsightCard extends StatelessWidget {
  const PerformanceInsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, _) {
        final stats = quizProvider.globalTopicPerformance;
        if (stats.isEmpty) return const SizedBox.shrink();

        final entries = stats.entries.toList();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.lPrimaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Performance Insights', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 6),
              Text('Based on your recent practice tests.', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
              const SizedBox(height: 20),
              ...entries.take(2).map((entry) {
                final topic = entry.key;
                final correct = entry.value['correct']!;
                final total = entry.value['total']!;
                final value = total > 0 ? correct / total : 0.0;
                final pct = '${(value * 100).round()}%';
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _InsightBar(
                    label: topic, 
                    value: value, 
                    valueLabel: pct,
                    barColor: value < 0.5 ? AppColors.lError : AppColors.lSecondaryFixed,
                  ),
                );
              }),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.stats),
                icon: const Icon(Icons.analytics_outlined, size: 16, color: Colors.white),
                label: Text('View Detailed Analytics', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InsightBar extends StatelessWidget {
  final String label;
  final double value;
  final String valueLabel;
  final Color barColor;

  const _InsightBar({required this.label, required this.value, required this.valueLabel, this.barColor = AppColors.lSecondaryFixed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 13, color: Colors.white)),
            Text(valueLabel, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
