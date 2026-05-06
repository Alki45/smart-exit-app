import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

/// Next mock exam card with reminder button.
class NextExamCard extends StatelessWidget {
  final String dateLabel;
  final String subtitle;
  const NextExamCard({
    super.key,
    this.dateLabel = 'Saturday, 10:00 AM',
    this.subtitle = 'Full Comprehensive Simulation',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lOutlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('NEXT MOCK EXAM',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                color: AppColors.lOnSurfaceVariant, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Text(dateLabel,
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.lPrimary)),
            Text(subtitle,
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.lOnSurfaceVariant, fontStyle: FontStyle.italic)),
          ]),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lPrimary,
              foregroundColor: Colors.white,
              textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('SET REMINDER'),
          ),
        ],
      ),
    );
  }
}
