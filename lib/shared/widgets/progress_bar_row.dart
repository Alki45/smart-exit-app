import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Labeled linear progress bar row.
/// Used in ModuleCard and Coursemastery sections.
class ProgressBarRow extends StatelessWidget {
  final String? label;
  final String? trailingLabel;
  final double value; // 0.0 to 1.0
  final Color barColor;
  final double height;

  const ProgressBarRow({
    super.key,
    this.label,
    this.trailingLabel,
    required this.value,
    this.barColor = AppColors.lSecondary,
    this.height = 7,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || trailingLabel != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lOnSurface,
                    ),
                  ),
                if (trailingLabel != null)
                  Text(
                    trailingLabel!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: barColor,
                    ),
                  ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            backgroundColor: AppColors.lSurfaceContainer,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: height,
          ),
        ),
      ],
    );
  }
}
