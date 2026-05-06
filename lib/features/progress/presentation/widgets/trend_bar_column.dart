import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

/// Weekly bar column for the performance trend chart.
class TrendBarColumn extends StatelessWidget {
  final String weekLabel;
  final double value; // 0.0–1.0

  const TrendBarColumn({super.key, required this.weekLabel, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            width: double.infinity,
            height: 120 * value,
            decoration: BoxDecoration(
              color: AppColors.lPrimaryFixed,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              width: 10, height: 10,
              decoration: const BoxDecoration(color: AppColors.lPrimary, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(height: 6),
          Text(weekLabel,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.lOutline)),
        ],
      ),
    );
  }
}
