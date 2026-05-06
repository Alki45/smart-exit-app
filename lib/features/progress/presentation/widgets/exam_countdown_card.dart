import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

/// Countdown card — navy background, shows days to exam.
class ExamCountdownCard extends StatelessWidget {
  final int daysRemaining;
  const ExamCountdownCard({super.key, this.daysRemaining = 42});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.lPrimary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(right: -16, bottom: -16,
            child: Icon(Icons.event_rounded, size: 90, color: Colors.white.withOpacity(0.1))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('NATIONAL EXIT EXAM',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                  color: AppColors.lPrimaryFixed, letterSpacing: 0.5)),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('$daysRemaining Days',
                  style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('Time remaining until finals',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.lPrimaryFixed)),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
