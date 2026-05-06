import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/trend_bar_column.dart';

/// Performance trend card with 4-week animated bar chart.
class PerformanceTrendSection extends StatelessWidget {
  const PerformanceTrendSection({super.key});

  // Weekly scores 0.0–1.0 — swap with real ProgressProvider data when ready.
  static const _weeks = [
    ('WK 1', 0.30), ('WK 2', 0.45), ('WK 3', 0.55), ('WK 4', 0.65),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lOutlineVariant),
        boxShadow: const [BoxShadow(color: Color(0x08002045), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Performance Trend',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.lPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.lPrimaryFixed, borderRadius: BorderRadius.circular(99)),
                child: Text('LAST 30 DAYS',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.lOnPrimaryFixed)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _weeks
                .map((w) => Expanded(child: TrendBarColumn(weekLabel: w.$1, value: w.$2)))
                .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
