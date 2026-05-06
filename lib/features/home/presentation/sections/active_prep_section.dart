import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../courses/presentation/providers/course_provider.dart';
import '../../../quizzes/presentation/providers/quiz_provider.dart';
import '../widgets/module_card.dart';
import '../widgets/performance_insight_card.dart';

/// Active Preparation section — header + bento grid of module cards.
class ActivePrepSection extends StatelessWidget {
  const ActivePrepSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CourseProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Active Preparation', 
                        style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.lPrimary, letterSpacing: -0.5)),
                      Text('Track your progress across core modules', 
                        style: GoogleFonts.inter(fontSize: 14, color: AppColors.lOnSurfaceVariant)),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.stats),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: Text('Stats', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  style: TextButton.styleFrom(foregroundColor: AppColors.lPrimary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (provider.isLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(48.0),
                child: CircularProgressIndicator(),
              ))
            else if (provider.courses.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.lSurfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.lOutlineVariant),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppColors.lPrimaryFixed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.upload_file, size: 40, color: AppColors.lPrimary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Blueprint Uploaded Yet',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.lPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Go to the Lab, select your department, and upload the official exit exam blueprint to generate your course map.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.lOnSurfaceVariant),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.lab),
                      icon: const Icon(Icons.science_rounded, size: 18),
                      label: Text('Open Lab', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // Mock Exam Trigger — only shown when courses exist from a real blueprint
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: InkWell(
                  onTap: () async {
                    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    final userId = authProvider.currentUser?.id ?? 'demo_user';
                    final mock = await quizProvider.generateMockExam(userId, provider.courses);
                    if (mock != null && context.mounted) {
                      Navigator.pushNamed(context, AppRoutes.takeQuiz);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.lPrimary, AppColors.lPrimary.withValues(alpha: 0.8)]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stars_rounded, color: Colors.white, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('National Mock Exam', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(
                                '${provider.courses.fold(0, (sum, c) => sum + (c.itemShareCount ?? 0))} questions • Blueprint aligned',
                                style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Course Cards
              ...provider.courses.map((course) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: ModuleCard(
                  subject: course.courseCode,
                  title: course.courseName,
                  unitCount: course.topics.length,
                  quizCount: 0,
                  progress: 0.0,
                  courseId: course.id,
                  theme: course.theme,
                  courseShare: course.courseShare,
                  hasMaterial: course.materialUrls.isNotEmpty,
                ),
              )),
              const PerformanceInsightCard(),
            ],
          ],
        );
      },
    );
  }
}
