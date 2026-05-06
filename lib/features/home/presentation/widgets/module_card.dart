import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/progress_bar_row.dart';
import '../../../courses/presentation/providers/course_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// Reusable module progress card matching the HTML bento grid cards.
class ModuleCard extends StatelessWidget {
  final String subject;
  final String title;
  final int unitCount;
  final int quizCount;
  final double progress;
  final String? theme;
  final double? courseShare;
  final String courseId;
  final bool hasMaterial;

  const ModuleCard({
    super.key,
    required this.subject,
    required this.title,
    required this.unitCount,
    required this.quizCount,
    required this.progress,
    required this.courseId,
    this.theme,
    this.courseShare,
    this.hasMaterial = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lOutlineVariant),
        boxShadow: const [BoxShadow(color: Color(0x06002045), blurRadius: 8)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: 4, color: hasMaterial ? AppColors.lSecondary : AppColors.lPrimary),
        Padding(padding: const EdgeInsets.all(18), child: _CardBody(
          subject: subject, title: title, unitCount: unitCount,
          quizCount: quizCount, progress: progress, courseId: courseId,
          theme: theme, courseShare: courseShare, hasMaterial: hasMaterial,
        )),
      ]),
    );
  }
}

class _CardBody extends StatelessWidget {
  final String subject, title, courseId;
  final int unitCount, quizCount;
  final double progress;
  final String? theme;
  final double? courseShare;
  final bool hasMaterial;
  const _CardBody({required this.subject, required this.title, required this.unitCount,
    required this.quizCount, required this.progress, required this.courseId,
    this.theme, this.courseShare, required this.hasMaterial});

  @override
  Widget build(BuildContext context) {
    final pct = '${(progress * 100).round()}% Complete';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: AppColors.lPrimaryFixed, borderRadius: BorderRadius.circular(6)),
          child: Text(subject, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.lOnPrimaryFixed, letterSpacing: 0.6)),
        ),
        if (hasMaterial)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.lSecondaryContainer, borderRadius: BorderRadius.circular(6)),
            child: Text('FILLED', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.lSecondary, letterSpacing: 0.4)),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.lSurfaceContainerHigh, borderRadius: BorderRadius.circular(6)),
            child: Text('EMPTY', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.lOnSurfaceVariant, letterSpacing: 0.4)),
          ),
        const Spacer(),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20, color: AppColors.lOnSurfaceVariant),
          onSelected: (val) async {
            if (val == 'delete') {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final provider = Provider.of<CourseProvider>(context, listen: false);
              await provider.deleteCourse(auth.currentUser?.id ?? 'demo_user', courseId);
            }
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(value: 'delete', child: Text('Delete Course', style: TextStyle(color: AppColors.lError, fontSize: 13, fontWeight: FontWeight.w600))),
          ],
        ),
        Text(pct, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.lSecondary)),
      ]),
      const SizedBox(height: 10),
      Text(title, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.lPrimary, height: 1.3)),
      const SizedBox(height: 12),
      ProgressBarRow(value: progress),
      const SizedBox(height: 14),
      Row(children: [
        const Icon(Icons.menu_book_outlined, size: 15, color: AppColors.lOnSurfaceVariant),
        const SizedBox(width: 4),
        Text('$unitCount Units', style: GoogleFonts.inter(fontSize: 13, color: AppColors.lOnSurfaceVariant)),
        const SizedBox(width: 16),
        const Icon(Icons.quiz_outlined, size: 15, color: AppColors.lOnSurfaceVariant),
        const SizedBox(width: 4),
        Text('$quizCount Quizzes', style: GoogleFonts.inter(fontSize: 13, color: AppColors.lOnSurfaceVariant)),
        if (courseShare != null) ...[
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.lSecondaryContainer, borderRadius: BorderRadius.circular(6)),
            child: Text('${courseShare!.toStringAsFixed(1)}% Share', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.lSecondary)),
          ),
        ],
      ]),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, child: OutlinedButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.quizList, arguments: {'courseId': courseId}),
        style: OutlinedButton.styleFrom(foregroundColor: AppColors.lPrimary, side: const BorderSide(color: AppColors.lPrimary),
          padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: Text('Continue Learning', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      )),
    ]);
  }
}
