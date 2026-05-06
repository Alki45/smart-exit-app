import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

/// Streak milestone card shown in the exam milestones row.
class StreakMilestoneCard extends StatelessWidget {
  final int streak;
  const StreakMilestoneCard({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.lSurfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('STUDY STREAK',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
              color: AppColors.lOnSurfaceVariant, letterSpacing: 0.5)),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('$streak Days',
                style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.lPrimary)),
              const SizedBox(width: 6),
              const Icon(Icons.local_fire_department_rounded, color: AppColors.lSecondary, size: 22),
            ]),
            Text('Top 5% of users in Addis Ababa',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.lOnSurfaceVariant)),
          ]),
        ],
      ),
    );
  }
}
