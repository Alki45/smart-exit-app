import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../sections/readiness_score_section.dart';
import '../sections/performance_trend_section.dart';
import '../sections/course_mastery_section.dart';
import '../sections/weak_spots_section.dart';
import '../sections/exam_milestones_section.dart';

/// Stats / My Progress screen — thin shell composing all stats sections.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lBackground,
      appBar: AppTopBar(
        rightSlot: Row(children: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.lOnSurfaceVariant), onPressed: () {}),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Progress', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.lPrimary, letterSpacing: -0.3)),
            const SizedBox(height: 20),
            const ReadinessScoreSection(),
            const SizedBox(height: 16),
            const PerformanceTrendSection(),
            const SizedBox(height: 16),
            const CourseMasterySection(),
            const SizedBox(height: 16),
            const WeakSpotsSection(),
            const SizedBox(height: 16),
            const ExamMilestonesSection(),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}
