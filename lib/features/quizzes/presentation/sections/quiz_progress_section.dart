import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

/// Quiz progress bar section — question counter + linear progress.
class QuizProgressSection extends StatelessWidget {
  final int current;
  final int total;

  const QuizProgressSection({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? current / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CURRENT SESSION', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: AppColors.lOnSurfaceVariant)),
                const SizedBox(height: 2),
                Text('Question $current of $total', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.lPrimary)),
              ],
            ),
            Text('${(pct * 100).round()}% Complete', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.lPrimary)),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: AppColors.lSurfaceContainer,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.lPrimary),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
