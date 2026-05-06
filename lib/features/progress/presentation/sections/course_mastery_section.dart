import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/progress_bar_row.dart';
import '../../../courses/presentation/providers/course_provider.dart';
import '../providers/progress_provider.dart';

/// Course mastery breakdown with labeled progress bars.
class CourseMasterySection extends StatelessWidget {
  const CourseMasterySection({super.key});

  // Replace with real data from CourseProvider / ProgressProvider
  @override
  Widget build(BuildContext context) {
    return Consumer2<CourseProvider, ProgressProvider>(
      builder: (context, courseProvider, progressProvider, _) {
        final courses = courseProvider.courses;
        
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.lOutlineVariant),
            boxShadow: const [BoxShadow(color: Color(0x08002045), blurRadius: 12)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.leaderboard_rounded, color: AppColors.lPrimary, size: 20),
                const SizedBox(width: 8),
                Text('Course Mastery', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.lPrimary)),
              ]),
              const SizedBox(height: 20),
              if (courses.isEmpty)
                Center(child: Text('No courses tracked yet.', style: GoogleFonts.inter(color: AppColors.lOnSurfaceVariant))),
              ...courses.map((course) {
                // In a full implementation, this would be calculated per course.
                // For now, we use a proxy or placeholder logic linked to course materials.
                final mastery = course.materialUrls.isNotEmpty ? 0.65 : 0.0;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: ProgressBarRow(
                    label: course.courseName,
                    trailingLabel: '${(mastery * 100).round()}%',
                    value: mastery,
                    barColor: AppColors.lPrimary,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

